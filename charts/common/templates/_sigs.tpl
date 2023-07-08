{{/* Return the appropriate apiVersion for Kubernetes Gateway API */}}
{{- define "common.capabilities.networkingGateway.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1beta1" -}}
  {{- print "gateway.networking.k8s.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}