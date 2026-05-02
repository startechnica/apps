<!--- app-name: Adminer -->

# Helm chart for Adminer

Adminer (formerly phpMinAdmin) is a full-featured database management tool written in PHP. Conversely to phpMyAdmin, it consist of a single file ready to deploy to the target server. Adminer is available for MySQL, PostgreSQL, SQLite, MS SQL, Oracle, Firebird, SimpleDB, Elasticsearch and MongoDB.

[Overview of Adminer](https://www.adminer.org/)

**This chart is not maintained by the upstream project and any issues with the chart should be raised [here](https://github.com/startechnica/apps/issues/new/choose)**

## TL;DR

```console
helm repo add startechnica https://startechnica.github.io/apps
helm install adminer startechnica/adminer
```

## Prerequisites

- Kubernetes 1.24+
- Helm 3.10.0+

## Installing the Chart

To install the chart with the release name `adminer` on `adminer` namespace:

```console
helm repo add startechnica https://startechnica.github.io/apps
helm install adminer startechnica/adminer --namespace adminer --create-namespace
```

These commands deploy Adminer on the Kubernetes cluster in the default configuration.

> **Tip**: List all releases using `helm list -A`

## Uninstalling the Chart

To uninstall/delete the `adminer` deployment:

```console
helm delete adminer --namespace adminer
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Global parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `global.imageRegistry` | Global Docker image registry | `""` |
| `global.imagePullSecrets` | Global Docker registry secret names as an array | `[]` |
| `global.storageClass` | Global StorageClass for Persistent Volume(s) | `""` |
| `global.compatibility.openshift.adaptSecurityContext` | Adapt the securityContext sections for OpenShift restricted-v2 SCC. Allowed: `auto`, `force`, `disabled` | `auto` |
| `global.compatibility.omitEmptySeLinuxOptions` | Remove `seLinuxOptions` from `securityContexts` when set to an empty object | `false` |

### Common parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `kubeVersion` | Force target Kubernetes version (using Helm capabilities if not set) | `""` |
| `nameOverride` | String to partially override `adminer.fullname` | `""` |
| `fullnameOverride` | String to fully override `adminer.fullname` | `""` |
| `commonLabels` | Labels to add to all deployed objects | `{}` |
| `commonAnnotations` | Annotations to add to all deployed objects | `{}` |
| `clusterDomain` | Default Kubernetes cluster domain | `cluster.local` |
| `extraDeploy` | Array of extra objects to deploy with the release | `[]` |
| `diagnosticMode.enabled` | Enable diagnostic mode (all probes will be disabled and the command will be overridden) | `false` |
| `diagnosticMode.command` | Command to override all containers in the deployment | `["sleep"]` |
| `diagnosticMode.args` | Args to override all containers in the deployment | `["infinity"]` |

### Adminer Image parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `image.registry` | Adminer image registry | `docker.io` |
| `image.repository` | Adminer image repository | `adminer` |
| `image.tag` | Adminer image tag (immutable tags are recommended) | `5.4.2-standalone` |
| `image.pullPolicy` | Adminer image pull policy | `IfNotPresent` |
| `image.pullSecrets` | Specify docker-registry secret names as an array | `[]` |
| `image.debug` | Specify if debug logs should be enabled | `false` |

### Adminer Configuration parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `config.plugins` | List of Adminer plugins to enable. YAML list (preferred) or pre-formatted space-separated string. The `adminer.config.plugins` helper joins lists for `ADMINER_PLUGINS`. | `[]` |
| `config.design` | Bundled Adminer design name (`ADMINER_DESIGN`) | `pepa-linha` |
| `config.externalserver` | **[DEPRECATED — use `config.defaultServer`]** Default upstream database server. Kept as fallback via the `adminer.config.defaultServer` helper. Slated for removal in 2.0. | `""` |
| `config.defaultServer` | Default value for the "Server" field on the login screen (`ADMINER_DEFAULT_SERVER`) | `""` |
| `config.defaultDriver` | Default value for the "System" field (`ADMINER_DEFAULT_DRIVER`). Recognised by login-servers / login-password-less plugins and derivative images. | `""` |
| `config.defaultUsername` | Default value for the "Username" field (`ADMINER_DEFAULT_USERNAME`). Requires a compatible plugin or derivative image. | `""` |
| `config.defaultPassword` | Default value for the "Password" field (`ADMINER_DEFAULT_PASSWORD`). Requires a compatible plugin or derivative image; consider sourcing from a Secret via `extraEnvVarsSecret`. | `""` |
| `config.defaultDatabase` | Default value for the "Database" field (`ADMINER_DEFAULT_DATABASE`). Requires a compatible plugin or derivative image. | `""` |
| `config.autoLogin` | Auto-submit the login form when used with login-servers / login-password-less plugins (`ADMINER_AUTO_LOGIN`) | `false` |
| `config.permanentLogin` | Persist the Adminer login session across browser restarts (`ADMINER_PERMANENT_LOGIN`) | `false` |
| `config.baseUrl` | Base URL Adminer is served from (`ADMINER_BASE_URL`). Used when running behind a path-based reverse proxy. | `""` |
| `configuration` | Inline Adminer configuration file content (rendered into a ConfigMap) | `""` |
| `existingConfigmap` | Name of existing ConfigMap with Adminer configuration. When set, the chart-rendered env-vars ConfigMap is skipped and the Deployment's `envFrom` references this CM. | `""` |
| `extraStartupArgs` | Extra default startup args | `""` |
| `extraFlags` | Adminer additional command line flags | `""` |
| `initdbScripts` | Dictionary of initdb scripts to run at first boot | `{}` |
| `initdbScriptsConfigMap` | ConfigMap with the initdb scripts (overrides `initdbScripts`) | `""` |
| `extraEnvVars` | Extra environment variables to be set on Adminer containers | `[]` |
| `extraEnvVarsCM` | Name of existing ConfigMap containing extra env vars | `""` |
| `extraEnvVarsSecret` | Name of existing Secret containing extra env vars | `""` |

### Adminer Authentication parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `auth.existingSecret` | An already existing Secret containing auth info | `""` |
| `auth.existingSecretPerPassword` | Override `existingSecret` and other secret values per-key | `{}` |

### Deployment / Workload parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `replicaCount` | Number of Adminer pods. Ignored when `horizontalPodAutoscaler.enabled` is true. | `1` |
| `horizontalPodAutoscaler.enabled` | Render an HPA and skip setting `replicas` on the Deployment | `false` |
| `horizontalPodAutoscaler.minReplicas` | Lower bound for HPA-managed replica count | `1` |
| `horizontalPodAutoscaler.maxReplicas` | Upper bound for HPA-managed replica count | `5` |
| `horizontalPodAutoscaler.targetCPU` | Target average CPU utilization (percent). Set to `""` to disable CPU-based scaling. | `80` |
| `horizontalPodAutoscaler.targetMemory` | Target average memory utilization (percent). Set to `""` to disable memory-based scaling. | `80` |
| `horizontalPodAutoscaler.metrics` | Full HPA `metrics` list passthrough. When non-empty, takes precedence over `targetCPU`/`targetMemory`. | `[]` |
| `revisionHistoryLimit` | Number of old ReplicaSets retained for rollback | `1` |
| `updateStrategy.type` | Update strategy for the Adminer Deployment | `RollingUpdate` |
| `schedulerName` | Alternative scheduler | `""` |
| `terminationGracePeriodSeconds` | Time in seconds the Adminer pod has to terminate gracefully | `""` |
| `priorityClassName` | Priority class name | `""` |
| `hostAliases` | Add deployment host aliases | `[]` |
| `deploymentAnnotations` | Annotations to add to the deployment | `{}` |

### Pod parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `automountServiceAccountToken` | Mount Service Account token in pod | `false` |
| `podLabels` | Extra labels for Adminer pods | `{}` |
| `podAnnotations` | Adminer pod annotations | `{}` |
| `podAffinityPreset` | Pod affinity preset. Ignored if `affinity` is set. Allowed: `soft`, `hard` | `""` |
| `podAntiAffinityPreset` | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed: `soft`, `hard` | `soft` |
| `nodeAffinityPreset.type` | Node affinity preset type. Allowed: `soft`, `hard` | `""` |
| `nodeAffinityPreset.key` | Node label key to match. Ignored if `affinity` is set. | `""` |
| `nodeAffinityPreset.values` | Node label values to match. Ignored if `affinity` is set. | `[]` |
| `affinity` | Affinity for Adminer pods (overrides the presets above) | `{}` |
| `nodeSelector` | Node labels for Adminer pods assignment | `{}` |
| `tolerations` | Tolerations for Adminer pods assignment | `[]` |
| `topologySpreadConstraints` | Topology Spread Constraints for Adminer pods assignment | `{}` |

### Container parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `command` | Override the default container command. Ignored when `diagnosticMode.enabled`. | `[]` |
| `args` | Override the default container args. Ignored when `diagnosticMode.enabled`. | `[]` |
| `lifecycleHooks` | Lifecycle hooks for the Adminer container(s) | `{}` |
| `containerPorts.http` | Adminer HTTP container port | `8080` |
| `containerPorts.https` | Adminer HTTPS container port | `8443` |
| `extraPorts` | Extra ports for container deployment | `[]` |
| `podSecurityContext.enabled` | Enable security context for Adminer pods | `false` |
| `podSecurityContext.fsGroup` | Group ID for the mounted volumes' filesystem | `101` |
| `podSecurityContext.runAsUser` | User ID for the Adminer pod | `101` |
| `containerSecurityContext.enabled` | Enable Adminer container `securityContext` | `false` |
| `containerSecurityContext.capabilities` | Linux capabilities to add/drop | `{}` |
| `containerSecurityContext.runAsUser` | User ID for the Adminer container | `101` |
| `containerSecurityContext.runAsNonRoot` | Set Adminer container's `runAsNonRoot` | `true` |
| `containerSecurityContext.readOnlyRootFilesystem` | Mount the container's root filesystem as read-only | `false` |
| `containerSecurityContext.allowPrivilegeEscalation` | Block child processes from gaining more privileges than the parent | `false` |
| `containerSecurityContext.seccompProfile` | Seccomp profile applied to the container | `{"type":"RuntimeDefault"}` |
| `resourcesPreset` | Container resources from a common preset (`none`, `nano`, `micro`, `small`, `medium`, `large`, `xlarge`, `2xlarge`, `gs-3xsmall`, …). Ignored if `resources` is set. | `gs-3xsmall` |
| `resources` | Container requests and limits (essential for production workloads) | `{}` |
| `startupProbe.enabled` | Enable startupProbe | `false` |
| `startupProbe.initialDelaySeconds` | Initial delay seconds for startupProbe | `120` |
| `startupProbe.periodSeconds` | Period seconds for startupProbe | `15` |
| `startupProbe.timeoutSeconds` | Timeout seconds for startupProbe | `5` |
| `startupProbe.failureThreshold` | Failure threshold for startupProbe | `10` |
| `startupProbe.successThreshold` | Success threshold for startupProbe | `1` |
| `livenessProbe.enabled` | Enable livenessProbe | `true` |
| `livenessProbe.initialDelaySeconds` | Initial delay seconds for livenessProbe | `120` |
| `livenessProbe.periodSeconds` | Period seconds for livenessProbe | `60` |
| `livenessProbe.timeoutSeconds` | Timeout seconds for livenessProbe | `2` |
| `livenessProbe.failureThreshold` | Failure threshold for livenessProbe | `3` |
| `livenessProbe.successThreshold` | Success threshold for livenessProbe | `1` |
| `readinessProbe.enabled` | Enable readinessProbe | `true` |
| `readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe | `10` |
| `readinessProbe.periodSeconds` | Period seconds for readinessProbe | `10` |
| `readinessProbe.timeoutSeconds` | Timeout seconds for readinessProbe | `1` |
| `readinessProbe.failureThreshold` | Failure threshold for readinessProbe | `3` |
| `readinessProbe.successThreshold` | Success threshold for readinessProbe | `1` |
| `customStartupProbe` | Override default startup probe | `{}` |
| `customLivenessProbe` | Override default liveness probe | `{}` |
| `customReadinessProbe` | Override default readiness probe | `{}` |
| `startupWaitOptions` | Override default builtin startup wait check options | `{}` |
| `extraVolumes` | Additional volumes attached to the Adminer pod | `[]` |
| `extraVolumeMounts` | Additional volume mounts attached to the Adminer container | `[]` |
| `sidecars` | Additional sidecar containers added to the Adminer pod | `[]` |

### Persistence parameters

PVC consumed by `templates/PersistentVolumeClaim.yaml` and auto-mounted into the Adminer container at `persistence.mountPath`. Adminer is stateless, so this is opt-in — typical use cases are persisting plugin/extension files or session storage.

| Name | Description | Value |
| ---- | ----------- | ----- |
| `persistence.enabled` | Render a PersistentVolumeClaim AND mount it at `persistence.mountPath`. When false, no PVC is created and the volume/volumeMount are skipped. | `false` |
| `persistence.existingClaim` | Name of an externally-managed PVC. When set, the chart skips its own PVC but still mounts this claim. | `""` |
| `persistence.storageClass` | StorageClass for the PVC. Falls back to `global.storageClass`. Set to `-` to disable dynamic provisioning. | `""` |
| `persistence.accessModes` | List of access modes requested on the PVC | `["ReadWriteOnce"]` |
| `persistence.size` | Storage capacity requested on the PVC | `8Gi` |
| `persistence.mountPath` | Path inside the Adminer container where the PVC is mounted | `/data` |
| `persistence.subPath` | Sub-path within the volume mounted at `mountPath` | `""` |
| `persistence.annotations` | Extra annotations applied to the PVC (merged with `commonAnnotations`) | `{}` |
| `persistence.selector` | Label selector for binding to a specific pre-provisioned PV | `{}` |
| `persistence.dataSource` | Source the PVC clones from (Snapshot or another PVC) | `{}` |

### Metrics parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `metrics.enabled` | Enable metrics collection for the Adminer pod | `false` |
| `metrics.service.annotations` | Extra annotations merged into the Service when `metrics.enabled` is true (e.g. `prometheus.io/scrape: "true"`) | `{}` |
| `metrics.serviceMonitor.enabled` | Create a ServiceMonitor resource for the Prometheus Operator | `false` |
| `metrics.serviceMonitor.namespace` | Namespace in which to create the ServiceMonitor (defaults to release namespace) | `""` |
| `metrics.serviceMonitor.jobLabel` | Label on the target Service used by Prometheus as the job name | `""` |
| `metrics.serviceMonitor.port` | Service port the ServiceMonitor scrapes | `http` |
| `metrics.serviceMonitor.path` | HTTP path the exporter exposes | `/metrics` |
| `metrics.serviceMonitor.interval` | Scrape interval (defaults to Prometheus default if empty) | `""` |
| `metrics.serviceMonitor.scrapeTimeout` | Per-scrape timeout (defaults to Prometheus default if empty) | `""` |
| `metrics.serviceMonitor.honorLabels` | Honor labels coming from the scraped target | `false` |
| `metrics.serviceMonitor.labels` | Extra labels for the ServiceMonitor resource | `{}` |
| `metrics.serviceMonitor.annotations` | Extra annotations for the ServiceMonitor resource | `{}` |
| `metrics.serviceMonitor.selector` | Selector to filter which Services this ServiceMonitor matches | `{}` |
| `metrics.serviceMonitor.relabelings` | RelabelConfigs to apply before scraping | `[]` |
| `metrics.serviceMonitor.metricRelabelings` | MetricRelabelConfigs to apply on collected samples | `[]` |
| `metrics.serviceMonitor.tlsConfig` | TLS configuration for the scrape endpoint (switches scheme to https) | `{}` |
| `metrics.serviceMonitor.endpoints` | Full endpoint definitions; overrides the single-endpoint shorthand | `[]` |

### Traffic Exposure parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `service.type` | Adminer Kubernetes service type | `ClusterIP` |
| `service.ports.http` | Adminer Kubernetes service HTTP port | `8080` |
| `service.ports.https` | Adminer Kubernetes service HTTPS port | `8443` |
| `service.nodePorts.http` | Service HTTP node port (NodePort/LoadBalancer) | `""` |
| `service.nodePorts.https` | Service HTTPS node port (NodePort/LoadBalancer) | `""` |
| `service.clusterIP` | Adminer Kubernetes service clusterIP | `""` |
| `service.loadBalancerIP` | `loadBalancerIP` if service type is `LoadBalancer` | `""` |
| `service.ipFamilyPolicy` | Adminer Kubernetes service `ipFamilyPolicy` | `SingleStack` |
| `service.externalTrafficPolicy` | Enable client source IP preservation | `Cluster` |
| `service.loadBalancerClass` | Use a load balancer implementation other than the cloud provider default | `""` |
| `service.loadBalancerSourceRanges` | Addresses allowed when service is `LoadBalancer` | `[]` |
| `service.extraPorts` | Extra ports to expose (normally used with `sidecar` value) | `[]` |
| `service.annotations` | Additional Service annotations | `{}` |
| `service.sessionAffinity` | Session Affinity for Service. `None` or `ClientIP`. | `None` |
| `service.sessionAffinityConfig` | Additional `sessionAffinity` settings | `{}` |
| `ingress.enabled` | Enable ingress record generation for Adminer | `false` |
| `ingress.pathType` | Ingress path type | `ImplementationSpecific` |
| `ingress.apiVersion` | Force Ingress API version (auto-detected if not set) | `""` |
| `ingress.hostname` | Default host for the ingress record | `adminer.local` |
| `ingress.path` | Default path for the ingress record | `/` |
| `ingress.servicePort` | Backend service port to use (`http` or `https`) | `http` |
| `ingress.annotations` | Additional annotations for the Ingress resource | `{}` |
| `ingress.tls` | Enable TLS configuration for the host defined at `ingress.hostname` | `false` |
| `ingress.selfSigned` | Create a TLS secret using self-signed certificates generated by Helm | `false` |
| `ingress.extraHosts` | Additional hostname(s) to be covered with the ingress record | `[]` |
| `ingress.extraPaths` | Additional arbitrary paths added to the ingress under the main host | `[]` |
| `ingress.extraTls` | TLS configuration for additional hostnames | `[]` |
| `ingress.secrets` | Custom TLS certificates as Secrets (PEM format) | `[]` |
| `ingress.ingressClassName` | IngressClass for the Ingress (Kubernetes 1.18+) | `""` |
| `ingress.extraRules` | Additional rules to be covered with this ingress record | `[]` |

### TLS configuration

| Name | Description | Value |
| ---- | ----------- | ----- |
| `tls.enabled` | Enable SSL/TLS encryption for the Adminer HTTP server (in-pod TLS termination) | `false` |
| `tls.autoGenerated` | Create self-signed TLS certificates (PEM only) | `false` |
| `tls.certificatesMountPath` | Where Adminer certificates are mounted | `/app/certs/` |
| `tls.certificatesSecretName` | Name of the Secret that contains the certificates | `""` |
| `tls.certCAFilename` | CA certificate filename in `tls.certificatesSecretName` | `""` |
| `tls.certFilename` | Certificate filename in `tls.certificatesSecretName` | `""` |
| `tls.certKeyFilename` | Certificate key filename in `tls.certificatesSecretName` | `""` |
| `tls.existingSecretName` | Name of the existing Secret containing Adminer server certificates | `""` |
| `tls.usePemCerts` | Use PEM certificates instead of PKCS12 (ignored when `autoGenerated`) | `false` |
| `tls.keyPassword` | Password to access the PEM key | `""` |
| `tls.keystorePassword` | Password to access the PKCS12 keystore | `""` |
| `tls.passwordsSecret` | Existing Secret containing the keystore or PEM key password | `""` |
| `tls.certManager.create` | Render cert-manager `Certificate` resources for any TLS-enabled exposure (ingress and/or gateway) | `false` |
| `tls.certManager.issuerRef` | Reference to the cert-manager Issuer / ClusterIssuer that signs the certificate(s). Default: `{group: cert-manager.io, kind: ClusterIssuer, name: selfsigned-issuer}` | `<see values.yaml>` |
| `tls.certManager.tlsAcme` | Add legacy `kubernetes.io/tls-acme: "true"` annotation to the Ingress | `true` |

### RBAC parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `serviceAccount.create` | Enable creation of a ServiceAccount for Adminer pods | `true` |
| `serviceAccount.name` | Name of the created ServiceAccount (auto-generated from fullname if empty) | `""` |
| `serviceAccount.automountServiceAccountToken` | Auto-mount the SA token in the pod | `false` |
| `serviceAccount.annotations` | Additional annotations for the ServiceAccount | `{}` |
| `rbac.create` | Specify whether RBAC resources should be created and used | `false` |
| `rbac.rules` | Custom RBAC rules | `[]` |
| `networkPolicy.enabled` | Specify whether a NetworkPolicy should be created | `true` |
| `networkPolicy.allowExternal` | Don't require server label for connections | `true` |
| `networkPolicy.allowExternalEgress` | Allow the pod to access any range of port and all destinations | `true` |
| `networkPolicy.extraIngress` | Add extra ingress rules to the NetworkPolicy | `[]` |
| `networkPolicy.extraEgress` | Add extra egress rules to the NetworkPolicy | `[]` |
| `networkPolicy.ingressNSMatchLabels` | Labels to match to allow traffic from other namespaces | `{}` |
| `networkPolicy.ingressNSPodMatchLabels` | Pod labels to match to allow traffic from other namespaces | `{}` |

### Gateway API parameters

| Name | Description | Value |
| ---- | ----------- | ----- |
| `gateway.enabled` | Enable creation of Gateway API / Istio resources to manage incoming traffic | `false` |
| `gateway.implementation` | Implementation to render: `gateway-api` or `istio` | `gateway-api` |
| `gateway.gateway.create` | Create a Gateway API Gateway resource | `false` |
| `gateway.gateway.name` | Name of the Gateway resource (required when `gateway.gateway.create` is true) | `""` |
| `gateway.gateway.namespace` | Namespace for the Gateway resource (defaults to release namespace via helper) | `""` |
| `gateway.clusterDomain` | Cluster domain for the Gateway resource (falls back to top-level `clusterDomain`) | `""` |
| `gateway.serviceAccountName` | Service Account name for the Gateway resource | `""` |
| `gateway.selector` | Gateway instance selector labels | `{}` |
| `gateway.gatewayClassName` | Gateway-API GatewayClass name | `istio` |
| `gateway.listeners` | Override the chart-rendered listener list verbatim | `[]` |
| `gateway.existingGateway` | Name of an existing Gateway resource to attach generated routes to | `~` |
| `gateway.hostnames` | List of hostnames matched by the generated HTTPRoute / VirtualService / Gateway listeners. First entry is the single `hostname` on the gateway-api default HTTPS listener. Empty → matches all; `hosts:` falls back to `["*"]`. | `[]` |
| `gateway.tls.enabled` | Render an HTTPS server (istio) / HTTPS terminate listener (gateway-api). **Mutually exclusive with `tls.enabled`** on the gateway-api path: passthrough wins. | `false` |
| `gateway.tls.existingSecret` | Externally-managed Secret holding TLS material the Gateway HTTPS listener references. Skips the chart's selfSigned/certManager/secrets rendering. | `""` |
| `gateway.tls.selfSigned` | Generate a self-signed TLS Secret in the gateway's namespace via `templates/secret/gateway-tls.yaml` | `false` |
| `gateway.tls.secrets` | Custom TLS certificates rendered as Secrets in the gateway's namespace. Same shape as `ingress.secrets`. | `[]` |
| `gateway.httpRoute.enabled` | Create an HTTPRoute resource attached to the Gateway | `true` |
| `gateway.httpRoute.parentRefs` | Override `parentRefs` for the HTTPRoute. Default: chart-rendered ListenerSet when `gateway.listenerSet.enabled` + `gateway.listenerSet.listeners` are set (and cluster supports it); otherwise the chart's Gateway. | `[]` |
| `gateway.httpRoute.rules.filters` | List of filters to apply (auth, rate limiting, retries, etc.) | `[]` |
| `gateway.httpRoute.rules.matches` | List of HTTP matchers selecting which requests this rule applies to | `[]` |
| `gateway.httpRoute.rules.extraBackendRefs` | Additional backendRefs to route traffic to | `[]` |
| `gateway.httpRoute.extraRules` | Additional rule entries appended to the generated HTTPRoute | `[]` |
| `gateway.httpRoute.existingHTTPRouteName` | Name of an existing HTTPRoute resource to use instead of creating one | `""` |
| `gateway.tlsRoute.parentRefs` | Override `parentRefs` for the TLSRoute (rendered when `tls.enabled` + `gateway-api`). Same defaulting as `gateway.httpRoute.parentRefs`. | `[]` |
| `gateway.virtualService.existingVirtualService` | Name of an existing Istio VirtualService to use instead of creating one | `""` |
| `gateway.virtualService.http` | Istio VirtualService `http` rules (full istio HTTPRoute schema). Default routes prefix `/` to the chart's Service. | `[]` |
| `gateway.listenerSet.enabled` | Create a ListenerSet attached to the parent Gateway (silently skipped unless `listeners` is also non-empty) | `false` |
| `gateway.listenerSet.parentRef` | Override the parent Gateway reference (defaults to this release's Gateway) | `{}` |
| `gateway.listenerSet.listeners` | Listeners attached to the parent Gateway (same shape as `Gateway.spec.listeners`) | `[]` |
| `gateway.referenceGrant.enabled` | Create a ReferenceGrant for cross-namespace references | `false` |
| `gateway.referenceGrant.from` | Source resource references granted access (default: HTTPRoutes from gateway namespace) | `[]` |
| `gateway.referenceGrant.to` | Target resources permitted to be referenced (default: this chart's Service) | `[]` |
| `gateway.mesh.enabled` | Enable Ambient Mesh integration for the workload | `false` |
| `gateway.waypoint.enabled` | Enable Kubernetes Gateway API waypoint | `false` |
| `gateway.waypoint.type` | Waypoint traffic types: `service`, `workload`, `all`, `none` | `service` |
| `gateway.waypoint.gatewayClassName` | GatewayClass for the Waypoint Gateway | `istio-waypoint` |
| `gateway.waypoint.extraListeners` | Extra listeners associated with the Waypoint Gateway | `[]` |
| `gateway.authorizationPolicy.enabled` | Create an AuthorizationPolicy for traffic through the Gateway | `true` |
| `gateway.authorizationPolicy.rules.allowAll` | Allow all traffic through the Gateway | `false` |
| `gateway.authorizationPolicy.rules.denyAll` | Deny all traffic through the Gateway | `false` |
| `gateway.authorizationPolicy.rules.allow` | List of allow rules in the AuthorizationPolicy | `[]` |
| `gateway.authorizationPolicy.rules.deny` | List of deny rules in the AuthorizationPolicy | `[]` |

### Miscellaneous

| Name | Description | Value |
| ---- | ----------- | ----- |
| `organization` | Organization label rendered into chart metadata | `Startechnica` |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
helm install adminer \
    --set imagePullPolicy=Always \
    startechnica/adminer
```

The above command sets the `imagePullPolicy` to `Always`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
helm install adminer startechnica/adminer -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Configuration and installation details

### Adding extra environment variables

In case you want to add extra environment variables (useful for advanced operations like custom init scripts), you can use the `extraEnvVars` property.

```yaml
extraEnvVars:
  - name: LOG_LEVEL
    value: error
```

Alternatively, you can use a ConfigMap or a Secret with the environment variables. To do so, use the `extraEnvVarsCM` or the `extraEnvVarsSecret` values.

### Use Sidecars and Init Containers
If additional containers are needed in the same pod (such as additional metrics or logging exporters), they can be defined using the `sidecars` config parameter. Similarly, extra init containers can be added using the `initContainers` parameter.

Refer to the chart documentation for more information on, and examples of, configuring and using sidecars and init containers.

### Setting Pod's affinity

This chart allows you to set your custom affinity using the `affinity` parameter. Find more information about Pod's affinity in the [kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity).

### Deploying extra resources

There are cases where you may want to deploy extra objects, such a ConfigMap containing your app's configuration or some extra deployment with a micro service used by your app. For covering this case, the chart allows adding the full specification of other objects using the `extraDeploy` parameter.

## Troubleshooting

Find more information about how to deal with common errors related to Startechnica's Helm charts in [this troubleshooting guide](https://startechnica.github.io/doc/troubleshoot-helm-chart-issues).

## Upgrading

### To 1.0.0 (breaking)

This is a major release. Most users with existing `values.yaml` overrides will
need to migrate the keys below. The full change list is in
[CHANGELOG.md](CHANGELOG.md).

#### 1. cert-manager configuration moved under `tls.certManager.*`

Both `ingress.certManager.*` and the never-released `gateway.tls.certManager.*`
are gone. Use the single canonical block instead — the same flag now triggers
both ingress-namespace and gateway-namespace cert issuance, depending on which
exposures are enabled.

```yaml
# Before
ingress:
  certManager:
    create: true
    issuerRef:
      kind: ClusterIssuer
      name: letsencrypt-prod
    tlsAcme: true

# After
tls:
  certManager:
    create: true
    issuerRef:
      kind: ClusterIssuer
      name: letsencrypt-prod
    tlsAcme: true
```

#### 2. Gateway "bring your own TLS Secret" knob renamed

```yaml
# Before
istio:
  certificate:
    existingSecret: my-tls-secret

# After
gateway:
  tls:
    existingSecret: my-tls-secret
```

The `istio:` top-level block is gone. The new key applies to both
`gateway.implementation: istio` and `gateway-api`.

#### 3. VirtualService SNI passthrough is now auto-derived

`gateway.virtualService.tls` is removed. If you previously hand-authored SNI
routes there, drop them and set `tls.enabled: true` instead — the chart
auto-derives the passthrough rules from `gateway.hostnames` and the backend's
TLS port. If you need exotic per-host rules, set
`gateway.virtualService.existingVirtualService` to a manifest you manage.

#### 4. `config.externalserver` deprecated, prefer `config.defaultServer`

Both still work — `defaultServer` wins when set, falling back to
`externalserver`. The legacy key is slated for removal in 2.0.

#### 5. Gateway-namespace cert-manager Certificate is now opt-in

The previous chart silently rendered a duplicate `Certificate` in the gateway
namespace whenever `ingress.tls + ingress.certManager.create + gateway.enabled`
were all set. After 1.0 you have to opt in explicitly via
`gateway.tls.enabled: true` (with `tls.certManager.create: true`). If you were
relying on the implicit behaviour, flip those flags.

#### 6. Self-signed CA persists, but rotates exactly once on this upgrade

Users on `ingress.selfSigned: true` (or the new `gateway.tls.selfSigned: true`)
will see the chart-managed CA rotate on the first upgrade to 1.0.0 — there was
no persistent CA Secret in 0.x to recover from. From 1.0 on, the CA is stored
in `<release>-tls-ca` and recovered via `lookup` on every subsequent render,
so clients trusting the CA stay valid across `helm upgrade` and across
ingress↔gateway path migrations.

#### 7. `existingConfigmap` is now actively `envFrom`-mounted

In 0.x `existingConfigmap` was an "I'll handle it" escape hatch the
Deployment didn't actually consume. Now the chart-rendered env-vars ConfigMap
(`templates/configmap/envvars.yaml`) is wired into the Deployment via
`envFrom`, and `existingConfigmap` overrides which CM the `envFrom` points at.
If you set `existingConfigmap: my-cm`, your CM's `data` is loaded into the
Adminer container as env vars on first upgrade — make sure it contains the
keys Adminer expects (`ADMINER_PLUGINS`, `ADMINER_DESIGN`,
`ADMINER_DEFAULT_SERVER`, etc.) or a superset.

#### 8. Inline `ADMINER_*` env vars dropped from the Deployment

For the same reason as #7: those env vars now flow through the env-vars
ConfigMap, not inline `env:` entries. Behaviour is unchanged unless you were
relying on the precedence of inline `env:` over `envFrom` to override
something — in which case set the override via `extraEnvVars` (which still
renders inline and still wins over `envFrom`).

#### 9. HTTPRoute / TLSRoute now default-attach to the ListenerSet (when one is rendered)

When `gateway.listenerSet.enabled: true` AND `gateway.listenerSet.listeners`
is non-empty (and the cluster supports a ListenerSet API), the chart-rendered
HTTPRoute and TLSRoute now default their `parentRefs` to the chart's
ListenerSet instead of the Gateway. This is the canonical Gateway API pattern:
a ListenerSet's listeners only accept routes that target the ListenerSet — a
route still attached to the Gateway directly will silently match the Gateway's
own listeners, not the ListenerSet's, which is almost never what you want.

The default falls back to the Gateway when ListenerSet isn't in play, so users
not using ListenerSet are unaffected. Explicit `parentRefs` continue to win.

If you previously had `gateway.listenerSet.enabled: true` AND were relying on
the HTTPRoute / TLSRoute attaching to the parent Gateway (not the
ListenerSet), pin the previous behaviour explicitly:

```yaml
# Before (implicit Gateway attachment)
gateway:
  listenerSet:
    enabled: true
    listeners:
      - name: extra-http
        port: 8080
        protocol: HTTP
  httpRoute:
    parentRefs: []  # defaulted to Gateway

# After — to keep the old behaviour
gateway:
  listenerSet:
    enabled: true
    listeners:
      - name: extra-http
        port: 8080
        protocol: HTTP
  httpRoute:
    parentRefs:
      - group: gateway.networking.k8s.io
        kind: Gateway
        name: my-release-gateway   # whatever st-common.gateway.fullname resolves to
        namespace: my-gateway-ns
  tlsRoute:
    parentRefs:
      - group: gateway.networking.k8s.io
        kind: Gateway
        name: my-release-gateway
        namespace: my-gateway-ns
```

`gateway.tlsRoute.parentRefs` is new in 1.0.0; same shape and semantics as
`gateway.httpRoute.parentRefs`.

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
