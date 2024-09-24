{{- /*
Copyright (c) 2024 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* Return the appropriate apiVersion for cert-manager. */}}
{{- define "common.capabilities.certManager.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "cert-manager.io/v1" -}}
  {{- print "cert-manager.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for cert-manager Certificate. */}}
{{- define "common.capabilities.certmanagerCertificate.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "cert-manager.io/v1/Certificate" -}}
  {{- print "cert-manager.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for cert-manager CertificateRequest. */}}
{{- define "common.capabilities.certmanagerCertificateRequest.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "cert-manager.io/v1/CertificateRequest" -}}
  {{- print "cert-manager.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for cert-manager ClusterIssuer. */}}
{{- define "common.capabilities.certmanagerClusterIssuer.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "cert-manager.io/v1/ClusterIssuer" -}}
  {{- print "cert-manager.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for cert-manager Issuer. */}}
{{- define "common.capabilities.certmanagerIssuer.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "cert-manager.io/v1/Issuer" -}}
  {{- print "cert-manager.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for cert-manager ACME. */}}
{{- define "common.capabilities.certManagerAcme.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "acme.cert-manager.io/v1" -}}
  {{- print "acme.cert-manager.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

