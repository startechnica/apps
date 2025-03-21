{{/*
Copyright Firmansyah Nainggolan <firmansyah@nanggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Returns the proper service account name depending if an explicit service account name is set
in the values file. If the name is not set it will default to either st-common.names.fullname if $gateway.serviceAccount.create
is true or default otherwise.
*/}}
{{/*
{{ include "gateways.rbac.serviceAccountName" (dict "gatewayValues" .Values.gateways.gateway "context" .) }}
*/}}
{{- define "gateways.rbac.serviceAccountName" -}}
{{- if and .gatewayValues.serviceAccount .gatewayValues.serviceAccount.create -}}
  {{ default .gatewayValues.name .gatewayValues.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
  {{ default "default" .context.Values.serviceAccount.name }}
{{- end -}}
{{- end -}}