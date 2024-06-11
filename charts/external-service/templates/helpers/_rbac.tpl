{{/*
Create the name of the service account to use
*/}}
{{- define "external-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
  {{- default (include "external-service.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
  {{- default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}