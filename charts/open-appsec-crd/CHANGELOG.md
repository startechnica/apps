# Changelog

## 1.0.0 (2026-05-15)

Initial release. The CRDs that previously shipped inside `open-appsec-injector`
under `templates/crds/` now live in their own chart, allowing independent
install/upgrade and matching the upstream Kubernetes guidance for CRD
lifecycle management (Helm intentionally refuses to update CRDs inside the
`templates/` directory of an application chart, so a sister CRD-only chart
is the standard way to evolve schemas without forcing reinstalls).

### Added

- 18 CRDs sourced from
  [openappsec/openappsec config/crds/open-appsec-crd-latest.yaml](https://github.com/openappsec/openappsec/blob/main/config/crds/open-appsec-crd-latest.yaml):
  cluster-scoped `accesscontrolpractices`, `customresponses`, `exceptions`,
  `logtriggers`, `policies`, `policyactivations`, `practices`,
  `sourcesidentifiers`, `threatpreventionpractices`, `trustedsources` —
  plus their `-ns` namespaced twins for everything except
  `policyactivations` and `practices`.
- `crds.keep` (default `true`) — adds `helm.sh/resource-policy: keep`
  annotation to every CRD so they survive `helm uninstall`.
- `commonLabels` — extra labels applied to every CRD on top of the
  standard `app.kubernetes.io/*` block.
- Schema content is identical to the cleaned-up CRDs in `open-appsec-injector`
  1.1.0: includes the upstream `spec.properties.name` field, the
  `logDestination.k8s-service` boolean, the `policiesns` v1beta2
  `specificRules.items.required` block, and the new `practices.openappsec.io`
  v1beta1 CRD. Inherited upstream dup-key bugs in `customresponses` and
  `sourcesidentifiers` are cleaned.
