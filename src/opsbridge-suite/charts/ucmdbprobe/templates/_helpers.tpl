{{/* vim: set filetype=mustache: */}}

{{- define "ucmdbserver.injectGlobalVar" -}}
{{- $globalVarRef := cat "{{ " (cat ".Values.global." .var | nospace) " }}" -}}
{{- $serviceVarRef := cat "{{ " (cat ".Values.deployment." .var | nospace) " }}" -}}
{{- if .isTpl -}}
{{ coalesce (tpl (tpl $serviceVarRef .) .) (tpl (tpl $globalVarRef .) .) }}
{{- else -}}
{{ coalesce (tpl $serviceVarRef .) (tpl $globalVarRef .) }}
{{- end -}}
{{- end -}}