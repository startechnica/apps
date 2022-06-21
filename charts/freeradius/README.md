<!--- app-name: FreeRADIUS -->

# Helm chart for FreeRADIUS

FreeRADIUS is a modular, high performance free RADIUS suite developed and distributed under the GNU General Public License, version 2, and is free for download and use.

[Overview of FreeRADIUS](https://freeradius.org/)

**This chart is not maintained by the upstream project and any issues with the chart should be raised [here](https://github.com/startechnica/apps/issues/new/choose)**

## TL;DR

```bash
$ helm repo add startechnica https://startechnica.github.io/apps
$ helm install my-release startechnica/freeradius
```

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Installing the Chart

To install the chart with the release name `my-release` on `my-release` namespace:

```bash
$ helm repo add startechnica https://startechnica.github.io/apps
$ helm install my-release startechnica/freeradius --namespace my-release --create-namespace
```

These commands deploy FreeRADIUS on the Kubernetes cluster in the default configuration.

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
   
   
### FreeRADIUS parameters

| Name                                          | Description                                                                                                              | Value                          |
| ----------------------------------------------| -------------------------------------------------------------------------------------------------------------------------| -------------------------------|
| `image.registry`                              | FreeRADIUS image registry                                                                                                | `docker.io`                    |
| `image.repository`                            | FreeRADIUS image repository                                                                                              | `freeradius/freeradius-server` |
| `image.tag`                                   | FreeRADIUS image tag (immutable tags are recommended)                                                                    | `3.2.0`                        |
| `image.pullPolicy`                            | FreeRADIUS image pull policy                                                                                             | `IfNotPresent`                 |
| `image.pullSecrets`                           | Specify docker-registry secret names as an array                                                                         | `[]`                           |
| `image.debug`                                 | Set to true if you would like to see extra information on logs                                                           | `false`                        |
| `hostAliases`                                 | Deployment pod host aliases                                                                                              | `[]`                           |
| `command`                                     | Override default container command (useful when using custom images)                                                     | `[]`                           |
| `args`                                        | Override default container args (useful when using custom images)                                                        | `[]`                           |
| `extraEnvVars`                                | Extra environment variables to be set on FreeRADIUS containers                                                           | `[]`                           |
| `extraEnvVarsCM`                              | ConfigMap with extra environment variables                                                                               | `""`                           |
| `extraEnvVarsSecret`                          | Secret with extra environment variables                                                                                  | `""`                           |
| `service.type`                                | Kubernetes service type                                                                                                  | `ClusterIP`                    |
| `service.clusterIP`                           | Specific cluster IP when service type is cluster IP. Use `None` for headless service                                     | `""`                           |
| `service.ports.auth`                          | FreeRADIUS Authentication and Authorization service port                                                                 | `1812`                         |
| `service.ports.acct`                          | FreeRADIUS Accounting service port                                                                                       | `1813`                         |
| `service.ports.coa`                           | FreeRADIUS Coa service port                                                                                              | `3799`                         |
| `service.ports.radsec`                        | FreeRADIUS Radsec service port                                                                                           | `2083`                         |
| `service.ports.status`                        | FreeRADIUS Status service port                                                                                           | `18121`                        |
| `service.nodePorts.auth`                      | Specify the nodePort value for the LoadBalancer and NodePort service types.                                              | `""`                           |
| `service.nodePorts.acct`                      | Specify the nodePort value for the LoadBalancer and NodePort service types.                                              | `""`                           |
| `service.nodePorts.coa`                       | Specify the nodePort value for the LoadBalancer and NodePort service types.                                              | `""`                           |
| `service.nodePorts.radsec`                    | Specify the nodePort value for the LoadBalancer and NodePort service types.                                              | `""`                           |
| `service.nodePorts.status`                    | Specify the nodePort value for the LoadBalancer and NodePort service types.                                              | `""`                           |
| `service.extraPorts`                          | Extra ports to expose (normally used with the `sidecar` value)                                                           | `[]`                           |
| `service.externalIPs`                         | External IP list to use with ClusterIP service type                                                                      | `[]`                           |
| `service.loadBalancerIP`                      | `loadBalancerIP` if service type is `LoadBalancer`                                                                       | `""`                           |
| `service.loadBalancerSourceRanges`            | Addresses that are allowed when svc is `LoadBalancer`                                                                    | `[]`                           |
| `service.externalTrafficPolicy`               | FreeRADIUS service external traffic policy                                                                               | `Cluster`                      |
| `service.annotations`                         | Additional annotations for FreeRADIUS service                                                                            | `{}`                           |
| `service.sessionAffinity`                     | Session Affinity for Kubernetes service, can be "None" or "ClientIP"                                                     | `None`                         |
| `service.sessionAffinityConfig`               | Additional settings for the sessionAffinity                                                                              | `{}`                           |
| `serviceAccount.create`                       | Specify whether a ServiceAccount should be created                                                                       | `false`                        |
| `serviceAccount.name`                         | Name of the service account to use. If not set and create is true, a name is generated using the fullname template.      | `""`                           |
| `serviceAccount.automountServiceAccountToken` | Automount service account token for the server service account                                                           | `false`                        |
| `serviceAccount.annotations`                  | Annotations for service account. Evaluated as a template. Only used if `create` is `true`.                               | `{}`                           |
| `command`                                     | Override default container command (useful when using custom images)                                                     | `[]`                           |
| `extraEnvVars`                                | Array containing extra env vars to configure FreeRADIUS                                                                  | `[]`                           |
| `extraEnvVarsCM`                              | ConfigMap containing extra env vars to configure FreeRADIUS                                                              | `""`                           |
| `extraEnvVarsSecret`                          | Secret containing extra env vars to configure FreeRADIUS                                                                 | `""`                           |
| `rbac.create`                                 | Specify whether RBAC resources should be created and used                                                                | `false`                        |
| `podSecurityContext.enabled`                  | Enable security context                                                                                                  | `true`                         |
| `podSecurityContext.fsGroup`                  | Group ID for the container filesystem                                                                                    | `101`                          |
| `podSecurityContext.runAsUser`                | User ID for the container                                                                                                | `101`                          |
| `containerSecurityContext.enabled`            | Enabled galera's container Security Context                                                                              | `true`                         |
| `containerSecurityContext.runAsUser`          | Set galera's container Security Context runAsUser                                                                        | `101`                          |
| `containerSecurityContext.runAsNonRoot`       | Set galera's container Security Context runAsNonRoot                                                                     | `true`                         |
| `tls.enabled`                                 | Enable TLS support for replication traffic                                                                               | `false`                        |
| `tls.autoGenerated`                           | Generate automatically self-signed TLS certificates                                                                      | `false`                        |
| `tls.certificatesSecret`                      | Name of the secret that contains the certificates                                                                        | `""`                           |
| `tls.certFilename`                            | Certificate filename                                                                                                     | `""`                           |
| `tls.certKeyFilename`                         | Certificate key filename                                                                                                 | `""`                           |
| `tls.certCAFilename`                          | CA Certificate filename                                                                                                  | `""`                           |
| `configuration`                               | Configuration for the FreeRADIUS server                                                                                  | `""`                           |
| `configurationConfigMap`                      | ConfigMap with the FreeRADIUS configuration files (Note: Overrides `configuration`). The value is evaluated as a template. | `""`                         |
| `initdbScripts`                               | Specify dictionary of scripts to be run at first boot                                                                    | `{}`                           |
| `initdbScriptsConfigMap`                      | ConfigMap with the initdb scripts (Note: Overrides `initdbScripts`)                                                      | `""`                           |
| `extraFlags`                                  | FreeRADIUS additional command line flags                                                                                 | `""`                           |
| `replicaCount`                                | Desired number of cluster nodes                                                                                          | `3`                            |
| `updateStrategy.type`                         | updateStrategy for FreeRADIUS Master StatefulSet                                                                         | `RollingUpdate`                |
| `podLabels`                                   | Extra labels for FreeRADIUS pods                                                                                         | `{}`                           |
| `podAnnotations`                              | Annotations for FreeRADIUS  pods                                                                                         | `{}`                           |
| `podAffinityPreset`                           | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                      | `""`                           |
| `podAntiAffinityPreset`                       | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                 | `soft`                         |
| `nodeAffinityPreset.type`                     | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                | `""`                           |
| `nodeAffinityPreset.key`                      | Node label key to match. Ignored if `affinity` is set.                                                                   | `""`                           |
| `nodeAffinityPreset.values`                   | Node label values to match. Ignored if `affinity` is set.                                                                | `[]`                           |
| `affinity`                                    | Affinity for pod assignment                                                                                              | `{}`                           |
| `nodeSelector`                                | Node labels for pod assignment                                                                                           | `{}`                           |
| `tolerations`                                 | Tolerations for pod assignment                                                                                           | `[]`                           |
| `topologySpreadConstraints`                   | Topology Spread Constraints for pods assignment                                                                          | `[]`                           |
| `lifecycleHooks`                              | for the galera container(s) to automate configuration before or after startup                                            | `{}`                           |
| `containerPorts.auth`                         | auth database container port                                                                                             | `1812`                         |
| `containerPorts.acct`                         | acct cluster container port                                                                                              | `1813`                         |
| `containerPorts.coa`                          | coa container port                                                                                                       | `3799`                         |
| `containerPorts.radsec`                       | radsec container port                                                                                                    | `2083`                         |
| `containerPorts.status`                       | status container port                                                                                                    | `18121`                        |
| `persistence.enabled`                         | Enable persistence using PVC                                                                                             | `true`                         |
| `persistence.existingClaim`                   | Provide an existing `PersistentVolumeClaim`                                                                              | `""`                           |
| `persistence.subPath`                         | Subdirectory of the volume to mount                                                                                      | `""`                           |
| `persistence.mountPath`                       | Path to mount the volume at                                                                                              | `/etc/freeradius`              |
| `persistence.selector`                        | Selector to match an existing Persistent Volume (this value is evaluated as a template)                                  | `{}`                           |
| `persistence.storageClass`                    | Persistent Volume Storage Class                                                                                          | `""`                           |
| `persistence.annotations`                     | Persistent Volume Claim annotations                                                                                      | `{}`                           |
| `persistence.labels`                          | Persistent Volume Claim Labels                                                                                           | `{}`                           |
| `persistence.accessModes`                     | Persistent Volume Access Modes                                                                                           | `["ReadWriteOnce"]`            |
| `persistence.size`                            | Persistent Volume Size                                                                                                   | `8Gi`                          |
| `priorityClassName`                           | Priority Class Name for Statefulset                                                                                      | `""`                           |
| `initContainers`                              | Additional init containers (this value is evaluated as a template)                                                       | `[]`                           |
| `sidecars`                                    | Add additional sidecar containers (this value is evaluated as a template)                                                | `[]`                           |
| `extraVolumes`                                | Extra volumes                                                                                                            | `[]`                           |
| `extraVolumeMounts`                           | Mount extra volume(s)                                                                                                    | `[]`                           |
| `resources.limits`                            | The resources limits for the container                                                                                   | `{}`                           |
| `resources.requests`                          | The requested resources for the container                                                                                | `{}`                           |
| `livenessProbe.enabled`                       | Turn on and off liveness probe                                                                                           | `true`                         |
| `livenessProbe.initialDelaySeconds`           | Delay before liveness probe is initiated                                                                                 | `120`                          |
| `livenessProbe.periodSeconds`                 | How often to perform the probe                                                                                           | `10`                           |
| `livenessProbe.timeoutSeconds`                | When the probe times out                                                                                                 | `1`                            |
| `livenessProbe.failureThreshold`              | Minimum consecutive failures for the probe                                                                               | `3`                            |
| `livenessProbe.successThreshold`              | Minimum consecutive successes for the probe                                                                              | `1`                            |
| `readinessProbe.enabled`                      | Turn on and off readiness probe                                                                                          | `true`                         |
| `readinessProbe.initialDelaySeconds`          | Delay before readiness probe is initiated                                                                                | `30`                           |
| `readinessProbe.periodSeconds`                | How often to perform the probe                                                                                           | `10`                           |
| `readinessProbe.timeoutSeconds`               | When the probe times out                                                                                                 | `1`                            |
| `readinessProbe.failureThreshold`             | Minimum consecutive failures for the probe                                                                               | `3`                            |
| `readinessProbe.successThreshold`             | Minimum consecutive successes for the probe                                                                              | `1`                            |
| `startupProbe.enabled`                        | Turn on and off startup probe                                                                                            | `false`                        |
| `startupProbe.initialDelaySeconds`            | Delay before startup probe is initiated                                                                                  | `120`                          |
| `startupProbe.periodSeconds`                  | How often to perform the probe                                                                                           | `10`                           |
| `startupProbe.timeoutSeconds`                 | When the probe times out                                                                                                 | `1`                            |
| `startupProbe.failureThreshold`               | Minimum consecutive failures for the probe                                                                               | `48`                           |
| `startupProbe.successThreshold`               | Minimum consecutive successes for the probe                                                                              | `1`                            |
| `customStartupProbe`                          | Custom liveness probe for the Web component                                                                              | `{}`                           |
| `customLivenessProbe`                         | Custom liveness probe for the Web component                                                                              | `{}`                           |
| `customReadinessProbe`                        | Custom rediness probe for the Web component                                                                              | `{}`                           |
| `podDisruptionBudget.create`                  | Specifies whether a Pod disruption budget should be created                                                              | `false`                        |
| `podDisruptionBudget.minAvailable`            | Minimum number / percentage of pods that should remain scheduled                                                         | `1`                            |
| `podDisruptionBudget.maxUnavailable`          | Maximum number / percentage of pods that may be made unavailable                                                         | `""`                           |
| `metrics.enabled`                             | Start a side-car prometheus exporter                                                                                     | `false`                        |
| `metrics.image.registry`                      | FreeRADIUS Prometheus exporter image registry                                                                            | `""`                           |
| `metrics.image.repository`                    | FreeRADIUS Prometheus exporter image repository                                                                          | `""`                           |
| `metrics.image.tag`                           | FreeRADIUS Prometheus exporter image tag (immutable tags are recommended)                                                | `""`                           |
| `metrics.image.pullPolicy`                    | FreeRADIUS Prometheus exporter image pull policy                                                                         | `IfNotPresent`                 |
| `metrics.image.pullSecrets`                   | FreeRADIUS Prometheus exporter image pull secrets                                                                        | `[]`                           |
| `metrics.extraFlags`                          | FreeRADIUS Prometheus exporter additional command line flags                                                             | `[]`                           |
| `metrics.resources.limits`                    | The resources limits for the container                                                                                   | `{}`                           |
| `metrics.resources.requests`                  | The requested resources for the container                                                                                | `{}`                           |
| `metrics.service.type`                        | Prometheus exporter service type                                                                                         | `ClusterIP`                    |
| `metrics.service.port`                        | Prometheus exporter service port                                                                                         | `9104`                         |
| `metrics.service.annotations`                 | Prometheus exporter service annotations                                                                                  | `{}`                           |
| `metrics.service.loadBalancerIP`              | Load Balancer IP if the Prometheus metrics server type is `LoadBalancer`                                                 | `""`                           |
| `metrics.service.clusterIP`                   | Prometheus metrics service Cluster IP                                                                                    | `""`                           |
| `metrics.service.loadBalancerSourceRanges`    | Prometheus metrics service Load Balancer sources                                                                         | `[]`                           |
| `metrics.service.externalTrafficPolicy`       | Prometheus metrics service external traffic policy                                                                       | `Cluster`                      |
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


### Custom FreeRADIUS application parameters

| Name                                       | Description                                                                                       | Value             |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------- | ----------------- |
| `modsEnabled.sql.enabled`                  |                                                                                                   | `false`           |
| `sitesEnabled.status.port`                 | Git image registry                                                                                | `18121`           |
| `sitesEnabled.status.secret`               | Git image repository                                                                              | `adminsecret`     |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install my-release \
  --set imagePullPolicy=Always \
    startechnica/freeradius
```

The above command sets the `imagePullPolicy` to `Always`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install my-release startechnica/freeradius -f values.yaml
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