{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
{{ include "gateway.labels.matchLabels" (dict "name" .name) }}
*/}}
{{- define "gateway.labels.matchLabels" -}}
{{- $gatewayName := .name -}}
istio: {{ $gatewayName }}
istio.io/gateway-name: {{ $gatewayName }}
{{- end -}}