{{- /*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* Return the appropriate apiVersion for Percona PerconaServerMongoDBBackup */}}
{{- define "st-common.capabilities.perconaPerconaServerMongoDBBackup.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "psmdb.percona.com/v1/PerconaServerMongoDBBackup" -}}
  {{- print "psmdb.percona.com/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Percona PerconaServerMongoDBRestore */}}
{{- define "st-common.capabilities.perconaPerconaServerMongoDBRestore.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "psmdb.percona.com/v1/PerconaServerMongoDBRestore" -}}
  {{- print "psmdb.percona.com/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Percona PerconaServerMongoDB */}}
{{- define "st-common.capabilities.perconaPerconaServerMongoDB.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "psmdb.percona.com/v1/PerconaServerMongoDB" -}}
  {{- print "psmdb.percona.com/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}