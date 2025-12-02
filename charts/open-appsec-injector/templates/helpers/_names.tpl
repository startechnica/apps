{{- /*
(c) 2025 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{- define "open-appsec.webhook.fullname" -}}
{{- printf "%s-%s" (include "st-common.names.fullname" .) "webhook" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "open-appsec.webhook.serviceName" -}}
{{- if .Values.webhook.service.name -}}
{{- .Values.webhook.service.name -}}
{{- else -}}
{{- printf "%s-%s" (include "st-common.names.fullname" .) "webhook" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "open-appsec.agent.fullname" -}}
{{- printf "%s-%s" (include "st-common.names.fullname" .) "agent" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "open-appsec.learning.fullname" -}}
{{- printf "%s-%s" (include "st-common.names.fullname" .) "learning" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "open-appsec.storage.fullname" -}}
{{- printf "%s-%s" (include "st-common.names.fullname" .) "storage" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "open-appsec.tuning.fullname" -}}
{{- printf "%s-%s" (include "st-common.names.fullname" .) "tuning" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "open-appsec.names.secretName" -}}
{{- if .Values.existingSecretName -}}
{{- .Values.existingSecretName -}}
{{- else -}}
{{- printf "%s-%s" (include "st-common.names.fullname" .) "secrets" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}