{{- /*
(c) 2026 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Create a default fully qualified app name for the bundled PostgreSQL subchart.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "netbox.postgresql.fullname" -}}
{{ include "st-common.names.dependency.fullname" (dict "chartName" "postgresql" "chartValues" .Values.postgresql "context" $) }}
{{- end -}}

{{/*
Return the Database hostname
*/}}
{{- define "netbox.databaseHost" -}}
{{- if eq .Values.postgresql.architecture "replication" -}}
  {{- ternary (include "netbox.postgresql.fullname" .) (tpl .Values.externalDatabase.host $) .Values.postgresql.enabled -}}-primary
{{- else -}}
  {{- ternary (include "netbox.postgresql.fullname" .) (tpl .Values.externalDatabase.host $) .Values.postgresql.enabled -}}
{{- end -}}
{{- end -}}

{{/*
Return Database port
*/}}
{{- define "netbox.databasePort" -}}
{{- if .Values.postgresql.enabled -}}
    {{ include "postgresql.v1.service.port" .Subcharts.postgresql }}
{{- else -}}
  {{- default 5432 .Values.externalDatabase.port | int -}}
{{- end -}}
{{- end -}}

{{/*
Return Database name
*/}}
{{- define "netbox.databaseName" -}}
{{- if .Values.postgresql.enabled -}}
    {{ include "postgresql.v1.database" .Subcharts.postgresql }}
{{- else -}}
    {{- .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/*
Return Database user
*/}}
{{- define "netbox.databaseUser" -}}
{{- if .Values.postgresql.enabled -}}
    {{ include "postgresql.v1.username" .Subcharts.postgresql }}
{{- else -}}
    {{- .Values.externalDatabase.username -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database secret object name
*/}}
{{- define "netbox.databaseSecretName" -}}
{{- if .Values.postgresql.enabled -}}
    {{ include "postgresql.v1.secretName" .Subcharts.postgresql }}
{{- else if .Values.externalDatabase.existingSecretName -}}
    {{- .Values.externalDatabase.existingSecretName }}
{{- else -}}
    {{- printf "%s-%s" (include "st-common.names.fullname" .) "external-db" -}}
{{- end -}}
{{- end -}}

{{/*
Return database password key
*/}}
{{- define "netbox.databaseSecretPasswordKey" -}}
{{- if .Values.postgresql.enabled -}}
    {{- include "postgresql.v1.userPasswordKey" .Subcharts.postgresql -}}
{{- else -}}
    {{- if .Values.externalDatabase.existingSecretName -}}
        {{- if .Values.externalDatabase.existingSecretPasswordKey -}}
            {{- printf "%s" .Values.externalDatabase.existingSecretPasswordKey -}}
        {{- else -}}
            {{- printf "%s" "db-password" -}}
        {{- end -}}
    {{- else -}}
        {{- printf "%s" "db-password" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return Database password
*/}}
{{- define "netbox.databasePassword" -}}
{{- if .Values.postgresql.enabled -}}
    {{ include "postgresql.v1.password" .Subcharts.postgresql }}
{{- else -}}
    {{ include "st-common.secrets.lookup" (dict "secret" (include "netbox.databaseSecretName" .) "key" (include "netbox.databaseSecretPasswordKey" .) "defaultValue" .Values.externalDatabase.password "context" $) }}
{{- end -}}
{{- end -}}

{{- define "netbox.databaseSecretHostKey" -}}
{{- if .Values.externalDatabase.existingSecretHostKey -}}
    {{- printf "%s" .Values.externalDatabase.existingSecretHostKey -}}
{{- else -}}
    {{- print "db-host" -}}
{{- end -}}
{{- end -}}

{{- define "netbox.databaseSecretPortKey" -}}
{{- if .Values.externalDatabase.existingSecretPortKey -}}
    {{- printf "%s" .Values.externalDatabase.existingSecretPortKey -}}
{{- else -}}
    {{- print "db-port" -}}
{{- end -}}
{{- end -}}

{{- define "netbox.databaseSecretUserKey" -}}
{{- if .Values.externalDatabase.existingSecretUserKey -}}
    {{- printf "%s" .Values.externalDatabase.existingSecretUserKey -}}
{{- else -}}
    {{- print "db-user" -}}
{{- end -}}
{{- end -}}

{{- define "netbox.databaseSecretDatabaseKey" -}}
{{- if .Values.externalDatabase.existingSecretDatabaseKey -}}
    {{- printf "%s" .Values.externalDatabase.existingSecretDatabaseKey -}}
{{- else -}}
    {{- print "db-name" -}}
{{- end -}}
{{- end -}}

{{/* Validate values of Netbox - database */}}
{{- define "netbox.validateValues.database" -}}
{{- if and (not .Values.postgresql.enabled) (not .Values.externalDatabase.host) (and (not .Values.externalDatabase.password) (not .Values.externalDatabase.existingSecretName)) -}}
netbox: database
    You disabled the PostgreSQL sub-chart but did not specify an external PostgreSQL host.
    Either deploy the PostgreSQL sub-chart (--set postgresql.enabled=true),
    or set a value for the external database host (--set externalDatabase.host=<db-host>)
    and set a value for the external database password (--set externalDatabase.password=<db-password>)
    or use existing secret (--set externalDatabase.existingSecretName=BAR).
{{- end -}}
{{- end -}}
