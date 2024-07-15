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
Prometheus ServiceMonitor Labels
*/}}
{{- define "servicemonitor.labels" -}}
{{- toYaml .Values.global.prometheus.prometheusSelector }}
app.kubernetes.io/managed-by: {{.Release.Name}}
app.kubernetes.io/version: {{.Chart.Version}}
itom.microfocus.com/capability: itom-data-ingestion
tier.itom.microfocus.com/backend: backend
{{- end }}

{{/*
Prometheus ServiceMonitor tlsConfig RID
*/}}
{{- define "servicemonitor.tlsConfig.certs.ca" -}}
cert:
  secret:
    name: {{ .Values.global.prometheus.scrapeCertSecretName }}
    key: tls.crt
keySecret:
  name: {{ .Values.global.prometheus.scrapeCertSecretName }}
  key: tls.key
ca:
  configMap:
    name: {{ .Values.global.prometheus.scrapeCaConfigmapName }}
    key: ca.crt
{{- end }}

{{/*
Prometheus ServiceMonitor base relabelings
*/}}
{{- define "servicemonitor.relabelings" -}}
- sourceLabels: [__meta_kubernetes_pod_label_component]
  targetLabel: job
{{- end }}

{{/*
Prometheus ServiceMonitor namespaceSelector
*/}}
{{- define "servicemonitor.namespaceSelector" -}}
namespaceSelector:
  matchNames:
  - {{ .Release.Namespace }}
{{- end }}
