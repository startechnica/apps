{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* Return the appropriate apiVersion for Flux CD HelmRelease */}}
{{- define "common.capabilities.fluxcdHelmRelease.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "helm.toolkit.fluxcd.io/v2/HelmRelease" -}}
  {{- print "helm.toolkit.fluxcd.io/v2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Flux CD HelmRelease */}}
{{- define "st-common.capabilities.fluxcdHelmRelease.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "helm.toolkit.fluxcd.io/v2/HelmRelease" -}}
  {{- print "helm.toolkit.fluxcd.io/v2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}