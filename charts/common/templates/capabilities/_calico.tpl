{{- /*
(c) 2026 Firmansyah Nainggolan. All Rights Reserved.
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

{{/* Return the appropriate apiVersion for Calico BGPFilter */}}
{{- define "st-common.capabilities.calicoBGPFilter.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/BGPFilter" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/BGPFilter" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico BGPPeer */}}
{{- define "st-common.capabilities.calicoBGPPeer.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/BGPPeer" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/BGPPeer" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico BlockAffinity */}}
{{- define "st-common.capabilities.calicoBlockAffinity.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/BlockAffinity" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/BlockAffinity" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico CalicoNodeStatus */}}
{{- define "st-common.capabilities.calicoCalicoNodeStatus.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/CalicoNodeStatus" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/CalicoNodeStatus" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico ClusterInformation */}}
{{- define "st-common.capabilities.calicoClusterInformation.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/ClusterInformation" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/ClusterInformation" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico FelixConfiguration */}}
{{- define "st-common.capabilities.calicoFelixConfiguration.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/FelixConfiguration" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/FelixConfiguration" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico GlobalNetworkPolicy */}}
{{- define "st-common.capabilities.calicoGlobalNetworkPolicy.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/GlobalNetworkPolicy" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/GlobalNetworkPolicy" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico GlobalNetworkSet */}}
{{- define "st-common.capabilities.calicoGlobalNetworkSet.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/GlobalNetworkSet" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/GlobalNetworkSet" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico HostEndpoint */}}
{{- define "st-common.capabilities.calicoHostEndpoint.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/HostEndpoint" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/HostEndpoint" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico IPAMBlock */}}
{{- define "st-common.capabilities.calicoIPAMBlock.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/IPAMBlock" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/IPAMBlock" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico IPAMConfig */}}
{{- define "st-common.capabilities.calicoIPAMConfig.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/IPAMConfig" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/IPAMConfig" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico IPAMHandle */}}
{{- define "st-common.capabilities.calicoIPAMHandle.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/IPAMHandle" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/IPAMHandle" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico IPPool */}}
{{- define "st-common.capabilities.calicoIPPool.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/IPPool" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/IPPool" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico IPReservation */}}
{{- define "st-common.capabilities.calicoIPReservation.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/IPReservation" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/IPReservation" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico KubeControllersConfiguration */}}
{{- define "st-common.capabilities.calicoKubeControllersConfiguration.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/KubeControllersConfiguration" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/KubeControllersConfiguration" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico NetworkPolicy (note: Calico's, NOT the Kubernetes-native one) */}}
{{- define "st-common.capabilities.calicoNetworkPolicy.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/NetworkPolicy" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/NetworkPolicy" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico NetworkSet */}}
{{- define "st-common.capabilities.calicoNetworkSet.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/NetworkSet" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/NetworkSet" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico Node */}}
{{- define "st-common.capabilities.calicoNode.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/Node" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/Node" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico Profile */}}
{{- define "st-common.capabilities.calicoProfile.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/Profile" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/Profile" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Calico Tier (Calico Enterprise / Tigera) */}}
{{- define "st-common.capabilities.calicoTier.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "projectcalico.org/v3/Tier" -}}
  {{- print "projectcalico.org/v3" -}}
{{- else if .Capabilities.APIVersions.Has "crd.projectcalico.org/v1/Tier" -}}
  {{- print "crd.projectcalico.org/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}
