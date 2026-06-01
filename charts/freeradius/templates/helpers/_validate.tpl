{{- /*
(c) 2026 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Hard-validation aggregator. Each `freeradius.validate.<area>` helper below
returns a non-empty string when its precondition is violated, otherwise the
empty string. This template gathers all of them, drops the empty entries,
and calls `fail` when anything remains so `helm install` / `helm upgrade` /
`helm template` reject the misconfigured release before any resource is
applied.

Included from `templates/NOTES.txt` (Helm renders NOTES.txt as part of the
install path, so a `fail` here aborts the operation).
*/}}
{{- define "freeradius.validate" -}}
{{- $messages := list -}}
{{- $messages = append $messages (include "freeradius.validate.gatewayInfrastructure" .) -}}
{{- $messages = append $messages (include "freeradius.validate.metrics" .) -}}
{{- $messages = append $messages (include "freeradius.validate.sql.backend" .) -}}
{{- $messages = append $messages (include "freeradius.validate.rest" .) -}}
{{- $messages = append $messages (include "freeradius.validate.eap" .) -}}
{{- $messages = append $messages (include "freeradius.validate.cache" .) -}}
{{- $messages = append $messages (include "freeradius.validate.tlsCache" .) -}}
{{- $messages = append $messages (include "freeradius.validate.cacheInstances" .) -}}
{{- $messages = append $messages (include "freeradius.validate.oidcInstances" .) -}}
{{- $messages = append $messages (include "freeradius.validate.oidcClientBindings" .) -}}
{{- $messages = append $messages (include "freeradius.validate.oidcClientBindings" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}
{{- if $message -}}
{{- printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Validation message: `gateway.infrastructure` value coherence.

Rejects:
  - unknown values (`gateway.infrastructure` not in {"", "envoy"}),
  - `infrastructure: envoy` paired with `implementation: istio` — the istio
    Gateway CRD has no `spec.infrastructure` field and Envoy Gateway does not
    consume EnvoyProxy from an istio-managed Gateway.
*/}}
{{- define "freeradius.validate.gatewayInfrastructure" -}}
{{- if .Values.gateway.enabled -}}
{{- $infra := .Values.gateway.infrastructure | default "" -}}
{{- $allowed := list "" "envoy" -}}
{{- if not (has $infra $allowed) -}}
freeradius: gateway.infrastructure
    `gateway.infrastructure: {{ $infra }}` is not a recognised value. Allowed:
    `""` (none — Gateway uses its GatewayClass defaults) or `envoy` (renders
    an `EnvoyProxy` CR and attaches it via `spec.infrastructure.parametersRef`).
{{- else if and (eq $infra "envoy") (ne .Values.gateway.implementation "gateway-api") -}}
freeradius: gateway.infrastructure=envoy
    `gateway.infrastructure: envoy` requires `gateway.implementation: gateway-api`
    (currently `{{ .Values.gateway.implementation }}`). The istio Gateway CRD
    has no `spec.infrastructure` field; switch to the gateway-api
    implementation, or leave `gateway.infrastructure: ""`.
{{- else if and (eq $infra "envoy") (not .Values.gateway.envoyProxy.create) (not .Values.gateway.envoyProxy.name) -}}
freeradius: gateway.envoyProxy
    `gateway.envoyProxy.create: false` requires `gateway.envoyProxy.name` to
    reference the externally-managed EnvoyProxy in `gateway.gateway.namespace`.
    Either set `name` to your existing EnvoyProxy's name, or flip
    `gateway.envoyProxy.create: true` to let the chart render its own.
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validation message: metrics enabled but the RADIUS `status` virtual server is
disabled — the standalone exporter Deployment would have nothing to scrape.
*/}}
{{- define "freeradius.validate.metrics" -}}
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
{{- define "freeradius.validate.sql.backend" -}}
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
  - `rest.enabled: true` with empty `rest.connect_uri`,
  - `rest.auth != none` with no password source (no `password`, no
    `existingSecret`),
  - `rest.tls.enabled: true` with no cert source (no `auto_generated`, no
    `certificates_secret`),
  - `rest.auth` set to something other than the four known values.

Server-cert verification (`tls.check_cert*`) is independent of client-cert
material so it's not validated here — those flags work against the system
CA bundle when no `tls.*` material is mounted.
*/}}
{{- define "freeradius.validate.rest" -}}
{{- if .Values.modules.rest.enabled -}}
{{- $auth := .Values.modules.rest.auth -}}
{{- $allowedAuth := list "none" "basic" "digest" "bearer" -}}
{{- if not .Values.modules.rest.connect_uri -}}
freeradius: modules.rest.enabled
    `modules.rest.enabled: true` requires a non-empty
    `modules.rest.connect_uri` — rlm_rest has nothing to call without it.
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
{{- else if and .Values.modules.rest.tls.enabled (not .Values.modules.rest.tls.auto_generated) (not .Values.modules.rest.tls.certificates_secret) -}}
freeradius: modules.rest.tls.enabled
    `modules.rest.tls.enabled: true` requires a TLS material source.
    Set one of:
      - modules.rest.tls.auto_generated: true        (chart generates a self-signed leaf)
      - modules.rest.tls.certificates_secret: <name> (BYO Secret already in the namespace)
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validation message: EAP module configuration coherence.

Rejects:
  - `eap.enabled: true` with no EAP method enabled,
  - `eap.defaultType` not among the ENABLED methods.

A TLS server certificate is no longer validated here: when the module is enabled
and no `certificates_secret` is supplied, the chart auto-generates one (via
cert-manager when its API is present, otherwise via the shared genCA path) —
`modules.eap.tlsConfig.autoGenerated` is deprecated and no longer consulted.
*/}}
{{- define "freeradius.validate.eap" -}}
{{- if .Values.modules.eap.enabled -}}
{{- $type := .Values.modules.eap.defaultType -}}
{{- $methods := .Values.modules.eap.methods -}}
{{- $outer := list -}}
{{- if has "tls" $methods -}}{{- $outer = append $outer "tls" -}}{{- end -}}
{{- if has "ttls" $methods -}}{{- $outer = append $outer "ttls" -}}{{- end -}}
{{- if eq (len $outer) 0 -}}
freeradius: modules.eap.methods
    `modules.eap.enabled: true` but no outer EAP method is enabled. Add at least
    one of `tls` / `ttls` to `modules.eap.methods`.
{{- else if not (has $type $outer) -}}
freeradius: modules.eap.defaultType
    `modules.eap.defaultType: {{ $type }}` must be one of the enabled outer
    methods ({{ join ", " $outer }}). Either change `defaultType` or add that
    method to `modules.eap.methods`.
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validation message: tls-cache virtual server preconditions. The site has no
value without (a) the EAP module to invoke it, and (b) a Redis backend so
resumption actually works across replicas — in-pod backends (rbtree) reduce
to the per-pod caveat we're trying to escape, so we hard-fail rather than
render something that ships a false promise.
*/}}
{{- define "freeradius.validate.tlsCache" -}}
{{- if .Values.sites.tlsCache.enabled -}}
{{- if not .Values.modules.eap.enabled -}}
freeradius: sites.tlsCache.enabled
    `sites.tlsCache.enabled: true` requires `modules.eap.enabled: true` —
    the tls-cache virtual server only makes sense as a backend for EAP TLS
    session resumption.
{{- else if and (not .Values.redis.enabled) (not .Values.modules.redis.server) -}}
freeradius: sites.tlsCache.enabled
    `sites.tlsCache.enabled: true` requires a Redis backend (cross-pod
    session resumption is the whole point — an in-pod cache defeats it).
    Either enable the bundled subchart (`redis.enabled: true`) or point
    `modules.redis.server` at an external Redis.
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validation messages: per-instance checks for modules.cache.instances entries.
Same rules as the base cache module — driver must be one of the supported
backends and `update` must be non-empty (rlm_cache refuses to load without
at least one map).
*/}}
{{- define "freeradius.validate.cacheInstances" -}}
{{- $allowed := list "rbtree" "redis" "memcached" -}}
{{- range $name, $cfg := .Values.modules.cache.instances -}}
{{- if not (has $cfg.driver $allowed) }}
freeradius: modules.cache.instances.{{ $name }}.driver
    `modules.cache.instances.{{ $name }}.driver: {{ $cfg.driver }}` is not a recognised
    value. Allowed: `rbtree` (in-memory), `redis` (reuses the `modules.redis`
    connection), `memcached`.
{{- else if not (trim ($cfg.update | default "")) }}
freeradius: modules.cache.instances.{{ $name }}.update
    `modules.cache.instances.{{ $name }}` requires a non-empty `update` field.
    rlm_cache refuses to load without at least one map ("Must have an
    'update' section in order to cache anything"). Set `update` to one or
    more FreeRADIUS maps, e.g. `&reply: += &reply:`.
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validation messages for `modules.oidc.instances.<name>`. Per instance:
  - name must match `^[a-z][a-z0-9_]*$` (Python module + DNS-1123 safe),
  - `tokenUrl` is required,
  - `introspect: true` requires `introspectUrl` and a client_secret,
  - `tls.caCert` and `tls.existingSecret` are mutually exclusive,
  - `cache.enabled: true` requires a Redis backend,
  - `roleMappings` requires `rolesClaim` (the chart needs to know which
    claim path holds the role list — there is no provider-agnostic default),
  - `refreshTokenCache: true` requires `cache.enabled: true`,
  - `extraEnvVars` must not shadow the per-instance env-var prefix.
*/}}
{{- define "freeradius.validate.oidcInstances" -}}
{{- if .Values.modules.oidc.enabled -}}
{{- $resolved := include "freeradius.oidc.resolveInstances" . | fromYaml -}}
{{- $nameRe := "^[a-z][a-z0-9_]*$" -}}
{{- $hasRedis := or .Values.redis.enabled .Values.modules.redis.server -}}
{{- $extraEnvNames := list -}}
{{- range $e := .Values.extraEnvVars -}}{{- $extraEnvNames = append $extraEnvNames $e.name -}}{{- end -}}
{{- range $name, $cfg := $resolved.instances }}
{{- if not (regexMatch $nameRe $name) }}
freeradius: modules.oidc.instances.{{ $name }}
    Instance name `{{ $name }}` must match `^[a-z][a-z0-9_]*$` — the name is
    used as a Python module filename (`oidc_<name>.py`, imported via
    `import oidc_<name>`, which forbids hyphens) and as a suffix on K8s
    resource names. Use lowercase letters, digits, and underscores; start
    with a letter.
{{- end -}}
{{- if not $cfg.tokenUrl }}
freeradius: modules.oidc.instances.{{ $name }}.tokenUrl
    `modules.oidc.instances.{{ $name }}.tokenUrl` is required — the chart
    has no way to derive a token endpoint for a generic OIDC provider.
    Set it to the IdP's RFC 6749 token endpoint (e.g.
    `https://auth.example.com/application/o/freeradius/token/` for
    Authentik; `https://<tenant>/oauth2/v2.0/token` for Azure AD).
{{- end -}}
{{- if and $cfg.introspect (not $cfg.introspectUrl) }}
freeradius: modules.oidc.instances.{{ $name }}.introspectUrl
    `modules.oidc.instances.{{ $name }}.introspect: true` requires
    `introspectUrl` — the chart cannot derive an introspect endpoint for a
    generic OIDC provider. Set it to the IdP's RFC 7662 introspect endpoint.
{{- end -}}
{{- if and $cfg.tls $cfg.tls.caCert $cfg.tls.existingSecret }}
freeradius: modules.oidc.instances.{{ $name }}.tls
    `modules.oidc.instances.{{ $name }}.tls.caCert` and
    `modules.oidc.instances.{{ $name }}.tls.existingSecret` are mutually
    exclusive — set one or the other.
{{- end -}}
{{- if and $cfg.cache $cfg.cache.enabled (not $hasRedis) }}
freeradius: modules.oidc.instances.{{ $name }}.cache.enabled
    `modules.oidc.instances.{{ $name }}.cache.enabled: true` requires a
    Redis backend. Either enable the bundled subchart (`redis.enabled: true`)
    or point `modules.redis.server` at an external Redis.
{{- end -}}
{{- $roleAttr := default "Class" $cfg.roleAttribute -}}
{{- $groupAttr := default "Class" $cfg.groupAttribute -}}
{{- if and $cfg.roleMappings $cfg.groupMappings (eq $roleAttr $groupAttr) }}
freeradius: modules.oidc.instances.{{ $name }}.groupAttribute
    `modules.oidc.instances.{{ $name }}` defines both `roleMappings` and
    `groupMappings` but `roleAttribute` and `groupAttribute` resolve to
    the same control attribute (`{{ $roleAttr }}`). Set `groupAttribute`
    to a different attribute.
{{- end -}}
{{- if and $cfg.roleMappings (not $cfg.rolesClaim) }}
freeradius: modules.oidc.instances.{{ $name }}.rolesClaim
    `modules.oidc.instances.{{ $name }}.roleMappings` is non-empty but
    `rolesClaim` is unset — the chart has no way to know which JWT/
    introspect claim holds the role list for a generic OIDC provider.
    Set it to the dotted claim path (e.g. `roles`, `realm_access.roles`,
    `resource_access.<id>.roles`, `groups`).
{{- end -}}
{{- range $i, $m := default list $cfg.roleMappings }}
{{- if not $m.role }}
freeradius: modules.oidc.instances.{{ $name }}.roleMappings[{{ $i }}].role
    Each `roleMappings` entry must set `role` (the value the chart compares
    against `&control:{{ $roleAttr }}[*]`).
{{- end -}}
{{- end -}}
{{- range $i, $m := default list $cfg.groupMappings }}
{{- if not $m.group }}
freeradius: modules.oidc.instances.{{ $name }}.groupMappings[{{ $i }}].group
    Each `groupMappings` entry must set `group`.
{{- end -}}
{{- end -}}
{{- range $i, $m := default list $cfg.attributeMappings }}
{{- if or (not $m.claim) (not $m.reply) }}
freeradius: modules.oidc.instances.{{ $name }}.attributeMappings[{{ $i }}]
    Each `attributeMappings` entry must set both `claim` and `reply`.
{{- end -}}
{{- end -}}
{{- range $i, $r := default list $cfg.require }}
{{- if not $r }}
freeradius: modules.oidc.instances.{{ $name }}.require[{{ $i }}]
    Each `require` entry must be a non-empty claim name.
{{- end -}}
{{- end -}}
{{- if and $cfg.introspect (not $cfg.clientSecret) (not $cfg.existingSecret) }}
freeradius: modules.oidc.instances.{{ $name }}.introspect
    `modules.oidc.instances.{{ $name }}.introspect: true` requires a
    client secret — RFC 7662 introspection is HTTP-Basic-authenticated.
    Set `clientSecret` (inline) or `existingSecret` (BYO).
{{- end -}}
{{- if and $cfg.refreshTokenCache (or (not $cfg.cache) (not $cfg.cache.enabled)) }}
freeradius: modules.oidc.instances.{{ $name }}.refreshTokenCache
    `modules.oidc.instances.{{ $name }}.refreshTokenCache: true` requires
    `cache.enabled: true` — the refresh flow runs on cache HIT.
{{- end -}}
{{- $prefix := include "freeradius.oidc.envVarPrefix" (dict "name" $name) -}}
{{- range $envName := $extraEnvNames -}}
{{- if hasPrefix $prefix $envName }}
freeradius: extraEnvVars
    `extraEnvVars` contains `{{ $envName }}`, which shadows the chart-emitted
    prefix `{{ $prefix }}*` for `modules.oidc.instances.{{ $name }}`.
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validation: every non-empty `clients.<x>.oidc` references an existing
`modules.oidc.instances.<name>` and the client has an `ipv4addr` /
`ipv6addr`.
*/}}
{{- define "freeradius.validate.oidcClientBindings" -}}
{{- if .Values.modules.oidc.enabled -}}
{{- $resolved := include "freeradius.oidc.resolveInstances" . | fromYaml -}}
{{- range $clientName, $client := .Values.clients -}}
{{- if and (kindIs "map" $client) $client.oidc -}}
{{- if not (hasKey $resolved.instances $client.oidc) }}
freeradius: clients.{{ $clientName }}.oidc
    `clients.{{ $clientName }}.oidc: {{ $client.oidc }}` references an
    undefined instance — add it under `modules.oidc.instances.{{ $client.oidc }}`
    or fix the typo. Defined instances: {{ join ", " (keys $resolved.instances) }}.
{{- else if and (not $client.ipv4addr) (not $client.ipv6addr) }}
freeradius: clients.{{ $clientName }}.oidc
    `clients.{{ $clientName }}.oidc: {{ $client.oidc }}` requires
    `clients.{{ $clientName }}.ipv4addr` and/or `.ipv6addr` to be non-empty.
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validation message: cache module driver must be one of the supported backends.
*/}}
{{- define "freeradius.validate.cache" -}}
{{- if .Values.modules.cache.enabled -}}
{{- $driver := .Values.modules.cache.driver -}}
{{- $allowed := list "rbtree" "redis" "memcached" -}}
{{- if not (has $driver $allowed) -}}
freeradius: modules.cache.driver
    `modules.cache.driver: {{ $driver }}` is not a recognised value. Allowed:
    `rbtree` (in-memory), `redis` (reuses the `modules.redis` connection), `memcached`.
{{- else if not (trim (.Values.modules.cache.update | default "")) -}}
freeradius: modules.cache.update
    `modules.cache.enabled: true` requires a non-empty `modules.cache.update`.
    rlm_cache refuses to load without at least one map ("Must have an 'update'
    section in order to cache anything"). Set `modules.cache.update` to one or
    more FreeRADIUS maps, e.g. `&reply: += &reply:`.
{{- end -}}
{{- end -}}
{{- end -}}
