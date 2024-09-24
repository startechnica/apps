{{/*
Copyright Firmansyah Nainggolan <firmansyah@nanggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "gateways.names.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gateways.names.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper Istio Gateway fullname
{{ include "gateway.fullname" (dict "name" .name "context" $) }}
*/}}
{{- define "gateway.fullname" -}}
{{- $gatewayName := .name -}}
{{- printf "%s" $gatewayName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper Istio Gateway fullname
{{ include "gateway.fullname" (dict "gatewayName" .gatewayName "context" $) }}
*/}}
{{- define "gateways.names.fullname" -}}
{{- printf "%s" .gatewayName | trunc 63 | trimSuffix "-" -}}
{{- end -}}