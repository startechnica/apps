{{- /*
(c) 2026 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Render a values subtree into a FreeRADIUS config block:
  - scalar leaf -> `key = value`
  - nested map  -> `key { ... }` block (recursively, indented 4 spaces per level)
Keys within a map are emitted in alphabetical order (Go `range` over a map).
Lists are not supported. The assembled block is run through `tpl` once at the
top level (only when it contains a `{{ ... }}` action), so values may reference
`.Values` / `.Release`. The function recurses into nested maps with
`nested=true`, which skips that `tpl` pass — it must run exactly once, on the
fully-assembled output. The caller controls outer indentation via `nindent`.
Usage:
{{ include "freeradius.tplvalues.renderConfig" ( dict "value" .Values.path.to.value "context" $ ) | nindent 4 }}
*/}}
{{- define "freeradius.tplvalues.renderConfig" -}}
{{- $out := "" -}}
{{- range $key, $val := .value -}}
  {{- if kindIs "map" $val -}}
    {{- $body := include "freeradius.tplvalues.renderConfig" (dict "value" $val "nested" true) -}}
    {{- if $body -}}
      {{- $out = printf "%s%s {\n%s\n}\n" $out $key (indent 4 $body) -}}
    {{- else -}}
      {{- $out = printf "%s%s {\n}\n" $out $key -}}
    {{- end -}}
  {{- else -}}
    {{- $out = printf "%s%s = %v\n" $out $key $val -}}
  {{- end -}}
{{- end -}}
{{- $out = $out | trimSuffix "\n" -}}
{{- if and (not .nested) (contains "{{" $out) -}}
{{- tpl $out .context -}}
{{- else -}}
{{- $out -}}
{{- end -}}
{{- end -}}