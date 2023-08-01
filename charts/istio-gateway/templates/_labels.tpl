{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
{{ include "gateway.labels.matchLabels" (dict "value" .name "context" $) }}
*/}}
{{- define "gateway.labels.matchLabels" -}}
{{- $gatewayName := .value -}}
istio: {{ $gatewayName }}
istio.io/gateway-name: {{ $gatewayName }}
{{- end -}}