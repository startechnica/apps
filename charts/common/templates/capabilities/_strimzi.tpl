{{- /*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* Return the appropriate apiVersion for Strimzi Kafka */}}
{{- define "st-common.capabilities.strimziKafka.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "kafka.strimzi.io/v1beta2/Kafka" -}}
  {{- print "kafka.strimzi.io/v1beta2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Strimzi KafkaBridge */}}
{{- define "st-common.capabilities.strimziKafkaBridge.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "kafka.strimzi.io/v1beta2/KafkaBridge" -}}
  {{- print "kafka.strimzi.io/v1beta2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Strimzi KafkaConnector */}}
{{- define "st-common.capabilities.strimziKafkaConnector.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "kafka.strimzi.io/v1beta2/KafkaConnector" -}}
  {{- print "kafka.strimzi.io/v1beta2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Strimzi KafkaConnect */}}
{{- define "st-common.capabilities.strimziKafkaConnect.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "kafka.strimzi.io/v1beta2/KafkaConnect" -}}
  {{- print "kafka.strimzi.io/v1beta2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Strimzi KafkaMirrorMaker2 */}}
{{- define "st-common.capabilities.strimziKafkaMirrorMaker2.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "kafka.strimzi.io/v1beta2/KafkaMirrorMaker2" -}}
  {{- print "kafka.strimzi.io/v1beta2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Strimzi KafkaNodePool */}}
{{- define "st-common.capabilities.strimziKafkaNodePool.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "kafka.strimzi.io/v1beta2/KafkaNodePool" -}}
  {{- print "kafka.strimzi.io/v1beta2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Strimzi KafkaRebalance */}}
{{- define "st-common.capabilities.strimziKafkaRebalance.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "kafka.strimzi.io/v1beta2/KafkaRebalance" -}}
  {{- print "kafka.strimzi.io/v1beta2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Strimzi KafkaTopic */}}
{{- define "st-common.capabilities.strimziKafkaTopic.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "kafka.strimzi.io/v1beta2/KafkaTopic" -}}
  {{- print "kafka.strimzi.io/v1beta2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Strimzi KafkaUser */}}
{{- define "st-common.capabilities.strimziKafkaUser.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "kafka.strimzi.io/v1beta2/KafkaUser" -}}
  {{- print "kafka.strimzi.io/v1beta2" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}