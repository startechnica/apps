{{- /*
(c) 2026 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Create a default fully qualified app name for the bundled Redis subchart.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "netbox.redis.fullname" -}}
{{ include "st-common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $) }}
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
    {{- printf "%s-%s" (include "st-common.names.fullname" .) "external-redis" -}}
{{- end -}}
{{- end -}}

{{/*
Return "true" if a redis Secret should be mounted into pods (subchart
or BYO existing-secret or chart-rendered Secret/external-redis.yaml).
Mirrors the Secret/external-redis.yaml render gate so we don't try to
mount a Secret that was suppressed for being empty.
*/}}
{{- define "netbox.redis.mountSecret" -}}
{{- if or .Values.redis.enabled .Values.externalRedis.existingSecretName .Values.tasksRedis.existingSecretName .Values.cachingRedis.existingSecretName .Values.externalRedis.host .Values.externalRedis.password .Values.tasksRedis.password .Values.cachingRedis.password -}}
true
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
