
{{/*
Kubernetes standard labels
{{ include "gateway.labels.standard" (dict "name" .name "revision" .revision "context" $) }}
*/}}
{{- define "gateway.labels.standard" -}}
{{- $gatewayName := .name -}}
app.kubernetes.io/name: {{ .name }}
gateway.istio.io/managed: {{ .context.Release.Service }}
helm.sh/chart: {{ include "gateways.names.chart" .context }}
istio.io/dataplane-mode: none
istio.io/gateway-name: {{ $gatewayName }}
{{- end -}}

{{/*
Kubernetes standard labels
{{ include "gateway.labels.standard" (dict "gatewayName" .gatewayName "context" $) }}
*/}}
{{- define "gatewaysz.labels.standard" -}}
app.kubernetes.io/name: {{ .gatewayName }}
gateway.istio.io/managed: {{ .context.Release.Service }}
helm.sh/chart: {{ include "gateways.names.chart" .context }}
istio.io/dataplane-mode: none
istio.io/gateway-name: {{ .gatewayName }}
{{- end -}}

{{/*
Kubernetes standard labels
{{ include "gateways.labels.standard" (dict "gatewayName" .gatewayName "customLabels" .Values.commonLabels "context" $) -}}
*/}}
{{- define "gateways.labels.standard" -}}
{{- if and (hasKey . "customLabels") (hasKey . "context") -}}
{{- $default := dict "app.kubernetes.io/name" .gatewayName "helm.sh/chart" (include "gateways.names.chart" .context) "app.kubernetes.io/instance" .context.Release.Name "app.kubernetes.io/managed-by" .context.Release.Service "gateway.istio.io/managed" .context.Release.Service -}}
{{- with .context.Chart.AppVersion -}}
{{- $_ := set $default "app.kubernetes.io/version" . -}}
{{- end -}}
{{ template "common.tplvalues.merge" (dict "values" (list .customLabels $default) "context" .context) }}
{{- else -}}
app.kubernetes.io/name: {{ include "gateways.names.name" . }}
gateway.istio.io/managed: {{ .Release.Service }}
helm.sh/chart: {{ include "gateways.names.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
istio.io/dataplane-mode: none
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
{{ include "gateway.labels.matchLabels" (dict "name" .name "revision" .revision "context" $) }}
*/}}
{{- define "gateway.labels.matchLabels" -}}
{{- $gatewayName := .name -}}
app.kubernetes.io/name: {{ .name }}
istio.io/gateway-name: {{ $gatewayName }}
{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
{{ include "gateway.labels.matchLabels" (dict "gatewayName" .gatewayName "context" $) }}
*/}}
{{- define "gateways.labels.matchLabels" -}}
app.kubernetes.io/name: {{ .gatewayName }}
istio.io/gateway-name: {{ .gatewayName }}
{{- end -}}