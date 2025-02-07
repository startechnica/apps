{{- /*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* Return the appropriate apiVersion for Zalando PostgreSQL Operator. */}}
{{- define "common.capabilities.zalando.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "acid.zalan.do/v1" -}}
  {{- print "acid.zalan.do/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Zalando PostgreSQL Operator. */}}
{{- define "st-common.capabilities.zalandoAcid.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "acid.zalan.do/v1" -}}
  {{- print "acid.zalan.do/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}