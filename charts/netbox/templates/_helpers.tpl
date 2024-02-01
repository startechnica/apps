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
{{- if .Values.fullnameOverride -}}
    {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{- $name := default .Chart.Name .Values.nameOverride }}
    {{- if contains $name .Release.Name -}}
        {{- .Release.Name | trunc 63 | trimSuffix "-" }}
    {{- else -}}
        {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
    {{- end -}}
{{- end -}}
{{- end -}}

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
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "netbox.postgresql.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "postgresql" "chartValues" .Values.postgresql "context" $) -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "netbox.redis.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $) -}}
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
{{- define "netbox.init-dirs.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.initDirs.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper PostgreSQL image name
*/}}
{{- define "netbox.postgresql.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.postgresql.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Redis image name
*/}}
{{- define "netbox.redis.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.redis.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "netbox.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.image .Values.worker.image .Values.housekeeping.image .Values.initDirs.image .Values.volumePermissions.image) "context" $) -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "netbox.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

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
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "netbox.selectorLabels" -}}
app.kubernetes.io/name: {{ include "netbox.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "netbox.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
  {{- default (include "netbox.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
  {{- default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the path Netbox is hosted on. This looks at httpRelativePath and returns it with a trailing slash. For example:
    / -> / (the default httpRelativePath)
    /auth -> /auth/ (trailing slash added)
    /custom/ -> /custom/ (unchanged)
*/}}
{{- define "netbox.httpPath" -}}
{{ ternary .Values.httpRelativePath (printf "%s%s" .Values.httpRelativePath "/") (hasSuffix "/" .Values.httpRelativePath) }}
{{- end -}}

{{/*
Name of the Secret that contains the PostgreSQL password
*/}}
{{- define "netbox.postgresql.secret" -}}
  {{- if .Values.postgresql.enabled -}}
    {{- include "postgresql.v1.secretName" .Subcharts.postgresql -}}
  {{- else if .Values.externalDatabase.existingSecretName -}}
    {{- .Values.externalDatabase.existingSecretName }}
  {{- else -}}
    {{- .Values.existingSecretName | default (include "netbox.postgresql.fullname" .) }}
  {{- end -}}
{{- end -}}

{{/*
Name of the key in Secret that contains the PostgreSQL password
*/}}
{{- define "netbox.postgresql.secretKey" -}}
{{- if .Values.postgresql.enabled -}}
    {{- include "postgresql.v1.userPasswordKey" .Subcharts.postgresql -}}
{{- else if .Values.externalDatabase.existingSecretName -}}
    {{- .Values.externalDatabase.existingSecretKey -}}
{{- else -}}
    {{- print "db_password" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis secret name
*/}}
{{- define "netbox.tasksRedis.secretName" -}}
{{- if .Values.redis.enabled -}}
    {{- if .Values.global.redis -}}
        {{- if .Values.global.redis.auth -}}
            {{- if .Values.global.redis.auth.existingSecret -}}
                {{- tpl .Values.global.redis.auth.existingSecret $ -}}
            {{- else -}}
                {{- default (include "netbox.redis.fullname" .) (tpl .Values.redis.auth.existingSecret $) -}}
            {{- end -}}
        {{- else -}}
            {{- default (include "netbox.redis.fullname" .) (tpl .Values.redis.auth.existingSecret $) -}}
        {{- end -}}
    {{- else -}}
        {{- default (include "netbox.redis.fullname" .) (tpl .Values.redis.auth.existingSecret $) -}}
    {{- end -}}
{{- else -}}
    {{- default (printf "%s-external-redis" .Release.Name) (tpl .Values.tasksRedis.existingSecretName $) -}}
{{- end -}}
{{- end -}}

{{/*
Return the task Redis hostname
*/}}
{{- define "netbox.tasksRedis.host" -}}
{{- if eq .Values.redis.architecture "replication" }}
  {{- ternary (include "netbox.redis.fullname" .) (tpl .Values.tasksRedis.host $) .Values.redis.enabled -}}-master
{{- else -}}
  {{- ternary (include "netbox.redis.fullname" .) (tpl .Values.tasksRedis.host $) .Values.redis.enabled -}}-master
{{- end -}}
{{- end -}}

{{/*
Return the task Redis port
*/}}
{{- define "netbox.tasksRedis.port" -}}
  {{- ternary 6379 .Values.tasksRedis.port .Values.redis.enabled | int -}}
{{- end -}}

{{/*
Add environment variables to configure tasks Redis values
*/}}
{{- define "netbox.tasksRedis.secretPasswordKey" -}}
{{- if .Values.redis.enabled -}}
    {{- print "redis-password" -}}
{{- else -}}
    {{- if .Values.tasksRedis.existingSecretName -}}
        {{- if .Values.tasksRedis.existingSecretPasswordKey -}}
            {{- printf "%s" .Values.tasksRedis.existingSecretPasswordKey -}}
        {{- else -}}
            {{- print "redis-tasks-password" -}}
        {{- end -}}
    {{- else -}}
        {{- print "redis-tasks-password" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Name of the Secret that contains the Redis tasks password
*/}}
{{- define "netbox.tasksRedis.secret" -}}
  {{- if .Values.redis.enabled -}}
    {{- include "redis.secretName" .Subcharts.redis -}}
  {{- else if .Values.tasksRedis.existingSecretName -}}
    {{- .Values.tasksRedis.existingSecretName }}
  {{- else -}}
    {{- .Values.existingSecretName | default (include "netbox.fullname" .) }}
  {{- end -}}
{{- end -}}

{{/*
Name of the key in Secret that contains the Redis tasks password
*/}}
{{- define "netbox.tasksRedis.secretKey" -}}
  {{- if .Values.redis.enabled -}}
    {{- include "redis.secretPasswordKey" .Subcharts.redis -}}
  {{- else if .Values.tasksRedis.existingSecretName -}}
    {{ .Values.tasksRedis.existingSecretKey }}
  {{- else -}}
    {{- print "redis_tasks_password" -}}
  {{- end -}}
{{- end -}}

{{/*
Return the Redis secret name
*/}}
{{- define "netbox.cachingRedis.secretName" -}}
{{- if .Values.redis.enabled -}}
    {{- if .Values.global.redis -}}
        {{- if .Values.global.redis.auth -}}
            {{- if .Values.global.redis.auth.existingSecret -}}
                {{- tpl .Values.global.redis.auth.existingSecret $ -}}
            {{- else -}}
                {{- default (include "netbox.redis.fullname" .) (tpl .Values.redis.auth.existingSecret $) -}}
            {{- end -}}
        {{- else -}}
            {{- default (include "netbox.redis.fullname" .) (tpl .Values.redis.auth.existingSecret $) -}}
        {{- end -}}
    {{- else -}}
        {{- default (include "netbox.redis.fullname" .) (tpl .Values.redis.auth.existingSecret $) -}}
    {{- end -}}
{{- else -}}
    {{- default (printf "%s-external-redis" .Release.Name) (tpl .Values.cachingRedis.existingSecretName $) -}}
{{- end -}}
{{- end -}}

{{/*
Return the cache Redis hostname
*/}}
{{- define "netbox.cachingRedis.host" -}}
{{- if eq .Values.redis.architecture "replication" }}
  {{- ternary (include "netbox.redis.fullname" .) (tpl .Values.cachingRedis.host $) .Values.redis.enabled -}}-master
{{- else -}}
  {{- ternary (include "netbox.redis.fullname" .) (tpl .Values.cachingRedis.host $) .Values.redis.enabled -}}-master
{{- end -}}
{{- end -}}

{{/*
Return the cache Redis port
*/}}
{{- define "netbox.cachingRedis.port" -}}
  {{- ternary 6379 .Values.cachingRedis.port .Values.redis.enabled | int -}}
{{- end -}}

{{/*
Add environment variables to configure tasks Redis values
*/}}
{{- define "netbox.cachingRedis.secretPasswordKey" -}}
{{- if .Values.redis.enabled -}}
    {{- print "redis-password" -}}
{{- else -}}
    {{- if .Values.cachingRedis.existingSecretName -}}
        {{- if .Values.cachingRedis.existingSecretPasswordKey -}}
            {{- printf "%s" .Values.cachingRedis.existingSecretPasswordKey -}}
        {{- else -}}
            {{- print "redis-cache-password" -}}
        {{- end -}}
    {{- else -}}
        {{- print "redis-cache-password" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Name of the Secret that contains the Redis cache password
*/}}
{{- define "netbox.cachingRedis.secret" -}}
{{- if .Values.redis.enabled -}}
    {{- include "redis.secretName" .Subcharts.redis -}}
{{- else if .Values.cachingRedis.existingSecretName -}}
    {{- .Values.cachingRedis.existingSecretName }}
{{- else -}}
    {{- .Values.existingSecretName | default (include "netbox.fullname" .) }}
{{- end -}}
{{- end -}}

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
{{- end -}}

{{/*
Volumes that need to be mounted for .Values.extraConfig entries
*/}}
{{- define "netbox.extraConfig.volumes" -}}
{{- range $index, $config := .Values.extraConfig -}}
- name: extra-config-{{ $index }}
  {{- if $config.values -}}
  configMap:
    name: {{ include "netbox.fullname" $ }}
    items:
    - key: extra-{{ $index }}.yaml
      path: extra-{{ $index }}.yaml
  {{- else if $config.configMap -}}
  configMap:
    {{- toYaml $config.configMap | nindent 4 }}
  {{- else if $config.secret -}}
  secret:
    {{- toYaml $config.secret | nindent 4 }}
  {{- end -}}
{{ end -}}
{{- end -}}

{{/*
Volume mounts for .Values.extraConfig entries
*/}}
{{- define "netbox.extraConfig.volumeMounts" -}}
{{- range $index, $config := .Values.extraConfig -}}
- name: extra-config-{{ $index }}
  mountPath: /run/config/extra/{{ $index }}
  readOnly: true
{{ end -}}
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
Return the Database port
*/}}
{{- define "netbox.databasePort" -}}
  {{- ternary 5432 .Values.externalDatabase.port .Values.postgresql.enabled | int -}}
{{- end -}}

{{/*
Return the Database database name
*/}}
{{- define "netbox.databaseName" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if .Values.global.postgresql -}}
        {{- if .Values.global.postgresql.auth }}
            {{- coalesce .Values.global.postgresql.auth.database .Values.postgresql.auth.database | quote -}}
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
    {{- default (include "netbox.postgresql.fullname" .) (tpl .Values.postgresql.auth.existingSecret $) -}}
{{- else if .Values.existingSecretName -}}
    {{- printf "%s" .Values.existingSecretName -}}
{{- else -}}
    {{- default (printf "%s-externaldb" .Release.Name) (tpl .Values.externalDatabase.existingSecretName $) -}}
{{- end -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "netbox.databaseSecretPasswordKey" -}}
{{- if .Values.postgresql.enabled -}}
    {{- printf "%s" "password" -}}
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

{{/*
Return the Redis secret name
*/}}
{{- define "netbox.redis.secretName" -}}
{{- if .Values.redis.enabled -}}
    {{- if .Values.redis.auth.existingSecret -}}
        {{- printf "%s" .Values.redis.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" (include "netbox.redis.fullname" .) }}
    {{- end -}}
{{- else if .Values.externalRedis.existingSecretName -}}
    {{- printf "%s" .Values.externalRedis.existingSecretName -}}
{{- else if .Values.existingSecretName -}}
    {{- printf "%s" .Values.existingSecretName -}}
{{- else -}}
    {{- printf "%s" (include "netbox.redis.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis secret key
*/}}
{{- define "netbox.redis.secretPasswordKey" -}}
{{- if .Values.redis.enabled -}}
    {{- printf "%s" "redis-password" -}}
{{- else -}}
    {{- if .Values.externalRedis.existingSecretName -}}
        {{- if .Values.externalRedis.existingSecretPasswordKey -}}
            {{- printf "%s" .Values.externalRedis.existingSecretPasswordKey -}}
        {{- else -}}
            {{- printf "%s" "redis-password" -}}
        {{- end -}}
    {{- else -}}
        {{- printf "%s" "redis-password" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return whether Redis uses password authentication or not
*/}}
{{- define "netbox.redis.auth.enabled" -}}
{{- if or (and .Values.redis.enabled .Values.redis.auth.enabled) (and (not .Values.redis.enabled) (or .Values.externalRedis.password .Values.externalRedis.existingSecretName)) -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis hostname
*/}}
{{- define "netbox.redisHost" -}}
{{- if .Values.redis.enabled -}}
    {{- printf "%s-master" (include "netbox.redis.fullname" .) -}}
{{- else if .Values.externalRedis.host -}}
    {{- .Values.externalRedis.host -}}
{{- else -}}
    {{- required "If the redis dependency is disabled you need to add an external redis host" .Values.externalRedis.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis port
*/}}
{{- define "netbox.redisPort" -}}
{{- if .Values.redis.enabled -}}
    {{- .Values.redis.master.service.ports.redis -}}
{{- else if .Values.externalRedis.port -}}
    {{- .Values.externalRedis.port -}}
{{- else -}}
    {{ 6379 | int }}
{{- end -}}
{{- end -}}

{{/*
Return the secret containing the Netbox superuser password
*/}}
{{- define "netbox.secretName" -}}
{{- $secretName := .Values.superuser.existingSecretName -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret key that contains the Netbox superuser password
*/}}
{{- define "netbox.secretKey" -}}
{{- $secretName := .Values.superuser.existingSecretName -}}
{{- if and $secretName .Values.superuser.existingSecretPasswordKey -}}
    {{- printf "%s" .Values.superuser.existingSecretPasswordKey -}}
{{- else -}}
    {{- print "superuser_password" -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret name containing the Netbox superuser password
*/}}
{{- define "netbox.superuser.secretName" -}}
{{- if .Values.superuser.existingSecretName -}}
    {{- printf "%s" .Values.superuser.existingSecretName -}}
{{- else -}}
    {{- .Values.existingSecretName | default (include "netbox.fullname" .) }}
{{- end -}}
{{- end -}}

{{/*
Return the secret key that contains the Netbox superuser password
*/}}
{{- define "netbox.superuser.secretPasswordKey" -}}
{{- if .Values.superuser.existingSecretName -}}
    {{- if .Values.superuser.existingSecretPasswordKey -}}
        {{- printf "%s" .Values.superuser.existingSecretPasswordKey -}}
    {{- else -}}
        {{- printf "%s" "superuser-password" -}}
    {{- end -}}
{{- else if .Values.existingSecretName -}}
    {{- printf "%s" "superuser-password" -}}
{{- else -}}
    {{- printf "%s" "superuser_password" -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret key that contains the Netbox superuser API token
*/}}
{{- define "netbox.superuser.secretApiTokenKey" -}}
{{- if .Values.superuser.existingSecretName -}}
    {{- if .Values.superuser.existingSecretApiTokenKey -}}
        {{- printf "%s" .Values.superuser.existingSecretApiTokenKey -}}
    {{- else -}}
        {{- printf "%s" "superuser-api-token" -}}
    {{- end -}}
{{- else if .Values.existingSecretName -}}
    {{- printf "%s" "superuser-api-token" -}}
{{- else -}}
    {{- printf "%s" "superuser_api_token" -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret name containing email server
*/}}
{{- define "netbox.email.secretName" -}}
{{- if .Values.email.existingSecretName -}}
    {{- printf "%s" .Values.email.existingSecretName -}}
{{- else -}}
    {{- .Values.existingSecretName | default (include "netbox.fullname" .) }}
{{- end -}}

{{/*
Return the secret key that contains the Netbox email password
*/}}
{{- define "netbox.email.secretPasswordKey" -}}
{{- if .Values.email.existingSecretName -}}
    {{- if .Values.email.existingSecretPasswordKey -}}
        {{- printf "%s" .Values.email.existingSecretPasswordKey -}}
    {{- else -}}
        {{- printf "%s" "email-password" -}}
    {{- end -}}
{{- else if .Values.existingSecretName -}}
    {{- printf "%s" "email-password" -}}
{{- else -}}
    {{- printf "%s" "email_password" -}}
{{- end -}}
{{- end -}}

{{/* Validate values of Netbox - database */}}
{{- define "netbox.validateValues.database" -}}
{{- if and (not .Values.postgresql.enabled) (not .Values.externalDatabase.host) (and (not .Values.externalDatabase.password) (not .Values.externalDatabase.existingSecretName)) -}}
netbox: database
    You disabled the PostgreSQL sub-chart but did not specify an external PostgreSQL host.
    Either deploy the PostgreSQL sub-chart (--set postgresql.enabled=true),
    or set a value for the external database host (--set externalDatabase.host=FOO)
    and set a value for the external database password (--set externalDatabase.password=BAR)
    or existing secret (--set externalDatabase.existingSecretName=BAR).
{{- end -}}
{{- end -}}

{{/* Validate values of Netbox - TLS enabled */}}
{{- define "netbox.validateValues.tls" -}}
{{- if and .Values.tls.enabled (not .Values.tls.autoGenerated) (not .Values.tls.existingSecretName) }}
netbox: tls.enabled
    In order to enable TLS, you also need to provide
    an existing secret containing the Keystore and Truststore or
    enable auto-generated certificates.
{{- end -}}
{{- end -}}