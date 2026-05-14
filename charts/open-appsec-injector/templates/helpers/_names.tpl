{{- /*
(c) 2026 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
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

{{- /*
Resolve the tuning component's PostgreSQL connection details. Precedence:
  1. .Values.externalDatabase.<key>           (external instance wins; shared by every component)
  2. .Subcharts.postgresql.*                  (only valid when `postgresql.enabled=true`)
  3. fail with a clear error                  (neither configured; install would silently break)
The database NAME is intentionally NOT plumbed through — the smartsync-tuning
binary hardcodes it in the connection-URL format string (datatube.go), so
no chart-side override works without an upstream patch.
*/ -}}
{{- define "open-appsec.tuning.dbHost" -}}
{{- if .Values.externalDatabase.host -}}
{{- .Values.externalDatabase.host -}}
{{- else if .Values.postgresql.enabled -}}
{{- include "postgresql.primary.fullname" .Subcharts.postgresql -}}
{{- else -}}
{{- fail "appsec.tuning is enabled but no database is configured: either set externalDatabase.host or postgresql.enabled=true" -}}
{{- end -}}
{{- end -}}

{{- define "open-appsec.tuning.dbPort" -}}
{{- if .Values.externalDatabase.host -}}
{{- .Values.externalDatabase.port -}}
{{- else if .Values.postgresql.enabled -}}
{{- .Subcharts.postgresql.Values.primary.service.ports.postgresql | default 5432 -}}
{{- else -}}
{{- fail "appsec.tuning is enabled but no database is configured: either set externalDatabase.host or postgresql.enabled=true" -}}
{{- end -}}
{{- end -}}

{{- define "open-appsec.tuning.dbSecretName" -}}
{{- if .Values.externalDatabase.existingSecret -}}
{{- .Values.externalDatabase.existingSecret -}}
{{- else if .Values.postgresql.enabled -}}
{{- include "st-common.names.fullname" .Subcharts.postgresql -}}
{{- else -}}
{{- fail "appsec.tuning is enabled but no database Secret is reachable: either set externalDatabase.existingSecret or postgresql.enabled=true" -}}
{{- end -}}
{{- end -}}

{{- define "open-appsec.tuning.dbSecretPasswordKey" -}}
{{- if .Values.externalDatabase.existingSecretPasswordKey -}}
{{- .Values.externalDatabase.existingSecretPasswordKey -}}
{{- else if .Values.postgresql.enabled -}}
{{- include "postgresql.adminPasswordKey" .Subcharts.postgresql -}}
{{- else -}}
{{- fail "appsec.tuning is enabled but no database Secret is reachable: either set externalDatabase.existingSecretPasswordKey or postgresql.enabled=true" -}}
{{- end -}}
{{- end -}}

{{- /*
Resolve the name of the Secret holding the webhook serving cert.
Precedence:
  1. webhook.tls.certificatesSecretName (BYO override)
  2. <fullname>-webhook-tls (chart-rendered, used by Certificate.yaml when tls.certManager.create=true)
*/ -}}
{{- define "open-appsec.webhook.tlsSecretName" -}}
{{- if .Values.webhook.tls.certificatesSecretName -}}
{{- .Values.webhook.tls.certificatesSecretName -}}
{{- else -}}
{{- printf "%s-webhook-tls" (include "st-common.names.fullname" .) -}}
{{- end -}}
{{- end -}}