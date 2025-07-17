{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "st-common.names.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "st-common.names.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "st-common.names.fullname" -}}
{{- if .Values.fullnameOverride -}}
  {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- $name := default .Chart.Name .Values.nameOverride -}}
  {{- $releaseName := regexReplaceAll "(-?[^a-z\\d\\-])+-?" (lower .Release.Name) "-" -}}
  {{- if contains $name $releaseName -}}
    {{- $releaseName | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- printf "%s-%s" $releaseName $name | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified dependency name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
Usage:
{{ include "st-common.names.dependency.fullname" (dict "chartName" "dependency-chart-name" "chartValues" .Values.dependency-chart "context" $) }}
*/}}
{{- define "st-common.names.dependency.fullname" -}}
{{- if .chartValues.fullnameOverride -}}
{{- .chartValues.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .chartName .chartValues.nameOverride -}}
{{- if contains $name .context.Release.Name -}}
{{- .context.Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .context.Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts.
*/}}
{{- define "st-common.names.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified app name adding the installation's namespace.
*/}}
{{- define "st-common.names.fullname.namespace" -}}
{{- printf "%s-%s" (include "st-common.names.fullname" .) (include "st-common.names.namespace" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Gateway name.
*/}}
{{- define "st-common.names.gateway.name" -}}
{{- default .Values.gateway.gateway.name .Values.gateway.existingGateway -}}
{{- end -}}

{{/*
Gateway namespace.
*/}}
{{- define "st-common.names.gateway.namespace" -}}
{{- if .Values.gateway.gateway.namespace -}}
  {{- .Values.gateway.gateway.namespace -}}
{{- else -}}
  {{- include "st-common.names.namespace" . -}}
{{- end -}}
{{- end -}}

{{- define "st-common.names.gatewayWaypoint.name" -}}
{{- if .Values.gateway.waypoint.name -}}
  {{- print .Values.gateway.waypoint.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- printf "%s-waypoint" (include "st-common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "st-common.names.gatewayWaypoint.namespace" -}}
{{- if .Values.gateway.waypoint.namespace -}}
  {{- print .Values.gateway.waypoint.namespace | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- include "st-common.names.namespace" . -}}
{{- end -}}
{{- end -}}

{{/*
Create name of dotenv ConfigMap name
*/}}
{{- define "st-common.names.dotenv" -}}
{{- if .Values.dotenvConfigMap.existingConfigMapName -}}
  {{- print .Values.dotenvConfigMap.existingConfigMapName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- printf "%s-dotenv" (include "st-common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create name of ENV variables ConfigMap name
*/}}
{{- define "st-common.names.envvars" -}}
{{- if .Values.envvarsConfigMap.existingConfigMapName -}}
  {{- print .Values.envvarsConfigMap.existingConfigMapName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- printf "%s-envvars" (include "st-common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
