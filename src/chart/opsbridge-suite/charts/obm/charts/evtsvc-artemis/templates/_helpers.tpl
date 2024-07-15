{{- /* Copyright 2020-2023 Open Text */ -}}

{{/* vim: set filetype=mustache: */}}

{{/*
Common labels
*/}}
{{- define "evtsvc-artemis.labels" -}}
app: "{{ .Values.global.evtsvc.namePrefix }}-artemis"
app.kubernetes.io/name: "{{ .Values.global.evtsvc.namePrefix }}-artemis"
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
itom.microfocus.com/capability:  {{ default "event-service" .Values.global.evtsvc.capability | quote }}
itom.microfocus.com/capability-version: {{ (required "missing capability version in .global.evtsvc.version" .Values.global.evtsvc.version) | quote }}
tier.itom.microfocus.com/backend: backend
{{- end -}}

{{- define "evtsvc-artemis.resources" -}}
requests:
  memory: {{ .Values.minMemory }}
  cpu: {{ .Values.minCpu }}
limits:
  memory: {{ .Values.maxMemory }}
  cpu: {{ .Values.maxCpu }}
{{- end -}}
