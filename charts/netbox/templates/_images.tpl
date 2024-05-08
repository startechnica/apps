{{/*
Return the proper Netbox image name
{{ include "netbox.images.image" ( dict "imageRoot" .Values.path.to.the.image "global" .Values.global ) }}
*/}}
{{- define "netbox.images.image" -}}
{{- $registryName := default .imageRoot.registry ((.global).imageRegistry) -}}
{{- $repositoryName := default .imageRoot.repository ((.global).imageRepository) -}}
{{- $separator := ":" -}}
{{- $termination := default .imageRoot.tag ((.global).imageTag) | toString -}}

{{- if or (.imageRoot.digest) ((.global).imageDigest) }}
    {{- $separator = "@" -}}
    {{- $termination = default .imageRoot.digest ((.global).imageDigest) | toString -}}
{{- end -}}
{{- if $registryName }}
    {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $termination -}}
{{- else -}}
    {{- printf "%s%s%s"  $repositoryName $separator $termination -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper image version (ingores image revision/prerelease info & fallbacks to chart appVersion)
{{ include "netbox.images.version" ( dict "imageRoot" .Values.path.to.the.image "global" .Values.global "chart" .Chart ) }}
*/}}
{{- define "netbox.images.version" -}}
{{- $imageTag := default .imageRoot.tag ((.global).imageTag) | toString -}}
{{/* regexp from https://github.com/Masterminds/semver/blob/23f51de38a0866c5ef0bfc42b3f735c73107b700/version.go#L41-L44 */}}
{{- if regexMatch `^([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-([0-9A-Za-z\-]+(\.[0-9A-Za-z\-]+)*))?(\+([0-9A-Za-z\-]+(\.[0-9A-Za-z\-]+)*))?$` $imageTag -}}
    {{- $version := semver $imageTag -}}
    {{- printf "%d.%d.%d" $version.Major $version.Minor $version.Patch -}}
{{- else -}}
    {{- print .chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Netbox image name
*/}}
{{- define "netbox.image" -}}
{{ include "netbox.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Netbox worker image name
*/}}
{{- define "netbox.worker.image" -}}
{{ include "netbox.images.image" (dict "imageRoot" .Values.worker.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Netbox housekeeping image name
*/}}
{{- define "netbox.housekeeping.image" -}}
{{ include "netbox.images.image" (dict "imageRoot" .Values.housekeeping.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Netbox init image name
*/}}
{{- define "netbox.init-dirs.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.initDirs.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Redis image name
*/}}
{{- define "netbox.redis.image" -}}
{{- if .Values.redis.enabled -}}
    {{- include "redis.image" .Subcharts.redis -}}
{{- else -}}
    {{ include "common.images.image" (dict "imageRoot" .Values.redis.image "global" .Values.global) }}
{{- end -}}
{{- end -}}

{{/*
Return the proper Redis wait image name
*/}}
{{- define "netbox.redisWait.image" -}}
{{- if .Values.redis.enabled -}}
    {{- include "redis.image" .Subcharts.redis -}}
{{- else -}}
    {{ include "common.images.image" ( dict "imageRoot" .Values.redisWait.image "global" .Values.global ) }}
{{- end -}}
{{- end -}}