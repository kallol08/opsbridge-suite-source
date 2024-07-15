
{{- define "restrict.isClient" -}}
	{{- if (eq ((.Values.global.services.opticDataLake).deploy | toString) "false") }}
	  {{- printf "%s" "true" -}}
	{{- else }}
	  {{- printf "%s" "false" -}}
	{{- end }}
{{- end }}

{{- define "restrict.getSharedIdmUser" -}}
{{ $sharedidmuser := (coalesce .Values.global.services.opticDataLake.externalOpticDataLake.integrationUser .Values.global.idm.integrationUser) -}}
{{- printf "%s" $sharedidmuser -}}
{{- end -}}

{{- define "restrict.getSharedIdmKey" -}}
{{ $sharedidmkey := (coalesce .Values.global.services.opticDataLake.externalOpticDataLake.integrationPasswordKey .Values.global.idm.integrationUserKey) -}}
{{- printf "%s" $sharedidmkey -}}
{{- end -}}

