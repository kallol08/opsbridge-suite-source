{{/* vim: set filetype=mustache: */}}

{{/*
Prometheus ServiceMonitor Labels
*/}}
{{- define "servicemonitor.labels" -}}
{{- toYaml .Values.global.prometheus.prometheusSelector }}
{{- end }}



{{/*
Prometheus ServiceMonitor base relabelings
*/}}
{{- define "servicemonitor.relabelings" -}}
- sourceLabels: [__meta_kubernetes_pod_label_component]
  targetLabel: job
- sourceLabels: [__meta_kubernetes_pod_name]
  targetLabel: kubernetes_pod_name
- action: labelmap
  regex: __meta_kubernetes_pod_label_(.+)
{{- end }}

{{/*
Prometheus ServiceMonitor namespaceSelector
*/}}
{{- define "servicemonitor.namespaceSelector" -}}
namespaceSelector:
  matchNames:
  - {{ .Release.Namespace }}
{{- end }}
