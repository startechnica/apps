{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{- define "st-common.email.recipientsBcc" -}}
{{- print (join "," .Values.email.recipientsBcc)  -}}
{{- end -}}

{{- define "st-common.email.recipientsCc" -}}
{{- print (join "," .Values.email.recipientsCc)  -}}
{{- end -}}