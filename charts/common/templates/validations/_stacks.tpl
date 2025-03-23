{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Auxiliary function to get the right value for enabled stack.

Usage:
{{ include "st-common.stack.values.enabled" (dict "context" $) }}
*/}}
{{- define "st-common.stack.values.enabled" -}}
  {{- if .subchart -}}
    {{- printf "%v" .context.Values.stack.enabled -}}
  {{- else -}}
    {{- printf "%v" (not .context.Values.enabled) -}}
  {{- end -}}
{{- end -}}