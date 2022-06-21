{{/* Return the appropriate apiVersion for cert-manager. */}}
{{- define "common.capabilities.certManager.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "cert-manager.io/v1" -}}
  {{- print "cert-manager.io/v1" -}}
{{- else -}}
  {{- print "false" -}}
{{- end -}}
{{- end -}}