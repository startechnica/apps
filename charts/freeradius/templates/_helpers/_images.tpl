{{- /*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* Return the proper FreeRADIUS image name */}}
{{- define "freeradius.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Docker Image Registry Secret Names */}}
{{- define "freeradius.imagePullSecrets" -}}
  {{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.volumePermissions.image .Values.metrics.image) "global" .Values.global) -}}
{{- end -}}