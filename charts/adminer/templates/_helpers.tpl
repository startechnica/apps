{{/*
Name of the Kubernetes Secret holding the TLS material referenced by the
Gateway HTTPS listener — `credentialName` on the istio path,
`certificateRefs[].name` on the gateway-api path, and the resource name
produced by `templates/secret/gateway-tls.yaml`. Single source of truth so
the listener and the secret can never drift apart.

Resolution order (first match wins):
  1. `gateway.tls.existingSecret`       — BYO Secret managed outside the chart.
  2. `gateway.tls.secrets[0].name`      — first user-supplied PEM Secret rendered by `templates/secret/gateway-tls.yaml`.
                                          For multi-secret SNI setups, override via `gateway.listeners`.
  3. `<ingress.hostname>-tls`           — chart-managed default that matches the secret name produced by the
                                          self-signed branch in `templates/secret/gateway-tls.yaml`,
                                          the `Certificate.spec.secretName` in `templates/Certificate.yaml`,
                                          and `templates/secret/ingress-tls.yaml`.
*/}}
{{- define "adminer.gateway.tlsSecretName" -}}
{{- if .Values.gateway.tls.existingSecret -}}
{{- .Values.gateway.tls.existingSecret -}}
{{- else if .Values.gateway.tls.secrets -}}
{{- (first .Values.gateway.tls.secrets).name -}}
{{- else -}}
{{- printf "%s-tls" .Values.ingress.hostname -}}
{{- end -}}
{{- end -}}

{{/*
Render `config.plugins` as the space-separated string the Adminer image
expects in the ADMINER_PLUGINS env var. Accepts either a list (preferred,
YAML-friendly) or a pre-formatted string (backwards-compatible).
*/}}
{{- define "adminer.config.plugins" -}}
{{- if kindIs "slice" .Values.config.plugins -}}
{{- join " " .Values.config.plugins -}}
{{- else -}}
{{- .Values.config.plugins -}}
{{- end -}}
{{- end -}}

{{/*
Default value for the "Server" field on Adminer's login screen
(ADMINER_DEFAULT_SERVER). Returns `config.defaultServer` if set, otherwise
falls back to the DEPRECATED `config.externalserver` so existing user
overrides keep working until the next major bump.
*/}}
{{- define "adminer.config.defaultServer" -}}
{{- default .Values.config.externalserver .Values.config.defaultServer -}}
{{- end -}}

{{/*
Name of the ConfigMap whose data: block is loaded into the Adminer container
via `envFrom`. Returns `existingConfigmap` when the user is bringing their
own ConfigMap, otherwise the name of the chart-rendered env-vars ConfigMap
(see `templates/configmap/envvars.yaml`).
*/}}
{{- define "adminer.config.envvarsConfigMapName" -}}
{{- default (printf "%s-envvars" (include "st-common.names.fullname" .)) .Values.existingConfigmap -}}
{{- end -}}

{{/*
Name of the chart-internal CA Secret (`<fullname>-tls-ca`) holding the
self-signed Certificate Authority shared by the ingress and gateway leaf TLS
Secrets. Single source of truth for the CA Secret name — used by both
`templates/secret/tls-ca.yaml` and the lookup inside `adminer.tls.ca.init`.
*/}}
{{- define "adminer.tls.ca.secretName" -}}
{{- printf "%s-tls-ca" (include "st-common.names.fullname" .) -}}
{{- end -}}

{{/*
Populates `$._adminerTlsCa` (root-context cache) with the chart's self-signed
TLS Certificate Authority — a dict shaped `{Cert, Key}` compatible with
sprig's `genSignedCert`. After calling this template-include, callers read the
CA back via `index $ "_adminerTlsCa"`.

Recovery chain on first invocation per render:
  1. lookup the persistent CA Secret rendered by `templates/secret/tls-ca.yaml`
     in the release namespace; recover Cert+Key if present.
  2. otherwise fall back to `genCA` (first install path).

Why: previously `templates/secret/ingress-tls.yaml` and
`templates/secret/gateway-tls.yaml` each called `genCA` independently, which
produced two distinct CAs in the same render. A user migrating from ingress
to gateway exposure (or running both) would have to re-trust a different CA
per path, AND each `helm upgrade` would rotate the CA — breaking pinned
clients on every release. This helper makes a single CA persist across both
paths and across upgrades.

Caveat: chart upgrades from versions before this helper landed will rotate
the CA exactly once (no persistent CA Secret existed to recover from), so
clients that pinned the old CA need to re-trust on that one upgrade.
*/}}
{{- define "adminer.tls.ca.init" -}}
{{- if not (hasKey $ "_adminerTlsCa") -}}
  {{- $existing := lookup "v1" "Secret" (include "st-common.names.namespace" .) (include "adminer.tls.ca.secretName" .) -}}
  {{- $ca := "" -}}
  {{- if and $existing $existing.data (hasKey $existing.data "ca.crt") (hasKey $existing.data "ca.key") -}}
    {{- $ca = buildCustomCert (index $existing.data "ca.crt") (index $existing.data "ca.key") -}}
  {{- else -}}
    {{- $ca = genCA "adminer-ca" 365 -}}
  {{- end -}}
  {{- $_ := set $ "_adminerTlsCa" $ca -}}
{{- end -}}
{{- end -}}