{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Return the MongoDB Secret Name
*/}}
{{- define "st-common.mongodb.secretName" -}}
{{- if .Values.mongodb.existingSecretName -}}
    {{- print .Values.mongodb.existingSecretName -}}
{{- else if .Values.existingSecretName -}}
    {{- print .Values.existingSecretName -}}
{{- else -}}
    {{- printf "%s-%s" (include "st-common.names.fullname" .) "mongodb" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}