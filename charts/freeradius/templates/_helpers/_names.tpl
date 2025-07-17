{{- /*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{- define "freeradius.names.envvars" -}}
{{- printf "%s-envvars" (include "st-common.names.fullname" .) -}}
{{- end -}}