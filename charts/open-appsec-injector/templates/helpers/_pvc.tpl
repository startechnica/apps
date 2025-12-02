{{- /*
(c) 2025 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{- define "open-appsec.agent-config.pvClaim" -}}
{{- if .Values.agent.persistence.existingClaim -}}
{{- .Values.agent.persistence.existingClaim -}}
{{- else -}}
    {{- if .Values.agent.persistence.config.name -}}
    {{- .Values.agent.persistence.config.name -}}
    {{- else -}}
    {{- printf "%s-%s"  (include "open-appsec.agent.fullname" .) "config" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "open-appsec.agent-data.pvClaim" -}}
{{- if .Values.agent.persistence.existingClaim -}}
{{- .Values.agent.persistence.existingClaim -}}
{{- else -}}
    {{- if .Values.agent.persistence.data.name -}}
    {{- .Values.agent.persistence.data.name -}}
    {{- else -}}
    {{- printf "%s-%s"  (include "open-appsec.agent.fullname" .) "data" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "open-appsec.learning.pvClaim" -}}
{{- if .Values.learning.persistence.existingClaim -}}
{{- .Values.learning.persistence.existingClaim -}}
{{- else -}}
    {{- if .Values.learning.persistence.name -}}
    {{- .Values.learning.persistence.name -}}
    {{- else -}}
    {{- printf "%s-%s" (include "st-common.names.fullname" .) "learning" | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "open-appsec.storage.pvClaim" -}}
{{- if .Values.storage.persistence.existingClaim -}}
{{- .Values.storage.persistence.existingClaim -}}
{{- else -}}
    {{- if .Values.storage.persistence.name -}}
    {{- .Values.storage.persistence.name -}}
    {{- else -}}
    {{- printf "%s-%s" (include "st-common.names.fullname" .) "storage" | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
{{- end -}}
{{- end -}}
