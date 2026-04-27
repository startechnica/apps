{{- /*
(c) 2025 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Create the name of the service account to use for the open-appsec Webhook
*/}}
{{- define "open-appsec.webhook.serviceAccountName" -}}
{{- if .Values.webhook.serviceAccount.create -}}
    {{ default (printf "%s-webhook" (include "st-common.names.fullname" .)) .Values.webhook.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.webhook.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the open-appsec Learning
*/}}
{{- define "open-appsec.learning.serviceAccountName" -}}
{{- if .Values.appsec.learning.serviceAccount.create -}}
    {{ default (printf "%s-learning" (include "st-common.names.fullname" .)) .Values.appsec.learning.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.appsec.learning.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the open-appsec Storage
*/}}
{{- define "open-appsec.storage.serviceAccountName" -}}
{{- if .Values.appsec.storage.serviceAccount.create -}}
    {{ default (printf "%s-storage" (include "st-common.names.fullname" .)) .Values.appsec.storage.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.appsec.storage.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the open-appsec Tuning
*/}}
{{- define "open-appsec.tuning.serviceAccountName" -}}
{{- if .Values.appsec.tuning.serviceAccount.create -}}
    {{ default (printf "%s-tuning" (include "st-common.names.fullname" .)) .Values.appsec.tuning.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.appsec.tuning.serviceAccount.name }}
{{- end -}}
{{- end -}}
