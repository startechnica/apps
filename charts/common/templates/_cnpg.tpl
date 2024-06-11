{{/* Return the appropriate apiVersion for Cloudnative PG */}}
{{- define "common.capabilities.cnpgPostgresql.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "postgresql.cnpg.io/v1" -}}
  {{- print "postgresql.cnpg.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}