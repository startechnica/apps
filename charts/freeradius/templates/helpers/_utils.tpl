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
{{/*
Render an array of tokens as a single delimited string, falling back to a
default when the input is nil or empty. Lets values.yaml express a list-shaped
parameter (override-friendly: append/remove single tokens via wrapping charts)
while emitting the joined scalar form FreeRADIUS expects.
Usage:
{{ include "freeradius.utils.joinOrDefault" (dict "list" .Values.path.to.list "sep" ":" "default" "DEFAULT") }}
*/}}
{{- define "freeradius.utils.joinOrDefault" -}}
{{- if .list -}}
{{- join .sep .list -}}
{{- else -}}
{{- .default -}}
{{- end -}}
{{- end -}}

{{/*
Convert a string to snake_case-safe form for FreeRADIUS identifiers — replace
hyphens with underscores. Used by `createDefaultInstance` to derive
proxy/realm names from `st-common.names.fullname` (which is DNS-1123 and
hyphen-separated).
Usage:
{{ include "freeradius.utils.snakeCase" "my-release-freeradius" }}   -> my_release_freeradius
*/}}
{{- define "freeradius.utils.snakeCase" -}}
{{- . | toString | replace "-" "_" -}}
{{- end -}}

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