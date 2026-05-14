# Changelog

## 1.1.0 (2026-05-03)

Upstream sync — engine image, CRDs, and chart dependencies updated to match
[`openappsec/open-appsec-injector` 1.1.33](https://charts.openappsec.io) and the
canonical CRD source at
[openappsec/openappsec/config/crds/open-appsec-crd-latest.yaml](https://github.com/openappsec/openappsec/blob/main/config/crds/open-appsec-crd-latest.yaml).

### Changed

- Bumped `appVersion` and `agent.image.tag` from `1.1.32` to `1.1.34`.
- Bumped `postgresql` subchart dependency from `12.2.8` → `17.1.0` (PG 14 → PG 17 default image). Existing data volumes survive a fresh install with the same PVC, but operators upgrading in place should review the [Bitnami postgresql 17.x upgrade notes](https://github.com/bitnami/charts/tree/main/bitnami/postgresql#to-1700) — PG major-version upgrades are not automatic.
- Bumped `st-common` dependency from `0.1.16` → `0.1.20`.

### Added

- *(see also)* — CRDs split into sister chart [`open-appsec-crd`](../open-appsec-crd) 1.0.0, declared as an optional dependency on this chart with the gate `crds.enabled` (default `false`). The previously-embedded `templates/crds/` directory (18 CRDs including the new `practices.openappsec.io`) lives in the sister chart now. Two install modes: bundle by flipping `crds.enabled: true` on the injector, or install `open-appsec-crd` separately and leave `crds.enabled: false` (recommended for production where schema lifecycle is decoupled from application lifecycle). See **Upgrading**.
- `agent.namespaceSelector` / `agent.objectSelector` are now documented in `values.yaml` (`@param` annotations) — same defaults, just explicit documentation for users overriding either selector.
- `spec.properties.name: string` added to every cluster- and namespaced-scope CRD under `openappsec.io` (acp, customresponses, exceptions, logtriggers, sourcesidentifiers, threatpreventionpractices, trustedsources). Matches upstream v1beta2 schemas; lets users carry a human-readable name in policy bundles.
- `logDestination.k8s-service` (boolean) added to `LogTrigger` / `LogTriggerNS` v1beta2.
- Top-level `allowedNamespaces` (default `[]`) to scope both the `openappsec.io` ClusterRoleBinding subject set AND the ingress source set on every component's NetworkPolicy. `[]` = release namespace only (most restrictive; safe default); `["*"]` = legacy cluster-wide `Group system:serviceaccounts` subject + wide-open network ingress; an explicit list like `[istio-ingress, kong]` = per-namespace RBAC + per-namespace network ingress in one knob. Tightens default RBAC + network blast radius — see Upgrading.
- `tls.certManager.{create,issuerRef,duration,renewBefore}` at root + `templates/webhook/{Issuer,Certificate}.yaml` + `cert-manager.io/inject-ca-from` annotation on the `MutatingWebhookConfiguration`. Mirrors the adminer chart's TLS architecture. **Dormant**: the open-appsec container's built-in `secretgen.py` writes its own cert at startup and patches the MWC `caBundle` itself, so chart-side cert provisioning races against the container. Code is in place pending an upstream container toggle (e.g. `SKIP_CERTGEN=1`) to disable the runtime generator; gating flips on at that point.
- `webhook.tls.{certSecretKey,certKeySecretKey,caSecretKey}` (default `tls.crt` / `tls.key` / `ca.crt`) — Secret data-key names. Combined with the existing `certFilename` / `certKeyFilename` / `certCAFilename` (mount-side names), the TLS volume now does explicit `items[]` remapping in the Deployment, so a `kubernetes.io/tls`-shaped Secret (cert-manager output, external-secrets, etc.) is consumed without renaming keys.
- `webhook.metrics.serviceMonitor.path` (default `/metrics`) — surfaces the fallback path used by `templates/webhook/ServiceMonitor.yaml` when `endpoints` is empty. Was previously templated as nil.
- `appsec.tuning.externalDatabase.{host,port,user,database,existingSecret,existingSecretPasswordKey}` — escape hatch for pointing the tuning component at an external PostgreSQL (managed RDS, CloudSQL, on-prem PG) instead of the bundled subchart. Driven by four new helpers (`open-appsec.tuning.{dbHost,dbPort,dbSecretName,dbSecretPasswordKey}`) used by `templates/tuning/Deployment.yaml`. New env `QUERY_DB_PORT` plumbed through to the container.
- `postgresql.enabled` (default `false`) — decouples the bundled postgresql subchart's lifecycle from `appsec.tuning.enabled`. See Upgrading.
- New helper `open-appsec.webhook.tlsSecretName` — single source of truth for the webhook TLS Secret name (BYO `webhook.tls.certificatesSecretName` wins, else `<fullname>-webhook-tls`). Both the Deployment volume and the Certificate's `secretName` reference it.
- `values.yaml` now has 25 `## @section` markers; the README's `## Parameters` block regenerates idempotently via `@bitnami/readme-generator-for-helm` and now contains ~660 documented rows across 18 logical sections (Global, OpenAppSec CRD, Common parameters, Diagnostic mode, Playground, CrowdSec, Custom Fog, Default configurations, Agent, AppSec/Learning/Storage/Tuning, Webhook, Webhook TLS, Metrics, TLS / cert-manager, PostgreSQL subchart).

### Changed

- Webhook `livenessProbe` / `readinessProbe` / `startupProbe` defaults: `port: http` / `scheme: HTTP` → `port: https` / `scheme: HTTPS`. `containerPorts` only declares `https: 443` and `metrics: 7465`, so the prior defaults referenced a port name that didn't exist — enabling any probe would have failed pod scheduling. Probes are still `enabled: false` by default.
- `templates/webhook/MutatingWebhookConfiguration.yaml` — conditional `cert-manager.io/inject-ca-from` annotation + gated `caBundle` rendering, controlled by the new `$injectCA` local. No behavior change when cert-manager mode is off (default).
- `templates/webhook/Deployment.yaml` TLS volume now uses `secret.items[]` to remap Secret data keys to mount-side filenames (see `webhook.tls.{cert,certKey,ca}SecretKey` above). Renders the same way as before for BYO Secrets that follow the `tls.crt`/`tls.key`/`ca.crt` convention.
- `webhook.tls.{certFilename,certKeyFilename,certCAFilename}` are now actually consumed by the Deployment volume mount (`items[].path`). Previously declared in `values.yaml` but never referenced — dead from the chart's inception.

### Removed

- `logDestination.local-tuning` from `LogTrigger` / `LogTriggerNS` v1beta2 — replaced upstream by `k8s-service` (above). **Anyone setting `local-tuning: true` must rename it to `k8s-service: true` before upgrade**, otherwise the CR will be rejected.
- Embedded `templates/crds/` directory (18 CRDs). They now live in the sister chart `open-appsec-crd`, declared as a conditional dependency of this chart. `crds.enabled` (default `false`) bundles the sister chart as a subchart; otherwise the operator installs `open-appsec-crd` separately. The old `crds.keep` key is gone — the sister chart owns that toggle now (defaults to keep-on-uninstall, override via `--set open-appsec-crd.crds.keep=false` on bundled installs). `crds.scope` survives at this chart's level as a runtime hint plumbed to the webhook as `CRDS_SCOPE` env.
- Dead `webhook.{imagePullPolicy, integrationType, namePretty, namespace, rbac.create, rbac.serviceAccount.create, rbac.serviceAccount.name}` values keys (8 in total). None were referenced by any template; the live SA gate is `webhook.serviceAccount.*` and the live pull policy is `webhook.image.pullPolicy`.
- Dead `webhook.objectSelector` legacy block (the new shape lives at `agent.objectSelector` and is the only one any template reads).

### Fixed

- `customresponses.openappsec.io` and `customresponsesns.openappsec.io`: removed a duplicate `required: [mode]` block in v1beta2 spec. Inherited from upstream; benign under Helm's lenient YAML loader (last-wins, identical values), but rejected outright by stricter parsers (yaml.v3, kubeval pipelines).
- `sourcesidentifiers.openappsec.io` and `sourcesidentifiersns.openappsec.io`: removed an orphan `properties:` line followed by a duplicate `type: object` at the v1beta2 `spec` level — same upstream bug class. Runtime-equivalent under lenient parsing, rejected by strict parsers.
- `policiesns.openappsec.io` v1beta2: added the missing `required: [mode, threatPreventionPractices, accessControlPractices]` on `specificRules.items`. Cluster-scoped `policies` already had it; the namespaced twin had silently drifted.
- `templates/webhook/Deployment.yaml`: `schedulerName` gate was reading `.Values.schedulerName` (top-level, undeclared) while the body referenced `.Values.webhook.schedulerName`. The block never rendered. Both now read the same key.
- `templates/helpers/_pvc.tpl`: agent PVC-name helpers now resolve `agent.persistence.config.existingClaim` / `agent.persistence.data.existingClaim` (the actual values shape) instead of the flat `agent.persistence.existingClaim` (which didn't exist). Learning / storage helpers similarly fixed to read `appsec.learning.persistence.*` / `appsec.storage.persistence.*` instead of the wrong-prefix `learning.persistence.*` / `storage.persistence.*`. `existingClaim` overrides now actually take effect.
- ~170 stale or missing `@param` annotations across `values.yaml` (typos like `webhoo.tls.X` → `webhook.tls.X`, `crd.X` → `crds.X`, `crowdSec.api.uri` → `.url`, plus auto-generated annotations for every previously-undocumented key). Ensures `readme-generator-for-helm` validates clean.

### Upgrading from 1.0.x

- **`local-tuning` → `k8s-service` rename** (above): values overrides on the `LogTrigger` CR must be migrated. Same value, new name.
- **RBAC scope tightens**: the default top-level `allowedNamespaces: []` narrows the `openappsec.io` ClusterRoleBinding subject from the cluster-wide `Group system:serviceaccounts` to just SAs in the release namespace. If you inject agent sidecars into pods in other namespaces (the documented Istio/Kong workflow where the chart lives in `open-appsec` but gateways live in `istio-ingress`/`kong`), set `allowedNamespaces: ["*"]` to restore the previous behavior, OR list the specific injection-target namespaces (`allowedNamespaces: [istio-ingress, kong]`). The same value also gates per-component NetworkPolicy ingress when those are enabled.
- **CRDs split into sister chart `open-appsec-crd`**: the schema is no longer embedded in this chart's `templates/crds/`. Pick one of two paths before upgrading:
    - **Bundled** (simplest): `helm upgrade open-appsec-injector ... --set crds.enabled=true`. The injector pulls `open-appsec-crd` 1.0.0 in as a subchart and renders the CRDs alongside its own resources.
    - **Decoupled** (recommended for production): `helm install open-appsec-crd startechnica/open-appsec-crd` once cluster-wide, then `helm upgrade open-appsec-injector startechnica/open-appsec-injector` with `crds.enabled: false` (the default). Schema lifecycle is then independent of application lifecycle.
  CRDs are functionally identical to the previously-embedded set, and both sides carry `helm.sh/resource-policy: keep`, so existing CustomResources survive the migration regardless of which path you pick.
- **PostgreSQL subchart now opt-in via `postgresql.enabled`**: previously the bundled PostgreSQL subchart rendered whenever `appsec.tuning.enabled=true` (Chart.yaml dependency condition). Now it's governed by an explicit `postgresql.enabled` flag (default `false`). If you had `appsec.tuning.enabled: true` in 1.0.x and want to keep the bundled DB, **add `postgresql.enabled: true` to your values**. Alternatively, point tuning at an external PostgreSQL via `appsec.tuning.externalDatabase.host` (and optionally `.existingSecret` / `.existingSecretPasswordKey`) and leave `postgresql.enabled: false`. Templates fail-fast with a clear error message if `tuning.enabled` is true but neither path is configured.
- **PG major-version bump**: postgresql subchart 12 → 17 (default image PG 14 → PG 17). Skim the [Bitnami postgresql 17.x upgrade notes](https://github.com/bitnami/charts/tree/main/bitnami/postgresql#to-1700) — PG major upgrades are not automatic.

## 1.0.1 20251203
- Adjust agent PV Claimm to wname to hardcoded on webhook

## 1.0.0 20251203
- Initial commit