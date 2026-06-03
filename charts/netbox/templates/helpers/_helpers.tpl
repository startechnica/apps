{{- /*
(c) 2026 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper Netbox worker fullname
*/}}
{{- define "netbox.worker.fullname" -}}
{{- printf "%s-%s" (include "st-common.names.fullname" .) "worker" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper Netbox housekeeping fullname
*/}}
{{- define "netbox.housekeeping.fullname" -}}
{{- printf "%s-%s" (include "st-common.names.fullname" .) "housekeeping" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "netbox.imagePullSecrets" -}}
{{- include "st-common.images.renderPullSecrets" (dict "images" (list .Values.image .Values.worker.image .Values.housekeeping.image .Values.initDirs.image .Values.volumePermissions.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "netbox.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
  {{- default (include "st-common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
  {{- default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the configuration configmap name
*/}}
{{- define "netbox.configmapName" -}}
{{- if .Values.existingConfigmap -}}
    {{- printf "%s" (tpl .Values.existingConfigmap $) -}}
{{- else -}}
    {{- printf "%s" (include "st-common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a configmap object should be created
*/}}
{{- define "netbox.createConfigmap" -}}
{{- if empty .Values.existingConfigmap }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the init-scripts ConfigMap name (user-provided or chart-managed)
*/}}
{{- define "netbox.initdbScriptsCM" -}}
{{- if .Values.initdbScriptsConfigMap -}}
    {{- printf "%s" (tpl .Values.initdbScriptsConfigMap $) -}}
{{- else -}}
    {{- printf "%s-init-scripts" (include "st-common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the path Netbox is hosted on. This looks at httpRelativePath and returns it with a trailing slash. For example:
    / -> / (the default httpRelativePath)
    /auth -> /auth/ (trailing slash added)
    /custom/ -> /custom/ (unchanged)
*/}}
{{- define "netbox.httpPath" -}}
{{ ternary .Values.httpRelativePath (printf "%s%s" .Values.httpRelativePath "/") (hasSuffix "/" .Values.httpRelativePath) }}
{{- end -}}

{{/*
Returns the available value for certain key in an existing secret (if it exists), otherwise generate random value.
*/}}
{{- define "netbox.getValueFromSecret" }}
    {{- $len := (default 16 .Length) | int -}}
    {{- $obj := (lookup "v1" "Secret" .Namespace .Name).data -}}
    {{- if $obj }}
        {{- index $obj .Key | b64dec -}}
    {{- else -}}
        {{- randAlphaNum $len -}}
    {{- end -}}
{{- end }}

{{/*
Return the Netbox secret name
*/}}
{{- define "netbox.secretName" -}}
    {{ default (include "st-common.names.fullname" .) .Values.existingSecretName }}
{{- end -}}

{{/*
Volumes that need to be mounted for .Values.extraConfig entries
*/}}
{{- define "netbox.extraConfig.volumes" -}}
{{- range $index, $config := .Values.extraConfig -}}
- name: extra-config-{{ $index }}
  {{- if $config.values }}
  configMap:
    name: {{ printf "%s" (include "st-common.names.fullname" $) }}
    items:
    - key: extra-{{ $index }}.yaml
      path: extra-{{ $index }}.yaml
  {{- else if $config.configMap }}
  configMap:
    {{- toYaml $config.configMap | nindent 4 }}
  {{- else if $config.secret }}
  secret:
    {{- toYaml $config.secret | nindent 4 }}
  {{- end }}
{{ end -}}
{{- end -}}

{{/*
Volume mounts for .Values.extraConfig entries
*/}}
{{- define "netbox.extraConfig.volumeMounts" -}}
{{- range $index, $config := .Values.extraConfig -}}
- name: extra-config-{{ $index }}
  mountPath: /run/config/extra/{{ $index }}
  readOnly: true
{{ end -}}
{{- end -}}

{{/*
Return the secret name containing the Netbox superuser password
*/}}
{{- define "netbox.superuser.secretName" -}}
{{- if .Values.superuser.existingSecretName -}}
    {{- printf "%s" .Values.superuser.existingSecretName -}}
{{- else -}}
    {{- .Values.existingSecretName | default (include "st-common.names.fullname" .) }}
{{- end -}}
{{- end -}}

{{/*
Return the secret key that contains the Netbox superuser password
*/}}
{{- define "netbox.superuser.secretPasswordKey" -}}
{{- if .Values.superuser.existingSecretName -}}
    {{- if .Values.superuser.existingSecretPasswordKey -}}
        {{- printf "%s" .Values.superuser.existingSecretPasswordKey -}}
    {{- else -}}
        {{- printf "%s" "superuser-password" -}}
    {{- end -}}
{{- else if .Values.existingSecretName -}}
    {{- printf "%s" "superuser-password" -}}
{{- else -}}
    {{- printf "%s" "superuser_password" -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret key that contains the Netbox superuser API token
*/}}
{{- define "netbox.superuser.secretApiTokenKey" -}}
{{- if .Values.superuser.existingSecretName -}}
    {{- if .Values.superuser.existingSecretApiTokenKey -}}
        {{- printf "%s" .Values.superuser.existingSecretApiTokenKey -}}
    {{- else -}}
        {{- printf "%s" "superuser-api-token" -}}
    {{- end -}}
{{- else if .Values.existingSecretName -}}
    {{- printf "%s" "superuser-api-token" -}}
{{- else -}}
    {{- printf "%s" "superuser_api_token" -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret name containing email server
*/}}
{{- define "netbox.email.secretName" -}}
{{- if .Values.email.existingSecretName -}}
    {{- printf "%s" .Values.email.existingSecretName -}}
{{- else -}}
    {{- default (include "st-common.names.fullname" .) .Values.existingSecretName }}
{{- end -}}
{{- end -}}

{{/*
Return the secret key that contains the Netbox email password
*/}}
{{- define "netbox.email.secretPasswordKey" -}}
{{- if .Values.email.existingSecretName -}}
    {{- if .Values.email.existingSecretPasswordKey -}}
        {{- printf "%s" .Values.email.existingSecretPasswordKey -}}
    {{- else -}}
        {{- printf "%s" "email-password" -}}
    {{- end -}}
{{- else -}}
    {{- if .Values.existingSecretName -}}
        {{- printf "%s" "email-password" -}}
    {{- else -}}
        {{- printf "%s" "email_password" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret key that contains the Netbox Secret Key
*/}}
{{- define "netbox.secretSecretKeyKey" -}}
{{- if .Values.existingSecretName -}}
    {{- printf "%s" "secret-key" -}}
{{- else -}}
    {{- printf "%s" "secret_key" -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret name containing remote auth
*/}}
{{- define "netbox.remoteAuth.secretName" -}}
{{- if .Values.remoteAuth.existingSecretName -}}
    {{- printf "%s" .Values.remoteAuth.existingSecretName -}}
{{- else -}}
    {{ include "netbox.secretName" . }}
{{- end -}}
{{- end -}}

{{- define "netbox.remoteAuth.ldap.secretBindPasswordKey" -}}
{{- if .Values.remoteAuth.ldap.existingSecretBindPasswordKey -}}
    {{- printf "%s" .Values.remoteAuth.ldap.existingSecretBindPasswordKey -}}
{{- else -}}
  {{- if .Values.remoteAuth.existingSecretName -}}
      {{- printf "%s" "ldap-bind-password" -}}
  {{- else -}}
    {{- print "ldap-bind-password" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS secret object should be created
*/}}
{{- define "netbox.tls.isCreateSecret" -}}
{{- if and .Values.tls.enabled .Values.tls.autoGenerated (not .Values.tls.existingSecretName) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Resolve whether the chart should render a cert-manager Certificate. Returns
string "true" when:
  - TLS is wanted (`tls.enabled` OR `ingress.tls` non-empty),
  - cert-manager API is detected on the cluster, AND
  - the user has NOT pinned an external secret via `tls.certificatesSecret`.

The legacy flags `tls.certManager.create` and `tls.autoGenerator.certManager.enabled`
are no longer consulted (cert-manager is auto-detected). Slated for removal
in 6.0.0.
*/}}
{{- define "netbox.tls.certManager.create" -}}
{{- $wantsTls := or .Values.tls.enabled .Values.ingress.tls -}}
{{- $cmApi := include "st-common.capabilities.certmanagerCertificate.apiVersion" . -}}
{{- $hasCm := and $cmApi (ne $cmApi "false") -}}
{{- $externalSecret := .Values.tls.certificatesSecret -}}
{{- if and $wantsTls $hasCm (not $externalSecret) -}}
true
{{- end -}}
{{- end -}}

{{/*
Resolve cert-manager Issuer kind. Prefers `tls.certManager.issuerRef.kind`,
falls back to the deprecated `tls.autoGenerator.certManager.issuerKind`.
*/}}
{{- define "netbox.tls.certManager.issuerKind" -}}
{{- if and .Values.tls.certManager .Values.tls.certManager.issuerRef .Values.tls.certManager.issuerRef.kind -}}
{{- .Values.tls.certManager.issuerRef.kind -}}
{{- else if and .Values.tls.autoGenerator .Values.tls.autoGenerator.certManager .Values.tls.autoGenerator.certManager.issuerKind -}}
{{- .Values.tls.autoGenerator.certManager.issuerKind -}}
{{- else -}}
ClusterIssuer
{{- end -}}
{{- end -}}

{{/*
Resolve cert-manager Issuer name. Prefers `tls.certManager.issuerRef.name`,
falls back to the deprecated `tls.autoGenerator.certManager.issuerName`.
*/}}
{{- define "netbox.tls.certManager.issuerName" -}}
{{- if and .Values.tls.certManager .Values.tls.certManager.issuerRef .Values.tls.certManager.issuerRef.name -}}
{{- .Values.tls.certManager.issuerRef.name -}}
{{- else if and .Values.tls.autoGenerator .Values.tls.autoGenerator.certManager .Values.tls.autoGenerator.certManager.issuerName -}}
{{- .Values.tls.autoGenerator.certManager.issuerName -}}
{{- else -}}
selfsigned-issuer
{{- end -}}
{{- end -}}

{{- define "netbox.media.pvcName" -}}
{{- if .Values.persistence.existingClaim -}}
    {{- .Values.persistence.existingClaim -}}
{{- else -}}
    {{ printf "%s-%s" (include "st-common.names.fullname" .) "media" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "netbox.reports.pvcName" -}}
{{- if .Values.reportsPersistence.existingClaim -}}
    {{- .Values.reportsPersistence.existingClaim -}}
{{- else -}}
    {{ printf "%s-%s" (include "st-common.names.fullname" .) "reports" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "netbox.scripts.pvcName" -}}
{{- if .Values.scriptsPersistence.existingClaim -}}
    {{- .Values.scriptsPersistence.existingClaim -}}
{{- else -}}
    {{ printf "%s-%s" (include "st-common.names.fullname" .) "scripts" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Returns the volumes that will be attached to the workload resources (deployment, statefulset, etc)
*/}}
{{- define "netbox.media.volumes" -}}
- name: media
  {{- if .Values.persistence.enabled }}
  persistentVolumeClaim:
    claimName: {{ include "netbox.media.pvcName" . }}
  {{- else }}
  emptyDir: {}
  {{- end }}
{{- end -}}

{{- define "netbox.reports.volumes" -}}
- name: reports
  {{- if .Values.reportsPersistence.enabled }}
  persistentVolumeClaim:
    claimName: {{ include "netbox.reports.pvcName" . }}
  {{- else }}
  emptyDir: {}
  {{- end }}
{{- end -}}

{{- define "netbox.scripts.volumes" -}}
- name: scripts
  {{- if .Values.scriptsPersistence.enabled }}
  persistentVolumeClaim:
    claimName: {{ include "netbox.scripts.pvcName" . }}
  {{- else }}
  emptyDir: {}
  {{- end }}
{{- end -}}

{{/* Validate values of Netbox - TLS enabled */}}
{{- define "netbox.validateValues.tls" -}}
{{- if and .Values.tls.enabled (not .Values.tls.autoGenerated) (not .Values.tls.existingSecretName) }}
netbox: tls.enabled
    In order to enable TLS, you also need to provide
    an existing secret containing the Keystore and Truststore or
    enable auto-generated certificates.
{{- end -}}
{{- end -}}
