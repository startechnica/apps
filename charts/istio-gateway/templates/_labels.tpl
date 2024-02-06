{{/*
Return the proper Istio Gateway fullname
{{ include "gateway.fullname" (dict "name" .name "context" $) }}
*/}}
{{- define "gateway.fullname" -}}
{{- $gatewayName := .name -}}
{{- printf "%s" $gatewayName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Kubernetes standard labels
{{ include "gateway.labels.standard" (dict "name" .name "revision" .revision "context" $) }}
*/}}
{{- define "gateway.labels.standard" -}}
{{- $gatewayName := .name -}}
app: {{ include "common.names.name" .context }}
app.kubernetes.io/name: {{ include "common.names.name" .context }}
helm.sh/chart: {{ include "common.names.chart" .context }}
istio: {{ $gatewayName }}
istio.io/gateway-name: {{ $gatewayName }}
{{- if .revision }}
istio.io/rev: {{ .revision | quote }}
{{- end }}
{{- end -}}

{{/*
Kubernetes standard labels
{{ include "common.labels.standard" (dict "customLabels" .Values.commonLabels "context" $) -}}
*/}}
{{- define "gateways.labels.standard" -}}
{{- if and (hasKey . "customLabels") (hasKey . "context") -}}
{{- $default := dict "app.kubernetes.io/name" (include "common.names.name" .context) "helm.sh/chart" (include "common.names.chart" .context) "app.kubernetes.io/instance" .context.Release.Name "app.kubernetes.io/managed-by" .context.Release.Service -}}
{{- with .context.Chart.AppVersion -}}
{{- $_ := set $default "app.kubernetes.io/version" . -}}
{{- end -}}
{{ template "common.tplvalues.merge" (dict "values" (list .customLabels $default) "context" .context) }}
{{- else -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
helm.sh/chart: {{ include "common.names.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
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
app: {{ include "common.names.name" .context }}
app.kubernetes.io/name: {{ include "common.names.name" .context }}
istio: {{ $gatewayName }}
istio.io/gateway-name: {{ $gatewayName }}
{{- if .revision }}
istio.io/rev: {{ .revision | quote }}
{{- end }}
{{- end -}}