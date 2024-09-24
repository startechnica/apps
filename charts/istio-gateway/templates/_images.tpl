{{/*
Return the proper image name
{{ include "gateway.image" ( dict "imageRoot" .Values.path.to.the.image "global" .Values.global ) }}
*/}}
{{- define "gateway.image" -}}
{{- if .imageRoot }}
    {{- $registryName := .imageRoot.registry -}}
    {{- $repositoryName := .imageRoot.repository -}}
    {{- $separator := ":" -}}
    {{- $termination := .imageRoot.tag | toString -}}
    {{- if .global }}
        {{- if .global.imageRegistry }}
        {{- $registryName = .global.imageRegistry -}}
        {{- end -}}
    {{- end -}}
    {{- if .imageRoot .imageRoot.digest }}
        {{- $separator = "@" -}}
        {{- $termination = .imageRoot.digest | toString -}}
    {{- end -}}
    {{- if and .imageRoot $registryName }}
        {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $termination -}}
    {{- else -}}
        {{- printf "%s%s%s"  $repositoryName $separator $termination -}}
    {{- end -}}
{{- else -}}
    {{ print "auto" }}
{{- end -}}
{{- end -}}

{{/*
Return the proper image version (ingores image revision/prerelease info & fallbacks to chart appVersion)
{{ include "gateways.images.version" ( dict "imageRoot" .Values.path.to.the.image "chart" .Chart ) }}
*/}}
{{- define "gateways.images.version" -}}
{{- if and .imageRoot .imageRoot.tag }}
    {{- $imageTag := .imageRoot.tag | toString -}}
    {{/* regexp from https://github.com/Masterminds/semver/blob/23f51de38a0866c5ef0bfc42b3f735c73107b700/version.go#L41-L44 */}}
    {{- if regexMatch `^([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-([0-9A-Za-z\-]+(\.[0-9A-Za-z\-]+)*))?(\+([0-9A-Za-z\-]+(\.[0-9A-Za-z\-]+)*))?$` $imageTag -}}
        {{- $version := semver $imageTag -}}
        {{- printf "%d.%d.%d" $version.Major $version.Minor $version.Patch -}}
    {{- end -}}
{{- else -}}
    {{- print .chart.AppVersion -}}
{{- end -}}
{{- end -}}