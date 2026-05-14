# open-appsec-crd

CustomResourceDefinitions for [open-appsec](https://www.openappsec.io/),
packaged as their own Helm chart so they can be installed and upgraded
independently of the application workload.

## Why a separate chart?

Helm 3 [intentionally refuses to upgrade CRDs](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/)
that live inside an application chart's `templates/` directory — they are
applied once at install and never touched again. The official workaround
is to ship CRDs as their own chart with its own version line, and let
operators upgrade the schema cleanly via `helm upgrade open-appsec-crd ...`
without redeploying the application that consumes them.

The sister chart is [open-appsec-injector](../open-appsec-injector) —
install that one in a workload namespace; it will use these CRDs to render
policies, exceptions, log triggers, and so on.

## TL;DR

```console
helm repo add startechnica https://startechnica.github.io/apps
helm install open-appsec-crd startechnica/open-appsec-crd
```

CRDs are cluster-scoped resources, so the install namespace doesn't matter
functionally — pick whatever fits your operational story (we install into
`open-appsec` to match the injector chart).

## What it installs

18 CRDs in the `openappsec.io` API group:

| Kind | Namespaced twin | Notes |
| --- | --- | --- |
| `AccessControlPractice` (`acp`) | `AccessControlPracticeNS` (`acpns`) | Rate-limit + access-control rules |
| `CustomResponse` (`customresponse`) | `CustomResponseNS` (`customresponsens`) | Block-page / redirect / response-code templates |
| `Exception` (`exception`) | `ExceptionNS` (`exceptionns`) | Skip/accept/drop/suppressLog overrides |
| `LogTrigger` (`logtrigger`) | `LogTriggerNS` (`logtriggerns`) | Log destination + verbosity config |
| `Policy` (`policy`) | `PolicyNS` (`policyns`) | Top-level routing of practices to hosts |
| `PolicyActivation` | — | Cluster-scoped policy activation pointer |
| `Practice` (`practice`) | — | Legacy v1beta1 Practice resource (kebab-case schema) |
| `SourcesIdentifier` (`sourcesidentifier`) | `SourcesIdentifierNS` (`sourcesidentifierns`) | How the agent identifies clients (header / JWT / cookie / IP) |
| `ThreatPreventionPractice` (`tpp`) | `ThreatPreventionPracticeNS` (`tppns`) | Modern v1beta2 Practice (camelCase schema) |
| `TrustedSource` (`trustedsource`) | `TrustedSourceNS` (`trustedsourcens`) | Reputation allowlist sources |

All cluster-scoped CRDs serve both `v1beta1` (legacy kebab-case) and
`v1beta2` (modern camelCase) where the upstream defines them; `-ns`
twins are v1beta2-only.

## Parameters

| Name | Description | Value |
| --- | --- | --- |
| `crds.keep` | Add `helm.sh/resource-policy: keep` annotation to every CRD so they survive `helm uninstall`. Strongly recommended in production. | `true` |
| `commonLabels` | Extra labels applied to every CRD on top of the standard `app.kubernetes.io/*` block. | `{}` |

## Uninstall

By default (`crds.keep: true`) the CRDs survive `helm uninstall`:

```console
helm uninstall open-appsec-crd
# CRDs remain registered
```

To fully remove the CRDs **and every CustomResource of those kinds in every
namespace**, delete the CRDs explicitly after uninstalling:

```console
kubectl delete crd \
  accesscontrolpractices.openappsec.io \
  accesscontrolpracticesns.openappsec.io \
  customresponses.openappsec.io \
  customresponsesns.openappsec.io \
  exceptions.openappsec.io \
  exceptionsns.openappsec.io \
  logtriggers.openappsec.io \
  logtriggersns.openappsec.io \
  policies.openappsec.io \
  policiesns.openappsec.io \
  policyactivations.openappsec.io \
  practices.openappsec.io \
  sourcesidentifiers.openappsec.io \
  sourcesidentifiersns.openappsec.io \
  threatpreventionpractices.openappsec.io \
  threatpreventionpracticesns.openappsec.io \
  trustedsources.openappsec.io \
  trustedsourcesns.openappsec.io
```

This is irreversible — every `Policy`, `Practice`, `CustomResponse`, etc. in
every namespace is gone. Confirm with `kubectl get policies.openappsec.io -A`
before deleting.

## License

Copyright &copy; 2026 Startechnica

Licensed under the Apache License, Version 2.0.
