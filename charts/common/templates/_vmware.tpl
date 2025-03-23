{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* Return the appropriate apiVersion for vmware */}}
{{- define "common.capabilities.vmwareCns.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "cns.vmware.com/v1alpha1" -}}
  {{- print "cns.vmware.com/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for vmware */}}
{{- define "st-common.capabilities.vmwareCns.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "cns.vmware.com/v1alpha1" -}}
  {{- print "cns.vmware.com/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}
