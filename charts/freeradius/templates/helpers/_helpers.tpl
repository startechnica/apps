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
Name of the headless (clusterIP: None) sibling Service. Backs `serviceName:` on
a StatefulSet so per-pod DNS (`<fullname>-0.<headless>.<ns>.svc`) resolves.
*/}}
{{- define "freeradius.headlessServiceName" -}}
{{- printf "%s-%s" (include "st-common.names.fullname" .) (default "headless" .Values.service.headless.nameSuffix) -}}
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
================================================================================
Generic OIDC multi-instance helpers. Per-instance values are resolved
with a small defaults dict; `clients.<x>.oidc` binds a NAS to an
instance for the sites/default dispatch chain.

To run FreeRADIUS against Keycloak, configure a generic OIDC instance:

  modules:
    oidc:
      enabled: true
      instances:
        my-kc:
          tokenUrl: "https://auth.example.com/realms/master/protocol/openid-connect/token"
          introspectUrl: "https://auth.example.com/realms/master/protocol/openid-connect/token/introspect"
          clientId: freeradius
          clientSecret: "..."
          # `client` roleMapper equivalent → resource_access.<clientId>.roles
          # `realm`  roleMapper equivalent → realm_access.roles
          rolesClaim: "resource_access.freeradius.roles"
          groupsClaim: "groups"

  envVarPrefix       FREERADIUS_OIDC_           / FREERADIUS_OIDC_<NAME>_
  moduleName         oidc                       / oidc_<name>
  validateModuleName oidc_validate              / oidc_<name>_validate
  policyName         oidc_authorize             / oidc_<name>_authorize
  rolesPolicyName    oidc_roles                 / oidc_<name>_roles
  groupsPolicyName   oidc_groups                / oidc_<name>_groups
  cacheName          oidc_cache                 / oidc_<name>_cache
  cacheKey           "oidc:%{User-Name}"        / "oidc:<name>:%{User-Name}"
  modKey             oidc                       / oidc_<name>
  policyKey          oidc                       / oidc_<name>
  scriptKey          oidc.py                    / oidc_<name>.py
================================================================================
*/}}

{{- define "freeradius.oidc.resolveInstances" -}}
{{- $tlsDefaults := dict "caCert" "" "existingSecret" "" "existingSecretCaKey" "ca.crt" "insecure" false -}}
{{- $cacheDefaults := dict "enabled" false "ttl" 300 -}}
{{- $instanceDefaults := dict
      "tokenUrl" ""
      "introspectUrl" ""
      "clientId" "freeradius"
      "clientSecret" ""
      "scope" ""
      "connectTimeout" "4.0"
      "roleAttribute" "Class"
      "rolesClaim" ""
      "denyWithoutRole" false
      "roleMappings" (list)
      "groupAttribute" "Class"
      "groupsClaim" "groups"
      "groupMappings" (list)
      "attributeMappings" (list)
      "require" (list)
      "introspect" false
      "refreshTokenCache" false
      "existingConfigMap" ""
      "existingSecret" "" -}}
{{- $instances := dict -}}
{{- range $name, $cfg := (default dict .Values.modules.oidc.instances) -}}
{{- $tls := merge (deepCopy (default dict $cfg.tls)) $tlsDefaults -}}
{{- $cache := merge (deepCopy (default dict $cfg.cache)) $cacheDefaults -}}
{{- $merged := merge (deepCopy $cfg) (dict "tls" $tls "cache" $cache) $instanceDefaults -}}
{{- $_ := set $instances $name $merged -}}
{{- end -}}
{{- (dict "instances" $instances) | toYaml -}}
{{- end -}}

{{- define "freeradius.oidc.envVarPrefix" -}}
{{- if eq .name "default" -}}FREERADIUS_OIDC_
{{- else -}}FREERADIUS_OIDC_{{ .name | upper }}_
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.moduleName" -}}
{{- if eq .name "default" -}}oidc
{{- else -}}oidc_{{ .name }}
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.validateModuleName" -}}
{{- if eq .name "default" -}}oidc_validate
{{- else -}}oidc_{{ .name }}_validate
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.policyName" -}}
{{- if eq .name "default" -}}oidc_authorize
{{- else -}}oidc_{{ .name }}_authorize
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.rolesPolicyName" -}}
{{- if eq .name "default" -}}oidc_roles
{{- else -}}oidc_{{ .name }}_roles
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.groupsPolicyName" -}}
{{- if eq .name "default" -}}oidc_groups
{{- else -}}oidc_{{ .name }}_groups
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.cacheName" -}}
{{- if eq .name "default" -}}oidc_cache
{{- else -}}oidc_{{ .name }}_cache
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.cacheKey" -}}
{{- if eq .name "default" -}}"oidc:%{User-Name}"
{{- else -}}"oidc:{{ .name }}:%{User-Name}"
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.modKey" -}}
{{- if eq .name "default" -}}oidc
{{- else -}}oidc_{{ .name }}
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.policyKey" -}}
{{- if eq .name "default" -}}oidc
{{- else -}}oidc_{{ .name }}
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.scriptKey" -}}
{{- /* The default-instance wrapper is named `oidc_default.py` (not
       `oidc.py`) so it does not collide with the shared library
       `oidc.py` mounted alongside it under python_path. */}}
{{- if eq .name "default" -}}oidc_default.py
{{- else -}}oidc_{{ .name }}.py
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.clientSecretName" -}}
{{- if .instance.existingSecret -}}
{{- tpl .instance.existingSecret .context -}}
{{- else if eq .name "default" -}}
{{- printf "%s-oidc" (include "st-common.names.fullname" .context) -}}
{{- else -}}
{{- printf "%s-oidc-%s" (include "st-common.names.fullname" .context) .name -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.tls.enabled" -}}
{{- if or .instance.tls.caCert .instance.tls.existingSecret -}}
true
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.tls.createSecret" -}}
{{- if and .instance.tls.caCert (not .instance.tls.existingSecret) -}}
true
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.tls.secretName" -}}
{{- if .instance.tls.existingSecret -}}
{{- tpl .instance.tls.existingSecret .context -}}
{{- else if eq .name "default" -}}
{{- printf "%s-oidc-ca" (include "st-common.names.fullname" .context) -}}
{{- else -}}
{{- printf "%s-oidc-%s-ca" (include "st-common.names.fullname" .context) .name -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.tls.caKey" -}}
{{- if .instance.tls.existingSecret -}}
{{- default "ca.crt" .instance.tls.existingSecretCaKey -}}
{{- else -}}
ca.crt
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.tls.caFilePath" -}}
{{- if eq .name "default" -}}
{{- printf "/etc/freeradius/certs-oidc/%s" (include "freeradius.oidc.tls.caKey" .) -}}
{{- else -}}
{{- printf "/etc/freeradius/certs-oidc-%s/%s" .name (include "freeradius.oidc.tls.caKey" .) -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.tlsVolumeName" -}}
{{- if eq .name "default" -}}oidc-tls
{{- else -}}oidc-{{ .name }}-tls
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.dispatchArms" -}}
{{- $arms := list -}}
{{- range $clientName, $client := .Values.clients -}}
{{- if and (kindIs "map" $client) $client.oidc (or $client.ipv4addr $client.ipv6addr) -}}
{{- $arms = append $arms (dict "client" $clientName "ipv4" (default "" $client.ipv4addr) "ipv6" (default "" $client.ipv6addr) "instance" $client.oidc) -}}
{{- end -}}
{{- end -}}
{{- (dict "arms" $arms) | toYaml -}}
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
  3. The chart's Gateway, resolved via `freeradius.gateway.fullname` /
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
  name: {{ include "freeradius.gateway.fullname" $ctx }}
  namespace: {{ include "st-common.gateway.namespace" $ctx }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Body of one `client { }` block in `clients.conf` — the directives that come
AFTER the `ipaddr` / `ipv6addr` line. Shared so that a single values entry
with both `ipv4addr` and `ipv6addr` can render two sibling blocks
(`<name>` for v4, `<name>_v6` for v6) without duplicating the body. Caller
passes the per-client map as `.`.
*/}}
{{- define "freeradius.clientBlockBody" -}}
proto = {{ default "udp" .proto }}
secret = {{ .secret | quote }}
nas_type = {{ default "other" .nas_type }}
virtual_server = {{ default "default" .virtual_server }}
{{- if .coa_server }}
coa_server = {{ .coa_server }}
{{- end }}
{{- if .require_message_authenticator }}
require_message_authenticator = yes
{{- end }}
{{- if .limit }}
limit {
    max_connections = {{ default 16 .limit.max_connections }}
    lifetime = {{ default 0 .limit.lifetime }}
    idle_timeout = {{ default 30 .limit.idle_timeout }}
}
{{- end }}
{{- end -}}

{{/*
Body of one `client { }` block inside the RADSEC `clients radsec { }` group
(`sites/radsec.yaml`). Same dual-address splitting rationale as
`freeradius.clientBlockBody`, but the RADSEC body has its own shape:
`proto = tls` always (RADSEC is TCP+TLS), no `coa_server` / `limit{}`,
and `secret` defaults to literal `"radsec"` (FreeRADIUS's `proto = tls`
default). Caller passes the per-client map as `.`.
*/}}
{{- define "freeradius.radsecClientBlockBody" -}}
proto = tls
secret = {{ default "radsec" .secret | quote }}
{{- if .require_message_authenticator }}
require_message_authenticator = yes
{{- end }}
{{- if .nas_type }}
nas_type = {{ .nas_type }}
{{- end }}
{{- if .virtual_server }}
virtual_server = {{ .virtual_server }}
{{- end }}
{{- end -}}

{{/*
Gateway resource name — chart-local override of `st-common.gateway.fullname`
that appends `-gateway` to the chart-default name. This avoids a collision
with the chart's Service and Deployment (both named via
`st-common.names.fullname`). The collision matters in practice under
Envoy Gateway, where the gateway-api controller materialises an Envoy
proxy `Deployment` named after the Gateway and would otherwise overwrite
the FreeRADIUS workload `Deployment` in the same namespace. Istio's
gateway-api controller has the same shape, so the suffix is applied
uniformly across both implementations.

Resolution order (first match wins):
  1. `gateway.existingGateway`   — BYO; user owns the name, no suffix.
  2. `gateway.gateway.name`      — explicit user override, no suffix.
  3. `<fullname>-gateway`        — chart default.
*/}}
{{- define "freeradius.gateway.fullname" -}}
{{- if .Values.gateway.existingGateway -}}
  {{- .Values.gateway.existingGateway -}}
{{- else if .Values.gateway.gateway.name -}}
  {{- .Values.gateway.gateway.name -}}
{{- else -}}
  {{- printf "%s-gateway" (include "st-common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
EnvoyProxy resource name. When the chart creates the EnvoyProxy
(`gateway.envoyProxy.create: true`), empty `gateway.envoyProxy.name`
defaults to the chart fullname. When BYO (`create: false`), the value
flows through verbatim — the validator demands a non-empty name in that
case, so we don't paper over a missing value here.
Used by `templates/gateway-api/EnvoyProxy.yaml` (when rendering) and by
the `spec.infrastructure.parametersRef` block on the chart's Gateway
(both rendering and BYO).
*/}}
{{- define "freeradius.gateway.envoyProxy.name" -}}
{{- if .Values.gateway.envoyProxy.create -}}
{{- default (include "st-common.names.fullname" .) .Values.gateway.envoyProxy.name -}}
{{- else -}}
{{- .Values.gateway.envoyProxy.name -}}
{{- end -}}
{{- end -}}

{{/*
Whether to render `templates/gateway-api/EnvoyProxy.yaml`. True only when
`gateway.enabled`, `implementation: gateway-api`, `infrastructure: envoy`,
AND `envoyProxy.create: true` (BYO leaves rendering to the operator).
*/}}
{{- define "freeradius.gateway.envoyProxy.create" -}}
{{- if and .Values.gateway.enabled (eq .Values.gateway.implementation "gateway-api") (eq .Values.gateway.infrastructure "envoy") .Values.gateway.envoyProxy.create -}}
true
{{- end -}}
{{- end -}}
