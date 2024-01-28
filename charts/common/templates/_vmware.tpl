{{/* Return the appropriate apiVersion for vmware */}}
{{- define "common.capabilities.vmwareCns.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "cns.vmware.com/v1alpha1" -}}
  {{- print "cns.vmware.com/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}