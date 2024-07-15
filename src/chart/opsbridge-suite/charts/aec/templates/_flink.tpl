{{/* Memory request and limits for task manager */}}
{{ define "aec.flinkTaskManagerMemory" }}
{{- if .Values.deployment.flinkPipeline.taskManagerResources.memory }}
{{ .Prefix }}: "{{ .Values.deployment.flinkPipeline.taskManagerResources.memory }}{{ .Unit }}"
{{- else if eq .Values.global.deployment.size "large"  }}
{{ .Prefix }}: "2000{{ .Unit }}"
{{- else if eq .Values.global.deployment.size "extra-large" }}
{{ .Prefix }}: "2500{{ .Unit }}"
{{- else }}
{{ .Prefix }}: "1500{{ .Unit }}"
{{- end }}
{{- end }}
