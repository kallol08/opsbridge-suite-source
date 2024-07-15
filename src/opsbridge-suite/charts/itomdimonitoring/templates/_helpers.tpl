{{/* # */}}
{{/* # Copyright 2023 Open Text. */}}
{{/* # */}}
{{/* # The only warranties for products and services of Open Text and its affiliates and  */}}
{{/* # licensors (“Open Text”) are as may be set forth in the express warranty statements  */}}
{{/* # accompanying such products and services. Nothing herein should be construed as */}}
{{/* # constituting an additional warranty. Open Text shall not be liable for technical or */}}
{{/* # editorial errors or omissions contained herein. The information contained herein is  */}}
{{/* # subject to change without notice. */}}
{{/* # */}}
{{/* # Except as specifically indicated otherwise, this document contains confidential  */}}
{{/* # information and a valid license is required for possession, use or copying. If this work  */}}
{{/* # is provided to the U.S. Government, consistent with FAR 12.211 and 12.212, Commercial Computer  */}}
{{/* # Software, Computer Software Documentation, and Technical Data for Commercial Items are licensed to */}}
{{/* # the U.S. Government under vendor’s standard commercial license. */}}
{{/* # */}}
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "monitoring.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "monitoring.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "monitoring.vpename" -}}
app.kubernetes.io/name: "{{ template "monitoring.fullname" . }}-{{ .Values.monitoring.verticapromexporter.component }}"
{{- end }}

{{- define "monitoring.standardLabels" -}}
app: {{ template "monitoring.name" . }}
app.kubernetes.io/managed-by: {{.Release.Name}}
app.kubernetes.io/version: {{.Chart.Version}}
itom.microfocus.com/capability: itom-data-ingestion
tier.itom.microfocus.com/backend: backend
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "monitoring.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Vertica Database Properties.
*/}}

{{- define "vertica.host" -}}
{{- $vhost := "itom-di-vertica-svc" | quote -}}
{{- if (eq (.Values.global.vertica.embedded | toString) "true") }}
{{- printf "%s" $vhost -}}
{{- else -}}
{{- $vhost := .Values.global.vertica.host | quote -}}
{{- printf "%s" $vhost -}}
{{- end -}}
{{- end -}}

{{- define "vertica.rwuser" -}}
{{- $vrwuser := "dbadmin" | quote -}}
{{- if (eq (.Values.global.vertica.embedded | toString) "true") }}
{{- printf "%s" $vrwuser -}}
{{- else -}}
{{- $vrwuser := .Values.global.vertica.rwuser | quote -}}
{{- printf "%s" $vrwuser -}}
{{- end -}}
{{- end -}}

{{- define "vertica.rouser" -}}
{{- $vrouser := "dbadmin" | quote -}}
{{- if (eq (.Values.global.vertica.embedded | toString) "true") }}
{{- printf "%s" $vrouser -}}
{{- else -}}
{{- $vrouser := .Values.global.vertica.rouser | quote -}}
{{- printf "%s" $vrouser -}}
{{- end -}}
{{- end -}}

{{- define "vertica.db" -}}
{{- $vdb := "itomdb" | quote -}}
{{- if (eq (.Values.global.vertica.embedded | toString) "true") }}
{{- printf "%s" $vdb -}}
{{- else -}}
{{- $vdb := .Values.global.vertica.db | quote -}}
{{- printf "%s" $vdb -}}
{{- end -}}
{{- end -}}

{{- define "vertica.port" -}}
{{- $vport := "5444" | quote -}}
{{- if (eq (.Values.global.vertica.embedded | toString) "true") }}
{{- printf "%s" $vport -}}
{{- else -}}
{{- $vport := .Values.global.vertica.port | quote -}}
{{- printf "%s" $vport -}}
{{- end -}}
{{- end -}}

{{/*
vprom component name
*/}}
{{- define "vprom.component.name" -}}
{{- if (.Values.monitoring.verticapromexporter.component) -}}
{{- if (not (empty .Values.monitoring.verticapromexporter.component)) -}}
{{- printf "%s" .Values.monitoring.verticapromexporter.component  -}}
{{- else -}}
{{- print "Required value is not defined for verticapromexporter component" -}}
{{- end -}}
{{- else -}}
{{- print "Required value is not defined for verticapromexporter component" -}}
{{- end -}}
{{- end }}

{{/*
gencert component name
*/}}
{{- define "gencert.component.name" -}}
{{- if (.Values.monitoring.gencerts.component) -}}
{{- if (not (empty .Values.monitoring.gencerts.component)) -}}
{{- printf "%s" .Values.monitoring.gencerts.component  -}}
{{- else -}}
{{- print "Required value is not defined for gencerts component" -}}
{{- end -}}
{{- else -}}
{{- print "Required value is not defined for gencerts component" -}}
{{- end -}}
{{- end }}

{{- define "monitoring.initContainers.resources" -}}
limits:
  cpu: "20m"
  memory: "20Mi"
requests:
  cpu: "5m"
  memory: "5Mi"
{{- end -}}


{{/*
Can alerts be deployed
*/}}
{{- define "monitoring.alerts_deployment" -}}
{{- if and (eq (((((.Values.global).di).prometheus).alerts).enabled)  true)  (and (.Capabilities.APIVersions.Has "monitoring.coreos.com/v1") (eq  (((.Values.global).prometheus).deployPrometheusConfig)  true)) -}}
{{- printf "%t" true -}}
{{- else -}}
{{- printf "%t" false -}}
{{- end -}}
{{- end -}}
