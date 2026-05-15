# Changelog

## 1.1.2 (2026-05-15)

### Changed

- `agent.objectSelector` default is now `{}` (empty) instead of a hardcoded `matchLabels.gateway.networking.k8s.io/gateway-name: istio-ingress`. The previous default silently constrained injection to Istio gateway pods, even though the chart advertises support for Kong and other ingresses (with the result that Kong / non-Istio gateways labeled `inject-waf-attachment=true` at the namespace level were matched by the MWC's `namespaceSelector` but rejected by the hardcoded `objectSelector` — silently no-op). The empty default lets `agent.namespaceSelector` be the sole gate; operators who want pod-level filtering set it explicitly.

### Upgrading from 1.1.1

- **Istio-gateway users**: the default behavior change widens the MWC's match set. If you relied on the prior default to scope injection to Istio's gateway Deployment (typical Istio-only deployments), restore it explicitly:

  ```yaml
  agent:
    objectSelector:
      matchLabels:
        gateway.networking.k8s.io/gateway-name: istio-ingress
  ```

  Otherwise every pod in any namespace labeled `inject-waf-attachment: "true"` becomes an injection candidate. The `inject-waf-attachment: "false"` per-pod opt-out (handled by the chart's MWC config elsewhere) still applies.
- **Kong / multi-gateway users**: no action — this default change is the fix that unblocks Kong injection.

## 1.1.1 (2026-05-15)

First successfully-published release in the 1.1.x line. The unreleased
1.1.0 entry below describes the bulk of the work; this patch ships
those changes plus a few additions and dep tweaks that were required
to actually get the chart into the repo.

### Added

- Top-level `externalDatabase.{host, port, user, existingSecret, existingSecretPasswordKey}` block for pointing the tuning component at an external PostgreSQL (managed RDS, CloudSQL, on-prem PG). Connection details live at root so future components beyond `appsec.tuning` can share the same server. Driven by four helpers (`open-appsec.tuning.{dbHost, dbPort, dbSecretName, dbSecretPasswordKey}`) used by `templates/tuning/Deployment.yaml`. New env `QUERY_DB_PORT` plumbed through to the container. The logical-database name is NOT chart-configurable: the upstream `smartsync-tuning` binary hardcodes `i2datatubeschemasecurityeventlogsv03` in the connection-URL format string (`datatube.go`), so a chart-side override would have no effect without an upstream patch.
- `appsec.tuning.configs.bootstrap.existingConfigMap` — BYO-only hook for overriding the tuning binary's bootstrap config. When set, the chart mounts `bootstrapConfig.yaml` and `tableSchema.json` from the named ConfigMap into the pod at `/app/configs/` via `subPath`, shadowing the baked-in container defaults so operators can override knobs that aren't surfaced as env vars (log level, scheduler intervals, etcd settings, tuning thresholds). Empty (default) skips the mount entirely and the container falls back to its baked-in files. The chart does NOT carry a verbatim copy of upstream's files — operators ship their own ConfigMap if they need overrides.
- `webhook.uninstallCleanup.*` + new `templates/webhook/uninstall-cleanup.yaml` (Helm `pre-delete` hook Job). The open-appsec webhook binary creates EnvoyFilter resources at admission time (label `owner: waf`) directly via the K8s API; those resources aren't part of any Helm release manifest and previously survived `helm uninstall`, leaving the cluster with broken Envoy filters that reference a now-missing attachment library. Enable `webhook.uninstallCleanup.enabled: true` to render a Job that runs `kubectl delete envoyfilter -A -l 'owner=waf' --ignore-not-found` before the rest of the chart tears down. Reuses the existing webhook ServiceAccount (already has cluster-wide `envoyfilters: delete` RBAC via the `:mutate-injection` ClusterRoleBinding). Default `false` for backwards compatibility.

### Changed

- postgresql subchart dependency moved from the legacy HTTPS index `https://charts.bitnami.com/bitnami` to Bitnami's free OCI registry `oci://registry-1.docker.io/bitnamicharts` (the HTTPS index was retired by Bitnami in late 2025 and now 302-redirects to a Broadcom-hosted mirror that doesn't carry every historical chart version). Version bumped from `17.1.0` to `18.6.6` because Bitnami pruned every chart version below `18.x` from the OCI registry — `17.1.0` is no longer resolvable. Bundled-DB users get PG 18 instead of PG 17; external-DB users are unaffected.
- open-appsec-crd sister-chart dependency switched from the HTTPS index URL to a `file://../open-appsec-crd` relative path so chart-releaser can resolve the cross-monorepo dependency on the first publish (before the sister chart exists in the gh-pages index). Functional behavior identical for both bundled (`crds.enabled=true`, the default) and decoupled (`crds.enabled=false`) installs.

The st-common subchart dependency stays at the HTTPS index `https://startechnica.github.io/apps` (`version: 0.1.20`) since that version was published via classic chart-releaser and isn't yet mirrored to GHCR's OCI registry. Will migrate to OCI in a later release once st-common has been re-released through the OCI publish workflow.

### Note for anyone who tested the unreleased 1.1.0 dev build

The external-DB configuration shape changed between dev-1.1.0 and 1.1.1:
connection details moved from `appsec.tuning.externalDatabase.*` to the new
top-level `externalDatabase.*`. There is no longer a chart-side knob for the
database name — the upstream binary hardcodes it (see Added entry above).
The dev-1.1.0 paths are inert in 1.1.1 — overrides at those paths render as
a no-op without error. Anyone with overrides at the dev paths should re-shape:

```yaml
# Dev-1.1.0 paths (now inert)
appsec:
  tuning:
    externalDatabase:
      host: pg.example.com

# 1.1.1 paths
externalDatabase:
  host: pg.example.com
```

## 1.1.0 (2026-05-03)

Upstream sync — engine image, CRDs, and chart dependencies updated to match
[`openappsec/open-appsec-injector` 1.1.33](https://charts.openappsec.io) and the
canonical CRD source at
[openappsec/openappsec/config/crds/open-appsec-crd-latest.yaml](https://github.com/openappsec/openappsec/blob/main/config/crds/open-appsec-crd-latest.yaml).

### Changed

- Bumped `appVersion` and `agent.image.tag` from `1.1.32` to `1.1.34`.
- Bumped `postgresql` subchart dependency from `12.2.8` → `18.6.6` (PG 14 → PG 18 default image) and **moved repository to Bitnami's free OCI registry** (`oci://registry-1.docker.io/bitnamicharts`). Bitnami stopped publishing to the legacy HTTP index `https://charts.bitnami.com/bitnami` and pruned all sub-18 chart versions from OCI in late 2025 — pinning to anything older than 18.x is no longer resolvable. Existing data volumes survive a fresh install with the same PVC, but operators upgrading in place need a PG major-version migration plan (`pg_upgrade` or dump/restore); review the [Bitnami postgresql 18.x upgrade notes](https://github.com/bitnami/charts/tree/main/bitnami/postgresql#upgrading) before proceeding.
- Bumped `st-common` dependency from `0.1.16` → `0.1.20`.

### Added

- *(see also)* — CRDs split into sister chart [`open-appsec-crd`](../open-appsec-crd) 1.0.0, declared as a conditional dependency on this chart with gate `crds.enabled` (default `true` — bundled). The previously-embedded `templates/crds/` directory (18 CRDs including the new `practices.openappsec.io`) lives in the sister chart now. Two install modes: keep the default to bundle the subchart alongside this release, OR install `open-appsec-crd` separately and set `crds.enabled: false` on the injector (recommended when multiple injector releases share one CRD set, or CRD lifecycle is owned by a different team). See **Upgrading**.
- `agent.namespaceSelector` / `agent.objectSelector` are now documented in `values.yaml` (`@param` annotations) — same defaults, just explicit documentation for users overriding either selector.
- `spec.properties.name: string` added to every cluster- and namespaced-scope CRD under `openappsec.io` (acp, customresponses, exceptions, logtriggers, sourcesidentifiers, threatpreventionpractices, trustedsources). Matches upstream v1beta2 schemas; lets users carry a human-readable name in policy bundles.
- `logDestination.k8s-service` (boolean) added to `LogTrigger` / `LogTriggerNS` v1beta2.
- Top-level `allowedNamespaces` (default `[]`) to scope both the `openappsec.io` ClusterRoleBinding subject set AND the ingress source set on every component's NetworkPolicy. `[]` = release namespace only (most restrictive; safe default); `["*"]` = legacy cluster-wide `Group system:serviceaccounts` subject + wide-open network ingress; an explicit list like `[istio-ingress, kong]` = per-namespace RBAC + per-namespace network ingress in one knob. Tightens default RBAC + network blast radius — see Upgrading.
- `tls.certManager.{create,issuerRef,duration,renewBefore}` at root + `templates/webhook/{Issuer,Certificate}.yaml` + `cert-manager.io/inject-ca-from` annotation on the `MutatingWebhookConfiguration`. Mirrors the adminer chart's TLS architecture. **Dormant**: the open-appsec container's built-in `secretgen.py` writes its own cert at startup and patches the MWC `caBundle` itself, so chart-side cert provisioning races against the container. Code is in place pending an upstream container toggle (e.g. `SKIP_CERTGEN=1`) to disable the runtime generator; gating flips on at that point.
- `webhook.tls.{certSecretKey,certKeySecretKey,caSecretKey}` (default `tls.crt` / `tls.key` / `ca.crt`) — Secret data-key names. Combined with the existing `certFilename` / `certKeyFilename` / `certCAFilename` (mount-side names), the TLS volume now does explicit `items[]` remapping in the Deployment, so a `kubernetes.io/tls`-shaped Secret (cert-manager output, external-secrets, etc.) is consumed without renaming keys.
- `webhook.metrics.serviceMonitor.path` (default `/metrics`) — surfaces the fallback path used by `templates/webhook/ServiceMonitor.yaml` when `endpoints` is empty. Was previously templated as nil.
- Top-level `externalDatabase.{host,port,user,existingSecret,existingSecretPasswordKey}` — connection details for an external PostgreSQL shared by any component that needs DB access (currently `appsec.tuning`; future components can reuse). Driven by four helpers (`open-appsec.tuning.{dbHost,dbPort,dbSecretName,dbSecretPasswordKey}`) used by `templates/tuning/Deployment.yaml`. New env `QUERY_DB_PORT` plumbed through to the container. The logical-DB name is NOT a chart knob — upstream `smartsync-tuning` hardcodes `i2datatubeschemasecurityeventlogsv03` in `datatube.go`'s connection-URL format string.
- `appsec.tuning.configs.bootstrap.existingConfigMap` — BYO-only mount point for overriding the tuning binary's bootstrap config. When set, the chart mounts the named ConfigMap's `bootstrapConfig.yaml` + `tableSchema.json` keys into the pod at `/app/configs/` via subPath, shadowing the baked-in container defaults so operators can override knobs without env-var bindings (log level, scheduler intervals, etcd, tuning thresholds). Default empty — pod uses the container's baked-in files unchanged.
- `postgresql.enabled` (default `false`) — decouples the bundled postgresql subchart's lifecycle from `appsec.tuning.enabled`. See Upgrading.
- `templates/default-configs/prevent-learn/` and `templates/default-configs/prevent/` — two new preset directories matching the existing `detect-learn/`. Each ships 10 files: 5 cluster-scoped CRs + 5 namespaced (`*NS`) twins. Operators progress through the standard open-appsec rollout (`detect-learn` → `prevent-learn` → `prevent`) by flipping `defaultConfigurations.mode` alone — the `crds.scope` value picks cluster vs namespaced rendering orthogonally. Only the `Policy` resource changes per mode; AccessControlPractice / CustomResponse / LogTrigger / ThreatPreventionPractice are mode-agnostic (they all use `practiceMode: inherited`).
- `templates/default-configs/detect-learn/*NS.yaml` (5 new files) — namespaced twins of the existing detect-learn cluster-scoped defaults; rendered when `crds.scope: namespaced`. Same five default-named resources as the cluster variants, scoped to the release namespace.
- `webhook.pdb.{enabled,minAvailable,maxUnavailable}` — optional PodDisruptionBudget for the webhook (default `enabled: false`). When the webhook has `failurePolicy: Fail` (the chart's default), losing it during a voluntary disruption stops admission cluster-wide; a PDB blocks the drain until a replacement schedules. Recommended for production with `webhook.replicaCount >= 2`.
- `values.schema.json` — JSON Schema generated from `values.yaml` defaults. Permissive (no `required`, no `additionalProperties: false`); catches gross type mistakes (`replicaCount: "two"`, `webhook.timeoutSeconds: "5s"`) at `helm install`/`upgrade` time. Same approach the adminer chart uses.
- `templates/NOTES.txt` — post-install walkthrough that prints the webhook readiness command, MWC caBundle verification, CRD presence check (different message depending on `crds.enabled`), and the three-step injection-opt-in (label namespace → label deployment → rollout restart). Replaces silent install with a focused "what to do next" message.
- `webhook.uninstallCleanup.*` + new `templates/webhook/uninstall-cleanup.yaml` (Helm `pre-delete` hook Job). The webhook's mutating logic creates EnvoyFilter resources at runtime (label `owner: waf`) directly via the K8s API; they're not part of any Helm release manifest and previously survived `helm uninstall`, leaving the cluster with broken Envoy filters that reference a now-missing attachment library. Enable `webhook.uninstallCleanup.enabled: true` to render a Job that runs `kubectl delete envoyfilter -A -l 'owner=waf' --ignore-not-found` before the rest of the chart tears down. Reuses the existing webhook ServiceAccount (already has cluster-wide `envoyfilters: delete` RBAC); no extra binding needed. Default `false` to preserve historical behavior. Single caveat: the runtime stamps `owner=waf` without a release-name suffix, so multi-release clusters will cross-delete on uninstall — flagged in the values comment.
- New helper `open-appsec.webhook.tlsSecretName` — single source of truth for the webhook TLS Secret name (BYO `webhook.tls.certificatesSecretName` wins, else `<fullname>-webhook-tls`). Both the Deployment volume and the Certificate's `secretName` reference it.
- `values.yaml` now has 25 `## @section` markers; the README's `## Parameters` block regenerates idempotently via `@bitnami/readme-generator-for-helm` and now contains ~660 documented rows across 18 logical sections (Global, OpenAppSec CRD, Common parameters, Diagnostic mode, Playground, CrowdSec, Custom Fog, Default configurations, Agent, AppSec/Learning/Storage/Tuning, Webhook, Webhook TLS, Metrics, TLS / cert-manager, PostgreSQL subchart).

### Changed

- Webhook `livenessProbe` / `readinessProbe` / `startupProbe` defaults: `port: http` / `scheme: HTTP` → `port: https` / `scheme: HTTPS`. `containerPorts` only declares `https: 443` and `metrics: 7465`, so the prior defaults referenced a port name that didn't exist — enabling any probe would have failed pod scheduling. Probes are still `enabled: false` by default.
- `templates/webhook/MutatingWebhookConfiguration.yaml` — conditional `cert-manager.io/inject-ca-from` annotation + gated `caBundle` rendering, controlled by the new `$injectCA` local. No behavior change when cert-manager mode is off (default).
- `templates/webhook/Deployment.yaml` TLS volume now uses `secret.items[]` to remap Secret data keys to mount-side filenames (see `webhook.tls.{cert,certKey,ca}SecretKey` above). Renders the same way as before for BYO Secrets that follow the `tls.crt`/`tls.key`/`ca.crt` convention.
- `webhook.tls.{certFilename,certKeyFilename,certCAFilename}` are now actually consumed by the Deployment volume mount (`items[].path`). Previously declared in `values.yaml` but never referenced — dead from the chart's inception.

### Removed

- `logDestination.local-tuning` from `LogTrigger` / `LogTriggerNS` v1beta2 — replaced upstream by `k8s-service` (above). **Anyone setting `local-tuning: true` must rename it to `k8s-service: true` before upgrade**, otherwise the CR will be rejected.
- Embedded `templates/crds/` directory (18 CRDs). They now live in the sister chart `open-appsec-crd`, declared as a conditional dependency of this chart. `crds.enabled` (default `true`) bundles the sister chart as a subchart; set `crds.enabled: false` to manage CRDs via a separately-installed `open-appsec-crd` release. The old `crds.keep` key is gone — the sister chart owns that toggle now (defaults to keep-on-uninstall, override via `--set open-appsec-crd.crds.keep=false` on bundled installs). `crds.scope` survives at this chart's level as a runtime hint plumbed to the webhook as `CRDS_SCOPE` env.
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
- **CRDs split into sister chart `open-appsec-crd`**: the schema is no longer embedded in this chart's `templates/crds/`. Default behavior (`crds.enabled: true`) bundles `open-appsec-crd` 1.0.0 as a subchart on each `helm upgrade open-appsec-injector ...` — the upgrade is transparent for operators who don't manage CRDs out-of-band. CRDs carry `helm.sh/resource-policy: keep` on both sides, so existing CustomResources survive the migration. If you ALREADY manage CRDs separately (cluster-wide `helm install open-appsec-crd` from a parallel pipeline, or `kubectl apply -f` from a CD job), pass `--set crds.enabled=false` on the injector upgrade to avoid duplicate ownership; the bundled subchart will be skipped and the externally-installed CRDs continue serving the injector unchanged.
- **PostgreSQL subchart now opt-in via `postgresql.enabled`**: previously the bundled PostgreSQL subchart rendered whenever `appsec.tuning.enabled=true` (Chart.yaml dependency condition). Now it's governed by an explicit `postgresql.enabled` flag (default `false`). If you had `appsec.tuning.enabled: true` in 1.0.x and want to keep the bundled DB, **add `postgresql.enabled: true` to your values**. Alternatively, point tuning at an external PostgreSQL via the top-level `externalDatabase.host` (and optionally `.existingSecret` / `.existingSecretPasswordKey`) and leave `postgresql.enabled: false`. The logical-database name is not chart-configurable (upstream binary hardcodes `i2datatubeschemasecurityeventlogsv03` in `datatube.go`); the external server must allow connecting to that DB name, or you must pre-create it. Templates fail-fast with a clear error message if `tuning.enabled` is true but neither connection path is configured.
- **PG major-version bump**: postgresql subchart 12 → 18 (default image PG 14 → PG 18). The subchart was also moved off the legacy `https://charts.bitnami.com/bitnami` HTTP index — which Bitnami retired in late 2025 — to the free OCI registry `oci://registry-1.docker.io/bitnamicharts`. CI/CD pipelines doing `helm dep update` need a Helm 3.8+ binary to resolve OCI dependencies (chart-releaser-action `v1.6+` already qualifies). PG major upgrades are not automatic; see the [Bitnami postgresql upgrade notes](https://github.com/bitnami/charts/tree/main/bitnami/postgresql#upgrading) before in-place upgrading bundled data volumes.

## 1.0.1 20251203
- Adjust agent PV Claimm to wname to hardcoded on webhook

## 1.0.0 20251203
- Initial commit