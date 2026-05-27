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
`bitnami/mariadb` repository and `modsEnabled.sql.dialect: postgresql` —
the default image only ships the `mysql` client, so a postgresql user
would otherwise have to override two unrelated keys to make bootstrap work.
Explicit user overrides (any non-default repository) always win.
*/}}
{{- define "freeradius.database.bootstrap.image" -}}
{{- $img := .Values.database.bootstrap.image -}}
{{- if and (eq $img.repository "bitnami/mariadb") (eq .Values.modsEnabled.sql.dialect "postgresql") -}}
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
  {{- include "st-common.images.pullSecrets" (dict "images" (list .Values.image .Values.volumePermissions.image .Values.metrics.image .Values.database.bootstrap.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Name of the ConfigMap holding the rlm_sql schema loaded by the `db-bootstrap`
init container. Resolution order:
  1. `database.bootstrap.schemaConfigMap` — BYO ConfigMap.
  2. Chart-rendered `<fullname>-db-schema` from `templates/configmap/db-schema.yaml`.
*/}}
{{- define "freeradius.database.schemaConfigMapName" -}}
{{- default (printf "%s-db-schema" (include "st-common.names.fullname" .)) .Values.database.bootstrap.schemaConfigMap -}}
{{- end -}}

{{/*
CLI command the `db-bootstrap` init container uses to apply the schema, derived
from `modsEnabled.sql.dialect`. Returns an empty string for dialects that don't
need a separate schema load (sqlite).
*/}}
{{- define "freeradius.database.bootstrap.cmd" -}}
{{- $dialect := .Values.modsEnabled.sql.dialect -}}
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
{{- if and .Values.metrics.enabled (not .Values.sitesEnabled.status.enabled) -}}
freeradius: metrics.enabled
    `metrics.enabled: true` requires `sitesEnabled.status.enabled: true`.
    The bvantagelimited/freeradius_exporter Deployment reaches the RADIUS
    `status` virtual server through the cluster Service to scrape its
    counters — disabling the status site leaves the exporter with nothing
    to read, so the chart refuses to render this combination.
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
{{- if .Values.modsEnabled.sql.tls.enabled -}}
  {{- if .Values.modsEnabled.sql.tls.autoGenerated -}}
    {{- printf "/opt/startechnica/freeradius/certs/sql-tls.crt" -}}
  {{- else if .Values.modsEnabled.sql.tls.certFilename -}}
    {{- printf "/opt/startechnica/freeradius/certs/%s" .Values.modsEnabled.sql.tls.certFilename -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.sql.tls.certKeyPath" -}}
{{- if .Values.modsEnabled.sql.tls.enabled -}}
  {{- if .Values.modsEnabled.sql.tls.autoGenerated -}}
    {{- printf "/opt/startechnica/freeradius/certs/sql-tls.key" -}}
  {{- else if .Values.modsEnabled.sql.tls.certKeyFilename -}}
    {{- printf "/opt/startechnica/freeradius/certs/%s" .Values.modsEnabled.sql.tls.certKeyFilename -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.sql.tls.caCertPath" -}}
{{- if .Values.modsEnabled.sql.tls.enabled -}}
  {{- if .Values.modsEnabled.sql.tls.autoGenerated -}}
    {{- printf "/opt/startechnica/freeradius/certs/sql-ca.crt" -}}
  {{- else if .Values.modsEnabled.sql.tls.certCAFilename -}}
    {{- printf "/opt/startechnica/freeradius/certs/%s" .Values.modsEnabled.sql.tls.certCAFilename -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.sql.tls.secretName" -}}
{{- if .Values.modsEnabled.sql.tls.certificatesSecret -}}
{{- .Values.modsEnabled.sql.tls.certificatesSecret -}}
{{- else if .Values.modsEnabled.sql.tls.existingTlsSecret -}}
{{- .Values.modsEnabled.sql.tls.existingTlsSecret -}}
{{- else -}}
{{- printf "%s-sql-tls" (include "st-common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.sql.tls.createSecret" -}}
{{- if and .Values.modsEnabled.sql.tls.enabled .Values.modsEnabled.sql.tls.autoGenerated (not .Values.modsEnabled.sql.tls.certificatesSecret) (not .Values.modsEnabled.sql.tls.existingTlsSecret) -}}
true
{{- end -}}
{{- end -}}

{{/*
Database (MariaDB sub-chart) fullname.
*/}}
{{- define "freeradius.mariadb.fullname" -}}
  {{- include "st-common.names.dependency.fullname" (dict "chartName" "mariadb" "chartValues" .Values.mariadb "context" $) -}}
{{- end -}}

{{- define "freeradius.mariadb.host" -}}
{{- if eq .Values.mariadb.architecture "replication" -}}
  {{- ternary (printf "%s-primary" (include "freeradius.mariadb.fullname" .)) .Values.externalDatabase.host .Values.mariadb.enabled -}}
{{- else -}}
  {{- ternary (include "freeradius.mariadb.fullname" .) .Values.externalDatabase.host .Values.mariadb.enabled -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.mariadb.port" -}}
{{- ternary "3306" (.Values.externalDatabase.port | toString) .Values.mariadb.enabled | quote -}}
{{- end -}}

{{- define "freeradius.mariadb.name" -}}
{{- if .Values.mariadb.enabled -}}
    {{- if .Values.global.mariadb -}}
        {{- if .Values.global.mariadb.auth -}}
            {{- coalesce .Values.global.mariadb.auth.database .Values.mariadb.auth.database -}}
        {{- else -}}
            {{- .Values.mariadb.auth.database -}}
        {{- end -}}
    {{- else -}}
        {{- .Values.mariadb.auth.database -}}
    {{- end -}}
{{- else -}}
  {{- .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.mariadb.user" -}}
{{- if .Values.mariadb.enabled -}}
  {{- if .Values.global.mariadb -}}
    {{- if .Values.global.mariadb.auth -}}
      {{- coalesce .Values.global.mariadb.auth.username .Values.mariadb.auth.username -}}
    {{- else -}}
      {{- .Values.mariadb.auth.username -}}
    {{- end -}}
  {{- else -}}
    {{- .Values.mariadb.auth.username -}}
  {{- end -}}
{{- else -}}
  {{- .Values.externalDatabase.user -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.mariadb.secretName" -}}
{{- if .Values.mariadb.enabled -}}
    {{- if and .Values.global.mariadb .Values.global.mariadb.auth .Values.global.mariadb.auth.existingSecret -}}
        {{- tpl .Values.global.mariadb.auth.existingSecret $ -}}
    {{- else -}}
        {{- default (include "freeradius.mariadb.fullname" .) (tpl .Values.mariadb.auth.existingSecret $) -}}
    {{- end -}}
{{- else -}}
    {{- default (include "st-common.secrets.name" (dict "existingSecret" .Values.auth.existingSecret "context" $)) (tpl .Values.externalDatabase.existingSecret $) -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.mariadb.secretKey" -}}
{{- if .Values.mariadb.enabled -}}
  {{- print "mariadb-password" -}}
{{- else -}}
  {{- if and .Values.externalDatabase.existingSecret .Values.externalDatabase.existingSecretPasswordKey -}}
    {{- printf "%s" .Values.externalDatabase.existingSecretPasswordKey -}}
  {{- else -}}
    {{- print "database-password" -}}
  {{- end -}}
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
