{{- /*
Copyright (c) 2024 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* Return the appropriate apiVersion for Prometheus API */}}
{{- define "common.capabilities.coreosMonitoring.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1" -}}
  {{- print "monitoring.coreos.com/v1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1" -}}
  {{- print "monitoring.coreos.com/v1beta1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1alpha2" -}}
  {{- print "monitoring.coreos.com/v1alpha2" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1alpha1" -}}
  {{- print "monitoring.coreos.com/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}