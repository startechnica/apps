{{/* Return the appropriate apiVersion for MetalLB */}}
{{- define "common.capabilities.metallb.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta1" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}