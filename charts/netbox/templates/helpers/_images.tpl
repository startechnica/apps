{{- /*
(c) 2026 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper Netbox image name
{{ include "netbox.images.image" ( dict "imageRoot" .Values.path.to.the.image "global" .Values.global ) }}
*/}}
{{- define "netbox.images.image" -}}
{{/*
  Per-component (.imageRoot) takes precedence over global. Sprig's `default A B`
  returns B if B is non-empty, so the per-component value goes in the B slot.
  Fixes #83: previously `default .imageRoot.X .global.imageX` flipped this and
  silently ignored any per-component override.
*/}}
{{- $registryName := default ((.global).imageRegistry) .imageRoot.registry -}}
{{- $repositoryName := default ((.global).imageRepository) .imageRoot.repository -}}
{{- $separator := ":" -}}
{{- $termination := default ((.global).imageTag) .imageRoot.tag | toString -}}

{{- if or (.imageRoot.digest) ((.global).imageDigest) }}
    {{- $separator = "@" -}}
    {{- $termination = default ((.global).imageDigest) .imageRoot.digest | toString -}}
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
Return the proper Redis image name
*/}}
{{- define "netbox.redis.image" -}}
{{- if .Values.redis.enabled -}}
    {{- include "redis.image" .Subcharts.redis -}}
{{- else -}}
    {{ include "st-common.images.image" (dict "imageRoot" .Values.redis.image "global" .Values.global) }}
{{- end -}}
{{- end -}}

{{/*
Return the proper Redis wait image name
*/}}
{{- define "netbox.redisWait.image" -}}
{{- if .Values.redis.enabled -}}
    {{- include "redis.image" .Subcharts.redis -}}
{{- else -}}
    {{ include "st-common.images.image" ( dict "imageRoot" .Values.redisWait.image "global" .Values.global ) }}
{{- end -}}
{{- end -}}
