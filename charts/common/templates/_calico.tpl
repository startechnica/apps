{{- /*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* Return the appropriate apiVersion for Project Calico */}}
{{- define "common.capabilities.calico.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{- define "common.capabilities.calicoCrd.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico BGPConfiguration */}}
{{- define "common.capabilities.calicoBGPConfiguration.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/BGPConfiguration" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/BGPConfiguration" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Project Calico */}}
{{- define "st-common.capabilities.calico.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{- define "st-common.capabilities.calicoCrd.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico BGPConfiguration */}}
{{- define "st-common.capabilities.calicoBGPConfiguration.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/BGPConfiguration" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/BGPConfiguration" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}