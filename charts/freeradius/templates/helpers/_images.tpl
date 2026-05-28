{{- /*
(c) 2026 Firmansyah Nainggolan <firmansyah@nainggolan.id>. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Image used by the `db-bootstrap` init container. The per-dialect defaults
live HERE (not in values.yaml) — each dialect maps to a canonical client
image that actually ships the matching CLI (`mysql` for mariadb,
`psql` for postgresql). User overrides via `bootstrap.database.image.*`
fill in field-by-field: any non-empty user value wins, anything empty
falls back to the dialect default. Sqlite never reaches this helper —
`freeradius.bootstrap.database.cmd` returns empty for sqlite, which the
Deployment treats as a skip-the-init-container sentinel.

To add a new dialect, extend `$defaults` below AND the SQL backend
validator's allowed-dialect list.
*/}}
{{- define "freeradius.bootstrap.database.image" -}}
{{- $defaults := dict
    "mysql"      (dict "registry" "public.ecr.aws" "repository" "bitnami/mariadb"    "tag" "12.2.2")
    "postgresql" (dict "registry" "public.ecr.aws" "repository" "bitnami/postgresql" "tag" "18.4.0")
-}}
{{- $default := index $defaults .Values.modules.sql.dialect | default dict -}}
{{- $user := .Values.bootstrap.database.image -}}
{{- $img := dict
    "registry"    (default (get $default "registry")   $user.registry)
    "repository"  (default (get $default "repository") $user.repository)
    "tag"         (default (get $default "tag")        $user.tag)
    "digest"      $user.digest
    "pullPolicy"  $user.pullPolicy
    "pullSecrets" $user.pullSecrets
-}}
{{ include "st-common.images.image" (dict "imageRoot" $img "global" .Values.global) }}
{{- end -}}

{{- define "freeradius.image.pullSecrets" -}}
  {{- include "st-common.images.pullSecrets" (dict "images" (list .Values.image .Values.volumePermissions.image .Values.metrics.image .Values.bootstrap.database.image) "global" .Values.global) -}}
{{- end -}}
