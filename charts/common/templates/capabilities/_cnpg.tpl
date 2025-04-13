{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* Return the appropriate apiVersion for Cloudnative PG */}}
{{- define "common.capabilities.cnpgPostgresql.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "postgresql.cnpg.io/v1" -}}
  {{- print "postgresql.cnpg.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Cloudnative PG */}}
{{- define "st-common.capabilities.cnpgPostgresql.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "postgresql.cnpg.io/v1" -}}
  {{- print "postgresql.cnpg.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Cloudnative PG Backup. */}}
{{- define "st-common.capabilities.postgresqlCnpgBackup.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "postgresql.cnpg.io/v1/Backup" -}}
  {{- print "postgresql.cnpg.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Cloudnative PG ClusterImageCatalog. */}}
{{- define "st-common.capabilities.postgresqlCnpgClusterImageCatalog.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "postgresql.cnpg.io/v1/ClusterImageCatalog" -}}
  {{- print "postgresql.cnpg.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Cloudnative PG Cluster. */}}
{{- define "st-common.capabilities.postgresqlCnpgCluster.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "postgresql.cnpg.io/v1/Cluster" -}}
  {{- print "postgresql.cnpg.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Cloudnative PG Database. */}}
{{- define "st-common.capabilities.postgresqlCnpgDatabase.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "postgresql.cnpg.io/v1/Database" -}}
  {{- print "postgresql.cnpg.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Cloudnative PG ImageCatalog. */}}
{{- define "st-common.capabilities.postgresqlCnpgImageCatalog.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "postgresql.cnpg.io/v1/ImageCatalog" -}}
  {{- print "postgresql.cnpg.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Cloudnative PG Pooler. */}}
{{- define "st-common.capabilities.postgresqlCnpgPooler.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "postgresql.cnpg.io/v1/Pooler" -}}
  {{- print "postgresql.cnpg.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Cloudnative PG Publication. */}}
{{- define "st-common.capabilities.postgresqlCnpgPublication.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "postgresql.cnpg.io/v1/Publication" -}}
  {{- print "postgresql.cnpg.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Cloudnative PG ScheduledBackup. */}}
{{- define "st-common.capabilities.postgresqlCnpgScheduledBackup.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "postgresql.cnpg.io/v1/ScheduledBackup" -}}
  {{- print "postgresql.cnpg.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Cloudnative PG Subscription. */}}
{{- define "st-common.capabilities.postgresqlCnpgSubscription.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "postgresql.cnpg.io/v1/Subscription" -}}
  {{- print "postgresql.cnpg.io/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}
