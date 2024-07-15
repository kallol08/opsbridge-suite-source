{{/* vim: set filetype=mustache: */}}

{{/*
Common labels
*/}}
{{- define "chart.labels" -}}
app: {{ .Chart.Name }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
tier.itom.microfocus.com/backend: backend
{{- end -}}
