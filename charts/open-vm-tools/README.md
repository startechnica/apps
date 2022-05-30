<!--- app-name: open-vm-tools -->

# Open VM Tools Helm chart

Open VM Tools (open-vm-tools) is the open source implementation of VMware Tools for Linux guest operating systems.
The open-vm-tools suite is bundled with some Linux operating systems and is installed as a part of the OS, eliminating the need to separately install the suite on guest operating systems. All leading Linux vendors support the open-vm-tools suite on vSphere, Workstation, and Fusion, and bundle open-vm-tools with their product releases. For information about OS compatibility check for the open-vm-tools suite, see the VMware Compatibility Guide at http://www.vmware.com/resources/compatibility.

[Overview of open-vm-tools](https://docs.vmware.com/en/VMware-Tools/12.0.0/com.vmware.vsphere.vmwaretools.doc/GUID-8B6EA5B7-453B-48AA-92E5-DB7F061341D1.html)

**This chart is not maintained by the upstream project and any issues with the chart should be raised [here](https://github.com/startechnica/apps/issues/new/choose)**

## TL;DR

```bash
$ helm repo add startechnica https://startechnica.github.io/apps
$ helm install my-release startechnica/open-vm-tools
```

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Installing the Chart

To install the chart with the release name `my-release` on `my-release` namespace:

```bash
$ helm repo add startechnica https://startechnica.github.io/apps
$ helm install my-release startechnica/open-vm-tools --namespace my-release --create-namespace
```

These commands deploy open-vm-tools on the Kubernetes cluster in the default configuration.

> **Tip**: List all releases using `helm list -A`

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

| Name                | Description                                                                                   | Value           |
| ------------------- | --------------------------------------------------------------------------------------------- | --------------- |
| `nameOverride`      | String to partially override open-vm-tools.fullname template (will maintain the release name) | `""`            |
| `fullnameOverride`  | String to fully override open-vm-tools.fullname template                                      | `""`            |
| `kubeVersion`       | Force target Kubernetes version (using Helm capabilities if not set)                          | `""`            |
| `clusterDomain`     | Kubernetes Cluster Domain                                                                     | `cluster.local` |
| `extraDeploy`       | Extra objects to deploy (value evaluated as a template)                                       | `[]`            |
| `commonLabels`      | Add labels to all the deployed resources                                                      | `{}`            |
| `commonAnnotations` | Add annotations to all the deployed resources                                                 | `{}`            |


### open-vm-tools parameters

| Name                 | Description                                                          | Value                         |
| -------------------- | -------------------------------------------------------------------- | ----------------------------- |
| `image.registry`     | open-vm-tools image registry                                         | `docker.io`                   |
| `image.repository`   | open-vm-tools image repository                                       | `arnegroskurth/open-vm-tools` |
| `image.tag`          | open-vm-tools image tag (immutable tags are recommended)             | `sha-fa19579`                 |
| `image.pullPolicy`   | open-vm-tools image pull policy                                      | `IfNotPresent`                |
| `image.pullSecrets`  | Specify docker-registry secret names as an array                     | `[]`                          |
| `image.debug`        | Set to true if you would like to see extra information on logs       | `false`                       |
| `hostAliases`        | Deployment pod host aliases                                          | `[]`                          |
| `command`            | Override default container command (useful when using custom images) | `[]`                          |
| `args`               | Override default container args (useful when using custom images)    | `[]`                          |
| `extraEnvVars`       | Extra environment variables to be set on open-vm-tools containers    | `[]`                          |
| `extraEnvVarsCM`     | ConfigMap with extra environment variables                           | `""`                          |
| `extraEnvVarsSecret` | Secret with extra environment variables                              | `""`                          |


### open-vm-tools Daemonset parameters



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