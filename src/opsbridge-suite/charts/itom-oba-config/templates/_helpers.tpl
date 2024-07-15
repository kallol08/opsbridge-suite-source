{{/*
Expand the name of the chart.
*/}}
{{- define "itom-oba-config.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "itom-oba-config.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "itom-oba-config.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "itom-oba-config.labels" -}}
helm.sh/chart: {{ include "itom-oba-config.chart" . }}
{{ include "itom-oba-config.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "itom-oba-config.selectorLabels" -}}
app.kubernetes.io/name: {{ include "itom-oba-config.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "itom-oba-config.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "itom-oba-config.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define vault volume
*/}}
{{- define "itom-oba-config.vault.volume" -}}
- name: vault-token
  emptyDir: {}
{{- end }}

{{/*
Define vault mount
*/}}
{{- define "itom-oba-config.vault.volumeMount" -}}
- name: vault-token
  mountPath: /var/run/secrets/boostport.com
{{- end }}

{{/*
Define external certs volumes
*/}}
{{- define "itom-oba-config.externalcert.volumes" -}}
{{- if (hasKey .Values.global "tlsTruststore") }}
- name: cert-storage
  configMap:
    name: {{ .Values.global.tlsTruststore }}
    optional: true
{{- end }}
{{- if .Values.global.apiClient.authorizedClientCAs }}
- name: client-cert-storage
  configMap:
    name: {{ .Values.global.apiClient.authorizedClientCAs }}
{{- end }}
{{- end }}

{{/*
Define external certs volumes mounts
*/}}
{{- define "itom-oba-config.externalcert.volumesMounts" -}}
{{- if (hasKey .Values.global "tlsTruststore") }}
- name: cert-storage
  mountPath: /service/conf/certificates
  readOnly: true
{{- end }}
- name: client-cert-storage
  mountPath: "/service/conf/client-certificates"
  readOnly: true
{{- end }}
