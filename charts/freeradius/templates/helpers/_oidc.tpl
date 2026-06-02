{{- /*
(c) 2026 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
================================================================================
Generic OIDC multi-instance helpers. Per-instance values are resolved
with a small defaults dict; `clients.<x>.oidc` binds a NAS to an
instance for the sites/default dispatch chain.

To run FreeRADIUS against Keycloak, configure a generic OIDC instance:

  modules:
    oidc:
      enabled: true
      instances:
        my-kc:
          tokenUrl: "https://auth.example.com/realms/master/protocol/openid-connect/token"
          introspectUrl: "https://auth.example.com/realms/master/protocol/openid-connect/token/introspect"
          clientId: freeradius
          clientSecret: "..."
          # `client` roleMapper equivalent → resource_access.<clientId>.roles
          # `realm`  roleMapper equivalent → realm_access.roles
          rolesClaim: "resource_access.freeradius.roles"
          groupsClaim: "groups"

  envVarPrefix       FREERADIUS_OIDC_           / FREERADIUS_OIDC_<NAME>_
  moduleName         oidc                       / oidc_<name>
  validateModuleName oidc_validate              / oidc_<name>_validate
  policyName         oidc_authorize             / oidc_<name>_authorize
  rolesPolicyName    oidc_roles                 / oidc_<name>_roles
  groupsPolicyName   oidc_groups                / oidc_<name>_groups
  cacheName          oidc_cache                 / oidc_<name>_cache
  cacheKey           "oidc:%{User-Name}"        / "oidc:<name>:%{User-Name}"
  modKey             oidc                       / oidc_<name>
  policyKey          oidc                       / oidc_<name>
  scriptKey          oidc.py                    / oidc_<name>.py
================================================================================
*/}}

{{- define "freeradius.oidc.resolveInstances" -}}
{{- $tlsDefaults := dict "caCert" "" "existingSecret" "" "existingSecretCaKey" "ca.crt" "insecure" false -}}
{{- $cacheDefaults := dict "enabled" false "ttl" 300 -}}
{{- $instanceDefaults := dict
      "tokenUrl" ""
      "introspectUrl" ""
      "clientId" "freeradius"
      "clientSecret" ""
      "scope" ""
      "connectTimeout" "4.0"
      "roleAttribute" "Class"
      "rolesClaim" ""
      "denyWithoutRole" false
      "roleMappings" (list)
      "groupAttribute" "Class"
      "groupsClaim" "groups"
      "groupMappings" (list)
      "attributeMappings" (list)
      "require" (list)
      "introspect" false
      "refreshTokenCache" false
      "existingConfigMap" ""
      "existingSecret" "" -}}
{{- $instances := dict -}}
{{- range $name, $cfg := (default dict .Values.modules.oidc.instances) -}}
{{- $tls := merge (deepCopy (default dict $cfg.tls)) $tlsDefaults -}}
{{- $cache := merge (deepCopy (default dict $cfg.cache)) $cacheDefaults -}}
{{- $merged := merge (deepCopy $cfg) (dict "tls" $tls "cache" $cache) $instanceDefaults -}}
{{- $_ := set $instances $name $merged -}}
{{- end -}}
{{- (dict "instances" $instances) | toYaml -}}
{{- end -}}

{{- define "freeradius.oidc.envVarPrefix" -}}
{{- if eq .name "default" -}}FREERADIUS_OIDC_
{{- else -}}FREERADIUS_OIDC_{{ .name | upper }}_
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.moduleName" -}}
{{- if eq .name "default" -}}oidc
{{- else -}}oidc_{{ .name }}
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.validateModuleName" -}}
{{- if eq .name "default" -}}oidc_validate
{{- else -}}oidc_{{ .name }}_validate
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.policyName" -}}
{{- if eq .name "default" -}}oidc_authorize
{{- else -}}oidc_{{ .name }}_authorize
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.rolesPolicyName" -}}
{{- if eq .name "default" -}}oidc_roles
{{- else -}}oidc_{{ .name }}_roles
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.groupsPolicyName" -}}
{{- if eq .name "default" -}}oidc_groups
{{- else -}}oidc_{{ .name }}_groups
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.cacheName" -}}
{{- if eq .name "default" -}}oidc_cache
{{- else -}}oidc_{{ .name }}_cache
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.cacheKey" -}}
{{- if eq .name "default" -}}"oidc:%{User-Name}"
{{- else -}}"oidc:{{ .name }}:%{User-Name}"
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.modKey" -}}
{{- if eq .name "default" -}}oidc
{{- else -}}oidc_{{ .name }}
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.policyKey" -}}
{{- if eq .name "default" -}}oidc
{{- else -}}oidc_{{ .name }}
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.scriptKey" -}}
{{- /* The default-instance wrapper is named `oidc_default.py` (not
       `oidc.py`) so it does not collide with the shared library
       `oidc.py` mounted alongside it under python_path. */}}
{{- if eq .name "default" -}}oidc_default.py
{{- else -}}oidc_{{ .name }}.py
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.clientSecretName" -}}
{{- if .instance.existingSecret -}}
{{- tpl .instance.existingSecret .context -}}
{{- else if eq .name "default" -}}
{{- printf "%s-oidc" (include "st-common.names.fullname" .context) -}}
{{- else -}}
{{- printf "%s-oidc-%s" (include "st-common.names.fullname" .context) .name -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.tls.enabled" -}}
{{- if or .instance.tls.caCert .instance.tls.existingSecret -}}
true
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.tls.createSecret" -}}
{{- if and .instance.tls.caCert (not .instance.tls.existingSecret) -}}
true
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.tls.secretName" -}}
{{- if .instance.tls.existingSecret -}}
{{- tpl .instance.tls.existingSecret .context -}}
{{- else if eq .name "default" -}}
{{- printf "%s-oidc-ca" (include "st-common.names.fullname" .context) -}}
{{- else -}}
{{- printf "%s-oidc-%s-ca" (include "st-common.names.fullname" .context) .name -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.tls.caKey" -}}
{{- if .instance.tls.existingSecret -}}
{{- default "ca.crt" .instance.tls.existingSecretCaKey -}}
{{- else -}}
ca.crt
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.tls.caFilePath" -}}
{{- if eq .name "default" -}}
{{- printf "/etc/freeradius/certs-oidc/%s" (include "freeradius.oidc.tls.caKey" .) -}}
{{- else -}}
{{- printf "/etc/freeradius/certs-oidc-%s/%s" .name (include "freeradius.oidc.tls.caKey" .) -}}
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.tlsVolumeName" -}}
{{- if eq .name "default" -}}oidc-tls
{{- else -}}oidc-{{ .name }}-tls
{{- end -}}
{{- end -}}

{{- define "freeradius.oidc.dispatchArms" -}}
{{- $arms := list -}}
{{- range $clientName, $client := .Values.clients -}}
{{- if and (kindIs "map" $client) $client.oidc (or $client.ipv4addr $client.ipv6addr) -}}
{{- $arms = append $arms (dict "client" $clientName "ipv4" (default "" $client.ipv4addr) "ipv6" (default "" $client.ipv6addr) "instance" $client.oidc) -}}
{{- end -}}
{{- end -}}
{{- (dict "arms" $arms) | toYaml -}}
{{- end -}}
