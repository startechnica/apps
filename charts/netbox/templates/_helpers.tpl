{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "netbox.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "netbox.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Return the proper Netbox worker fullname
*/}}
{{- define "netbox.worker.fullname" -}}
{{- printf "%s-%s" (include "common.names.fullname" .) "worker" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper Netbox housekeeping fullname
*/}}
{{- define "netbox.housekeeping.fullname" -}}
{{- printf "%s-%s" (include "common.names.fullname" .) "housekeeping" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper Netbox image name
*/}}
{{- define "netbox.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Netbox worker image name
*/}}
{{- define "netbox.worker.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.worker.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Netbox housekeeping image name
*/}}
{{- define "netbox.housekeeping.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.housekeeping.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Netbox init image name
*/}}
{{- define "netbox.init.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.init.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "netbox.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.image .Values.worker.image .Values.housekeeping.image .Values.init.image .Values.volumePermissions.image) "context" $) -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "netbox.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "netbox.labels" -}}
helm.sh/chart: {{ include "netbox.chart" . }}
{{ include "netbox.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "netbox.selectorLabels" -}}
app.kubernetes.io/name: {{ include "netbox.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "netbox.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
  {{- default (include "netbox.fullname" .) .Values.serviceAccount.name }}
{{- else }}
  {{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret that contains the PostgreSQL password
*/}}
{{- define "netbox.postgresql.secret" -}}
  {{- if .Values.postgresql.enabled }}
    {{- include "postgresql.v1.secretName" .Subcharts.postgresql -}}
  {{- else if .Values.externalDatabase.existingSecretName }}
    {{- .Values.externalDatabase.existingSecretName }}
  {{- else }}
    {{- .Values.existingSecret | default (include "netbox.fullname" .) }}
  {{- end }}
{{- end }}

{{/*
Name of the key in Secret that contains the PostgreSQL password
*/}}
{{- define "netbox.postgresql.secretKey" -}}
  {{- if .Values.postgresql.enabled -}}
    {{- include "postgresql.v1.userPasswordKey" .Subcharts.postgresql -}}
  {{- else if .Values.externalDatabase.existingSecretName -}}
    {{- .Values.externalDatabase.existingSecretKey -}}
  {{- else -}}
    db_password
  {{- end -}}
{{- end }}

{{/*
Name of the Secret that contains the Redis tasks password
*/}}
{{- define "netbox.tasksRedis.secret" -}}
  {{- if .Values.redis.enabled }}
    {{- include "redis.secretName" .Subcharts.redis -}}
  {{- else if .Values.tasksRedis.existingSecretName }}
    {{- .Values.tasksRedis.existingSecretName }}
  {{- else }}
    {{- .Values.existingSecret | default (include "netbox.fullname" .) }}
  {{- end }}
{{- end }}

{{/*
Name of the key in Secret that contains the Redis tasks password
*/}}
{{- define "netbox.tasksRedis.secretKey" -}}
  {{- if .Values.redis.enabled -}}
    {{- include "redis.secretPasswordKey" .Subcharts.redis -}}
  {{- else if .Values.tasksRedis.existingSecretName -}}
    {{ .Values.tasksRedis.existingSecretKey }}
  {{- else -}}
    redis_tasks_password
  {{- end -}}
{{- end }}

{{/*
Name of the Secret that contains the Redis cache password
*/}}
{{- define "netbox.cachingRedis.secret" -}}
  {{- if .Values.redis.enabled }}
    {{- include "redis.secretName" .Subcharts.redis -}}
  {{- else if .Values.cachingRedis.existingSecretName }}
    {{- .Values.cachingRedis.existingSecretName }}
  {{- else }}
    {{- .Values.existingSecret | default (include "netbox.fullname" .) }}
  {{- end }}
{{- end }}

{{/*
Name of the key in Secret that contains the Redis cache password
*/}}
{{- define "netbox.cachingRedis.secretKey" -}}
  {{- if .Values.redis.enabled -}}
    {{- include "redis.secretPasswordKey" .Subcharts.redis -}}
  {{- else if .Values.cachingRedis.existingSecretName -}}
    {{ .Values.cachingRedis.existingSecretKey }}
  {{- else -}}
    redis_cache_password
  {{- end -}}
{{- end }}

{{/*
Volumes that need to be mounted for .Values.extraConfig entries
*/}}
{{- define "netbox.extraConfig.volumes" -}}
{{- range $index, $config := .Values.extraConfig -}}
- name: extra-config-{{ $index }}
  {{- if $config.values }}
  configMap:
    name: {{ include "netbox.fullname" $ }}
    items:
    - key: extra-{{ $index }}.yaml
      path: extra-{{ $index }}.yaml
  {{- else if $config.configMap }}
  configMap:
    {{- toYaml $config.configMap | nindent 4 }}
  {{- else if $config.secret }}
  secret:
    {{- toYaml $config.secret | nindent 4 }}
  {{- end }}
{{ end -}}
{{- end }}

{{/*
Volume mounts for .Values.extraConfig entries
*/}}
{{- define "netbox.extraConfig.volumeMounts" -}}
{{- range $index, $config := .Values.extraConfig -}}
- name: extra-config-{{ $index }}
  mountPath: /run/config/extra/{{ $index }}
  readOnly: true
{{ end -}}
{{- end }}

{{/*
Return the Database hostname
*/}}
{{- define "netbox.databaseHost" -}}
{{- if eq .Values.postgresql.architecture "replication" }}
  {{- ternary (include "netbox.postgresql.fullname" .) (tpl .Values.externalDatabase.host $) .Values.postgresql.enabled -}}-primary
{{- else -}}
  {{- ternary (include "netbox.postgresql.fullname" .) (tpl .Values.externalDatabase.host $) .Values.postgresql.enabled -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database port
*/}}
{{- define "netbox.databasePort" -}}
  {{- ternary "5432" .Values.externalDatabase.port .Values.postgresql.enabled | quote -}}
{{- end -}}

{{/*
Return the Database database name
*/}}
{{- define "netbox.databaseName" -}}
{{- if .Values.postgresql.enabled }}
    {{- if .Values.global.postgresql }}
        {{- if .Values.global.postgresql.auth }}
            {{- coalesce .Values.global.postgresql.auth.database .Values.postgresql.auth.database -}}
        {{- else -}}
            {{- .Values.postgresql.auth.database -}}
        {{- end -}}
    {{- else -}}
        {{- .Values.postgresql.auth.database -}}
    {{- end -}}
{{- else -}}
    {{- .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database user
*/}}
{{- define "netbox.databaseUser" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if .Values.global.postgresql -}}
        {{- if .Values.global.postgresql.auth -}}
            {{- coalesce .Values.global.postgresql.auth.username .Values.postgresql.auth.username -}}
        {{- else -}}
            {{- .Values.postgresql.auth.username -}}
        {{- end -}}
    {{- else -}}
        {{- .Values.postgresql.auth.username -}}
    {{- end -}}
{{- else -}}
    {{- .Values.externalDatabase.user -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database encrypted password
*/}}
{{- define "netbox.databaseSecretName" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if .Values.global.postgresql -}}
        {{- if .Values.global.postgresql.auth -}}
            {{- if .Values.global.postgresql.auth.existingSecret -}}
                {{- tpl .Values.global.postgresql.auth.existingSecret $ -}}
            {{- else -}}
                {{- default (include "netbox.postgresql.fullname" .) (tpl .Values.postgresql.auth.existingSecret $) -}}
            {{- end -}}
        {{- else -}}
            {{- default (include "netbox.postgresql.fullname" .) (tpl .Values.postgresql.auth.existingSecret $) -}}
        {{- end -}}
    {{- else -}}
        {{- default (include "netbox.postgresql.fullname" .) (tpl .Values.postgresql.auth.existingSecret $) -}}
    {{- end -}}
{{- else -}}
    {{- default (printf "%s-externaldb" .Release.Name) (tpl .Values.externalDatabase.existingSecret $) -}}
{{- end -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "netbox.databaseSecretPasswordKey" -}}
{{- if .Values.postgresql.enabled -}}
    {{- print "password" -}}
{{- else -}}
    {{- if .Values.externalDatabase.existingSecret -}}
        {{- if .Values.externalDatabase.existingSecretPasswordKey -}}
            {{- printf "%s" .Values.externalDatabase.existingSecretPasswordKey -}}
        {{- else -}}
            {{- print "db-password" -}}
        {{- end -}}
    {{- else -}}
        {{- print "db-password" -}}
    {{- end -}}
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
        {{- print "db-port" -}}
    {{- end -}}
{{- end -}}
{{- define "netbox.databaseSecretDatabaseKey" -}}
    {{- if .Values.externalDatabase.existingSecretDatabaseKey -}}
        {{- printf "%s" .Values.externalDatabase.existingSecretDatabaseKey -}}
    {{- else -}}
        {{- print "db-port" -}}
    {{- end -}}
{{- end -}}

{{/* Validate values of Netbox - database */}}
{{- define "netbox.validateValues.database" -}}
{{- if and (not .Values.postgresql.enabled) (not .Values.externalDatabase.host) (and (not .Values.externalDatabase.password) (not .Values.externalDatabase.existingSecret)) -}}
netbox: database
    You disabled the PostgreSQL sub-chart but did not specify an external PostgreSQL host.
    Either deploy the PostgreSQL sub-chart (--set postgresql.enabled=true),
    or set a value for the external database host (--set externalDatabase.host=FOO)
    and set a value for the external database password (--set externalDatabase.password=BAR)
    or existing secret (--set externalDatabase.existingSecret=BAR).
{{- end -}}
{{- end -}}

{{/* Validate values of Netbox - TLS enabled */}}
{{- define "netbox.validateValues.tls" -}}
{{- if and .Values.tls.enabled (not .Values.tls.autoGenerated) (not .Values.tls.existingSecret) }}
netbox: tls.enabled
    In order to enable TLS, you also need to provide
    an existing secret containing the Keystore and Truststore or
    enable auto-generated certificates.
{{- end -}}
{{- end -}}