{{- /*
(c) 2025 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{- define "open-appsec.utils.firstKey" -}}
{{- $keys := keys . -}}
{{- if gt (len $keys) 0 -}}
{{- index $keys 0 -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end }}

{{- define "open-appsec.utils.firstValue" -}}
{{- $keys := keys . -}}
{{- if gt (len $keys) 0 -}}
{{- index . (index $keys 0) -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end }}