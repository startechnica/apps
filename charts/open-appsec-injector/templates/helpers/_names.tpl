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
  1. appsec.tuning.externalDatabase.<key>     (external instance wins)
  2. .Subcharts.postgresql.*                  (only valid when `postgresql.enabled=true`)
  3. fail with a clear error                  (neither configured; install would silently break)
*/ -}}
{{- define "open-appsec.tuning.dbHost" -}}
{{- if .Values.appsec.tuning.externalDatabase.host -}}
{{- .Values.appsec.tuning.externalDatabase.host -}}
{{- else if .Values.postgresql.enabled -}}
{{- include "postgresql.primary.fullname" .Subcharts.postgresql -}}
{{- else -}}
{{- fail "appsec.tuning is enabled but no database is configured: either set appsec.tuning.externalDatabase.host or postgresql.enabled=true" -}}
{{- end -}}
{{- end -}}

{{- define "open-appsec.tuning.dbPort" -}}
{{- if .Values.appsec.tuning.externalDatabase.host -}}
{{- .Values.appsec.tuning.externalDatabase.port -}}
{{- else if .Values.postgresql.enabled -}}
{{- .Subcharts.postgresql.Values.primary.service.ports.postgresql | default 5432 -}}
{{- else -}}
{{- fail "appsec.tuning is enabled but no database is configured: either set appsec.tuning.externalDatabase.host or postgresql.enabled=true" -}}
{{- end -}}
{{- end -}}

{{- define "open-appsec.tuning.dbSecretName" -}}
{{- if .Values.appsec.tuning.externalDatabase.existingSecret -}}
{{- .Values.appsec.tuning.externalDatabase.existingSecret -}}
{{- else if .Values.postgresql.enabled -}}
{{- include "st-common.names.fullname" .Subcharts.postgresql -}}
{{- else -}}
{{- fail "appsec.tuning is enabled but no database Secret is reachable: either set appsec.tuning.externalDatabase.existingSecret or postgresql.enabled=true" -}}
{{- end -}}
{{- end -}}

{{- define "open-appsec.tuning.dbSecretPasswordKey" -}}
{{- if .Values.appsec.tuning.externalDatabase.existingSecretPasswordKey -}}
{{- .Values.appsec.tuning.externalDatabase.existingSecretPasswordKey -}}
{{- else if .Values.postgresql.enabled -}}
{{- include "postgresql.adminPasswordKey" .Subcharts.postgresql -}}
{{- else -}}
{{- fail "appsec.tuning is enabled but no database Secret is reachable: either set appsec.tuning.externalDatabase.existingSecretPasswordKey or postgresql.enabled=true" -}}
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