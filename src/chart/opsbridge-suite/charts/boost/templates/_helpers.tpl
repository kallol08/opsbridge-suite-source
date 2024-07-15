{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "boost.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "boost.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "boost.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "boost.labels" -}}
helm.sh/chart: {{ include "boost.chart" . }}
{{ include "boost.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "boost.selectorLabels" -}}
app.kubernetes.io/name: {{ include "boost.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "boost.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "boost.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "boost.buildEndpoint" -}}
{{- $namespace := .root.Release.Namespace -}}
{{- if .service.namespace -}}
{{- $namespace = .service.namespace -}}
{{ .service.protocol }}://{{ .service.host }}.{{ $namespace }}.{{ default "svc.cluster.local" .root.Values.global.kubernetesDomain.name }}:{{ .service.port }}{{ .service.contextPath }}
{{- else -}}
{{ .service.protocol }}://{{ .root.Release.Name }}-{{ .service.host }}.{{ $namespace }}.{{ default "svc.cluster.local" .root.Values.global.kubernetesDomain.name }}:{{ .service.port }}{{ .service.contextPath }}
{{- end -}}
{{- end -}}
