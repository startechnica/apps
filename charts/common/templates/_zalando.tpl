{{/* Return the appropriate apiVersion for Zalando PostgreSQL Operator. */}}
{{- define "common.capabilities.zalando.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "acid.zalan.do/v1" -}}
  {{- print "acid.zalan.do/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}