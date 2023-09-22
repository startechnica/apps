<!--- app-name: Istio Gateway -->

# Helm chart for Istio Gateway (Multi Gateway)

Gateway used to manage inbound and outbound traffic for your mesh, letting you specify which traffic you want to enter or leave the mesh. Gateway configurations are applied to standalone Envoy proxies that are running at the edge of the mesh, rather than sidecar Envoy proxies running alongside your service workloads.

Along with support for Kubernetes Ingress resources, Istio also allows you to configure ingress traffic using either an [Istio Gateway](https://istio.io/latest/docs/concepts/traffic-management/#gateways) or [Kubernetes Gateway](https://gateway-api.sigs.k8s.io/api-types/gateway/) resource. A Gateway provides more extensive customization and flexibility than Ingress, and allows Istio features such as monitoring and route rules to be applied to traffic entering the cluster.

This Helm chart configure Istio to expose a service outside of the service mesh using a `Gateway`.

[Overview of Istio Gateway](https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/)

**This chart is not maintained by the upstream project and any issues with the chart should be raised [here](https://github.com/startechnica/apps/issues/new/choose)**

## TL;DR

```console
helm repo add startechnica https://startechnica.github.io/apps
helm install istio-ingressgateway startechnica/istio-gateway
```

## Prerequisites

- Kubernetes 1.24+
- Helm 3.10.0+

## Installing the Chart

To install the chart with the release name `istio-ingressgateway` on `istio-ingressgateway` namespace:

```console
helm repo add startechnica https://startechnica.github.io/apps
helm install istio-ingressgateway startechnica/istio-gateway --namespace istio-ingressgateway --create-namespace
```

These commands deploy Istio Gateway on the Kubernetes cluster in the default configuration.

> **Tip**: List all releases using `helm list -A`

## Uninstalling the Chart

To uninstall/delete the `istio-ingressgateway` deployment:

```console
helm delete istio-ingressgateway --namespace istio-ingressgateway
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Global parameters

| Name                       | Description                                                                                                             | Value |
| -------------------------  | ----------------------------------------------------------------------------------------------------------------------- | ----- |
| `global.imageRegistry`     | Global Docker image registry                                                                                            | `""`  |
| `global.imagePullSecrets`  | Global Docker registry secret names as an array                                                                         | `[]`  |
| `global.storageClass`      | Global StorageClass for Persistent Volume(s)                                                                            | `""`  |
| `global.namespaceOverride` | Override the namespace for resource deployed by the chart, but can itself be overridden by the local namespaceOverride  | `""`  |


### Common parameters

| Name                       | Description                                                                                                       | Value           |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------- |
| `kubeVersion`              | Force target Kubernetes version (using Helm capabilities if not set)                                              | `""`            |
| `nameOverride`             | String to partially override common.names.fullname template with a string (will prepend the release name)         | `""`            |
| `namespaceOverride`        | String to fully override common.names.namespace                                                                   | `""`            |
| `fullnameOverride`         | String to fully override common.names.fullname template with a string                                             | `""`            |
| `commonAnnotations`        | Annotations to add to all deployed objects                                                                        | `{}`            |
| `commonLabels`             | Labels to add to all deployed objects                                                                             | `{}`            |
| `schedulerName`            | Name of the Kubernetes scheduler (other than default)                                                             | `""`            |
| `clusterDomain`            | Kubernetes DNS Domain name to use                                                                                 | `cluster.local` |
| `extraDeploy`              | Array of extra objects to deploy with the release (evaluated as a template)                                       | `[]`            |
| `diagnosticMode.enabled`   | Enable diagnostic mode (all probes will be disabled and the command will be overridden)                           | `false`         |
| `diagnosticMode.command`   | Command to override all containers in the deployment                                                              | `[]`            |
| `diagnosticMode.args`      | Args to override all containers in the deployment                                                                 | `[]`            |


### Istio common parameters

| Name                       | Description                                                                                                       | Value           |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------- |
| `istioNamespace`           | Istiod namespace                                                                                                  | `istio-system`  |
   
   
### Istio Gateway parameters

| Name                                                   | Description                                                                                                              | Value                          |
| ------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------| ------------------------------ |
| `gateways.enabled`                                     | Enable Istio Gateway                                                                                                     | `true`                         |
| `gateways.name`                                        | Istio Gateway identifier                                                                                                 | `ingressgateway`               |
| `gateways.revision`                                    | Revision is set as 'version' label and part of the resource names when installing multiple control planes.               | `""`                           |
| `gateways.replicaCount`                                | Desired number of pods                                                                                                   | `1`                            |
| `gateways.image.registry`                              | Istio Gateway image registry                                                                                             | `""`                           |
| `gateways.image.repository`                            | Istio Gateway image repository                                                                                           | `""`                           |
| `gateways.image.tag`                                   | Istio Gateway image tag (immutable tags are recommended)                                                                 | `""`                           |
| `gateways.image.digest`                                | Istio Gateway image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag.           | `""`                           |
| `gateways.image.pullPolicy`                            | Istio Gateway image pull policy                                                                                          | `IfNotPresent`                 |
| `gateways.image.pullSecrets`                           | Specify docker-registry secret names as an array                                                                         | `[]`                           |
| `gateways.image.debug`                                 | Set to true if you would like to see extra information on logs                                                           | `false`                        |
| `gateways.hostAliases`                                 | Deployment pod host aliases                                                                                              | `[]`                           |
| `gateways.command`                                     | Override default container command (useful when using custom images)                                                     | `[]`                           |
| `gateways.args`                                        | Override default container args (useful when using custom images)                                                        | `[]`                           |
| `gateways.extraEnvVars`                                | Extra environment variables to be set on Istio Gateway containers                                                        | `[]`                           |
| `gateways.extraEnvVarsCM`                              | ConfigMap with extra environment variables                                                                               | `""`                           |
| `gateways.extraEnvVarsSecret`                          | Secret with extra environment variables                                                                                  | `""`                           |
| `gateways.service.type`                                | Kubernetes service type                                                                                                  | `LoadBalancer`                 |
| `gateways.service.ports.http2`                         | Istio Gateway HTTP/2 service port                                                                                        | `80`                           |
| `gateways.service.ports.https`                         | Istio Gateway HTTPS/TLS service port                                                                                     | `443`                          |
| `gateways.service.ports.status`                        | Istio Gateway Status service port                                                                                        | `15021`                        |
| `gateways.service.nodePorts.http2`                     | Specify the nodePort value for the `LoadBalancer` and `NodePort` service types.                                          | `""`                           |
| `gateways.service.nodePorts.https`                     | Specify the nodePort value for the `LoadBalancer` and `NodePort` service types.                                          | `""`                           |
| `gateways.service.nodePorts.status`                    | Specify the nodePort value for the `LoadBalancer` and `NodePort` service types.                                          | `""`                           |
| `gateways.service.extraPorts`                          | Extra ports to expose (normally used with the `sidecar` value)                                                           | `[]`                           |
| `gateways.service.externalIPs`                         | External IP list to use with `ClusterIP` service type                                                                    | `[]`                           |
| `gateways.service.clusterIP`                           | Specific cluster IP when service type is `ClusterIP`. Use `None` for headless service                                    | `""`                           |
| `gateways.service.loadBalancerIP`                      | `loadBalancerIP` if service type is `LoadBalancer`                                                                       | `""`                           |
| `gateways.service.ipFamilyPolicy`                      | Istio Gateway Kubernetes service `ipFamilyPolicy` policy                                                                 | `SingleStack`                  |
| `gateways.service.loadBalancerSourceRanges`            | Addresses that are allowed when svc is `LoadBalancer`                                                                    | `[]`                           |
| `gateways.service.externalTrafficPolicy`               | Istio Gateway service external traffic policy                                                                            | `Cluster`                      |
| `gateways.service.annotations`                         | Additional annotations for Istio Gateway service                                                                         | `{}`                           |
| `gateways.service.sessionAffinity`                     | Session Affinity for Kubernetes service, can be `None` or `ClientIP`                                                     | `None`                         |
| `gateways.service.sessionAffinityConfig`               | Additional settings for the sessionAffinity                                                                              | `{}`                           |
| `gateways.networkGateway`                              | If specified, the gateway will act as a network gateway for the given network.                                           | `false`                        |
| `gateways.rbac.create`                                 | Specify whether RBAC resources should be created and used                                                                | `true`                         |
| `gateways.rbac.rules`                                  |                                                                                                                          | `[]`                           |
| `gateways.serviceAccount.create`                       | Specify whether a ServiceAccount should be created                                                                       | `true`                         |
| `gateways.serviceAccount.name`                         | Name of the service account to use. If not set and create is true, a name is generated using the fullname template.      | `""`                           |
| `gateways.serviceAccount.automountServiceAccountToken` | Automount service account token for the server service account                                                           | `false`                        |
| `gateways.serviceAccount.annotations`                  | Annotations for service account. Evaluated as a template. Only used if `create` is `true`.                               | `{}`                           |
| `gateways.command`                                     | Override default container command (useful when using custom images)                                                     | `[]`                           |
| `gateways.extraEnvVars`                                | Array containing extra env vars to configure Istio Gateway                                                               | `[]`                           |
| `gateways.extraEnvVarsCM`                              | ConfigMap containing extra env vars to configure Istio Gateway                                                           | `""`                           |
| `gateways.extraEnvVarsSecret`                          | Secret containing extra env vars to configure Istio Gateway                                                              | `""`                           |
| `gateways.podSecurityContext.enabled`                  | Enable security context                                                                                                  | `true`                         |
| `gateways.containerSecurityContext.enabled`            | Enabled Istio Gateway container Security Context                                                                         | `true`                         |
| `gateways.containerSecurityContext.allowPrivilegeEscalation`   |                                                                                                                  | `false`                        |
| `gateways.containerSecurityContext.capabilities`       |                                                                                                                          | `{}}`                          |
| `gateways.containerSecurityContext.capabilities.drop`  |                                                                                                                          | `[ALL]`                        |
| `gateways.containerSecurityContext.privileged`         |                                                                                                                          | `false`                        |
| `gateways.containerSecurityContext.readOnlyRootFilesystem`     |                                                                                                                  | `true`                         |
| `gateways.containerSecurityContext.runAsGroup`         | Set Istio Gateway container Security Context runAsGroup                                                                  | `1337`                         |
| `gateways.containerSecurityContext.runAsUser`          | Set Istio Gateway container Security Context runAsUser                                                                   | `1337`                         |
| `gateways.containerSecurityContext.runAsNonRoot`       | Set Istio Gateway container Security Context runAsNonRoot                                                                | `true`                         |
| `gateways.tls.enabled`                                 | Enable TLS support for gateway traffic                                                                                   | `false`                        |
| `gateways.tls.autoGenerated`                           | Generate automatically self-signed TLS certificates                                                                      | `false`                        |
| `gateways.tls.certificatesSecret`                      | Name of the secret that contains the certificates                                                                        | `""`                           |
| `gateways.tls.certFilename`                            | Certificate filename                                                                                                     | `""`                           |
| `gateways.tls.certKeyFilename`                         | Certificate key filename                                                                                                 | `""`                           |
| `gateways.tls.certCAFilename`                          | CA Certificate filename                                                                                                  | `""`                           |
| `gateways.extraFlags`                                  | Istio Gateway additional command line flags                                                                              | `""`                           |
| `gateways.podLabels`                                   | Extra labels for Istio Gateway pods                                                                                      | `{}`                           |
| `gateways.podAnnotations`                              | Annotations for Istio Gateway  pods                                                                                      | `{}`                           |
| `gateways.podAffinityPreset`                           | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                      | `""`                           |
| `gateways.podAntiAffinityPreset`                       | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                 | `soft`                         |
| `gateways.nodeAffinityPreset.type`                     | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                | `""`                           |
| `gateways.nodeAffinityPreset.key`                      | Node label key to match. Ignored if `affinity` is set.                                                                   | `""`                           |
| `gateways.nodeAffinityPreset.values`                   | Node label values to match. Ignored if `affinity` is set.                                                                | `[]`                           |
| `gateways.affinity`                                    | Affinity for pod assignment                                                                                              | `{}`                           |
| `gateways.nodeSelector`                                | Node labels for pod assignment                                                                                           | `{}`                           |
| `gateways.tolerations`                                 | Tolerations for pod assignment                                                                                           | `[]`                           |
| `gateways.topologySpreadConstraints`                   | Topology Spread Constraints for pods assignment                                                                          | `[]`                           |
| `gateways.lifecycleHooks`                              | for the galera container(s) to automate configuration before or after startup                                            | `{}`                           |
| `gateways.containerPorts.http2`                        | HTTP/2 container port                                                                                                    | `80`                           |
| `gateways.containerPorts.https`                        | HTTPS/TLS container port                                                                                                 | `443`                          |
| `gateways.containerPorts.status`                       | Status container port                                                                                                    | `15021`                        |
| `gateways.priorityClassName`                           | Priority Class Name for Deployment                                                                                       | `""`                           |
| `gateways.runtimeClassName`                            | Runtime Class for Istio Gateway pods                                                                                     | `""`                           |
| `gateways.initContainers`                              | Additional init containers (this value is evaluated as a template)                                                       | `[]`                           |
| `gateways.sidecars`                                    | Add additional sidecar containers (this value is evaluated as a template)                                                | `[]`                           |
| `gateways.extraVolumes`                                | Extra volumes                                                                                                            | `[]`                           |
| `gateways.extraVolumeMounts`                           | Mount extra volume(s)                                                                                                    | `[]`                           |
| `gateways.resources.limits`                            | The resources limits for the container                                                                                   | `{}`                           |
| `gateways.resources.limits.cpu`                        | CPU resources limits for the container                                                                                   | `2000m`                        |
| `gateways.resources.limits.memory`                     | Memory resources limits for the container                                                                                | `1024Mi`                       |
| `gateways.resources.requests`                          | The requested resources for the container                                                                                | `{}`                           |
| `gateways.resources.requests.cpu`                      | CPU requested resources for the container                                                                                | `100m`                         |
| `gateways.resources.requests.memory`                   | Memory requested resources for the container                                                                             | `128Mi`                        |
| `gateways.livenessProbe.enabled`                       | Turn on and off liveness probe                                                                                           | `false`                        |
| `gateways.livenessProbe.initialDelaySeconds`           | Delay before liveness probe is initiated                                                                                 | `120`                          |
| `gateways.livenessProbe.periodSeconds`                 | How often to perform the probe                                                                                           | `10`                           |
| `gateways.livenessProbe.timeoutSeconds`                | When the probe times out                                                                                                 | `1`                            |
| `gateways.livenessProbe.failureThreshold`              | Minimum consecutive failures for the probe                                                                               | `3`                            |
| `gateways.livenessProbe.successThreshold`              | Minimum consecutive successes for the probe                                                                              | `1`                            |
| `gateways.readinessProbe.enabled`                      | Turn on and off readiness probe                                                                                          | `true`                         |
| `gateways.readinessProbe.initialDelaySeconds`          | Delay before readiness probe is initiated                                                                                | `30`                           |
| `gateways.readinessProbe.periodSeconds`                | How often to perform the probe                                                                                           | `10`                           |
| `gateways.readinessProbe.timeoutSeconds`               | When the probe times out                                                                                                 | `1`                            |
| `gateways.readinessProbe.failureThreshold`             | Minimum consecutive failures for the probe                                                                               | `3`                            |
| `gateways.readinessProbe.successThreshold`             | Minimum consecutive successes for the probe                                                                              | `1`                            |
| `gateways.startupProbe.enabled`                        | Turn on and off startup probe                                                                                            | `true`                         |
| `gateways.startupProbe.initialDelaySeconds`            | Delay before startup probe is initiated                                                                                  | `120`                          |
| `gateways.startupProbe.periodSeconds`                  | How often to perform the probe                                                                                           | `10`                           |
| `gateways.startupProbe.timeoutSeconds`                 | When the probe times out                                                                                                 | `1`                            |
| `gateways.startupProbe.failureThreshold`               | Minimum consecutive failures for the probe                                                                               | `30`                           |
| `gateways.startupProbe.successThreshold`               | Minimum consecutive successes for the probe                                                                              | `1`                            |
| `gateways.customStartupProbe`                          | Custom startup probe for the Istio Gateway component                                                                     | `{}`                           |
| `gateways.customLivenessProbe`                         | Custom liveness probe for the Istio Gateway component                                                                    | `{}`                           |
| `gateways.customReadinessProbe`                        | Custom rediness probe for the Istio Gateway component                                                                    | `{}`                           |

### Metrics parameters

| Name                                          | Description                                                                                                              | Value                          |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | ------------------------------ |
| `metrics.enabled`                             | Start a side-car prometheus exporter                                                                                     | `false`                        |
| `metrics.service.annotations`                 | Prometheus exporter service annotations                                                                                  | `{}`                           |
| `metrics.serviceMonitor.enabled`              | if `true`, creates a Prometheus Operator ServiceMonitor (also requires `metrics.enabled` to be `true`)                   | `false`                        |
| `metrics.serviceMonitor.namespace`            | Optional namespace which Prometheus is running in                                                                        | `""`                           |
| `metrics.serviceMonitor.jobLabel`             | The name of the label on the target service to use as the job name in prometheus.                                        | `""`                           |
| `metrics.serviceMonitor.interval`             | How frequently to scrape metrics (use by default, falling back to Prometheus' default)                                   | `""`                           |
| `metrics.serviceMonitor.scrapeTimeout`        | Timeout after which the scrape is ended                                                                                  | `""`                           |
| `metrics.serviceMonitor.selector`             | ServiceMonitor selector labels                                                                                           | `{}`                           |
| `metrics.serviceMonitor.relabelings`          | RelabelConfigs to apply to samples before scraping                                                                       | `[]`                           |
| `metrics.serviceMonitor.metricRelabelings`    | MetricRelabelConfigs to apply to samples before ingestion                                                                | `[]`                           |
| `metrics.serviceMonitor.honorLabels`          | honorLabels chooses the metric's labels on collisions with target labels                                                 | `false`                        |
| `metrics.serviceMonitor.labels`               | ServiceMonitor extra labels                                                                                              | `{}`                           |
| `metrics.prometheusRules.enabled`             | if `true`, creates a Prometheus Operator PrometheusRule (also requires `metrics.enabled` to be `true`, and makes little sense without ServiceMonitor)  | `false`                   |
| `metrics.prometheusRules.additionalLabels`    | Additional labels to add to the PrometheusRule so it is picked up by the operator                                        | `{}`                           |
| `metrics.prometheusRules.rules`               | PrometheusRule rules to configure                                                                                                                                                             | `{}`                      |


### Other parameters

| Name                                       | Description                                                                        | Value             |
| ------------------------------------------ | ---------------------------------------------------------------------------------- | ----------------- |
| `pdb.create`                               | Specifies whether a Pod disruption budget should be created                        | `false`           |
| `pdb.minAvailable`                         | Minimum number / percentage of pods that should remain scheduled                   | `1`               |
| `pdb.maxUnavailable`                       | Maximum number / percentage of pods that may be made unavailable                   | `""`              |
| `autoscaling.enabled`                      | Whether enable horizontal pod autoscaler                                           | `false`           |
| `autoscaling.minReplicas`                  | Configure a minimum amount of pods                                                 | `1`               |
| `autoscaling.maxReplicas`                  | Configure a maximum amount of pods                                                 | `""`              |
| `autoscaling.targetCPU`                    | Define the CPU target to trigger the scaling actions (utilization percentage)      | `80`              |
| `autoscaling.targetMemory`                 | Define the memory target to trigger the scaling actions (utilization percentage)   | `80`              |


### NetworkPolicy parameters

| Name                                                          | Description                                                                                                                            | Value   |
| ------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `networkPolicy.enabled`                                       | Enable network policies                                                                                                                | `false` |
| `networkPolicy.metrics.enabled`                               | Enable network policy for metrics (prometheus)                                                                                         | `false` |
| `networkPolicy.metrics.namespaceSelector`                     | Monitoring namespace selector labels. These labels will be used to identify the prometheus' namespace.                                 | `{}`    |
| `networkPolicy.metrics.podSelector`                           | Monitoring pod selector labels. These labels will be used to identify the Prometheus pods.                                             | `{}`    |
| `networkPolicy.ingressRules.accessOnlyFrom.enabled`           | Enable ingress rule that makes primary mariadb nodes only accessible from a particular origin.                                         | `false` |
| `networkPolicy.ingressRules.accessOnlyFrom.namespaceSelector` | Namespace selector label that is allowed to access the primary node. This label will be used to identified the allowed namespace(s).   | `{}`    |
| `networkPolicy.ingressRules.accessOnlyFrom.podSelector`       | Pods selector label that is allowed to access the primary node. This label will be used to identified the allowed pod(s).              | `{}`    |
| `networkPolicy.ingressRules.accessOnlyFrom.customRules`       | Custom network policy for the primary node.                                                                                            | `[]`    |
| `networkPolicy.egressRules.denyConnectionsToExternal`         | Enable egress rule that denies outgoing traffic outside the cluster, except for DNS (port 53).                                         | `false` |
| `networkPolicy.egressRules.customRules`                       | Custom network policy rule                                                                                                             | `{}`    |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
helm install istio-ingressgateway \
    --set imagePullPolicy=Always \
    startechnica/istio-gateway
```

The above command sets the `imagePullPolicy` to `Always`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
helm install istio-ingressgateway startechnica/istio-gateway -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Configuration and installation details

### Rolling VS Immutable tags

It is strongly recommended to use immutable tags in a production environment. This ensures your deployment does not change automatically if the same tag is updated with a different image.

Istio will release a new chart updating its containers if a new version of the main container, significant changes, or critical vulnerabilities exist.


### Change Istio Gateway version

To modify the Istio Gateway version used in this chart you can specify a [valid image tag](https://hub.docker.com/r/istio/proxyv2/tags) using the `image.tag` parameter. For example, `image.tag=X.Y.Z`. This approach is also applicable to other images like exporters.


### Sidecars and Init Containers

If additional containers are needed in the same pod as Istio Gateway (such as additional metrics or logging exporters), they can be defined using the sidecars parameter.

The Helm chart already includes sidecar containers for the Prometheus exporters. These can be activated by adding the `--set enable-metrics=true` parameter at deployment time. The `sidecars` parameter should therefore only be used for any extra sidecar containers.

Similarly, additional containers can be added to Istio Gateway pods using the `initContainers` parameter.


### Adding extra environment variables

In case you want to add extra environment variables (useful for advanced operations like custom init scripts), you can use the `extraEnvVars` property.

```yaml
extraEnvVars:
  - name: LOG_LEVEL
    value: error
```

Alternatively, you can use a ConfigMap or a Secret with the environment variables. To do so, use the `extraEnvVarsCM` or the `extraEnvVarsSecret` values.


### Setting Pod's affinity

This chart allows you to set your custom affinity using the `affinity` parameter. Find more information about Pod's affinity in the [kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity).


### Deploying extra resources

There are cases where you may want to deploy extra objects, such a ConfigMap containing your app's configuration or some extra deployment with a micro service used by your app. For covering this case, the chart allows adding the full specification of other objects using the `extraDeploy` parameter.


## Troubleshooting

Find more information about how to deal with common errors related to Startechnica's Helm charts in [this troubleshooting guide](https://startechnica.github.io/doc/troubleshoot-helm-chart-issues).

## Upgrading

## License

Copyright &copy; 2023 Startechnica

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.