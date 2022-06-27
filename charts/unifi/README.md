<!--- app-name: UniFi Network -->

# Helm chart for UniFi Network

UniFi Network is a modular, high performance free RADIUS suite developed and distributed under the GNU General Public License, version 2, and is free for download and use.

[Overview of UniFi Network](https://unifi.org/)

**This chart is not maintained by the upstream project and any issues with the chart should be raised [here](https://github.com/startechnica/apps/issues/new/choose)**

## TL;DR

```bash
$ helm repo add startechnica https://startechnica.github.io/apps
$ helm install my-release startechnica/unifi
```

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Dependencies

| Repository	                            | Name	      | Version   |
| --------------------------------------- | ----------- | --------- |
| `https://startechnica.github.io/apps`   | `st-common` | `"*"`     |
| `https://charts.bitnami.com/bitnami`    | `common`    | `"*"`     |
| `https://charts.bitnami.com/bitnami`    | `mongodb`   | `"*"`     |

## Installing the Chart

To install the chart with the release name `my-release` on `my-release` namespace:

```bash
$ helm repo add startechnica https://startechnica.github.io/apps
$ helm install my-release startechnica/unifi --namespace my-release --create-namespace
```

These commands deploy UniFi Network on the Kubernetes cluster in the default configuration.

> **Tip**: List all releases using `helm list -A`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --namespace my-release
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


### UniFi Network Application parameters

| Name                 | Description                                                          | Value                     |
| -------------------- | -------------------------------------------------------------------- | ------------------------- |
| `image.registry`     | UniFi Network image registry                                         | `docker.io`               |
| `image.repository`   | UniFi Network image repository                                       | `jacobalberty/unifi`      |
| `image.tag`          | UniFi Network image tag (immutable tags are recommended)             | `v7.1.66`                 |
| `image.pullPolicy`   | UniFi Network image pull policy                                      | `IfNotPresent`            |
| `image.pullSecrets`  | Specify docker-registry secret names as an array                     | `[]`                      |
| `image.debug`        | Set to true if you would like to see extra information on logs       | `false`                   |
| `hostAliases`        | Deployment pod host aliases                                          | `[]`                      |
| `command`            | Override default container command (useful when using custom images) | `[]`                      |
| `args`               | Override default container args (useful when using custom images)    | `[]`                      |
| `extraEnvVars`       | Extra environment variables to be set on UniFi Network containers    | `[]`                      |
| `extraEnvVarsCM`     | ConfigMap with extra environment variables                           | `""`                      |
| `extraEnvVarsSecret` | Secret with extra environment variables                              | `""`                      |


### UniFi Network Application deployment parameters

| Name                                    | Description                                                                               | Value   |
| --------------------------------------- | ----------------------------------------------------------------------------------------- | ------- |
| `replicaCount`                          | Number of UniFi Network replicas to deploy                                                | `1`     |
| `podLabels`                             | Additional labels for UniFi Network pods                                                  | `{}`    |
| `podAnnotations`                        | Annotations for UniFi Network pods                                                        | `{}`    |
| `podAffinityPreset`                     | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`       | `""`    |
| `podAntiAffinityPreset`                 | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`  | `soft`  |
| `nodeAffinityPreset.type`               | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `""`    |
| `nodeAffinityPreset.key`                | Node label key to match Ignored if `affinity` is set.                                     | `""`    |
| `nodeAffinityPreset.values`             | Node label values to match. Ignored if `affinity` is set.                                 | `[]`    |
| `affinity`                              | Affinity for pod assignment                                                               | `{}`    |
| `nodeSelector`                          | Node labels for pod assignment. Evaluated as a template.                                  | `{}`    |
| `tolerations`                           | Tolerations for pod assignment. Evaluated as a template.                                  | `{}`    |
| `priorityClassName`                     | Priority class name                                                                       | `""`    |
| `podSecurityContext.enabled`            | Enabled UniFi Network pods' Security Context                                              | `false` |
| `podSecurityContext.fsGroup`            | Set UniFi Network pod's Security Context fsGroup                                          | `1001`  |
| `podSecurityContext.sysctls`            | sysctl settings of the UniFi Network pods                                                 | `[]`    |
| `containerSecurityContext.enabled`      | Enabled UniFi Network containers' Security Context                                        | `false` |
| `containerSecurityContext.runAsUser`    | Set UniFi Network container's Security Context runAsUser                                  | `1001`  |
| `containerSecurityContext.runAsNonRoot` | Set UniFi Network container's Security Context runAsNonRoot                               | `true`  |
| `containerPorts.http`                   | Sets http port inside UniFi Network container                                             | `8080`  |
| `containerPorts.https`                  | Sets https port inside UniFi Network container                                            | `""`    |
| `resources.limits`                      | The resources limits for the UniFi Network container                                      | `{}`    |
| `resources.requests`                    | The requested resources for the UniFi Network container                                   | `{}`    |
| `livenessProbe.enabled`                 | Enable livenessProbe                                                                      | `true`  |
| `livenessProbe.initialDelaySeconds`     | Initial delay seconds for livenessProbe                                                   | `30`    |
| `livenessProbe.periodSeconds`           | Period seconds for livenessProbe                                                          | `10`    |
| `livenessProbe.timeoutSeconds`          | Timeout seconds for livenessProbe                                                         | `5`     |
| `livenessProbe.failureThreshold`        | Failure threshold for livenessProbe                                                       | `6`     |
| `livenessProbe.successThreshold`        | Success threshold for livenessProbe                                                       | `1`     |
| `readinessProbe.enabled`                | Enable readinessProbe                                                                     | `true`  |
| `readinessProbe.initialDelaySeconds`    | Initial delay seconds for readinessProbe                                                  | `5`     |
| `readinessProbe.periodSeconds`          | Period seconds for readinessProbe                                                         | `5`     |
| `readinessProbe.timeoutSeconds`         | Timeout seconds for readinessProbe                                                        | `3`     |
| `readinessProbe.failureThreshold`       | Failure threshold for readinessProbe                                                      | `3`     |
| `readinessProbe.successThreshold`       | Success threshold for readinessProbe                                                      | `1`     |
| `customLivenessProbe`                   | Override default liveness probe                                                           | `{}`    |
| `customReadinessProbe`                  | Override default readiness probe                                                          | `{}`    |
| `autoscaling.enabled`                   | Enable autoscaling for UniFi Network deployment                                           | `false` |
| `autoscaling.minReplicas`               | Minimum number of replicas to scale back                                                  | `""`    |
| `autoscaling.maxReplicas`               | Maximum number of replicas to scale out                                                   | `""`    |
| `autoscaling.targetCPU`                 | Target CPU utilization percentage                                                         | `""`    |
| `autoscaling.targetMemory`              | Target Memory utilization percentage                                                      | `""`    |
| `extraVolumes`                          | Array to add extra volumes                                                                | `[]`    |
| `extraVolumeMounts`                     | Array to add extra mount                                                                  | `[]`    |
| `serviceAccount.create`                 | Enable creation of ServiceAccount for unifi pod                                           | `false` |
| `serviceAccount.name`                   | The name of the ServiceAccount to use.                                                    | `""`    |
| `serviceAccount.annotations`            | Annotations for service account. Evaluated as a template.                                 | `{}`    |
| `serviceAccount.autoMount`              | Auto-mount the service account token in the pod                                           | `false` |
| `sidecars`                              | Sidecar parameters                                                                        | `[]`    |
| `sidecarSingleProcessNamespace`         | Enable sharing the process namespace with sidecars                                        | `false` |
| `initContainers`                        | Extra init containers                                                                     | `[]`    |
| `pdb.create`                            | Created a PodDisruptionBudget                                                             | `false` |
| `pdb.minAvailable`                      | Min number of pods that must still be available after the eviction                        | `1`     |
| `pdb.maxUnavailable`                    | Max number of pods that can be unavailable after the eviction                             | `0`     |


### Metrics parameters

| Name                                          | Description                                                                                                              | Value                          |
| ----------------------------------------------| -------------------------------------------------------------------------------------------------------------------------| -------------------------------|
| `metrics.enabled`                             | Start a side-car prometheus exporter                                                                                     | `false`                        |
| `metrics.image.registry`                      | UniFi Prometheus exporter image registry                                                                                 | `"docker.io"`                  |
| `metrics.image.repository`                    | UniFi Prometheus exporter image repository                                                                               | `"golift/unifi-poller"`        |
| `metrics.image.tag`                           | UniFi Prometheus exporter image tag (immutable tags are recommended)                                                     | `"2.1.3"`                      |
| `metrics.image.pullPolicy`                    | UniFi Prometheus exporter image pull policy                                                                              | `IfNotPresent`                 |
| `metrics.image.pullSecrets`                   | UniFi Prometheus exporter image pull secrets                                                                             | `[]`                           |
| `containerSecurityContext.enabled`            | Enabled metrics containers' Security Context                                                                             | `true`                         |
| `containerSecurityContext.runAsUser`          | Set metrics container's Security Context runAsUser                                                                       | `1001`                         |
| `containerSecurityContext.runAsNonRoot`       | Set metrics container's Security Context runAsNonRoot                                                                    | `true`                         |
| `metrics.extraFlags`                          | UniFi Prometheus exporter additional command line flags                                                                  | `[]`                           |
| `metrics.resources.limits`                    | The resources limits for the container                                                                                   | `{}`                           |
| `metrics.resources.requests`                  | The requested resources for the container                                                                                | `{}`                           |
| `metrics.service.annotations`                 | Prometheus exporter service annotations                                                                                  | `{}`                           |
| `metrics.service.clusterIP`                   | Prometheus metrics service Cluster IP                                                                                    | `""`                           |
| `metrics.service.externalTrafficPolicy`       | Prometheus metrics service external traffic policy                                                                       | `Cluster`                      |
| `metrics.service.loadBalancerIP`              | Load Balancer IP if the Prometheus metrics server type is `LoadBalancer`                                                 | `""`                           |
| `metrics.service.loadBalancerSourceRanges`    | Prometheus metrics service Load Balancer sources                                                                         | `[]`                           |
| `metrics.service.nodePorts.http`              | Specify the nodePort value for the LoadBalancer and NodePort service types.                                              | `""`                           |
| `metrics.service.nodePorts.metrics`           | Specify the nodePort value for the LoadBalancer and NodePort service types.                                              | `""`                           |
| `metrics.service.ports.http`                  | Prometheus exporter HTP service port                                                                                     | `37288`                        |
| `metrics.service.ports.metrics`               | Prometheus exporter metrics service port                                                                                 | `9130`                         |
| `metrics.service.type`                        | Prometheus exporter service type                                                                                         | `ClusterIP`                    |
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
| `metrics.prometheusRules.namespace`           | Namespace where prometheusRules resource should be created                                                               | `""`                           |
| `metrics.prometheusRules.rules`               | PrometheusRule rules to configure                                                                                        | `{}`                           |


### Custom UniFi Network application parameters

| Name                                       | Description                                                                                       | Value                  |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------- | ---------------------- |



Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install my-release \
  --set imagePullPolicy=Always \
    startechnica/unifi
```

The above command sets the `imagePullPolicy` to `Always`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install my-release startechnica/unifi -f values.yaml
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

### Setting Pod's affinity

This chart allows you to set your custom affinity using the `affinity` parameter. Find more information about Pod's affinity in the [kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity).

### Deploying extra resources

There are cases where you may want to deploy extra objects, such a ConfigMap containing your app's configuration or some extra deployment with a micro service used by your app. For covering this case, the chart allows adding the full specification of other objects using the `extraDeploy` parameter.

## Troubleshooting

Find more information about how to deal with common errors related to Startechnica's Helm charts in [this troubleshooting guide](https://startechnica.github.io/doc/troubleshoot-helm-chart-issues).

## Upgrading

## License

Copyright &copy; 2022 Startechnica

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.