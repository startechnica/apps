# Changelog

All notable changes to the **Netbox** chart are documented in this file. The
format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [5.1.0] - 2026-06-03

### Added
- `tls.certManager.{issuerRef.kind,issuerRef.name,tlsAcme}` — canonical
  cert-manager Issuer reference for the chart-rendered Certificate. The
  Certificate now **auto-renders** whenever (`tls.enabled` OR
  `ingress.tls`) AND the cert-manager API is detected on the cluster AND
  `tls.certificatesSecret` is empty (fixes
  [#79](https://github.com/startechnica/apps/issues/79) — external-controller
  users opt out by setting `tls.certificatesSecret`).
- `gateway.tls.{enabled,existingSecret,selfSigned,secrets}` — gateway-side
  TLS material, independent of the in-pod `tls.*` block. Listener
  `credentialName` and chart-managed Secret name resolve through the new
  `netbox.gateway.tlsSecretName` helper (three-step chain: `existingSecret`
  → first user-supplied `secrets[].name` → `<ingress.hostname>-tls`).
- `gateway.serviceEntry.{enabled,hosts,location,resolution,ports,exportTo}`
  — explicit value-driven ServiceEntry config; previously the template
  hardcoded `netbox.dev`, `github.com`, `api.github.com` (now removed).
- `externalDatabase.passwordless: false` — skip the `db_password` projected
  secret item and `DATABASE["PASSWORD"]` config loading for passwordless
  external auth flows (e.g. CloudSQL IAM)
  ([#63](https://github.com/startechnica/apps/issues/63)).
- Inline documentation in `values.yaml` describing how `externalRedis`,
  `tasksRedis`, and `cachingRedis` interact: `externalRedis.*` fans out to
  both components by default; per-component `tasksRedis.*` /
  `cachingRedis.*` overrides take precedence and enable pointing each at
  its own backend ([#65](https://github.com/startechnica/apps/issues/65)).
- `remoteAuth.keycloak.*` chart-managed Keycloak convenience block —
  values `enabled`, `clientId`, `clientSecret`, `realmUrl`, `publicKey`,
  `groupSource` (client/realm/groups), `isStaffRole`, `isSuperuserRole`,
  `extraGroupMappings`, `scopes`, `pipelines`,
  `existingPipelineConfigMap{,Key}`. Renders shared
  `<release>-remoteauth` Secret carrying `oidc-keycloak.yaml` (with all
  `SOCIAL_AUTH_KEYCLOAK_*` settings including the pipeline list) plus
  `<release>-keycloak-pipeline` ConfigMap carrying a templated
  `keycloak_pipeline_roles.py`. Mounted on the server pod only
  (`/run/config/extra/remote-auth/` + `/opt/netbox/netbox/netbox/`).
  Worker/CronJob skip the mounts — social-auth runs only at web login.
  Naming reserves room for sibling providers (`oidc-azuread.yaml`,
  `oidc-google.yaml`, `oidc-okta.yaml`, `oidc-oidc.yaml`).
- Worker `Deployment` renders previously-declared-but-dead keys:
  `dnsConfig`, `dnsPolicy`, `enableServiceLinks`, `schedulerName`,
  `topologySpreadConstraints`, `revisionHistoryLimit`, `minReadySeconds`,
  `shareProcessNamespace`, `lifecycleHooks`, and
  `startupProbe`/`livenessProbe`/`readinessProbe` (default
  `exec: pgrep -f "manage.py rqworker"`) plus `custom*` overrides.
- `housekeeping.containerSecurityContext.readOnlyRootFilesystem: true`
  default — matches server/worker.
- New helpers: `netbox.socialAuth.{secretName,secretVolume,secretVolumeMount,enabled}`,
  `netbox.keycloak.{pipelineConfigMapName,pipelineVolume,pipelineVolumeMount}`,
  `netbox.redis.mountSecret`, `netbox.initdbScriptsCM` (the last was
  referenced from `Deployment.yaml:385` but never defined — would crash
  `helm template` for anyone setting `initdbScripts`/`initdbScriptsConfigMap`).
- helm-unittest grew from 10 suites / 91 tests → 12 suites / 137 tests.
  New `tests/Secret_test.yaml` and `tests/ConfigMap_test.yaml`; regression
  tests for every bug fixed below (CronJob housekeeping-scope, worker
  HPA gate, worker probe wiring, external-redis Secret gate, HTTPRoute
  modern v1 extraPaths, etc.).
- `docs/auth.md` expanded substantially: chart-managed Keycloak section
  (`remoteAuth.keycloak.*` walkthrough with the `groupSource` mapper
  table, `pipelines` override, `existingPipelineConfigMap` escape hatch),
  Azure AD / Entra ID example with GUID-to-name mapping, Google Workspace,
  Okta with claim filter notes, generic OIDC, "How group sync works"
  semantics table (`defaultGroups` vs. `groupSyncEnabled`), and a
  Troubleshooting section covering 403-on-login, group-sync no-shows,
  redirect_uri reference, token-refresh, LDAP bind-password rotation.
- `worker.revisionHistoryLimit` value declared (empty string by default;
  renders `spec.revisionHistoryLimit` when set).
- Chart annotations `artifacthub.io/changes` and `artifacthub.io/links`
  for ArtifactHub release page.
- `docs/plugins.md` — end-to-end recipe for installing NetBox plugins
  (derived image overlaying `pip install` on top of
  `netboxcommunity/netbox`, pointing the three `image:` blocks at it,
  enabling via `plugins:` / `pluginsConfig:`, optional post-install
  migration Job, troubleshooting). Addresses
  [#62](https://github.com/startechnica/apps/issues/62).

### Deprecated
- `tls.autoGenerated` — no longer consulted. When `tls.enabled: true`, the
  chart auto-generates TLS material implicitly (cert-manager when detected,
  otherwise an in-template `genCA`). Suppress by setting
  `tls.certificatesSecret`. Slated for removal in 6.0.0.
- `tls.certManager.create` — no longer consulted. cert-manager is
  auto-detected; pre-create the Secret + set `tls.certificatesSecret` to
  opt out. Slated for removal in 6.0.0.
- `tls.autoGenerator.certManager.{enabled,issuerKind,issuerName}` — no
  longer consulted. Use `tls.certManager.issuerRef.{kind,name}` instead.
  Slated for removal in 6.0.0.

### Changed
- **Bundled subchart bumps** (chart-version, NOT app-version): postgresql
  `13.x.x` → `18.7.0`, redis `19.x.x` → `27.0.0`. Image majors change too
  (PostgreSQL → 17, Redis → 8) — review your data path before upgrading.
- All template helper references migrated from the bitnami `common` chart
  to `st-common` (`include "common.X"` → `include "st-common.X"`). The
  `bitnami common` and `startechnica-common` aliases were dropped; the
  remaining dependency is now `st-common 0.1.21` directly. Per-resource
  capability helpers (`certmanagerCertificate`, `istioGateway`,
  `istioVirtualService`, `istioServiceEntry`,
  `coreosMonitoringServiceMonitor`, `coreosMonitoringPrometheusRule`,
  `networkingGatewayHTTPRoute`) are used instead of the bitnami umbrella
  helpers.
- `Chart.lock` is now committed (rather than gitignored) and Bitnami deps
  are pinned to **exact** versions, so ArgoCD's `helm dependency build`
  works against the deprecated `bitnamicharts/*` registry without hitting
  the broken Docker Hub `tags/list` endpoint.
- All chart helper files moved into `templates/helpers/` subdirectory
  (`_helpers.tpl`, `_images.tpl`, `_init_helpers.tpl`, `_git_helpers.tpl`).
- `housekeeping.image.*` `@param` doc-lines corrected to point at the
  right key paths (were previously labeled `image.*`).
- `Chart.yaml` top-level keys sorted ascending.
- **Service ports changed**: `service.ports.http` 80 → **8080**,
  `service.ports.https` 443 → **8443**, legacy `service.port` 80 → 8080.
  Service ports now match the in-pod container port — Ingress/Gateway
  listeners still terminate on 80/443 externally. Clients hitting the
  netbox Service directly (port-forwards, peer Services, NodePort
  listeners) need to update.
- **Image coordinates moved from `global.image*` to per-component
  blocks**: `image:`, `worker.image:`, and `housekeeping.image:` now
  each carry the full `registry`/`repository`/`tag`; `global.image*`
  default to empty strings. Render output is byte-identical thanks to
  the [#83](https://github.com/startechnica/apps/issues/83) precedence
  helper.
- **Worker probes now actually render** — `worker.livenessProbe.enabled`
  and `worker.readinessProbe.enabled` were `true` in values.yaml for
  several releases but never rendered. Default check is
  `exec: pgrep -f "manage.py rqworker"` (works on the
  `netboxcommunity/netbox` image; stripped custom images without
  `procps` need `customLivenessProbe` / `customReadinessProbe` or
  `enabled: false`).
- **Redis subchart NetworkPolicy tightened** — `redis.networkPolicy.allowExternal: false`
  (was Bitnami default `true`) plus an `extraIngress` rule scoped to
  pods labeled `app.kubernetes.io/part-of=netbox` AND
  `app.kubernetes.io/component in (server, worker, housekeeping)`. Other
  in-cluster clients (shared monitoring, mirrors) must opt in via
  `redis.networkPolicy.ingressNSMatchLabels` / `extraIngress` or set
  `allowExternal: true`.
- **HTTPRoute backendRefs emit explicit `group: ""` / `kind: Service`** —
  spec defaults the Kubernetes API server fills in on POST. Rendered
  output now matches what `kubectl get httproute -o yaml` returns. No
  behavior change.
- Chart maintainer renamed `Firmansyah Nainggolan` → `firmansyahn` to
  satisfy `ct lint --validate-maintainers`.
- README `Breaking Changes` section now covers every minor/patch from
  5.0.5 → 5.0.6 → 5.0.7 → 5.0.8 → 5.0.9 → 5.0.10 → 5.1.0, grouped
  under 5.0.10 → 5.1.0 as **A. Subchart and helper migration** vs.
  **B. Default flips and latent-bug fixes**.

### Fixed
- `_images.tpl` — `default A B` arg order was reversed; `.Values.image.*`
  per-component overrides were silently ignored because `.Values.global.*`
  always won ([#83](https://github.com/startechnica/apps/issues/83)).
  Applies to `netbox.images.image`, `netbox.image`, `netbox.worker.image`,
  `netbox.housekeeping.image`. Side-effect resolves
  [#64](https://github.com/startechnica/apps/issues/64) — `housekeeping.image.*`
  per-component overrides now actually take effect.
- `netbox.redis.secretName` + `netbox.databaseSecretName` helpers — the
  fallback `default <fullname>-external-redis .Values.existingSecretName`
  conflated the top-level Netbox secret with the external-redis/-db secret;
  setting `existingSecretName` on the main Netbox release silently
  redirected the redis/db mount to the wrong Secret
  ([#61](https://github.com/startechnica/apps/issues/61)).
- `istio/VirtualService.yaml`, `istio/Gateway.yaml`, `istio/ServiceEntry.yaml`
  — capability-version guards now check `($apiVer && ne $apiVer "false" &&
  ne $apiVer "<no value>")`, no longer rendering `apiVersion: false` when
  the cluster lacks the CRD ([#56](https://github.com/startechnica/apps/issues/56)).
- `metrics/ServiceMonitor.yaml` + `worker/ServiceMonitor.yaml` — parse
  error from `merge.Values...` (missing space, calling Sprig `merge` as a
  method) replaced with `st-common.tplvalues.merge`.
- `istio/ServiceEntry.yaml` no longer hardcodes `netbox.dev`, `github.com`,
  `api.github.com`. Hosts come from `gateway.serviceEntry.hosts`, defaulted
  to `[]` (the resource is gated on `gateway.serviceEntry.enabled` so an
  empty list is never rendered).
- `gatewayApi/HTTPRoute.yaml` — capability helper changed from generic
  `networkingGateway` to resource-specific `networkingGatewayHTTPRoute`.
- **CronJob housekeeping pod scope** — silently inherited the server
  pod's `containerSecurityContext`, `extraEnvVarsCM` / `extraEnvVarsSecret`,
  `sidecars`, `extraVolumes`, and `args` fallback. Now honors
  `housekeeping.*` scoped keys (which were declared in `values.yaml`
  all along). CronJob template also missed the `imagePullPolicy`
  line and now renders it from `housekeeping.image.pullPolicy`.
  Defaults to `housekeeping.containerSecurityContext.readOnlyRootFilesystem: true`.
- **Worker `replicaCount` was gated on `.Values.autoscaling.enabled`**
  (the server-side HPA flag) instead of `worker.autoscaling.enabled`.
  Enabling the server HPA silently stripped the worker's replicas. Fixed.
- **`Secret/netbox.yaml` LDAP bind-password key fix** — under
  `remoteAuth.backends: [netbox.authentication.LDAPBackend]`, the chart
  was writing `remoteAuth.ldap.bindPassword` to a data key named
  `superuser_password` (via `netbox.superuser.secretPasswordKey`),
  clobbering the actual superuser password. Now uses
  `netbox.remoteAuth.ldap.secretBindPasswordKey` (→ `ldap_bind_password`)
  and gates on `remoteAuth.ldap.existingSecretName`. **If you ran
  5.0.x with LDAPBackend enabled, rotate the bind password after
  upgrade** — the old shared key has likely been read by both code paths.
- **External-redis Secret no longer renders empty** — previously the
  chart always rendered `<release>-external-redis` when the redis
  subchart was disabled and no `existingSecretName` was set, even with
  all `externalRedis.* / tasksRedis.* / cachingRedis.*` left empty. The
  Secret now only renders when at least one of `externalRedis.host`,
  `externalRedis.password`, `tasksRedis.password`, or
  `cachingRedis.password` is set; the projected-Secret mount in all four
  pod templates is gated on the same condition (no more
  `ContainerCreating: secret not found` for empty redis configurations).
- **`worker.extraVolumes` and `housekeeping.extraVolumes` are now
  respected** — the worker `Deployment`, worker `Job`, and housekeeping
  `CronJob` were reading the top-level `.Values.extraVolumes`. Now read
  their component-scoped keys (matching how `extraVolumeMounts` already
  worked). Builds on the indentation fix from
  [#52](https://github.com/startechnica/apps/issues/52) (PR #53) by
  routing `housekeeping.extraVolumes` to the right key as well.
- Possibly addresses [#58](https://github.com/startechnica/apps/issues/58)
  ("5.0.6 broken" — `yaml.scanner.ScannerError` at
  `/run/config/netbox/netbox.yaml:119`). The condition is no longer
  reproducible on a default 5.1.0 render — likely fixed by intervening
  `ConfigMap/netbox.yaml` cleanups. Asking the reporter to retest.
- **HTTPRoute `ingress.extraPaths` handles modern Ingress v1 shape** —
  the template previously crashed with a nil-pointer dereference on
  `.backend.serviceName` when the user supplied the v1
  `backend.service.{name,port.number}` form. Both shapes are now
  translated; entries that only carry `backend.service.port.name`
  (no resolvable port number) are skipped — HTTPRoute backendRefs
  require a numeric port.

## [5.0.10] - 2024-06-13

### Fixed
- Add missing parameter on external-db secret
  ([#71](https://github.com/startechnica/apps/issues/71)).

## [5.0.9] - 2024-05-08

### Added
- `censusReporting` toggle for Netbox telemetry opt-in.

### Changed
- Update Netbox to **v3.7.8** (image `netboxcommunity/netbox:v3.7.8-2.8.0`,
  Netbox Docker **2.8.0**).
- Move image resolution to a local `netbox.images.*` helper (drop reliance on
  the shared `common.images.image` / `common.images.version` helpers).
- Consolidate image values: drop separate `worker.image` /
  `housekeeping.image` / server `image` blocks in favor of a single image
  source.
- Document breaking change note around the image helper migration.

### Fixed
- Add missing import when `allowedHostsIncludesPodIp` is true
  ([#68](https://github.com/startechnica/apps/pull/68)).
- Worker `ServiceMonitor` selector / labels.
- Surface a missing `global.imageRegistry` fallback when the local image
  helper is in use.
- License wording in chart metadata.

## [5.0.8] - 2024-04-24

### Changed
- Bump `bitnami/redis` subchart dependency to **19.x.x**.

### Fixed
- External Redis secret name resolution
  ([#61](https://github.com/startechnica/apps/issues/61)).
- Task-queue and cache `secretPasswordKey` handling for external Redis.
- `init-redisWait` container wiring when Redis auth is enabled.
- Database password / `passwordSecretKey` lookup when an existing secret is
  supplied.
- Auto-generation of the external Redis secret.

### Added
- `redis.password` helper to centralize password resolution across server,
  worker and housekeeping pods.

## [5.0.7] - 2024-03-12

### Changed
- Bump appVersion to **v3.7.3** (image
  `netboxcommunity/netbox:v3.7.3-2.8.0`).

### Added
- LDAP `bindPassword` helper for cleaner secret wiring.
- Reports / scripts / media volume helpers (`netbox.reports.volumes`,
  scripts PVC helper) so all three deployments mount the same sources.
- Extra documentation tip about Keycloak integration.
- CI pipeline scaffolding for the chart.

### Fixed
- Housekeeping `nodeSelector` indentation
  ([#59](https://github.com/startechnica/apps/issues/59)).
- `ServiceEntry` rendering for port 443.
- PVC helper typos in the scripts / reports volume rendering.

## [5.0.6] - 2024-02-17

### Added
- Git clone / sync init-container skeleton on the worker (pulls reports and
  scripts from a remote repo at start-up).
- Reports and scripts PVC helpers; git-backed volume mount.
- `SKIP_SUPERUSER` env-var to disable the bootstrap superuser creation.
- `ipFamilyPolicy` and `externalIPs` support on the Netbox Service.
- Gateway API selector and gateway-capabilities conditionals.
- NetworkPolicy for worker pods plus per-pod-label scoping.
- `resourcesPreset` shorthand for sizing presets.
- `waitRedis` helper, reused by the worker deployment.
- Plugins parameters block.

### Changed
- Move `secretKey` resolution into a dedicated helper.
- Drop the Keycloak backend wiring (moved out of the chart for now).
- Disable worker metrics emission by default; move metrics volume +
  volumeMounts to values.
- Normalize line endings to LF and clean up CRLF leftovers.
- Move ConfigMap name resolution to a helper; tidy redis and database
  helpers.

### Removed
- `values-test.yaml` fixtures from the chart tree.
- `git` binary from the server deployment (now only on the worker).

### Fixed
- `ServiceEntry` rendering and worker NetworkPolicy selector.
- Media-PVC name; `redisWait` container ordering.
- `git-helper` regression after the deployment revert.
- Worker `extraPorts` propagation and metrics-port restoration.

## [5.0.5] - 2024-02-07

### Changed
- Update base image to **v3.7.2** (`appVersion: v3.7.2`).
- Migrate `extraConfig` handling to the `tplrender` pattern.

### Added
- `extraDeploy` block for shipping arbitrary user manifests with the
  release.
- `extraConfig.volumeMounts` / `extraVolumes` plumbing on all pods.

### Fixed
- `extraConfig` helper end-tag and volume-mount indentation.

## [5.0.4] - 2024-02-03

### Added
- Gateway API support (`gatewayApi`) with optional extra hosts and TLS.
- HorizontalPodAutoscaler for the Netbox server.
- Default resources for the Netbox server pod; raised
  `initialDelaySeconds`.
- Housekeeping `interval` and worker `max-jobs` knobs.
- Superuser API-token support; e-mail default password handling.
- Worker NetworkPolicy `podLabel` scoping.
- Metrics volume scaffold on the worker.

### Changed
- Switch the worker from a long-running Deployment to a Job (then reverted
  back to Deployment within the same release after testing — final form is
  Deployment with a configurable `command`).
- Tidy up the housekeeping CronJob (cleanup of values, extra-vars mount,
  PVC wiring).

### Fixed
- CronJob PVC name and media volume mount.
- `taskRedis` password resolution and helper context.
- Email secret generation; gateway end-closure rendering; HPA template.
- Server and worker `Service` rendering; external database `username`
  resolution.

## [5.0.3] - 2024-02-02

### Added
- Keycloak entry in `remoteAuth.backends`.
- HorizontalPodAutoscaler scaffold.
- Metrics `Service`, `ServiceMonitor` and metrics labels.
- Housekeeping `extraVolumes` and `extraEnvVars`.
- TLS secret support.

### Fixed
- Server `Deployment` rollback / restore (deployment manifest stabilization).
- `remoteAuth.backends` typo handling and `has` conditional in volume /
  volumeMount blocks.
- ServiceMonitor selector; Secret cleanup; helper end-tag bugs.
- NetworkPolicy now allows egress to Redis and the database.

### Changed
- Tidy up housekeeping manifest; update README.

## [5.0.2] - 2024-01-31

### Added
- Gateway API resources alongside the legacy Ingress.
- `NetworkPolicy` for server / worker / housekeeping.
- Superuser helper.
- env-vars `ConfigMap` rendered from values.
- Redis-wait init container; `init container` plumbing throughout.
- Database helper (`netbox.database.*`) and Postgres-port helper.
- Deployment tuning knobs (sidecars, podSecurityContext, extraEnvVars,
  annotations / labels, reports & scripts volume paths).

### Removed
- Obsolete top-level `ingress` block (superseded by Gateway API).
- Postgres `user` parameter (now derived from the database helper).

### Changed
- Worker deployment manifest reorganized; Redis architecture defaults to
  `standalone` with auth enabled.
- Switch to the env-vars ConfigMap + `envFrom` pattern.
- Enable Postgres persistence by default; disable Redis persistence by
  default.

### Fixed
- Numerous Deployment indentation / template-rendering bugs surfaced while
  reorganizing the worker and server pods.
- Redis password / hostname / fullname / port helpers; database password
  resolution.
- Redis ServiceAccount and worker `ConfigMap` / `Secret` template paths.

## [5.0.1] - 2024-01-29

### Added
- Additional manifest scaffolding (`additionalManifests`-style values).
- PodDisruptionBudget and autoscaling primitives.
- `scriptsPersistence` block.
- Redis `ServiceAccount`.

### Changed
- Bump appVersion to **v3.7.1**.
- Sweep through default values; retouch the README.
- Pin `st-common` dependency version.

### Removed
- Committed `Chart.lock` (now generated on demand).

## [5.0.0] - 2024-01-29

### Added
- Initial release of the Startechnica Netbox chart, forked from the
  upstream [bootc/netbox-chart](https://github.com/bootc/netbox-chart) and
  rebased onto the `st-common` helper library.
- `appVersion: v3.6.4` against Netbox **3.6.4**.
- PostgreSQL dependency (`bitnamicharts/postgresql` 13.x) and Redis
  dependency (`bitnamicharts/redis` 18.x) gated by
  `postgresql.enabled` / `redis.enabled`.
- `kubeVersion: ">=1.25.0"`.

[5.1.0]: https://github.com/startechnica/apps/compare/netbox-5.0.10...netbox-5.1.0
[5.0.10]: https://github.com/startechnica/apps/compare/netbox-5.0.9...netbox-5.0.10
[5.0.9]: https://github.com/startechnica/apps/compare/netbox-5.0.8...netbox-5.0.9
[5.0.8]: https://github.com/startechnica/apps/compare/netbox-5.0.7...netbox-5.0.8
[5.0.7]: https://github.com/startechnica/apps/compare/netbox-5.0.6...netbox-5.0.7
[5.0.6]: https://github.com/startechnica/apps/compare/netbox-5.0.5...netbox-5.0.6
[5.0.5]: https://github.com/startechnica/apps/compare/netbox-5.0.4...netbox-5.0.5
[5.0.4]: https://github.com/startechnica/apps/compare/netbox-5.0.3...netbox-5.0.4
[5.0.3]: https://github.com/startechnica/apps/compare/netbox-5.0.2...netbox-5.0.3
[5.0.2]: https://github.com/startechnica/apps/compare/netbox-5.0.1...netbox-5.0.2
[5.0.1]: https://github.com/startechnica/apps/compare/netbox-5.0.0...netbox-5.0.1
[5.0.0]: https://github.com/startechnica/apps/releases/tag/netbox-5.0.0
