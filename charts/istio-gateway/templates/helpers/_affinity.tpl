{{/*
Copyright Firmansyah Nainggolan <firmansyah@nanggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return a soft podAffinity/podAntiAffinity definition
{{ include "gateways.affinities.pods.soft" (dict "component" "FOO" "customLabels" .Values.podLabels "extraMatchLabels" .Values.extraMatchLabels "topologyKey" "BAR" "extraPodAffinityTerms" .Values.extraPodAffinityTerms "context" $) -}}
*/}}
{{- define "gateways.affinities.pods.soft" -}}
{{- $component := default "" .component -}}
{{- $customLabels := default (dict) .customLabels -}}
{{- $extraMatchLabels := default (dict) .extraMatchLabels -}}
{{- $extraPodAffinityTerms := default (list) .extraPodAffinityTerms -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - podAffinityTerm:
      labelSelector:
        matchLabels: {{- (include "gateways.labels.matchLabels" ( dict "customLabels" $customLabels "context" .context )) | nindent 10 }}
          {{- if not (empty $component) }}
          {{ printf "app.kubernetes.io/component: %s" $component }}
          {{- end }}
          {{- range $key, $value := $extraMatchLabels }}
          {{ $key }}: {{ $value | quote }}
          {{- end }}
      topologyKey: {{ include "st-common.affinities.topologyKey" (dict "topologyKey" .topologyKey) }}
    weight: 1
  {{- range $extraPodAffinityTerms }}
  - podAffinityTerm:
      labelSelector:
        matchLabels: {{- (include "gateways.labels.matchLabels" ( dict "customLabels" $customLabels "context" $.context )) | nindent 10 }}
          {{- if not (empty $component) }}
          {{ printf "app.kubernetes.io/component: %s" $component }}
          {{- end }}
          {{- range $key, $value := .extraMatchLabels }}
          {{ $key }}: {{ $value | quote }}
          {{- end }}
      topologyKey: {{ include "st-common.affinities.topologyKey" (dict "topologyKey" .topologyKey) }}
    weight: {{ .weight | default 1 -}}
  {{- end -}}
{{- end -}}

{{/*
Return a hard podAffinity/podAntiAffinity definition
{{ include "gateways.affinities.pods.hard" (dict "component" "FOO" "customLabels" .Values.podLabels "extraMatchLabels" .Values.extraMatchLabels "topologyKey" "BAR" "extraPodAffinityTerms" .Values.extraPodAffinityTerms "context" $) -}}
*/}}
{{- define "gateways.affinities.pods.hard" -}}
{{- $component := default "" .component -}}
{{- $customLabels := default (dict) .customLabels -}}
{{- $extraMatchLabels := default (dict) .extraMatchLabels -}}
{{- $extraPodAffinityTerms := default (list) .extraPodAffinityTerms -}}
requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels: {{- (include "gateways.labels.matchLabels" ( dict "customLabels" $customLabels "context" .context )) | nindent 8 }}
        {{- if not (empty $component) }}
        {{ printf "app.kubernetes.io/component: %s" $component }}
        {{- end }}
        {{- range $key, $value := $extraMatchLabels }}
        {{ $key }}: {{ $value | quote }}
        {{- end }}
    topologyKey: {{ include "st-common.affinities.topologyKey" (dict "topologyKey" .topologyKey) }}
  {{- range $extraPodAffinityTerms }}
  - labelSelector:
      matchLabels: {{- (include "gateways.labels.matchLabels" ( dict "customLabels" $customLabels "context" $.context )) | nindent 8 }}
        {{- if not (empty $component) }}
        {{ printf "app.kubernetes.io/component: %s" $component }}
        {{- end }}
        {{- range $key, $value := .extraMatchLabels }}
        {{ $key }}: {{ $value | quote }}
        {{- end }}
    topologyKey: {{ include "st-common.affinities.topologyKey" (dict "topologyKey" .topologyKey) }}
  {{- end -}}
{{- end -}}

{{/*
Return a podAffinity/podAntiAffinity definition
{{ include "gateways.affinities.pods" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "gateways.affinities.pods" -}}
  {{- if eq .type "soft" }}
    {{- include "gateways.affinities.pods.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "gateways.affinities.pods.hard" . -}}
  {{- end -}}
{{- end -}}