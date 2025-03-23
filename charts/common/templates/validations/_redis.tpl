{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Auxiliary function to get the right value for enabled redis.

Usage:
{{ include "st-common.redis.values.enabled" (dict "context" $) }}
*/}}
{{- define "st-common.redis.values.enabled" -}}
  {{- if .subchart -}}
    {{- printf "%v" .context.Values.redis.enabled -}}
  {{- else -}}
    {{- printf "%v" (not .context.Values.enabled) -}}
  {{- end -}}
{{- end -}}

{{/*
Auxiliary function to get the right prefix path for the values

Usage:
{{ include "st-common.redis.values.key.prefix" (dict "subchart" "true" "context" $) }}
Params:
  - subchart - Boolean - Optional. Whether redis is used as subchart or not. Default: false
*/}}
{{- define "st-common.redis.values.keys.prefix" -}}
  {{- if .subchart -}}redis.{{- else -}}{{- end -}}
{{- end -}}

{{/*
Checks whether the redis chart's includes the standarizations (version >= 14)

Usage:
{{ include "st-common.redis.values.standarized.version" (dict "context" $) }}
*/}}
{{- define "st-common.redis.values.standarized.version" -}}

  {{- $standarizedAuth := printf "%s%s" (include "st-common.redis.values.keys.prefix" .) "auth" -}}
  {{- $standarizedAuthValues := include "st-common.utils.getValueFromKey" (dict "key" $standarizedAuth "context" .context) }}

  {{- if $standarizedAuthValues -}}
    {{- true -}}
  {{- end -}}
{{- end -}}