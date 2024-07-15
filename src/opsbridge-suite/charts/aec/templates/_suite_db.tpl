{{/* Oracle connection string for JDBC */}}
{{ define "aec.oracleConnectionStringJDBC" }}
{{- if .Values.global.database.oracleConnectionString }}
{{- include "helm-lib.dbUrl" . }}
{{- else }}
{{- $protocol := ternary "TCPS" "TCP" (and (hasKey .Values.global.database "tlsEnabled") .Values.global.database.tlsEnabled) }}
{{- printf "jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=%s)(HOST=%s)(PORT=%s))(CONNECT_DATA=(SID=%s)))" $protocol (include "helm-lib.dbHost" .) (include "helm-lib.dbPort" .) (include "helm-lib.dbOracleSid" .) }}
{{- end }}
{{- end }}

{{/* PostgreSQL connection string for JDBC */}}
{{ define "aec.postgresConnectionStringJDBC" }}
{{- $sslMode := ternary "verify-full" "disable" (and (hasKey .Values.global.database "tlsEnabled") .Values.global.database.tlsEnabled) }}
{{- printf "jdbc:postgresql://%s:%s/%s?sslmode=%s" (include "helm-lib.dbHost" .) (include "helm-lib.dbPort" .) (include "helm-lib.dbName" .) $sslMode }}
{{- end }}

{{- define "aec.backgroundResourcepool" -}}
{{- if .Values.deployment.vertica.aecBackgroundResourcepool -}}
  {{- .Values.deployment.vertica.aecBackgroundResourcepool -}}
{{- else -}}
  itom_di_aecbackground_respool_
    {{- if hasKey .Values.global.di "tenant" -}}
      {{- .Values.global.di.tenant -}}
    {{- else -}}
      provider
    {{- end -}}
  _{{ .Values.global.di.deployment }}
{{- end -}}
{{- end -}}

{{- define "aec.interactiveResourcepool" -}}
{{- if .Values.deployment.vertica.aecInteractiveResourcepool -}}
  {{- .Values.deployment.vertica.aecInteractiveResourcepool -}}
{{- else -}}
  itom_di_rouser_respool_
    {{- if hasKey .Values.global.di "tenant" -}}
      {{- .Values.global.di.tenant -}}
    {{- else -}}
      provider
    {{- end -}}
  _{{ .Values.global.di.deployment }}
{{- end -}}
{{- end -}}
