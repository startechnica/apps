{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

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

{{/* Return the appropriate apiVersion for Kubernetes Gateway API BackendLBPolicy */}}
{{- define "common.capabilities.networkingGatewayBackendLBPolicy.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/BackendLBPolicy" -}}
  {{- print "gateway.networking.k8s.io/v1alpha2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API BackendTLSPolicy */}}
{{- define "common.capabilities.networkingGatewayBackendTLSPolicy.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha3/BackendTLSPolicy" -}}
  {{- print "gateway.networking.k8s.io/v1alpha3" -}}
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

{{/* Return the appropriate apiVersion for Kubernetes Gateway API GatewayClass */}}
{{- define "common.capabilities.networkingGatewayGatewayClass.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/GatewayClass" -}}
  {{- print "gateway.networking.k8s.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1beta1/GatewayClass" -}}
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

{{/* Return the appropriate apiVersion for Kubernetes Gateway API TCPRoute */}}
{{- define "common.capabilities.networkingGatewayTCPRoute.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/TCPRoute" -}}
  {{- print "gateway.networking.k8s.io/v1alpha2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API TLSRoute */}}
{{- define "common.capabilities.networkingGatewayTLSRoute.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/TLSRoute" -}}
  {{- print "gateway.networking.k8s.io/v1alpha2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API UDPRoute */}}
{{- define "common.capabilities.networkingGatewayUDPRoute.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/UDPRoute" -}}
  {{- print "gateway.networking.k8s.io/v1alpha2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API */}}
{{- define "st-common.capabilities.networkingGateway.apiVersion" -}}
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

{{/* Return the appropriate apiVersion for Kubernetes Gateway API BackendLBPolicy */}}
{{- define "st-common.capabilities.networkingGatewayBackendLBPolicy.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/BackendLBPolicy" -}}
  {{- print "gateway.networking.k8s.io/v1alpha2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API BackendTLSPolicy */}}
{{- define "st-common.capabilities.networkingGatewayBackendTLSPolicy.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha3/BackendTLSPolicy" -}}
  {{- print "gateway.networking.k8s.io/v1alpha3" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API BackendTrafficPolicy */}}
{{- define "st-common.capabilities.networkingGatewayBackendTrafficPolicy.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha1/BackendTrafficPolicy" -}}
  {{- print "gateway.networking.k8s.io/v1alpha1" -}}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.x-k8s.io/v1alpha1/XBackendTrafficPolicy" -}}
  {{- print "gateway.networking.x-k8s.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API Gateway */}}
{{- define "st-common.capabilities.networkingGatewayGateway.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/Gateway" -}}
  {{- print "gateway.networking.k8s.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1beta1/Gateway" -}}
  {{- print "gateway.networking.k8s.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API GatewayClass */}}
{{- define "st-common.capabilities.networkingGatewayGatewayClass.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/GatewayClass" -}}
  {{- print "gateway.networking.k8s.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1beta1/GatewayClass" -}}
  {{- print "gateway.networking.k8s.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API GRPCRoute */}}
{{- define "st-common.capabilities.networkingGatewayGRPCRoute.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/GRPCRoute" -}}
  {{- print "gateway.networking.k8s.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1beta1/GRPCRoute" -}}
  {{- print "gateway.networking.k8s.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API HTTPRoute */}}
{{- define "st-common.capabilities.networkingGatewayHTTPRoute.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/HTTPRoute" -}}
  {{- print "gateway.networking.k8s.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1beta1/HTTPRoute" -}}
  {{- print "gateway.networking.k8s.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{/* Return the appropriate apiVersion for Kubernetes Gateway API ListenerSet */}}
{{- define "st-common.capabilities.networkingGatewayListenerSet.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha1/ListenerSet" -}}
  {{- print "gateway.networking.k8s.io/v1alpha1" -}}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.x-k8s.io/v1alpha1/XListenerSet" -}}
  {{- print "gateway.networking.x-k8s.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API ReferenceGrant */}}
{{- define "st-common.capabilities.networkingGatewayReferenceGrant.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1/ReferenceGrant" -}}
  {{- print "gateway.networking.k8s.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1beta1/ReferenceGrant" -}}
  {{- print "gateway.networking.k8s.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API TCPRoute */}}
{{- define "st-common.capabilities.networkingGatewayTCPRoute.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/TCPRoute" -}}
  {{- print "gateway.networking.k8s.io/v1alpha2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API TLSRoute */}}
{{- define "st-common.capabilities.networkingGatewayTLSRoute.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/TLSRoute" -}}
  {{- print "gateway.networking.k8s.io/v1alpha2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Kubernetes Gateway API UDPRoute */}}
{{- define "st-common.capabilities.networkingGatewayUDPRoute.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.networking.k8s.io/v1alpha2/UDPRoute" -}}
  {{- print "gateway.networking.k8s.io/v1alpha2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}