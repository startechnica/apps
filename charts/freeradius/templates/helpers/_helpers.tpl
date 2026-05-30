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
  2. Chart-rendered `<fullname>-db-schema` from `templates/configmaps/db-schema.yaml`.
*/}}
{{- define "freeradius.bootstrap.database.schemaConfigMapName" -}}
{{- default (printf "%s-db-schema" (include "st-common.names.fullname" .)) .Values.bootstrap.database.schemaConfigMap -}}
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
ConfigMap name a module mounts at `mods-enabled/<module>`: the BYO
`modules.<module>.existingConfigMap` when set (tpl-evaluated), otherwise the
chart-rendered `<fullname>-mods-<module>`.
Usage: {{ include "freeradius.module.configMapName" (dict "module" "sql" "context" $) }}
*/}}
{{- define "freeradius.module.configMapName" -}}
{{- $existing := index .context.Values.modules .module "existingConfigMap" -}}
{{- if $existing -}}
{{- tpl $existing .context -}}
{{- else -}}
{{- printf "%s-mods-%s" (include "st-common.names.fullname" .context) .module -}}
{{- end -}}
{{- end -}}

{{/*
Bundled Redis subchart helpers. When the `redis` subchart is enabled the
rlm_redis module targets its `<fullname>-master` Service and (when
`redis.auth.enabled`) pulls the password from the subchart's Secret as
`$ENV{FREERADIUS_MODS_REDIS_PASSWORD}`. Otherwise the module uses
`modules.redis.server` and whatever the user configures there.
*/}}
{{- define "freeradius.redis.fullname" -}}
{{- include "st-common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $) -}}
{{- end -}}

{{- define "freeradius.redis.host" -}}
{{- if .Values.redis.enabled -}}
{{- printf "%s-master" (include "freeradius.redis.fullname" .) -}}
{{- else -}}
{{- .Values.modules.redis.server -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.redis.usePassword" -}}
{{- $redisConsumer := or .Values.modules.redis.enabled (and .Values.modules.cache.enabled (eq .Values.modules.cache.driver "redis")) -}}
{{- if and $redisConsumer .Values.redis.enabled .Values.redis.auth.enabled -}}
true
{{- end -}}
{{- end -}}

{{- define "freeradius.redis.secretName" -}}
{{- if .Values.redis.auth.existingSecret -}}
{{- tpl .Values.redis.auth.existingSecret $ -}}
{{- else -}}
{{- include "freeradius.redis.fullname" . -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.redis.secretKey" -}}
{{- default "redis-password" .Values.redis.auth.existingSecretPasswordKey -}}
{{- end -}}

{{/*
ConfigMap name a virtual server mounts at `sites-enabled/<site>`: the BYO
`sites.<key>.existingConfigMap` when set (tpl-evaluated), otherwise the
chart-rendered `<fullname>-sites-<site>`.
`site` is the FreeRADIUS-facing name (on-disk file / mount); `key` is the
values-map key and defaults to `site` (pass it only when they differ, e.g.
`inner-tunnel` on disk vs `innerTunnel` in values).
Usage: {{ include "freeradius.site.configMapName" (dict "site" "default" "context" $) }}
*/}}
{{- define "freeradius.site.configMapName" -}}
{{- $existing := index .context.Values.sites (.key | default .site) "existingConfigMap" -}}
{{- if $existing -}}
{{- tpl $existing .context -}}
{{- else -}}
{{- printf "%s-sites-%s" (include "st-common.names.fullname" .context) .site -}}
{{- end -}}
{{- end -}}

{{/*
Whether the chart-managed health-check script ConfigMap
(`templates/configmaps/health.yaml`) is needed: not in diagnostic mode, and at
least one probe uses the chart default (script-based) exec rather than a custom
probe. Returns "true" when needed, empty otherwise.
*/}}
{{- define "freeradius.healthcheck.create" -}}
{{- if not .Values.diagnosticMode.enabled -}}
{{- if or (and (not .Values.customStartupProbe) .Values.startupProbe.enabled) (and (not .Values.customLivenessProbe) .Values.livenessProbe.enabled) (and (not .Values.customReadinessProbe) .Values.readinessProbe.enabled) -}}
true
{{- end -}}
{{- end -}}
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
