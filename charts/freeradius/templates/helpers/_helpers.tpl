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
Keycloak multi-instance helpers.

Resolution (`freeradius.keycloak.resolveInstances`) — returns a YAML
document with a single `instances:` key holding the effective map.
Templates parse it with `fromYaml`:

  {{- $resolved := include "freeradius.keycloak.resolveInstances" . | fromYaml -}}
  {{- range $name, $cfg := $resolved.instances }}
    ...
  {{- end }}

Direction: NAS → instance. Each `clients.<x>.keycloak` references one of
the resolved instance names. The chart special-cases the instance named
`default` to keep legacy resource names (module instance `keycloak_lua`/
`keycloak_python`, policy `authorize_keycloak`, Secret
`<fullname>-keycloak`, unprefixed env vars, etc.) so existing values
files keep rendering identically.

Deprecation shim: legacy top-level fields (`keycloak.url`, `realm`, …)
auto-synthesise an `instances.default` entry when `keycloak.enabled` is
true AND `instances` doesn't already define `default` AND
`keycloak.realm` is non-empty. Removal slated for the next major.
*/}}

{{- define "freeradius.keycloak.resolveInstances" -}}
{{- $tlsDefaults := dict "caCert" "" "existingSecret" "" "existingSecretCaKey" "ca.crt" "insecure" false -}}
{{- $cacheDefaults := dict "enabled" false "ttl" 300 -}}
{{- $instanceDefaults := dict
      "mode" "python"
      "url" ""
      "realm" ""
      "clientId" "freeradius"
      "clientSecret" ""
      "scope" ""
      "connectTimeout" "4.0"
      "roleAttribute" "Class"
      "roleMapper" "client"
      "denyWithoutRole" false
      "roleMappings" (list)
      "existingConfigMap" ""
      "existingSecret" "" -}}
{{- $instances := dict -}}
{{- range $name, $cfg := (default dict .Values.keycloak.instances) -}}
{{- $tls := merge (deepCopy (default dict $cfg.tls)) $tlsDefaults -}}
{{- $cache := merge (deepCopy (default dict $cfg.cache)) $cacheDefaults -}}
{{- $merged := merge (deepCopy $cfg) (dict "tls" $tls "cache" $cache) $instanceDefaults -}}
{{- $_ := set $instances $name $merged -}}
{{- end -}}
{{- if and .Values.keycloak.enabled (not (hasKey $instances "default")) .Values.keycloak.realm -}}
{{- $legacy := dict
      "mode" .Values.keycloak.mode
      "url" .Values.keycloak.url
      "realm" .Values.keycloak.realm
      "clientId" .Values.keycloak.clientId
      "clientSecret" .Values.keycloak.clientSecret
      "scope" .Values.keycloak.scope
      "connectTimeout" .Values.keycloak.connectTimeout
      "roleAttribute" .Values.keycloak.roleAttribute
      "roleMapper" .Values.keycloak.roleMapper
      "denyWithoutRole" .Values.keycloak.denyWithoutRole
      "roleMappings" .Values.keycloak.roleMappings -}}
{{- $tls := merge (deepCopy (default dict .Values.keycloak.tls)) $tlsDefaults -}}
{{- $cache := merge (deepCopy (default dict .Values.keycloak.cache)) $cacheDefaults -}}
{{- $defaultEntry := merge $legacy (dict "tls" $tls "cache" $cache) $instanceDefaults -}}
{{- $_ := set $instances "default" $defaultEntry -}}
{{- end -}}
{{- (dict "instances" $instances) | toYaml -}}
{{- end -}}

{{/*
True when the legacy top-level fields synthesised the `default` instance
(used by NOTES.txt to emit a deprecation warning).
*/}}
{{- define "freeradius.keycloak.shimFired" -}}
{{- if and .Values.keycloak.enabled (not (hasKey (default dict .Values.keycloak.instances) "default")) .Values.keycloak.realm -}}
true
{{- end -}}
{{- end -}}

{{/*
Per-instance naming helpers. Each takes a dict with `name` (instance
name); some also need `mode` (the per-instance `mode` value) for
module/script naming. The `default` instance maps to legacy names for
byte-identical backwards-compat rendering against pre-multi-instance
values files; non-default instances suffix the name everywhere.

  envVarPrefix       FREERADIUS_KEYCLOAK_                / FREERADIUS_KEYCLOAK_<NAME>_
  moduleName         keycloak_lua|python|rest            / keycloak_<name>
  policyName         authorize_keycloak                  / authorize_keycloak_<name>
  rolesPolicyName    roles_keycloak                      / roles_keycloak_<name>
  cacheName          cache_keycloak                      / cache_keycloak_<name>
  cacheKey           "keycloak:%{User-Name}"             / "keycloak:<name>:%{User-Name}"
                                                          (forced, non-overridable)
  modKey             keycloak                            / keycloak_<name>
  policyKey          keycloak                            / keycloak_<name>
  scriptKey          keycloak.lua | keycloak.py          / keycloak_<name>.lua
                                                          | keycloak_<name>.py
*/}}

{{- define "freeradius.keycloak.envVarPrefix" -}}
{{- if eq .name "default" -}}FREERADIUS_KEYCLOAK_
{{- else -}}FREERADIUS_KEYCLOAK_{{ .name | upper }}_
{{- end -}}
{{- end -}}

{{- define "freeradius.keycloak.moduleName" -}}
{{- if eq .name "default" -}}
{{- if eq .mode "python" -}}keycloak_python
{{- else -}}keycloak_lua
{{- end -}}
{{- else -}}keycloak_{{ .name }}
{{- end -}}
{{- end -}}

{{- define "freeradius.keycloak.policyName" -}}
{{- if eq .name "default" -}}authorize_keycloak
{{- else -}}authorize_keycloak_{{ .name }}
{{- end -}}
{{- end -}}

{{- define "freeradius.keycloak.rolesPolicyName" -}}
{{- if eq .name "default" -}}roles_keycloak
{{- else -}}roles_keycloak_{{ .name }}
{{- end -}}
{{- end -}}

{{- define "freeradius.keycloak.cacheName" -}}
{{- if eq .name "default" -}}cache_keycloak
{{- else -}}cache_keycloak_{{ .name }}
{{- end -}}
{{- end -}}

{{- define "freeradius.keycloak.cacheKey" -}}
{{- if eq .name "default" -}}"keycloak:%{User-Name}"
{{- else -}}"keycloak:{{ .name }}:%{User-Name}"
{{- end -}}
{{- end -}}

{{- define "freeradius.keycloak.modKey" -}}
{{- if eq .name "default" -}}keycloak
{{- else -}}keycloak_{{ .name }}
{{- end -}}
{{- end -}}

{{- define "freeradius.keycloak.policyKey" -}}
{{- if eq .name "default" -}}keycloak
{{- else -}}keycloak_{{ .name }}
{{- end -}}
{{- end -}}

{{- define "freeradius.keycloak.scriptKey" -}}
{{- if eq .mode "lua" -}}
{{- if eq .name "default" -}}keycloak.lua
{{- else -}}keycloak_{{ .name }}.lua
{{- end -}}
{{- else if eq .mode "python" -}}
{{- if eq .name "default" -}}keycloak.py
{{- else -}}keycloak_{{ .name }}.py
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Per-instance client-secret Secret name. BYO via `instance.existingSecret`,
otherwise chart-managed: `<fullname>-keycloak` for default,
`<fullname>-keycloak-<name>` for non-default. Requires (name, instance,
context).
*/}}
{{- define "freeradius.keycloak.clientSecretName" -}}
{{- if .instance.existingSecret -}}
{{- tpl .instance.existingSecret .context -}}
{{- else if eq .name "default" -}}
{{- printf "%s-keycloak" (include "st-common.names.fullname" .context) -}}
{{- else -}}
{{- printf "%s-keycloak-%s" (include "st-common.names.fullname" .context) .name -}}
{{- end -}}
{{- end -}}

{{/*
Keycloak TLS verification helpers — per-instance. All take a dict with
`name` (instance name), `instance` (per-instance config dict), and
`context` (root `$`).

  tls.enabled       "true" when CA bundle is configured for the instance
  tls.createSecret  "true" when the chart renders its own per-instance Secret
  tls.secretName    BYO existingSecret OR <fullname>-keycloak[-<name>]-ca
  tls.caKey         key within the resolved Secret holding the PEM bundle
  tls.caFilePath    absolute path of the mounted CA file inside the pod
                    (/etc/freeradius/certs-keycloak/<key> for default,
                     /etc/freeradius/certs-keycloak-<name>/<key> otherwise)
*/}}
{{- define "freeradius.keycloak.tls.enabled" -}}
{{- if or .instance.tls.caCert .instance.tls.existingSecret -}}
true
{{- end -}}
{{- end -}}

{{- define "freeradius.keycloak.tls.createSecret" -}}
{{- if and .instance.tls.caCert (not .instance.tls.existingSecret) -}}
true
{{- end -}}
{{- end -}}

{{- define "freeradius.keycloak.tls.secretName" -}}
{{- if .instance.tls.existingSecret -}}
{{- tpl .instance.tls.existingSecret .context -}}
{{- else if eq .name "default" -}}
{{- printf "%s-keycloak-ca" (include "st-common.names.fullname" .context) -}}
{{- else -}}
{{- printf "%s-keycloak-%s-ca" (include "st-common.names.fullname" .context) .name -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.keycloak.tls.caKey" -}}
{{- if .instance.tls.existingSecret -}}
{{- default "ca.crt" .instance.tls.existingSecretCaKey -}}
{{- else -}}
ca.crt
{{- end -}}
{{- end -}}

{{- define "freeradius.keycloak.tls.caFilePath" -}}
{{- if eq .name "default" -}}
{{- printf "/etc/freeradius/certs-keycloak/%s" (include "freeradius.keycloak.tls.caKey" .) -}}
{{- else -}}
{{- printf "/etc/freeradius/certs-keycloak-%s/%s" .name (include "freeradius.keycloak.tls.caKey" .) -}}
{{- end -}}
{{- end -}}

{{/*
Mount-volume names for per-instance projected ConfigMaps / Secrets. Used
by Deployment.yaml so the same name is referenced by both the volume and
volumeMount blocks.

  tlsVolumeName     keycloak-tls          / keycloak-<name>-tls
*/}}
{{- define "freeradius.keycloak.tlsVolumeName" -}}
{{- if eq .name "default" -}}keycloak-tls
{{- else -}}keycloak-{{ .name }}-tls
{{- end -}}
{{- end -}}

{{/*
Dispatch arms — list of (client, instance) pairs derived from
`clients.<x>.keycloak`. Returns a YAML `arms: [...]` document so templates
can `fromYaml` it. Each entry: `client`, `ipv4`, `ipv6`, `instance`. Order
is map-iteration order (alphabetical by client name in Helm) — deterministic
but does not preserve declaration order from values.yaml.
*/}}
{{- define "freeradius.keycloak.dispatchArms" -}}
{{- $arms := list -}}
{{- range $clientName, $client := .Values.clients -}}
{{- if and (kindIs "map" $client) $client.keycloak $client.ipv4addr -}}
{{- $arms = append $arms (dict "client" $clientName "ipv4" $client.ipv4addr "ipv6" (default "" $client.ipv6addr) "instance" $client.keycloak) -}}
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
