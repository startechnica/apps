# Startechnica Common Library Chart

A [Helm Library Chart](https://helm.sh/docs/topics/library_charts/#helm) for grouping common logic between Startechnica charts.

## TL;DR

```yaml
dependencies:
  - name: common
    version: x.x.x
    repository: https://startechnica.github.io/apps
```

```bash
$ helm dependency update
```

## Introduction

This chart provides a common template helpers which can be used to develop new charts using [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Parameters

The following table lists the helpers available in the library which are scoped in different sections.

### Istio

| Helper identifier                                 | Description                                                              | Expected Input    |
|---------------------------------------------------|--------------------------------------------------------------------------|-------------------|
| `common.capabilities.istioExtensions.apiVersion`  | Return the appropriate apiVersion for Istio Extension.                   | `.` Chart context |
| `common.capabilities.istioInstall.apiVersion`     | Return the appropriate apiVersion for Istio Install.                     | `.` Chart context |
| `common.capabilities.istioNetworking.apiVersion`  | Return the appropriate apiVersion for Istio Networking.                  | `.` Chart context |
| `common.capabilities.istioSecurity.apiVersion`    | Return the appropriate apiVersion for Istio Security.                    | `.` Chart context |
| `common.capabilities.istioTelemetry.apiVersion`   | Return the appropriate apiVersion for Istio Telemetry.                   | `.` Chart context |

### cert-manager

| Helper identifier                                 | Description                                                              | Expected Input    |
|---------------------------------------------------|--------------------------------------------------------------------------|-------------------|
| `common.capabilities.certManager.apiVersion`      | Return the appropriate apiVersion for cert-manager.                      | `.` Chart context |

## Example of use

```yaml
{{- if not (eq (include "common.capabilities.istioNetworking.apiVersion" .) "false") }}
apiVersion: {{ include "common.capabilities.istioNetworking.apiVersion" . }}
kind: Gateway
metadata:
  name: gateway-name
  namespace: gateway-namespace
. . .
{{- end }}
```

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
