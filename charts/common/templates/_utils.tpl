{{/*
(c) 2026 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Print instructions to get a secret value.
Usage:
{{ include "st-common.utils.secret.getvalue" (dict "secret" "secret-name" "field" "secret-value-field" "context" $) }}
*/}}
{{- define "st-common.utils.secret.getvalue" -}}
{{- $varname := include "st-common.utils.fieldToEnvVar" . -}}
export {{ $varname }}=$(kubectl get secret --namespace {{ include "st-common.names.namespace" .context | quote }} {{ .secret }} -o jsonpath="{.data.{{ .field }}}" | base64 -d)
{{- end -}}

{{/*
Build env var name given a field
Usage:
{{ include "st-common.utils.fieldToEnvVar" dict "field" "my-password" }}
*/}}
{{- define "st-common.utils.fieldToEnvVar" -}}
  {{- $fieldNameSplit := splitList "-" .field -}}
  {{- $upperCaseFieldNameSplit := list -}}

  {{- range $fieldNameSplit -}}
    {{- $upperCaseFieldNameSplit = append $upperCaseFieldNameSplit ( upper . ) -}}
  {{- end -}}

  {{ join "_" $upperCaseFieldNameSplit }}
{{- end -}}

{{/*
Gets a value from .Values given
Usage:
{{ include "st-common.utils.getValueFromKey" (dict "key" "path.to.key" "context" $) }}
*/}}
{{- define "st-common.utils.getValueFromKey" -}}
{{- $splitKey := splitList "." .key -}}
{{- $value := "" -}}
{{- $latestObj := $.context.Values -}}
{{- range $splitKey -}}
  {{- if not $latestObj -}}
    {{- printf "please review the entire path of '%s' exists in values" $.key | fail -}}
  {{- end -}}
  {{- $value = ( index $latestObj . ) -}}
  {{- $latestObj = $value -}}
{{- end -}}
{{- printf "%v" (default "" $value) -}} 
{{- end -}}

{{/*
Returns first .Values key with a defined value or first of the list if all non-defined
Usage:
{{ include "st-common.utils.getKeyFromList" (dict "keys" (list "path.to.key1" "path.to.key2") "context" $) }}
*/}}
{{- define "st-common.utils.getKeyFromList" -}}
{{- $key := first .keys -}}
{{- $reverseKeys := reverse .keys }}
{{- range $reverseKeys }}
  {{- $value := include "st-common.utils.getValueFromKey" (dict "key" . "context" $.context ) }}
  {{- if $value -}}
    {{- $key = . }}
  {{- end -}}
{{- end -}}
{{- printf "%s" $key -}} 
{{- end -}}

{{/*
Checksum a template at "path" containing a *single* resource (ConfigMap,Secret) for use in pod annotations, excluding the metadata (see #18376).
Usage:
{{ include "st-common.utils.checksumTemplate" (dict "path" "/configmap.yaml" "context" $) }}
*/}}
{{- define "st-common.utils.checksumTemplate" -}}
{{- $obj := include (print .context.Template.BasePath .path) .context | fromYaml -}}
{{ omit $obj "apiVersion" "kind" "metadata" | toYaml | sha256sum }}
{{- end -}}

{{/*
Because of Helm bug (https://github.com/helm/helm/issues/3001), Helm converts int value to float64 implictly, like 2748336 becomes 2.748336e+06.
This breaks the output even when using quote to render.

Use this function when you want to get the string value only. It handles the case when the value is string itself as well.
Parameters: is string/number
*/}}
{{- define "st-common.utils.stringOrNumber" -}}
{{- if kindIs "string" . }}
  {{- print . -}}
{{- else  }}
  {{- int64 . | toString -}}
{{- end -}}
{{- end -}}

{{/*
Build a URI of the form Scheme://Host[:Port][/Path].

Usage:
  {{ include "st-common.utils.createUri" (dict "scheme" "https" "host" "api.example.com" "port" 8443 "path" "/v1") }}
  {{ include "st-common.utils.createUri" (dict "scheme" "http"  "host" "svc.local") }}

Behavior:
  - port is included whenever provided (and non-zero).
  - path is optional; a leading "/" is added if missing.
  - scheme and host are required; fails loudly otherwise.
*/}}
{{- define "st-common.utils.createUri" -}}
{{- $scheme := required "st-common.utils.createUri: 'scheme' is required" .scheme | lower -}}
{{- $host   := required "st-common.utils.createUri: 'host' is required"   .host -}}
{{- $port   := .port | default "" -}}
{{- $path   := .path | default "" -}}

{{- $portStr := "" -}}
{{- if and $port (ne (printf "%v" $port) "0") -}}
  {{- $portStr = printf ":%v" $port -}}
{{- end -}}

{{- $pathStr := "" -}}
{{- if $path -}}
  {{- if hasPrefix "/" $path -}}
    {{- $pathStr = $path -}}
  {{- else -}}
    {{- $pathStr = printf "/%s" $path -}}
  {{- end -}}
{{- end -}}

{{- printf "%s://%s%s%s" $scheme $host $portStr $pathStr -}}
{{- end -}}
