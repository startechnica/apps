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
Image used by the `db-bootstrap` init container. The per-dialect defaults
live HERE (not in values.yaml) — each dialect maps to a canonical client
image that actually ships the matching CLI (`mysql` for mariadb,
`psql` for postgresql). User overrides via `bootstrap.database.image.*`
fill in field-by-field: any non-empty user value wins, anything empty
falls back to the dialect default. Sqlite never reaches this helper —
`freeradius.bootstrap.database.cmd` returns empty for sqlite, which the
Deployment treats as a skip-the-init-container sentinel.

To add a new dialect, extend `$defaults` below AND the SQL backend
validator's allowed-dialect list.
*/}}
{{- define "freeradius.bootstrap.database.image" -}}
{{- $defaults := dict
    "mysql"      (dict "registry" "public.ecr.aws" "repository" "bitnami/mariadb"    "tag" "12.2.2")
    "postgresql" (dict "registry" "public.ecr.aws" "repository" "bitnami/postgresql" "tag" "18.4.0")
-}}
{{- $default := index $defaults .Values.modules.sql.dialect | default dict -}}
{{- $user := .Values.bootstrap.database.image -}}
{{- $img := dict
    "registry"    (default (get $default "registry")   $user.registry)
    "repository"  (default (get $default "repository") $user.repository)
    "tag"         (default (get $default "tag")        $user.tag)
    "digest"      $user.digest
    "pullPolicy"  $user.pullPolicy
    "pullSecrets" $user.pullSecrets
-}}
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
Validation helpers (aggregator + per-area `freeradius.validate.*`) live in
`templates/helpers/_validate.tpl`.
*/}}

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
SQL backend helpers (`freeradius.sql.*` and the `freeradius.{mariadb,postgresql}.fullname`
subchart name resolvers) live in `templates/helpers/_sql.tpl`.
*/}}

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
