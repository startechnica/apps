{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

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

{{/* Return the appropriate apiVersion for Prometheus API AlertmanagerConfig */}}
{{- define "common.capabilities.coreosMonitoringAlertmanagerConfig.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1alpha1/AlertmanagerConfig" -}}
  {{- print "monitoring.coreos.com/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API Alertmanager */}}
{{- define "common.capabilities.coreosMonitoringAlertmanager.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1/Alertmanager" -}}
  {{- print "monitoring.coreos.com/v1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1/Alertmanager" -}}
  {{- print "monitoring.coreos.com/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API PodMonitor */}}
{{- define "common.capabilities.coreosMonitoringPodMonitor.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1/PodMonitor" -}}
  {{- print "monitoring.coreos.com/v1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1/PodMonitor" -}}
  {{- print "monitoring.coreos.com/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API Probe */}}
{{- define "common.capabilities.coreosMonitoringProbe.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1/Probe" -}}
  {{- print "monitoring.coreos.com/v1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1/Probe" -}}
  {{- print "monitoring.coreos.com/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API Prometheus */}}
{{- define "common.capabilities.coreosMonitoringPrometheus.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1/Prometheus" -}}
  {{- print "monitoring.coreos.com/v1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1/Prometheus" -}}
  {{- print "monitoring.coreos.com/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API PrometheusAgent */}}
{{- define "common.capabilities.coreosMonitoringPrometheusAgent.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1alpha1/PrometheusAgent" -}}
  {{- print "monitoring.coreos.com/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API PrometheusRule */}}
{{- define "common.capabilities.coreosMonitoringPrometheusRule.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1/PrometheusRule" -}}
  {{- print "monitoring.coreos.com/v1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1/PrometheusRule" -}}
  {{- print "monitoring.coreos.com/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API ScrapeConfig */}}
{{- define "common.capabilities.coreosMonitoringScrapeConfig.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1alpha1/ScrapeConfig" -}}
  {{- print "monitoring.coreos.com/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API ServiceMonitor */}}
{{- define "common.capabilities.coreosMonitoringServiceMonitor.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1/ServiceMonitor" -}}
  {{- print "monitoring.coreos.com/v1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1/ServiceMonitor" -}}
  {{- print "monitoring.coreos.com/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API ThanosRuler */}}
{{- define "common.capabilities.coreosMonitoringThanosRuler.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1/ThanosRuler" -}}
  {{- print "monitoring.coreos.com/v1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1/ThanosRuler" -}}
  {{- print "monitoring.coreos.com/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API */}}
{{- define "st-common.capabilities.coreosMonitoring.apiVersion" -}}
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

{{/* Return the appropriate apiVersion for Prometheus API AlertmanagerConfig */}}
{{- define "st-common.capabilities.coreosMonitoringAlertmanagerConfig.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1alpha1/AlertmanagerConfig" -}}
  {{- print "monitoring.coreos.com/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API Alertmanager */}}
{{- define "st-common.capabilities.coreosMonitoringAlertmanager.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1/Alertmanager" -}}
  {{- print "monitoring.coreos.com/v1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1/Alertmanager" -}}
  {{- print "monitoring.coreos.com/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API PodMonitor */}}
{{- define "st-common.capabilities.coreosMonitoringPodMonitor.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1/PodMonitor" -}}
  {{- print "monitoring.coreos.com/v1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1/PodMonitor" -}}
  {{- print "monitoring.coreos.com/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API Probe */}}
{{- define "st-common.capabilities.coreosMonitoringProbe.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1/Probe" -}}
  {{- print "monitoring.coreos.com/v1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1/Probe" -}}
  {{- print "monitoring.coreos.com/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API Prometheus */}}
{{- define "st-common.capabilities.coreosMonitoringPrometheus.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1/Prometheus" -}}
  {{- print "monitoring.coreos.com/v1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1/Prometheus" -}}
  {{- print "monitoring.coreos.com/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API PrometheusAgent */}}
{{- define "st-common.capabilities.coreosMonitoringPrometheusAgent.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1alpha1/PrometheusAgent" -}}
  {{- print "monitoring.coreos.com/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API PrometheusRule */}}
{{- define "st-common.capabilities.coreosMonitoringPrometheusRule.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1/PrometheusRule" -}}
  {{- print "monitoring.coreos.com/v1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1/PrometheusRule" -}}
  {{- print "monitoring.coreos.com/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API ScrapeConfig */}}
{{- define "st-common.capabilities.coreosMonitoringScrapeConfig.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1alpha1/ScrapeConfig" -}}
  {{- print "monitoring.coreos.com/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API ServiceMonitor */}}
{{- define "st-common.capabilities.coreosMonitoringServiceMonitor.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1/ServiceMonitor" -}}
  {{- print "monitoring.coreos.com/v1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1/ServiceMonitor" -}}
  {{- print "monitoring.coreos.com/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Prometheus API ThanosRuler */}}
{{- define "st-common.capabilities.coreosMonitoringThanosRuler.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1/ThanosRuler" -}}
  {{- print "monitoring.coreos.com/v1" -}}
{{- else if .Capabilities.APIVersions.Has "monitoring.coreos.com/v1beta1/ThanosRuler" -}}
  {{- print "monitoring.coreos.com/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}