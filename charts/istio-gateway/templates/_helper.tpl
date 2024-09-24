{{/*
Returns the proper service account name depending if an explicit service account name is set
in the values file. If the name is not set it will default to either common.names.fullname if $gateway.serviceAccount.create
is true or default otherwise.
*/}}
{{- define "gateway.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create -}}
    {{ default (printf "%s-sa" (include "common.names.fullname" .)) .Values.serviceAccount.name | trunc 63 | trimSuffix "-" }}
  {{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
  {{- end -}}
{{- end -}}


{{/*
{{ include "gateway.rbac.serviceAccountName" ( dict "gatewayValues" .Values.gateways.gateway "context" . ) }}
*/}}

{{- define "gateway.rbac.serviceAccountName" -}}
{{- if and .gatewayValues.serviceAccount .gatewayValues.serviceAccount.create -}}
  {{ print .gatewayValues.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
  {{ default "default" .context.Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Return the proper Docker Image Registry Secret Names */}}
{{- define "gateway.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.proxy.image) "global" .Values.global) -}}
{{- end -}}