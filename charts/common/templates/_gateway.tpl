{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Gateway name.
*/}}
{{- define "st-common.gateway.fullname" -}}
{{- if .Values.gateway.existingGateway -}}
  {{- .Values.gateway.existingGateway -}}
{{- else -}}
  {{- default (include "st-common.names.fullname" .) .Values.gateway.gateway.name  -}}
{{- end -}}
{{- end -}}

{{/*
Gateway namespace.
*/}}
{{- define "st-common.gateway.namespace" -}}
{{- default (include "st-common.names.namespace" .) .Values.gateway.namespace  -}}
{{- end -}}

{{- define "st-common.gatewayWaypoint.fullname" -}}
{{- if .Values.gateway.waypoint.name -}}
  {{- print .Values.gateway.waypoint.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- printf "%s-waypoint" (include "st-common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "st-common.gatewayWaypoint.namespace" -}}
{{- if .Values.gateway.waypoint.namespace -}}
  {{- print .Values.gateway.waypoint.namespace | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- include "st-common.names.namespace" . -}}
{{- end -}}
{{- end -}}