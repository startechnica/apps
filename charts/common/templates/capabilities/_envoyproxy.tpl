{{- /*
(c) 2026 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* Return the appropriate apiVersion for Envoy Gateway core API (gateway.envoyproxy.io) */}}
{{- define "st-common.capabilities.envoyproxy.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.envoyproxy.io/v1alpha1" -}}
  {{- print "gateway.envoyproxy.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Envoy Gateway Backend */}}
{{- define "st-common.capabilities.envoyproxyBackend.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.envoyproxy.io/v1alpha1/Backend" -}}
  {{- print "gateway.envoyproxy.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Envoy Gateway BackendTrafficPolicy */}}
{{- define "st-common.capabilities.envoyproxyBackendTrafficPolicy.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.envoyproxy.io/v1alpha1/BackendTrafficPolicy" -}}
  {{- print "gateway.envoyproxy.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Envoy Gateway ClientTrafficPolicy */}}
{{- define "st-common.capabilities.envoyproxyClientTrafficPolicy.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.envoyproxy.io/v1alpha1/ClientTrafficPolicy" -}}
  {{- print "gateway.envoyproxy.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Envoy Gateway EnvoyExtensionPolicy */}}
{{- define "st-common.capabilities.envoyproxyEnvoyExtensionPolicy.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.envoyproxy.io/v1alpha1/EnvoyExtensionPolicy" -}}
  {{- print "gateway.envoyproxy.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Envoy Gateway EnvoyPatchPolicy */}}
{{- define "st-common.capabilities.envoyproxyEnvoyPatchPolicy.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.envoyproxy.io/v1alpha1/EnvoyPatchPolicy" -}}
  {{- print "gateway.envoyproxy.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Envoy Gateway EnvoyProxy */}}
{{- define "st-common.capabilities.envoyproxyEnvoyProxy.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.envoyproxy.io/v1alpha1/EnvoyProxy" -}}
  {{- print "gateway.envoyproxy.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Envoy Gateway HTTPRouteFilter */}}
{{- define "st-common.capabilities.envoyproxyHTTPRouteFilter.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.envoyproxy.io/v1alpha1/HTTPRouteFilter" -}}
  {{- print "gateway.envoyproxy.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Envoy Gateway SecurityPolicy */}}
{{- define "st-common.capabilities.envoyproxySecurityPolicy.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "gateway.envoyproxy.io/v1alpha1/SecurityPolicy" -}}
  {{- print "gateway.envoyproxy.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}
