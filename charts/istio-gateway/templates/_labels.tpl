{{/*
Kubernetes standard labels
{{ include "gateway.labels.standard" (dict "name" .name "revision" .revision "context" $) }}
*/}}
{{- define "gateway.labels.standard" -}}
{{- $gatewayName := .name -}}
app.kubernetes.io/name: {{ include "common.names.name" .context }}
helm.sh/chart: {{ include "common.names.chart" .context }}
istio: {{ $gatewayName }}
istio.io/gateway-name: {{ $gatewayName }}
{{- if .revision }}
istio.io/rev: {{ .revision | quote }}
{{- end }}
{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
{{ include "gateway.labels.matchLabels" (dict "name" .name "revision" .revision "context" $) }}
*/}}
{{- define "gateway.labels.matchLabels" -}}
{{- $gatewayName := .name -}}
app.kubernetes.io/name: {{ include "common.names.name" .context }}
istio: {{ $gatewayName }}
istio.io/gateway-name: {{ $gatewayName }}
{{- if .revision }}
istio.io/rev: {{ .revision | quote }}
{{- end }}
{{- end -}}