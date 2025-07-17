{{- /*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* Create a default fully qualified app name. We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec). */}}
{{- define "freeradius.mariadb.fullname" -}}
  {{- include "st-common.names.dependency.fullname" (dict "chartName" "mariadb" "chartValues" .Values.mariadb "context" $) -}}
{{- end -}}

{{/* Return the Database hostname */}}
{{- define "freeradius.database.host" -}}
{{- if eq .Values.mariadb.architecture "replication" }}
  {{- ternary (include "freeradius.mariadb.fullname" .) .Values.externalDatabase.host .Values.mariadb.enabled -}}-primary
{{- else -}}
  {{- ternary (include "freeradius.mariadb.fullname" .) .Values.externalDatabase.host .Values.mariadb.enabled -}}
{{- end -}}
{{- end -}}

{{/* Return the Database port */}}
{{- define "freeradius.database.port" -}}
  {{- ternary "3306" .Values.externalDatabase.port .Values.mariadb.enabled | quote -}}
{{- end -}}

{{/* Return the Database database name */}}
{{- define "freeradius.database.name" -}}
{{- if .Values.mariadb.enabled }}
    {{- if .Values.global.mariadb }}
        {{- if .Values.global.mariadb.auth }}
            {{- coalesce .Values.global.mariadb.auth.database .Values.mariadb.auth.database -}}
        {{- else -}}
            {{- .Values.mariadb.auth.database -}}
        {{- end -}}
    {{- else -}}
        {{- .Values.mariadb.auth.database -}}
    {{- end -}}
{{- else -}}
  {{- .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/* Return the Database user */}}
{{- define "freeradius.database.user" -}}
{{- if .Values.mariadb.enabled }}
  {{- if .Values.global.mariadb }}
    {{- if .Values.global.mariadb.auth }}
      {{- coalesce .Values.global.mariadb.auth.username .Values.mariadb.auth.username -}}
    {{- else -}}
      {{- .Values.mariadb.auth.username -}}
    {{- end -}}
  {{- else -}}
    {{- .Values.mariadb.auth.username -}}
  {{- end -}}
{{- else -}}
  {{- .Values.externalDatabase.user -}}
{{- end -}}
{{- end -}}

{{/* Return the Database encrypted password */}}
{{- define "freeradius.database.secretName" -}}
{{- if .Values.mariadb.enabled }}
    {{- if .Values.global.mariadb }}
        {{- if .Values.global.mariadb.auth }}
            {{- if .Values.global.mariadb.auth.existingSecret }}
                {{- tpl .Values.global.mariadb.auth.existingSecret $ -}}
            {{- else -}}
                {{- default (include "freeradius.mariadb.fullname" .) (tpl .Values.mariadb.auth.existingSecret $) -}}
            {{- end -}}
        {{- else -}}
            {{- default (include "freeradius.mariadb.fullname" .) (tpl .Values.mariadb.auth.existingSecret $) -}}
        {{- end -}}
    {{- else -}}
        {{- default (include "freeradius.mariadb.fullname" .) (tpl .Values.mariadb.auth.existingSecret $) -}}
    {{- end -}}
{{- else -}}
    {{- default (include "st-common.secrets.name" (dict "existingSecret" .Values.mariadb.auth.existingSecret "context" $)) (tpl .Values.externalDatabase.existingSecret $) -}}
{{- end -}}
{{- end -}}

{{/* Add environment variables to configure database values */}}
{{- define "freeradius.database.secretKey" -}}
{{- if .Values.mariadb.enabled -}}
  {{- print "mariadb-password" -}}
{{- else -}}
  {{- if .Values.externalDatabase.existingSecret -}}
    {{- if .Values.externalDatabase.existingSecretPasswordKey -}}
      {{- printf "%s" .Values.externalDatabase.existingSecretPasswordKey -}}
    {{- else -}}
      {{- print "database-password" -}}
    {{- end -}}
  {{- else -}}
    {{- print "database-password" -}}
  {{- end -}}
{{- end -}}
{{- end -}}