# Changelog

## 1.2.0 (2026-06-02)

### Added

- **Generic OIDC authentication module (`modules.oidc.*`).** Replaces
  the dedicated Keycloak module from 1.1.0 (which is now removed — see
  `### Removed` below). Provider-agnostic: works against any OIDC
  provider with an RFC 6749 token endpoint and (optionally) an RFC 7662
  introspect endpoint — Keycloak, Authentik, Azure AD, Auth0, Okta,
  etc. Configure any number of backends under
  `modules.oidc.instances.<name>` with `tokenUrl` (required), optional
  `introspectUrl`, OAuth2 client credentials (`clientId` +
  `clientSecret` / `existingSecret`), TLS material (`tls.caCert` /
  `tls.existingSecret` / `tls.insecure`), and claim-path config
  (`rolesClaim`, `groupsClaim`, `roleAttribute`, `groupAttribute`).
  NAS-to-backend binding via `clients.<x>.oidc: <name>` renders an
  `if (Packet-Src-IP-Address == …) { oidc_<name>_authorize }` dispatch
  chain into `sites/default` and `sites/inner-tunnel`.
  `modules.oidc.unmatchedReject` — when `true` and no `default` instance
  is wired, the dispatch chain's `else` branch rejects unmatched NAS
  instead of falling through to `pap`.

- **Per-instance OIDC features:**
  - `roleMappings` / `groupMappings` — unlang reply-mapping policies
    keyed off the claim path (`rolesClaim`, `groupsClaim`). Roles land
    in `&control:<roleAttribute>` (default `Class`); groups in
    `&control:<groupAttribute>` (default `Class` — validator rejects
    when both attributes collide and both mappings are non-empty). The
    chart emits `oidc[_<name>]_roles` and `oidc[_<name>]_groups` policy
    blocks alongside the main authorize policy.
  - `attributeMappings` — generic `{claim, reply}` engine copying any
    top-level JWT claim verbatim to a reply attribute (e.g.
    `preferred_username` → `User-Name`, `sub` → `Class`). The chosen
    reply attrs are added to the cache `update {}` so they survive
    cache hits.
  - `require` — list of JWT claim names that must be truthy after
    decode (or introspection). Catches "user authenticated but
    admin-disabled-since-issuance" via e.g.
    `require: [email_verified]`; rejects early before any reply attrs
    are populated.
  - `introspect` — switches the post-ROPC claim source from local
    JWT-payload decode to RFC 7662 introspection at `introspectUrl`.
    Catches token revocation, admin-disabled-since-issuance, and
    provider key rotation. Validator rejects `introspect: true` without
    a client secret (RFC 7662 calls are HTTP-Basic-authenticated).
  - `refreshTokenCache` — only meaningful with `cache.enabled`. The
    ROPC response's `refresh_token` rides out in
    `&control:Tmp-String-9` so the cache layer stores it; a second
    module instance `oidc[_<name>]_validate` (rlm_python3, same script,
    `func_authorize = "validate"`) is rendered, and the policy calls
    it on cache hit. The validator attempts `grant_type=refresh_token`
    against the IdP: HTTP 200 confirms the session is alive, 400/401
    triggers cache-entry invalidation + reject, network FAIL falls
    through gracefully with the cached attrs intact.

- **Per-instance OIDC K8s resources:**
  - One module ConfigMap (`<fullname>-oidc[-<name>]`) for
    `mods-enabled/oidc[_<name>]` — the rlm_python3 module instance
    block.
  - One policy ConfigMap (`<fullname>-oidc[-<name>]-policy`) for
    `policy.d/oidc[_<name>]` — wraps the module with optional rlm_cache
    cache-aside and cache-hit refresh-token validate.
  - One client-secret Secret per instance (skipped under
    `existingSecret`); `client_secret` rides into the pod via
    `FREERADIUS_OIDC[_<NAME>]_CLIENT_SECRET` env.
  - One TLS CA Secret per instance (skipped under `tls.existingSecret`),
    mounted at `/etc/freeradius/certs-oidc[-<name>]/ca.crt`.

- **Shared OIDC python library + per-instance wrappers.** A single
  `<fullname>-oidc-py` ConfigMap renders the shared `oidc.py`
  library — pure logic, no env reads, no module-level config — so one
  bug fix to the library propagates to every instance on the next
  `helm upgrade`. A single `<fullname>-oidc-python` ConfigMap carries
  the per-instance wrappers as separate `data` keys (`oidc_default.py`,
  `oidc_<name>.py`, …); each wrapper imports `oidc` and delegates
  `authorize(p)` / `accounting(p)` / `validate(p)` over a `_CONFIG`
  dict baked in at chart-render time. Both ConfigMaps are mounted
  under `/etc/freeradius/scripts/` via subPath mounts so `python_path`
  resolves `import oidc` to the shared file.

- `cache oidc[_<name>]_cache` rlm_cache instance per OIDC instance
  whose `cache.enabled: true`, rendered into the shared
  `mods-enabled/cache` file. The cache key is hard-coded to
  `oidc:<name>:%{User-Name}` (non-overridable) to prevent silent
  cross-instance cache hits on common usernames.

- OIDC namespacing helpers
  `freeradius.oidc.{resolveInstances, envVarPrefix, moduleName,
  validateModuleName, policyName, rolesPolicyName, groupsPolicyName,
  modKey, policyKey, scriptKey, cacheName, cacheKey, dispatchArms,
  clientSecretName, tlsVolumeName, tls.{enabled, createSecret,
  secretName, caKey, caFilePath}}` — single source of truth for the
  legacy-default-vs-named naming split.

- `freeradius.validate.oidcInstances` + `freeradius.validate.oidcClientBindings`
  — per-instance schema validation (`tokenUrl` required;
  `introspect: true` requires `introspectUrl` and a client secret;
  `refreshTokenCache: true` requires `cache.enabled: true` and a Redis
  backend; `roleMappings` requires `rolesClaim`; instance-name regex;
  TLS `caCert`/`existingSecret` exclusivity; `extraEnvVars` must not
  shadow the per-instance `FREERADIUS_OIDC[_<NAME>]_` prefix) plus a
  typo guard on every `clients.<x>.oidc` reference.

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
- `templates/gateway-api/EnvoyProxy.yaml` — JSON access-log format on the
  chart-managed EnvoyProxy CR: bytes received/sent, duration, client IP,
  method/path, headers, response code/flags, upstream host. Renders by
  default under `gateway.infrastructure: envoy`.
- **End-to-end PROXY protocol v1 for RADSEC** — new `gateway.proxyProtocol`
  flag. When `true` (and `gateway.implementation: gateway-api` +
  `gateway.infrastructure: envoy` + `tls.enabled: true`), the chart wires
  PROXY v1 from the Envoy data plane into the RADSEC `listen { }` block in
  one shot:
  - Renders `templates/gateway-api/BackendTrafficPolicy.yaml` — an Envoy
    Gateway `BackendTrafficPolicy` (`gateway.envoyproxy.io/v1alpha1`)
    scoped to the FreeRADIUS Service's `tls-radsec` port via
    `targetRefs[].sectionName`, with `proxyProtocol.version: V1`. Envoy
    prepends a PROXY v1 header to every TCP connection it opens to the
    pod. Other Service ports (UDP auth/acct/coa, optional `udp-status`)
    are not in scope.
  - Forces `proxy_protocol = yes` on the RADSEC `listen { }` block via an
    `or` with the existing `sites.radsec.listen.proxy_protocol` knob — so
    FreeRADIUS parses the PROXY header and replaces
    `Packet-Src-IP-Address` with the real client IP. `clients.conf`
    matching, accounting logs, and policy all see the real source.

  v1 is pinned because FreeRADIUS 3.2.x parses v1 only on its TCP
  listeners (v2 is undocumented in the receive path); the flag has no
  effect on UDP auth/acct/coa, which can't accept PROXY headers
  regardless. The standalone `sites.radsec.listen.proxy_protocol` knob
  remains available for non-Envoy front-ends (HAProxy, AWS NLB
  direct-to-pod, …).
- `freeradius.validate.gatewayProxyProtocol` — hard-fails
  `gateway.proxyProtocol: true` paired with `gateway.implementation: istio`,
  `gateway.infrastructure: ""`, or `tls.enabled: false`. Each combination
  would render a CR that can't function (BTP needs Envoy Gateway as the
  data plane; FR-side parsing needs the RADSEC TCP listener), so the
  validator catches it at `helm install` / `helm template` instead of at
  apply time.

### Changed

- **`oidc.py` is more verbose for diagnostics.** No change to the runtime
  contract; opaque failures turn into actionable log lines:
  - `_post_form` now returns `(status, body, err)` where `err` is the
    `repr()` of the caught `URLError` / `OSError` on network/TLS failure
    (previously swallowed). `authorize()` and `validate()` surface it
    into `radlog`, so:

        oidc[keycloak]: token request failed (network/TLS): \
            <urlopen error [SSL: CERTIFICATE_VERIFY_FAILED] ...>

    instead of the prior bare `token request failed (network/TLS)`. The
    same applies to introspection failures (new code path: introspect
    network failure → `RLM_MODULE_FAIL` with the error surfaced, vs. the
    prior bucket of "either revoked or network broken — can't tell").
  - L_DBG entries around each HTTP call: `ROPC POST <url> (user=...)` /
    `ROPC -> HTTP <status>`, `introspect POST <url>`, `refresh_token
    POST <url>` / `refresh_token -> HTTP <status>`. Visible under
    `radiusd -X`; lets you confirm the chart rendered the right
    `tokenUrl` / `introspectUrl` without exec-into-pod + curl.
  - **Token response visibility.** L_DBG: token-response metadata after a
    successful ROPC (`token_type`, `expires_in`, `scope`, refresh? y/n) —
    enough to verify scope/lifetime without leaking the bearer token.
    L_AUTH: HTTP body on 4xx/5xx token responses (RFC 6749's
    `{"error": "...", "error_description": "..."}`) — surfaces why the
    IdP rejected the ROPC (bad credentials, client misconfigured, scope
    denied) instead of just an HTTP code.
  - **Claim visibility.** L_DBG after JWT decode / introspect: sorted
    top-level claim keys, plus the resolved values at each configured
    claim path (`required[]`, `rolesClaim`, `groupsClaim`). Lets you see
    exactly what the IdP returned at the paths the chart cares about.
    Top-level values are NOT logged — keys only, since values may carry
    PII the operator didn't ask for.
  - **"No roles" warning is now diagnostic.** Walks the configured
    `rolesClaim` path one segment at a time and reports where it broke
    (`segment X.Y missing; available at parent: [a, b, c]`). The Keycloak
    case where the realm uses `realm_access.roles` but the chart was
    configured for `resource_access.<client>.roles` now points at the
    first missing segment instead of "no roles at <full path>".
  - L_WARN when local JWT decode returns no claims (malformed token,
    truncated body, etc.) — previously every downstream check
    (`required`, `rolesClaim`, `groupsClaim`, `attributeMappings`)
    silently saw an empty dict and either no-op'd or accepted the user.
  - L_DBG: extracted role/group lists logged as a single line each
    (`extracted N role(s): [...]`) instead of one log line per item.
  - **id_token claims are now merged into the claim source.** Per OIDC
    Core §3.1.3.3 the token endpoint returns an `id_token` alongside
    `access_token` whenever the request carries the `openid` scope. The
    id_token is the authoritative identity bearer (`sub`, `email`,
    `name`, `preferred_username`, …) — claims the access_token
    typically lacks. The module now decodes both and uses the union for
    `required[]`, `rolesClaim`, `groupsClaim`, `attributeMappings`
    (id_token wins on conflicts for shared registered claims; access-
    token-only fields like `realm_access.roles` /
    `resource_access.*` are untouched). Pure OAuth 2.0 providers that
    don't emit id_token degrade silently. L_DBG also reports the
    id_token-only vs access-token-only key sets so you can see which
    bearer carried which claim. Introspection path is unchanged — when
    `introspect: true`, RFC 7662 is the single source of truth.
  - L_DBG: token-response extras dict (anything outside the standard
    OIDC fields) — Keycloak's `not-before-policy`, Authentik's
    `id_token_expires`, Azure's `ext_expires_in`, etc. — without baking
    provider knowledge into the chart.
  - L_DBG: `session_state` from the token response (when present) — lets
    you trace the same session across renewal/refresh log lines.
- **`sites/coa.yaml` refactored to listen-inside-server pattern.** Aligned
  with the modern FreeRADIUS 3.x convention used by `default`,
  `inner-tunnel`, `status`, `dhcp` (the upstream `sites-available/coa`
  is the lone holdout still using listen-outside; we don't follow it).
  Now renders as `server coa { listen { type = coa ... } recv-coa{} send-coa{} }`.
  Two over-flexible knobs dropped from values: `sites.coa.listen.type`
  (only `coa` is ever valid) and `sites.coa.listen.virtual_server` (the
  server name must match the on-disk filename `sites-enabled/coa`).
  `sites.coa.listen.ipaddr` remains. Migration: drop the two keys from
  any values file overriding them.
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
    `tls.enabled` / `tls.certificatesSecret` / `tls.certManager.issuerRef.*`)
    is **unchanged** by this rename — these knobs describe
    TLS-the-protocol, not the site name. (`tls.autoGenerated` /
    `tls.certManager.create` are deprecated in this release for an
    unrelated reason; see `### Deprecated` below.)
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
- **cert-manager is now used automatically (BREAKING).** Whenever the
  cert-manager API is detected on the cluster, the chart issues RADSEC and
  gateway certificates through cert-manager; when the API is absent it falls
  back to the in-template self-signed genCA path. There is no longer a toggle
  to force the genCA path on a cluster where cert-manager is installed — to
  opt out of cert-manager issuance for a given release, pre-create a Secret
  and set `tls.certificatesSecret`. The `validate.tls` hard-fail is removed
  (auto-generation handles every case); `validate.eap` keeps the `methods` /
  `defaultType` checks but drops the `tlsConfig` cert-source clause.
- `tls.certManager.issuerRef.name` now defaults to `""` (was
  `selfsigned-issuer`). Empty bootstraps a chart-managed CA; set it to use a
  pre-existing Issuer/ClusterIssuer and skip the bootstrap.
- **TLS auto-generation is now implicit (BREAKING).** When the matching
  feature is enabled (`tls.enabled`, `modules.eap.enabled`,
  `modules.sql.tls.enabled`) and no `*certificatesSecret` / `*certificates_secret`
  is supplied, the chart auto-generates TLS material — via cert-manager when
  its API is present, otherwise via the shared genCA path. The previous opt-in
  toggles (`tls.autoGenerated`, `modules.sql.tls.autoGenerated`,
  `modules.eap.tlsConfig.autoGenerated`) are no longer consulted; see
  `### Deprecated` below. To opt out of chart-managed generation, set the
  corresponding `*certificatesSecret` / `*certificates_secret`.
- Replaced the env-vars ConfigMap (`templates/configmap/envvars.yaml`) with a
  Secret (`templates/secret/envvars.yaml`, keeping the `<fullname>-envvars`
  name). Dropped the unused `FREERADIUS_ENABLE_TLS` / `FREERADIUS_SITES_NAMESPACE`
  keys (nothing read them — TLS and site config are rendered directly into the
  per-site ConfigMaps); the only remaining content is the conditional
  `FREERADIUS_MODS_REST_PASSWORD` fallback, which now lives in a Secret rather
  than a ConfigMap. The Deployment `envFrom` switches to `secretRef` for the
  chart-managed env vars (the `existingConfigmap` BYO path still uses
  `configMapRef`).
- **Routes attach to specific Gateway listeners via `sectionName`.** The
  chart-rendered UDPRoute (`auth`/`acct`/`coa`) and TLSRoute (`radsec`)
  now emit `spec.parentRefs[].sectionName` matching the listener name in
  the chart's Gateway, so each route attaches to one specific listener
  rather than all compatible listeners on the parent Gateway. Threaded
  through `freeradius.gateway.routeParentRefs` (new optional `sectionName`
  argument) — routes whose `parentRefs` are overridden via
  `gateway.{udpRoute,tlsRoute}.parentRefs` pass through verbatim and are
  unaffected. Same for the ListenerSet attachment path
  (`gateway.listenerSet.enabled`), where listener names are user-defined.

### Removed (BREAKING — see Upgrading)

- **Dedicated Keycloak module removed end-to-end.** The 1.1.0 top-level
  `keycloak.*` block — `enabled`, `mode`, `url`, `realm`, `clientId`,
  `clientSecret`, `scope`, `connectTimeout`, `roleAttribute`,
  `roleMapper`, `denyWithoutRole`, `roleMappings`, `tls.*`, `cache.*` —
  is gone. So are
  `templates/modules/mods-config/keycloak/configmap-{lua,policy,rest}.yaml`,
  every `freeradius.keycloak.*` helper, `freeradius.validate.keycloak*`
  validators, the Keycloak coordinate env vars (`KC_*` /
  `FREERADIUS_KEYCLOAK_*`) injected into the pod, the
  `clients.<x>.keycloak` NAS binding, and the
  `Auth-Type REST { keycloak_rest }` wiring in `sites/inner-tunnel`.
  Migrate to the new generic `modules.oidc.*` module — same JWT/ROPC
  flow against any OIDC provider, plus `groupMappings` /
  `attributeMappings` / `require` / `introspect` / `refreshTokenCache`.
  NAS binding is now `clients.<x>.oidc: <name>`. See
  **Upgrading → Keycloak module removed; migrate to `modules.oidc.*`**
  in the README.
- **`lua` mapper-script mode removed.** The 1.1.0 chart accepted
  `keycloak.mode: lua` via rlm_lua, but rlm_lua is not bundled in
  `freeradius/freeradius-server:3.2.8` (the chart's default image), so
  enabling it required a custom image. The new `modules.oidc.*` module
  is rlm_python3-only — bundled in the stock image, no custom build
  needed.
- **`keycloak.mode: rest` removed.** `python` mode was a strict
  superset (same ROPC POST + JWT-decode for role extraction, via the
  bundled rlm_python3) so the rest variant added nothing but config
  surface; gone along with the dedicated Keycloak module.

### Deprecated

- **TLS auto-generation toggles** `tls.autoGenerated`,
  `tls.certManager.create`, `modules.sql.tls.autoGenerated`, and
  `modules.eap.tlsConfig.autoGenerated` — all four still accepted in
  values for backwards compatibility, but no longer consulted by the
  templates. Auto-generation is now implicit (see `### Changed` above).
  `NOTES.txt` fires a deprecation advisory whenever any of these is set to
  a non-default value:

      DEPRECATION: the following TLS auto-generation toggles are no longer
      consulted by the chart and will be removed in the next major release.
      …
        - tls.autoGenerated                       (RADSEC leaf is now auto-generated implicitly)
        - tls.certManager.create: false           (no longer forces the genCA path; …)
        - modules.sql.tls.autoGenerated: false    (no longer suppresses generation; …)
        - modules.eap.tlsConfig.autoGenerated: false   (no longer suppresses generation; …)

  Migration (no action required for the default case — auto-generation
  Just Works):

      tls:
        enabled: true
      - autoGenerated: true            # remove — now implicit
      - certManager:
      -   create: true                 # remove — now implicit

      modules:
        sql:
          tls:
            enabled: true
      -     autoGenerated: false       # if you relied on this to suppress
      +     certificatesSecret: my-sql-tls   # generation, BYO a Secret instead

        eap:
          enabled: true
          tlsConfig:
      -     autoGenerated: false       # if you relied on this to suppress
      +     certificates_secret: my-eap-tls  # generation, BYO a Secret instead

  Marked `deprecated: true` in `values.schema.json` for all four properties.
  Slated for removal in the next major bump.

### Fixed

- Certificate / Issuer templates no longer emit an invalid `apiVersion: false`
  manifest when the cert-manager API is absent. The
  `st-common.capabilities.certmanager*` helpers return the string `"false"`
  (truthy in templates); the gates now test it explicitly via
  `freeradius.tls.useCertManager` / `ne … "false"`.
- `templates/configmaps/clients.yaml` no longer fails to render when the
  `clients` map carries non-client scalar keys (`includeFile`,
  `existingConfigMapName`) — it skips non-map entries via `kindIs "map"`
  instead of a hand-maintained `omit` list.
- `image.debug` (previously documented but unwired) now gates the container
  args between `-f` (normal) and `-fxx` (debug), so FreeRADIUS no longer starts
  in verbose debug mode by default.
- Added a writable `emptyDir` at `/var/run/radiusd` so the daemon can write its
  pidfile under `readOnlyRootFilesystem: true`.
- OIDC dispatch chain is now also rendered into `sites/inner-tunnel` (it was
  only emitted into `sites/default` despite the Added-note promising both).
  EAP-TTLS / PEAP tunnelled auth bound via `clients.<x>.oidc: <instance>` now
  reaches `oidc_<name>_authorize` — previously the inner-tunnel authorize
  section fell straight through to `pap` with no OIDC call. `Packet-Src-IP-
  Address` / `Packet-Src-IPv6-Address` still reflect the outer NAS inside the
  tunnel (RFC 5281 §11.2), so the same NAS-binding logic works unchanged.
- OIDC dispatch arms no longer render the `if (Packet-Src-IP-Address …) {`
  directive glued onto the trailing comment line of the preamble. The ipv6
  arm's terminating `-}}` was eating the newline + leading indent before the
  `{{ if $i }}elsif{{ else }}if{{ end }}` action, which produced
  ``…runs before `pap`.if (…) {`` — a single comment line followed by an
  unmatched closing `}`, which would fail `radiusd -C`. Changed to `}}` so
  the trailing newline is preserved. Affected both `sites/default` and the
  newly-wired `sites/inner-tunnel` (the bug existed in `default` since 1.2.0
  but only fired when at least one `clients.<x>.oidc` binding was set).
- OIDC dispatch arms now guard each `Packet-Src-IP[v6]-Address` comparison
  with an attribute-existence check (`&Attr && &Attr <= "..."`) so an
  IPv4-only request doesn't bail with
  `Failed casting lhs operand: Failed resolving "" to IPv6 address` when
  the OR falls through to the IPv6 leg (and vice versa for IPv6-only).
  Without the guard, unlang resolves the absent attribute to `""` and the
  cast to IPv6 fails at runtime; the cast error stamps Module-Failure-
  Message and the arm evaluates as false, so dispatch silently misses
  the matching instance.
- OIDC role-mapping and group-mapping policies (`oidc[_<name>]_roles`,
  `oidc[_<name>]_groups`) now guard the multi-value `[*]` comparison on
  attribute existence: `&control:<attr> && &control:<attr>[*] == "..."`.
  Without the guard, when the IdP returns no roles at the configured
  `rolesClaim` (or groups at `groupsClaim`), the `[*]` iterator hits an
  absent attribute and FreeRADIUS bails with
  `ERROR: Failed retrieving values required to evaluate condition`,
  skipping the remaining arms. The auth still completes via the outer
  `if (ok) { Auth-Type := Accept }` set by `oidc_<name>_authorize`, but
  every "user has no role" or "user has no group" case stamps an ugly
  error in the log. Guard matches the same pattern used for the dispatch
  arms.
- OIDC dispatch arms now use the `<=` IP-in-prefix operator instead of `==`
  for the `clients.<x>.{ipv4addr,ipv6addr}` match. `==` is exact-string
  equality in unlang, so any CIDR value (`0.0.0.0/0`, `192.168.1.0/24`,
  `::/0`) silently missed — the dispatch always fell through, NAS-bound
  OIDC never fired. The `<=` operator (FR3 `unlang(5)` §CONDITIONS, "checking
  that an IP address is contained within a network") handles both CIDR and
  single hosts uniformly: a bare host like `172.18.0.1` is a /32 prefix
  containing only itself, so the same render works for both. This matches
  the semantic of the underlying `clients{}` block (which has always parsed
  CIDR natively for shared-secret matching).

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
