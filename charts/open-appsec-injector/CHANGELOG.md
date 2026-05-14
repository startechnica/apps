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

- `templates/crds/practices.openappsec.io.yaml` — the legacy `Practice` CRD (v1beta1 only, kebab-case `web-attacks` / `anti-bot` / `snort-signatures` / `openapi-schema-validation` blocks). Missing from previous releases; some users referencing older policy bundles need it to apply cleanly. The modern equivalent is `ThreatPreventionPractice` (v1beta2 camelCase).
- `agent.namespaceSelector` / `agent.objectSelector` are now documented in `values.yaml` (`@param` annotations) — same defaults, just explicit documentation for users overriding either selector.
- `spec.properties.name: string` added to every cluster- and namespaced-scope CRD under `openappsec.io` (acp, customresponses, exceptions, logtriggers, sourcesidentifiers, threatpreventionpractices, trustedsources). Matches upstream v1beta2 schemas; lets users carry a human-readable name in policy bundles.
- `logDestination.k8s-service` (boolean) added to `LogTrigger` / `LogTriggerNS` v1beta2.

### Removed

- `logDestination.local-tuning` from `LogTrigger` / `LogTriggerNS` v1beta2 — replaced upstream by `k8s-service` (above). **Anyone setting `local-tuning: true` must rename it to `k8s-service: true` before upgrade**, otherwise the CR will be rejected.

### Fixed

- `customresponses.openappsec.io` and `customresponsesns.openappsec.io`: removed a duplicate `required: [mode]` block in v1beta2 spec. Inherited from upstream; benign under Helm's lenient YAML loader (last-wins, identical values), but rejected outright by stricter parsers (yaml.v3, kubeval pipelines).
- `sourcesidentifiers.openappsec.io` and `sourcesidentifiersns.openappsec.io`: removed an orphan `properties:` line followed by a duplicate `type: object` at the v1beta2 `spec` level — same upstream bug class. Runtime-equivalent under lenient parsing, rejected by strict parsers.

## 1.0.1 20251203
- Adjust agent PV Claimm to wname to hardcoded on webhook

## 1.0.0 20251203
- Initial commit