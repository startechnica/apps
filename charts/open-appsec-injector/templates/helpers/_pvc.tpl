{{- /*
(c) 2026 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{- define "open-appsec.agent-config.pvClaim" -}}
{{- if .Values.agent.persistence.config.existingClaim -}}
{{- .Values.agent.persistence.config.existingClaim -}}
{{- else -}}
    {{- if .Values.agent.persistence.config.name -}}
    {{- .Values.agent.persistence.config.name -}}
    {{- else -}}
    {{- printf "%s-%s"  (include "open-appsec.agent.fullname" .) "config" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "open-appsec.agent-data.pvClaim" -}}
{{- if .Values.agent.persistence.data.existingClaim -}}
{{- .Values.agent.persistence.data.existingClaim -}}
{{- else -}}
    {{- if .Values.agent.persistence.data.name -}}
    {{- .Values.agent.persistence.data.name -}}
    {{- else -}}
    {{- printf "%s-%s"  (include "open-appsec.agent.fullname" .) "data" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "open-appsec.learning.pvClaim" -}}
{{- if .Values.appsec.learning.persistence.existingClaim -}}
{{- .Values.appsec.learning.persistence.existingClaim -}}
{{- else -}}
    {{- printf "%s-%s" (include "st-common.names.fullname" .) "learning" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "open-appsec.storage.pvClaim" -}}
{{- if .Values.appsec.storage.persistence.existingClaim -}}
{{- .Values.appsec.storage.persistence.existingClaim -}}
{{- else -}}
    {{- printf "%s-%s" (include "st-common.names.fullname" .) "storage" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
