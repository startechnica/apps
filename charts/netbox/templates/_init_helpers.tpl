{{/*
Returns the init container that will wait for redis connections
Usage:
{{ include "netbox.redisWait.container" ( dict "securityContext" .Values.path.to.the.component.securityContext "context" $ ) }}
*/}}
{{- define "netbox.redisWait.container" -}}
{{- if .context.Values.redisWait.enabled }}
- name: wait-for-redis
  image: {{ include "netbox.redisWait.image" .context | quote }}
  imagePullPolicy: {{ .context.Values.redisWait.image.pullPolicy | quote }}
  {{- if .securityContext.enabled }}
  securityContext: {{- omit .securityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .context.Values.redisWait.resources }}
  resources: {{- toYaml .context.Values.redisWait.resources | nindent 4 }}
  {{- end }}
  {{- if .context.Values.redisWait.command }}
  command: {{- include "common.tplvalues.render" (dict "value" .context.Values.redisWait.command "context" .context) | nindent 4 }}
  {{- else }}
  command:
    - /bin/bash
  {{- end }}
  {{- if .context.Values.redisWait.args }}
  args: {{- include "common.tplvalues.render" (dict "value" .context.Values.redisWait.args "context" .context) | nindent 4 }}
  {{- else }}
  args:
    - -ec
    - |
        #!/bin/bash

        set -o errexit
        set -o nounset
        set -o pipefail

        . /opt/bitnami/scripts/libos.sh
        . /opt/bitnami/scripts/liblog.sh

        check_redis_connection() {
            local result="$(redis-cli -h {{ include "netbox.tasksRedis.host" .context }} -p {{ include "netbox.tasksRedis.port" .context }} {{ .context.Values.redisWait.extraArgs }} PING)"
            if [[ "$result" != "PONG" ]]; then
              false
            fi
        }

        info "Checking redis connection..."
        if ! retry_while "check_redis_connection"; then
            error "Could not connect to the task Redis server"
            return 1
        else
            info "Connected to the task Redis instance"
        fi
  {{- end }}
  {{- if include "netbox.redis.auth.enabled" .context }}
  env:
    - name: REDISCLI_AUTH
      valueFrom:
        secretKeyRef:
          name: {{ include "netbox.redis.secretName" .context }}
          key: {{ include "netbox.redis.secretPasswordKey" .context }}
  {{- end }}
{{- end }}
{{- end -}}