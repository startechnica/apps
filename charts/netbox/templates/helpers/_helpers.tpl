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
{{- printf "%s-%s" (include "st-common.names.fullname" .) "worker" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper Netbox housekeeping fullname
*/}}
{{- define "netbox.housekeeping.fullname" -}}
{{- printf "%s-%s" (include "st-common.names.fullname" .) "housekeeping" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "netbox.postgresql.fullname" -}}
{{ include "st-common.names.dependency.fullname" (dict "chartName" "postgresql" "chartValues" .Values.postgresql "context" $) }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "netbox.redis.fullname" -}}
{{ include "st-common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "netbox.imagePullSecrets" -}}
{{- include "st-common.images.renderPullSecrets" (dict "images" (list .Values.image .Values.worker.image .Values.housekeeping.image .Values.initDirs.image .Values.volumePermissions.image) "context" $) -}}
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
Kubernetes standard labels
{{ include "st-common.labels.standard" (dict "customLabels" .Values.commonLabels "context" $) -}}
*/}}
{{- define "netbox.labels.standard" -}}
{{- if and (hasKey . "customLabels") (hasKey . "context") -}}
{{- $default := dict "app.kubernetes.io/name" (include "st-common.names.name" .context) "helm.sh/chart" (include "st-common.names.chart" .context) "app.kubernetes.io/instance" .context.Release.Name "app.kubernetes.io/managed-by" .context.Release.Service -}}
{{- with .context.Chart.AppVersion -}}
{{- $_ := set $default "app.kubernetes.io/version" . -}}
{{- end -}}
{{ template "st-common.tplvalues.merge" (dict "values" (list .customLabels $default) "context" .context) }}
{{- else -}}
app.kubernetes.io/name: {{ include "st-common.names.name" . }}
helm.sh/chart: {{ include "st-common.names.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end -}}
{{- end -}}
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
Return the configuration configmap name
*/}}
{{- define "netbox.configmapName" -}}
{{- if .Values.existingConfigmap -}}
    {{- printf "%s" (tpl .Values.existingConfigmap $) -}}
{{- else -}}
    {{- printf "%s" (include "netbox.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a configmap object should be created
*/}}
{{- define "netbox.createConfigmap" -}}
{{- if empty .Values.existingConfigmap }}
    {{- true -}}
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
Returns the available value for certain key in an existing secret (if it exists), otherwise generate random value.
*/}}
{{- define "netbox.getValueFromSecret" }}
    {{- $len := (default 16 .Length) | int -}}
    {{- $obj := (lookup "v1" "Secret" .Namespace .Name).data -}}
    {{- if $obj }}
        {{- index $obj .Key | b64dec -}}
    {{- else -}}
        {{- randAlphaNum $len -}}
    {{- end -}}
{{- end }}

{{/*
Return the Netbox secret name 
*/}}
{{- define "netbox.secretName" -}}
    {{ default (include "netbox.fullname" .) .Values.existingSecretName }}
{{- end -}}

{{/*
Volumes that need to be mounted for .Values.extraConfig entries
*/}}
{{- define "netbox.extraConfig.volumes" -}}
{{- range $index, $config := .Values.extraConfig -}}
- name: extra-config-{{ $index }}
  {{- if $config.values }}
  configMap:
    name: {{ printf "%s" (include "netbox.fullname" $) }}
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
    {{- printf "%s-%s" (include "netbox.fullname" .) "external-db" -}}
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

{{/*
Return the Redis secret name.
Fixes #61: the previous fallback was `default <fullname>-external-redis .Values.existingSecretName`,
which conflated the top-level Netbox secret with the external-redis secret.
With `redis.enabled=false` and a user-set top-level `existingSecretName`, the
mount referenced a secret that lacked the redis-cache/tasks keys.
*/}}
{{- define "netbox.redis.secretName" -}}
{{- if .Values.redis.enabled -}}
    {{- include "redis.secretName" .Subcharts.redis -}}
{{- else if .Values.externalRedis.existingSecretName -}}
    {{- printf "%s" .Values.externalRedis.existingSecretName -}}
{{- else -}}
    {{- printf "%s-%s" (include "netbox.fullname" .) "external-redis" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis secret key
*/}}
{{- define "netbox.cachingRedis.secretPasswordKey" -}}
{{- if .Values.redis.enabled -}}
    {{- include "redis.secretPasswordKey" .Subcharts.redis -}}
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

{{- define "netbox.tasksRedis.secretPasswordKey" -}}
{{- if .Values.redis.enabled -}}
    {{- include "redis.secretPasswordKey" .Subcharts.redis -}}
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

{{- define "netbox.redis.secretPasswordKey" -}}
{{- if .Values.redis.enabled -}}
    {{- include "redis.secretPasswordKey" .Subcharts.redis -}}
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
Return Redis password
*/}}
{{- define "netbox.cachingRedis.password" -}}
{{- if .Values.redis.enabled -}}
    {{- include "redis.password" .Subcharts.redis -}}
{{- else if .Values.cachingRedis.password -}}
    {{ include "st-common.secrets.lookup" (dict "secret" (include "netbox.redis.secretName" .) "key" (include "netbox.cachingRedis.secretPasswordKey" .) "defaultValue" .Values.cachingRedis.password "context" $) }}
{{- else -}}
    {{ include "st-common.secrets.lookup" (dict "secret" (include "netbox.redis.secretName" .) "key" (include "netbox.redis.secretPasswordKey" .) "defaultValue" .Values.externalRedis.password "context" $) }}
{{- end -}}
{{- end -}}

{{- define "netbox.tasksRedis.password" -}}
{{- if .Values.redis.enabled -}}
    {{- include "redis.password" .Subcharts.redis -}}
{{- else if .Values.tasksRedis.password -}}
    {{ include "st-common.secrets.lookup" (dict "secret" (include "netbox.redis.secretName" .) "key" (include "netbox.tasksRedis.secretPasswordKey" .) "defaultValue" .Values.tasksRedis.password "context" $) }}
{{- else -}}
    {{ include "st-common.secrets.lookup" (dict "secret" (include "netbox.redis.secretName" .) "key" (include "netbox.redis.secretPasswordKey" .) "defaultValue" .Values.externalRedis.password "context" $) }}
{{- end -}}
{{- end -}}

{{- define "netbox.redis.password" -}}
{{- if .Values.redis.enabled -}}
    {{ include "redis.password" .Subcharts.redis }}
{{- else -}}
    {{ include "st-common.secrets.lookup" (dict "secret" (include "netbox.redis.secretName" .) "key" (include "netbox.redis.secretPasswordKey" .) "defaultValue" .Values.externalRedis.password "context" $) }}
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
{{- define "netbox.cachingRedis.host" -}}
{{- if .Values.redis.enabled -}}
    {{- if or (eq .Values.redis.architecture "replication") (eq .Values.redis.architecture "standalone") -}}
        {{- printf "%s-%s" (include "netbox.redis.fullname" .) "master" -}}
    {{- end -}}
{{- else if .Values.cachingRedis.host -}}
    {{- print .Values.cachingRedis.host -}}
{{- else -}}
    {{- default (include "netbox.redis.fullname" .) .Values.externalRedis.host -}}
{{- end -}}
{{- end -}}

{{- define "netbox.tasksRedis.host" -}}
{{- if .Values.redis.enabled -}}
    {{- if or (eq .Values.redis.architecture "replication") (eq .Values.redis.architecture "standalone") -}}
        {{- printf "%s-%s" (include "netbox.redis.fullname" .) "master" -}}
    {{- end -}}
{{- else if .Values.tasksRedis.host -}}
    {{- print .Values.tasksRedis.host -}}
{{- else -}}
    {{- default (include "netbox.redis.fullname" .) .Values.externalRedis.host -}}
{{- end -}}
{{- end -}}

{{- define "netbox.redis.host" -}}
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
{{- define "netbox.tasksRedis.port" -}}
    {{- ternary 6379 .Values.tasksRedis.port .Values.redis.enabled | int -}}
{{- end -}}

{{- define "netbox.cachingRedis.port" -}}
  {{- ternary 6379 .Values.cachingRedis.port .Values.redis.enabled | int -}}
{{- end -}}

{{- define "netbox.redis.port" -}}
{{- if .Values.redis.enabled -}}
    {{- .Values.redis.master.service.ports.redis -}}
{{- else if .Values.externalRedis.port -}}
    {{- .Values.externalRedis.port -}}
{{- else -}}
    {{ 6379 | int }}
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
    {{- default (include "netbox.fullname" .) .Values.existingSecretName }}
{{- end -}}
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
{{- else -}}
    {{- if .Values.existingSecretName -}}
        {{- printf "%s" "email-password" -}}
    {{- else -}}
        {{- printf "%s" "email_password" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret key that contains the Netbox Secret Key
*/}}
{{- define "netbox.secretSecretKeyKey" -}}
{{- if .Values.existingSecretName -}}
    {{- printf "%s" "secret-key" -}}
{{- else -}}
    {{- printf "%s" "secret_key" -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret name containing remote auth
*/}}
{{- define "netbox.remoteAuth.secretName" -}}
{{- if .Values.remoteAuth.existingSecretName -}}
    {{- printf "%s" .Values.remoteAuth.existingSecretName -}}
{{- else -}}
    {{ include "netbox.secretName" . }}
{{- end -}}
{{- end -}}

{{- define "netbox.remoteAuth.ldap.secretBindPasswordKey" -}}
{{- if .Values.remoteAuth.ldap.existingSecretBindPasswordKey -}}
    {{- printf "%s" .Values.remoteAuth.ldap.existingSecretBindPasswordKey -}}
{{- else -}}
  {{- if .Values.remoteAuth.existingSecretName -}}
      {{- printf "%s" "ldap-bind-password" -}}
  {{- else -}}
    {{- print "ldap-bind-password" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS secret object should be created
*/}}
{{- define "netbox.tls.isCreateSecret" -}}
{{- if and .Values.tls.enabled .Values.tls.autoGenerated (not .Values.tls.existingSecretName) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Resolve whether the chart should render a cert-manager Certificate. Returns
string "true" when:
  - TLS is wanted (`tls.enabled` OR `ingress.tls` non-empty),
  - cert-manager API is detected on the cluster, AND
  - the user has NOT pinned an external secret via `tls.certificatesSecret`.

The legacy flags `tls.certManager.create` and `tls.autoGenerator.certManager.enabled`
are no longer consulted (cert-manager is auto-detected). Slated for removal
in 6.0.0.
*/}}
{{- define "netbox.tls.certManager.create" -}}
{{- $wantsTls := or .Values.tls.enabled .Values.ingress.tls -}}
{{- $cmApi := include "st-common.capabilities.certmanagerCertificate.apiVersion" . -}}
{{- $hasCm := and $cmApi (ne $cmApi "false") (ne $cmApi "<no value>") -}}
{{- $externalSecret := .Values.tls.certificatesSecret -}}
{{- if and $wantsTls $hasCm (not $externalSecret) -}}
true
{{- end -}}
{{- end -}}

{{/*
Resolve cert-manager Issuer kind. Prefers `tls.certManager.issuerRef.kind`,
falls back to the deprecated `tls.autoGenerator.certManager.issuerKind`.
*/}}
{{- define "netbox.tls.certManager.issuerKind" -}}
{{- if and .Values.tls.certManager .Values.tls.certManager.issuerRef .Values.tls.certManager.issuerRef.kind -}}
{{- .Values.tls.certManager.issuerRef.kind -}}
{{- else if and .Values.tls.autoGenerator .Values.tls.autoGenerator.certManager .Values.tls.autoGenerator.certManager.issuerKind -}}
{{- .Values.tls.autoGenerator.certManager.issuerKind -}}
{{- else -}}
ClusterIssuer
{{- end -}}
{{- end -}}

{{/*
Resolve cert-manager Issuer name. Prefers `tls.certManager.issuerRef.name`,
falls back to the deprecated `tls.autoGenerator.certManager.issuerName`.
*/}}
{{- define "netbox.tls.certManager.issuerName" -}}
{{- if and .Values.tls.certManager .Values.tls.certManager.issuerRef .Values.tls.certManager.issuerRef.name -}}
{{- .Values.tls.certManager.issuerRef.name -}}
{{- else if and .Values.tls.autoGenerator .Values.tls.autoGenerator.certManager .Values.tls.autoGenerator.certManager.issuerName -}}
{{- .Values.tls.autoGenerator.certManager.issuerName -}}
{{- else -}}
selfsigned-issuer
{{- end -}}
{{- end -}}

{{/*
Resolve the chart-managed gateway-side TLS Secret name. Three-step chain
(first match wins):
  1. `gateway.tls.existingSecret` — BYO Secret managed outside the chart.
  2. `gateway.tls.secrets[0].name` — first user-supplied PEM Secret rendered
     by the chart.
  3. `<ingress.hostname>-tls` — backward-compatible default for self-signed
     and cert-manager paths (matches the historical Certificate.yaml secretName).
*/}}
{{- define "netbox.gateway.tlsSecretName" -}}
{{- if and .Values.gateway.tls .Values.gateway.tls.existingSecret -}}
{{- .Values.gateway.tls.existingSecret -}}
{{- else if and .Values.gateway.tls .Values.gateway.tls.secrets -}}
{{- (first .Values.gateway.tls.secrets).name -}}
{{- else -}}
{{- printf "%s-tls" .Values.ingress.hostname -}}
{{- end -}}
{{- end -}}

{{- define "netbox.media.pvcName" -}}
{{- if .Values.persistence.existingClaim -}}
    {{- .Values.persistence.existingClaim -}}
{{- else -}}
    {{ printf "%s-%s" (include "netbox.fullname" .) "media" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "netbox.reports.pvcName" -}}
{{- if .Values.reportsPersistence.existingClaim -}}
    {{- .Values.reportsPersistence.existingClaim -}}
{{- else -}}
    {{ printf "%s-%s" (include "netbox.fullname" .) "reports" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "netbox.scripts.pvcName" -}}
{{- if .Values.scriptsPersistence.existingClaim -}}
    {{- .Values.scriptsPersistence.existingClaim -}}
{{- else -}}
    {{ printf "%s-%s" (include "netbox.fullname" .) "scripts" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Returns the volumes that will be attached to the workload resources (deployment, statefulset, etc)
*/}}
{{- define "netbox.media.volumes" -}}
- name: media
  {{- if .Values.persistence.enabled }}
  persistentVolumeClaim:
    claimName: {{ include "netbox.media.pvcName" . }}
  {{- else }}
  emptyDir: {}
  {{- end }}
{{- end -}}

{{- define "netbox.reports.volumes" -}}
- name: reports
  {{- if .Values.reportsPersistence.enabled }}
  persistentVolumeClaim:
    claimName: {{ include "netbox.reports.pvcName" . }}
  {{- else }}
  emptyDir: {}
  {{- end }}
{{- end -}}

{{- define "netbox.scripts.volumes" -}}
- name: scripts
  {{- if .Values.scriptsPersistence.enabled }}
  persistentVolumeClaim:
    claimName: {{ include "netbox.scripts.pvcName" . }}
  {{- else }}
  emptyDir: {}
  {{- end }}
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

{{/* Validate values of Netbox - TLS enabled */}}
{{- define "netbox.validateValues.tls" -}}
{{- if and .Values.tls.enabled (not .Values.tls.autoGenerated) (not .Values.tls.existingSecretName) }}
netbox: tls.enabled
    In order to enable TLS, you also need to provide
    an existing secret containing the Keystore and Truststore or
    enable auto-generated certificates.
{{- end -}}
{{- end -}}