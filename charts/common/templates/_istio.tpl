{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* Return the appropriate apiVersion for Istio Extensions. */}}
{{- define "common.capabilities.istioExtensions.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "extensions.istio.io/v1alpha1" -}}
  {{- print "extensions.istio.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio Install. */}}
{{- define "common.capabilities.istioInstall.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "install.istio.io/v1alpha1" -}}
  {{- print "install.istio.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio Networking. */}}
{{- define "common.capabilities.istioNetworking.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1" -}}
  {{- print "networking.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1alpha3" -}}
  {{- print "networking.istio.io/v1alpha3" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio Security. */}}
{{- define "common.capabilities.istioSecurity.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "security.istio.io/v1" -}}
  {{- print "security.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "security.istio.io/v1beta1" -}}
  {{- print "security.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio Telemetry. */}}
{{- define "common.capabilities.istioTelemetry.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "telemetry.istio.io/v1/Telemetry" -}}
  {{- print "telemetry.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "telemetry.istio.io/v1alpha1/Telemetry" -}}
  {{- print "telemetry.istio.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio AuthorizationPolicy. */}}
{{- define "common.capabilities.istioAuthorizationPolicy.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "security.istio.io/v1/AuthorizationPolicy" -}}
  {{- print "security.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "security.istio.io/v1beta1/AuthorizationPolicy" -}}
  {{- print "security.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio DestinationRule. */}}
{{- define "common.capabilities.istioDestinationRule.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1/DestinationRule" -}}
  {{- print "networking.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/DestinationRule" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio EnvoyFilter. */}}
{{- define "common.capabilities.istioEnvoyFilter.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1alpha3/EnvoyFilter" -}}
  {{- print "networking.istio.io/v1alpha3" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio Gateway. */}}
{{- define "common.capabilities.istioGateway.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1/Gateway" -}}
  {{- print "networking.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/Gateway" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio PeerAuthentication. */}}
{{- define "common.capabilities.istioPeerAuthentication.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "security.istio.io/v1/PeerAuthentication" -}}
  {{- print "security.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "security.istio.io/v1beta1/PeerAuthentication" -}}
  {{- print "security.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio ProxyConfig. */}}
{{- define "common.capabilities.istioProxyConfig.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/ProxyConfig" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio RequestAuthentication. */}}
{{- define "common.capabilities.istioRequestAuthentication.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "security.istio.io/v1/RequestAuthentication" -}}
  {{- print "security.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "security.istio.io/v1beta1/RequestAuthentication" -}}
  {{- print "security.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio Sidecar. */}}
{{- define "common.capabilities.istioSidecar.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1/Sidecar" -}}
  {{- print "networking.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/Sidecar" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio ServiceEntry. */}}
{{- define "common.capabilities.istioServiceEntry.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1/ServiceEntry" -}}
  {{- print "networking.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/ServiceEntry" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio VirtualService. */}}
{{- define "common.capabilities.istioVirtualService.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1/VirtualService" -}}
  {{- print "networking.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/VirtualService" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio WasmPlugin. */}}
{{- define "common.capabilities.istioWasmPlugin.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "extensions.istio.io/v1alpha1/WasmPlugin" -}}
  {{- print "extensions.istio.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio WorkloadEntry. */}}
{{- define "common.capabilities.istioWorkloadEntry.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1/WorkloadEntry" -}}
  {{- print "networking.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/WorkloadEntry" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio WorkloadGroup. */}}
{{- define "common.capabilities.istioWorkloadGroup.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1/WorkloadGroup" -}}
  {{- print "networking.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/WorkloadGroup" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio IstioOperator. */}}
{{- define "common.capabilities.istioIstioOperator.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "install.istio.io/v1alpha1/IstioOperator" -}}
  {{- print "install.istio.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio AuthorizationPolicy. */}}
{{- define "st-common.capabilities.istioAuthorizationPolicy.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "security.istio.io/v1/AuthorizationPolicy" -}}
  {{- print "security.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "security.istio.io/v1beta1/AuthorizationPolicy" -}}
  {{- print "security.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio DestinationRule. */}}
{{- define "st-common.capabilities.istioDestinationRule.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1/DestinationRule" -}}
  {{- print "networking.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/DestinationRule" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio EnvoyFilter. */}}
{{- define "st-common.capabilities.istioEnvoyFilter.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1alpha3/EnvoyFilter" -}}
  {{- print "networking.istio.io/v1alpha3" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio Gateway. */}}
{{- define "st-common.capabilities.istioGateway.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1/Gateway" -}}
  {{- print "networking.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/Gateway" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio PeerAuthentication. */}}
{{- define "st-common.capabilities.istioPeerAuthentication.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "security.istio.io/v1/PeerAuthentication" -}}
  {{- print "security.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "security.istio.io/v1beta1/PeerAuthentication" -}}
  {{- print "security.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio ProxyConfig. */}}
{{- define "st-common.capabilities.istioProxyConfig.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/ProxyConfig" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio RequestAuthentication. */}}
{{- define "st-common.capabilities.istioRequestAuthentication.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "security.istio.io/v1/RequestAuthentication" -}}
  {{- print "security.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "security.istio.io/v1beta1/RequestAuthentication" -}}
  {{- print "security.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio Sidecar. */}}
{{- define "st-common.capabilities.istioSidecar.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1/Sidecar" -}}
  {{- print "networking.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/Sidecar" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio ServiceEntry. */}}
{{- define "st-common.capabilities.istioServiceEntry.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1/ServiceEntry" -}}
  {{- print "networking.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/ServiceEntry" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio Telemetry. */}}
{{- define "st-common.capabilities.istioTelemetry.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "telemetry.istio.io/v1/Telemetry" -}}
  {{- print "telemetry.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "telemetry.istio.io/v1alpha1/Telemetry" -}}
  {{- print "telemetry.istio.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio VirtualService. */}}
{{- define "st-common.capabilities.istioVirtualService.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1/VirtualService" -}}
  {{- print "networking.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/VirtualService" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio WasmPlugin. */}}
{{- define "st-common.capabilities.istioWasmPlugin.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "extensions.istio.io/v1alpha1/WasmPlugin" -}}
  {{- print "extensions.istio.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio WorkloadEntry. */}}
{{- define "st-common.capabilities.istioWorkloadEntry.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1/WorkloadEntry" -}}
  {{- print "networking.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/WorkloadEntry" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio WorkloadGroup. */}}
{{- define "st-common.capabilities.istioWorkloadGroup.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1/WorkloadGroup" -}}
  {{- print "networking.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1/WorkloadGroup" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio IstioOperator. */}}
{{- define "st-common.capabilities.istioIstioOperator.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "install.istio.io/v1alpha1/IstioOperator" -}}
  {{- print "install.istio.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}