{{- /*
(c) 2026 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Image rendering.
*/}}
{{- define "freeradius.image" -}}
  {{ include "st-common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{- define "freeradius.volumePermissions.image" -}}
  {{ include "st-common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/*
Image used by the `db-bootstrap` init container. Auto-swaps to a
dialect-appropriate default when the user is still on the chart's default
`bitnami/mariadb` repository and `modules.sql.dialect: postgresql` —
the default image only ships the `mysql` client, so a postgresql user
would otherwise have to override two unrelated keys to make bootstrap work.
Explicit user overrides (any non-default repository) always win.
*/}}
{{- define "freeradius.bootstrap.database.image" -}}
{{- $img := .Values.bootstrap.database.image -}}
{{- if and (eq $img.repository "bitnami/mariadb") (eq .Values.modules.sql.dialect "postgresql") -}}
  {{- $img = dict "registry" $img.registry "repository" "bitnami/postgresql" "tag" "17" "digest" "" "pullPolicy" $img.pullPolicy "pullSecrets" $img.pullSecrets -}}
{{- end -}}
{{ include "st-common.images.image" (dict "imageRoot" $img "global" .Values.global) }}
{{- end -}}

{{- define "freeradius.metrics.image" -}}
  {{ include "st-common.images.image" (dict "imageRoot" .Values.metrics.image "global" .Values.global) }}
{{- end -}}

{{/*
Name of the chart-rendered metrics exporter Deployment / Service / ServiceAccount.
*/}}
{{- define "freeradius.metrics.fullname" -}}
{{- printf "%s-metrics" (include "st-common.names.fullname" .) -}}
{{- end -}}

{{- define "freeradius.imagePullSecrets" -}}
  {{- include "st-common.images.pullSecrets" (dict "images" (list .Values.image .Values.volumePermissions.image .Values.metrics.image .Values.bootstrap.database.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Name of the ConfigMap holding the rlm_sql schema loaded by the `db-bootstrap`
init container. Resolution order:
  1. `bootstrap.database.schemaConfigMap` — BYO ConfigMap.
  2. Chart-rendered `<fullname>-db-schema` from `templates/configmap/db-schema.yaml`.
*/}}
{{- define "freeradius.bootstrap.database.schemaConfigMapName" -}}
{{- default (printf "%s-db-schema" (include "st-common.names.fullname" .)) .Values.bootstrap.database.schemaConfigMap -}}
{{- end -}}

{{/*
CLI command the `db-bootstrap` init container uses to apply the schema, derived
from `modules.sql.dialect`. Returns an empty string for dialects that don't
need a separate schema load (sqlite).
*/}}
{{- define "freeradius.bootstrap.database.cmd" -}}
{{- $dialect := .Values.modules.sql.dialect -}}
{{- if eq $dialect "mysql" -}}
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < /schema/schema.sql
{{- else if eq $dialect "postgresql" -}}
PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f /schema/schema.sql
{{- end -}}
{{- end -}}

{{/*
ServiceAccount name resolution.
*/}}
{{- define "freeradius.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
  {{- default (include "st-common.names.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
  {{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
PersistentVolumeClaim name resolution.
*/}}
{{- define "freeradius.claimName" -}}
{{- if .Values.persistence.existingClaim -}}
  {{- tpl .Values.persistence.existingClaim $ -}}
{{- else -}}
  {{- include "st-common.names.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Env-vars ConfigMap name (BYO via existingConfigmap, otherwise chart-rendered).
*/}}
{{- define "freeradius.names.envvars" -}}
{{- default (printf "%s-envvars" (include "st-common.names.fullname" .)) .Values.existingConfigmap -}}
{{- end -}}

{{/*
Configurations ConfigMap name (BYO via configurationsConfigMap, otherwise chart-rendered).
*/}}
{{- define "freeradius.configurationCM" -}}
{{- if .Values.configurationsConfigMap -}}
  {{- tpl .Values.configurationsConfigMap $ -}}
{{- else -}}
  {{- printf "%s-configurations" (include "st-common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
initdb scripts ConfigMap name (BYO via initdbScriptsConfigMap, otherwise chart-rendered).
*/}}
{{- define "freeradius.initdbScriptsCM" -}}
{{- default (printf "%s-init-scripts" (include "st-common.names.fullname" .)) .Values.initdbScriptsConfigMap -}}
{{- end -}}

{{/*
RADSEC in-pod TLS secret name. Resolution order:
  1. tls.certificatesSecret      — BYO Secret (chart-managed leaf).
  2. tls.existingSecretName      — deprecated alias (kept for backwards compatibility).
  3. <fullname>-tls              — chart-managed default (auto-generated, cert-manager, etc.).
*/}}
{{- define "freeradius.tls.secretName" -}}
{{- if .Values.tls.certificatesSecret -}}
{{- .Values.tls.certificatesSecret -}}
{{- else if .Values.tls.existingSecretName -}}
{{- .Values.tls.existingSecretName -}}
{{- else -}}
{{- printf "%s-tls" (include "st-common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Whether the chart should render `templates/secret/tls.yaml` with a self-signed
RADSEC leaf. False when the user is bringing their own Secret or cert-manager
owns issuance.
*/}}
{{- define "freeradius.tls.createSecret" -}}
{{- if and .Values.tls.enabled .Values.tls.autoGenerated (not .Values.tls.certificatesSecret) (not .Values.tls.existingSecretName) (not .Values.tls.certManager.create) -}}
true
{{- end -}}
{{- end -}}

{{/*
Validation aggregator. Each chart-defined `freeradius.<area>.validate` helper
returns a non-empty string when its precondition is violated, otherwise the
empty string. This template gathers all of them, drops the empty entries, and
calls `fail` when anything remains so `helm install` / `helm upgrade` / `helm
template` reject the misconfigured release before any resource is applied.

Include from `NOTES.txt` (Helm renders NOTES.txt as part of the install path,
so a `fail` here aborts the operation).
*/}}
{{- define "freeradius.validateValues" -}}
{{- $messages := list -}}
{{- $messages = append $messages (include "freeradius.tls.validate" .) -}}
{{- $messages = append $messages (include "freeradius.metrics.validate" .) -}}
{{- $messages = append $messages (include "freeradius.sql.backend.validate" .) -}}
{{- $messages = append $messages (include "freeradius.rest.validate" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}
{{- if $message -}}
{{- printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Validation message: RADSEC enabled but no cert source configured.
*/}}
{{- define "freeradius.tls.validate" -}}
{{- if and .Values.tls.enabled (not .Values.tls.autoGenerated) (not .Values.tls.certificatesSecret) (not .Values.tls.existingSecretName) (not .Values.tls.certManager.create) -}}
freeradius: tls.enabled
    In order to enable RADSEC TLS (`tls.enabled: true`), you must also configure
    a certificate source. Set one of:
      - tls.autoGenerated: true            (chart generates a self-signed leaf)
      - tls.certificatesSecret: <name>     (BYO Secret already in the namespace)
      - tls.certManager.create: true       (cert-manager issues the Certificate)
{{- end -}}
{{- end -}}

{{/*
Validation message: metrics enabled but the RADIUS `status` virtual server is
disabled — the standalone exporter Deployment would have nothing to scrape.
*/}}
{{- define "freeradius.metrics.validate" -}}
{{- if and .Values.metrics.enabled (not .Values.sites.status.enabled) -}}
freeradius: metrics.enabled
    `metrics.enabled: true` requires `sites.status.enabled: true`.
    The bvantagelimited/freeradius_exporter Deployment reaches the RADIUS
    `status` virtual server through the cluster Service to scrape its
    counters — disabling the status site leaves the exporter with nothing
    to read, so the chart refuses to render this combination.
{{- end -}}
{{- end -}}

{{/*
Validation message: SQL backend selection must be coherent.

Rejects:
  - both bundled subcharts enabled at once,
  - a bundled subchart whose wire protocol doesn't match `modules.sql.dialect`,
  - `dialect: sqlite` with any bundled subchart enabled (sqlite is file-based),
  - `dialect: mysql|postgresql` with no subchart AND empty `externalDatabase.host`
    (no backend at all).
*/}}
{{- define "freeradius.sql.backend.validate" -}}
{{- if .Values.modules.sql.enabled -}}
{{- $dialect    := .Values.modules.sql.dialect -}}
{{- $mariadb    := .Values.mariadb.enabled -}}
{{- $postgresql := .Values.postgresql.enabled -}}
{{- if and $mariadb $postgresql -}}
freeradius: mariadb.enabled / postgresql.enabled
    Only one bundled database subchart may be enabled at a time. Set either
    `mariadb.enabled: true` (mysql dialect) or `postgresql.enabled: true`
    (postgresql dialect), not both.
{{- else if and (eq $dialect "sqlite") (or $mariadb $postgresql) -}}
freeradius: modules.sql.dialect=sqlite
    SQLite is a file-based engine — disable both bundled subcharts
    (`mariadb.enabled: false`, `postgresql.enabled: false`) and configure
    the SQLite file via `modules.sql.sqlite.*`.
{{- else if and $mariadb (ne $dialect "mysql") -}}
freeradius: mariadb.enabled
    `mariadb.enabled: true` requires `modules.sql.dialect: mysql`
    (currently `{{ $dialect }}`). The bundled MariaDB subchart only speaks
    the MySQL wire protocol.
{{- else if and $postgresql (ne $dialect "postgresql") -}}
freeradius: postgresql.enabled
    `postgresql.enabled: true` requires `modules.sql.dialect: postgresql`
    (currently `{{ $dialect }}`). The bundled PostgreSQL subchart only speaks
    the PostgreSQL wire protocol.
{{- else if and (ne $dialect "sqlite") (not $mariadb) (not $postgresql) (not .Values.externalDatabase.host) -}}
freeradius: modules.sql.dialect={{ $dialect }}
    No database backend is configured. Either enable a bundled subchart
    matching the dialect (`mariadb.enabled: true` for mysql,
    `postgresql.enabled: true` for postgresql) or point at an external
    database via `externalDatabase.host`. For a file-based backend, set
    `modules.sql.dialect: sqlite`.
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validation message: REST module configuration coherence.

Rejects:
  - `rest.enabled: true` with empty `rest.connectUri`,
  - `rest.auth != none` with no password source (no `password`, no
    `existingSecret`),
  - `rest.tls.enabled: true` with no cert source (no `autoGenerated`, no
    `certificatesSecret`),
  - `rest.auth` set to something other than the four known values.

Server-cert verification (`tls.checkCert*`) is independent of client-cert
material so it's not validated here — those flags work against the system
CA bundle when no `tls.*` material is mounted.
*/}}
{{- define "freeradius.rest.validate" -}}
{{- if .Values.modules.rest.enabled -}}
{{- $auth := .Values.modules.rest.auth -}}
{{- $allowedAuth := list "none" "basic" "digest" "bearer" -}}
{{- if not .Values.modules.rest.connectUri -}}
freeradius: modules.rest.enabled
    `modules.rest.enabled: true` requires a non-empty
    `modules.rest.connectUri` — rlm_rest has nothing to call without it.
{{- else if not (has $auth $allowedAuth) -}}
freeradius: modules.rest.auth
    `modules.rest.auth: {{ $auth }}` is not a recognised value. Allowed:
    `none`, `basic`, `digest`, `bearer`.
{{- else if and (ne $auth "none") (not .Values.modules.rest.password) (not .Values.modules.rest.existingSecret) -}}
freeradius: modules.rest.auth={{ $auth }}
    `modules.rest.auth: {{ $auth }}` requires a password source. Set
    one of:
      - modules.rest.password: <value>          (chart-managed Secret)
      - modules.rest.existingSecret: <name>     (BYO Secret already in the namespace)
{{- else if and .Values.modules.rest.tls.enabled (not .Values.modules.rest.tls.autoGenerated) (not .Values.modules.rest.tls.certificatesSecret) -}}
freeradius: modules.rest.tls.enabled
    `modules.rest.tls.enabled: true` requires a TLS material source.
    Set one of:
      - modules.rest.tls.autoGenerated: true        (chart generates a self-signed leaf)
      - modules.rest.tls.certificatesSecret: <name> (BYO Secret already in the namespace)
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
RADSEC in-pod TLS material paths (used by the env-vars ConfigMap to point
FreeRADIUS at the certificate files mounted from the Secret).
*/}}
{{- define "freeradius.tls.certPath" -}}
{{- if .Values.tls.certFilename -}}
  {{- printf "%s/%s" .Values.tls.certificatesMountPath .Values.tls.certFilename -}}
{{- else -}}
  {{- printf "%s/tls.crt" .Values.tls.certificatesMountPath -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.tls.certKeyPath" -}}
{{- if .Values.tls.certKeyFilename -}}
  {{- printf "%s/%s" .Values.tls.certificatesMountPath .Values.tls.certKeyFilename -}}
{{- else -}}
  {{- printf "%s/tls.key" .Values.tls.certificatesMountPath -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.tls.caCertPath" -}}
{{- if .Values.tls.certCAFilename -}}
  {{- printf "%s/%s" .Values.tls.certificatesMountPath .Values.tls.certCAFilename -}}
{{- else -}}
  {{- printf "%s/ca.crt" .Values.tls.certificatesMountPath -}}
{{- end -}}
{{- end -}}

{{/*
SQL backend TLS — separate namespace from the in-pod RADSEC TLS above.
Material paths assume the SQL TLS Secret is mounted at
`/opt/startechnica/freeradius/certs` (see Deployment.yaml `freeradius-sql-tls`
volumeMount).
*/}}
{{- define "freeradius.sql.tls.certPath" -}}
{{- if .Values.modules.sql.tls.enabled -}}
  {{- if .Values.modules.sql.tls.autoGenerated -}}
    {{- printf "/opt/startechnica/freeradius/certs/sql-tls.crt" -}}
  {{- else if .Values.modules.sql.tls.certFilename -}}
    {{- printf "/opt/startechnica/freeradius/certs/%s" .Values.modules.sql.tls.certFilename -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.sql.tls.certKeyPath" -}}
{{- if .Values.modules.sql.tls.enabled -}}
  {{- if .Values.modules.sql.tls.autoGenerated -}}
    {{- printf "/opt/startechnica/freeradius/certs/sql-tls.key" -}}
  {{- else if .Values.modules.sql.tls.certKeyFilename -}}
    {{- printf "/opt/startechnica/freeradius/certs/%s" .Values.modules.sql.tls.certKeyFilename -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.sql.tls.caCertPath" -}}
{{- if .Values.modules.sql.tls.enabled -}}
  {{- if .Values.modules.sql.tls.autoGenerated -}}
    {{- printf "/opt/startechnica/freeradius/certs/sql-ca.crt" -}}
  {{- else if .Values.modules.sql.tls.certCAFilename -}}
    {{- printf "/opt/startechnica/freeradius/certs/%s" .Values.modules.sql.tls.certCAFilename -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.sql.tls.secretName" -}}
{{- if .Values.modules.sql.tls.certificatesSecret -}}
{{- .Values.modules.sql.tls.certificatesSecret -}}
{{- else if .Values.modules.sql.tls.existingTlsSecret -}}
{{- .Values.modules.sql.tls.existingTlsSecret -}}
{{- else -}}
{{- printf "%s-sql-tls" (include "st-common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.sql.tls.createSecret" -}}
{{- if and .Values.modules.sql.tls.enabled .Values.modules.sql.tls.autoGenerated (not .Values.modules.sql.tls.certificatesSecret) (not .Values.modules.sql.tls.existingTlsSecret) -}}
true
{{- end -}}
{{- end -}}

{{/*
REST module TLS — third TLS namespace (after RADSEC and SQL).
Material paths assume the REST TLS Secret is mounted at
`/opt/startechnica/freeradius/certs-rest` (see Deployment.yaml
`freeradius-rest-tls` volumeMount). Each *Path helper returns the empty string
when its source material isn't configured, so rlm_rest's `tls{}` block falls
back to the system CA bundle / no client cert.
*/}}
{{- define "freeradius.rest.tls.certPath" -}}
{{- if .Values.modules.rest.tls.enabled -}}
  {{- if .Values.modules.rest.tls.certFilename -}}
    {{- printf "/opt/startechnica/freeradius/certs-rest/%s" .Values.modules.rest.tls.certFilename -}}
  {{- else if or .Values.modules.rest.tls.autoGenerated .Values.modules.rest.tls.certificatesSecret -}}
    {{- printf "/opt/startechnica/freeradius/certs-rest/tls.crt" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.rest.tls.certKeyPath" -}}
{{- if .Values.modules.rest.tls.enabled -}}
  {{- if .Values.modules.rest.tls.certKeyFilename -}}
    {{- printf "/opt/startechnica/freeradius/certs-rest/%s" .Values.modules.rest.tls.certKeyFilename -}}
  {{- else if or .Values.modules.rest.tls.autoGenerated .Values.modules.rest.tls.certificatesSecret -}}
    {{- printf "/opt/startechnica/freeradius/certs-rest/tls.key" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.rest.tls.caCertPath" -}}
{{- if .Values.modules.rest.tls.enabled -}}
  {{- if .Values.modules.rest.tls.certCAFilename -}}
    {{- printf "/opt/startechnica/freeradius/certs-rest/%s" .Values.modules.rest.tls.certCAFilename -}}
  {{- else if or .Values.modules.rest.tls.autoGenerated .Values.modules.rest.tls.certificatesSecret -}}
    {{- printf "/opt/startechnica/freeradius/certs-rest/ca.crt" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.rest.tls.secretName" -}}
{{- if .Values.modules.rest.tls.certificatesSecret -}}
{{- .Values.modules.rest.tls.certificatesSecret -}}
{{- else -}}
{{- printf "%s-rest-tls" (include "st-common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.rest.tls.createSecret" -}}
{{- if and .Values.modules.rest.enabled .Values.modules.rest.tls.enabled .Values.modules.rest.tls.autoGenerated (not .Values.modules.rest.tls.certificatesSecret) -}}
true
{{- end -}}
{{- end -}}

{{/*
REST password Secret resolution. Bring-your-own via `existingSecret`;
otherwise the chart-managed credentials Secret (`auth.existingSecret`) holds
the password under `mods-rest-password`. Mirrors `freeradius.sql.secretName`
and `freeradius.sql.secretKey` for the in-chart-managed branch.
*/}}
{{- define "freeradius.rest.secretName" -}}
{{- if .Values.modules.rest.existingSecret -}}
{{- tpl .Values.modules.rest.existingSecret $ -}}
{{- else -}}
{{- include "st-common.secrets.name" (dict "existingSecret" .Values.auth.existingSecret "context" $) -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.rest.secretKey" -}}
{{- if and .Values.modules.rest.existingSecret .Values.modules.rest.existingSecretPasswordKey -}}
{{- .Values.modules.rest.existingSecretPasswordKey -}}
{{- else -}}
{{- print "mods-rest-password" -}}
{{- end -}}
{{- end -}}

{{/*
Bundled-subchart fullnames. Resolved via `st-common.names.dependency.fullname`
so they honour `fullnameOverride` and the subchart's own naming knobs.
*/}}
{{- define "freeradius.mariadb.fullname" -}}
  {{- include "st-common.names.dependency.fullname" (dict "chartName" "mariadb" "chartValues" .Values.mariadb "context" $) -}}
{{- end -}}

{{- define "freeradius.postgresql.fullname" -}}
  {{- include "st-common.names.dependency.fullname" (dict "chartName" "postgresql" "chartValues" .Values.postgresql "context" $) -}}
{{- end -}}

{{/*
SQL backend connection helpers — single source of truth for both the env-vars
ConfigMap (`FREERADIUS_MODS_SQL_*`) and the `db-bootstrap` init container.

Resolution order (first match wins):
  1. `mariadb.enabled`     → bundled MariaDB subchart (mysql wire protocol).
  2. `postgresql.enabled`  → bundled PostgreSQL subchart (postgresql wire protocol).
  3. `externalDatabase.*`  → user-supplied external database (any dialect).

The chart's `freeradius.sql.backend.validate` aggregator rejects misconfigurations
(two subcharts at once, dialect/subchart mismatch, sqlite + subchart, etc.)
before any resource is applied.
*/}}
{{- define "freeradius.sql.host" -}}
{{- if .Values.mariadb.enabled -}}
  {{- if eq .Values.mariadb.architecture "replication" -}}
    {{- printf "%s-primary" (include "freeradius.mariadb.fullname" .) -}}
  {{- else -}}
    {{- include "freeradius.mariadb.fullname" . -}}
  {{- end -}}
{{- else if .Values.postgresql.enabled -}}
  {{- if eq .Values.postgresql.architecture "replication" -}}
    {{- printf "%s-primary" (include "freeradius.postgresql.fullname" .) -}}
  {{- else -}}
    {{- include "freeradius.postgresql.fullname" . -}}
  {{- end -}}
{{- else -}}
  {{- .Values.externalDatabase.host -}}
{{- end -}}
{{- end -}}

{{/*
SQL backend port. Bundled subcharts use their well-known defaults; for the
external case, `externalDatabase.port` wins when set, otherwise the chart
defaults from `modules.sql.dialect` (3306 mysql, 5432 postgresql).
*/}}
{{- define "freeradius.sql.port" -}}
{{- if .Values.mariadb.enabled -}}
  {{- print "3306" | quote -}}
{{- else if .Values.postgresql.enabled -}}
  {{- print "5432" | quote -}}
{{- else if .Values.externalDatabase.port -}}
  {{- .Values.externalDatabase.port | toString | quote -}}
{{- else if eq .Values.modules.sql.dialect "postgresql" -}}
  {{- print "5432" | quote -}}
{{- else -}}
  {{- print "3306" | quote -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.sql.name" -}}
{{- if .Values.mariadb.enabled -}}
  {{- if and .Values.global.mariadb .Values.global.mariadb.auth -}}
    {{- coalesce .Values.global.mariadb.auth.database .Values.mariadb.auth.database -}}
  {{- else -}}
    {{- .Values.mariadb.auth.database -}}
  {{- end -}}
{{- else if .Values.postgresql.enabled -}}
  {{- if and .Values.global.postgresql .Values.global.postgresql.auth -}}
    {{- coalesce .Values.global.postgresql.auth.database .Values.postgresql.auth.database -}}
  {{- else -}}
    {{- .Values.postgresql.auth.database -}}
  {{- end -}}
{{- else -}}
  {{- .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.sql.user" -}}
{{- if .Values.mariadb.enabled -}}
  {{- if and .Values.global.mariadb .Values.global.mariadb.auth -}}
    {{- coalesce .Values.global.mariadb.auth.username .Values.mariadb.auth.username -}}
  {{- else -}}
    {{- .Values.mariadb.auth.username -}}
  {{- end -}}
{{- else if .Values.postgresql.enabled -}}
  {{- if and .Values.global.postgresql .Values.global.postgresql.auth -}}
    {{- coalesce .Values.global.postgresql.auth.username .Values.postgresql.auth.username -}}
  {{- else -}}
    {{- .Values.postgresql.auth.username -}}
  {{- end -}}
{{- else -}}
  {{- .Values.externalDatabase.user -}}
{{- end -}}
{{- end -}}

{{/*
Name of the Secret holding the SQL backend password. For bundled subcharts the
chart points at the subchart's own auth secret (so credentials stay in lockstep
with what the subchart provisions). For external databases, the user's existing
Secret wins, otherwise the chart-managed credentials Secret.
*/}}
{{- define "freeradius.sql.secretName" -}}
{{- if .Values.mariadb.enabled -}}
  {{- if and .Values.global.mariadb .Values.global.mariadb.auth .Values.global.mariadb.auth.existingSecret -}}
    {{- tpl .Values.global.mariadb.auth.existingSecret $ -}}
  {{- else -}}
    {{- default (include "freeradius.mariadb.fullname" .) (tpl .Values.mariadb.auth.existingSecret $) -}}
  {{- end -}}
{{- else if .Values.postgresql.enabled -}}
  {{- if and .Values.global.postgresql .Values.global.postgresql.auth .Values.global.postgresql.auth.existingSecret -}}
    {{- tpl .Values.global.postgresql.auth.existingSecret $ -}}
  {{- else -}}
    {{- default (include "freeradius.postgresql.fullname" .) (tpl .Values.postgresql.auth.existingSecret $) -}}
  {{- end -}}
{{- else -}}
  {{- default (include "st-common.secrets.name" (dict "existingSecret" .Values.auth.existingSecret "context" $)) (tpl .Values.externalDatabase.existingSecret $) -}}
{{- end -}}
{{- end -}}

{{/*
Key inside `freeradius.sql.secretName` that holds the SQL backend password.
The Bitnami subcharts use different key names: mariadb stores it under
`mariadb-password`, postgresql under `password`.
*/}}
{{- define "freeradius.sql.secretKey" -}}
{{- if .Values.mariadb.enabled -}}
  {{- print "mariadb-password" -}}
{{- else if .Values.postgresql.enabled -}}
  {{- print "password" -}}
{{- else if and .Values.externalDatabase.existingSecret .Values.externalDatabase.existingSecretPasswordKey -}}
  {{- printf "%s" .Values.externalDatabase.existingSecretPasswordKey -}}
{{- else -}}
  {{- print "database-password" -}}
{{- end -}}
{{- end -}}

{{/*
Name of the Kubernetes Secret holding the TLS material referenced by the
Gateway TLS listener — `credentialName` on the istio path,
`certificateRefs[].name` on the gateway-api path, and the resource name
produced by `templates/secret/gateway-tls.yaml`. Single source of truth so
the listener and the secret can never drift apart.

Resolution order (first match wins):
  1. `gateway.tls.existingSecret`       — BYO Secret managed outside the chart.
  2. `gateway.tls.secrets[0].name`      — first user-supplied PEM Secret rendered by `templates/secret/gateway-tls.yaml`.
                                          For multi-secret SNI setups, override via `gateway.listeners`.
  3. `<gateway-hostname>-tls`           — chart-managed default that matches the secret name produced by the
                                          self-signed branch in `templates/secret/gateway-tls.yaml` and the
                                          `Certificate.spec.secretName` in `templates/Certificate.yaml`.
                                          Falls back to `<fullname>-tls` when no hostnames are configured.
*/}}
{{- define "freeradius.gateway.tlsSecretName" -}}
{{- if .Values.gateway.tls.existingSecret -}}
{{- .Values.gateway.tls.existingSecret -}}
{{- else if .Values.gateway.tls.secrets -}}
{{- (first .Values.gateway.tls.secrets).name -}}
{{- else if .Values.gateway.hostnames -}}
{{- printf "%s-tls" (first .Values.gateway.hostnames) -}}
{{- else -}}
{{- printf "%s-gateway-tls" (include "st-common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
parentRefs body shared by `templates/gateway-api/UDPRoute.yaml` and
`templates/gateway-api/TLSRoute.yaml`. Returns a YAML list (no leading
`parentRefs:` key); callers are expected to emit the key and pipe through
`nindent`.

Resolution order (first match wins):
  1. Explicit per-route `parentRefs` from values (rendered via
     `st-common.tplvalues.render` so tpl strings inside list entries work).
  2. The chart-rendered ListenerSet — when `gateway.listenerSet.enabled`
     is true, `gateway.listenerSet.listeners` is non-empty, AND the cluster
     exposes a ListenerSet API.
  3. The chart's Gateway, resolved via `st-common.gateway.fullname` /
     `st-common.gateway.namespace` (which honor `gateway.existingGateway`).

Args (dict):
  parentRefs — route-specific override list
               (e.g. `.Values.gateway.udpRoute.parentRefs`).
  context    — root `$` context.
*/}}
{{- define "freeradius.gateway.routeParentRefs" -}}
{{- $ctx := .context -}}
{{- if .parentRefs -}}
{{- include "st-common.tplvalues.render" (dict "value" .parentRefs "context" $ctx) -}}
{{- else -}}
{{- $lsApiVersion := include "st-common.capabilities.networkingGatewayListenerSet.apiVersion" $ctx -}}
{{- if and $ctx.Values.gateway.listenerSet.enabled $ctx.Values.gateway.listenerSet.listeners (ne $lsApiVersion "false") }}
- group: {{ index (splitList "/" $lsApiVersion) 0 }}
  kind: {{ ternary "XListenerSet" "ListenerSet" (eq $lsApiVersion "gateway.networking.x-k8s.io/v1alpha1") }}
  name: {{ include "st-common.names.fullname" $ctx }}
  namespace: {{ include "st-common.names.namespace" $ctx }}
{{- else }}
- group: gateway.networking.k8s.io
  kind: Gateway
  name: {{ include "st-common.gateway.fullname" $ctx }}
  namespace: {{ include "st-common.gateway.namespace" $ctx }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Name of the chart-internal CA Secret (`<fullname>-tls-ca`) holding the
self-signed Certificate Authority shared by the in-pod RADSEC leaf and the
gateway-namespace leaf TLS Secrets.
*/}}
{{- define "freeradius.tls.ca.secretName" -}}
{{- printf "%s-tls-ca" (include "st-common.names.fullname" .) -}}
{{- end -}}

{{/*
Populates `$._freeradiusTlsCa` (root-context cache) with the chart's
self-signed TLS Certificate Authority — a sprig `certificate` struct
compatible with `genSignedCert`.

Recovery chain on first invocation per render:
  1. lookup the persistent CA Secret rendered by `templates/secret/tls-ca.yaml`
     in the release namespace; recover Cert+Key if present.
  2. otherwise fall back to `genCA` (first install path).
*/}}
{{- define "freeradius.tls.ca.init" -}}
{{- if not (hasKey $ "_freeradiusTlsCa") -}}
  {{- $existing := lookup "v1" "Secret" (include "st-common.names.namespace" .) (include "freeradius.tls.ca.secretName" .) -}}
  {{- $ca := "" -}}
  {{- if and $existing $existing.data (hasKey $existing.data "ca.crt") (hasKey $existing.data "ca.key") -}}
    {{- $ca = buildCustomCert (index $existing.data "ca.crt") (index $existing.data "ca.key") -}}
  {{- else -}}
    {{- $ca = genCA "freeradius-ca" 365 -}}
  {{- end -}}
  {{- $_ := set $ "_freeradiusTlsCa" $ca -}}
{{- end -}}
{{- end -}}
