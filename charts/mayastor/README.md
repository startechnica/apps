<!--- app-name: Mayastor -->

# Helm chart for Mayastor

Mayastor is a cloud-native declarative data plane written in Rust. Our goal is to abstract storage resources and their differences through the data plane such that users only need to supply the what and do not have to worry about the how so that individual teams stay in control.

Mayastor also try to be as unopinionated as possible. What this means is that we try to work with the existing storage systems you might already have and unify them as abstract resources instead of swapping them out whenever the resources are local or remote.

[Overview of Mayastor](https://mayastor.gitbook.io)

**This chart is not maintained by the upstream project and any issues with the chart should be raised [here](https://github.com/startechnica/apps/issues/new/choose)**

## TL;DR

```bash
$ helm repo add startechnica https://startechnica.github.io/apps
$ helm install my-release startechnica/mayastor
```

## Prerequisites

- Kubernetes 1.20+
- Helm 3.2.0+

## Installing the Chart

To install the chart with the release name `my-release` on `my-release` namespace:

```bash
$ helm repo add startechnica https://startechnica.github.io/apps
$ helm install my-release startechnica/mayastor --namespace my-release --create-namespace
```

These commands deploy Mayastor on the Kubernetes cluster in the default configuration.

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

| Name                | Description                                                                                | Value           |
| ------------------- | ------------------------------------------------------------------------------------------ | --------------- |
| `nameOverride`      | String to partially override mayastor.fullname template (will maintain the release name)   | `""`            |
| `fullnameOverride`  | String to fully override mayastor.fullname template                                        | `""`            |
| `kubeVersion`       | Force target Kubernetes version (using Helm capabilities if not set)                       | `""`            |
| `clusterDomain`     | Kubernetes Cluster Domain                                                                  | `cluster.local` |
| `extraDeploy`       | Extra objects to deploy (value evaluated as a template)                                    | `[]`            |
| `commonLabels`      | Add labels to all the deployed resources                                                   | `{}`            |
| `commonAnnotations` | Add annotations to all the deployed resources                                              | `{}`            |

### I/O Engine Dataplane Deployment

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