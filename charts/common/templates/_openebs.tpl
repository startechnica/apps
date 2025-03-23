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

{{/* Return the appropriate apiVersion for OpenEBS LVMNode */}}
{{- define "st-common.capabilities.openebsLocalLVMNode.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "local.openebs.io/v1alpha1/LVMNode" -}}
  {{- print "local.openebs.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for OpenEBS LVMSnapshot */}}
{{- define "st-common.capabilities.openebsLocalLVMSnapshot.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "local.openebs.io/v1alpha1/LVMSnapshot" -}}
  {{- print "local.openebs.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for OpenEBS LVMVolume */}}
{{- define "st-common.capabilities.openebsLocalLVMVolume.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "local.openebs.io/v1alpha1/LVMVolume" -}}
  {{- print "local.openebs.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}