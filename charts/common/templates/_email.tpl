{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{- define "st-commonemail.recipients" -}}
{{- print (join "," .Values.email.recipients)  -}}
{{- end -}}

{{- define "st-commonemail.recipientsCc" -}}
{{- print (join "," .Values.email.recipientsCc)  -}}
{{- end -}}

{{- define "st-common.email.recipientsBcc" -}}
{{- print (join "," .Values.email.recipientsBcc)  -}}
{{- end -}}

{{/*
Return whether Email uses password authentication or not
*/}}
{{- define "st-commonemail.auth.enabled" -}}
{{- if and .Values.email.server (or .Values.email.password .Values.email.existingSecretName) -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret name containing email server
*/}}
{{- define "st-commonemail.secretName" -}}
{{- if .Values.email.existingSecretName -}}
    {{- printf "%s" .Values.email.existingSecretName -}}
{{- else -}}
    {{- include "st-common.secrets.name" (dict "existingSecret" .Values.existingSecretName "context" $) }}
{{- end -}}
{{- end -}}

{{/*
Return the secret key that contains the app email password
*/}}
{{- define "st-commonemail.secretPasswordKey" -}}
{{- if .Values.email.existingSecretName -}}
    {{- if .Values.email.existingSecretPasswordKey -}}
        {{- printf "%s" .Values.email.existingSecretPasswordKey -}}
    {{- else -}}
        {{- printf "%s" "email-password" -}}
    {{- end -}}
{{- else -}}
    {{- print "email-password" -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret key that contains the app email api key
*/}}
{{- define "st-commonemail.secretApiKeyKey" -}}
{{- if .Values.email.existingSecretName -}}
    {{- if .Values.email.existingSecretApiKeyKey -}}
        {{- printf "%s" .Values.email.existingSecretPasswordKey -}}
    {{- else -}}
        {{- printf "%s" "email-apikey" -}}
    {{- end -}}
{{- else -}}
    {{- if .Values.existingSecretName -}}
        {{- printf "%s" "email-apikey" -}}
    {{- else -}}
        {{- printf "%s" "email-apikey" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "st-commonemail.apiKey" -}}
{{ include "st-common.secrets.lookup" (dict "secret" (include "st-commonemail.secretName" .) "key" (include "st-commonemail.secretApiKeyKey" .) "defaultValue" .Values.email.auth.apiKey "context" $) }}
{{- end -}}

{{- define "st-commonemail.password" -}}
{{ include "st-common.secrets.lookup" (dict "secret" (include "st-commonemail.secretName" .) "key" (include "st-commonemail.secretPasswordKey" .) "defaultValue" .Values.email.auth.password "context" $) }}
{{- end -}}

{{- define "st-commonemail.nameAddress" -}}
{{- printf "%s <%s>" .Values.email.from.name .Values.email.from.address -}}
{{- end -}}
