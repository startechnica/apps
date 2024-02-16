{{/* vim: set filetype=mustache: */}}
{{/*
Return the proper git image name
*/}}
{{- define "netbox.git.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.git.image "global" .Values.global) -}}
{{- end -}}

{{/*
Returns the name that will identify the repository internally and it will be used to create folders or
volume names
*/}}
{{- define "netbox.git.repository.name" -}}
  {{- $defaultName := regexFind "/.*$" .repository | replace "//" "" | replace "/" "-" | replace "." "-" -}}
  {{- .name | default $defaultName | kebabcase -}}
{{- end -}}

{{/*
Returns the volume mounts that will be used by git containers (clone and sync)
*/}}
{{- define "netbox.git.volumeMounts" -}}
{{- if .Values.git.reports.enabled }}
- name: git-cloned-reports
  mountPath: /reports
{{- end }}
{{- if .Values.git.scripts.enabled }}
- name: git-cloned-scripts
  mountPath: /scripts
{{- end }}
{{- end -}}

{{/*
Returns the volume mounts that will be used by the main container
*/}}
{{- define "netbox.git.maincontainer.volumeMounts" -}}
{{- if .Values.git.reports.enabled }}
  {{- range .Values.git.reports.repositories }}
- name: git-cloned-reports
  mountPath: {{ printf "%s/git_%s" $.Values.reportsPersistence.path (include "netbox.git.repository.name" .) }}
  {{- if .path }}
  subPath: {{ include "netbox.git.repository.name" . }}/{{ .path }}
  {{- else }}
  subPath: {{ include "netbox.git.repository.name" . }}
  {{- end }}
  {{- end }}
{{- end }}
{{- if .Values.git.scripts.enabled }}
  {{- range .Values.git.scripts.repositories }}
- name: git-cloned-scripts
  mountPath: {{ printf "%s/git_%s" $.Values.scriptsPersistence.path (include "netbox.git.repository.name" .) }}
  {{- if .path }}
  subPath: {{ include "netbox.git.repository.name" . }}/{{ .path }}
  {{- else }}
  subPath: {{ include "netbox.git.repository.name" . }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Returns the volumes that will be attached to the workload resources (deployment, statefulset, etc)
*/}}
{{- define "netbox.git.volumes" -}}
{{- if .Values.git.reports.enabled }}
- name: git-cloned-reports
  emptyDir: {}
{{- end }}
{{- if .Values.git.scripts.enabled }}
- name: git-cloned-scripts
  emptyDir: {}
{{- end }}
{{- end -}}

{{/*
Returns the init container that will clone repositories files from a given list of git repositories
Usage:
{{ include "netbox.git.containers.clone" ( dict "securityContext" .Values.path.to.the.component.securityContext "context" $ ) }}
*/}}
{{- define "netbox.git.containers.clone" -}}
{{- if or .context.Values.git.reports.enabled .context.Values.git.scripts.enabled }}
- name: clone-repositories
  image: {{ include "netbox.git.image" .context | quote }}
  imagePullPolicy: {{ .context.Values.git.image.pullPolicy | quote }}
{{- if .securityContext.enabled }}
  securityContext: {{- omit .securityContext "enabled" | toYaml | nindent 4 }}
{{- end }}
{{- if .context.Values.git.clone.resources }}
  resources: {{- toYaml .context.Values.git.clone.resources | nindent 4 }}
  {{- else if ne .context.Values.git.clone.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .context.Values.git.clone.resourcesPreset) | nindent 4 }}
{{- end }}
{{- if .context.Values.git.clone.command }}
  command: {{- include "common.tplvalues.render" (dict "value" .context.Values.git.clone.command "context" .context) | nindent 4 }}
{{- else }}
  command:
    - /bin/bash
{{- end }}
{{- if .context.Values.git.clone.args }}
  args: {{- include "common.tplvalues.render" (dict "value" .context.Values.git.clone.args "context" .context) | nindent 4 }}
{{- else }}
  args:
    - -ec
    - |
      . /opt/bitnami/scripts/libfs.sh
      [[ -f "/opt/bitnami/scripts/git/entrypoint.sh" ]] && . /opt/bitnami/scripts/git/entrypoint.sh
    {{- if .context.Values.git.reports.enabled }}
      {{- range .context.Values.git.reports.repositories }}
      is_dir_empty "/reports/{{ include "netbox.git.repository.name" . }}" && git clone {{ .repository }} --branch {{ .branch }} /reports/{{ include "netbox.git.repository.name" . }}
      {{- end }}
    {{- end }}
    {{- if .context.Values.git.scripts.enabled }}
      {{- range .context.Values.git.scripts.repositories }}
      is_dir_empty "/scripts/{{ include "netbox.git.repository.name" . }}" && git clone {{ .repository }} --branch {{ .branch }} /scripts/{{ include "netbox.git.repository.name" . }}
      {{- end }}
    {{- end }}
{{- end }}
  volumeMounts:
    {{- include "netbox.git.volumeMounts" .context | trim | nindent 4 }}
  {{- if .context.Values.git.clone.extraVolumeMounts }}
    {{- include "common.tplvalues.render" (dict "value" .context.Values.git.clone.extraVolumeMounts "context" .context) | nindent 4 }}
  {{- end }}
{{- if .context.Values.git.clone.extraEnvVars }}
  env: {{- include "common.tplvalues.render" (dict "value" .context.Values.git.clone.extraEnvVars "context" .context) | nindent 4 }}
{{- end }}
{{- if or .context.Values.git.clone.extraEnvVarsCM .context.Values.git.clone.extraEnvVarsSecret }}
  envFrom:
    {{- if .context.Values.git.clone.extraEnvVarsCM }}
    - configMapRef:
        name: {{ .context.Values.git.clone.extraEnvVarsCM }}
    {{- end }}
    {{- if .context.Values.git.clone.extraEnvVarsSecret }}
    - secretRef:
        name: {{ .context.Values.git.clone.extraEnvVarsSecret }}
    {{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Returns the container that will pull and sync repositories files from a given list of git repositories
Usage:
{{ include "netbox.git.containers.sync" ( dict "securityContext" .Values.path.to.the.component.securityContext "context" $ ) }}
*/}}
{{- define "netbox.git.containers.sync" -}}
{{- if or .context.Values.git.reports.enabled .context.Values.git.scripts.enabled }}
- name: sync-repositories
  image: {{ include "netbox.git.image" .context | quote }}
  imagePullPolicy: {{ .context.Values.git.image.pullPolicy | quote }}
  {{- if .securityContext.enabled }}
  securityContext: {{- omit .securityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .context.Values.git.sync.resources }}
  resources: {{- toYaml .context.Values.git.sync.resources | nindent 4 }}
  {{- end }}
  {{- if .context.Values.git.sync.command }}
  command: {{- include "common.tplvalues.render" (dict "value" .context.Values.git.sync.command "context" .context) | nindent 4 }}
  {{- else }}
  command:
    - /bin/bash
  {{- end }}
  {{- if .context.Values.git.sync.args }}
  args: {{- include "common.tplvalues.render" (dict "value" .context.Values.git.sync.args "context" .context) | nindent 4 }}
  {{- else }}
  args:
    - -ec
    - |
      [[ -f "/opt/bitnami/scripts/git/entrypoint.sh" ]] && . /opt/bitnami/scripts/git/entrypoint.sh
      while true; do
      {{- if .context.Values.git.reports.enabled }}
        {{- range .context.Values.git.reports.repositories }}
          cd /reports/{{ include "netbox.git.repository.name" . }} && git pull origin {{ .branch }} || true
        {{- end }}
      {{- end }}
      {{- if .context.Values.git.scripts.enabled }}
        {{- range .context.Values.git.scripts.repositories }}
          cd /scripts/{{ include "netbox.git.repository.name" . }} && git pull origin {{ .branch }} || true
        {{- end }}
      {{- end }}
          sleep {{ default "60" .context.Values.git.sync.interval }}
      done
  {{- end }}
  volumeMounts:
    {{- include "netbox.git.volumeMounts" .context | trim | nindent 4 }}
  {{- if .context.Values.git.sync.extraVolumeMounts }}
    {{- include "common.tplvalues.render" (dict "value" .context.Values.git.sync.extraVolumeMounts "context" .context) | nindent 4 }}
  {{- end }}
{{- if .context.Values.git.sync.extraEnvVars }}
  env: {{- include "common.tplvalues.render" (dict "value" .context.Values.git.sync.extraEnvVars "context" .context) | nindent 4 }}
{{- end }}
{{- if or .context.Values.git.sync.extraEnvVarsCM .context.Values.git.sync.extraEnvVarsSecret }}
  envFrom:
    {{- if .context.Values.git.sync.extraEnvVarsCM }}
    - configMapRef:
        name: {{ .context.Values.git.sync.extraEnvVarsCM }}
    {{- end }}
    {{- if .context.Values.git.sync.extraEnvVarsSecret }}
    - secretRef:
        name: {{ .context.Values.git.sync.extraEnvVarsSecret }}
    {{- end }}
{{- end }}
{{- end }}
{{- end -}}