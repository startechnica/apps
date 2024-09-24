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
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gateways.names.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
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