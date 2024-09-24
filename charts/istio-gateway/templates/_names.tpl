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

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts.
*/}}
{{- define "gateways.names.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified app name adding the installation's namespace.
*/}}
{{- define "gateways.names.fullname.namespace" -}}
{{- printf "%s-%s" (include "common.names.fullname" .) (include "common.names.namespace" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}