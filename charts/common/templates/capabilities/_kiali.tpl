{{- /*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* Return the appropriate apiVersion for Kiali */}}
{{- define "st-common.capabilities.kiali.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "kiali.io/v1alpha1/Kiali" -}}
  {{- print "kiali.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}