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

### Affinities

| Helper identifier                  | Description                                          | Expected Input                                               |
| ---------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------ |
| `st-common.affinities.nodes.soft`  | Return a soft nodeAffinity definition                | `dict "key" "FOO" "values" (list "BAR" "BAZ")`               |
| `st-common.affinities.nodes.hard`  | Return a hard nodeAffinity definition                | `dict "key" "FOO" "values" (list "BAR" "BAZ")`               |
| `st-common.affinities.nodes`       | Return a nodeAffinity definition                     | `dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")` |
| `st-common.affinities.topologyKey` | Return a topologyKey definition                      | `dict "topologyKey" "FOO"`                                   |
| `st-common.affinities.pods.soft`   | Return a soft podAffinity/podAntiAffinity definition | `dict "component" "FOO" "context" $`                         |
| `st-common.affinities.pods.hard`   | Return a hard podAffinity/podAntiAffinity definition | `dict "component" "FOO" "context" $`                         |
| `st-common.affinities.pods`        | Return a podAffinity/podAntiAffinity definition      | `dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")` |

### Gateway

| Helper identifier                     | Description                                                         | Expected Input            |
| ------------------------------------- | ------------------------------------------------------------------- | --------------------------|
| `st-common.gateway.clusterDomain`     | Return gateway cluster domain                                       | `.` Chart context         |
| `st-common.gateway.fullname`          | Create a default fully qualified gateway name                       | `.` Chart context         |
| `st-common.gateway.namespace`         | Allow the gateway namespace to be overridden                        | `.` Chart context         |

### Labels

| Helper identifier              | Description                                                                 | Expected Input    |
| ------------------------------ | --------------------------------------------------------------------------- | ----------------- |
| `st-common.labels.standard`    | Return Kubernetes standard labels                                           | `.` Chart context |
| `st-common.labels.matchLabels` | Labels to use on `deploy.spec.selector.matchLabels` and `svc.spec.selector` | `.` Chart context |

### Names

| Helper identifier                     | Description                                                           | Expected Input                                                                                |
| ------------------------------------- | --------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `st-common.names.name`                | Expand the name of the chart or use `.Values.nameOverride`            | `.` Chart context                                                                             |
| `st-common.names.fullname`            | Create a default fully qualified app name.                            | `.` Chart context                                                                             |
| `st-common.names.namespace`           | Allow the release namespace to be overridden                          | `.` Chart context                                                                             |
| `st-common.names.fullname.namespace`  | Create a fully qualified app name adding the installation's namespace | `.` Chart context                                                                             |
| `st-common.names.chart`               | Chart name plus version                                               | `.` Chart context                                                                             |
| `st-common.names.dependency.fullname` | Create a default fully qualified dependency name.                     | `dict "chartName" "dependency-chart-name" "chartValues" .Values.dependency-chart "context" $` |

### Capabilities

| Helper identifier                                            | Description                                                                                    | Expected Input                          |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------- | --------------------------------------- |
| `st-common.capabilities.kubeVersion`                         | Return the target Kubernetes version (using client default if .Values.kubeVersion is not set). | `.` Chart context                       |
| `st-common.capabilities.apiVersions.has`                     | Return true if the apiVersion is supported                                                     | `dict "version" "batch/v1" "context" $` |
| `st-common.capabilities.job.apiVersion`                      | Return the appropriate apiVersion for job.                                                     | `.` Chart context                       |
| `st-common.capabilities.cronjob.apiVersion`                  | Return the appropriate apiVersion for cronjob.                                                 | `.` Chart context                       |
| `st-common.capabilities.daemonset.apiVersion`                | Return the appropriate apiVersion for daemonset.                                               | `.` Chart context                       |
| `st-common.capabilities.cronjob.apiVersion`                  | Return the appropriate apiVersion for cronjob.                                                 | `.` Chart context                       |
| `st-common.capabilities.deployment.apiVersion`               | Return the appropriate apiVersion for deployment.                                              | `.` Chart context                       |
| `st-common.capabilities.statefulset.apiVersion`              | Return the appropriate apiVersion for statefulset.                                             | `.` Chart context                       |
| `st-common.capabilities.ingress.apiVersion`                  | Return the appropriate apiVersion for ingress.                                                 | `.` Chart context                       |
| `st-common.capabilities.rbac.apiVersion`                     | Return the appropriate apiVersion for RBAC resources.                                          | `.` Chart context                       |
| `st-common.capabilities.crd.apiVersion`                      | Return the appropriate apiVersion for CRDs.                                                    | `.` Chart context                       |
| `st-common.capabilities.policy.apiVersion`                   | Return the appropriate apiVersion for podsecuritypolicy.                                       | `.` Chart context                       |
| `st-common.capabilities.networkPolicy.apiVersion`            | Return the appropriate apiVersion for networkpolicy.                                           | `.` Chart context                       |
| `st-common.capabilities.apiService.apiVersion`               | Return the appropriate apiVersion for APIService.                                              | `.` Chart context                       |
| `st-common.capabilities.hpa.apiVersion`                      | Return the appropriate apiVersion for Horizontal Pod Autoscaler                                | `.` Chart context                       |
| `st-common.capabilities.vpa.apiVersion`                      | Return the appropriate apiVersion for Vertical Pod Autoscaler.                                 | `.` Chart context                       |
| `st-common.capabilities.psp.supported`                       | Returns true if PodSecurityPolicy is supported                                                 | `.` Chart context                       |
| `st-common.capabilities.supportsHelmVersion`                 | Returns true if the used Helm version is 3.3+                                                  | `.` Chart context                       |
| `st-common.capabilities.admissionConfiguration.supported`    | Returns true if AdmissionConfiguration is supported                                            | `.` Chart context                       |
| `st-common.capabilities.admissionConfiguration.apiVersion`   | Return the appropriate apiVersion for AdmissionConfiguration.                                  | `.` Chart context                       |
| `st-common.capabilities.podSecurityConfiguration.apiVersion` | Return the appropriate apiVersion for PodSecurityConfiguration.                                | `.` Chart context                       |

The following table lists the helpers available in the library which are scoped in different sections.

#### Istio

| Helper identifier                                             | Description                                                              | Expected Input    |
|---------------------------------------------------------------|--------------------------------------------------------------------------|-------------------|
| `st-common.capabilities.istiolWasmPugin.apiVersion`           | Return the appropriate apiVersion for Istio WasmPlugin.                  | `.` Chart context |
| `st-common.capabilities.istioIstioOperator.apiVersion`        | Return the appropriate apiVersion for Istio IstioOperator.               | `.` Chart context |
| `st-common.capabilities.istioAuthorizationPolicy.apiVersion`  | Return the appropriate apiVersion for Istio AuthorizationPolicy.         | `.` Chart context |
| `st-common.capabilities.istioDestinationRule.apiVersion`      | Return the appropriate apiVersion for Istio DestinationRule.             | `.` Chart context |
| `st-common.capabilities.istioTelemetry.apiVersion`            | Return the appropriate apiVersion for Istio Telemetry.                   | `.` Chart context |

#### cert-manager

| Helper identifier                                 | Description                                                              | Expected Input    |
|---------------------------------------------------|--------------------------------------------------------------------------|-------------------|
| `st-common.capabilities.certManager.apiVersion`   | Return the appropriate apiVersion for cert-manager.                      | `.` Chart context |

#### Kubernetes Gateway API

| Helper identifier                                             | Description                                                              | Expected Input    |
|---------------------------------------------------------------|--------------------------------------------------------------------------|-------------------|
| `st-common.capabilities.networkingGatewayGateway.apiVersion`  | Return the appropriate apiVersion for Kubernetes Gateway API - Gateway   | `.` Chart context |

#### Prometheus

| Helper identifier                                     | Description                                                              | Expected Input    |
|-------------------------------------------------------|--------------------------------------------------------------------------|-------------------|
| `st-common.capabilities.coreosMonitoring.apiVersion`  | Return the appropriate apiVersion for Prometheus.                        | `.` Chart context |

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

Copyright &copy; 2025 Startechnica

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
