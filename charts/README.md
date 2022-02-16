<!--- app-name: FreeRADIUS -->

# FreeRADIUS Helm chart

FreeRADIUS is a modular, high performance free RADIUS suite developed and distributed under the GNU General Public License, version 2, and is free for download and use.

[Overview of FreeRADIUS](https://freeradius.org/)


## TL;DR

```bash
$ helm repo add startechnica https://startechnica.github.io/apps
$ helm install my-release startechnica/freeradius
```

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm repo add startechnica https://startechnica.github.io/apps
$ helm install my-release startechnica/freeradius --namespace my-release --create-namespace
```

These commands deploy FreeRADIUS on the Kubernetes cluster in the default configuration.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --namespace my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Global parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `global.imageRegistry`    | Global Docker image registry                    | `""`  |
| `global.imagePullSecrets` | Global Docker registry secret names as an array | `[]`  |


### Common parameters

| Name                | Description                                                                           | Value           |
| ------------------- | ------------------------------------------------------------------------------------- | --------------- |
| `nameOverride`      | String to partially override nginx.fullname template (will maintain the release name) | `""`            |
| `fullnameOverride`  | String to fully override nginx.fullname template                                      | `""`            |
| `kubeVersion`       | Force target Kubernetes version (using Helm capabilities if not set)                  | `""`            |
| `clusterDomain`     | Kubernetes Cluster Domain                                                             | `cluster.local` |
| `extraDeploy`       | Extra objects to deploy (value evaluated as a template)                               | `[]`            |
| `commonLabels`      | Add labels to all the deployed resources                                              | `{}`            |
| `commonAnnotations` | Add annotations to all the deployed resources                                         | `{}`            |


### FreeRADIUS parameters

| Name                 | Description                                                          | Value                 |
| -------------------- | -------------------------------------------------------------------- | --------------------- |
| `image.registry`     | NGINX image registry                                                 | `docker.io`           |
| `image.repository`   | NGINX image repository                                               | `bitnami/nginx`       |
| `image.tag`          | NGINX image tag (immutable tags are recommended)                     | `1.21.5-debian-10-r3` |
| `image.pullPolicy`   | NGINX image pull policy                                              | `IfNotPresent`        |
| `image.pullSecrets`  | Specify docker-registry secret names as an array                     | `[]`                  |
| `image.debug`        | Set to true if you would like to see extra information on logs       | `false`               |
| `hostAliases`        | Deployment pod host aliases                                          | `[]`                  |
| `command`            | Override default container command (useful when using custom images) | `[]`                  |
| `args`               | Override default container args (useful when using custom images)    | `[]`                  |
| `extraEnvVars`       | Extra environment variables to be set on NGINX containers            | `[]`                  |
| `extraEnvVarsCM`     | ConfigMap with extra environment variables                           | `""`                  |
| `extraEnvVarsSecret` | Secret with extra environment variables                              | `""`                  |


### FreeRADIUS deployment parameters

| Name                                    | Description                                                                               | Value   |
| --------------------------------------- | ----------------------------------------------------------------------------------------- | ------- |
| `replicaCount`                          | Number of NGINX replicas to deploy                                                        | `1`     |
| `podLabels`                             | Additional labels for NGINX pods                                                          | `{}`    |
| `podAnnotations`                        | Annotations for NGINX pods                                                                | `{}`    |
| `podAffinityPreset`                     | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`       | `""`    |
| `podAntiAffinityPreset`                 | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`  | `soft`  |
| `nodeAffinityPreset.type`               | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `""`    |
| `nodeAffinityPreset.key`                | Node label key to match Ignored if `affinity` is set.                                     | `""`    |
| `nodeAffinityPreset.values`             | Node label values to match. Ignored if `affinity` is set.                                 | `[]`    |
| `affinity`                              | Affinity for pod assignment                                                               | `{}`    |
| `nodeSelector`                          | Node labels for pod assignment. Evaluated as a template.                                  | `{}`    |
| `tolerations`                           | Tolerations for pod assignment. Evaluated as a template.                                  | `{}`    |
| `priorityClassName`                     | Priority class name                                                                       | `""`    |
| `podSecurityContext.enabled`            | Enabled NGINX pods' Security Context                                                      | `false` |
| `podSecurityContext.fsGroup`            | Set NGINX pod's Security Context fsGroup                                                  | `1001`  |
| `podSecurityContext.sysctls`            | sysctl settings of the NGINX pods                                                         | `[]`    |
| `containerSecurityContext.enabled`      | Enabled NGINX containers' Security Context                                                | `false` |
| `containerSecurityContext.runAsUser`    | Set NGINX container's Security Context runAsUser                                          | `1001`  |
| `containerSecurityContext.runAsNonRoot` | Set NGINX container's Security Context runAsNonRoot                                       | `true`  |
| `containerPorts.http`                   | Sets http port inside NGINX container                                                     | `8080`  |
| `containerPorts.https`                  | Sets https port inside NGINX container                                                    | `""`    |
| `resources.limits`                      | The resources limits for the NGINX container                                              | `{}`    |
| `resources.requests`                    | The requested resources for the NGINX container                                           | `{}`    |
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
| `autoscaling.enabled`                   | Enable autoscaling for NGINX deployment                                                   | `false` |
| `autoscaling.minReplicas`               | Minimum number of replicas to scale back                                                  | `""`    |
| `autoscaling.maxReplicas`               | Maximum number of replicas to scale out                                                   | `""`    |
| `autoscaling.targetCPU`                 | Target CPU utilization percentage                                                         | `""`    |
| `autoscaling.targetMemory`              | Target Memory utilization percentage                                                      | `""`    |
| `extraVolumes`                          | Array to add extra volumes                                                                | `[]`    |
| `extraVolumeMounts`                     | Array to add extra mount                                                                  | `[]`    |
| `serviceAccount.create`                 | Enable creation of ServiceAccount for nginx pod                                           | `false` |
| `serviceAccount.name`                   | The name of the ServiceAccount to use.                                                    | `""`    |
| `serviceAccount.annotations`            | Annotations for service account. Evaluated as a template.                                 | `{}`    |
| `serviceAccount.autoMount`              | Auto-mount the service account token in the pod                                           | `false` |
| `sidecars`                              | Sidecar parameters                                                                        | `[]`    |
| `sidecarSingleProcessNamespace`         | Enable sharing the process namespace with sidecars                                        | `false` |
| `initContainers`                        | Extra init containers                                                                     | `[]`    |
| `pdb.create`                            | Created a PodDisruptionBudget                                                             | `false` |
| `pdb.minAvailable`                      | Min number of pods that must still be available after the eviction                        | `1`     |
| `pdb.maxUnavailable`                    | Max number of pods that can be unavailable after the eviction                             | `0`     |


### Custom FreeRADIUS application parameters

| Name                                       | Description                                                                                       | Value                  |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------- | ---------------------- |
| `cloneStaticSiteFromGit.enabled`           | Get the server static content from a Git repository                                               | `false`                |
| `cloneStaticSiteFromGit.image.registry`    | Git image registry                                                                                | `docker.io`            |
| `cloneStaticSiteFromGit.image.repository`  | Git image repository                                                                              | `bitnami/git`          |
| `cloneStaticSiteFromGit.image.tag`         | Git image tag (immutable tags are recommended)                                                    | `2.34.1-debian-10-r33` |
| `cloneStaticSiteFromGit.image.pullPolicy`  | Git image pull policy                                                                             | `IfNotPresent`         |
| `cloneStaticSiteFromGit.image.pullSecrets` | Specify docker-registry secret names as an array                                                  | `[]`                   |
| `cloneStaticSiteFromGit.repository`        | Git Repository to clone static content from                                                       | `""`                   |
| `cloneStaticSiteFromGit.branch`            | Git branch to checkout                                                                            | `""`                   |
| `cloneStaticSiteFromGit.interval`          | Interval for sidecar container pull from the Git repository                                       | `60`                   |
| `cloneStaticSiteFromGit.gitClone.command`  | Override default container command for git-clone-repository                                       | `[]`                   |
| `cloneStaticSiteFromGit.gitClone.args`     | Override default container args for git-clone-repository                                          | `[]`                   |
| `cloneStaticSiteFromGit.gitSync.command`   | Override default container command for git-repo-syncer                                            | `[]`                   |
| `cloneStaticSiteFromGit.gitSync.args`      | Override default container args for git-repo-syncer                                               | `[]`                   |
| `cloneStaticSiteFromGit.extraEnvVars`      | Additional environment variables to set for the in the containers that clone static site from git | `[]`                   |
| `cloneStaticSiteFromGit.extraVolumeMounts` | Add extra volume mounts for the Git containers                                                    | `[]`                   |
| `serverBlock`                              | Custom server block to be added to NGINX configuration                                            | `""`                   |
| `existingServerBlockConfigmap`             | ConfigMap with custom server block to be added to NGINX configuration                             | `""`                   |
| `staticSiteConfigmap`                      | Name of existing ConfigMap with the server static site content                                    | `""`                   |
| `staticSitePVC`                            | Name of existing PVC with the server static site content                                          | `""`                   |


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

As an alternative, you can use of the preset configurations for pod affinity, pod anti-affinity, and node affinity available at the [bitnami/common](https://github.com/bitnami/charts/tree/master/bitnami/common#affinity) chart. To do so, set the `podAffinityPreset`, `podAntiAffinityPreset`, or `nodeAffinityPreset` parameters.

### Deploying extra resources

There are cases where you may want to deploy extra objects, such a ConfigMap containing your app's configuration or some extra deployment with a micro service used by your app. For covering this case, the chart allows adding the full specification of other objects using the `extraDeploy` parameter.

### Ingress

This chart provides support for ingress resources. If you have an ingress controller installed on your cluster, such as [nginx-ingress-controller](https://github.com/bitnami/charts/tree/master/bitnami/nginx-ingress-controller) or [contour](https://github.com/bitnami/charts/tree/master/bitnami/contour) you can utilize the ingress controller to serve your application.

To enable ingress integration, please set `ingress.enabled` to `true`.

#### Hosts

Most likely you will only want to have one hostname that maps to this NGINX installation. If that's your case, the property `ingress.hostname` will set it. However, it is possible to have more than one host. To facilitate this, the `ingress.extraHosts` object can be specified as an array. You can also use `ingress.extraTLS` to add the TLS configuration for extra hosts.

For each host indicated at `ingress.extraHosts`, please indicate a `name`, `path`, and any `annotations` that you may want the ingress controller to know about.

For annotations, please see [this document](https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/annotations.md). Not all annotations are supported by all ingress controllers, but this document does a good job of indicating which annotation is supported by many popular ingress controllers.

## Troubleshooting

Find more information about how to deal with common errors related to Bitnami's Helm charts in [this troubleshooting guide](https://docs.bitnami.com/general/how-to/troubleshoot-helm-chart-issues).

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