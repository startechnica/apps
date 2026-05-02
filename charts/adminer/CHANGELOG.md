# Changelog

## 1.0.1 (2026-05-02)

Documentation and validation polish on top of 1.0.0. No template or values
default changes — installs from 1.0.0 upgrade in place with no action.

### Added

- `values.schema.json` — JSON Schema generated from `values.yaml` defaults. Permissive (no `required`, no `additionalProperties: false`); catches gross type mistakes (`replicaCount: "two"`, `service.type: 8080`) at `helm install`/`upgrade` time. Null defaults map to `{}` (any), so existing overrides continue to validate.
- `README.md`: Artifact Hub repository badge plus static `Version` / `Type` / `AppVersion` shields under the title.

### Fixed

- `values.yaml`: duplicate `metrics.serviceMonitor.endpoints` key under `metrics.serviceMonitor`. Helm's YAML loader silently kept the last value (`endpoints: []`) and discarded the shorthand `endpoints: [{path: /metrics}]` that the section above intended. Behavior of the rendered ServiceMonitor is unchanged because `templates/ServiceMonitor.yaml` already falls back to the synthetic single-endpoint when `endpoints` is empty — but stricter YAML loaders (yaml.v3, js-yaml, kubeval pipelines) rejected the file outright.

## 1.0.0 (2026-05-02)

Major release. Substantial restructuring of TLS / cert-manager values, plus a
brand-new HPA template, env-vars ConfigMap, and full Gateway API resource set
(Gateway, HTTPRoute, ReferenceGrant, ListenerSet). **See "Upgrading from 0.x"
in the README for the migration steps your `values.yaml` needs.**

### Added

- `templates/HorizontalPodAutoscaler.yaml` and `horizontalPodAutoscaler.{enabled,minReplicas,maxReplicas,targetCPU,targetMemory,metrics}` values block. Bitnami-style `metrics: []` passthrough overrides the CPU/memory shorthand for custom/external metrics.
- `templates/configmap/envvars.yaml` — chart-rendered ConfigMap holding the standard `ADMINER_*` env vars; consumed by the Deployment via `envFrom`. Gated on `not existingConfigmap` so users can bring their own.
- `templates/gateway-api/Gateway.yaml`, `templates/gateway-api/ReferenceGrant.yaml`, `templates/gateway-api/ListenerSet.yaml` — full Gateway API resource set, mirroring `templates/istio/`. ListenerSet handles the v1 / v1alpha1 / `x-k8s.io` API-version drift transparently (`ListenerSet` vs `XListenerSet`).
- `templates/secret/gateway-tls.yaml` and `templates/secret/tls-ca.yaml` — gateway-namespace TLS Secret and a chart-internal CA Secret shared by both ingress and gateway leaf certs. The self-signed CA is recovered via Helm `lookup` on subsequent renders so it persists across upgrades AND across ingress↔gateway path migrations (clients keep trusting).
- `templates/NetworkPolicy.yaml` and `networkPolicy.*` block.
- `tls.certManager.{create,issuerRef,tlsAcme}` — single canonical location for cert-manager-driven TLS issuance, consumed by both ingress and gateway `Certificate` blocks in `templates/Certificate.yaml`.
- `gateway.tls.{enabled,existingSecret,selfSigned,secrets}` — gateway-side TLS knobs that don't require touching `ingress.*`. `gateway.tls.enabled` controls HTTPS listener rendering in both istio and gateway-api Gateway templates.
- `gateway.virtualService.{http,existingVirtualService}` — raw passthrough escape hatches for the istio path.
- `gateway.referenceGrant.{from,to}` — explicit override of the default "HTTPRoute from gateway-namespace → Service in release-namespace" grant.
- `gateway.listenerSet.{enabled,parentRef,listeners}` — attach extra listeners to the parent Gateway.
- `metrics.service.annotations` — Prometheus scrape annotations on the Service for clusters not running the Prometheus Operator.
- `containerSecurityContext.{readOnlyRootFilesystem,allowPrivilegeEscalation,seccompProfile}` — Pod Security Standard "restricted" profile defaults.
- Container parameters: `command`, `args`, `lifecycleHooks`, `extraVolumes`, `extraVolumeMounts`, `sidecars`.
- `config.{defaultServer,defaultDriver,defaultUsername,defaultPassword,defaultDatabase,autoLogin,permanentLogin}` for Adminer login defaults / login-servers plugin compatibility.
- `config.plugins` now accepts a YAML list (preferred) in addition to the legacy space-separated string. New `adminer.config.plugins` helper joins lists for `ADMINER_PLUGINS`.
- `gateway.tlsRoute.parentRefs` — explicit `parentRefs` override for `templates/gateway-api/TLSRoute.yaml`, mirroring `gateway.httpRoute.parentRefs`. Same shape, same defaulting rules.
- `persistence.{enabled,existingClaim,storageClass,accessModes,size,mountPath,subPath,annotations,selector,dataSource}` — values block consumed by `templates/PersistentVolumeClaim.yaml` (the PVC template existed but had no matching values keys, so it silently never rendered). The Deployment now auto-mounts the PVC at `persistence.mountPath` (default `/data`) with optional `subPath`; resolves to `persistence.existingClaim` when set, otherwise `<fullname>`.
- `adminer.gateway.routeParentRefs` helper — single source of truth for HTTPRoute and TLSRoute `parentRefs` defaulting. Picks the chart-rendered ListenerSet when one is rendered (group/kind track the same v1 / v1alpha1 / `x-k8s.io` (`XListenerSet`) fallback as `templates/gateway-api/ListenerSet.yaml`); falls back to the Gateway otherwise. Prevents the two route templates from drifting on group/kind/name.

### Changed

- **values.yaml**: complete reorganization with explicit `## ====` section banners. Order: Global → Common → Image → Configuration → Authentication → Deployment → Pod → Container → Traffic Exposure → TLS → RBAC → Gateway → Misc.
- **`templates/HTTPRoute.yaml` → `templates/gateway-api/HTTPRoute.yaml`** for symmetry with `templates/istio/`.
- **Deployment env injection**: the inline `env:` block no longer carries `ADMINER_PLUGINS` / `_DESIGN` / `_DEFAULT_SERVER`. Those flow through the env-vars ConfigMap via `envFrom`. Inline `env:` only renders when `extraEnvVars` is non-empty.
- **Deployment pod-template annotations**: `commonAnnotations` is now propagated to pods (was only `podAnnotations`). Checksum annotations are now individually gated on whether the chart actually manages each source — when the user supplies `existingSecret` or `existingConfigmap`, the corresponding checksum drops out instead of constantly hashing the empty string.
- **`Certificate.yaml` gateway-namespace block** uses `st-common.gateway.namespace` helper with proper fallback (was rendering invalid `namespace: ""` when `gateway.gateway.namespace` was unset).
- **`istio/Gateway.yaml` + `gateway-api/Gateway.yaml`**: HTTPS listener rendering and `hosts:` lists now driven by `gateway.{tls.enabled,hostnames}` instead of `ingress.{tls,hostname,extraHosts}`. Pure-gateway users no longer need to set ingress keys.
- **`istio/VirtualService.yaml`**: dropped all `ingress.*` references; routes derived from `gateway.hostnames` / `service.ports.*` / `gateway.clusterDomain` (with root-`clusterDomain` fallback). The `tls:` block is now auto-derived from `tls.enabled` (SNI passthrough to the backend's TLS port) — no longer requires hand-authored SNI rules.
- **`adminer.gateway.tlsSecretName` helper** consolidates two former duplicates (`istioCertificateSecret`, `istioCertificateSecret2`) and is now used by both Gateway templates and the gateway-tls Secret — single source of truth so listener and Secret can never drift apart.
- **NOTES.txt** rewritten — namespace placeholders use `st-common.names.namespace`, ClusterIP selector uses `.Chart.Name`, port-forward uses `service.ports.http` / `containerPorts.http`, and a new branch prints the gateway URL when `gateway.enabled`.
- **HTTPRoute & TLSRoute `parentRefs` default** (BREAKING — see Upgrading): when no explicit per-route `parentRefs` is set AND `gateway.listenerSet.enabled` + `gateway.listenerSet.listeners` are both set AND the cluster supports a ListenerSet API, both routes now attach to the chart-rendered ListenerSet instead of the Gateway. This is the canonical Gateway API attachment pattern (the ListenerSet's listeners only accept routes that target it). Explicit `parentRefs` continue to win, so users with custom values are unaffected.

### Removed (BREAKING — see Upgrading)

- `ingress.certManager.{create,issuerRef,tlsAcme}` — moved to `tls.certManager.*`.
- `gateway.tls.certManager.{create,issuerRef}` — moved to `tls.certManager.*`.
- `istio.certificate.existingSecret` (and the entire top-level `istio:` block) — moved to `gateway.tls.existingSecret`.
- `gateway.virtualService.tls` — VirtualService SNI passthrough is now auto-derived from `tls.enabled` + `gateway.hostnames`.

### Deprecated

- `config.externalserver` — use `config.defaultServer`. The `adminer.config.defaultServer` helper falls back to `externalserver` so existing overrides keep working until the next major bump.

### Fixed

- NOTES.txt: every `--namespace` placeholder used `st-common.labels.standard` (a labels map), not `st-common.names.namespace`. ClusterIP selector used `st-common.names.fullname` instead of `.Chart.Name`. Missing gateway URL branch.
- Certificate.yaml gateway-namespace block: invalid `namespace: ""` when `gateway.gateway.namespace` unset.
- ServiceMonitor.yaml: missing leading `.` on `Values.metrics.enabled` (would crash render); inverted endpoints/path ternary so a user-supplied `endpoints: [...]` correctly wins over the synthetic single-endpoint shorthand.
- istio/Gateway.yaml + istio/VirtualService.yaml: `gateway.hostnames` was iterated as objects with `.name` (rendered empty entries) — now correctly iterates string entries; `gateway.clusterDomain: ""` no longer produces broken `svc.svc.` FQDNs.
- Ingress.yaml: the `kubernetes.io/tls-acme: "true"` annotation is now gated on cert-manager actually being active (was previously emitted whenever any ingress annotation was set).
- Deployment.yaml: removed dead `if not .Values.horizontalPodAutoscaler.enabled` (the values key didn't exist; the gate evaluated to true → `replicas:` always rendered; HPA support was effectively broken).
- `templates/secret/gateway-tls.yaml` and `templates/secret/ingress-tls.yaml` failed to render with `wrong type for value; expected sprig.certificate; got map[string]interface {}` when `selfSigned: true` was set. The `adminer.tls.ca.init` helper was wrapping the CA in a plain `dict`; sprig's `genSignedCert` only accepts a real `sprig.certificate` struct. The helper now stores the struct shape directly — `genCA` result on first install, `buildCustomCert` (which rebuilds the struct from the base64-encoded PEM in the recovered CA Secret) on subsequent renders.

### Earlier in this session (before the 1.0.0 version bump)

The items below also landed during this release cycle — listed separately
because they happened before the cert-manager / TLS consolidation work above.

- Bumped Adminer image and `appVersion` to `5.4.2-standalone` (from `4.8.1`).
- Dropped `bitnami-common` dependency; pinned `st-common` to `0.1.20` (was `*`).
- Migrated all template helpers from `common.*` to `st-common.*`; updated label-block calls to the merged `st-common.labels.standard (dict "customLabels" … "context" $)` signature across `Secret-tls.yaml`, `istio/Gateway.yaml`, `istio/VirtualService.yaml`.
- Apache-2.0 license headers added to all templates; `LICENSE` file added.
- `gateway.*` values restructured:
  - Nested Gateway resource config under `gateway.gateway` (`create`, `name`, `namespace`).
  - Added `hostnames`, `selector`, `serviceAccountName`, `gatewayClassName` defaults.
  - Added `gateway.httpRoute` block (`parentRefs`, `rules`, `matches`, `filters`, `extraBackendRefs`, `extraRules`, `existingHTTPRouteName`).
  - Added `gateway.referenceGrant.enabled` for cross-namespace references.
  - Added `gateway.mesh` and `gateway.waypoint` blocks for Istio Ambient Mesh.
  - Added `gateway.authorizationPolicy` with allow/deny rule scaffolding.
  - **Removed** flat `gateway.{dedicated,gatewayApi,name,namespace}` (consolidated into the nested form above).
- Added `templates/ServiceMonitor.yaml` for Prometheus Operator scraping.
- Added `templates/extraDeploy.yaml` for shipping arbitrary extra manifests. [#100](https://github.com/startechnica/apps/issues/100)
- TLS Secret namespace pointer moved to `gateway.gateway.namespace` (was the now-removed flat `gateway.namespace`).

## 0.1.8

- Fix gateway cluster domain handling.
- Add `nodeAffinityPreset` placeholder.
- Fix reference link.

## 0.1.7

- Add `nodeAffinityPreset` placeholder
- Fix gateway cluster domain handling
- Cleanup VirtualService TLS conditional and TLSRoute

## 0.1.6

- Add Kubernetes Gateway API support (HTTPRoute)
- Fix Gateway templating and `extraHosts` path

## 0.1.5

- Add Istio capabilities helpers and templates (Gateway, VirtualService)
- Fix Ingress and Certificate TLS conditionals

## 0.1.4

- Add `st-common` and `bitnami-common` chart dependencies
- Cleanup Certificate manifest

## 0.1.3

- Bump version to v0.1.3

## 0.1.2

- Bumped version number to 0.1.2

## 0.1.0

- Initial release
