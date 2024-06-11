{{/* Return the appropriate apiVersion for Istio Extensions. */}}
{{- define "common.capabilities.istioExtensions.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "extensions.istio.io/v1alpha1" -}}
  {{- print "extensions.istio.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio Install. */}}
{{- define "common.capabilities.istioInstall.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "install.istio.io/v1alpha1" -}}
  {{- print "install.istio.io/v1alpha1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio Networking. */}}
{{- define "common.capabilities.istioNetworking.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1" -}}
  {{- print "networking.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1alpha3" -}}
  {{- print "networking.istio.io/v1alpha3" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio Security. */}}
{{- define "common.capabilities.istioSecurity.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "security.istio.io/v1" -}}
  {{- print "security.istio.io/v1" -}}
{{- else if .Capabilities.APIVersions.Has "security.istio.io/v1beta1" -}}
  {{- print "security.istio.io/v1beta1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio Telemetry. */}}
{{- define "common.capabilities.istioTelemetry.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "telemetry.istio.io/v1alpha1" -}}
  {{- print "telemetry.istio.io/v1alpha1" -}}
{{- else if .Capabilities.APIVersions.Has "telemetry.istio.io/v1" -}}
  {{- print "telemetry.istio.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}