{{- /*
Copyright (c) 2024 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API */}}
{{- define "common.capabilities.networkingGateway.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1" -}}
  {{- print "gateway.networking.k8s.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1beta1" -}}
  {{- print "gateway.networking.k8s.io/v1beta1" -}}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2" -}}
  {{- print "gateway.networking.k8s.io/v1alpha2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}