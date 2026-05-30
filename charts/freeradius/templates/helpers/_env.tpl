{{- /*
(c) 2026 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Secret-backed container env vars (`secretKeyRef`) for the freeradius container.
Each entry pulls from the per-password BYO Secret when
`auth.existingSecretPerPassword` is set, otherwise from the chart-managed
credentials Secret (`$globalSecretName`) or the SQL/REST/Redis module Secrets.
These stay explicit `env:` entries rather than `envFrom` keys because a Secret
cannot reference another Secret's keys.
Usage: {{ include "freeradius.secretEnvVars" . | trimPrefix "\n" | nindent 12 }}
*/}}
{{- define "freeradius.secretEnvVars" -}}
{{- $globalSecretName := printf "%s" (tpl (include "st-common.secrets.name" (dict "existingSecret" .Values.auth.existingSecret "context" $)) $) -}}
{{- if .Values.modules.sql.enabled }}
- name: FREERADIUS_MODS_SQL_PASSWORD
  valueFrom:
    secretKeyRef:
    {{- if .Values.auth.existingSecretPerPassword }}
      name: {{ tpl (include "st-common.secrets.name" (dict "existingSecret" .Values.auth.existingSecretPerPassword.databasePassword "context" $)) $ }}
      key: {{ include "st-common.secrets.key" (dict "existingSecret" .Values.auth.existingSecretPerPassword "key" "databasePassword") }}
    {{- else }}
      name: {{ include "freeradius.sql.secretName" . }}
      key: {{ include "freeradius.sql.secretKey" . }}
    {{- end }}
{{- end }}
{{- if .Values.sites.status.enabled }}
- name: FREERADIUS_SITES_STATUS_SECRET
  valueFrom:
    secretKeyRef:
    {{- if .Values.auth.existingSecretPerPassword }}
      name: {{ tpl (include "st-common.secrets.name" (dict "existingSecret" .Values.auth.existingSecretPerPassword.sitesStatusSecret "context" $)) $ }}
      key: {{ include "st-common.secrets.key" (dict "existingSecret" .Values.auth.existingSecretPerPassword "key" "sitesStatusSecret") }}
    {{- else }}
      name: {{ $globalSecretName }}
      key: {{ include "st-common.secrets.key" (dict "existingSecret" .Values.auth.existingSecret "key" "sites-status-secret") }}
    {{- end }}
{{- end }}
{{- if and .Values.tls.enabled .Values.sites.tls.privateKeyPassword }}
- name: FREERADIUS_SITES_TLS_PRIVKEY_PASSWORD
  valueFrom:
    secretKeyRef:
    {{- if .Values.auth.existingSecretPerPassword }}
      name: {{ tpl (include "st-common.secrets.name" (dict "existingSecret" .Values.auth.existingSecretPerPassword.sitesTlsPrivKeyPassword "context" $)) $ }}
      key: {{ include "st-common.secrets.key" (dict "existingSecret" .Values.auth.existingSecretPerPassword "key" "sitesTlsPrivKeyPassword") }}
    {{- else }}
      name: {{ $globalSecretName }}
      key: {{ include "st-common.secrets.key" (dict "existingSecret" .Values.auth.existingSecret "key" "sites-tls-privkey-password") }}
    {{- end }}
{{- end }}
{{- if and .Values.modules.rest.enabled (ne .Values.modules.rest.auth "none") }}
- name: FREERADIUS_MODS_REST_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "freeradius.rest.secretName" . }}
      key: {{ include "freeradius.rest.secretKey" . }}
{{- end }}
{{- if include "freeradius.redis.usePassword" . }}
- name: FREERADIUS_MODS_REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "freeradius.redis.secretName" . }}
      key: {{ include "freeradius.redis.secretKey" . }}
{{- end }}
{{- if and .Values.modules.eap.enabled .Values.modules.eap.tlsConfig.private_key_password }}
- name: FREERADIUS_MODS_EAP_TLS_PRIVKEY_PASSWORD
  valueFrom:
    secretKeyRef:
    {{- if .Values.auth.existingSecretPerPassword }}
      name: {{ tpl (include "st-common.secrets.name" (dict "existingSecret" .Values.auth.existingSecretPerPassword.modsEapTlsPrivKeyPassword "context" $)) $ }}
      key: {{ include "st-common.secrets.key" (dict "existingSecret" .Values.auth.existingSecretPerPassword "key" "modsEapTlsPrivKeyPassword") }}
    {{- else }}
      name: {{ $globalSecretName }}
      key: {{ include "st-common.secrets.key" (dict "existingSecret" .Values.auth.existingSecret "key" "mods-eap-tls-privkey-password") }}
    {{- end }}
{{- end }}
{{- end -}}
