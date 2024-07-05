{{- /*
Copyright (c) 2024 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* Return the appropriate apiVersion for Flux CD HelmRelease */}}
{{- define "common.capabilities.fluxcdHelmRelease.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "helm.toolkit.fluxcd.io/v2/HelmRelease" -}}
  {{- print "helm.toolkit.fluxcd.io/v2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}