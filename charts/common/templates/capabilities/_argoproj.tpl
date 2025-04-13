{{- /*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* Return the appropriate apiVersion for Argo Application */}}
{{- define "st-common.capabilities.argoprojApplication.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "argoproj.io/v1alpha1" -}}
  {{- print "argoproj.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Argo ApplicationSet */}}
{{- define "st-common.capabilities.argoprojApplicationSet.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "argoproj.io/v1alpha1" -}}
  {{- print "argoproj.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Argo AppProject */}}
{{- define "st-common.capabilities.argoprojAppProject.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "argoproj.io/v1alpha1" -}}
  {{- print "argoproj.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}
