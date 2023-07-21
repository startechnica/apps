<!--- app-name: Adminer -->

# Helm chart for Adminer

Adminer (formerly phpMinAdmin) is a full-featured database management tool written in PHP. Conversely to phpMyAdmin, it consist of a single file ready to deploy to the target server. Adminer is available for MySQL, PostgreSQL, SQLite, MS SQL, Oracle, Firebird, SimpleDB, Elasticsearch and MongoDB.

[Overview of Adminer](https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/)

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
   
   
### Adminer parameters

| Name                                          | Description                                                                                                              | Value                          |
| --------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------| ------------------------------ |
| `image.registry`                              | Adminer image registry                                                                                                   | `docker.io`                    |
| `image.repository`                            | Adminer image repository                                                                                                 | `adminer`                      |
| `image.tag`                                   | Adminer image tag (immutable tags are recommended)                                                                       | `4.8.1-standalone`             |
| `image.digest`                                | Adminer image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag                  | `""`                           |
| `image.pullPolicy`                            | Adminer image pull policy                                                                                                | `IfNotPresent`                 |
| `image.pullSecrets`                           | Specify docker-registry secret names as an array                                                                         | `[]`                           |
| `image.debug`                                 | Set to true if you would like to see extra information on logs                                                           | `false`                        |
| `replicaCount`                                | Number of Adminer pods to run                                                                                            | `1`                            |
| `hostAliases`                                 | Deployment pod host aliases                                                                                              | `[]`                           |
| `command`                                     | Override default container command (useful when using custom images)                                                     | `[]`                           |
| `args`                                        | Override default container args (useful when using custom images)                                                        | `[]`                           |
| `extraEnvVars`                                | Extra environment variables to be set on Adminer containers                                                              | `[]`                           |
| `extraEnvVarsCM`                              | ConfigMap with extra environment variables                                                                               | `""`                           |
| `extraEnvVarsSecret`                          | Secret with extra environment variables                                                                                  | `""`                           |
| `rbac.create`                                 | Specify whether RBAC resources should be created and used                                                                | `false`                        |
| `rbac.rules`                                  |                                                                                                                          | `[]`                           |
| `serviceAccount.create`                       | Specify whether a ServiceAccount should be created                                                                       | `false`                        |
| `serviceAccount.name`                         | Name of the service account to use. If not set and create is true, a name is generated using the fullname template.      | `""`                           |
| `serviceAccount.automountServiceAccountToken` | Automount service account token for the server service account                                                           | `false`                        |
| `serviceAccount.annotations`                  | Annotations for service account. Evaluated as a template. Only used if `create` is `true`.                               | `{}`                           |
| `command`                                     | Override default container command (useful when using custom images)                                                     | `[]`                           |
| `extraEnvVars`                                | Array containing extra env vars to configure Adminer                                                               | `[]`                           |
| `extraEnvVarsCM`                              | ConfigMap containing extra env vars to configure Adminer                                                           | `""`                           |
| `extraEnvVarsSecret`                          | Secret containing extra env vars to configure Adminer                                                              | `""`                           |
| `podSecurityContext.enabled`                  | Enable security context                                                                                                  | `true`                         |
| `containerSecurityContext.enabled`            | Enabled Adminer container Security Context                                                                         | `true`                         |
| `containerSecurityContext.allowPrivilegeEscalation`   |                                                                                                                  | `false`                        |
| `containerSecurityContext.capabilities`       |                                                                                                                          | `{}`                          |
| `containerSecurityContext.capabilities.drop`  |                                                                                                                          | `[ALL]`                        |
| `containerSecurityContext.privileged`         |                                                                                                                          | `false`                        |
| `containerSecurityContext.readOnlyRootFilesystem`     |                                                                                                                  | `true`                         |
| `containerSecurityContext.runAsGroup`         | Set Adminer container Security Context runAsGroup                                                                  | `1337`                         |
| `containerSecurityContext.runAsUser`          | Set Adminer container Security Context runAsUser                                                                   | `1337`                         |
| `containerSecurityContext.runAsNonRoot`       | Set Adminer container Security Context runAsNonRoot                                                                | `true`                         |
| `tls.enabled`                                 | Enable TLS support for gateway traffic                                                                                   | `false`                        |
| `tls.autoGenerated`                           | Generate automatically self-signed TLS certificates                                                                      | `false`                        |
| `tls.certificatesSecret`                      | Name of the secret that contains the certificates                                                                        | `""`                           |
| `tls.certFilename`                            | Certificate filename                                                                                                     | `""`                           |
| `tls.certKeyFilename`                         | Certificate key filename                                                                                                 | `""`                           |
| `tls.certCAFilename`                          | CA Certificate filename                                                                                                  | `""`                           |
| `extraFlags`                                  | Adminer additional command line flags                                                                              | `""`                           |
| `podLabels`                                   | Extra labels for Adminer pods                                                                                      | `{}`                           |
| `podAnnotations`                              | Annotations for Adminer  pods                                                                                      | `{}`                           |
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
| `containerPorts.http`                         | HTTP/2 container port                                                                                                    | `80`                           |
| `containerPorts.https`                        | HTTPS/TLS container port                                                                                                 | `443`                          |
| `containerPorts.status`                       | Status container port                                                                                                    | `15021`                        |
| `priorityClassName`                           | Priority Class Name for Deployment                                                                                       | `""`                           |
| `runtimeClassName`                            | Runtime Class for Adminer pods                                                                                     | `""`                           |
| `initContainers`                              | Additional init containers (this value is evaluated as a template)                                                       | `[]`                           |
| `sidecars`                                    | Add additional sidecar containers (this value is evaluated as a template)                                                | `[]`                           |
| `extraVolumes`                                | Extra volumes                                                                                                            | `[]`                           |
| `extraVolumeMounts`                           | Mount extra volume(s)                                                                                                    | `[]`                           |
| `resources.limits`                            | The resources limits for the container                                                                                   | `{}`                           |
| `resources.limits.cpu`                        | CPU resources limits for the container                                                                                   | `2000m`                        |
| `resources.limits.memory`                     | Memory resources limits for the container                                                                                | `1024Mi`                       |
| `resources.requests`                          | The requested resources for the container                                                                                | `{}`                           |
| `resources.requests.cpu`                      | CPU requested resources for the container                                                                                | `100m`                         |
| `resources.requests.memory`                   | Memory requested resources for the container                                                                             | `128Mi`                        |
| `livenessProbe.enabled`                       | Turn on and off liveness probe                                                                                           | `false`                        |
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
| `startupProbe.enabled`                        | Turn on and off startup probe                                                                                            | `true`                         |
| `startupProbe.initialDelaySeconds`            | Delay before startup probe is initiated                                                                                  | `120`                          |
| `startupProbe.periodSeconds`                  | How often to perform the probe                                                                                           | `10`                           |
| `startupProbe.timeoutSeconds`                 | When the probe times out                                                                                                 | `1`                            |
| `startupProbe.failureThreshold`               | Minimum consecutive failures for the probe                                                                               | `30`                           |
| `startupProbe.successThreshold`               | Minimum consecutive successes for the probe                                                                              | `1`                            |
| `customStartupProbe`                          | Custom startup probe for the Adminer component                                                                           | `{}`                           |
| `customLivenessProbe`                         | Custom liveness probe for the Adminer component                                                                          | `{}`                           |
| `customReadinessProbe`                        | Custom rediness probe for the Adminer component                                                                          | `{}`                           |

### Traffic exposure parameters

| Name                                          | Description                                                                                                              | Value                    |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | ------------------------ |
| `service.type`                                | Kubernetes service type                                                                                                  | `""`                     |
| `service.ports.http`                          | Adminer HTTP/2 service port                                                                                              | `8080`                   |
| `service.nodePorts.http`                      | Specify the nodePort value for the `LoadBalancer` and `NodePort` service types.                                          | `""`                     |
| `service.extraPorts`                          | Extra ports to expose (normally used with the `sidecar` value)                                                           | `[]`                     |
| `service.externalIPs`                         | External IP list to use with `ClusterIP` service type                                                                    | `[]`                     |
| `service.clusterIP`                           | Specific cluster IP when service type is `ClusterIP`. Use `None` for headless service                                    | `""`                     |
| `service.loadBalancerIP`                      | `loadBalancerIP` if service type is `LoadBalancer`                                                                       | `""`                     |
| `service.ipFamilyPolicy`                      | Adminer Kubernetes service `ipFamilyPolicy` policy                                                                       | `SingleStack`            |
| `service.loadBalancerSourceRanges`            | Addresses that are allowed when svc is `LoadBalancer`                                                                    | `[]`                     |
| `service.externalTrafficPolicy`               | Adminer service external traffic policy                                                                                  | `Cluster`                |
| `service.annotations`                         | Additional annotations for Adminer service                                                                               | `{}`                     |
| `service.sessionAffinity`                     | Session Affinity for Kubernetes service, can be `None` or `ClientIP`                                                     | `None`                   |
| `service.sessionAffinityConfig`               | Additional settings for the sessionAffinity                                                                              | `{}`                     |
| `ingress.enabled`                             | Enable ingress controller resource                                                                                       | `false`                  |
| `ingress.pathType`                            | Ingress Path type                                                                                                        | `ImplementationSpecific` |
| `ingress.apiVersion`                          | Override API Version (automatically detected if not set)                                                                 | `""`                     |
| `ingress.ingressClassName`                    | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)                                            | `""`                     |
| `ingress.hostname`                            | Default host for the ingress resource                                                                                    | `adminer.local`          |
| `ingress.path`                                | The Path to Adminer. You may need to set this to '/*' in order to use this                                               | `/`                      |
| `ingress.annotations`                         | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. | `{}`                     |
| `ingress.tls`                                 | Enable TLS configuration for the hostname defined at ingress.hostname parameter                                          | `false`                  |
| `ingress.extraHosts`                          | The list of additional hostnames to be covered with this ingress record.                                                 | `[]`                     |
| `ingress.extraPaths`                          | Any additional arbitrary paths that may need to be added to the ingress under the main host.                             | `[]`                     |
| `ingress.extraTls`                            | The tls configuration for additional hostnames to be covered with this ingress record.                                   | `[]`                     |
| `ingress.secrets`                             | If you're providing your own certificates, please use this to add the certificates as secrets                            | `[]`                     |
| `ingress.extraRules`                          | Additional rules to be covered with this ingress record                                                                  | `[]`                     |


### Istio gateway/Kubernetes Gateway API parameters

| Name                                       | Description                                                                        | Value             |
| ------------------------------------------ | ---------------------------------------------------------------------------------- | ----------------- |
| `gateway.enabled`                          |                                                                                    | `false`           |
| `gateway.dedicated`                        |                                                                                    | `false`           |
| `gateway.gatewayApi`                       |                                                                                    | `false`           |
| `gateway.name`                             |                                                                                    | `""`              |
| `gateway.namespace`                        |                                                                                    | `""`              |
| `gateway.gatewayClassName`                 |                                                                                    | `istio`           |
| `gateway.listeners`                        |                                                                                    | `[]`              |
| `gateway.existingGateway`                  |                                                                                    | `~`               |
| `gateway.existingVirtualService`           |                                                                                    | `~`               |
| `gateway.extraRoute`                       |                                                                                    | `[]`              |


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