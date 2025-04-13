{{/*
Copyright (c) 2025 Firmansyah Nainggolan. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/* Return the appropriate apiVersion for MongoDB Operator MongoDBCommunity. */}}
{{- define "st-common.capabilities.mongodbMongoDBCommunity.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "mongodbcommunity.mongodb.com/v1/MongoDBCommunity" -}}
  {{- print "mongodbcommunity.mongodb.com/v1" -}}
{{- else -}}
  {{- false -}}
{{- end -}}
{{- end -}}