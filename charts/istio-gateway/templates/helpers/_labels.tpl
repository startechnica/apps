{{/*
Copyright Firmansyah Nainggolan <firmansyah@nanggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Kubernetes standard labels
{{ include "gateways.labels.standard" (dict "gatewayValues" .Values.gateways "customLabels" .Values.commonLabels "context" $) -}}
*/}}
{{- define "gateways.labels.standard" -}}
{{- if and (hasKey . "customLabels") (hasKey . "context") -}}
{{- $default := dict "app.kubernetes.io/name" .gatewayValues.name "helm.sh/chart" (include "gateways.names.chart" .context) "app.kubernetes.io/instance" .context.Release.Name "app.kubernetes.io/managed-by" .context.Release.Service -}}
{{- $istioLabels := dict "istio.io/dataplane-mode" "none" "gateway.istio.io/managed" .context.Release.Service "gateway.networking.k8s.io/gateway-name" .gatewayValues.name -}}
{{- with .context.Chart.AppVersion -}}
{{- $_ := set $default "app.kubernetes.io/version" . -}}
{{- end -}}
{{ template "gateways.tplvalues.merge" (dict "values" (list .customLabels $default $istioLabels) "context" .context) }}
{{- else -}}
app.kubernetes.io/name: {{ include "gateways.names.name" . }}
gateway.istio.io/managed: {{ .Release.Service }}
helm.sh/chart: {{ include "gateways.names.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
istio.io/dataplane-mode: none
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Kubernetes common labels
{{ include "gateways.labels.common" (dict "customLabels" .Values.commonLabels "context" $) -}}
*/}}
{{- define "gateways.labels.common" -}}
{{- if and (hasKey . "customLabels") (hasKey . "context") -}}
{{- $default := dict "app.kubernetes.io/name" (include "gateways.names.fullname" .context) "helm.sh/chart" (include "gateways.names.chart" .context) "app.kubernetes.io/instance" .context.Release.Name "app.kubernetes.io/managed-by" .context.Release.Service -}}
{{- $istioLabels := dict "gateway.istio.io/managed" .context.Release.Service -}}
{{- with .context.Chart.AppVersion -}}
{{- $_ := set $default "app.kubernetes.io/version" . -}}
{{- end -}}
{{ template "gateways.tplvalues.merge" (dict "values" (list .customLabels $default $istioLabels) "context" .context) }}
{{- else -}}
app.kubernetes.io/name: {{ include "gateways.names.name" . }}
gateway.istio.io/managed: {{ .Release.Service }}
helm.sh/chart: {{ include "gateways.names.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
istio.io/dataplane-mode: none
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Labels used on immutable fields such as deploy.spec.selector.matchLabels or svc.spec.selector
{{ include "gateways.labels.matchLabels" (dict "gatewayValues" .Values.gateways "customLabels" .Values.podLabels "context" $) -}}

We don't want to loop over custom labels appending them to the selector
since it's very likely that it will break deployments, services, etc.
However, it's important to overwrite the standard labels if the user
overwrote them on metadata.labels fields.
*/}}
{{- define "gateways.labels.matchLabels" -}}
{{- if and (hasKey . "customLabels") (hasKey . "context") -}}
{{ merge (pick (include "gateways.tplvalues.render" (dict "value" .customLabels "context" .context) | fromYaml) "app.kubernetes.io/name" "app.kubernetes.io/instance" "gateway.networking.k8s.io/gateway-name") (dict "app.kubernetes.io/name" .gatewayValues.name "app.kubernetes.io/instance" .context.Release.Name "gateway.networking.k8s.io/gateway-name" .gatewayValues.name) | toYaml }}
{{- else -}}
app.kubernetes.io/name: {{ include "gateways.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{- end -}}