{{/* Return the appropriate apiVersion for Porject Calico */}}
{{- define "common.capabilities.calico.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{- define "common.capabilities.calicoCrd.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}