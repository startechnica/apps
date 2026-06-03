{{- /*
(c) 2026 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Resolve the chart-managed gateway-side TLS Secret name. Resolution order
(first match wins):
  1. `gateway.tls.existingSecret` — BYO Secret managed outside the chart.
  2. `gateway.tls.secrets[0].name` — first user-supplied PEM Secret rendered
     by the chart.
  3. `<first gateway.hostnames>-tls` — when the user has declared hostnames.
  4. `<ingress.hostname>-tls` — final fallback for users who still drive the
     gateway hosts off the legacy ingress block.
*/}}
{{- define "netbox.gateway.tlsSecretName" -}}
{{- if and .Values.gateway.tls .Values.gateway.tls.existingSecret -}}
{{- .Values.gateway.tls.existingSecret -}}
{{- else if and .Values.gateway.tls .Values.gateway.tls.secrets -}}
{{- (first .Values.gateway.tls.secrets).name -}}
{{- else if .Values.gateway.hostnames -}}
{{- printf "%s-tls" (first .Values.gateway.hostnames) -}}
{{- else -}}
{{- printf "%s-tls" .Values.ingress.hostname -}}
{{- end -}}
{{- end -}}

{{/*
Resolve the effective hostnames list for gateway-side resources (Gateway,
HTTPRoute, VirtualService). Prefers the explicit `gateway.hostnames` list;
falls back to `ingress.hostname` (+ `ingress.extraHosts[*].name`) for
backward compatibility with users who haven't migrated yet.
*/}}
{{- define "netbox.gateway.hostnames" -}}
{{- if .Values.gateway.hostnames -}}
{{- range .Values.gateway.hostnames }}
- {{ . | quote }}
{{- end }}
{{- else -}}
{{- if .Values.ingress.hostname }}
- {{ .Values.ingress.hostname | quote }}
{{- end }}
{{- range .Values.ingress.extraHosts }}
- {{ .name | quote }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Resolve the Gateway resource name. Three-step chain:
  1. `gateway.existingGateway` — BYO Gateway.
  2. `gateway.gateway.name` — explicit override.
  3. `<fullname>-gateway` — default chart-managed name (the `-gateway`
     suffix avoids colliding with the chart Service / Deployment, since
     Envoy Gateway and Istio gateway-api materialise a data-plane workload
     named after the Gateway).
*/}}
{{- define "netbox.gateway.fullname" -}}
{{- if .Values.gateway.existingGateway -}}
{{- .Values.gateway.existingGateway -}}
{{- else if and .Values.gateway.gateway .Values.gateway.gateway.name -}}
{{- .Values.gateway.gateway.name -}}
{{- else -}}
{{- printf "%s-gateway" (include "st-common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve the namespace the Gateway resource lives in. Falls back to the
release namespace when `gateway.gateway.namespace` is empty.
*/}}
{{- define "netbox.gateway.namespace" -}}
{{- if and .Values.gateway.gateway .Values.gateway.gateway.namespace -}}
{{- .Values.gateway.gateway.namespace -}}
{{- else -}}
{{- include "st-common.names.namespace" . -}}
{{- end -}}
{{- end -}}

{{/*
Resolve the EnvoyProxy resource name. When `envoyProxy.create: true` and
`name` is empty, defaults to the chart fullname. When `create: false`,
returns the user-supplied `name` (BYO — required to be set).
*/}}
{{- define "netbox.gateway.envoyProxy.name" -}}
{{- if and .Values.gateway.envoyProxy .Values.gateway.envoyProxy.name -}}
{{- .Values.gateway.envoyProxy.name -}}
{{- else -}}
{{- include "st-common.names.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Returns string "true" when the chart should render its own EnvoyProxy
manifest: `gateway.enabled`, `implementation: gateway-api`,
`infrastructure: envoy`, `envoyProxy.create: true`.
*/}}
{{- define "netbox.gateway.envoyProxy.create" -}}
{{- if and .Values.gateway.enabled (eq (default "gateway-api" .Values.gateway.implementation) "gateway-api") (eq (default "" .Values.gateway.infrastructure) "envoy") .Values.gateway.envoyProxy .Values.gateway.envoyProxy.create -}}
true
{{- end -}}
{{- end -}}

{{/*
Resolve the parentRefs block for routes (HTTPRoute) attached to the chart's
Gateway. Resolution order:
  1. Per-route explicit `parentRefs` override (via tplvalues.render).
  2. Chart-rendered ListenerSet when listenerSet.enabled AND listenerSet.listeners non-empty AND the API is available.
  3. Chart-rendered Gateway via `netbox.gateway.fullname` / `netbox.gateway.namespace`.

Caller passes a single arg dict: `(dict "parentRefs" .Values.gateway.httpRoute.parentRefs "context" $)`.
*/}}
{{- define "netbox.gateway.routeParentRefs" -}}
{{- $ctx := .context -}}
{{- if .parentRefs -}}
{{- include "st-common.tplvalues.render" (dict "value" .parentRefs "context" $ctx) -}}
{{- else -}}
{{- $lsApi := include "st-common.capabilities.networkingGatewayListenerSet.apiVersion" $ctx -}}
{{- $hasLs := and $ctx.Values.gateway.listenerSet $ctx.Values.gateway.listenerSet.enabled $ctx.Values.gateway.listenerSet.listeners $lsApi (ne $lsApi "false") -}}
{{- if $hasLs -}}
- group: {{ (regexSplit "/" $lsApi -1) | first | quote }}
  kind: {{ ternary "XListenerSet" "ListenerSet" (hasPrefix "gateway.networking.x-k8s.io" $lsApi) | quote }}
  name: {{ include "netbox.gateway.fullname" $ctx | quote }}
  namespace: {{ include "netbox.gateway.namespace" $ctx | quote }}
{{- else -}}
- group: gateway.networking.k8s.io
  kind: Gateway
  name: {{ include "netbox.gateway.fullname" $ctx | quote }}
  namespace: {{ include "netbox.gateway.namespace" $ctx | quote }}
{{- end -}}
{{- end -}}
{{- end -}}
