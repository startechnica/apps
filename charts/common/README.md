# Startechnica Common Library Chart

A [Helm Library Chart](https://helm.sh/docs/topics/library_charts/#helm) for grouping common logic between Startechnica charts.

## TL;DR

```yaml
dependencies:
  - name: st-common
    version: "*"
    repository: https://startechnica.github.io/apps
```

```console
helm dependency update
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "st-common.names.fullname" . }}
data:
  myvalue: "Hello World"
```

## Introduction

This chart provides a common template helpers which can be used to develop new charts using [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.2.0+

## Parameters

Every helper returns either a string/dict for direct embedding, or `false` (literal) when the capability isn't available — letting callers do `{{- if (include "st-common.capabilities.X.apiVersion" .) }}…{{- end }}` cleanly.

### Names

| Helper identifier                       | Description                                                             | Expected Input                                                                                |
| --------------------------------------- | ----------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `st-common.names.name`                  | Expand the name of the chart or use `.Values.nameOverride`              | `.` Chart context                                                                             |
| `st-common.names.fullname`              | Create a default fully qualified app name                               | `.` Chart context                                                                             |
| `st-common.names.namespace`             | Allow the release namespace to be overridden via `.Values.namespaceOverride` | `.` Chart context                                                                        |
| `st-common.names.fullname.namespace`    | Create a fully qualified app name with installation's namespace appended | `.` Chart context                                                                            |
| `st-common.names.chart`                 | Chart name plus version                                                 | `.` Chart context                                                                             |
| `st-common.names.dependency.fullname`   | Create a default fully qualified dependency name                        | `dict "chartName" "dep" "chartValues" .Values.dep "context" $`                                |
| `st-common.names.dotenv`                | Name of a generated `.env` ConfigMap (`<fullname>-dotenv`)              | `.` Chart context                                                                             |
| `st-common.names.envvars`               | Name of a generated env-vars ConfigMap (`<fullname>-envvars`)           | `.` Chart context                                                                             |
| `st-common.names.gateway.name`          | Resolve a Gateway resource name (override-aware)                        | `.` Chart context                                                                             |
| `st-common.names.gateway.namespace`     | Resolve a Gateway resource namespace (override-aware)                   | `.` Chart context                                                                             |
| `st-common.names.gatewayWaypoint.name`  | Resolve a Gateway-API Waypoint resource name                            | `.` Chart context                                                                             |
| `st-common.names.gatewayWaypoint.namespace` | Resolve a Gateway-API Waypoint resource namespace                   | `.` Chart context                                                                             |

### Labels

| Helper identifier              | Description                                                                              | Expected Input                                  |
| ------------------------------ | ---------------------------------------------------------------------------------------- | ----------------------------------------------- |
| `st-common.labels.standard`    | Kubernetes recommended labels (`app.kubernetes.io/*`) + custom labels                    | `dict "customLabels" .Values.X "context" $`     |
| `st-common.labels.matchLabels` | Labels for `deploy.spec.selector.matchLabels` / `svc.spec.selector` (subset of standard) | `dict "customLabels" .Values.X "context" $`     |

### Affinities

| Helper identifier                  | Description                                          | Expected Input                                               |
| ---------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------ |
| `st-common.affinities.nodes.soft`  | Return a soft nodeAffinity definition                | `dict "key" "FOO" "values" (list "BAR" "BAZ")`               |
| `st-common.affinities.nodes.hard`  | Return a hard nodeAffinity definition                | `dict "key" "FOO" "values" (list "BAR" "BAZ")`               |
| `st-common.affinities.nodes`       | Return a nodeAffinity definition (soft or hard)      | `dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")` |
| `st-common.affinities.topologyKey` | Return a topologyKey definition                      | `dict "topologyKey" "FOO"`                                   |
| `st-common.affinities.pods.soft`   | Return a soft podAffinity/podAntiAffinity definition | `dict "component" "FOO" "context" $`                         |
| `st-common.affinities.pods.hard`   | Return a hard podAffinity/podAntiAffinity definition | `dict "component" "FOO" "context" $`                         |
| `st-common.affinities.pods`        | Return a podAffinity/podAntiAffinity definition      | `dict "type" "soft" "component" "FOO" "context" $`           |

### Gateway

| Helper identifier                       | Description                                                | Expected Input    |
| --------------------------------------- | ---------------------------------------------------------- | ----------------- |
| `st-common.gateway.clusterDomain`       | Return gateway cluster domain                              | `.` Chart context |
| `st-common.gateway.fullname`            | Create a default fully qualified gateway name              | `.` Chart context |
| `st-common.gateway.namespace`           | Allow the gateway namespace to be overridden               | `.` Chart context |
| `st-common.gatewayWaypoint.fullname`    | Create a default fully qualified Gateway-API Waypoint name | `.` Chart context |
| `st-common.gatewayWaypoint.namespace`   | Allow the Gateway-API Waypoint namespace to be overridden  | `.` Chart context |

### Images

| Helper identifier                    | Description                                                                                | Expected Input                                              |
| ------------------------------------ | ------------------------------------------------------------------------------------------ | ----------------------------------------------------------- |
| `st-common.images.image`             | Build a fully-qualified image reference (`registry/repository:tag` or `@digest`)           | `dict "imageRoot" .Values.image "global" .Values.global`    |
| `st-common.images.version`           | Resolve image tag (`.tag` or `.digest`)                                                    | `.Values.image`                                             |
| `st-common.images.pullSecrets`       | Render `imagePullSecrets:` block from per-image and global pull secrets                    | `dict "images" (list .Values.image) "context" $`            |
| `st-common.images.renderPullSecrets` | Same as `pullSecrets` but skips the YAML key (`imagePullSecrets:`) — emits the list only   | `dict "images" (list .Values.image) "context" $`            |

### Ingress

| Helper identifier                          | Description                                                                | Expected Input                                                                 |
| ------------------------------------------ | -------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| `st-common.ingress.backend`                | Build a `backend:` block (v1 or v1beta1 shape based on cluster version)    | `dict "serviceName" "svc" "servicePort" 80 "context" $`                        |
| `st-common.ingress.supportsPathType`       | Returns `true` when `networking.k8s.io/v1` Ingress is available            | `.` Chart context                                                              |
| `st-common.ingress.supportsIngressClassname` | Returns `true` when `Ingress.spec.ingressClassName` is supported         | `.` Chart context                                                              |
| `st-common.ingress.certManagerRequest`     | Render cert-manager annotations on an Ingress when ACME is configured      | `dict "annotations" .Values.ingress.annotations`                               |

### Resources / Storage / RBAC

| Helper identifier                  | Description                                                                                   | Expected Input                                                                          |
| ---------------------------------- | --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| `st-common.resources.preset`       | Resolve a resource preset (`nano`/`micro`/`small`/`medium`/`large`/`xlarge`/`2xlarge`) into `requests`/`limits` | `dict "type" "small"`                                                |
| `st-common.storage.class`          | Resolve `storageClassName` (component-level → `global.defaultStorageClass` → `""`)            | `dict "persistence" .Values.persistence "global" .Values.global`                        |
| `st-common.rbac.serviceAccountName` | Resolve a ServiceAccount name (override-aware, falls back to chart fullname when create=true) | `dict "serviceAccount" .Values.serviceAccount "context" $`                              |

### Secrets

| Helper identifier                   | Description                                                                              | Expected Input                                                                                                                |
| ----------------------------------- | ---------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `st-common.secrets.name`            | Resolve a Secret name (`existingSecret` wins, else `<fullname>-suffix`)                  | `dict "existingSecret" .Values.X.existingSecret "defaultNameSuffix" "creds" "context" $`                                      |
| `st-common.secrets.key`             | Resolve a Secret data-key name (`existingSecretKey` wins, else default)                  | `dict "existingSecret" .Values.X.existingSecret "key" "password"`                                                             |
| `st-common.secrets.lookup`          | Look up a Secret's value with `lookup` (returns `""` if missing)                         | `dict "secret" "name" "namespace" "ns" "key" "k" "context" $`                                                                 |
| `st-common.secrets.exists`          | Returns `true` if a Secret with the given name exists in the namespace                   | `dict "secret" "name" "namespace" "ns" "context" $`                                                                           |
| `st-common.secrets.passwords.manage` | Generate or re-use a password from an existing Secret (idempotent across upgrades)      | `dict "secret" "name" "key" "k" "providedValues" (list "X.password") "length" 16 "strong" true "context" $`                   |

### tplvalues / Utils

| Helper identifier                     | Description                                                                              | Expected Input                                                                       |
| ------------------------------------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `st-common.tplvalues.render`          | Render a string/list/dict that may contain `tpl` directives, against a chart context     | `dict "value" .Values.X "context" $`                                                 |
| `st-common.tplvalues.merge`           | Deep-merge a list of dicts (first-wins), render via `tpl` against a context              | `dict "values" (list .Values.A .Values.B) "context" $`                               |
| `st-common.tplvalues.merge-overwrite` | Deep-merge a list of dicts (last-wins), render via `tpl` against a context               | `dict "values" (list .Values.A .Values.B) "context" $`                               |
| `st-common.utils.createUri`           | Build a URI of the form `scheme://host[:port][/path]`                                    | `dict "scheme" "https" "host" "h" "port" "443" "path" "/api"`                        |
| `st-common.utils.stringOrNumber`      | Force-render a value as a YAML string or number (preserves type)                         | `dict "value" .Values.X`                                                             |
| `st-common.utils.fieldToEnvVar`       | Convert a values-file dotted path (`a.bcD`) into a SHOUTY_SNAKE_CASE env-var name (`A_BC_D`) | `"a.bcD"`                                                                       |
| `st-common.utils.getValueFromKey`     | Resolve a dotted path against a dict (returns `""` when missing)                         | `dict "key" "a.b.c" "context" $`                                                     |
| `st-common.utils.getKeyFromList`      | Find the first non-empty value among a list of dotted-path keys                          | `dict "keys" (list "a.b" "a.c") "context" $`                                         |
| `st-common.utils.checksumTemplate`    | SHA256 checksum of a rendered template path (for `checksum/config` annotations)          | `dict "template" "configmap.yaml" "context" $`                                       |
| `st-common.utils.secret.getvalue`     | Read a single Secret data-key value (decoded), via `lookup`                              | `dict "secret" "name" "key" "k" "context" $`                                         |

### Compatibility / Errors / Warnings / Email

| Helper identifier                              | Description                                                                                      | Expected Input                                                                  |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------- |
| `st-common.compatibility.isOpenshift`          | Returns `true` when the target cluster is OpenShift                                              | `.` Chart context                                                               |
| `st-common.compatibility.renderSecurityContext` | Render a `securityContext` block, omitting `runAsUser`/`runAsGroup`/`fsGroup` on OpenShift restricted-v2 | `dict "secContext" .Values.X.securityContext "context" $`             |
| `st-common.errors.upgrade.passwords.empty`     | Fail the install/upgrade with a clear message when required passwords are empty                  | `dict "validationErrors" (list "X.password is required") "context" $`           |
| `st-common.errors.insecureImages`              | Fail when an image references `:latest` (when policy strict)                                     | `dict "images" (list .Values.image) "context" $`                                |
| `st-common.warnings.rollingTag`                | Print a NOTES warning if an image uses a rolling tag (`:latest`, `:edge`, etc.)                  | `.Values.image`                                                                 |
| `st-common.warnings.modifiedImages`            | Warn when an image registry/repository was overridden from chart defaults                        | `dict "images" (list .Values.image) "context" $`                                |
| `st-common.warnings.resources`                 | Warn when `resources` is empty and no `resourcesPreset` is set                                   | `dict "sections" (list "main") "context" $`                                     |
| `st-common.email.recipientsBcc`                | Render an SMTP BCC recipient list                                                                | `.Values.notifications.bccRecipients`                                           |

### MongoDB helper

| Helper identifier            | Description                                                | Expected Input    |
| ---------------------------- | ---------------------------------------------------------- | ----------------- |
| `st-common.mongodb.secretName` | Resolve the MongoDB Secret name (override-aware)         | `.` Chart context |

## Capabilities

`st-common.capabilities.*` helpers return the appropriate `apiVersion` string for the named resource based on the running cluster's discovered APIs, or `false` (literal) when the API isn't installed.

### Core Kubernetes

| Helper identifier                                            | Description                                                                                    | Expected Input                          |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------- | --------------------------------------- |
| `st-common.capabilities.kubeVersion`                         | Return the target Kubernetes version (using client default if `.Values.kubeVersion` is not set) | `.` Chart context                      |
| `st-common.capabilities.apiVersions.has`                     | Returns `true` if the apiVersion is supported                                                  | `dict "version" "batch/v1" "context" $` |
| `st-common.capabilities.supportsHelmVersion`                 | Returns `true` if the running Helm version is 3.3+                                             | `.` Chart context                       |
| `st-common.capabilities.job.apiVersion`                      | `apiVersion` for `Job`                                                                         | `.` Chart context                       |
| `st-common.capabilities.cronjob.apiVersion`                  | `apiVersion` for `CronJob`                                                                     | `.` Chart context                       |
| `st-common.capabilities.daemonset.apiVersion`                | `apiVersion` for `DaemonSet`                                                                   | `.` Chart context                       |
| `st-common.capabilities.deployment.apiVersion`               | `apiVersion` for `Deployment`                                                                  | `.` Chart context                       |
| `st-common.capabilities.statefulset.apiVersion`              | `apiVersion` for `StatefulSet`                                                                 | `.` Chart context                       |
| `st-common.capabilities.ingress.apiVersion`                  | `apiVersion` for `Ingress`                                                                     | `.` Chart context                       |
| `st-common.capabilities.rbac.apiVersion`                     | `apiVersion` for `Role`/`ClusterRole`/`RoleBinding`/`ClusterRoleBinding`                       | `.` Chart context                       |
| `st-common.capabilities.crd.apiVersion`                      | `apiVersion` for `CustomResourceDefinition`                                                    | `.` Chart context                       |
| `st-common.capabilities.policy.apiVersion`                   | `apiVersion` for `PodSecurityPolicy`                                                           | `.` Chart context                       |
| `st-common.capabilities.networkPolicy.apiVersion`            | `apiVersion` for `NetworkPolicy`                                                               | `.` Chart context                       |
| `st-common.capabilities.apiService.apiVersion`               | `apiVersion` for `APIService` (aggregation layer)                                              | `.` Chart context                       |
| `st-common.capabilities.hpa.apiVersion`                      | `apiVersion` for `HorizontalPodAutoscaler`                                                     | `.` Chart context                       |
| `st-common.capabilities.vpa.apiVersion`                      | `apiVersion` for `VerticalPodAutoscaler` (autoscaling.k8s.io)                                  | `.` Chart context                       |
| `st-common.capabilities.psp.supported`                       | Returns `true` if `PodSecurityPolicy` is supported (<= K8s 1.24)                               | `.` Chart context                       |
| `st-common.capabilities.admissionConfiguration.supported`    | Returns `true` if `AdmissionConfiguration` is supported                                        | `.` Chart context                       |
| `st-common.capabilities.admissionConfiguration.apiVersion`   | `apiVersion` for `AdmissionConfiguration`                                                      | `.` Chart context                       |
| `st-common.capabilities.podSecurityConfiguration.apiVersion` | `apiVersion` for `PodSecurityConfiguration`                                                    | `.` Chart context                       |

### Argo CD

| Helper identifier                                          | Description                            | Expected Input    |
| ---------------------------------------------------------- | -------------------------------------- | ----------------- |
| `st-common.capabilities.argoprojApplication.apiVersion`    | `apiVersion` for `Application`         | `.` Chart context |
| `st-common.capabilities.argoprojApplicationSet.apiVersion` | `apiVersion` for `ApplicationSet`      | `.` Chart context |
| `st-common.capabilities.argoprojAppProject.apiVersion`     | `apiVersion` for `AppProject`          | `.` Chart context |

### Calico

Each per-resource helper prefers `projectcalico.org/v3` (operator-managed Calico) and falls back to `crd.projectcalico.org/v1` (raw CRDs).

| Helper identifier                                                   | Description                                                       | Expected Input    |
| ------------------------------------------------------------------- | ----------------------------------------------------------------- | ----------------- |
| `st-common.capabilities.calico.apiVersion`                          | `apiVersion` for the core Calico API group (`projectcalico.org`)  | `.` Chart context |
| `st-common.capabilities.calicoCrd.apiVersion`                       | `apiVersion` for Calico raw CRDs (`crd.projectcalico.org`)        | `.` Chart context |
| `st-common.capabilities.calicoBGPConfiguration.apiVersion`          | `apiVersion` for `BGPConfiguration`                               | `.` Chart context |
| `st-common.capabilities.calicoBGPFilter.apiVersion`                 | `apiVersion` for `BGPFilter`                                      | `.` Chart context |
| `st-common.capabilities.calicoBGPPeer.apiVersion`                   | `apiVersion` for `BGPPeer`                                        | `.` Chart context |
| `st-common.capabilities.calicoBlockAffinity.apiVersion`             | `apiVersion` for `BlockAffinity`                                  | `.` Chart context |
| `st-common.capabilities.calicoCalicoNodeStatus.apiVersion`          | `apiVersion` for `CalicoNodeStatus`                               | `.` Chart context |
| `st-common.capabilities.calicoClusterInformation.apiVersion`        | `apiVersion` for `ClusterInformation`                             | `.` Chart context |
| `st-common.capabilities.calicoFelixConfiguration.apiVersion`        | `apiVersion` for `FelixConfiguration`                             | `.` Chart context |
| `st-common.capabilities.calicoGlobalNetworkPolicy.apiVersion`       | `apiVersion` for `GlobalNetworkPolicy`                            | `.` Chart context |
| `st-common.capabilities.calicoGlobalNetworkSet.apiVersion`          | `apiVersion` for `GlobalNetworkSet`                               | `.` Chart context |
| `st-common.capabilities.calicoHostEndpoint.apiVersion`              | `apiVersion` for `HostEndpoint`                                   | `.` Chart context |
| `st-common.capabilities.calicoIPAMBlock.apiVersion`                 | `apiVersion` for `IPAMBlock`                                      | `.` Chart context |
| `st-common.capabilities.calicoIPAMConfig.apiVersion`                | `apiVersion` for `IPAMConfig`                                     | `.` Chart context |
| `st-common.capabilities.calicoIPAMHandle.apiVersion`                | `apiVersion` for `IPAMHandle`                                     | `.` Chart context |
| `st-common.capabilities.calicoIPPool.apiVersion`                    | `apiVersion` for `IPPool`                                         | `.` Chart context |
| `st-common.capabilities.calicoIPReservation.apiVersion`             | `apiVersion` for `IPReservation`                                  | `.` Chart context |
| `st-common.capabilities.calicoKubeControllersConfiguration.apiVersion` | `apiVersion` for `KubeControllersConfiguration`                | `.` Chart context |
| `st-common.capabilities.calicoNetworkPolicy.apiVersion`             | `apiVersion` for Calico `NetworkPolicy` (not the K8s-native one)  | `.` Chart context |
| `st-common.capabilities.calicoNetworkSet.apiVersion`                | `apiVersion` for `NetworkSet`                                     | `.` Chart context |
| `st-common.capabilities.calicoNode.apiVersion`                      | `apiVersion` for Calico `Node`                                    | `.` Chart context |
| `st-common.capabilities.calicoProfile.apiVersion`                   | `apiVersion` for `Profile`                                        | `.` Chart context |
| `st-common.capabilities.calicoTier.apiVersion`                      | `apiVersion` for `Tier` (Calico Enterprise / Tigera)              | `.` Chart context |

### Envoy Gateway

| Helper identifier                                                            | Description                                                  | Expected Input    |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------ | ----------------- |
| `st-common.capabilities.envoyproxy.apiVersion`                        | `apiVersion` for the core Envoy Gateway API (`gateway.envoyproxy.io`) | `.` Chart context |
| `st-common.capabilities.envoyproxyBackend.apiVersion`                 | `apiVersion` for `Backend`                                   | `.` Chart context |
| `st-common.capabilities.envoyproxyBackendTrafficPolicy.apiVersion`    | `apiVersion` for `BackendTrafficPolicy`                      | `.` Chart context |
| `st-common.capabilities.envoyproxyClientTrafficPolicy.apiVersion`     | `apiVersion` for `ClientTrafficPolicy`                       | `.` Chart context |
| `st-common.capabilities.envoyproxyEnvoyExtensionPolicy.apiVersion`    | `apiVersion` for `EnvoyExtensionPolicy`                      | `.` Chart context |
| `st-common.capabilities.envoyproxyEnvoyPatchPolicy.apiVersion`        | `apiVersion` for `EnvoyPatchPolicy`                          | `.` Chart context |
| `st-common.capabilities.envoyproxyEnvoyProxy.apiVersion`              | `apiVersion` for `EnvoyProxy`                                | `.` Chart context |
| `st-common.capabilities.envoyproxyHTTPRouteFilter.apiVersion`         | `apiVersion` for `HTTPRouteFilter`                           | `.` Chart context |
| `st-common.capabilities.envoyproxySecurityPolicy.apiVersion`          | `apiVersion` for `SecurityPolicy`                            | `.` Chart context |

### cert-manager

| Helper identifier                                                | Description                              | Expected Input    |
| ---------------------------------------------------------------- | ---------------------------------------- | ----------------- |
| `st-common.capabilities.certmanager.apiVersion`                  | `apiVersion` for the core cert-manager API | `.` Chart context |
| `st-common.capabilities.certmanagerCertificate.apiVersion`       | `apiVersion` for `Certificate`           | `.` Chart context |
| `st-common.capabilities.certmanagerCertificateRequest.apiVersion` | `apiVersion` for `CertificateRequest`    | `.` Chart context |
| `st-common.capabilities.certmanagerIssuer.apiVersion`            | `apiVersion` for `Issuer`                | `.` Chart context |
| `st-common.capabilities.certmanagerClusterIssuer.apiVersion`     | `apiVersion` for `ClusterIssuer`         | `.` Chart context |
| `st-common.capabilities.certmanagerAcme.apiVersion`              | `apiVersion` for ACME `acme.cert-manager.io` resources | `.` Chart context |

### CloudNativePG (PostgreSQL)

| Helper identifier                                                 | Description                                       | Expected Input    |
| ----------------------------------------------------------------- | ------------------------------------------------- | ----------------- |
| `st-common.capabilities.cnpgPostgresql.apiVersion`                | `apiVersion` for the core CNPG API (`postgresql.cnpg.io`) | `.` Chart context |
| `st-common.capabilities.postgresqlCnpgCluster.apiVersion`         | `apiVersion` for `Cluster`                        | `.` Chart context |
| `st-common.capabilities.postgresqlCnpgBackup.apiVersion`          | `apiVersion` for `Backup`                         | `.` Chart context |
| `st-common.capabilities.postgresqlCnpgScheduledBackup.apiVersion` | `apiVersion` for `ScheduledBackup`                | `.` Chart context |
| `st-common.capabilities.postgresqlCnpgDatabase.apiVersion`        | `apiVersion` for `Database`                       | `.` Chart context |
| `st-common.capabilities.postgresqlCnpgPooler.apiVersion`          | `apiVersion` for `Pooler` (PgBouncer)             | `.` Chart context |
| `st-common.capabilities.postgresqlCnpgPublication.apiVersion`     | `apiVersion` for `Publication`                    | `.` Chart context |
| `st-common.capabilities.postgresqlCnpgSubscription.apiVersion`    | `apiVersion` for `Subscription`                   | `.` Chart context |
| `st-common.capabilities.postgresqlCnpgImageCatalog.apiVersion`    | `apiVersion` for `ImageCatalog`                   | `.` Chart context |
| `st-common.capabilities.postgresqlCnpgClusterImageCatalog.apiVersion` | `apiVersion` for `ClusterImageCatalog`        | `.` Chart context |
| `st-common.capabilities.postgresqlCnpgObjectStore.apiVersion`     | `apiVersion` for `ObjectStore` (barman-cloud plugin, `barmancloud.cnpg.io/v1`) | `.` Chart context |

### Flux CD

| Helper identifier                                  | Description                          | Expected Input    |
| -------------------------------------------------- | ------------------------------------ | ----------------- |
| `st-common.capabilities.fluxcdHelmRelease.apiVersion` | `apiVersion` for `HelmRelease`    | `.` Chart context |

### Istio

| Helper identifier                                              | Description                                | Expected Input    |
| -------------------------------------------------------------- | ------------------------------------------ | ----------------- |
| `st-common.capabilities.istioIstioOperator.apiVersion`         | `apiVersion` for `IstioOperator`           | `.` Chart context |
| `st-common.capabilities.istioGateway.apiVersion`               | `apiVersion` for Istio `Gateway`           | `.` Chart context |
| `st-common.capabilities.istioVirtualService.apiVersion`        | `apiVersion` for `VirtualService`          | `.` Chart context |
| `st-common.capabilities.istioDestinationRule.apiVersion`       | `apiVersion` for `DestinationRule`         | `.` Chart context |
| `st-common.capabilities.istioServiceEntry.apiVersion`          | `apiVersion` for `ServiceEntry`            | `.` Chart context |
| `st-common.capabilities.istioWorkloadEntry.apiVersion`         | `apiVersion` for `WorkloadEntry`           | `.` Chart context |
| `st-common.capabilities.istioWorkloadGroup.apiVersion`         | `apiVersion` for `WorkloadGroup`           | `.` Chart context |
| `st-common.capabilities.istioSidecar.apiVersion`               | `apiVersion` for `Sidecar`                 | `.` Chart context |
| `st-common.capabilities.istioEnvoyFilter.apiVersion`           | `apiVersion` for `EnvoyFilter`             | `.` Chart context |
| `st-common.capabilities.istioWasmPlugin.apiVersion`            | `apiVersion` for `WasmPlugin`              | `.` Chart context |
| `st-common.capabilities.istioAuthorizationPolicy.apiVersion`   | `apiVersion` for `AuthorizationPolicy`     | `.` Chart context |
| `st-common.capabilities.istioPeerAuthentication.apiVersion`    | `apiVersion` for `PeerAuthentication`      | `.` Chart context |
| `st-common.capabilities.istioRequestAuthentication.apiVersion` | `apiVersion` for `RequestAuthentication`   | `.` Chart context |
| `st-common.capabilities.istioProxyConfig.apiVersion`           | `apiVersion` for `ProxyConfig`             | `.` Chart context |
| `st-common.capabilities.istioTelemetry.apiVersion`             | `apiVersion` for `Telemetry`               | `.` Chart context |

### Kiali

| Helper identifier                            | Description                       | Expected Input    |
| -------------------------------------------- | --------------------------------- | ----------------- |
| `st-common.capabilities.kiali.apiVersion`    | `apiVersion` for Kiali `Kiali` CR | `.` Chart context |

### Kubernetes Gateway API

| Helper identifier                                                       | Description                                  | Expected Input    |
| ----------------------------------------------------------------------- | -------------------------------------------- | ----------------- |
| `st-common.capabilities.networkingGateway.apiVersion`                   | `apiVersion` for the core Gateway API group  | `.` Chart context |
| `st-common.capabilities.networkingGatewayGateway.apiVersion`            | `apiVersion` for `Gateway`                   | `.` Chart context |
| `st-common.capabilities.networkingGatewayGatewayClass.apiVersion`       | `apiVersion` for `GatewayClass`              | `.` Chart context |
| `st-common.capabilities.networkingGatewayHTTPRoute.apiVersion`          | `apiVersion` for `HTTPRoute`                 | `.` Chart context |
| `st-common.capabilities.networkingGatewayGRPCRoute.apiVersion`          | `apiVersion` for `GRPCRoute`                 | `.` Chart context |
| `st-common.capabilities.networkingGatewayTCPRoute.apiVersion`           | `apiVersion` for `TCPRoute`                  | `.` Chart context |
| `st-common.capabilities.networkingGatewayTLSRoute.apiVersion`           | `apiVersion` for `TLSRoute`                  | `.` Chart context |
| `st-common.capabilities.networkingGatewayUDPRoute.apiVersion`           | `apiVersion` for `UDPRoute`                  | `.` Chart context |
| `st-common.capabilities.networkingGatewayReferenceGrant.apiVersion`     | `apiVersion` for `ReferenceGrant`            | `.` Chart context |
| `st-common.capabilities.networkingGatewayListenerSet.apiVersion`        | `apiVersion` for `ListenerSet`               | `.` Chart context |
| `st-common.capabilities.networkingGatewayBackendLBPolicy.apiVersion`    | `apiVersion` for `BackendLBPolicy`           | `.` Chart context |
| `st-common.capabilities.networkingGatewayBackendTLSPolicy.apiVersion`   | `apiVersion` for `BackendTLSPolicy`          | `.` Chart context |
| `st-common.capabilities.networkingGatewayBackendTrafficPolicy.apiVersion` | `apiVersion` for `BackendTrafficPolicy`    | `.` Chart context |

### MetalLB

| Helper identifier                                          | Description                          | Expected Input    |
| ---------------------------------------------------------- | ------------------------------------ | ----------------- |
| `st-common.capabilities.metallb.apiVersion`                | `apiVersion` for MetalLB core API    | `.` Chart context |
| `st-common.capabilities.metallbIPAddressPool.apiVersion`   | `apiVersion` for `IPAddressPool`     | `.` Chart context |
| `st-common.capabilities.metallbL2Advertisement.apiVersion` | `apiVersion` for `L2Advertisement`   | `.` Chart context |
| `st-common.capabilities.metallbBGPAdvertisement.apiVersion` | `apiVersion` for `BGPAdvertisement` | `.` Chart context |
| `st-common.capabilities.metallbBGPPeer.apiVersion`         | `apiVersion` for `BGPPeer`           | `.` Chart context |
| `st-common.capabilities.metallbBFDProfile.apiVersion`      | `apiVersion` for `BFDProfile`        | `.` Chart context |
| `st-common.capabilities.metallbCommunity.apiVersion`       | `apiVersion` for `Community`         | `.` Chart context |
| `st-common.capabilities.metallbServiceL2Status.apiVersion` | `apiVersion` for `ServiceL2Status`   | `.` Chart context |

### MongoDB Community Operator

| Helper identifier                                          | Description                                   | Expected Input    |
| ---------------------------------------------------------- | --------------------------------------------- | ----------------- |
| `st-common.capabilities.mongodbMongoDBCommunity.apiVersion` | `apiVersion` for `MongoDBCommunity`         | `.` Chart context |

### OpenEBS

| Helper identifier                                            | Description                                    | Expected Input    |
| ------------------------------------------------------------ | ---------------------------------------------- | ----------------- |
| `st-common.capabilities.openebsLocal.apiVersion`             | `apiVersion` for OpenEBS Local PV core API     | `.` Chart context |
| `st-common.capabilities.openebsLocalLVMNode.apiVersion`      | `apiVersion` for `LVMNode`                     | `.` Chart context |
| `st-common.capabilities.openebsLocalLVMVolume.apiVersion`    | `apiVersion` for `LVMVolume`                   | `.` Chart context |
| `st-common.capabilities.openebsLocalLVMSnapshot.apiVersion`  | `apiVersion` for `LVMSnapshot`                 | `.` Chart context |

### Percona Server MongoDB

| Helper identifier                                                | Description                                       | Expected Input    |
| ---------------------------------------------------------------- | ------------------------------------------------- | ----------------- |
| `st-common.capabilities.perconaPerconaServerMongoDB.apiVersion`  | `apiVersion` for `PerconaServerMongoDB`           | `.` Chart context |
| `st-common.capabilities.perconaPerconaServerMongoDBBackup.apiVersion` | `apiVersion` for `PerconaServerMongoDBBackup` | `.` Chart context |
| `st-common.capabilities.perconaPerconaServerMongoDBRestore.apiVersion` | `apiVersion` for `PerconaServerMongoDBRestore` | `.` Chart context |

### Prometheus (CoreOS Monitoring)

| Helper identifier                                                       | Description                                | Expected Input    |
| ----------------------------------------------------------------------- | ------------------------------------------ | ----------------- |
| `st-common.capabilities.coreosMonitoring.apiVersion`                    | `apiVersion` for the core monitoring API   | `.` Chart context |
| `st-common.capabilities.coreosMonitoringPrometheus.apiVersion`          | `apiVersion` for `Prometheus`              | `.` Chart context |
| `st-common.capabilities.coreosMonitoringPrometheusAgent.apiVersion`     | `apiVersion` for `PrometheusAgent`         | `.` Chart context |
| `st-common.capabilities.coreosMonitoringPrometheusRule.apiVersion`      | `apiVersion` for `PrometheusRule`          | `.` Chart context |
| `st-common.capabilities.coreosMonitoringAlertmanager.apiVersion`        | `apiVersion` for `Alertmanager`            | `.` Chart context |
| `st-common.capabilities.coreosMonitoringAlertmanagerConfig.apiVersion`  | `apiVersion` for `AlertmanagerConfig`      | `.` Chart context |
| `st-common.capabilities.coreosMonitoringServiceMonitor.apiVersion`      | `apiVersion` for `ServiceMonitor`          | `.` Chart context |
| `st-common.capabilities.coreosMonitoringPodMonitor.apiVersion`          | `apiVersion` for `PodMonitor`              | `.` Chart context |
| `st-common.capabilities.coreosMonitoringProbe.apiVersion`               | `apiVersion` for `Probe`                   | `.` Chart context |
| `st-common.capabilities.coreosMonitoringScrapeConfig.apiVersion`        | `apiVersion` for `ScrapeConfig`            | `.` Chart context |
| `st-common.capabilities.coreosMonitoringThanosRuler.apiVersion`         | `apiVersion` for `ThanosRuler`             | `.` Chart context |

### Strimzi (Kafka)

Helpers prefer `kafka.strimzi.io/v1` (GA in Strimzi 0.46+) and fall back to `v1beta2`.

| Helper identifier                                              | Description                            | Expected Input    |
| -------------------------------------------------------------- | -------------------------------------- | ----------------- |
| `st-common.capabilities.strimziKafka.apiVersion`               | `apiVersion` for `Kafka`               | `.` Chart context |
| `st-common.capabilities.strimziKafkaNodePool.apiVersion`       | `apiVersion` for `KafkaNodePool`       | `.` Chart context |
| `st-common.capabilities.strimziKafkaTopic.apiVersion`          | `apiVersion` for `KafkaTopic`          | `.` Chart context |
| `st-common.capabilities.strimziKafkaUser.apiVersion`           | `apiVersion` for `KafkaUser`           | `.` Chart context |
| `st-common.capabilities.strimziKafkaConnect.apiVersion`        | `apiVersion` for `KafkaConnect`        | `.` Chart context |
| `st-common.capabilities.strimziKafkaConnector.apiVersion`      | `apiVersion` for `KafkaConnector`      | `.` Chart context |
| `st-common.capabilities.strimziKafkaBridge.apiVersion`         | `apiVersion` for `KafkaBridge`         | `.` Chart context |
| `st-common.capabilities.strimziKafkaMirrorMaker2.apiVersion`   | `apiVersion` for `KafkaMirrorMaker2`   | `.` Chart context |
| `st-common.capabilities.strimziKafkaRebalance.apiVersion`      | `apiVersion` for `KafkaRebalance`      | `.` Chart context |
| `st-common.capabilities.strimziPodSet.apiVersion`              | `apiVersion` for internal `PodSet` (`core.strimzi.io/v1`) | `.` Chart context |

### VMware / Zalando

| Helper identifier                                  | Description                                                | Expected Input    |
| -------------------------------------------------- | ---------------------------------------------------------- | ----------------- |
| `st-common.capabilities.vmwareCns.apiVersion`      | `apiVersion` for VMware CNS resources (`cns.vmware.com`)   | `.` Chart context |
| `st-common.capabilities.zalandoAcid.apiVersion`    | `apiVersion` for Zalando `postgresql` operator (`acid.zalan.do`) | `.` Chart context |

## Validations

`st-common.validations.values.*` fail the install/upgrade with a clear message when required values are missing. Component-specific validators (`st-common.X.values.*`) plug into the generic ones.

### Generic

| Helper identifier                              | Description                                                                  | Expected Input                                                                                                                |
| ---------------------------------------------- | ---------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `st-common.validations.values.single.empty`    | Fail when a single required value is empty                                   | `dict "valueKey" "X.password" "secret" "name" "field" "password" "context" $`                                                 |
| `st-common.validations.values.multiple.empty`  | Fail when any of a list of required values is empty                          | `dict "required" (list (dict "valueKey" "X.password" ...)) "context" $`                                                       |
| `st-common.validations.values.mariadb.passwords` | MariaDB-specific password validation entry-point                            | `dict "secret" "name" "subchart" true "context" $`                                                                            |

### Database stacks

For each of the databases below, `st-common.<db>.values.enabled` returns `true` if the bundled subchart should be considered enabled, `*.existingSecret` resolves the secret name to consume, and `*.key.*` resolves the data-key inside that secret.

| Helper identifier                                | Description                                                                | Expected Input    |
| ------------------------------------------------ | -------------------------------------------------------------------------- | ----------------- |
| `st-common.cassandra.values.enabled`             | Cassandra subchart enabled?                                                | `.` Chart context |
| `st-common.cassandra.values.existingSecret`      | Cassandra existing-secret name                                             | `.` Chart context |
| `st-common.cassandra.values.key.dbUser`          | Cassandra user-credential key                                              | `.` Chart context |
| `st-common.mariadb.values.enabled`               | MariaDB subchart enabled?                                                  | `.` Chart context |
| `st-common.mariadb.values.architecture`          | MariaDB architecture (`standalone`/`replication`)                          | `.` Chart context |
| `st-common.mariadb.values.auth.existingSecret`   | MariaDB existing-secret name                                               | `.` Chart context |
| `st-common.mariadb.values.key.auth`              | MariaDB auth key                                                           | `.` Chart context |
| `st-common.mongodb.values.enabled`               | MongoDB subchart enabled?                                                  | `.` Chart context |
| `st-common.mongodb.values.architecture`          | MongoDB architecture                                                       | `.` Chart context |
| `st-common.mongodb.values.auth.existingSecret`   | MongoDB existing-secret name                                               | `.` Chart context |
| `st-common.mongodb.values.key.auth`              | MongoDB auth key                                                           | `.` Chart context |
| `st-common.mysql.values.enabled`                 | MySQL subchart enabled?                                                    | `.` Chart context |
| `st-common.mysql.values.architecture`            | MySQL architecture                                                         | `.` Chart context |
| `st-common.mysql.values.auth.existingSecret`     | MySQL existing-secret name                                                 | `.` Chart context |
| `st-common.mysql.values.key.auth`                | MySQL auth key                                                             | `.` Chart context |
| `st-common.postgresql.values.enabled`            | PostgreSQL subchart enabled?                                               | `.` Chart context |
| `st-common.postgresql.values.enabled.replication` | PostgreSQL replication enabled?                                           | `.` Chart context |
| `st-common.postgresql.values.existingSecret`     | PostgreSQL existing-secret name                                            | `.` Chart context |
| `st-common.postgresql.values.use.global`         | Whether PostgreSQL is wired through the global block                       | `.` Chart context |
| `st-common.postgresql.values.key.postgressPassword` | PostgreSQL admin password key                                           | `.` Chart context |
| `st-common.postgresql.values.key.replicationPassword` | PostgreSQL replication password key                                   | `.` Chart context |
| `st-common.redis.values.enabled`                 | Redis subchart enabled?                                                    | `.` Chart context |
| `st-common.redis.values.keys.prefix`             | Redis key prefix (architecture-aware)                                      | `.` Chart context |
| `st-common.redis.values.standarized.version`     | Redis chart-version normalizer                                             | `.` Chart context |
| `st-common.stack.values.enabled`                 | Returns `true` if any configured database stack is enabled                 | `.` Chart context |

## Example of use

```yaml
{{- if (include "st-common.capabilities.networkingGatewayGateway.apiVersion" .) }}
apiVersion: {{ include "st-common.capabilities.networkingGatewayGateway.apiVersion" . }}
kind: Gateway
metadata:
  name: {{ include "st-common.gateway.fullname" . }}
  namespace: {{ include "st-common.gateway.namespace" . }}
. . .
{{- end }}
```

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
