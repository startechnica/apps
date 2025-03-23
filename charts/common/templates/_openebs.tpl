{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* Return the appropriate apiVersion for OpenEBS */}}
{{- define "common.capabilities.openebsLocal.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "local.openebs.io/v1alpha1" -}}
  {{- print "local.openebs.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for OpenEBS */}}
{{- define "st-common.capabilities.openebsLocal.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "local.openebs.io/v1alpha1" -}}
  {{- print "local.openebs.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}