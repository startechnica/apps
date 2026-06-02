<!--- app-name: FreeRADIUS -->

# Helm chart for FreeRADIUS

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/startechnica)](https://artifacthub.io/packages/search?repo=startechnica)
![Version](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square)
![Type](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion](https://img.shields.io/badge/AppVersion-3.2.8-informational?style=flat-square)

FreeRADIUS is a modular, high performance free RADIUS suite developed and distributed under the GNU General Public License, version 2, and is free for download and use.

[Overview of FreeRADIUS](https://freeradius.org/)

**This chart is not maintained by the upstream project and any issues with the chart should be raised [here](https://github.com/startechnica/apps/issues/new/choose)**

## TL;DR

```console
helm install my-release oci://ghcr.io/startechnica/charts/freeradius
```

## Prerequisites

- Kubernetes 1.22+
- Helm 3.10.0+

## Installing the Chart

To install the chart with the release name `my-release` on `my-release` namespace:

```console
helm install my-release oci://ghcr.io/startechnica/charts/freeradius \
  --namespace my-release --create-namespace
```

The chart is published as an OCI artifact in GHCR, so no `helm repo add` is needed — Helm 3.10+ resolves the `oci://` URL directly. The command deploys FreeRADIUS on the Kubernetes cluster in the default configuration.

> **Tip**: List all releases using `helm list -A`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release --namespace my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration and installation details

### Adding extra environment variables

In case you want to add extra environment variables (useful for advanced operations like custom init scripts), you can use the `extraEnvVars` property. Each entry is a standard Kubernetes `EnvVar`, so `valueFrom` works too.

```yaml
extraEnvVars:
  - name: LOG_LEVEL
    value: error
  - name: TZ
    value: "Europe/Amsterdam"
  - name: NODE_NAME             # downwardAPI example
    valueFrom:
      fieldRef:
        fieldPath: spec.nodeName
```

For larger sets of variables (or when the values live in a ConfigMap / Secret you already manage), point at them with `extraEnvVarsCM` / `extraEnvVarsSecret`. Every key from those resources is injected verbatim via `envFrom`.

```yaml
extraEnvVarsCM: my-freeradius-env       # ConfigMap with key=value pairs
extraEnvVarsSecret: my-freeradius-creds # Secret with key=value pairs (base64)
```

The three properties stack — `extraEnvVars` entries land first (so they can override anything from the ConfigMap/Secret with the same name), followed by `envFrom` for the ConfigMap, then the Secret.

### Chart-managed environment variables

In addition to whatever you add via `extraEnvVars*`, the chart injects a small fixed set of env vars into the FreeRADIUS container — every one of them backed by a Kubernetes Secret (`secretKeyRef`, not `envFrom`) and gated on the values that enable the matching feature. Reference them from your own config (or from `$ENV{...}` in values that go through `tpl`) when you need a chart-managed credential at runtime.

| Env var                                       | Wired when                                                                                                                                    | Source Secret                                                                            | What FreeRADIUS reads it for                                                                                          |
| --------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| `FREERADIUS_MODS_SQL_PASSWORD`                | `modules.sql.enabled`                                                                                                                         | DB credentials (bundled `mariadb` / `postgresql` subchart Secret, or `externalDatabase.existingSecret`) | `rlm_sql` `password = $ENV{...}` in `mods-enabled/sql`                                                              |
| `FREERADIUS_SITES_STATUS_SECRET`              | `sites.status.enabled`                                                                                                                        | Chart credentials Secret, key `sites-status-secret`                                      | Shared secret for the status virtual server's loopback `client probe { }` + the `radclient` healthcheck             |
| `FREERADIUS_SITES_RADSEC_PRIVKEY_PASSWORD`    | `tls.enabled` **AND** `sites.radsec.tls.private_key_password` is set                                                                          | Chart credentials Secret, key `sites-radsec-privkey-password`                            | `tls { private_key_password = $ENV{...} }` in **both** the RADSEC listener and the chart-managed `home_server radsec` |
| `FREERADIUS_CLIENTS_RADSEC_SECRET`            | `tls.enabled`                                                                                                                                 | Chart credentials Secret, key `clients-radsec-secret`                                    | Shared secret for the RADSEC loopback `client 127.0.0.1` and the chart-managed `home_server radsec` (self-proxy pattern) |
| `FREERADIUS_MODS_REST_PASSWORD`               | `modules.rest.enabled` (empty-string `envFrom` fallback always wired; an explicit `env:` secretKeyRef overrides when `modules.rest.auth != "none"`) | rlm_rest module Secret, key `mods-rest-password`                                         | `rlm_rest` body-template `password` field                                                                             |
| `FREERADIUS_MODS_REDIS_PASSWORD`              | Redis-with-auth in use — bundled `redis.enabled: true` (auth on by default) OR explicit `modules.redis.existingSecret`                        | Bundled Redis subchart Secret OR BYO Secret named by `modules.redis.existingSecret`      | `rlm_redis` and Redis-backed `rlm_cache` connection password                                                          |
| `FREERADIUS_MODS_EAP_TLS_PRIVKEY_PASSWORD`    | `modules.eap.enabled` **AND** `modules.eap.tlsConfig.private_key_password` is set                                                             | Chart credentials Secret, key `mods-eap-tls-privkey-password`                            | EAP module's `tls-config { private_key_password = $ENV{...} }`                                                       |
| `FREERADIUS_OIDC_CLIENT_SECRET`               | `modules.oidc.enabled` AND `modules.oidc.instances.default.clientSecret` is set (or its `existingSecret` BYO is set)                          | Per-instance OIDC Secret (`<fullname>-oidc`), key `client-secret`                        | OAuth2 `client_secret` for the `default` OIDC instance — read by the rlm_python3 wrapper via `os.environ.get(...)`    |
| `FREERADIUS_OIDC_<NAME>_CLIENT_SECRET`        | each non-`default` OIDC instance with `clientSecret` (or `existingSecret`) set                                                                | Per-instance OIDC Secret (`<fullname>-oidc-<name>`), key `client-secret`                 | OAuth2 `client_secret` for the named instance                                                                         |

A few things worth knowing:

- **Auto-generation.** When the source value is left empty (`sites.status.secret: ""`, `sites.radsec.tls.private_key_password: ""`, `modules.eap.tlsConfig.private_key_password: ""`, etc.), the chart materialises a random value into the chart credentials Secret on install and preserves it across upgrades via Helm's `lookup`. See [§Auto-generated credentials](#auto-generated-credentials) below for the rotation caveats around `helm template`-based workflows.
- **Pin them via your own Secret.** `auth.existingSecret` mounts one BYO Secret holding every chart-managed credential key; `auth.existingSecretPerPassword` lets you point each credential at its own Secret (e.g. one managed by an external-secrets operator). The env var names above stay the same — only the backing Secret changes.
- **Per-instance OIDC prefix.** The `default` OIDC instance uses the bare prefix `FREERADIUS_OIDC_`; every other instance uses `FREERADIUS_OIDC_<NAME>_` with the instance name upper-cased (e.g. `modules.oidc.instances.partner-realm.clientSecret` → `FREERADIUS_OIDC_PARTNER_REALM_CLIENT_SECRET`).
- **Not in the table above.** OIDC coordinates other than `CLIENT_SECRET` (`tokenUrl` / `introspectUrl` / `clientId` / `scope` / `connectTimeout` / `rolesClaim` / `groupsClaim` / `tls.*` / role-and-group-and-attribute mappings / `introspect` / `refreshTokenCache` / `cache.*`) are **baked into the per-instance rlm_python3 wrapper at chart-render time** — they are *not* runtime env vars. Update the values and re-apply to change them.
- **Your own `$ENV{...}`.** When you write `$ENV{FREERADIUS_RADSEC_CLIENT_AP_SECRET}` (or any other custom name) inside values like `sites.radsec.clients[*].secret`, `homeServers[*].secret`, or `realms[*].secret`, those env vars are **not** auto-created by the chart. Inject them yourself via `extraEnvVars` (inline `valueFrom` `secretKeyRef`) or `extraEnvVarsSecret` (a Secret you manage that the Deployment pulls in via `envFrom`).

### Setting Pod's affinity

This chart allows you to set your custom affinity using the `affinity` parameter, or to lean on the bundled presets (`podAntiAffinityPreset` / `podAffinityPreset` / `nodeAffinityPreset.type` — each accepts `soft` or `hard`). The presets render a sensible default; setting `affinity` overrides them entirely. Find more information about Pod's affinity in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity).

```yaml
# Option A — bundled presets (simplest)
podAntiAffinityPreset: hard              # spread replicas across nodes; default is "soft"
nodeAffinityPreset:
  type: soft
  key: workload-class
  values: [radius]

# Option B — explicit affinity passthrough (overrides every preset above)
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/os
              operator: In
              values: [linux]
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app.kubernetes.io/instance: my-release
              app.kubernetes.io/name: freeradius
          topologyKey: topology.kubernetes.io/zone
```

### Deploying extra resources

There are cases where you may want to deploy extra objects alongside the chart — a `ConfigMap` holding sideband config, a `NetworkPolicy` covering a CIDR that the chart's policies don't, a `ServiceMonitor` with custom relabelings, an external-secrets `ExternalSecret`, etc. The `extraDeploy` parameter takes a list of arbitrary manifests; each one is rendered through `tpl` so `{{ .Release.Name }}` / `{{ .Release.Namespace }}` work as you'd expect.

```yaml
extraDeploy:
  # Custom ConfigMap mounted into the pod via extraVolumes / extraVolumeMounts
  - apiVersion: v1
    kind: ConfigMap
    metadata:
      name: "{{ .Release.Name }}-freeradius-extra-clients"
      namespace: "{{ .Release.Namespace }}"
    data:
      extra-clients.conf: |
        client edge-router {
            ipaddr = 198.51.100.0/24
            secret = $ENV{FREERADIUS_EDGE_ROUTER_SECRET}
        }

  # NetworkPolicy that opens RADSEC to a specific peer CIDR the bundled policy doesn't cover
  - apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: "{{ .Release.Name }}-freeradius-radsec-extra"
      namespace: "{{ .Release.Namespace }}"
    spec:
      podSelector:
        matchLabels:
          app.kubernetes.io/instance: "{{ .Release.Name }}"
          app.kubernetes.io/name: freeradius
      policyTypes: [Ingress]
      ingress:
        - from:
            - ipBlock:
                cidr: 203.0.113.0/24
          ports:
            - protocol: TCP
              port: 2083
```

### Redis-backed cache

The `rlm_cache` module (`modules.cache`) defaults to the in-memory `rbtree`
driver, which is per-pod. To share cache state across replicas, switch it to the
`redis` driver and bundle a Redis. The **minimum** values are:

```yaml
redis:
  enabled: true        # bundle a Bitnami Redis (auth is on by default)

modules:
  cache:
    enabled: true
    driver: redis      # default is rbtree (in-memory, per-pod)
```

Regardless of driver, `rlm_cache` refuses to load without a non-empty
`update { }` section, so `modules.cache.update` is **required**. It holds the
attributes to cache in FreeRADIUS map syntax (`<list>:<attr> <op> <value>`, one
per line) and defaults to `&reply: += &reply:` (cache the whole reply list).
Override it for what you actually need to cache.

With `redis.enabled: true` the chart auto-wires the connection: the cache targets
the bundled `<release>-redis-master` Service and injects the Redis password from
the subchart's Secret as `$ENV{FREERADIUS_MODS_REDIS_PASSWORD}` — you don't set a
host or password yourself. You do **not** need `modules.redis.enabled` (that only
adds the `%{redis:...}` xlat); the cache reuses the connection settings under
`modules.redis` on its own.

To point the cache at an **external** Redis instead, leave `redis.enabled: false`
and set the connection under `modules.redis` (e.g. `modules.redis.server`).

### Adding users (`files` backend)

For small/static user sets — dev, test, lab — declare users directly in
values via the top-level `users:` array. The chart renders them into a
ConfigMap and mounts it at `/etc/freeradius/mods-config/files/authorize`
(via `subPath`), where the upstream image's bundled `mods-enabled/files`
symlink already loads them. No need to flip `modules.files.enabled` —
the `default` virtual server's `authorize {}` block already calls `files`
unconditionally.

```yaml
users:
  - name: alice
    password: wonderland                     # → Cleartext-Password (default)
    reply:
      - 'Filter-Id := "staff"'
      - 'Framed-IP-Address := "10.0.0.42"'
  - name: bob
    password: '$1$abc123$Q2YS.Cb6yYTzS6e9YQyXq.'
    passwordType: Crypt-Password             # any FR check-attribute name
  - name: charlie
    password: secret
    attributes:                              # extra check attrs (raw FR syntax)
      - 'NAS-IP-Address == 192.0.2.1'
    reply:
      - 'Service-Type := Framed-User'
```

The array is processed in declaration order — FreeRADIUS's `files`
module evaluates the file top-to-bottom with `Fall-Through = no` default
semantics, so order matters when two entries could match.

> **⚠️ Plaintext in a ConfigMap.** Passwords supplied here are baked
> into `<release>-freeradius-users` and visible to anyone with read
> access to the namespace. For dev/test that's fine; for sensitive
> credentials prefer **(a)** the SQL backend (`modules.sql.enabled:
> true` + a bundled subchart), where passwords live in a real Secret
> and CRUD goes through SQL; or **(b)** pre-create your own `authorize`
> file as a Secret and inject it via `extraVolumes` /
> `extraVolumeMounts` (chart's `users: []` stays empty).

For production multi-user setups with mutations through the day, the
SQL path is preferred — see the bundled MariaDB / PostgreSQL subchart
under `mariadb.enabled` / `postgresql.enabled`, and the standard
`radcheck` / `radreply` / `radusergroup` schema is auto-loaded by the
chart's `db-bootstrap` initContainer.

### OIDC authentication

FreeRADIUS can authenticate users against any OIDC provider (Keycloak,
Authentik, Azure AD, Auth0, Okta, …) using the OAuth2 Resource Owner Password
Credentials (ROPC) grant. Because ROPC needs the cleartext password, this only
works for password-based flows — **PAP**, or **EAP-TTLS/PAP** as the inner
method. MSCHAPv2/PEAP cannot authenticate against an OIDC IdP. Enable the
ROPC grant on the IdP's client (Keycloak calls it **Direct Access Grants**).

Each backend is configured as a named instance under
`modules.oidc.instances.<name>`. The chart renders one `oidc` (or
`oidc_<name>`) rlm_python3 module instance + a matching unlang policy
(`oidc_authorize` / `oidc_<name>_authorize`) per entry. The Python wrapper is
generated at chart-render time from the per-instance config — no custom image
needed; `rlm_python3` is already bundled in
`freeradius/freeradius-server:3.2.8`.

```yaml
modules:
  oidc:
    enabled: true
    wireDefaultSite: true            # call `default` instance from sites/default's else-branch
    unmatchedReject: false           # when no `default`, dispatch falls through to `pap` (set true to reject)
    instances:
      default:
        tokenUrl: https://auth.example.com/realms/corp/protocol/openid-connect/token
        clientId: freeradius
        clientSecret: "<confidential-client-secret>"   # empty for a public client
        rolesClaim: realm_access.roles                 # IdP-specific JWT claim path
        roleMappings:
          - role: network-admin
            reply:
              - 'Service-Type := Administrative-User'
              - 'Cisco-AVPair := "shell:priv-lvl=15"'
          - role: wifi-user
            reply:
              - 'Tunnel-Type:0 := VLAN'
              - 'Tunnel-Medium-Type:0 := IEEE-802'
              - 'Tunnel-Private-Group-Id:0 := "10"'
        denyWithoutRole: true        # reject users matching no roleMappings entry
        cache:
          enabled: true              # cache token + claims (requires redis-backed rlm_cache)
          ttl: 300
```

`rolesClaim` is **required** when you set `roleMappings` — there is no
provider-specific default. Common paths: `realm_access.roles` (Keycloak),
`groups` (Authentik / Azure AD), `resource_access.<clientId>.roles` (Keycloak
client roles). The chart's docs in [values.yaml](values.yaml) under
`modules.oidc.instances` enumerate every per-instance key
(`tokenUrl`, `introspectUrl`, `clientId`, `clientSecret`, `existingSecret`,
`scope`, `connectTimeout`, `roleAttribute`, `rolesClaim`, `denyWithoutRole`,
`roleMappings`, `groupAttribute`, `groupsClaim`, `groupMappings`,
`attributeMappings`, `require`, `introspect`, `refreshTokenCache`,
`cache.{enabled,ttl}`, `tls.{caCert,existingSecret,existingSecretCaKey,insecure}`,
`existingConfigMap`).

Bind a specific NAS to a named instance with `clients.<x>.oidc: <name>`. NAS
entries without a binding fall through to the `default` instance (when
`wireDefaultSite: true`) or to `pap` (when `unmatchedReject: false`).

Migration from the 1.1.0 `keycloak.*` module: see
[§Upgrading → Keycloak module removed](#keycloak-module-removed-migrate-to-modulesoidc-breaking).

### EAP-TTLS / PEAP supplicant notes

EAP-TTLS and PEAP exchange identity in two phases — once *before* the TLS tunnel
is established (outer / "anonymous" identity, visible in cleartext to anyone
sniffing the air) and once *inside* the tunnel (inner / real identity, encrypted).
If the supplicant doesn't set a distinct outer identity, FreeRADIUS logs the
following warning on every auth and the real username travels over the air in
the clear:

```
(N) WARNING: Outer and inner identities are the same. User privacy is compromised.
```

The fix lives entirely on the supplicant side — the chart can't do anything
about it. Configure the WiFi / 802.1X profile with:

| Field | Value |
| --- | --- |
| **Identity** (inner) | the real user, e.g. `logan@etb.co.id` |
| **Anonymous identity** (outer) | `anonymous@<realm>`, e.g. `anonymous@etb.co.id` |
| **Password** | the real password |

The realm part (after `@`) of the anonymous identity must match the real realm
so FreeRADIUS' `suffix` module routes the outer EAP to the correct inner-tunnel
virtual server. The local-part (`anonymous` here) is arbitrary — anything not
identifying the user works.

Roll-out paths:

- **Android (8.0+):** WiFi network → Advanced → "Anonymous identity" field
- **iOS / iPadOS / macOS:** the "Outside Identity" field in the WPA-Enterprise
  profile (`.mobileconfig` `OuterIdentity` key)
- **Windows 10/11:** 802.1X advanced settings → "Specify authentication mode" →
  enable **Privacy** and set the anonymous identity
- **MDM (Intune, JumpCloud, Jamf, …):** push the anonymous identity as part of
  the WiFi configuration profile — end users never see the setting

Older supplicants without an outer-identity field can't suppress the warning;
the real username will leak. Either upgrade the supplicant or accept the
privacy trade-off.

### Routing via Gateway (`gateway-api` or `istio`)

Three top-level knobs control whether and how a Gateway fronts the
pod's RADIUS / RADSEC ports:

| Knob | Effect |
| --- | --- |
| `gateway.enabled`            | Master switch. Nothing under `templates/gateway-api/` or `templates/istio/` renders when this is `false` (the pod is reachable via its `Service` only). |
| `gateway.implementation`     | Selects which CRD family the chart renders. `gateway-api` → Kubernetes Gateway API (`Gateway` + `UDPRoute` + `TLSRoute` + `ReferenceGrant`); `istio` → Istio networking CRDs (`Gateway` + `VirtualService`). UDPRoute support is uneven across GatewayClasses — see [Upgrading #6](#6-udproute--tlsroute-replace-httproute-style-attachment) for the matrix. |
| `gateway.gateway.create`     | **gateway-api path only.** When `true`, the chart renders its own `Gateway` (`templates/gateway-api/Gateway.yaml`) with the default UDP `auth` / `acct` / `coa` + TLS `radsec` listeners. When `false`, no `Gateway` is rendered — routes still render and must attach to a `Gateway` you manage elsewhere (see "BYO Gateway" below). |
| `gateway.gateway.name`       | Name of the chart-rendered `Gateway`. Defaults to **`<fullname>-gateway`** (the `-gateway` suffix avoids a name collision with the chart's `Service` and `Deployment`, both of which use `<fullname>` — under Envoy Gateway and Istio gateway-api the controller materialises a data-plane `Deployment` named after the `Gateway`, which would otherwise overwrite the FreeRADIUS workload). Override with an explicit value to drop the suffix. |
| `gateway.infrastructure`     | **gateway-api path only.** Optional data-plane extension. `""` (default) leaves the Gateway with no `spec.infrastructure` block (uses GatewayClass defaults). `envoy` renders an `EnvoyProxy` CR (`gateway.envoyproxy.io/v1alpha1`) and adds a `spec.infrastructure.parametersRef` pointing at it on the chart's Gateway — pair with an Envoy Gateway-backed `gatewayClassName` (typically `eg`). Validator rejects `envoy` on the istio path. |
| `gateway.gatewayClassName`   | Cluster-scoped GatewayClass that backs the Gateway. Default `istio`. Set to `eg` for Envoy Gateway, `cilium` for Cilium, etc. **Not auto-derived from `implementation` or `infrastructure`** — pick whichever GatewayClass your data plane provides. |

> **The istio path uses a different opt-out.** `gateway.gateway.create`
> only gates the gateway-api `Gateway` template. The istio
> `Gateway.yaml` instead checks `gateway.existingGateway` — set that to
> the name of your existing Istio `Gateway` to skip rendering and have
> the chart's `VirtualService` attach to yours.

#### Pattern A — Chart owns the Gateway (default, greenfield)

```yaml
gateway:
  enabled: true
  implementation: gateway-api    # or: istio
  gateway:
    create: true                 # chart renders the Gateway itself
  gatewayClassName: istio        # cluster GatewayClass that backs the Gateway
  hostnames:
    - radius.example.com         # listener hostname + seed for cert-manager Certificate
```

The chart renders `Gateway` + `UDPRoute` (auth/acct/coa) + `TLSRoute`
(when `tls.enabled`) + `ReferenceGrant` (when needed for cross-namespace
attachment).

#### Pattern B — BYO Gateway; chart attaches routes only

Use this when your platform team owns the cluster Gateway (one shared
Gateway fronting many apps) and the chart should only contribute its
routes:

```yaml
# gateway-api path
gateway:
  enabled: true
  implementation: gateway-api
  gateway:
    create: false                # do NOT render the chart's Gateway
  existingGateway: shared-edge   # name of the existing Gateway
  # OR pin parentRefs per route, e.g. when routes need to target
  # specific listeners on the shared Gateway:
  udpRoute:
    parentRefs:
      - group: gateway.networking.k8s.io
        kind: Gateway
        name: shared-edge
        namespace: gateway-system
        sectionName: radius-auth          # optional listener selector
  tlsRoute:
    parentRefs:
      - group: gateway.networking.k8s.io
        kind: Gateway
        name: shared-edge
        namespace: gateway-system
        sectionName: radsec
```

```yaml
# istio path (no gateway.gateway.create — uses existingGateway directly)
gateway:
  enabled: true
  implementation: istio
  existingGateway: shared-edge   # skips Gateway rendering; VirtualService attaches here
```

> **Route `parentRefs` resolution order** (gateway-api path, per
> `freeradius.gateway.routeParentRefs` in `_helpers.tpl`):
> 1. Explicit per-route override (`gateway.udpRoute.parentRefs` /
>    `gateway.tlsRoute.parentRefs`).
> 2. The chart-rendered `ListenerSet` — when `gateway.listenerSet.enabled`,
>    its `listeners` is non-empty, AND the cluster exposes the
>    `ListenerSet` API.
> 3. The chart's Gateway (via `freeradius.gateway.fullname` /
>    `st-common.gateway.namespace`), which honors `gateway.existingGateway`
>    when set and otherwise defaults to `<fullname>-gateway`.

The `ReferenceGrant` template fires automatically when the chart detects
cross-namespace attachment is required (Gateway in `gateway-system`,
routes in your app namespace).

#### Pattern C — No Gateway at all (Service-only)

```yaml
gateway:
  enabled: false
```

The pod is exposed via the chart's `Service` (`service.type:
ClusterIP` / `LoadBalancer` / `NodePort` per your values). Use this when
fronting RADIUS with an external L4 load balancer that handles the
public IP, or for in-cluster-only RADIUS where the Service DNS name is
enough.

#### Pattern D — Envoy Gateway data-plane (`gateway.infrastructure: envoy`)

Envoy Gateway *is* a Gateway API implementation, so this is built on
top of Pattern A or B (`implementation: gateway-api`, plus the chart
or your platform team's existing Gateway). Setting
`gateway.infrastructure: envoy` does two things:

1. Wires an `EnvoyProxy` reference into the chart's Gateway via
   `spec.infrastructure.parametersRef` (only when the chart owns the
   Gateway, i.e. `gateway.gateway.create: true`).
2. Optionally renders an `EnvoyProxy` CR
   ([gateway.envoyproxy.io/v1alpha1](https://gateway.envoyproxy.io/docs/api/extension_types/))
   in the gateway namespace — gated by `gateway.envoyProxy.create`.

`gateway.envoyProxy.{create, name}` mirrors `gateway.gateway.{create, name}`:

| `envoyProxy.create` | Behaviour |
| --- | --- |
| `true` (default) | Chart renders its own EnvoyProxy with a bundled opinionated spec (`provider.type: Kubernetes` + 1 replica, plus JSON access-log telemetry to stdout — see [`templates/gateway-api/EnvoyProxy.yaml`](charts/freeradius/templates/gateway-api/EnvoyProxy.yaml)). `name` defaults to the chart fullname if empty. |
| `false` | BYO — chart skips rendering. `name` is **required** (validator-enforced) and must reference an EnvoyProxy that exists in `gateway.gateway.namespace`. |

The chart's Gateway always uses the resolved `name` for its
`parametersRef`, so either path produces a working attachment.

```yaml
# Chart-managed EnvoyProxy (default)
gateway:
  enabled: true
  implementation: gateway-api
  infrastructure: envoy              # opt into the EnvoyProxy path
  gatewayClassName: eg               # Envoy Gateway's GatewayClass
  gateway:
    create: true
  hostnames:
    - radius.example.com
  envoyProxy:
    create: true                     # default — chart renders EnvoyProxy
    # name: ""                       # empty → chart fullname

# BYO EnvoyProxy (managed externally — by a platform team, kustomize, GitOps, etc.)
gateway:
  enabled: true
  implementation: gateway-api
  infrastructure: envoy
  gatewayClassName: eg
  gateway:
    create: true
  envoyProxy:
    create: false                    # chart does NOT render the EnvoyProxy
    name: shared-envoy-proxy         # required — must exist in the gateway namespace
```

> **The chart's EnvoyProxy ships with a bundled spec** — Kubernetes
> provider with 1 replica plus JSON access-log telemetry to stdout (see
> [`templates/gateway-api/EnvoyProxy.yaml`](charts/freeradius/templates/gateway-api/EnvoyProxy.yaml)).
> To tune anything beyond what the template exposes (replicas,
> additional telemetry sinks, concurrency, bootstrap patches, etc.),
> set `gateway.envoyProxy.create: false` and manage the EnvoyProxy CR
> externally with whatever tool owns the Envoy Gateway install.

> **Validator constraints**: `gateway.infrastructure: envoy` requires
> `gateway.implementation: gateway-api` (the istio Gateway CRD has no
> `spec.infrastructure` field). Unknown values for `infrastructure`
> (anything other than `""` / `envoy`) are also rejected. And
> `envoyProxy.create: false` without an `envoyProxy.name` fails the
> render — BYO must name its target.

### Enabling RADSEC (TLS-encrypted RADIUS)

Switch on the pod's TLS plumbing plus the radsec virtual server. The chart auto-issues a cert (via cert-manager when its API is present, otherwise a self-signed leaf via `genCA`), wires the loopback `home_server radsec` / `home_server_pool radsec` / `realm radsec` definitions, and ships a bundled `proxy.conf` mounted at `/etc/freeradius/proxy.conf` (with `realm LOCAL { }` commented out so the chart can own that name without a Duplicate realm error).

```yaml
# minimal config to enable RADSEC
tls:
  enabled: true
  autoGenerated: true

sites:
  radsec:
    enabled: true
```

That's enough to bring up a TCP+TLS listener on `containerPorts.radsec` (default `2083`), processed by the existing `server default { }`. The chart-managed `client 127.0.0.1` loopback is the only authorised peer in this minimal config — useful for verifying the listener end-to-end with `radclient` from inside the pod, but not for accepting external traffic.

To allow external NASes (WiFi controllers, switches, VPN concentrators), add them under `sites.radsec.clients`:

```yaml
sites:
  radsec:
    enabled: true
    clients:
      - name: my-nas
        ipaddr: 192.0.2.50/32
        secret: $ENV{FREERADIUS_RADSEC_CLIENT_MY_NAS_SECRET}
        require_message_authenticator: true   # BlastRADIUS mitigation
```

Each entry renders one `client <name> { … proto = tls … }` block inside the existing `clients radsec { }` group alongside the chart-managed loopback. Use `$ENV{…}` for the per-client secret and inject it via `extraEnvVarsSecret`.

Common follow-ups:

- **Loopback shared secret (recommended to pin)**: set `sites.radsec.radsecSecret` to a stable value of your choice (FreeRADIUS treats the literal `"radsec"` as the default for `proto = tls`, so any non-empty value works). When left empty the chart auto-generates one into the credentials Secret (`clients-radsec-secret`) and injects it via `$ENV{FREERADIUS_CLIENTS_RADSEC_SECRET}` — fine for a live `helm install` / `helm upgrade` (the value is recovered via `lookup` and preserved across releases), but in `helm template` / GitOps workflows it is **regenerated on every render** and rotates out from under the running pod's `home_server radsec` self-proxy. See [§Auto-generated credentials](#auto-generated-credentials) for the full caveat.
- **Password-protected private key**: set `sites.radsec.tls.private_key_password`. The chart auto-generates the matching `sites-radsec-privkey-password` Secret entry and injects it via `$ENV{FREERADIUS_SITES_RADSEC_PRIVKEY_PASSWORD}`.
- **Cipher hardening**: set `sites.radsec.tls.cipher_list` (e.g. `HIGH:!aNULL:!MD5`). The chart applies the same list to both the radsec listener and the loopback `home_server radsec` so both peers negotiate consistently.
- **Listener tuning**: `sites.radsec.listen.{ipaddr,type,virtual_server,proxy_protocol,check_client_connections}` — see the [§Parameters](#parameters) table. `proxy_protocol: true` is the one to set if you front the RADSEC port with an L4 load balancer that prepends HAProxy PROXY headers.
- **BYO certificate**: see [§Auto-generated credentials](#auto-generated-credentials) below — `tls.certificatesSecret`, `tls.certManager.issuerRef`, and the `auth.existingSecret` patterns all apply identically to RADSEC.

### Auto-generated credentials

When you don't supply them, the chart auto-generates several credentials into the chart-managed Secret (`<release>-freeradius`):

- `sites-status-secret` — shared secret for the RADIUS `status` virtual server (probes + metrics exporter).
- `clients-radsec-secret` — RADIUS shared secret for the RADSEC loopback `client 127.0.0.1` (only when `tls.enabled`; auto-generated when `sites.radsec.radsecSecret` is empty).
- `sites-radsec-privkey-password` — RADSEC private-key passphrase (only when `tls.enabled` AND `sites.radsec.tls.private_key_password` is set).
- `mods-eap-tls-privkey-password` — EAP private-key passphrase (only when `modules.eap.enabled` AND `modules.eap.tlsConfig.private_key_password` is set).
- `mods-rest-password`, `database-password` — when the matching feature is enabled.

These use the `lookup`-based "manage" pattern: on a normal `helm install` / `helm upgrade` **against a live cluster**, the existing value is read back and preserved, so it stays stable across releases.

> **⚠️ They are regenerated on every apply in `helm template`-based workflows.** Helm's `lookup` returns nothing when there is no live API connection — i.e. during `helm template`, `helm install --dry-run` (client), `helm diff`, and GitOps tools that render with `helm template` (Argo CD, Flux in template mode). In those workflows a **fresh random value is produced on every render/sync**, which rotates the status secret and the RADSEC key passphrase out from under running pods and can break probes, the metrics exporter, and RADSEC until the pods restart with the new values.

To make these deterministic, pin them explicitly instead of relying on auto-generation:

```yaml
# Option A — set the values directly
sites:
  status:
    secret: "<your-status-secret>"
  radsec:
    radsecSecret: "<your-loopback-shared-secret>"   # client 127.0.0.1 / home_server radsec
    tls:
      private_key_password: "<your-radsec-key-password>"

# Option B — bring your own Secret for everything
auth:
  existingSecret: my-freeradius-credentials

# Option C — per-credential Secrets (e.g. managed by an external operator)
auth:
  existingSecretPerPassword:
    keyMapping:
      sitesStatusSecret: status-secret
    sitesStatusSecret:
      name: freeradius-status
```

#### Auto-generated TLS certificates behave the same way

The same limitation applies to the chart's **self-signed TLS material** — the shared internal CA (`<release>-freeradius-tls-ca`) and every leaf it signs (in-pod RADSEC `tls.yaml`, SQL `sql-tls.yaml`, REST `rest-tls.yaml`, gateway `gateway-tls.yaml`). The CA is recovered via `lookup` (`freeradius.tls.ca.init`) and falls back to `genCA` when there is no live cluster, so in `helm template`-based workflows a **fresh CA + fresh leaf certificates are minted on every render/sync**. That rotates the CA out from under anything that already trusts it — RADSEC clients, SQL/REST peers — until they re-fetch.

> **Note:** this churn applies only to the **genCA fallback**. When the cert-manager API is present on the cluster (and `tls.certManager.create`, the default), the RADSEC/gateway certificates are issued through cert-manager — which owns the lifecycle, so there is no per-render churn. The genCA path is used only when cert-manager is absent or `tls.certManager.create: false`.

The deterministic escape hatches mirror the password ones:

```yaml
# Option A — let cert-manager own issuance (recommended; cert-manager,
# not Helm, manages the Certificate, so no churn on re-render). With the
# cert-manager API present this is the default behaviour: certManager.create
# is true, and an empty issuerRef.name makes the chart bootstrap its own CA.
tls:
  enabled: true
  autoGenerated: true
  certManager:
    create: true            # default; set false to force the genCA path
    # issuerRef:            # optional — omit to bootstrap a chart-managed CA
    #   kind: ClusterIssuer
    #   name: my-issuer

# Option B — bring your own certificate Secret (per TLS context)
tls:
  certificatesSecret: my-radsec-tls
modules:
  sql:
    tls:
      certificatesSecret: my-sql-tls
  rest:
    tls:
      certificates_secret: my-rest-tls
```

#### Extracting the CA bundle

External peers that need to verify the chart's TLS leaves (RADSEC NAS
peers verifying the FreeRADIUS server cert, SQL/REST clients connecting
inbound, anything you want to slot into a host trust store) need the CA
the chart signs with. **Where the CA lives depends on the issuance
path** (the `freeradius.tls.useCertManager` helper picks one at render
time):

| Issuance path                          | Secret name                                  | Owner                       |
| -------------------------------------- | -------------------------------------------- | --------------------------- |
| Cert-manager auto-detected, no external issuer (default when the cert-manager API is present) | `<release>-freeradius-ca` (override via `tls.certManager.ca.secretName`) | cert-manager (`templates/Issuer.yaml` bootstrap chain) |
| Cert-manager with `tls.certManager.issuerRef.name` set | (your issuer's own CA Secret — not chart-managed) | Your pre-existing Issuer / ClusterIssuer |
| genCA fallback (cert-manager API absent) | `<release>-freeradius-tls-ca` (`freeradius.tls.ca.secretName` helper) | Chart (`templates/secrets/tls-ca.yaml`) |

Each chart-managed CA Secret holds both `ca.crt` (the public certificate
— safe to distribute) and `ca.key` (the private key — **never** leave
the cluster). The same `ca.crt` is also copied into every per-leaf TLS
Secret (`<release>-freeradius-radsec-tls`, `<release>-freeradius-sql-tls`,
`<release>-freeradius-eap-tls`, `<release>-freeradius-rest-tls`,
`<release>-<hostname>-tls`) under the same `ca.crt` key — extract from
whichever Secret is most convenient.

Extract the CA certificate as PEM:

```bash
# Cert-manager bootstrap path (default when cert-manager is installed)
kubectl get secret <release>-freeradius-ca \
  -n <namespace> \
  -o jsonpath='{.data.ca\.crt}' | base64 -d > freeradius-ca.crt

# genCA fallback path (cert-manager API absent)
kubectl get secret <release>-freeradius-tls-ca \
  -n <namespace> \
  -o jsonpath='{.data.ca\.crt}' | base64 -d > freeradius-ca.crt
```

> **⚠️ Never extract `ca.key`.** Pulling the private key off-cluster
> turns your chart-managed CA into a copy-paste credential. If you need
> to sign new leaves with the same CA from outside the cluster, switch
> the chart to a cert-manager `Issuer` / `ClusterIssuer` you own
> (`tls.certManager.issuerRef.name`) — the issuer's private key stays
> in cert-manager, and leaves are minted via Kubernetes API calls
> instead.

Common downstream usages:

- **RADSEC NAS / WiFi controller / VPN concentrator** — import as a
  trusted CA on the peer so its RADSEC client validates the FreeRADIUS
  server certificate during the TLS handshake.
- **Linux trust store** (testing from a workstation):

  ```bash
  sudo cp freeradius-ca.crt /usr/local/share/ca-certificates/freeradius-ca.crt
  sudo update-ca-certificates       # Debian/Ubuntu
  # or:  sudo update-ca-trust       # RHEL/Fedora (drop into /etc/pki/ca-trust/source/anchors/ first)
  ```

- **`radclient` over RADSEC**:

  ```bash
  radclient -x -P tcp -S <secret-file> <radsec-host>:2083 \
    auth <radius-secret> \
    --cacert freeradius-ca.crt
  ```

- **OpenSSL handshake test**:

  ```bash
  openssl s_client -connect <radsec-host>:2083 \
    -CAfile freeradius-ca.crt -servername <radsec-host>
  ```

For programmatic re-extraction (e.g. wiring into a sync tool that
distributes the CA to NAS peers automatically), pin the CA to a
deterministic location by setting `tls.certManager.ca.secretName` (when
cert-manager owns issuance) — the auto-rotation caveat above applies to
the genCA fallback only.

## TODO

- **winbind sidecar to join domain / Samba** — bundle an optional winbind/samba sidecar so FreeRADIUS can join an Active Directory / Samba domain and authenticate against it (MS-CHAPv2 via `ntlm_auth`, machine-account-based PEAP/EAP-MSCHAPv2, group lookups via `wbinfo`). Needs Kerberos keytab plumbing, domain-join init container or pre-joined Secret, and integration with `modules.mschap` / `modules.exec`.
- **`modules.ldap` full schema** — currently a stub (`enabled` + `existingConfigMap` only). Every sibling module (`sql`, `rest`, `eap`, `cache`, `redis`, `oidc`) ships a fully templated schema rendered via `freeradius.tplvalues.renderConfig`; LDAP being the odd one out forces every install to fall back to `existingConfigMap`. Add `server` / `port` / `identity` / `password` (with `existingSecret`), `base_dn`, `user`, `group`, `tls`, `pool`, and wire TLS material into a `freeradius.ldap.tls.*` flow mirroring `modules.sql.tls`.
- **DHCP listener port auto-wiring** — `sites.dhcp.enabled: true` mounts the `dhcp` virtual server but leaves `containerPorts` / Service entry / NetworkPolicy ingress as manual `extraPorts`. Either wire it the way `coa` is wired (add `containerPorts.dhcp`, `service.ports.dhcp`, NetworkPolicy ingress rule) or document the intentional gap in the values comment.
- **`helm test` hook running `radclient`** — `tests/` directory already exists but holds no hook pods. Add a `helm.sh/hook: test` pod that runs `radclient -p 1812 status <fullname>:<status-port> <sites.status.secret>` against the deployed Service, giving ArgoCD/Flux a post-sync health gate. Cost: ~30 lines; payoff: catches broken installs before traffic hits.
- **EAP-PWD method** — `modules.eap.methods` ships `tls` / `ttls` / `peap` / `mschapv2`, but not `pwd`. EAP-PWD is the passwordless WiFi method that needs neither certificates nor a TLS-shared infra — useful for small/home deployments and as a stepping-stone before full EAP-TLS rollouts. Add `pwd` to the default methods list and an `eap.pwd.*` config block (default group 19, etc.).
- **TOTP / 2FA (`rlm_totp`)** — increasingly table-stakes for VPN/WiFi second-factor. Add `modules.totp.enabled` with `time_offset`, `lookback`, `lookforward`, `otp_length`, `key_attribute` knobs and wire it into the `authorize` / `authenticate` sections so it can layer on top of PAP/CHAP. Pairs naturally with the existing SQL backend for shared-secret storage.
- **External-Secrets / SecretProviderClass integration** — credentials, RADIUS shared secrets, TLS material, and per-instance OIDC `clientSecret` all live in chart-managed Secrets today. Many shops source from Vault / AWS Secrets Manager / GCP Secret Manager via ExternalSecrets or CSI SecretProviderClass. Add a `values.externalSecrets.*` pattern (or at minimum a docs §pattern under "Bring your own Secret") showing how to point `auth.existingSecret`, `tls.certificatesSecret`, `modules.oidc.instances.<name>.existingSecret`, etc. at an externally-synced Secret.
- **PodMonitor as alternative to ServiceMonitor** — `metrics.serviceMonitor.*` is wired; some Prometheus Operator installs (notably kube-prometheus-stack with a non-default selector scope) prefer PodMonitor. Add `metrics.podMonitor.enabled` rendering `templates/metrics/PodMonitor.yaml` mirroring the ServiceMonitor shape — small template, broadens out-of-the-box compatibility.

## Troubleshooting

Find more information about how to deal with common errors related to Startechnica's Helm charts in [this troubleshooting guide](https://startechnica.github.io/doc/troubleshoot-helm-chart-issues).

## Breaking Changes

Concise inventory of every breaking change shipped in this chart, newest
release first. Each entry links to the detailed migration in [§Upgrading](#upgrading)
where applicable; entries without a link are same-release renames with no
prior state to migrate from (the [Parameters](#parameters) table reflects
the new shape).

### 1.2.0

- **cert-manager is now used automatically** whenever its API is detected
  on the cluster — there is no toggle to force the in-template genCA path.
  To opt out, pre-create a Secret and set `tls.certificatesSecret`.
  See [§Upgrading → TLS issuance is now implicit](#tls-issuance-is-now-implicit-cert-manager-auto-detected-autogenerated-toggles-deprecated).
- **TLS auto-generation is now implicit.** When the matching feature is
  enabled (`tls.enabled`, `modules.eap.enabled`, `modules.sql.tls.enabled`)
  and no `*certificatesSecret` / `*certificates_secret` is supplied, the
  chart auto-generates. The four legacy toggles
  (`tls.autoGenerated`, `tls.certManager.create`,
  `modules.sql.tls.autoGenerated`, `modules.eap.tlsConfig.autoGenerated`)
  are still accepted but no longer consulted; NOTES.txt fires a
  deprecation advisory; removal in next major.
  See [§Upgrading → TLS issuance is now implicit](#tls-issuance-is-now-implicit-cert-manager-auto-detected-autogenerated-toggles-deprecated).
- **RADSEC site renamed `tls` → `radsec` end-to-end.** `sites.tls.*` →
  `sites.radsec.*`; ConfigMap, mount path, FreeRADIUS-internal
  `home_server`/`home_server_pool`/`realm` blocks, Secret key
  (`sites-tls-privkey-password` → `sites-radsec-privkey-password`),
  env-var (`FREERADIUS_SITES_TLS_PRIVKEY_PASSWORD` →
  `FREERADIUS_SITES_RADSEC_PRIVKEY_PASSWORD`), BYO secrets key
  (`sitesTlsPrivKeyPassword` → `sitesRadsecPrivKeyPassword`).
  Top-level `tls.*` (cert material switch) and `sites.tlsCache` are
  unaffected.
- **Keycloak module removed end-to-end → use `modules.oidc.*`.** The
  dedicated `keycloak.*` top-level block, its mapper ConfigMaps
  (`keycloak.{lua,py}`), env-var prefix (`FREERADIUS_KEYCLOAK_*` and the
  earlier `KC_*`), and NAS binding (`clients.<x>.keycloak`) are gone.
  Replaced by a generic, provider-agnostic OIDC module supporting any
  IdP (Keycloak, Authentik, Azure AD, Auth0, Okta, …) with per-instance
  config under `modules.oidc.instances.<name>` and NAS binding via
  `clients.<x>.oidc: <name>`. **No automatic migration shim** — the
  schemas differ enough (provider-agnostic `tokenUrl` instead of
  `url`+`realm`, required `rolesClaim`, no `mode` knob, rlm_python3-only)
  that a values rewrite is the only safe path. See [§Upgrading →
  Keycloak module removed](#keycloak-module-removed-migrate-to-modulesoidc-breaking).
- **`sites/coa.yaml` refactored to listen-inside-server.** Drops two
  over-flexible knobs: `sites.coa.listen.type` (only `coa` is valid) and
  `sites.coa.listen.virtual_server` (must match the on-disk filename).
  `sites.coa.listen.ipaddr` is kept.
- **Proxy / realm field renames to snake_case** to mirror the FreeRADIUS
  native directive names. Same-release rename (the new keys land
  alongside the new `homeServers` / `homeServerPools` / `realms` arrays
  in this same release), so old keys are silently ignored rather than
  shimmed:
  - `homeServers[].{responseWindow,zombiePeriod,reviveInterval,statusCheck,checkInterval,numAnswersToAlive}` → snake_case
  - `homeServerPools[].{virtualServer,homeServers}` → `virtual_server` / `home_servers` (silent-ignore renders an empty pool — functionally broken)
  - `realms[].{authPool,acctPool,virtualServer}` → snake_case; legacy proxy fields `authhost`/`accthost`/`secret` and new `coa_pool` accepted (silent-ignore renders an empty realm body — functionally broken)
  - `sites.radsec.clients[].{requireMessageAuthenticator,nasType,virtualServer}` → snake_case
  - `modules.sql.groupAttribute` / `modules.sql.readClients` → `modules.sql.group_attribute` / `modules.sql.read_clients`
  - `sites.radsec.cipher` → `sites.radsec.tls.cipher_list`
  - `sites.radsec.privateKeyPassword` → `sites.radsec.tls.private_key_password`

### 1.1.0

Numbered 1-10 in [§Upgrading → To 1.1.0 (breaking)](#to-110-breaking):

1. Cert-manager keys consolidated under `tls.certManager.*`.
2. The `ingress:` block is gone — use `gateway.hostnames`.
3. Gateway shape: flat → nested.
4. Gateway TLS knobs moved to `gateway.tls.*`.
5. SQL TLS / RADSEC TLS Secret keys renamed.
6. UDPRoute + TLSRoute replace HTTPRoute-style attachment.
7. Removed unused keys.
8. `modsEnabled:` renamed to `modules:`.
9. `sitesEnabled:` renamed to `sites:` (and `files/sites-available/` → `files/sites/`).
10. Bundled PostgreSQL subchart + dialect-aware backend selection.

## Upgrading

### To 1.2.0

#### TLS issuance is now implicit; cert-manager auto-detected; `autoGenerated` toggles deprecated

The chart now picks its TLS issuance mechanism automatically. When the
cert-manager API is detected on the cluster, RADSEC, EAP and gateway
certificates are issued through cert-manager; when it is absent, the chart
falls back to its in-template self-signed genCA path. **There is no longer
a toggle to force the genCA path on a cluster that has cert-manager
installed** — to opt out of cert-manager issuance for a given release,
pre-create a Secret yourself and point `tls.certificatesSecret` (or
`modules.sql.tls.certificatesSecret` / `modules.eap.tlsConfig.certificates_secret`)
at it.

Auto-generation is now **implicit** whenever the matching feature is
enabled and no `*certificatesSecret` / `*certificates_secret` is supplied.
The four legacy toggles are still accepted in values for backwards
compatibility but no longer consulted by the templates:

- `tls.autoGenerated`
- `tls.certManager.create`
- `modules.sql.tls.autoGenerated`
- `modules.eap.tlsConfig.autoGenerated`

All four are marked `deprecated: true` in `values.schema.json` and slated
for removal in the next major bump. NOTES.txt fires a deprecation
advisory whenever any of them is set to a non-default value.

`tls.certManager.issuerRef.name` continues to default to `""` (empty
bootstraps a chart-managed CA via `templates/Issuer.yaml`; set it to
reference a pre-existing Issuer/ClusterIssuer and skip the bootstrap).

```yaml
# Before (1.1.0)
tls:
  enabled: true
  autoGenerated: true            # required to opt in to chart-managed certs
  certManager:
    create: true                 # required to use cert-manager at all
    issuerRef:
      kind: ClusterIssuer
      name: selfsigned-issuer     # had to pre-exist

modules:
  sql:
    tls:
      enabled: true
      autoGenerated: true        # required to opt in
  eap:
    enabled: true
    tlsConfig:
      autoGenerated: true        # required to opt in

# After (1.2.0) — auto-generation is implicit; cert-manager auto-detected
tls:
  enabled: true                  # generation is implicit
  # certManager.issuerRef.name defaults to "" → chart bootstraps its own CA.
  # To use an existing issuer instead:
  # certManager:
  #   issuerRef:
  #     kind: ClusterIssuer
  #     name: my-issuer

modules:
  sql:
    tls:
      enabled: true              # generation is implicit
  eap:
    enabled: true                # tlsConfig generation is implicit

# To opt out of chart-managed generation, BYO a Secret per TLS context:
# tls:
#   certificatesSecret: my-radsec-tls
# modules:
#   sql:
#     tls:
#       certificatesSecret: my-sql-tls
#   eap:
#     tlsConfig:
#       certificates_secret: my-eap-tls
```

> **⚠️ Behaviour change for `tls.certManager.create: false` users.** If
> you previously set this to force the in-template genCA path on a
> cluster that has cert-manager installed, the chart now uses cert-manager
> anyway. To preserve the old behaviour, pre-create a Secret yourself and
> set `tls.certificatesSecret`.

> **⚠️ Behaviour change for `*autoGenerated: false` users.** If you set
> `modules.sql.tls.autoGenerated: false` or
> `modules.eap.tlsConfig.autoGenerated: false` to suppress chart
> generation (relying on the validator to flag the missing Secret), the
> chart now auto-generates instead. To preserve the no-generation
> behaviour, supply the corresponding `*certificatesSecret` /
> `*certificates_secret`.

#### Keycloak module removed; migrate to `modules.oidc.*` (BREAKING)

The dedicated Keycloak module from 1.1.0 has been removed end-to-end and
replaced by a generic OIDC module — same JWT/ROPC flow, but
provider-agnostic (Keycloak, Authentik, Azure AD, Auth0, Okta, …).
Configure each backend under `modules.oidc.instances.<name>`.
NAS-to-backend binding moves from `clients.<x>.keycloak: <name>` to
`clients.<x>.oidc: <name>`.

```yaml
# Before (1.1.0) — singleton Keycloak
keycloak:
  enabled: true
  mode: rest                                # rest | python | lua
  url: https://auth.example.com             # provider URL
  realm: master
  clientId: freeradius
  clientSecret: "…"
  roleMappings:
    - role: network-admin
      reply:
        - 'Service-Type := Administrative-User'
  cache: { enabled: true, ttl: 300 }

# After (1.2.0) — generic OIDC, multi-instance
modules:
  oidc:
    enabled: true
    instances:
      default:                              # fallback for unbound NAS
        tokenUrl: https://auth.example.com/realms/master/protocol/openid-connect/token
        clientId: freeradius
        clientSecret: "…"
        rolesClaim: realm_access.roles      # Keycloak's role-claim layout — now explicit
        roleMappings:
          - role: network-admin
            reply:
              - 'Service-Type := Administrative-User'
        cache: { enabled: true, ttl: 300 }
```

Per-instance OIDC resources rendered for `<name>`:

| Concern              | `default` instance                  | Named instance                          |
| -------------------- | ----------------------------------- | --------------------------------------- |
| Module instance      | `oidc`                              | `oidc_<name>`                           |
| Policy               | `oidc_authorize`                    | `oidc_<name>_authorize`                 |
| Cache instance       | `oidc_cache`                        | `oidc_<name>_cache`                     |
| Cache key (forced)   | `oidc:default:%{User-Name}`         | `oidc:<name>:%{User-Name}`              |
| Wrapper script (key) | `oidc_default.py`                   | `oidc_<name>.py`                        |
| ConfigMap (module)   | `<fullname>-oidc`                   | `<fullname>-oidc-<name>`                |
| ConfigMap (policy)   | `<fullname>-oidc-policy`            | `<fullname>-oidc-<name>-policy`         |
| ConfigMap (wrappers) | `<fullname>-oidc-python` (shared, one `data` key per instance)    |
| ConfigMap (library)  | `<fullname>-oidc-py` (one per release, holds the shared `oidc.py`)|
| Client-secret Secret | `<fullname>-oidc`                   | `<fullname>-oidc-<name>`                |
| TLS CA Secret        | `<fullname>-oidc-ca`                | `<fullname>-oidc-<name>-ca`             |
| CA mount path        | `/etc/freeradius/certs-oidc/`       | `/etc/freeradius/certs-oidc-<name>/`    |
| Env-var prefix       | `FREERADIUS_OIDC_*`                 | `FREERADIUS_OIDC_<NAME>_*`              |

Key migration points:

- **`mode: rest | python | lua` is gone.** The OIDC module is
  rlm_python3-only — `rlm_lua` is not bundled in
  `freeradius/freeradius-server:3.2.8`, and the `rest` variant was a
  strict subset of `python` that added nothing but config surface.
- **`url` + `realm` → `tokenUrl` (and optional `introspectUrl`).** OIDC
  is provider-agnostic, so the chart no longer constructs endpoints
  from a Keycloak-specific URL/realm pair. Supply the full token
  endpoint. For Keycloak: `<url>/realms/<realm>/protocol/openid-connect/token`.
- **`rolesClaim` is now required if you use `roleMappings`.** Keycloak
  exposes roles at `realm_access.roles` (the previous hard-coded
  assumption); other providers use `roles`, `groups`,
  `resource_access.<client>.roles`, etc. The chart can no longer guess.
- **NAS binding: `clients.<x>.keycloak: <name>` → `clients.<x>.oidc: <name>`.**
- **Env vars: `KC_*` and `FREERADIUS_KEYCLOAK_*` are gone.** The OIDC
  module reads only `FREERADIUS_OIDC[_<NAME>]_CLIENT_SECRET` from env;
  everything else is baked into the per-instance wrapper script at
  chart-render time.

> **⚠️ Migration is not automatic.** There is no shim that synthesises
> `modules.oidc.instances.default` from the old top-level `keycloak.*`
> block — the schemas differ enough (provider-agnostic endpoints,
> required `rolesClaim`, no `mode` knob, rlm_python3-only) that a
> values rewrite is the only safe path. Update `clients.<x>.keycloak`
> → `clients.<x>.oidc`, rewrite `keycloak.*` as
> `modules.oidc.instances.<name>.*`, and supply the full `tokenUrl`
> plus `rolesClaim` (and optional `introspectUrl`).

> **⚠️ One-time cache flush on upgrade.** Existing Redis-backed
> `keycloak_cache` entries (keyed `keycloak:%{User-Name}` in 1.1.0) are
> unreachable from the new `oidc_<name>_cache` module (keyed
> `oidc:<name>:%{User-Name}`) and naturally expire at `cache.ttl`. Flush
> sooner with `redis-cli FLUSHDB` against the chart's Redis if stale
> entries matter.

### To 1.1.0 (breaking)

This is a major release. Most users with existing `values.yaml` overrides
will need to migrate the keys below. The full change list is in
[CHANGELOG.md](CHANGELOG.md).

These notes apply to upgrades from **any pre-1.1.0 release**. The most recent
prior release, **1.0.3**, still used the old `modsEnabled` / `sitesEnabled` /
`ingress` / `configuration` / `tls.autoGenerator` keys, so the migrations below
are required coming from 1.0.x just as much as from 0.x. The `# Before` blocks
are labelled `≤ 1.0.3` accordingly.

#### 1. Cert-manager keys consolidated under `tls.certManager.*`

Cert-manager-driven TLS issuance is now configured in one canonical
location and covers both the in-pod RADSEC certificate and the
gateway-namespace certificate.

```yaml
# Before (≤ 1.0.3)
tls:
  autoGenerator:
    certmanager:
      enabled: true
      issuerKind: ClusterIssuer
      issuerName: letsencrypt

# After (1.1.0)
tls:
  certManager:
    create: true
    issuerRef:
      group: cert-manager.io
      kind: ClusterIssuer
      name: letsencrypt
```

#### 2. The `ingress:` block is gone — use `gateway.hostnames`

FreeRADIUS doesn't speak HTTP, so the chart no longer renders an Ingress.
Hostnames previously set under `ingress.hostname` / `ingress.extraHosts`
(which the Certificate, istio Gateway, and VirtualService templates read
from) now live under `gateway.hostnames`.

```yaml
# Before (≤ 1.0.3)
ingress:
  hostname: radius.example.com
  extraHosts:
    - name: radius2.example.com

# After (1.1.0)
gateway:
  enabled: true
  hostnames:
    - radius.example.com
    - radius2.example.com
```

#### 3. Gateway shape: flat → nested

The flat gateway knobs have been replaced with a nested form. The new
`gateway.implementation` flag picks between the two resource sets.

```yaml
# Before (≤ 1.0.3)
gateway:
  enabled: true
  gatewayApi: false        # if true → gateway-api; else → istio
  name: ""
  namespace: ""

# After (1.1.0)
gateway:
  enabled: true
  implementation: gateway-api   # or "istio"
  gateway:
    create: true
    name: ""
    namespace: ""
```

#### 4. Gateway TLS knobs moved to `gateway.tls.*`

The istio Gateway's TLS material is now configured under `gateway.tls`
rather than via `tls.secretName` / `sitesEnabled.tls.enabled`. In 1.1.0 the
`sitesEnabled:` block became `sites:` (see Upgrading #10) and RADSEC
enablement moved from the per-site `enabled` flag to the top-level
`tls.enabled`.

```yaml
# Before (≤ 1.0.3)
sitesEnabled:
  tls:
    enabled: true
tls:
  secretName: my-existing-tls

# After (1.1.0)
tls:
  enabled: true                       # enables RADSEC on the pod
gateway:
  enabled: true
  tls:
    enabled: true                     # renders the Gateway's TLS listener
    existingSecret: my-existing-tls   # BYO Secret (gateway-side)
    selfSigned: false
```

`sites.radsec.{cipher,privateKeyPassword}` remain — only the
`enabled` flag moved.

#### 5. SQL TLS / RADSEC TLS Secret keys renamed

The two `existingTlsSecret` / `existingSecretName` keys have been renamed
to `certificatesSecret` for consistency. The old keys still work via a
fallback in the helpers and are slated for removal in the next major bump.

```yaml
# Before (≤ 1.0.3)
tls:
  existingSecretName: my-radsec-tls
modsEnabled:
  sql:
    tls:
      existingTlsSecret: my-sql-tls

# After (1.1.0)
tls:
  certificatesSecret: my-radsec-tls
modules:
  sql:
    tls:
      certificatesSecret: my-sql-tls
```

#### 6. UDPRoute + TLSRoute replace HTTPRoute-style attachment

When using the Gateway API path, the chart now renders dedicated
`UDPRoute` resources for the auth/acct/coa ports and a `TLSRoute` for
RADSEC. UDPRoute support is uneven across GatewayClasses — Cilium and
Envoy Gateway support it, Istio currently does not (`UDPRoute` is an
Experimental-channel resource in Gateway API itself; the Istio gap is
tracked upstream in [istio/istio#54163](https://github.com/istio/istio/issues/54163)).
See the Gateway API [implementations matrix](https://gateway-api.sigs.k8s.io/implementations/)
for the current conformance status of HTTPRoute / TLSRoute / GRPCRoute
across implementations (UDPRoute is not part of the conformance
profile, so check the implementation's own docs). On clusters without
UDPRoute, fall back to `gateway.implementation: istio` (which uses
plain UDP listeners) or disable `gateway.udpRoute.enabled`.

#### 7. Removed unused keys

The following were removed without deprecation since they were never
consumed by any template:

- `gateway.dedicated`
- `gateway.extraRoute`
- `tls.secretName`
- `auth.{createClientUser,clientUser,clientUserPassword}`

#### 8. `modsEnabled:` renamed to `modules:`

The top-level Helm key for module enablement was renamed to drop the upstream
FreeRADIUS terminology drift (`mods-enabled` is the daemon's runtime path,
not a useful key name in values). Rename your overrides verbatim — every
sub-key under it (`sql`, `rest`, `json`, `pam`) keeps its shape.

```yaml
# Before (≤ 1.0.3)
modsEnabled:
  sql:
    enabled: true
    dialect: mysql
  rest:
    enabled: true
    connect_uri: https://api.example.com/radius

# After (1.1.0)
modules:
  sql:
    enabled: true
    dialect: mysql
  rest:
    enabled: true
    connect_uri: https://api.example.com/radius
```

Related chart-internal changes (only matter if you override templates):

- Each enabled module renders into its OWN ConfigMap
  (`templates/modules/<name>.yaml`, named `<release>-mods-<name>`) and is
  mounted at `mods-enabled/<name>` via its own pod volume
  `freeradius-mods-<name>`, with a per-module `checksum/configmap-mods-<name>`
  pod annotation. There is no aggregated `<release>-modules` ConfigMap — Helm
  upgrade creates the per-module ConfigMaps and removes any old aggregated one.

The in-container mount path `/etc/freeradius/mods-enabled/<name>` is
**unchanged** — that's the FreeRADIUS daemon's runtime path and isn't ours
to rename. Module config is now rendered directly from `.Values` into each
module ConfigMap (no `FREERADIUS_MODS_*` env-var indirection); only secrets
(DB/REST passwords, the EAP private-key passphrase) are injected as `$ENV{}`
by the Deployment.

#### 9. `sitesEnabled:` renamed to `sites:` (and `files/sites-available/` → `files/sites/`)

Same shape as the `modsEnabled:` → `modules:` rename in #8 — dropping the
upstream daemon-path terminology (`sites-enabled` is the runtime path, not
a useful key name in values). Sub-keys (`coa`, `status`, `tls`) keep their
shape.

```yaml
# Before (≤ 1.0.3)
sitesEnabled:
  coa:
    enabled: true
  status:
    enabled: true
    listen: 0.0.0.0

# After (1.1.0)
sites:
  coa:
    enabled: true
  status:
    enabled: true
    listen: 0.0.0.0
```

Chart-internal renames (only matter if you override templates):

- Source directory `files/sites-available/` → `files/sites/`.
- Template file `templates/configmap/sites-enabled.yaml` → `templates/configmap/sites.yaml`.
- K8s resource names (`<release>-sites` ConfigMap, `freeradius-sites`
  volume, `checksum/configmap-sites` annotation) were already in the short
  form and are unchanged.

The in-container mount path `/etc/freeradius/sites-enabled/<name>` is
**unchanged** — FreeRADIUS daemon convention.

#### 10. Bundled PostgreSQL subchart + dialect-aware backend selection

The chart now ships a `postgresql:` subchart block alongside the existing
`mariadb:` block. Pick exactly one backend; the chart's hard validator
(`freeradius.validate.sql.backend`) rejects two-subchart setups, mismatched
dialect/subchart pairs, `sqlite + subchart`, and "no backend at all".

```yaml
# Before (≤ 1.0.3 — postgresql users were forced to use externalDatabase)
modsEnabled:
  sql:
    dialect: postgresql
mariadb:
  enabled: false
externalDatabase:
  host: my-pg.example.com
  port: 5432
  user: freeradius_user
  database: freeradius_db
  existingSecret: pg-credentials

# After (1.1.0 — bundled PostgreSQL subchart)
modules:
  sql:
    dialect: postgresql
postgresql:
  enabled: true
  auth:
    username: freeradius_user
    database: freeradius_db
    # password auto-generated and stored in the postgresql subchart's Secret
  architecture: standalone
```

`externalDatabase.port` now defaults to `""` (empty); when left empty, the
chart picks `3306` for mysql and `5432` for postgresql automatically. Any
explicit value still wins. The connection helpers were renamed from
`freeradius.mariadb.{host,port,name,user,secretName,secretKey}` to
`freeradius.sql.{...}` — this only affects users who override templates,
not values.

## Parameters

### Global parameters

| Name                       | Description                                                                                                             | Value |
| -------------------------  | ----------------------------------------------------------------------------------------------------------------------- | ----- |
| `global.imageRegistry`     | Global Docker image registry                                                                                            | `""`  |
| `global.imagePullSecrets`  | Global Docker registry secret names as an array                                                                         | `[]`  |
| `global.storageClass`      | Global StorageClass for Persistent Volume(s)                                                                            | `""`  |
| `global.namespaceOverride` | Override the namespace for resource deployed by the chart, but can itself be overridden by the local namespaceOverride  | `""`  |


### Common parameters

| Name                       | Description                                                                                                       | Value           |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------- |
| `kubeVersion`              | Force target Kubernetes version (using Helm capabilities if not set)                                              | `""`            |
| `nameOverride`             | String to partially override common.names.fullname template with a string (will prepend the release name)         | `""`            |
| `namespaceOverride`        | String to fully override common.names.namespace                                                                   | `""`            |
| `fullnameOverride`         | String to fully override common.names.fullname template with a string                                             | `""`            |
| `commonAnnotations`        | Annotations to add to all deployed objects                                                                        | `{}`            |
| `commonLabels`             | Labels to add to all deployed objects                                                                             | `{}`            |
| `schedulerName`            | Name of the Kubernetes scheduler (other than default)                                                             | `""`            |
| `clusterDomain`            | Kubernetes DNS Domain name to use                                                                                 | `cluster.local` |
| `extraDeploy`              | Array of extra objects to deploy with the release (evaluated as a template)                                       | `[]`            |
| `diagnosticMode.enabled`   | Enable diagnostic mode (all probes will be disabled and the command will be overridden)                           | `false`         |
| `diagnosticMode.command`   | Command to override all containers in the deployment                                                              | `[]`            |
| `diagnosticMode.args`      | Args to override all containers in the deployment                                                                 | `[]`            |
   
   
### FreeRADIUS parameters

| Name                                          | Description                                                                                                              | Value                          |
| ----------------------------------------------| -------------------------------------------------------------------------------------------------------------------------| -------------------------------|
| `image.registry`                              | FreeRADIUS image registry                                                                                                | `docker.io`                    |
| `image.repository`                            | FreeRADIUS image repository                                                                                              | `freeradius/freeradius-server` |
| `image.tag`                                   | FreeRADIUS image tag (immutable tags are recommended)                                                                    | `3.2.3`                        |
| `image.pullPolicy`                            | FreeRADIUS image pull policy                                                                                             | `IfNotPresent`                 |
| `image.pullSecrets`                           | Specify docker-registry secret names as an array                                                                         | `[]`                           |
| `image.debug`                                 | Toggle the container args between `-f` (normal foreground) and `-fxx` (verbose debug). Independent of `logging.destination`. | `false`                        |
| `architecture`                                | FreeRADIUS architecture mode. `standalone` (default) or `replication`. The `replication` value flips `proxy_requests` on and feeds the chart's proxy/realm machinery; `standalone` runs the server without proxying. | `standalone`                   |
| `logging.destination`                         | FreeRADIUS log sink: `files` (write to `logging.file`), `syslog` (use `logging.syslog_facility`), `stdout`, or `stderr`. Runtime `-X` debug flag overrides this to stdout. | `stdout`                       |
| `logging.colourise`                           | Highlight WARN / ERROR log lines on stderr / stdout. No-op when output is not a TTY.                                     | `true`                         |
| `logging.file`                                | Log file path when `logging.destination: files`. `${logdir}` is a FreeRADIUS variable interpolated by FreeRADIUS at startup, not by Helm. | `${logdir}/radius.log`         |
| `logging.syslog_facility`                     | Syslog facility used when `logging.destination: syslog`. OS-dependent allowed values; `daemon` is the conventional default. | `daemon`                       |
| `logging.stripped_names`                      | When `true`, log the realm-stripped form of `User-Name` instead of the raw value.                                        | `false`                        |
| `logging.auth`                                | Log every Access-Accept / Access-Reject result.                                                                          | `false`                        |
| `logging.auth_badpass`                        | Log the offered password on rejected authentication. Requires `logging.auth: true`. Footgun — secrets in logs.            | `false`                        |
| `logging.auth_goodpass`                       | Log the offered password on successful authentication. Requires `logging.auth: true`. Footgun — secrets in logs.          | `false`                        |
| `logging.msg_denied`                          | Reply message returned when the user exceeds the Simultaneous-Use limit (rendered as a quoted string).                   | `"You are already logged in - access denied"` |
| `hostAliases`                                 | Deployment pod host aliases                                                                                              | `[]`                           |
| `command`                                     | Override default container command (useful when using custom images)                                                     | `[]`                           |
| `args`                                        | Override default container args (useful when using custom images)                                                        | `[]`                           |
| `extraEnvVars`                                | Extra environment variables to be set on FreeRADIUS containers                                                           | `[]`                           |
| `extraEnvVarsCM`                              | ConfigMap with extra environment variables                                                                               | `""`                           |
| `extraEnvVarsSecret`                          | Secret with extra environment variables                                                                                  | `""`                           |
| `service.type`                                | Kubernetes service type                                                                                                  | `ClusterIP`                    |
| `service.clusterIP`                           | Specific cluster IP when service type is cluster IP. Use `None` for headless service                                     | `""`                           |
| `service.ports.auth`                          | FreeRADIUS Authentication and Authorization service port                                                                 | `1812`                         |
| `service.ports.acct`                          | FreeRADIUS Accounting service port                                                                                       | `1813`                         |
| `service.ports.coa`                           | FreeRADIUS CoA service port                                                                                              | `3799`                         |
| `service.ports.radsec`                        | FreeRADIUS RadSec service port                                                                                           | `2083`                         |
| `service.ports.status`                        | FreeRADIUS Status service port                                                                                           | `18121`                        |
| `service.nodePorts.auth`                      | Specify the nodePort value for the LoadBalancer and NodePort for Authentication service types.                           | `""`                           |
| `service.nodePorts.acct`                      | Specify the nodePort value for the LoadBalancer and NodePort for Accounting service types.                               | `""`                           |
| `service.nodePorts.coa`                       | Specify the nodePort value for the LoadBalancer and NodePort for CoA service types.                                      | `""`                           |
| `service.nodePorts.radsec`                    | Specify the nodePort value for the LoadBalancer and NodePort for RadSec service types.                                   | `""`                           |
| `service.nodePorts.status`                    | Specify the nodePort value for the LoadBalancer and NodePort for Status service types.                                   | `""`                           |
| `service.extraPorts`                          | Extra ports to expose (normally used with the `sidecar` value)                                                           | `[]`                           |
| `service.externalIPs`                         | External IP list to use with ClusterIP service type                                                                      | `[]`                           |
| `service.loadBalancerIP`                      | `loadBalancerIP` if service type is `LoadBalancer`                                                                       | `""`                           |
| `service.loadBalancerSourceRanges`            | Addresses that are allowed when svc is `LoadBalancer`                                                                    | `[]`                           |
| `service.externalTrafficPolicy`               | FreeRADIUS service external traffic policy                                                                               | `Cluster`                      |
| `service.annotations`                         | Additional annotations for FreeRADIUS service                                                                            | `{}`                           |
| `service.sessionAffinity`                     | Session Affinity for Kubernetes service, can be `None` or `ClientIP`                                                     | `None`                         |
| `service.sessionAffinityConfig`               | Additional settings for the sessionAffinity                                                                              | `{}`                           |
| `serviceAccount.create`                       | Specify whether a ServiceAccount should be created                                                                       | `false`                        |
| `serviceAccount.name`                         | Name of the service account to use. If not set and create is true, a name is generated using the fullname template.      | `""`                           |
| `serviceAccount.automountServiceAccountToken` | Automount service account token for the server service account                                                           | `false`                        |
| `serviceAccount.annotations`                  | Annotations for service account. Evaluated as a template. Only used if `create` is `true`.                               | `{}`                           |
| `command`                                     | Override default container command (useful when using custom images)                                                     | `[]`                           |
| `extraEnvVars`                                | Array containing extra env vars to configure FreeRADIUS                                                                  | `[]`                           |
| `extraEnvVarsCM`                              | ConfigMap containing extra env vars to configure FreeRADIUS                                                              | `""`                           |
| `extraEnvVarsSecret`                          | Secret containing extra env vars to configure FreeRADIUS                                                                 | `""`                           |
| `rbac.create`                                 | Specify whether RBAC resources should be created and used                                                                | `false`                        |
| `podSecurityContext.enabled`                  | Enable security context                                                                                                  | `true`                         |
| `podSecurityContext.fsGroup`                  | Group ID for the container filesystem                                                                                    | `101`                          |
| `podSecurityContext.runAsUser`                | User ID for the container                                                                                                | `101`                          |
| `containerSecurityContext.enabled`            | Enabled FreeRADIUS container Security Context                                                                            | `true`                         |
| `containerSecurityContext.runAsUser`          | Set FreeRADIUS container Security Context runAsUser                                                                      | `101`                          |
| `containerSecurityContext.runAsNonRoot`       | Set FreeRADIUS container Security Context runAsNonRoot                                                                   | `true`                         |
| `tls.enabled`                                 | Enable RADSEC (RADIUS over TLS, TCP/2083) — RADSEC listener + chart-managed `home_server radsec` loopback + matching `home_server_pool radsec` / `realm radsec`. | `false`                        |
| `tls.autoGenerated`                           | **DEPRECATED — no longer consulted; removal in next major.** TLS auto-generation is now implicit when `tls.enabled` is set and no `tls.certificatesSecret` is supplied. | `false`                        |
| `tls.certificatesSecret`                      | Name of an existing Secret containing the RADSEC certificate material (`tls.crt`, `tls.key`, `ca.crt`). When set, opts out of chart-managed generation. | `""`                           |
| `tls.certFilename`                            | Certificate filename inside `tls.certificatesSecret`                                                                     | `""`                           |
| `tls.certKeyFilename`                         | Certificate key filename inside `tls.certificatesSecret`                                                                 | `""`                           |
| `tls.certCAFilename`                          | CA Certificate filename inside `tls.certificatesSecret`                                                                  | `""`                           |
| `configurations`                              | Inline override for the FreeRADIUS `radiusd.conf` body (run through `tplvalues.render`). When set, replaces the chart-managed body in `templates/configmaps/configuration.yaml`. Leave empty to use the chart-managed default. | `""`                           |
| `configurationsConfigMap`                     | Name of an externally-managed ConfigMap supplying `radiusd.conf` (must contain a `radiusd.conf` key). When set, skips both the chart-managed body and `configurations` — the Deployment mounts this resource at `/etc/freeradius/radiusd.conf`. Evaluated as a template. | `""`                           |
| `initdbScripts`                               | Specify dictionary of scripts to be run at first boot                                                                    | `{}`                           |
| `initdbScriptsConfigMap`                      | ConfigMap with the initdb scripts (Note: Overrides `initdbScripts`)                                                      | `""`                           |
| `extraStartupArgs`                            | Extra args prepended to the FreeRADIUS container command line (before `-f` / `-fxx`).                                    | `""`                           |
| `extraFlags`                                  | FreeRADIUS additional command line flags                                                                                 | `""`                           |
| `kind`                                        | Workload kind rendered by `templates/Application.yaml`. Accepted case-insensitively: `Deployment` / `StatefulSet` / `DaemonSet`. `StatefulSet` gives stable per-pod identity + per-replica `volumeClaimTemplates`; `DaemonSet` schedules one pod per node and ignores `replicaCount` / `horizontalPodAutoscaler`. | `Deployment`                   |
| `replicaCount`                                | Desired number of cluster nodes                                                                                          | `3`                            |
| `podManagementPolicy`                         | StatefulSet pod-start ordering. Empty → Kubernetes default (`OrderedReady`); `Parallel` starts all pods simultaneously. **IMMUTABLE on existing StatefulSets** — flipping the value on a live release requires `kubectl delete sts <release> --cascade=orphan` (preserves pods + PVCs) before the new spec lands. No effect on Deployment / DaemonSet. | `Parallel`                     |
| `podLabels`                                   | Extra labels for FreeRADIUS pods                                                                                         | `{}`                           |
| `podAnnotations`                              | Annotations for FreeRADIUS  pods                                                                                         | `{}`                           |
| `podAffinityPreset`                           | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                      | `""`                           |
| `podAntiAffinityPreset`                       | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                 | `soft`                         |
| `nodeAffinityPreset.type`                     | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                | `""`                           |
| `nodeAffinityPreset.key`                      | Node label key to match. Ignored if `affinity` is set.                                                                   | `""`                           |
| `nodeAffinityPreset.values`                   | Node label values to match. Ignored if `affinity` is set.                                                                | `[]`                           |
| `affinity`                                    | Affinity for pod assignment                                                                                              | `{}`                           |
| `nodeSelector`                                | Node labels for pod assignment                                                                                           | `{}`                           |
| `tolerations`                                 | Tolerations for pod assignment                                                                                           | `[]`                           |
| `topologySpreadConstraints`                   | Topology Spread Constraints for pods assignment                                                                          | `[]`                           |
| `lifecycleHooks`                              | for the galera container(s) to automate configuration before or after startup                                            | `{}`                           |
| `containerPorts.auth`                         | Auth database container port                                                                                             | `1812`                         |
| `containerPorts.acct`                         | Acct cluster container port                                                                                              | `1813`                         |
| `containerPorts.coa`                          | CoA container port                                                                                                       | `3799`                         |
| `containerPorts.radsec`                       | RadSec container port                                                                                                    | `2083`                         |
| `containerPorts.status`                       | Status container port                                                                                                    | `18121`                        |
| `persistence.enabled`                         | Enable persistence using PVC                                                                                             | `true`                         |
| `persistence.existingClaim`                   | Provide an existing `PersistentVolumeClaim`                                                                              | `""`                           |
| `persistence.subPath`                         | Subdirectory of the volume to mount                                                                                      | `""`                           |
| `persistence.mountPath`                       | Path to mount the volume at                                                                                              | `/startechnica/freeradius`     |
| `persistence.selector`                        | Selector to match an existing Persistent Volume (this value is evaluated as a template)                                  | `{}`                           |
| `persistence.storageClass`                    | Persistent Volume Storage Class                                                                                          | `""`                           |
| `persistence.annotations`                     | Persistent Volume Claim annotations                                                                                      | `{}`                           |
| `persistence.labels`                          | Persistent Volume Claim Labels                                                                                           | `{}`                           |
| `persistence.accessModes`                     | Persistent Volume Access Modes                                                                                           | `["ReadWriteOnce"]`            |
| `persistence.size`                            | Persistent Volume Size                                                                                                   | `8Gi`                          |
| `priorityClassName`                           | Priority Class Name for Statefulset                                                                                      | `""`                           |
| `initContainers`                              | Additional init containers (this value is evaluated as a template)                                                       | `[]`                           |
| `sidecars`                                    | Add additional sidecar containers (this value is evaluated as a template)                                                | `[]`                           |
| `extraVolumes`                                | Extra volumes                                                                                                            | `[]`                           |
| `extraVolumeMounts`                           | Mount extra volume(s)                                                                                                    | `[]`                           |
| `resources.limits`                            | The resources limits for the container                                                                                   | `{}`                           |
| `resources.requests`                          | The requested resources for the container                                                                                | `{}`                           |
| `livenessProbe.enabled`                       | Turn on and off liveness probe                                                                                           | `true`                         |
| `livenessProbe.initialDelaySeconds`           | Delay before liveness probe is initiated                                                                                 | `120`                          |
| `livenessProbe.periodSeconds`                 | How often to perform the probe                                                                                           | `10`                           |
| `livenessProbe.timeoutSeconds`                | When the probe times out                                                                                                 | `1`                            |
| `livenessProbe.failureThreshold`              | Minimum consecutive failures for the probe                                                                               | `3`                            |
| `livenessProbe.successThreshold`              | Minimum consecutive successes for the probe                                                                              | `1`                            |
| `readinessProbe.enabled`                      | Turn on and off readiness probe                                                                                          | `true`                         |
| `readinessProbe.initialDelaySeconds`          | Delay before readiness probe is initiated                                                                                | `30`                           |
| `readinessProbe.periodSeconds`                | How often to perform the probe                                                                                           | `10`                           |
| `readinessProbe.timeoutSeconds`               | When the probe times out                                                                                                 | `1`                            |
| `readinessProbe.failureThreshold`             | Minimum consecutive failures for the probe                                                                               | `3`                            |
| `readinessProbe.successThreshold`             | Minimum consecutive successes for the probe                                                                              | `1`                            |
| `startupProbe.enabled`                        | Turn on and off startup probe                                                                                            | `false`                        |
| `startupProbe.initialDelaySeconds`            | Delay before startup probe is initiated                                                                                  | `120`                          |
| `startupProbe.periodSeconds`                  | How often to perform the probe                                                                                           | `10`                           |
| `startupProbe.timeoutSeconds`                 | When the probe times out                                                                                                 | `1`                            |
| `startupProbe.failureThreshold`               | Minimum consecutive failures for the probe                                                                               | `48`                           |
| `startupProbe.successThreshold`               | Minimum consecutive successes for the probe                                                                              | `1`                            |
| `customStartupProbe`                          | Custom liveness probe for the Web component                                                                              | `{}`                           |
| `customLivenessProbe`                         | Custom liveness probe for the Web component                                                                              | `{}`                           |
| `customReadinessProbe`                        | Custom rediness probe for the Web component                                                                              | `{}`                           |
| `podDisruptionBudget.create`                  | Specifies whether a Pod disruption budget should be created                                                              | `false`                        |
| `podDisruptionBudget.minAvailable`            | Minimum number / percentage of pods that should remain scheduled                                                         | `1`                            |
| `podDisruptionBudget.maxUnavailable`          | Maximum number / percentage of pods that may be made unavailable                                                         | `""`                           |
| `metrics.enabled`                             | Start a side-car prometheus exporter                                                                                     | `false`                        |
| `metrics.image.registry`                      | FreeRADIUS Prometheus exporter image registry                                                                            | `""`                           |
| `metrics.image.repository`                    | FreeRADIUS Prometheus exporter image repository                                                                          | `""`                           |
| `metrics.image.tag`                           | FreeRADIUS Prometheus exporter image tag (immutable tags are recommended)                                                | `""`                           |
| `metrics.image.pullPolicy`                    | FreeRADIUS Prometheus exporter image pull policy                                                                         | `IfNotPresent`                 |
| `metrics.image.pullSecrets`                   | FreeRADIUS Prometheus exporter image pull secrets                                                                        | `[]`                           |
| `metrics.extraFlags`                          | FreeRADIUS Prometheus exporter additional command line flags                                                             | `[]`                           |
| `metrics.resources.limits`                    | The resources limits for the container                                                                                   | `{}`                           |
| `metrics.resources.requests`                  | The requested resources for the container                                                                                | `{}`                           |
| `metrics.service.type`                        | Prometheus exporter service type                                                                                         | `ClusterIP`                    |
| `service.ports.metrics`                       | Prometheus exporter service port (top-level ports inventory)                                                             | `9812`                         |
| `metrics.service.annotations`                 | Prometheus exporter service annotations                                                                                  | `{}`                           |
| `metrics.service.loadBalancerIP`              | Load Balancer IP if the Prometheus metrics server type is `LoadBalancer`                                                 | `""`                           |
| `metrics.service.clusterIP`                   | Prometheus metrics service Cluster IP                                                                                    | `""`                           |
| `metrics.service.loadBalancerSourceRanges`    | Prometheus metrics service Load Balancer sources                                                                         | `[]`                           |
| `metrics.service.externalTrafficPolicy`       | Prometheus metrics service external traffic policy                                                                       | `Cluster`                      |
| `metrics.serviceMonitor.enabled`              | if `true`, creates a Prometheus Operator ServiceMonitor (also requires `metrics.enabled` to be `true`)                   | `false`                        |
| `metrics.serviceMonitor.namespace`            | Optional namespace which Prometheus is running in                                                                        | `""`                           |
| `metrics.serviceMonitor.jobLabel`             | The name of the label on the target service to use as the job name in prometheus.                                        | `""`                           |
| `metrics.serviceMonitor.interval`             | How frequently to scrape metrics (use by default, falling back to Prometheus' default)                                   | `""`                           |
| `metrics.serviceMonitor.scrapeTimeout`        | Timeout after which the scrape is ended                                                                                  | `""`                           |
| `metrics.serviceMonitor.selector`             | ServiceMonitor selector labels                                                                                           | `{}`                           |
| `metrics.serviceMonitor.relabelings`          | RelabelConfigs to apply to samples before scraping                                                                       | `[]`                           |
| `metrics.serviceMonitor.metricRelabelings`    | MetricRelabelConfigs to apply to samples before ingestion                                                                | `[]`                           |
| `metrics.serviceMonitor.honorLabels`          | honorLabels chooses the metric's labels on collisions with target labels                                                 | `false`                        |
| `metrics.serviceMonitor.labels`               | ServiceMonitor extra labels                                                                                              | `{}`                           |
| `metrics.prometheusRule.enabled`              | If `true`, creates a Prometheus Operator PrometheusRule (also requires `metrics.enabled`, and makes little sense without `metrics.serviceMonitor.enabled`)                                     | `false`                        |
| `metrics.prometheusRule.namespace`            | Namespace in which to create the PrometheusRule (defaults to the release namespace)                                                                                                           | `""`                           |
| `metrics.prometheusRule.additionalLabels`     | Extra labels merged onto the PrometheusRule so the Prometheus Operator's `ruleSelector` picks it up                                                                                           | `{app: prometheus-operator, release: prometheus}` |
| `metrics.prometheusRule.groups`               | Verbatim `spec.groups` list passthrough (additive with `rules`)                                                                                                                               | `[]`                           |
| `metrics.prometheusRule.rules`                | PrometheusRule rules rendered under a single group named after the chart fullname (default set targets `bvantagelimited/freeradius_exporter` metric names)                                    | See `values.yaml`              |


### Modules parameters

| Name                                       | Description                                         | Value             |
| ------------------------------------------ | --------------------------------------------------- | ----------------- |
| `modules.sql.enabled`                  | Enable FreeRADIUS SQL module                        | `false`           |
| `modules.sql.dialect`                  | The driver module used to execute the queries.      | `mysql`           |
| `modules.sql.table.acct1`              | Tables containing 'accounting' items                | `radacct`         |
| `modules.sql.table.acct2`              | Tables containing 'accounting' items                | `radacct`         |
| `modules.sql.table.authcheck`          | Tables containing 'check' items                     | `radcheck`        |
| `modules.sql.table.authreply`          | Tables containing 'reply' items                     | `radreply`        |
| `modules.sql.table.client`             | Table to keep radius client info                    | `nas`             |
| `modules.sql.table.groupcheck`         | Tables containing 'check' items                     | `radgroupcheck`   |
| `modules.sql.table.groupreply`         | Tables containing 'reply' items                     | `radgroupreply`   |
| `modules.sql.table.postauth`           | Allow for storing data after authentication         | `radpostauth`     |
| `modules.sql.table.usergroup`          | Table to keep group info                            | `radusergroup`    |
| `modules.sql.tls.enabled`              | Enable FreeRADIUS SQL TLS module                    | `false`           |
| `modules.sql.tls.autoGenerated`        |                                                     | `false`           |
| `modules.sql.tls.certificatesSecret`   |                                                     | `""`              |
| `modules.sql.tls.certFilename`         |                                                     | `""`              |
| `modules.sql.tls.certKeyFilename`      |                                                     | `""`              |
| `modules.sql.tls.certCAFilename`       |                                                     | `""`              |
| `modules.sql.tls.existingTlsSecret`    |                                                     | `""`              |
| `modules.sql.group_attribute`          | Group attribute specific to this instance of rlm_sql (maps 1:1 to FreeRADIUS `group_attribute`) | `SQL-Group` |
| `modules.sql.read_clients`             | Read RADIUS clients from the `nas` table on startup (maps 1:1 to FreeRADIUS `read_clients`) | `true` |


### Proxy / realm parameters

Inline definitions of FreeRADIUS proxy targets (`home_server`), pools, and realms. Each top-level array is rendered into its own ConfigMap, mounted under `/opt/startechnica/freeradius/`, and `$INCLUDE`d from `radiusd.conf` in dependency order (`home-servers.conf` → `home-server-pools.conf` → `realms.conf`). The chart-managed `proxy.conf` (sourced from `files/proxy.conf` and mounted at `/etc/freeradius/proxy.conf`) replaces the image's bundled one with `realm LOCAL { }` commented out so the chart can own that name.

| Name                                       | Description                                                                                                          | Value             |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------- | ----------------- |
| `homeServers`                              | Inline `home_server` entries. Per-entry fields use snake_case mirroring FreeRADIUS native `home_server { }` directives (`name`, `type`, `ipaddr`, `port`, `secret`, `proto`, `response_window`, `zombie_period`, `revive_interval`, `status_check`, `check_interval`, `num_answers_to_alive`). See `values.yaml` for the full per-entry schema. | `[]` |
| `homeServerPools`                          | Inline `home_server_pool` entries. Per-entry: `name`, `type`, `home_servers` (list of `home_server` name references), optional `virtual_server`, `fallback`. | `[]` |
| `realms`                                   | Inline `realm` entries. Per-entry: `name`, new-style proxy via `auth_pool` / `acct_pool` / `coa_pool`, old-style proxy via `authhost` / `accthost` / `secret`, optional `nostrip` flag, optional local `virtual_server`. `realm LOCAL { }` is chart-managed (emitted unconditionally unless overridden by a user `name: LOCAL` entry); when `tls.enabled` the chart also emits `realm radsec { auth_pool = radsec }` plus the matching `home_server radsec` and `home_server_pool radsec` loopback definitions. | `[]` |
| `createDefaultInstance.realm`              | Emit a chart-managed `realm DEFAULT { auth_pool = <fullname>_auth_pool; acct_pool = <fullname>_acct_pool }` block referencing the auto-gen pools. No-op outside `kind: StatefulSet`. | `false` |
| `createDefaultInstance.homeServer`         | Emit one `home_server <fullname>_<ord>_auth` and one `<fullname>_<ord>_acct` per StatefulSet replica, each targeting the matching per-pod Service (`<fullname>-<ord>.<ns>.svc`). `secret` is rendered as literal `$ENV{FREERADIUS_DEFAULT_INSTANCE_SECRET}` — wire the env var yourself via `extraEnvVarsSecret`. No-op outside `kind: StatefulSet`. | `false` |
| `createDefaultInstance.homeServerPool`     | Emit `home_server_pool <fullname>_auth_pool` and `<fullname>_acct_pool` (each `type = load-balance`) listing the per-pod home_servers. No-op outside `kind: StatefulSet`. | `false` |


### Custom FreeRADIUS enabled sites parameters

| Name                                       | Description                                                                     | Value             |
| ------------------------------------------ | ------------------------------------------------------------------------------- | ----------------- |
| `sites.default.enabled`               | Enable the `default` virtual server (the main auth/acct server)                                    | `true`    |
| `sites.default.existingConfigMap`     | BYO ConfigMap (key `default`) mounted at `sites-enabled/default`; skips chart rendering            | `""`      |
| `sites.innerTunnel.enabled`           | Enable the `inner-tunnel` virtual server (EAP-TTLS/PEAP inner identity)                            | `true`    |
| `sites.innerTunnel.existingConfigMap` | BYO ConfigMap (key `inner-tunnel`) mounted at `sites-enabled/inner-tunnel`; skips chart rendering  | `""`      |
| `sites.coa.enabled`                   | Enable the `coa` virtual server (Change-of-Authorization)                                          | `false`   |
| `sites.coa.existingConfigMap`         | BYO ConfigMap (key `coa`) mounted at `sites-enabled/coa`; skips chart rendering                    | `""`      |
| `sites.status.enabled`                | Enable the `status` virtual server                                                                 | `true`    |
| `sites.status.listen`                 | Listen address for the status server                                                               | `0.0.0.0` |
| `sites.status.secret`                 | Shared secret for the status `radclient` (auto-generated when empty)                               | `""`      |
| `sites.status.existingConfigMap`      | BYO ConfigMap (key `status`) mounted at `sites-enabled/status`; skips chart rendering              | `""`      |
| `sites.dhcp.enabled`                  | Enable the `dhcp` virtual server                                                                   | `false`   |
| `sites.dhcp.existingConfigMap`        | BYO ConfigMap (key `dhcp`) mounted at `sites-enabled/dhcp`; skips chart rendering                  | `""`      |
| `sites.radsec.enabled`                       | Enable the RADSEC virtual server                                                                       | `false`     |
| `sites.radsec.listen.ipaddr`                 | Bind address for the RADSEC `listen { }` block (`*` = all interfaces)                                  | `"*"`       |
| `sites.radsec.listen.type`                   | Listen-socket packet type (`auth+acct` / `auth` / `acct`)                                              | `auth+acct` |
| `sites.radsec.listen.virtual_server`         | Virtual server that processes decrypted RADSEC requests                                                | `default`   |
| `sites.radsec.listen.proxy_protocol`         | Parse HAProxy PROXY-protocol headers (use the real client IP for client lookup)                        | `false`     |
| `sites.radsec.listen.check_client_connections` | Validate the client TCP/TLS handshake up front and reject unauthorised peers before parsing RADIUS    | `false`     |
| `sites.radsec.tls.cipher_list`               | OpenSSL cipher string for the radsec listener `tls { cipher_list = ... }` and the chart-managed `home_server radsec` loopback (`DEFAULT` keeps the image default) | `DEFAULT` |
| `sites.radsec.tls.private_key_password`      | Password for the RADSEC private key when it is password-protected. Auto-generated into the chart credentials Secret (`sites-radsec-privkey-password`) when left empty; the env-var (`FREERADIUS_SITES_RADSEC_PRIVKEY_PASSWORD`) is wired only when this value is set. | `""` |
| `sites.radsec.radsecSecret`                  | RADIUS shared secret for the chart-managed loopback `client 127.0.0.1` (auto-generated when empty)     | `""`        |
| `sites.radsec.clients`                       | Additional external RADSEC peers (NASes, WiFi controllers, switches) authorised to connect on port `containerPorts.radsec`. Each entry renders a `client <name> { }` block inside the existing `clients radsec { }` group alongside the chart-managed loopback. Per-entry fields use snake_case (`name`, `ipaddr`, `ipv6addr`, `secret`, `require_message_authenticator`, `nas_type`, `virtual_server`). | `[]` |
| `sites.radsec.existingConfigMap`             | BYO ConfigMap (key `radsec`) mounted at `sites-enabled/radsec`; skips chart rendering                  | `""`        |


### OIDC integration parameters

Generic OIDC module (`modules.oidc.*`) — provider-agnostic ROPC + JWT/introspect
flow against any IdP (Keycloak, Authentik, Azure AD, Auth0, Okta, …). Per-instance
config under `modules.oidc.instances.<name>`; NAS-to-instance binding via
`clients.<x>.oidc: <name>`.

| Name                                                  | Description                                                                                                                                                                | Value     |
| ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| `modules.oidc.enabled`                                | Master gate — render the OIDC ConfigMaps + Secrets + mounts. No-op when `false`.                                                                                           | `false`   |
| `modules.oidc.wireDefaultSite`                        | Auto-wire the `default` instance's `oidc_authorize` as the dispatch chain's `else` branch in `sites/default` and `sites/inner-tunnel`. No-op when no `default` instance.   | `true`    |
| `modules.oidc.unmatchedReject`                        | When `true` AND no `default` instance is wired, the dispatch chain rejects unmatched NAS instead of falling through to `pap`.                                              | `false`   |
| `modules.oidc.instances`                              | Map of named OIDC backends. Key = instance name (`^[a-z][a-z0-9_]*$`). Per-instance keys (see `modules.oidc.instances` block in [values.yaml](values.yaml) for the full schema): `tokenUrl` (REQUIRED), `introspectUrl`, `clientId`, `clientSecret` / `existingSecret`, `scope`, `connectTimeout`, `roleAttribute`, `rolesClaim`, `denyWithoutRole`, `roleMappings`, `groupAttribute`, `groupsClaim`, `groupMappings`, `attributeMappings`, `require`, `introspect`, `refreshTokenCache`, `cache.{enabled,ttl}`, `tls.{caCert,existingSecret,existingSecretCaKey,insecure}`, `existingConfigMap`. | `{}`      |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
helm install my-release \
  --set imagePullPolicy=Always \
  oci://ghcr.io/startechnica/charts/freeradius
```

The above command sets the `imagePullPolicy` to `Always`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
helm install my-release oci://ghcr.io/startechnica/charts/freeradius -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## License

Copyright &copy; 2026 Startechnica

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.