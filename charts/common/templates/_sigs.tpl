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

{{/* Return the appropriate apiVersion for Kubernetes Gateway API Gateway */}}
{{- define "common.capabilities.networkingGatewayGateway.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/Gateway" -}}
  {{- print "gateway.networking.k8s.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1beta1/Gateway" -}}
  {{- print "gateway.networking.k8s.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API GRPCRoute */}}
{{- define "common.capabilities.networkingGatewayGRPCRoute.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/GRPCRoute" -}}
  {{- print "gateway.networking.k8s.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1beta1/GRPCRoute" -}}
  {{- print "gateway.networking.k8s.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API HTTPRoute */}}
{{- define "common.capabilities.networkingGatewayHTTPRoute.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/HTTPRoute" -}}
  {{- print "gateway.networking.k8s.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1beta1/HTTPRoute" -}}
  {{- print "gateway.networking.k8s.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API ReferenceGrant */}}
{{- define "common.capabilities.networkingGatewayReferenceGrant.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/ReferenceGrant" -}}
  {{- print "gateway.networking.k8s.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1beta1/ReferenceGrant" -}}
  {{- print "gateway.networking.k8s.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}