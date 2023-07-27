{{/* Return the appropriate apiVersion for Prometheus API */}}
{{- define "common.capabilities.coreosMonitoring.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1" -}}
  {{- print "monitoring.coreos.com/v1beta1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1" -}}
  {{- print "monitoring.coreos.com/v1alpha2" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1alpha2" -}}
  {{- print "monitoring.coreos.com/v1alpha2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}