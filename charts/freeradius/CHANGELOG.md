# Changelog

## 1.2.0 (2026-05-31)

### Added

- **Keycloak shared-library extensions** — five additive features on
  top of the existing JWT/ROPC flow, all configured per-instance under
  `keycloak.instances.<name>`:
  - `groupMappings` / `groupAttribute` — mirror of `roleMappings` keyed
    off the Keycloak `groups` claim (Group Membership client mapper).
    Group paths land in `&control:<groupAttribute>` (default `Class` —
    validator rejects when the role and group attributes collide and
    both mappings are non-empty). A `keycloak[_<name>]_groups` policy
    block fires on `ok` alongside the existing `keycloak[_<name>]_roles`.
  - `require` — list of JWT claim names that must be truthy after
    decode (or introspection). Catches "user authenticated but
    admin-disabled-since-issuance" via e.g. `require: [email_verified]`;
    rejects early before any reply attrs are populated.
  - `attributeMappings` — generic `{claim, reply}` engine copying any
    top-level JWT claim verbatim to a reply attribute (e.g.
    `preferred_username` → `User-Name`, `sub` → `Class`). The chosen
    reply attrs are added to the cache `update {}` so they survive
    cache hits.
  - `introspect` — switches the post-ROPC claim source from local
    JWT-payload decode to RFC 7662 `/realms/<realm>/protocol/openid-connect/token/introspect`.
    Catches token revocation, admin-disabled-since-issuance, and realm
    key rotation. Validator rejects `introspect: true` without a client
    secret (Keycloak introspect calls are HTTP-Basic-authenticated).
  - `refreshTokenCache` — only meaningful with `cache.enabled`. The
    ROPC response's `refresh_token` rides out in `&control:Tmp-String-9`
    so the cache layer stores it; a second module instance
    `keycloak_<name>_validate` (rlm_python3 / rlm_lua, same script,
    `func_authorize = "validate"`) is rendered, and the policy calls it
    on cache hit. The validator attempts `grant_type=refresh_token`
    against Keycloak: HTTP 200 confirms the session is alive, 400/401
    triggers cache-entry invalidation + reject, network FAIL falls
    through gracefully with the cached attrs intact.
- `freeradius.keycloak.groupsPolicyName` / `validateModuleName` helpers
  for the per-instance groups policy and the cache-hit validator
  module-instance name (legacy default short form vs `*_<name>` suffix).
- `freeradius.validate.keycloakInstances` now enforces the new schema:
  group/role attribute collision, introspect-requires-secret,
  refreshTokenCache-requires-cache, and well-formed
  `attributeMappings` / `groupMappings` / `require` entries.
- **`values.schema.json`** — JSON Schema draft-07, type-only walk of
  `values.yaml` (matches the convention used by charts/adminer and
  charts/open-appsec-injector). Catches gross value-type mismatches at
  `helm install` / `helm template` / `helm lint` time without trying to
  be a value-level lint. Nullable placeholders (e.g.
  `gateway.existingGateway: ~`) are typed as `["string", "null"]` so
  both the default and any user override validate. Regen helper at
  `charts/freeradius/.gen-values-schema.py`; excluded from the package
  via `.helmignore`.
- **`.helmignore`** — first-class chart packaging excludes: standard
  VCS / IDE patterns plus this repo's build helpers (`.gen-*.py`,
  `ci/` render fixtures) and Claude-side artifacts (`.claude/`,
  `CLAUDE.md`).

- **Multi-instance Keycloak.** Configure any number of Keycloak backends
  under `keycloak.instances.<name>` (each with its own `mode` / `url` /
  `realm` / `clientId` / `clientSecret` / `tls` / `cache` /
  `roleMappings`). Bind each NAS to a backend with the new
  `clients.<x>.keycloak: <name>` field; the chart renders an
  `if (Packet-Src-IP-Address == …) { keycloak_<name>_authorize }`
  dispatch chain into the shared `sites/default` and `sites/inner-tunnel`
  virtual servers. The previously singleton `keycloak.*` fields auto-
  synthesise an `instances.default` entry for backwards-compat (a
  `NOTES.txt` deprecation notice fires).
- `keycloak.unmatchedReject` — when `true` AND no `default` instance is
  wired, the dispatch chain's `else` branch rejects unmatched NAS
  instead of falling through to `pap`.
- Per-instance K8s resources: one ConfigMap per instance for
  `mods-enabled/keycloak[_<name>]`, `policy.d/keycloak[_<name>]`, and
  (lua/python only) the mapper-script file. One Secret per instance for
  `client-secret` and (when configured) the TLS CA bundle. Per-instance
  TLS mount under `/etc/freeradius/certs-keycloak[-<name>]/ca.crt`.
- Shared mapper-script library — `keycloak_common.{py,lua}` rendered
  once per release in a dedicated ConfigMap
  (`<fullname>-keycloak-{python,lua}-common`), mounted at
  `/etc/freeradius/scripts/keycloak_common.{py,lua}`. The per-instance
  ConfigMaps drop from ~200 lines each to ~25-line wrappers that
  `import keycloak_common` (python) / `require("keycloak_common")`
  (lua) and delegate `authorize(p)` / `accounting(p)` over a config
  dict/table baked in at chart-render time. Dedupes the implementation
  body across N instances; one bug fix to the library propagates to
  every instance on the next `helm upgrade`. The library itself is
  pure logic — no env-var reads, no module-level config — so it's
  safely shared across instances inside the rlm_python3 process-global
  interpreter.
- `cache keycloak[_<name>]_cache` rlm_cache instance per Keycloak
  instance whose `cache.enabled: true`, rendered into the shared
  `mods-enabled/cache` file. The cache key is hard-coded to
  `keycloak:<name>:%{User-Name}` (non-overridable) to prevent silent
  cross-instance cache hits on common usernames.
- `freeradius.keycloak.resolveInstances` / `envVarPrefix` / `moduleName`
  / `policyName` / `rolesPolicyName` / `cacheName` / `cacheKey` /
  `dispatchArms` / `clientSecretName` helpers, plus per-instance
  `freeradius.keycloak.tls.*` helpers (now taking `(name, instance,
  context)`). Single-source-of-truth for the legacy-default-vs-named
  naming split.
- `freeradius.validate.keycloakInstances` and
  `freeradius.validate.keycloakClientBindings` — per-instance schema
  validation (mode, roleMapper, TLS exclusivity, cache-requires-Redis,
  instance-name regex, realm-non-empty, no `extraEnvVars` shadowing
  the `FREERADIUS_KEYCLOAK_*` prefix) and a typo guard on every
  `clients.<x>.keycloak` reference.

- Bundled **Redis** subchart (Bitnami, `condition: redis.enabled`) as an
  optional backend for the redis/cache modules. When enabled, the modules
  auto-target the `<release>-redis-master` Service and pull the password from the
  subchart Secret (`$ENV{FREERADIUS_MODS_REDIS_PASSWORD}`) via the new
  `freeradius.redis.*` helpers.
- `templates/modules/redis.yaml` + `modules.redis.*` — rlm_redis module
  (`%{redis:...}` xlat), rendered as `<fullname>-mods-redis`, mounted at
  `mods-enabled/redis`, with a config-checksum annotation for rollout-on-change.
- `templates/modules/cache.yaml` + `modules.cache.*` — standalone rlm_cache
  module with a pluggable `driver` (`rbtree` in-memory, `redis` reusing the
  redis connection, `memcached`), rendered as `<fullname>-mods-cache` and
  mounted at `mods-enabled/cache`. Includes the required `update { }` section
  (`modules.cache.update`, default `&reply: += &reply:`) — rlm_cache refuses to
  load without at least one map. The driver value and a non-empty `update` are
  both checked by the new `freeradius.validate.cache` aggregator rule.
- NetworkPolicy egress to the Redis backend on `modules.redis.port` (TCP),
  rendered when `rlm_redis` or the redis-driver cache is enabled. Skipped under
  `networkPolicy.allowExternalEgress` (which already permits all egress).
- `templates/Issuer.yaml` — self-signed CA chain bootstrapped via cert-manager
  (a self-signed `Issuer` → a CA `Certificate` with `isCA: true` → a CA
  `Issuer`). Rendered when the chart issues via cert-manager and no external
  `tls.certManager.issuerRef.name` is supplied; the RADSEC and gateway leaf
  Certificates then reference this chart-managed CA Issuer.
- `tls.certManager.ca.{commonName,duration,renewBefore,secretName}` — tuning
  knobs for the bootstrapped CA.
- `freeradius.tls.useCertManager` helper — single source of truth for whether
  the chart issues TLS through cert-manager (vs. the in-template genCA path).

### Changed

- **RADSEC site renamed `tls` → `radsec`** end-to-end. The chart's stock
  RADSEC virtual server (file, ConfigMap data key, FreeRADIUS-internal
  block names) now uses the protocol's actual name everywhere — the old
  `tls`-named site collided visually with the in-pod TLS material
  switch (`tls.enabled` / `tls.certificatesSecret`, which stay
  untouched). Specifically:
  - File: `templates/sites/tls.yaml` → `templates/sites/radsec.yaml`
    (git-mv'd to preserve history); ConfigMap renamed
    `<fullname>-sites-tls` → `<fullname>-sites-radsec`; data key `tls:` → `radsec:`;
    in-pod mount path `sites-enabled/tls` → `sites-enabled/radsec`.
  - FreeRADIUS-internal block names: `home_server tls`, `home_server_pool tls`,
    `realm tls` (and their `home_server = tls` / `auth_pool = tls`
    references) → `home_server radsec` / `home_server_pool radsec` /
    `realm radsec`.
  - values.yaml: the `sites.tls.*` block (`enabled`, `existingConfigMap`,
    `cipher`, `privateKeyPassword`, `radsecSecret`) became `sites.radsec.*`.
  - Secret / env / BYO: chart-managed credentials key
    `sites-tls-privkey-password` → `sites-radsec-privkey-password`;
    env var `FREERADIUS_SITES_TLS_PRIVKEY_PASSWORD` →
    `FREERADIUS_SITES_RADSEC_PRIVKEY_PASSWORD`;
    `auth.existingSecretPerPassword.sitesTlsPrivKeyPassword` →
    `sitesRadsecPrivKeyPassword`.
  - Top-level `tls.*` (RADSEC cert material —
    `tls.enabled` / `tls.certificatesSecret` / `tls.certManager.*` /
    `tls.autoGenerated`) is **unchanged** — these knobs describe
    TLS-the-protocol, not the site name.
  - `sites.tlsCache` / `cache_tls` / `sites-enabled/tls-cache`
    (the EAP TLS session-resumption site) is **unchanged** — separate
    feature, kept its existing name.

  Breaking values change. Migration:

      sites:
    -   tls:
    +   radsec:
          enabled: true
          cipher: "DEFAULT"
          privateKeyPassword: ""
          radsecSecret: ""

      auth:
        existingSecretPerPassword:
    -     sitesTlsPrivKeyPassword:
    +     sitesRadsecPrivKeyPassword:
            name: my-secret
            key:  privkey-password

- **`st-common` dependency moved from the GitHub Pages HTTP repo to the
  GHCR OCI registry.** `repository: oci://ghcr.io/startechnica/charts`
  (was `https://startechnica.github.io/apps`). Same chart, same version
  (0.1.21) — just a different fetch path. Aligns with the chart's own
  publish path (`.github/workflows/release.yaml` pushes to
  `oci://ghcr.io/<owner>/charts`) and skips the Pages-index round-trip.
  `helm dependency build` re-fetches; existing renders are byte-identical.
- **cert-manager is now auto-detected.** `tls.certManager.create` defaults to
  `true`; when the cert-manager API is present the chart issues RADSEC/gateway
  certificates through cert-manager, and when it is absent it transparently
  falls back to the in-template self-signed genCA path. Set
  `tls.certManager.create: false` to force the genCA path even where
  cert-manager is installed. (Previously `create` defaulted to `false` and had
  to be set manually.)
- `tls.certManager.issuerRef.name` now defaults to `""` (was
  `selfsigned-issuer`). Empty bootstraps a chart-managed CA; set it to use a
  pre-existing Issuer/ClusterIssuer and skip the bootstrap.
- `tls.autoGenerated` is now the single "auto-generate TLS material" switch
  across both mechanisms (cert-manager when its API is present, genCA
  otherwise).
- Replaced the env-vars ConfigMap (`templates/configmap/envvars.yaml`) with a
  Secret (`templates/secret/envvars.yaml`, keeping the `<fullname>-envvars`
  name). Dropped the unused `FREERADIUS_ENABLE_TLS` / `FREERADIUS_SITES_NAMESPACE`
  keys (nothing read them — TLS and site config are rendered directly into the
  per-site ConfigMaps); the only remaining content is the conditional
  `FREERADIUS_MODS_REST_PASSWORD` fallback, which now lives in a Secret rather
  than a ConfigMap. The Deployment `envFrom` switches to `secretRef` for the
  chart-managed env vars (the `existingConfigmap` BYO path still uses
  `configMapRef`).
- Renamed the Keycloak coordinate env vars injected by the Deployment from
  `KC_*` → `FREERADIUS_KEYCLOAK_*` (`BASE_URL`, `REALM`, `CLIENT_ID`,
  `CLIENT_SECRET`, `SCOPE`, `CONNECT_TIMEOUT`) so they share the chart's
  `FREERADIUS_` env-var namespace. The lua/python mapper scripts and the rest
  module's `$ENV{...}` reference are updated in lockstep. Internal rename — no
  `values.yaml` changes; only observable when exec'ing into the pod or
  overriding the mapper-script ConfigMaps / `keycloak.yaml` module template.
- Keycloak mapper-script filenames renamed for the multi-instance
  refactor: `keycloak-mapper.lua` → `keycloak.lua`,
  `keycloak_mapper.py` → `keycloak.py` (default instance);
  `keycloak_mapper_<name>.{py,lua}` → `keycloak_<name>.{py,lua}`
  (named instances). The rendered `python3 keycloak_<name>` module's
  `mod_authorize` directive updates to match (`"keycloak"` /
  `"keycloak_<name>"`).
- **Keycloak `rest` mode removed.** `python` mode is a strict superset
  (same ROPC POST + JWT-decode for role extraction, both via bundled
  modules — no custom image needed) so the rest variant added nothing.
  `keycloak.instances.<name>.mode` is now `lua | python` only; the
  legacy `keycloak.mode: rest` default switches to `python`. Setting
  `mode: rest` explicitly fails validation with a migration message.
  Dropped along with it: the `rest keycloak_<name> { … }` module body
  in `mods-config/keycloak/keycloak.yaml`, the `$isRest` branch in
  `keycloak-policy.yaml` (`okRcode` is always `(ok)`), and the
  `Auth-Type REST { keycloak_rest }` wiring in `sites/inner-tunnel`.

### Deprecated

- Top-level `keycloak.mode`, `keycloak.url`, `keycloak.realm`,
  `keycloak.clientId`, `keycloak.clientSecret`, `keycloak.scope`,
  `keycloak.connectTimeout`, `keycloak.roleAttribute`, `keycloak.roleMapper`,
  `keycloak.denyWithoutRole`, `keycloak.roleMappings`, `keycloak.tls.*`
  and `keycloak.cache.*` — use `keycloak.instances.default.<field>`
  instead. Existing values files continue to render via a shim that
  synthesises `instances.default` from the legacy fields; the shim and
  the legacy fields will be removed in the next major.

### Fixed

- Certificate / Issuer templates no longer emit an invalid `apiVersion: false`
  manifest when the cert-manager API is absent. The
  `st-common.capabilities.certmanager*` helpers return the string `"false"`
  (truthy in templates); the gates now test it explicitly via
  `freeradius.tls.useCertManager` / `ne … "false"`.
- `templates/configmap/clients.yaml` no longer fails to render when the
  `clients` map carries non-client scalar keys (`includeFile`,
  `existingConfigMapName`) — it skips non-map entries via `kindIs "map"`
  instead of a hand-maintained `omit` list.
- `image.debug` (previously documented but unwired) now gates the container
  args between `-f` (normal) and `-fxx` (debug), so FreeRADIUS no longer starts
  in verbose debug mode by default.
- Added a writable `emptyDir` at `/var/run/radiusd` so the daemon can write its
  pidfile under `readOnlyRootFilesystem: true`.

## 1.1.0 (2026-05-29)

Major release. End-to-end modernization: values.yaml restructured with
section banners, TLS / cert-manager keys consolidated, a chart-internal
shared CA helper, full Gateway API resource set adapted for RADIUS traffic
(UDPRoute / TLSRoute), HPA template, bundled PostgreSQL subchart alongside
MariaDB, REST/JSON/PAM/PAP modules, top-level Helm keys cleaned up
(`modsEnabled:` → `modules:`, `sitesEnabled:` → `sites:`,
`database.bootstrap.*` → `bootstrap.database.*`), and a long list of
common template fixes.
**See "Upgrading → To 1.1.0" in the README for the migration steps your
`values.yaml` needs. These apply to any pre-1.1.0 release: the most recent,
1.0.3, still used the old `modsEnabled` / `sitesEnabled` / `ingress` /
`configuration` / `tls.autoGenerator` keys.**

### Added

- `templates/HorizontalPodAutoscaler.yaml` and
  `horizontalPodAutoscaler.{enabled,minReplicas,maxReplicas,targetCPU,targetMemory,metrics}`
  values block. Bitnami-style `metrics: []` passthrough overrides the
  CPU/memory shorthand for custom/external metrics. Deployment's `replicas:`
  drops out when the HPA is enabled.
- `templates/gateway-api/Gateway.yaml` — chart-rendered Gateway API Gateway
  with UDP listeners for auth/acct (and coa when enabled) and a RADSEC TLS
  listener (passthrough when `tls.enabled`, terminate when only
  `gateway.tls.enabled`). Auto-derives `allowedRoutes.namespaces.from` based
  on whether the Gateway lives in the app or a different namespace.
- `templates/gateway-api/UDPRoute.yaml` — UDPRoute resources for the
  RADIUS auth/acct/coa ports. Skipped on cluster GatewayClasses that don't
  support UDPRoute via the `st-common.capabilities.networkingGatewayUDPRoute`
  helper (returns `"false"`).
- `templates/gateway-api/TLSRoute.yaml` — TLSRoute for the RADSEC port,
  attached to the chart's Gateway (or ListenerSet).
- `templates/gateway-api/ReferenceGrant.yaml` — cross-namespace permission
  from the gateway's namespace to the FreeRADIUS Service.
- `templates/gateway-api/ListenerSet.yaml` — optional ListenerSet for adding
  extra listeners to the parent Gateway. v1 / v1alpha1 / `x-k8s.io`
  (`XListenerSet`) API-version drift handled transparently.
- `templates/secret/tls-ca.yaml` and `templates/secret/gateway-tls.yaml` —
  gateway-namespace TLS Secret and a chart-internal CA Secret shared by the
  in-pod RADSEC leaf and the gateway-namespace leaf. The self-signed CA is
  recovered via Helm `lookup` on subsequent renders so it persists across
  upgrades AND across in-pod → gateway path migrations (clients keep
  trusting).
- `templates/ServiceMonitor.yaml` for Prometheus Operator scraping —
  synthetic single-endpoint fallback plus full `endpoints[]` passthrough.
- `templates/PrometheusRule.yaml` reworked: gated on
  `st-common.capabilities.coreosMonitoringPrometheusRule.apiVersion`, honors
  a per-resource `namespace` override, renders rules via
  `st-common.tplvalues.render` so `expr` / `annotations` can use Helm
  `include` calls and `{{ `{{` }} $labels.x {{ `}}` }}` placeholders, and
  ships a curated default rule set (`FreeRADIUSDown`, `FreeRADIUSAbsent`,
  `FreeRADIUSAuthRejectRateHigh`, `FreeRADIUSAuthRequestsDropped`,
  `FreeRADIUSQueueSaturated`) targeting the
  `bvantagelimited/freeradius_exporter` metric names. The values block was
  renamed `metrics.prometheusRules` → `metrics.prometheusRule` (singular)
  and gained `namespace` / `groups` keys; `rules` is now a list (was an
  empty dict).
- `templates/extraDeploy.yaml` — render arbitrary extra manifests via
  `extraDeploy: []`.
- `templates/NOTES.txt` — install instructions including a gateway URL
  branch, port-forward and LoadBalancer paths, and a validation message
  when RADSEC is enabled without a configured cert source.
- `LICENSE` (Apache-2.0).
- `tls.certManager.{create,issuerRef}` — single canonical location for
  cert-manager-driven TLS issuance, consumed by both the release-namespace
  in-pod RADSEC `Certificate` and the gateway-namespace `Certificate`.
- `gateway.tls.{enabled,existingSecret,selfSigned,secrets}` — gateway-side
  TLS knobs replacing the old istio-specific `credentialName` rendering.
- `gateway.implementation` — explicit selector between `gateway-api` and
  `istio` resource sets.
- `gateway.gateway.{create,name,namespace}` nested form (replaces flat
  `gateway.name` / `gateway.namespace`).
- `gateway.tlsRoute.parentRefs` and `gateway.udpRoute.parentRefs` —
  explicit `parentRefs` overrides for the two route templates, defaulting
  to the chart-rendered ListenerSet (when present) or the chart's Gateway.
- `gateway.referenceGrant.{enabled,from,to}` for cross-namespace setups.
- `gateway.listenerSet.{enabled,parentRef,listeners}` for parent-Gateway
  attachment.
- `gateway.virtualService.{existingVirtualService,tls,tcp}` raw passthrough
  escape hatches for the istio path.
- **First-class FreeRADIUS exporter as a separate Deployment.** When
  `metrics.enabled: true`, the chart renders the
  [`bvantagelimited/freeradius_exporter`](https://github.com/bvantagelimited/freeradius_exporter)
  as its own Deployment + Service under `templates/metrics/` — NOT a
  sidecar on the FreeRADIUS pod. The exporter talks to the FreeRADIUS
  `status` virtual server over the in-cluster Service and exposes
  Prometheus metrics on its own Service at `service.ports.metrics`.
  Default image is `ghcr.io/bvantagelimited/freeradius_exporter:1.4.4`.
  New manifests:
  - `templates/metrics/Deployment.yaml` — exporter Deployment
  - `templates/metrics/Service.yaml` — exporter Service (`<fullname>-metrics`)
  - `templates/metrics/ServiceMonitor.yaml` — moved from top-level; selector now targets the exporter Service
  - `templates/metrics/PrometheusRule.yaml` — moved from top-level
  - `templates/metrics/NetworkPolicy.yaml` — exporter-pod NetworkPolicy (Prometheus → 9812, exporter → FreeRADIUS status). The complementary ingress rule on the FreeRADIUS pods (allow `component: metrics` → status port) stays in the main `templates/NetworkPolicy.yaml`.
  New values: `metrics.{replicaCount,extraArgs,extraEnvVars,resources,
  containerSecurityContext,livenessProbe,readinessProbe,
  customLivenessProbe,customReadinessProbe,podAnnotations,podLabels,
  nodeSelector,tolerations,affinity,priorityClassName,containerPorts.http,
  service.{type,port,nodePort,clusterIP,loadBalancerIP,
  loadBalancerSourceRanges,annotations}}`. The exporter's
  `RADIUS_PASSWORD` is wired from the chart-managed `sites-status-secret`
  automatically. Requires `sites.status.enabled: true` — enforced by
  a new `freeradius.validate` aggregator that calls `fail` during
  `helm install` / `helm upgrade` / `helm template` when the two flags are
  mismatched (the chart refuses to render rather than producing a
  non-functional exporter). The same aggregator also rejects
  `tls.enabled: true` without a configured cert source.
- `sites.status.listen` default changed from `127.0.0.1` to `0.0.0.0`
  so the standalone metrics exporter pod can reach the status virtual
  server through the cluster Service. NetworkPolicy locks down who can
  hit the port either way — only RADIUS clients and the metrics exporter
  pod are allowed.
- `service.ports.status` is now published on the main FreeRADIUS Service
  whenever `sites.status.enabled` is true (was previously only
  bound on the pod's loopback interface, unreachable from other pods).
  `service.nodePorts.status` added for completeness.
- `sites.dhcp.{enabled,existingConfigMap}` — optional DHCP virtual server
  (`templates/sites/dhcp.yaml`, off by default). Enabling mounts the `dhcp`
  virtual server at `sites-enabled/dhcp`; opening a DHCP listener port is left
  to `containerPorts` / `service` / `extraPorts`.
- A second `<fullname>-metrics` NetworkPolicy resource is rendered
  alongside the main one when `networkPolicy.enabled && metrics.enabled`:
  it allows Prometheus to scrape the exporter's `/metrics` endpoint and
  permits the exporter pod to egress to the FreeRADIUS status port +
  DNS only.
- `containerSecurityContext.{readOnlyRootFilesystem,allowPrivilegeEscalation,seccompProfile,runAsNonRoot}`
  — Pod Security Standard "restricted" profile defaults. `SYS_PTRACE` kept
  in `capabilities.add` because the upstream `radiusd -fxx` exec mode uses
  ptrace for debug output.
- `command`, `args`, `extraPorts` container-spec passthroughs.
- `persistence.{dataSource,selector}` and an explicit doc-block on
  `mountPath` calling out the upstream image's UID/GID 101.
- `freeradius.gateway.tlsSecretName`, `freeradius.gateway.routeParentRefs`,
  `freeradius.tls.ca.{secretName,init}` helpers (single source of truth so
  the gateway listener and the gateway-tls Secret can never drift apart;
  UDPRoute and TLSRoute share parentRef defaulting).
- **Bundled PostgreSQL subchart support.** New `postgresql:` block in
  `values.yaml` mirroring the existing `mariadb:` block (same `auth.*` and
  `architecture` shape), gated on `postgresql.enabled` via a new Chart.yaml
  dependency on Bitnami `postgresql 16.x.x`. Enabling it requires
  `modules.sql.dialect: postgresql`; the new
  `freeradius.validate.sql.backend` aggregator rejects any other combination
  (two subcharts at once, dialect/subchart mismatch, sqlite + subchart, no
  backend at all). The PostgreSQL subchart's auth secret is wired in
  automatically via the `freeradius.sql.secretName` / `secretKey` helpers
  (key `password` for postgresql, `mariadb-password` for mariadb).
- `freeradius.postgresql.fullname` helper, mirroring
  `freeradius.mariadb.fullname` for the new subchart.
- `modules.sql.{readGroups,readProfiles}` values, mirroring the existing
  `readClients` knob. Both default to `true` (upstream rlm_sql default);
  rendered into the previously-commented-out `read_groups` / `read_profiles`
  directives in the sql module config (`templates/modules/sql.yaml`).
- **EAP module support (rlm_eap) — EAP-TLS + EAP-TTLS.** New `modules.eap:`
  values block rendered into its own ConfigMap (`<release>-mods-eap`,
  `templates/modules/eap.yaml`) and mounted directly at `mods-enabled/eap`
  when `modules.eap.enabled: true` — it is NOT aggregated into the shared
  `<release>-modules` ConfigMap. The values mirror FreeRADIUS's own structure:
  - `modules.eap.tlsConfig.*` — the shared `tls-config tls-common` block
    (server cert + TLS engine settings:
    `{name,autoGenerated,certificates_secret,cert_filename,cert_key_filename,
    cert_ca_filename,private_key_password,random_file,cipher_list,
    cipher_server_preference,min_version,max_version}` plus `cache`/`verify`/
    `ocsp` sub-maps rendered via `freeradius.tplvalues.renderConfig`). A
    fourth TLS context, mounted at `/opt/startechnica/freeradius/certs-eap`,
    signed off the chart's shared internal CA via
    `templates/secret/eap-tls.yaml` — mandatory whenever the module is enabled.
  - `modules.eap.methods` — the list of EAP method blocks to render
    (`tls`, `ttls`, `mschapv2`, `md5`, `pap`, `peap`). Each method's body
    comes from the matching `modules.eap.<method>` map via
    `freeradius.tplvalues.renderConfig` (every key emitted as a `key = value`
    directive); a method with no map renders an empty `<method> {}`. `tls` /
    `ttls` are the TLS-based outer methods (reference `tls-common` through
    their `tls:` value); `mschapv2` / `md5` / `pap` are inner types tunnelled
    by TTLS. Remove a method from the list to disable it (EAP-MD5 is legacy).
  - `modules.eap.defaultType` — `default_eap_type`; must be one of the
    enabled outer methods (`tls` / `ttls`).

  EAP runs over plain UDP RADIUS and is independent of RADSEC
  (`tls.enabled`). New `freeradius.eap.tlsConfig.{certPath,certKeyPath,
  caCertPath,secretName,createSecret}` helpers; `mods-eap-tls-privkey-password`
  auto-generated into the credentials Secret and injected at runtime as
  `$ENV{FREERADIUS_MODS_EAP_TLS_PRIVKEY_PASSWORD}` (never baked into the
  ConfigMap). The `freeradius.validate.eap` aggregator rejects no outer method
  in `methods`, a `defaultType` that isn't an enabled outer method, and
  `enabled: true` with no `tlsConfig` cert source. No `dh_file` is referenced
  (FreeRADIUS 3.2 negotiates ephemeral DH/ECDHE; the chart ships no DH params
  file).
- **JSON xlat module support (rlm_json).** New `modules.json:` values
  block, rendered into its own `<release>-mods-json` ConfigMap
  (`templates/modules/json.yaml`). When enabled, the module exposes the
  `%{json_encode:...}` xlat for serialising attributes into JSON in policies
  and rlm_rest payloads. The template is rendered through Helm `tpl`, but unlike
  the flat modules the rlm_json config is a nested `encode { attribute {}
  value {} }` stanza (which `freeradius.tplvalues.renderConfig`'s
  `key = value` flattening cannot express), so the block structure is fixed
  in the template and only the leaf directives are templated from
  `modules.json.encode.*`: `outputMode` (object / object_simple / array /
  array_of_names / array_of_values), `attribute.prefix`, and the
  `value.{singleValueAsArray,enumAsInteger,datesAsInteger,alwaysString}`
  value-formatting flags.
- **PAM authentication module support (rlm_pam).** New `modules.pam:`
  values block (`enabled`, `pam_auth`, default `radiusd`). The pam module
  ConfigMap (`templates/modules/pam.yaml`) is rendered through Helm `tpl`:
  every key under `modules.pam` except
  `enabled` is emitted into the `pam {}` block as a `key = value` directive
  (via `freeradius.tplvalues.renderConfig`), so values use FreeRADIUS
  directive names directly and no `FREERADIUS_MODS_PAM_AUTH` env var is
  needed. The upstream image ships `/etc/pam.d/radiusd`; to use a custom PAM
  service, override `pam_auth` AND mount the matching config via
  `extraVolumes` / `extraVolumeMounts`. Virtual-server wiring
  (`Auth-Type := PAM` in `authorize`, `pam` in `authenticate {}`) is the
  user's responsibility.
- **PAP authentication module support (rlm_pap).** New `modules.pap:`
  values block (`enabled`, `existingConfigMap`, `normalise`, default `true`).
  The pap module ConfigMap (`templates/modules/pap.yaml`) is rendered through
  Helm `tpl`: every key under `modules.pap` except `enabled` /
  `existingConfigMap` is emitted into the `pap {}` block as a `key = value`
  directive (via `freeradius.tplvalues.renderConfig`), so values use
  FreeRADIUS directive names directly. The module compares a cleartext
  `User-Password` against a "known good" password supplied by another module
  (`sql`, `files`, …). Virtual-server wiring (`pap` in `authorize {}` to set
  `Auth-Type := PAP`, and in `authenticate {}` to verify) is the user's
  responsibility.
- **REST module support (rlm_rest).** New `modules.rest:` values block,
  rendered into its own `<release>-mods-rest` ConfigMap
  (`templates/modules/rest.yaml`) when `modules.rest.enabled: true`. Structural
  config is rendered directly from `.Values.modules.rest.*` into the module
  file — the base URI, connect timeout, per-section URI/method/body (authorize
  / authenticate / accounting / post-auth), HTTP auth (none/basic/digest/bearer),
  and TLS verification toggles. Only the password stays as
  `$ENV{FREERADIUS_MODS_REST_PASSWORD}` (a secret, injected by the Deployment
  via secretKeyRef, never baked into the ConfigMap). A separate TLS context
  (`modules.rest.tls.*`) signs an optional client-cert leaf off the chart's
  shared CA — third TLS namespace alongside RADSEC and SQL, mounted at
  `/opt/startechnica/freeradius/certs-rest/`. `auth != none` pulls the password
  from `mods-rest-password` in the chart-managed credentials Secret (length 32,
  auto-generated) unless `modules.rest.existingSecret` is set. New
  `freeradius.rest.{tls.{secretName,createSecret,certPath,certKeyPath,caCertPath},secretName,secretKey,validate}`
  helpers. The validator rejects `enabled: true` without `connect_uri`,
  `auth != none` without a password source, `tls.enabled` without a cert
  source, and unrecognised `auth` values.
- **Keycloak authentication + client-role mapping.** New `keycloak.*` values
  block. When `keycloak.enabled`, a self-contained `rlm_lua` script
  (`scripts/keycloak-mapper.lua`, module instance `mods-enabled/keycloak_lua`)
  authenticates users against Keycloak's OIDC token endpoint (OAuth2 ROPC
  password grant) and reads their client roles via RFC 7662 token
  introspection — performing the HTTPS calls itself (needs `rlm_lua`,
  `lua-cjson` and an HTTPS Lua lib such as `luasec` in the image), so
  `rlm_rest` is not involved. The Lua is pure fetch-and-parse: it sets one
  `&control:Class` per role and returns a plain rcode. ALL policy lives in
  unlang (`policy.d/keycloak`): `keycloak_authorize` sets
  `&control:Auth-Type := Accept` on success and calls `keycloak_roles`, a
  generated first-match-wins policy mapping roles → RADIUS reply attributes
  from `keycloak.roleMappings`. ROPC only works for cleartext-password flows
  (PAP / EAP-TTLS-PAP inner) — PEAP/MSCHAPv2 cannot. The confidential client
  secret is held in a `<release>-keycloak` Secret and injected as
  `$ENV{KC_CLIENT_SECRET}`; `KC_BASE_URL` / `KC_REALM` / `KC_CLIENT_ID` /
  `KC_SCOPE` are passed as env. `keycloak.wireDefaultSite` (default true) wires
  the call into the `default` site's `authorize` section; `keycloak.realm` is
  required when enabled; `denyWithoutRole` rejects users whose roles match no
  mapping. New templates under `templates/mods-config/keycloak/`
  (`configmap-lua.yaml`, `configmap-policy.yaml`, `secret.yaml`).
- **`modsConfig` — custom `mods-config` data.** New `modsConfig` map: each
  top-level key is a subdirectory rendered into its own ConfigMap
  (`templates/configmap/mods-config.yaml`) and projected at
  `/etc/freeradius/mods-config/<subdir>/` (filenames = keys, values rendered
  with `tpl`). For module *data* (REST body templates, policy snippets,
  attribute maps) referenced from a `mods-enabled/` instance — placing a file
  here does not load a module on its own.
- **`prepare-sites` init container.** Always runs: copies the projected virtual
  servers into a writable `emptyDir` and `chmod 0711`s the sites-enabled
  directory (projected/configMap volumes are mounted read-only and cannot be
  chmod'd).
- `sites.includeDir` (`/opt/startechnica/freeradius/sites-enabled`) and
  `policies.includeDir` (`/opt/startechnica/freeradius/policy.d`) — configurable
  include directories. `sites.includeDir` also drives the `$INCLUDE` in the
  bundled `radiusd.conf` (the inline `configurations` value is rendered through
  `tpl`, so `{{ .Values.sites.includeDir }}` resolves there).
- `<release>-scripts` ConfigMap (`templates/configmap/scripts.yaml`) holding the
  health-check probe scripts and `db-bootstrap.sh`; the db-bootstrap script is
  mounted into the bootstrap init container via `subPath`.

### Changed

- **values.yaml**: complete reorganization with explicit `## ====` section
  banners. Order: Global → Common → Image → Configuration → Authentication →
  Deployment → Pod → Container → Persistence → Metrics → Traffic Exposure →
  TLS → RBAC → Gateway → Database.
- **Template subdirectory layout** lowercased for consistency:
  `templates/Istio/` → `templates/istio/`, `templates/ConfigMap/` →
  `templates/configmap/`, `templates/Secret/` → `templates/secret/`. The
  `_helpers/` subdirectory was consolidated into a single
  `templates/_helpers.tpl`.
- **Deployment.yaml** pod-template annotations: `commonAnnotations` is now
  propagated to pods (was only `podAnnotations`). Checksum annotations are
  now individually gated on whether the chart actually manages each source
  (skipped when the user supplies `existingConfigmap` or `auth.existingSecret`,
  and when SQL TLS / RADSEC TLS aren't actually being auto-generated). Pod
  port names now use the standard `<proto>-<purpose>` form
  Container ports use the short form (`auth`, `acct`, `coa`, `radsec`,
  `status`); Service ports keep the Istio service-discovery
  protocol prefix (`udp-auth`, `udp-acct`, `udp-coa`, `tls-radsec`,
  `http-metrics`) so Istio's proxy auto-detection picks the right
  L4/L7 handler.
- **Deployment.yaml** also now emits `automountServiceAccountToken` on the
  pod, `terminationGracePeriodSeconds`, and an optional metrics container
  port when `metrics.enabled` is true.
- **Certificate.yaml** rewritten to honor `tls.certManager.create` with a
  release-namespace block (in-pod RADSEC) AND a gateway-namespace block
  (when `gateway.enabled && gateway.tls.enabled`). Uses
  `st-common.gateway.namespace` with proper fallback (was unconditionally
  using `ingress.hostname` — broken for RADIUS).
- **istio/Gateway.yaml** + **istio/VirtualService.yaml**: dropped all
  `ingress.*` references; hosts derived from `gateway.hostnames`. TLS
  listener auto-derives PASSTHROUGH vs SIMPLE based on `tls.enabled` vs
  `gateway.tls.enabled`. Per-listener port names use the standard
  `<proto>-<purpose>` form.
- **NetworkPolicy.yaml**: added `allowExternalEgress`, `extraIngress`,
  `extraEgress`, `ingressNSMatchLabels`, `ingressNSPodMatchLabels`; metrics
  port now sourced from `containerPorts.metrics` (was the non-existent
  `containerPorts.metrics` in older 0.x — same name, but the new key is
  actually rendered into the exporter Deployment's container port).
- **Service.yaml**: added the metrics port when `metrics.enabled`; port
  names match the Deployment.
- **NOTES.txt** rewritten — namespace placeholders use `st-common.names.namespace`,
  ClusterIP selector uses `.Chart.Name`, and a new branch prints the gateway
  URL when `gateway.enabled`.
- **labels block across all templates** standardized to
  `st-common.labels.standard (dict "customLabels" .Values.commonLabels "context" $)`
  — drops the duplicate manual `commonLabels` append that previously
  followed every `st-common.labels.standard .` call.
- **Bumped st-common dependency** to `0.1.21` (was `0.1.10`). Picks up the
  `networkingGatewayUDPRoute` and `networkingGatewayListenerSet` capability
  helpers, plus the `gateway.{fullname,namespace}` resource-name helpers.
- **SQL connection helpers renamed**: `freeradius.mariadb.{host,port,name,user,secretName,secretKey}`
  → `freeradius.sql.{host,port,name,user,secretName,secretKey}`. The new
  helpers branch three ways on `mariadb.enabled` → `postgresql.enabled` →
  `externalDatabase.*` (first match wins) and are wired into both the rendered
  sql module ConfigMap (`templates/modules/sql.yaml`) and the `db-bootstrap`
  init container. `freeradius.mariadb.fullname` is kept (still used internally to
  resolve the MariaDB subchart's Service name and Secret name).
- **`externalDatabase.port` default changed** from `3306` to `""`. The
  `freeradius.sql.port` helper now picks a dialect-appropriate default
  (`3306` for mysql, `5432` for postgresql) when the value is empty, so
  postgresql users on external databases no longer have to flip an unrelated
  knob. Any explicit `externalDatabase.port` value still wins.
- **Sites volume reworked.** All enabled virtual servers (chart sites +
  `extraSites`) are aggregated into one projected volume (`freeradius-sites-tmp`)
  and staged by the new `prepare-sites` init container into a `0711` `emptyDir`
  mounted at `sites.includeDir`. This supersedes the per-site
  `freeradius-site-<name>` read-only mounts (each site is still its own
  ConfigMap, now projected rather than mounted directly). `radiusd.conf` is
  bundled via the top-level `configurations` value and `$INCLUDE`s
  `sites.includeDir`.
- **`volumePermissions` → `bootstrap.volumePermissions`.** The chown/chmod init
  container config moved under `bootstrap.*` and now defaults `enabled: true`.
- **SQL TLS moved to its own directory.** `freeradius-sql-tls` now mounts at
  `/opt/startechnica/freeradius/certs-sql` (read-only) using the native
  `tls.crt` / `tls.key` / `ca.crt` filenames — resolving a path collision with
  the RADSEC `freeradius-tls` mount at `/certs` and dropping the bespoke
  `sql-*.crt` Secret `items` renaming. The `freeradius.sql.tls.*` path helpers
  follow.
- Health-check probes now invoke their scripts from `/scripts` (the new
  `<release>-scripts` ConfigMap), and the status-probe port is rendered from
  values (the `FREERADIUS_SITES_STATUS_PORT` env indirection was dropped).

### Removed (BREAKING — see Upgrading)

- **`modsEnabled:` → `modules:`** (top-level Helm key). Every sub-key keeps
  its existing shape — `sql`, `rest`, `json`, `pam` are unchanged. Related
  chart-internal changes:
  - Each enabled module renders into its OWN ConfigMap
    (`templates/modules/<name>.yaml`, named `<release>-mods-<name>`), mounted
    at `mods-enabled/<name>` via its own pod volume `freeradius-mods-<name>`,
    with a per-module `checksum/configmap-mods-<name>` pod annotation. There
    is no single aggregated `<release>-modules` ConfigMap.
  - In-container mount path `/etc/freeradius/mods-enabled/<name>` is
    unchanged (FreeRADIUS daemon convention). Module config is now rendered
    directly from `.Values` into each module ConfigMap (no
    `FREERADIUS_MODS_*` env-var indirection); only secrets (DB/REST passwords,
    the EAP private-key passphrase) are injected as `$ENV{}` by the Deployment.
- **`sitesEnabled:` → `sites:`** (top-level Helm key). Related
  chart-internal changes (mirror the per-module split):
  - Each virtual server renders into its OWN ConfigMap
    (`templates/sites/<name>.yaml`, named `<release>-sites-<name>`), mounted
    at `sites-enabled/<name>` via its own pod volume `freeradius-site-<name>`,
    with a per-site `checksum/configmap-sites-<name>` pod annotation. There is
    no single aggregated `<release>-sites` ConfigMap, and the source directory
    `files/sites/` was removed — each site's config is inlined into its
    template (mirroring `templates/modules/<name>.yaml`).
  - Each site gained a `sites.<name>.existingConfigMap` BYO override (resolved
    by the new `freeradius.site.configMapName` helper), matching the
    per-module `existingConfigMap` pattern. `default` and `innerTunnel` are
    always rendered; `coa`, `status`, `dhcp`, and the RADSEC `tls` site are
    gated by their respective enable flags. The `inner-tunnel` on-disk/site
    name maps to the `sites.innerTunnel` values key.
  - In-container mount path `/etc/freeradius/sites-enabled/<name>` is
    unchanged (FreeRADIUS daemon convention). Site config (listen ports/
    addresses, RADSEC cert/key/CA paths, cipher) is now rendered directly from
    `.Values` into each site ConfigMap (no `FREERADIUS_SITES_*` env-var
    indirection); only secrets (status secret, RADSEC private-key passphrase,
    client secret) stay as `$ENV{}` injected by the Deployment. The lone
    exception kept in `configmap/envvars.yaml` is `FREERADIUS_SITES_STATUS_PORT`,
    still referenced by the Deployment's radclient probes.
- `ingress.*` block (entire block) — FreeRADIUS doesn't speak HTTP. The
  `Certificate.yaml` template now derives `dnsNames` from `gateway.hostnames`
  and the Service FQDN; istio Gateway and VirtualService likewise consume
  `gateway.hostnames`.
- `tls.autoGenerator.certmanager.{enabled,issuerKind,issuerName}` — moved to
  `tls.certManager.{create,issuerRef.{kind,name}}`. The new shape covers
  BOTH the in-pod RADSEC `Certificate` AND the gateway-namespace
  `Certificate` from a single switch.
- `tls.secretName` (unused) — gateway TLS secret name is now resolved by the
  `freeradius.gateway.tlsSecretName` helper.
- Flat `gateway.{dedicated,gatewayApi,name,namespace}` — consolidated into
  `gateway.gateway.{create,name,namespace}` (nested) and
  `gateway.implementation`.
- `gateway.extraRoute` (unused).
- `sites.tls.enabled` (moved) — RADSEC enablement is now driven by
  the top-level `tls.enabled` flag. `sites.tls.{cipher,privateKeyPassword}`
  remain.
- `metrics.prometheusRules` (renamed, plural) — renamed to
  `metrics.prometheusRule.*` (singular) to match the upstream
  Prometheus Operator CRD naming. New keys:
  `metrics.prometheusRule.{enabled,namespace,additionalLabels,groups,rules}`
  — `groups` takes a verbatim `spec.groups` list and `rules` falls back to
  a single chart-fullname group when only flat rules are provided.
- `auth.{createClientUser,clientUser,clientUserPassword}` (unused — the
  `clients.conf` rendering doesn't read these).
- `freeradius-sqlite` `emptyDir` volume + its mount — the SQLite database file
  lives on the `data` volume (its path sits under `persistence.mountPath`), so
  the separate volume was redundant (and non-persistent).
- dead `shared-certs` `emptyDir` volume + its read-only mount — nothing wrote to
  or read from `/opt/startechnica/freeradius/shared-certs`.
- top-level `volumePermissions` (relocated to `bootstrap.volumePermissions`).
- `healthCheck.*` values indirection — the probe scripts now use fixed names
  (`startup.sh` / `healthcheck.sh`) under `/scripts`.

### Deprecated

- `tls.existingSecretName` — use `tls.certificatesSecret`. The
  `freeradius.tls.secretName` helper falls back to `existingSecretName` so
  existing overrides keep working until the next major bump.
- `modules.sql.tls.existingTlsSecret` — use
  `modules.sql.tls.certificatesSecret`. Same fallback pattern as above.

### Fixed

- Deployment.yaml: `resources:` block referenced `.resources` instead of
  `.Values.resources` (and `.resourcesPreset` instead of
  `.Values.resourcesPreset`), so the resources block never rendered. Same
  for `customReadinessProbe` — the conditional was missing an `else`, so
  the custom probe AND the default probe could both fire.
- Deployment.yaml: checksum/configmap paths used the old camelCased subdir
  (`/ConfigMap/`, `/Secret/`) — would have broken outright after the
  lowercase rename. Now point at `/configmap/` and `/secret/`.
- Deployment.yaml: `replicas:` always rendered even when HPA was meant to
  manage the replica count. Now gated on `not horizontalPodAutoscaler.enabled`.
- secret/sql-tls.yaml + secret/tls.yaml: each called `genCA` independently,
  producing two distinct self-signed CAs per render. Now both leaf certs go
  through the shared `freeradius.tls.ca.init` helper, which `lookup`s the
  persistent `<fullname>-tls-ca` Secret first (recovering Cert+Key as a
  `sprig.certificate` struct via `buildCustomCert`) and falls back to
  `genCA` only on first install. This keeps clients trusting the same CA
  across `helm upgrade` and across path migrations (in-pod ↔ gateway).
- istio/Gateway.yaml: emitted an empty `hosts: - ""` entry when
  `ingress.hostname` was unset (which it always was for pure-gateway users).
  Now driven by `gateway.hostnames` with a `["*"]` fallback.
- istio/VirtualService.yaml: hardcoded `svc.cluster.local` FQDN ignored
  `gateway.clusterDomain` / `clusterDomain`. Now uses
  `default .Values.clusterDomain .Values.gateway.clusterDomain`.
- istio/VirtualService.yaml: iterated `gateway.hostnames` as
  `$host.name | quote` (object shape) but values.yaml defines them as
  strings → rendered empty entries. Now correctly iterates string entries.
- ServiceAccount.yaml + Role.yaml + RoleBinding.yaml + PDB / PVC /
  PrometheusRule: removed the duplicate `commonLabels` block that followed
  every `st-common.labels.standard .` call; consolidated into the single
  `(dict "customLabels" .Values.commonLabels "context" $)` argument.
- configmap/clients.yaml: previously emitted the literal string `client`
  with no body. Now renders proper `client <name> { ... }` blocks from
  `.Values.clients`.
- sites `tls` (now `templates/sites/tls.yaml`): was gated on
  `sites.tls.enabled` even though the rest of the chart drives RADSEC
  off `tls.enabled` (the in-pod TLS flag). Now correctly gated on
  `tls.enabled`.
- sites `inner-tunnel`: previously rendered into the bundled `<release>-sites`
  ConfigMap but never mounted, so EAP-TTLS/PEAP fell back to the base image's
  built-in copy. It is now mounted at `sites-enabled/inner-tunnel` from its
  own ConfigMap so the chart-shipped config is authoritative.
- sites `status` mount: was attached unconditionally even though its ConfigMap
  entry was gated on `sites.status.enabled`, so disabling the status site left
  a volumeMount referencing a missing subPath key (pod would fail to start).
  The mount is now gated on `sites.status.enabled` too.
- **`helm template` failed outright on 1.0.3 with `unexpected EOF`**
  ([#96](https://github.com/startechnica/apps/issues/96)). An unclosed
  conditional in the 1.0.3 `Deployment.yaml` (`templates/Deployment.yaml:367`)
  broke rendering for everyone pulling the published chart. The Deployment was
  reworked for this release and now renders cleanly (`helm template` /
  `helm lint` pass).
- **initContainers from `values.yaml` were ignored**
  ([#84](https://github.com/startechnica/apps/issues/84)). The 1.0.x
  `initContainers:` block only rendered the `volume-permissions` container and
  never appended `.Values.initContainers`. The Deployment now always emits an
  `initContainers:` block and includes `.Values.initContainers` (via
  `st-common.tplvalues.render`) ahead of the chart's own init containers
  (`prepare-sites`, `volume-permissions`, `db-bootstrap`).
- **rlm_sql schema not loaded into the database**
  ([#67](https://github.com/startechnica/apps/issues/67)). `files/schema/mysql.sql`
  shipped with the chart but no template wired it into MariaDB or any other
  database. Now loaded by a new `db-bootstrap` init container on the
  FreeRADIUS pod (gated on `modules.sql.enabled` and
  `bootstrap.database.enabled`, default true). The schema is rendered into
  a chart-managed `<fullname>-db-schema` ConfigMap by
  `templates/configmap/db-schema.yaml`, then mounted at `/schema/schema.sql`
  in the init container which waits for the DB to accept TCP connections
  (`bootstrap.database.waitTimeout`, default 120s) before applying the
  schema via the dialect-appropriate CLI (`mysql` or `psql`). Idempotent —
  every shipped schema uses `CREATE TABLE IF NOT EXISTS`, so restarts are
  no-ops. Works with both `mariadb.enabled: true` and
  `externalDatabase.*`; skipped when `dialect: sqlite` (rlm_sql's own
  `bootstrap = "${modconfdir}/sql/main/sqlite/schema.sql"` directive loads
  the schema at first connect — the upstream image already ships that
  file). The chart now ships dialect-specific schema files at
  `files/schema/{mysql,postgresql,sqlite}.sql` covering every dialect
  `modules.sql.dialect` accepts. PostgreSQL uses native `inet` / `cidr`
  types and partial indexes; SQLite uses `INTEGER PRIMARY KEY AUTOINCREMENT`
  and plain `TEXT` / `DATETIME` columns. The bootstrap-image helper carries
  per-dialect canonical defaults internally (`bitnami/mariadb:11` for
  mysql, `bitnami/postgresql:17` for postgresql — each ships the matching
  CLI), so postgresql users don't need to flip two unrelated keys to make
  bootstrap work.
- **`.Values.configurations` produced a dangling ConfigMap reference**
  ([#97](https://github.com/startechnica/apps/issues/97)). The Deployment
  mounted `freeradius.configurationCM` whenever `configurations` was set,
  but no template actually materialised the ConfigMap, so the pod failed
  to start with `configmap "<release>-freeradius-configurations" not found`.
  Now rendered by `templates/configmap/configuration.yaml` — emitted when
  `.Values.configurations` is non-empty or `files/radiusd.conf` is bundled
  AND the user hasn't supplied `.Values.configurationsConfigMap` (the BYO
  path short-circuits the helper and skips this template).
  Note: this rename `configuration`→`configurations` (and
  `configurationConfigMap`→`configurationsConfigMap`) is a breaking change
  for any pre-1.1.0 override that set those keys (1.0.3 still shipped
  `configuration`).

### Added (companion changes for the two fixes above)

- `bootstrap.database.{enabled,schemaConfigMap,image,resources,waitTimeout}`
  values block. The per-dialect canonical image defaults
  (`bitnami/mariadb:11` for mysql, `bitnami/postgresql:17` for postgresql)
  live inside the `freeradius.bootstrap.database.image` helper, NOT in
  values.yaml — `bootstrap.database.image.*` ships with empty defaults
  (`registry: ""`, `repository: ""`, `tag: ""`) so each empty field falls
  through to the dialect default at render time. Any non-empty user value
  here wins, field-by-field, so you can swap registry/tag without losing
  the dialect-driven repository default. (Earlier cuts of this release
  shipped a single hardcoded `bitnami/mariadb:11` default plus a
  repo-string-match auto-swap to `bitnami/postgresql:17`; the helper-based
  defaults replace that opaque magic.)
- `freeradius.bootstrap.database.{schemaConfigMapName,image,cmd}` helpers.
  The `cmd` helper returns the dialect-appropriate `mysql`/`psql`
  invocation, or an empty string for sqlite (which is the sentinel that
  tells the Deployment to skip the init container and ConfigMap altogether).
- `templates/configmap/configuration.yaml` and
  `templates/configmap/db-schema.yaml`.
- `files/schema/postgresql.sql` — PostgreSQL-dialect rlm_sql schema mirroring
  the table set in `files/schema/mysql.sql`, with PostgreSQL-native types
  (`bigserial`, `inet`, `cidr`, `timestamp with time zone`) and partial
  indexes on optional accounting columns. Loaded by the `db-bootstrap` init
  container described above.
- `files/schema/sqlite.sql` — SQLite-dialect rlm_sql schema covering the
  third dialect listed in `modules.sql.dialect`. Not loaded by the
  `db-bootstrap` init container (SQLite is a local file, not a network
  service) — instead, rlm_sql's own `bootstrap` directive (the sqlite{} block
  in `templates/modules/sql.yaml`) loads the schema on first open of an
  empty database file. Shipped for users who want to override the upstream
  image's bundled SQLite schema; wire it in via
  `bootstrap.database.schemaConfigMap` + `extraVolumes` / `extraVolumeMounts`
  mounting over `/etc/freeradius/mods-config/sql/main/sqlite/schema.sql`.

### 1.0.3 (2025-03-19) — appVersion 3.2.7

- Custom `livenessProbe` / `readinessProbe` / `startupProbe` support.
- `resourcesPreset` support.
- SQLite volume mount (`freeradius-sqlite`) for the SQLite dialect.
- Database helper tidy-up.
- Fixed a wrong env filename referenced in the Deployment's checksum annotations.

### 1.0.2 (2025-03-13) — appVersion 3.2.7 (from 3.2.3)

- Dropped the Bitnami common chart dependency.
- Added an init container; reworked container `args` (thread enablement).
- Added `containerSecurityContext`.
- Added TLS to ingress; VirtualService fixes.
- Fixed `allocateLoadBalancerNodePorts` logic; expanded README.

### 1.0.1 (2023-07-25) — appVersion 3.2.3

- Render fixes: removed range conditionals, fixed a stray `{{- end }}`, RADSEC
  protocol, port indentation, and Gateway hosts/servers.

### 1.0.0 (2023-07-25) — appVersion 3.2.3 (from 3.2.1)

- First 1.0 release. Deployment checksum annotations; TLS mounts +
  secret-conditional rendering; SQL TLS helper; PVC rename; repeated
  `volumePermissions` and startup-args fixes.

### 0.1.9 (2022-11-03) — appVersion 3.2.1

- Updated images to FreeRADIUS v3.2.1.

### 0.1.8 (2022-06-24) — appVersion 3.2.0

- New dependencies; certs fix; removed Chart annotations.

### 0.1.7 (2022-06-21) — appVersion 3.2.0

- NetworkPolicy (with port protocol) and `namespaceOverride` values; security
  parameter fixes; `service.allocateLoadBalancerNodePorts`; initscripts.

### 0.1.6 (2022-06-03) — appVersion 3.2.0 (from 3.0.25)

- Updated to FreeRADIUS 3.2.0. Added the `clients` template + `clients.conf`;
  reworked initContainers / securityContext / volumes; diagnosticMode toggling.

### 0.1.5 (2022-05-27) — appVersion 3.0.25

- Fixed coa / tls / mods volumeMounts.

### 0.1.4 (2022-05-27) — appVersion 3.0.25

- RADSEC support: radsec Service, tls/coa sites, the `shared-certs` mount, and
  TLS env / deployment / certificate fixes.

### 0.1.3 (2022-02-16) — appVersion 3.0.25

- TLS generator + secret volume; cert directory / altNames fixes; removed
  dependencies.

### 0.1.2 (2022-02-16) — appVersion 3.0.25

- Added a TLS helper; documentation.

### 0.1.1 (2022-02-15) — appVersion 3.0.25

- Minor fixes.

### 0.1.0 (2022-02-15) — appVersion 3.0.25

- Initial FreeRADIUS Helm chart.
