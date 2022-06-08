{{/* Create the name of the service account to use for the deployment */}}
{{- define "adminer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
  {{ default (printf "%s" (include "common.names.fullname" .)) .Values.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
  {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Return the proper Adminer image name */}}
{{- define "adminer.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Docker Image Registry Secret Names */}}
{{- define "adminer.imagePullSecrets" -}}
  {{- include "common.images.pullSecrets" (dict "images" (list .Values.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Create the name of the SSL certificate to use
*/}}
{{- define "istioCertificateSecret2" -}}
{{- default (printf "%s-tls" (include "common.names.fullname" .)) .Values.istio.certificate.existingSecret }}
{{- end }}

{{ define "istioCertificateSecret" }}
{{- if .Values.istio.certificate.existingSecret }}
  {{ .Values.istio.certificate.existingSecret }}
{{- else }}
  {{- default (printf "%s-tls" (include "common.names.fullname" .)) }}
{{- end }}
{{- end }}