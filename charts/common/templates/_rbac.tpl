{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Returns the proper service account name depending if an explicit service account name is set
in the values file. If the name is not set it will default to either st-common.names.fullname if serviceAccount.create
is true or default otherwise.
*/}}
{{- define "st-common.rbac.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create -}}
    {{ default (include "st-common.names.fullname" .) .Values.serviceAccount.name }}
  {{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
  {{- end -}}
{{- end -}}