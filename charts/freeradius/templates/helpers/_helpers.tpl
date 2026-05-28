{{- /*
(c) 2026 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Name of the chart-rendered metrics exporter Deployment / Service / ServiceAccount.
*/}}
{{- define "freeradius.metrics.fullname" -}}
{{- printf "%s-metrics" (include "st-common.names.fullname" .) -}}
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
TLS helpers (RADSEC `freeradius.tls.*`, REST `freeradius.rest.tls.*`, EAP
`freeradius.eap.tlsConfig.*`, the gateway TLS secret name `freeradius.gateway.tlsSecretName`,
and the shared chart-internal CA `freeradius.tls.ca.*`) live in
`templates/helpers/_tls.tpl`.
*/}}

{{/*
Validation helpers (aggregator + per-area `freeradius.validate.*`) live in
`templates/helpers/_validate.tpl`.
*/}}

{{/*
SQL backend helpers (`freeradius.sql.*` and the `freeradius.{mariadb,postgresql}.fullname`
subchart name resolvers) live in `templates/helpers/_sql.tpl`.
*/}}

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
