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