{{- /*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* Return the FreeRADIUS PVC name. */}}
{{- define "freeradius.claimName" -}}
{{- if .Values.persistence.existingClaim }}
  {{- printf "%s" (tpl .Values.persistence.existingClaim $) -}}
{{- else }}
  {{- printf "%s" (include "st-common.names.fullname" .) -}}
{{- end }}
{{- end -}}

{{/* Return the proper image name (for the init container volume-permissions image) */}}
{{- define "freeradius.volumePermissions.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}