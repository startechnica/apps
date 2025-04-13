{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* Return the appropriate apiVersion for MetalLB */}}
{{- define "common.capabilities.metallb.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta1" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for MetalLB BFDProfile */}}
{{- define "common.capabilities.metallbBFDProfile.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta1/BFDProfile" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for MetalLB BGPAdvertisement */}}
{{- define "common.capabilities.metallbBGPAdvertisement.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta1/BGPAdvertisement" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for MetalLB BGPPeer */}}
{{- define "common.capabilities.metallbBGPPeer.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta2/BGPPeer" -}}
  {{- print "metallb.io/v1beta2" -}}
{{- else if .Capabilities.APIVersions.Has "metallb.io/v1beta1/BGPPeer" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for MetalLB Community */}}
{{- define "common.capabilities.metallbCommunity.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta1/Community" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for MetalLB IPAddressPool */}}
{{- define "common.capabilities.metallbIPAddressPool.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta1/IPAddressPool" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for MetalLB L2Advertisement */}}
{{- define "common.capabilities.metallbL2Advertisement.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta1/L2Advertisement" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for MetalLB ServiceL2Status */}}
{{- define "common.capabilities.metallbServiceL2Status.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta1/ServiceL2Status" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for MetalLB */}}
{{- define "st-common.capabilities.metallb.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta1" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for MetalLB BFDProfile */}}
{{- define "st-common.capabilities.metallbBFDProfile.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta1/BFDProfile" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for MetalLB BGPAdvertisement */}}
{{- define "st-common.capabilities.metallbBGPAdvertisement.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta1/BGPAdvertisement" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for MetalLB BGPPeer */}}
{{- define "st-common.capabilities.metallbBGPPeer.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta2/BGPPeer" -}}
  {{- print "metallb.io/v1beta2" -}}
{{- else if .Capabilities.APIVersions.Has "metallb.io/v1beta1/BGPPeer" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for MetalLB Community */}}
{{- define "st-common.capabilities.metallbCommunity.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta1/Community" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for MetalLB IPAddressPool */}}
{{- define "st-common.capabilities.metallbIPAddressPool.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta1/IPAddressPool" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for MetalLB L2Advertisement */}}
{{- define "st-common.capabilities.metallbL2Advertisement.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta1/L2Advertisement" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for MetalLB ServiceL2Status */}}
{{- define "st-common.capabilities.metallbServiceL2Status.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "metallb.io/v1beta1/ServiceL2Status" -}}
  {{- print "metallb.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}
