# Changelog

## 1.0.0 (2026-05-27)

Major release. End-to-end modernization matching the playbook applied to the
adminer chart in 1.0.0: values.yaml restructured with section banners, TLS /
cert-manager keys consolidated, a chart-internal shared CA helper, full
Gateway API resource set adapted for RADIUS traffic (UDPRoute / TLSRoute),
HPA template, and a long list of common template fixes.
**See "Upgrading from 0.x" in the README for the migration steps your
`values.yaml` needs.**

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
- `templates/ServiceMonitor.yaml` for Prometheus Operator scraping (matches
  the adminer template shape — synthetic single-endpoint fallback plus
  full `endpoints[]` passthrough).
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
- `gateway.gateway.{create,name,namespace}` nested form (matches adminer
  shape; replaces flat `gateway.name`/`gateway.namespace`).
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
  New values: `metrics.{replicaCount,extraArgs,extraEnvVars,resources,
  containerSecurityContext,livenessProbe,readinessProbe,
  customLivenessProbe,customReadinessProbe,podAnnotations,podLabels,
  nodeSelector,tolerations,affinity,priorityClassName,containerPorts.http,
  service.{type,port,nodePort,clusterIP,loadBalancerIP,
  loadBalancerSourceRanges,annotations}}`. The exporter's
  `RADIUS_PASSWORD` is wired from the chart-managed `sites-status-secret`
  automatically. Requires `sitesEnabled.status.enabled: true` — enforced by
  a new `freeradius.validateValues` aggregator that calls `fail` during
  `helm install` / `helm upgrade` / `helm template` when the two flags are
  mismatched (the chart refuses to render rather than producing a
  non-functional exporter). The same aggregator also rejects
  `tls.enabled: true` without a configured cert source.
- `sitesEnabled.status.listen` default changed from `127.0.0.1` to `0.0.0.0`
  so the standalone metrics exporter pod can reach the status virtual
  server through the cluster Service. NetworkPolicy locks down who can
  hit the port either way — only RADIUS clients and the metrics exporter
  pod are allowed.
- `service.ports.status` is now published on the main FreeRADIUS Service
  whenever `sitesEnabled.status.enabled` is true (was previously only
  bound on the pod's loopback interface, unreachable from other pods).
  `service.nodePorts.status` added for completeness.
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

### Changed

- **values.yaml**: complete reorganization with explicit `## ====` section
  banners. Order: Global → Common → Image → Configuration → Authentication →
  Deployment → Pod → Container → Persistence → Metrics → Traffic Exposure →
  TLS → RBAC → Gateway → Database.
- **Template subdirectory layout** lowercased to match the adminer chart:
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

### Removed (BREAKING — see Upgrading)

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
- `sitesEnabled.tls.enabled` (moved) — RADSEC enablement is now driven by
  the top-level `tls.enabled` flag. `sitesEnabled.tls.{cipher,privateKeyPassword}`
  remain.
- `metrics.prometheusRules` (renamed, plural) — renamed to
  `metrics.prometheusRule.*` (singular) to match the upstream
  Prometheus Operator CRD naming. New keys:
  `metrics.prometheusRule.{enabled,namespace,additionalLabels,groups,rules}`
  — `groups` takes a verbatim `spec.groups` list and `rules` falls back to
  a single chart-fullname group when only flat rules are provided.
- `auth.{createClientUser,clientUser,clientUserPassword}` (unused — the
  `clients.conf` rendering doesn't read these).

### Deprecated

- `tls.existingSecretName` — use `tls.certificatesSecret`. The
  `freeradius.tls.secretName` helper falls back to `existingSecretName` so
  existing overrides keep working until the next major bump.
- `modsEnabled.sql.tls.existingTlsSecret` — use
  `modsEnabled.sql.tls.certificatesSecret`. Same fallback pattern as above.

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
- configmap/sites-enabled.yaml: gated the `tls` site on
  `sitesEnabled.tls.enabled` even though the rest of the chart drives RADSEC
  off `tls.enabled` (the in-pod TLS flag). Now correctly gated on
  `tls.enabled`.
- **rlm_sql schema not loaded into the database**
  ([#67](https://github.com/startechnica/apps/issues/67)). `files/schema/mysql.sql`
  shipped with the chart but no template wired it into MariaDB or any other
  database. Now loaded by a new `db-bootstrap` init container on the
  FreeRADIUS pod (gated on `modsEnabled.sql.enabled` and
  `database.bootstrap.enabled`, default true). The schema is rendered into
  a chart-managed `<fullname>-db-schema` ConfigMap by
  `templates/configmap/db-schema.yaml`, then mounted at `/schema/schema.sql`
  in the init container which waits for the DB to accept TCP connections
  (`database.bootstrap.waitTimeout`, default 120s) before applying the
  schema via the dialect-appropriate CLI (`mysql` or `psql`). Idempotent —
  every shipped schema uses `CREATE TABLE IF NOT EXISTS`, so restarts are
  no-ops. Works with both `mariadb.enabled: true` and
  `externalDatabase.*`; skipped when `dialect: sqlite` (rlm_sql's own
  `bootstrap = "${modconfdir}/sql/main/sqlite/schema.sql"` directive loads
  the schema at first connect — the upstream image already ships that
  file). The chart now ships dialect-specific schema files at
  `files/schema/{mysql,postgresql,sqlite}.sql` covering every dialect
  `modsEnabled.sql.dialect` accepts. PostgreSQL uses native `inet` / `cidr`
  types and partial indexes; SQLite uses `INTEGER PRIMARY KEY AUTOINCREMENT`
  and plain `TEXT` / `DATETIME` columns. The bootstrap-image helper
  auto-swaps `bitnami/mariadb:11` → `bitnami/postgresql:17` when
  `dialect: postgresql` so postgresql users don't need to flip two unrelated
  keys.
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
  for any 0.x override that set those keys.

### Added (companion changes for the two fixes above)

- `database.bootstrap.{enabled,schemaConfigMap,image,resources,waitTimeout}`
  values block. The default image is `docker.io/bitnami/mariadb:11`; the
  `freeradius.database.bootstrap.image` helper auto-swaps to
  `bitnami/postgresql:17` when `modsEnabled.sql.dialect: postgresql` AND
  the repo is still on the chart default. Explicit user overrides always win.
- `freeradius.database.schemaConfigMapName`, `freeradius.database.bootstrap.image`,
  `freeradius.database.bootstrap.cmd` helpers. The `cmd` helper returns the
  dialect-appropriate `mysql`/`psql` invocation, or an empty string for
  sqlite (which is the sentinel that tells the Deployment to skip the init
  container and ConfigMap altogether).
- `templates/configmap/configuration.yaml` and
  `templates/configmap/db-schema.yaml`.
- `files/schema/postgresql.sql` — PostgreSQL-dialect rlm_sql schema mirroring
  the table set in `files/schema/mysql.sql`, with PostgreSQL-native types
  (`bigserial`, `inet`, `cidr`, `timestamp with time zone`) and partial
  indexes on optional accounting columns. Loaded by the `db-bootstrap` init
  container described above.
- `files/schema/sqlite.sql` — SQLite-dialect rlm_sql schema covering the
  third dialect listed in `modsEnabled.sql.dialect`. Not loaded by the
  `db-bootstrap` init container (SQLite is a local file, not a network
  service) — instead, rlm_sql's own `bootstrap` directive at
  `files/mods-available/sql` line 81 loads the schema on first open of an
  empty database file. Shipped for users who want to override the upstream
  image's bundled SQLite schema; wire it in via
  `database.bootstrap.schemaConfigMap` + `extraVolumes` / `extraVolumeMounts`
  mounting over `/etc/freeradius/mods-config/sql/main/sqlite/schema.sql`.

## 1.0.3 (2026-05-02)

- Pre-1.0.0 incremental release. Superseded by 1.0.0 above. (Yes, the
  version number was bumped past 1.0.0 during pre-modernization work —
  apologies for the confusion. The current 1.0.0 release notes above are
  authoritative.)

## 0.x

Older releases pre-dating the modernization. See `git log` for details.
