{{/* Return the appropriate apiVersion for OpenEBS */}}
{{- define "common.capabilities.openebsLocal.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "local.openebs.io/v1alpha1" -}}
  {{- print "local.openebs.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}