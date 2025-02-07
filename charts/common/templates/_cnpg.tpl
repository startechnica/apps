{{- /*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* Return the appropriate apiVersion for Cloudnative PG */}}
{{- define "common.capabilities.cnpgPostgresql.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "postgresql.cnpg.io/v1" -}}
  {{- print "postgresql.cnpg.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Cloudnative PG */}}
{{- define "st-common.capabilities.cnpgPostgresql.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "postgresql.cnpg.io/v1" -}}
  {{- print "postgresql.cnpg.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}