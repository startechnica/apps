{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
{{ include "gateway.labels.matchLabels" (dict "name" .name) }}
*/}}
{{- define "gateway.labels.matchLabels" -}}
{{- $gatewayName := .name -}}
app.kubernetes.io/name: {{ include "common.names.name" $ }}
app.kubernetes.io/instance: {{ .Release.Name }}
istio: {{ $gatewayName }}
istio.io/gateway-name: {{ $gatewayName }}
{{- end -}}