{{ $gateway := index .Values "gateways" "istio-ingressgateway" }}


{{/*
Returns the proper service account name depending if an explicit service account name is set
in the values file. If the name is not set it will default to either common.names.fullname if controller.serviceAccount.create
is true or default otherwise.
*/}}
{{- define "certmanager.controller.serviceAccountName" -}}
    {{- if $gateway.serviceAccount.create -}}
        {{- if (empty $gateway.serviceAccount.name) -}}
          {{- printf "%s-controller" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
        {{- else -}}
          {{ default "default" $gateway.serviceAccount.name }}
        {{- end -}}
    {{- else -}}
        {{ default "default" $gateway.serviceAccount.name }}
    {{- end -}}
{{- end -}}


{{/* Create the name of the service account to use for the deployment */}}
{{- define "gateway.serviceAccountName" -}}
    {{- if .Values.serviceAccount.create -}}
        {{ default (printf "%s" (include "common.names.fullname" .)) $gateway.serviceAccount.name | trunc 63 | trimSuffix "-" }}
    {{- else -}}
        {{ default "default" .Values.serviceAccount.name }}
    {{- end -}}
{{- end -}}

{{/* Return the proper Proxy image name */}}
{{- define "proxy.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Gateway image name */}}
{{- define "gateway.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Docker Image Registry Secret Names */}}
{{- define "proxy.imagePullSecrets" -}}
  {{- include "common.images.pullSecrets" (dict "images" (list .Values.proxy.image) "global" .Values.global) -}}
{{- end -}}

{{/* Return the proper Docker Image Registry Secret Names */}}
{{- define "gateway.imagePullSecrets" -}}
  {{- include "common.images.pullSecrets" (dict "images" (list .Values.proxy.image) "global" .Values.global) -}}
{{- end -}}