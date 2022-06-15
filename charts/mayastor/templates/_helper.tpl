{{/* Create the name of the service account to use for the deployment */}}
{{- define "mayastor.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
  {{ default (printf "%s" (include "common.names.fullname" .)) .Values.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
  {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Return the proper Mayastor image name */}}
{{- define "mayastor.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Mayastor CSI image name */}}
{{- define "mayastor.csi.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.csi.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Mayastor CSI image name */}}
{{- define "mayastor.csiController.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.csiController.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Mayastor Rest image name */}}
{{- define "mayastor.mcpCore.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.mcpCore.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Mayastor Rest image name */}}
{{- define "mayastor.mcpRest.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.mcpRest.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Mayastor Operator image name */}}
{{- define "mayastor.mspOperator.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.mspOperator.image "global" .Values.global) }}
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