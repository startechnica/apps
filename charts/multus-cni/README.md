<!--- app-name: Multus CNI -->

# Multus CNI Helm chart

Multus CNI enables attaching multiple network interfaces to pods in Kubernetes.

Multus CNI is a container network interface (CNI) plugin for Kubernetes that enables attaching multiple network interfaces to pods. Typically, in Kubernetes each pod only has one network interface (apart from a loopback) -- with Multus CNI you can create a multi-homed pod that has multiple interfaces. This is accomplished by Multus CNI acting as a "meta-plugin", a CNI plugin that can call multiple other CNI plugins.


## Thin Plugin v.s Thick Plugin
With the multus 4.0 release, Multus introduce a new client/server-style plugin deployment. This new deployment is called 'thick plugin', in contrast to deployments in previous versions, which is now called a 'thin plugin'. The new thick plugin consists of two binaries, multus-daemon and multus-shim CNI plugin. The 'multus-daemon' will be deployed to all nodes as a local agent and supports additional features, such as metrics, which were not available with the 'thin plugin' deployment before. Due to these additional features, the 'thick plugin' comes with the trade-off of consuming more resources than the 'thin plugin'.

We recommend using the thick plugin in most environments.

[Overview of Multus CNI](https://github.com/k8snetworkplumbingwg/multus-cni)

**This chart is not maintained by the upstream project and any issues with the chart should be raised [here](https://github.com/startechnica/apps/issues/new/choose)**

## TL;DR

```console
helm repo add startechnica https://startechnica.github.io/apps
helm install my-release startechnica/multus-cni
```

## Prerequisites

- Kubernetes 1.24+
- Helm 3.10.0+

## Installing the Chart

To install the chart with the release name `my-release` on `my-release` namespace:

```console
helm repo add startechnica https://startechnica.github.io/apps
helm install my-release startechnica/multus-cni --namespace my-release --create-namespace
```

These commands deploy Multus CNI on the Kubernetes cluster in the default configuration.

> **Tip**: List all releases using `helm list -A`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release --namespace my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Global parameters

| Name                       | Description                                                                                                             | Value |
| -------------------------- | -----------------------------------------------                                                                         | ----- |
| `global.imageRegistry`     | Global Docker image registry                                                                                            | `""`  |
| `global.imagePullSecrets`  | Global Docker registry secret names as an array                                                                         | `[]`  |
| `global.storageClass`      | Global StorageClass for Persistent Volume(s)                                                                            | `""`  |
| `global.namespaceOverride` | Override the namespace for resource deployed by the chart, but can itself be overridden by the local namespaceOverride  | `""`  |


### Common parameters

| Name                       | Description                                                                                    | Value           |
| -------------------        | ---------------------------------------------------------------------------------------------- | --------------- |
| `nameOverride`             | String to partially override multus-cni.fullname template (will maintain the release name)     | `""`            |
| `fullnameOverride`         | String to fully override multus-cni.fullname template                                          | `""`            |
| `kubeVersion`              | Force target Kubernetes version (using Helm capabilities if not set)                           | `""`            |
| `clusterDomain`            | Kubernetes Cluster Domain                                                                      | `cluster.local` |
| `extraDeploy`              | Extra objects to deploy (value evaluated as a template)                                        | `[]`            |
| `commonLabels`             | Add labels to all the deployed resources                                                       | `{}`            |
| `commonAnnotations`        | Add annotations to all the deployed resources                                                  | `{}`            |
| `diagnosticMode.enabled`   | Enable diagnostic mode (all probes will be disabled and the command will be overridden)        | `false`         |
| `diagnosticMode.command`   | Command to override all containers in the deployment                                           | `[]`            |
| `diagnosticMode.args`      | Args to override all containers in the deployment                                              | `[]`            |


### Multus CNI parameters

| Name                 | Description                                                                                              | Value                                 |
| -------------------- | --------------------------------------------------------------------                                     | ------------------------------------- |
| `image.registry`     | Multus CNI image registry                                                                                | `ghcr.io`                             |
| `image.repository`   | Multus CNI image repository                                                                              | `k8snetworkplumbingwg/multus-cni`     |
| `image.tag`          | Multus CNI image tag (immutable tags are recommended)                                                    | `latest-thick`                        |
| `image.digest`       | Adminer image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag  | `""`                                  |
| `image.pullPolicy`   | Multus CNI image pull policy                                                                             | `IfNotPresent`                        |
| `image.pullSecrets`  | Specify docker-registry secret names as an array                                                         | `[]`                                  |
| `image.debug`        | Set to true if you would like to see extra information on logs                                           | `false`                               |
| `CNIVersion`         | CNI version                                                                                              | `0.3.1`                               |
| `hostCNIBinDir`      | CNI binary dir in the host machine to mount                                                              | `/opt/cni/bin`                        |
| `hostCNINetDir`      | CNI net.d dir in the host machine to mount                                                               | `/etc/cni/net.d`                      |
| `CNIMountPath`       | Path inside the container to mount the CNI dirs                                                          | `/host`                               |
| `hostAliases`        | Deployment pod host aliases                                                                              | `[]`                                  |
| `command`            | Override default container command (useful when using custom images)                                     | `[]`                                  |
| `args`               | Override default container args (useful when using custom images)                                        | `[]`                                  |
| `extraEnvVars`       | Extra environment variables to be set on Multus CNI containers                                           | `[]`                                  |
| `extraEnvVarsCM`     | ConfigMap with extra environment variables                                                               | `""`                                  |
| `extraEnvVarsSecret` | Secret with extra environment variables                                                                  | `""`                                  |


### Multus CNI deployment parameters

| Name                                          | Description                                                                                                              | Value   |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | ------- |
| `rbac.create`                                 | Specify whether RBAC resources should be created and used                                                                | `false`                        |
| `rbac.rules`                                  |                                                                                                                          | `[]`                           |
| `serviceAccount.create`                       | Specify whether a ServiceAccount should be created                                                                       | `false`                        |
| `serviceAccount.name`                         | Name of the service account to use. If not set and create is true, a name is generated using the fullname template.      | `""`                           |
| `serviceAccount.automountServiceAccountToken` | Automount service account token for the server service account                                                           | `false`                        |
| `serviceAccount.annotations`                  | Annotations for service account. Evaluated as a template. Only used if `create` is `true`.                               | `{}`                           |
| `podLabels`                                   | Additional labels for Multus CNI pods                                                                                    | `{}`    |
| `podAnnotations`                              | Annotations for Multus CNI pods                                                                                          | `{}`    |
| `podAffinityPreset`                           | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                      | `""`    |
| `podAntiAffinityPreset`                       | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                 | `soft`  |
| `nodeAffinityPreset.type`                     | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                | `""`    |
| `nodeAffinityPreset.key`                      | Node label key to match Ignored if `affinity` is set.                                                                    | `""`    |
| `nodeAffinityPreset.values`                   | Node label values to match. Ignored if `affinity` is set.                                                                | `[]`    |
| `affinity`                                    | Affinity for pod assignment                                                                                              | `{}`    |
| `nodeSelector`                                | Node labels for pod assignment. Evaluated as a template.                                                                 | `{}`    |
| `tolerations`                                 | Tolerations for pod assignment. Evaluated as a template.                                                                 | `{}`    |
| `priorityClassName`                           | Priority class name                                                                                                      | `""`    |
| `podSecurityContext.enabled`                  | Enabled Multus CNI pods' Security Context                                                                                | `false` |
| `podSecurityContext.fsGroup`                  | Set Multus CNI pod's Security Context fsGroup                                                                            | `1001`  |
| `podSecurityContext.sysctls`                  | sysctl settings of the Multus CNI pods                                                                                   | `[]`    |
| `containerSecurityContext.enabled`            | Enabled Multus CNI containers' Security Context                                                                          | `false` |
| `containerSecurityContext.runAsUser`          | Set Multus CNI container's Security Context runAsUser                                                                    | `1001`  |
| `containerSecurityContext.runAsNonRoot`       | Set Multus CNI container's Security Context runAsNonRoot                                                                 | `true`  |
| `containerPorts.http`                         | Sets http port inside Multus CNI container                                                                               | `8080`  |
| `containerPorts.https`                        | Sets https port inside Multus CNI container                                                                              | `""`    |
| `resources.limits`                            | The resources limits for the Multus CNI container                                                                        | `{}`    |
| `resources.requests`                          | The requested resources for the Multus CNI container                                                                     | `{}`    |
| `livenessProbe.enabled`                       | Enable livenessProbe                                                                                                     | `true`  |
| `livenessProbe.initialDelaySeconds`           | Initial delay seconds for livenessProbe                                                                                  | `30`    |
| `livenessProbe.periodSeconds`                 | Period seconds for livenessProbe                                                                                         | `10`    |
| `livenessProbe.timeoutSeconds`                | Timeout seconds for livenessProbe                                                                                        | `5`     |
| `livenessProbe.failureThreshold`              | Failure threshold for livenessProbe                                                                                      | `6`     |
| `livenessProbe.successThreshold`              | Success threshold for livenessProbe                                                                                      | `1`     |
| `readinessProbe.enabled`                      | Enable readinessProbe                                                                                                    | `true`  |
| `readinessProbe.initialDelaySeconds`          | Initial delay seconds for readinessProbe                                                                                 | `5`     |
| `readinessProbe.periodSeconds`                | Period seconds for readinessProbe                                                                                        | `5`     |
| `readinessProbe.timeoutSeconds`               | Timeout seconds for readinessProbe                                                                                       | `3`     |
| `readinessProbe.failureThreshold`             | Failure threshold for readinessProbe                                                                                     | `3`     |
| `readinessProbe.successThreshold`             | Success threshold for readinessProbe                                                                                     | `1`     |
| `customLivenessProbe`                         | Override default liveness probe                                                                                          | `{}`    |
| `customReadinessProbe`                        | Override default readiness probe                                                                                         | `{}`    |
| `extraVolumes`                                | Array to add extra volumes                                                                                               | `[]`    |
| `extraVolumeMounts`                           | Array to add extra mount                                                                                                 | `[]`    |
| `sidecars`                                    | Sidecar parameters                                                                                                       | `[]`    |
| `sidecarSingleProcessNamespace`               | Enable sharing the process namespace with sidecars                                                                       | `false` |
| `initContainers`                              | Extra init containers                                                                                                    | `[]`    |


### Custom Multus CNI application parameters


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
helm install my-release --set imagePullPolicy=Always startechnica/multus-cni
```

The above command sets the `imagePullPolicy` to `Always`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
helm install my-release startechnica/multus-cni -f values.yaml
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