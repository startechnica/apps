{{/* Return the proper Mayastor image name */}}
{{- define "mayastor.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Mayastor CSI image name */}}
{{- define "mayastor.csi.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.csi.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper image name (for the init container volume-permissions image) */}}
{{- define "mayastor.volumePermissions.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Docker Image Registry Secret Names */}}
{{- define "mayastor.imagePullSecrets" -}}
  {{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}

{{/* Enforce trailing slash to mayastorImagesPrefix or leave empty */}}
{{- define "mayastorImagesPrefix" -}}
{{- if .Values.mayastorImagesRegistry }}
{{- printf "%s/" (.Values.mayastorImagesRegistry | trimSuffix "/") }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/* Generate CPU list specification based on CPU count (-l param of mayastor) */}}
{{- define "mayastorCpuSpec" -}}
{{- range $i, $e := until (int .Values.mayastorCpuCount) }}
{{- if gt $i 0 }}
{{- printf "," }}
{{- end }}
{{- printf "%d" (add $i 1) }}
{{- end }}
{{- end }}