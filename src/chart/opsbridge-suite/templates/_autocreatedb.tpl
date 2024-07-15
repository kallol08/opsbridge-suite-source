{{/* #These functions are used by the autocreate database job */}}

{{- define "opsb.getPostgresAdminUser" -}}
{{ $postgresAdminUser := (coalesce .Values.global.database.admin "postgres") -}}
{{- printf "%s" $postgresAdminUser -}}
{{- end -}}

{{- define "opsb.getIdmPasswordKey" -}}
{{- if .Values.secrets.IDM_DB_USER_PASSWORD_KEY }}
{{- $idmPassword := .Values.secrets.IDM_DB_USER_PASSWORD_KEY |b64dec -}}
{{- printf "%s" $idmPassword -}}
{{- end -}}
{{- end -}}

{{- define "opsb.getBvdPasswordKey" -}}
{{- if .Values.secrets.BVD_DB_USER_PASSWORD_KEY }}
{{- $bvdPassword := .Values.secrets.BVD_DB_USER_PASSWORD_KEY |b64dec -}}
{{- printf "%s" $bvdPassword -}}
{{- end -}}
{{- end -}}

{{- define "opsb.getAecPasswordKey" -}}
{{- if .Values.secrets.AEC_DB_USER_PASSWORD_KEY }}
{{- $aecPassword := .Values.secrets.AEC_DB_USER_PASSWORD_KEY |b64dec -}}
{{- printf "%s" $aecPassword -}}
{{- end -}}
{{- end -}}

{{- define "opsb.getAutopassPasswordKey" -}}
{{- if .Values.secrets.AUTOPASS_DB_USER_PASSWORD_KEY }}
{{- $autopassPassword := .Values.secrets.AUTOPASS_DB_USER_PASSWORD_KEY |b64dec -}}
{{- printf "%s" $autopassPassword -}}
{{- end -}}
{{- end -}}

{{- define "opsb.getObmEventPasswordKey" -}}
{{- if .Values.secrets.OBM_EVENT_DB_USER_PASSWORD_KEY }}
{{- $obmEventPassword := .Values.secrets.OBM_EVENT_DB_USER_PASSWORD_KEY |b64dec -}}
{{- printf "%s" $obmEventPassword -}}
{{- end -}}
{{- end -}}

{{- define "opsb.getObmMgmtPasswordKey" -}}
{{- if .Values.secrets.OBM_MGMT_DB_USER_PASSWORD_KEY }}
{{- $obmMgmtPassword := .Values.secrets.OBM_MGMT_DB_USER_PASSWORD_KEY |b64dec -}}
{{- printf "%s" $obmMgmtPassword -}}
{{- end -}}
{{- end -}}

{{- define "opsb.getRtsmPasswordKey" -}}
{{- if .Values.secrets.RTSM_DB_USER_PASSWORD_KEY }}
{{- $rtsmPassword := .Values.secrets.RTSM_DB_USER_PASSWORD_KEY |b64dec -}}
{{- printf "%s" $rtsmPassword -}}
{{- end -}}
{{- end -}}

{{- define "opsb.getMonitoringAdminPasswordKey" -}}
{{- if .Values.secrets.MA_DB_USER_PASSWORD_KEY }}
{{- $maPassword := .Values.secrets.MA_DB_USER_PASSWORD_KEY |b64dec -}}
{{- printf "%s" $maPassword -}}
{{- end -}}
{{- end -}}

{{- define "opsb.getMonitoringSNFPasswordKey" -}}
{{- if .Values.secrets.SNF_DB_USER_PASSWORD_KEY }}
{{- $snfPassword := .Values.secrets.SNF_DB_USER_PASSWORD_KEY |b64dec -}}
{{- printf "%s" $snfPassword -}}
{{- end -}}
{{- end -}}

{{- define "opsb.getCredentialmanagerPasswordKey" -}}
{{- if .Values.secrets.CM_DB_PASSWD_KEY }}
{{- $cmPassword := .Values.secrets.CM_DB_PASSWD_KEY |b64dec -}}
{{- printf "%s" $cmPassword -}}
{{- end -}}
{{- end -}}

{{- define "opsb.getBtcdPasswordKey" -}}
{{- if .Values.secrets.BTCD_DB_PASSWD_KEY }}
{{- $btcdPassword := .Values.secrets.BTCD_DB_PASSWD_KEY |b64dec -}}
{{- printf "%s" $btcdPassword -}}
{{- end -}}
{{- end -}}
