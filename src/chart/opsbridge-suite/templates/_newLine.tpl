#printNewLine()
#This function is used to print newline.
{{- define "opsb.printNewLine" -}}
{{- println }}
{{- end -}}

{{- define "opsb.getAutopassDB" -}}
{{ $autopassDb := (coalesce .Values.autopass.deployment.database.dbName .Values.global.database.dbName "autopassdb") -}}
{{- printf "%s" $autopassDb -}}
{{- end -}}

{{- define "opsb.getAutopassUser" -}}
{{ $autopassUser := (coalesce .Values.autopass.deployment.database.user .Values.global.database.user "cdfidmuser") -}}
{{- printf "%s" $autopassUser -}}
{{- end -}}

{{- define "opsb.getIDMDB" -}}
{{ $idmDb := (coalesce .Values.idm.deployment.database.dbName .Values.global.database.dbName "cdfidmdb") -}}
{{- printf "%s" $idmDb -}}
{{- end -}}

{{- define "opsb.getIDMUser" -}}
{{ $idmUser := (coalesce .Values.idm.deployment.database.user .Values.global.database.user "cdfidmuser") -}}
{{- printf "%s" $idmUser -}}
{{- end -}}

{{- define "opsb.getBVDDB" -}}
{{ $bvdDb := (coalesce .Values.bvd.deployment.database.dbName .Values.global.database.dbName "bvd") -}}
{{- printf "%s" $bvdDb -}}
{{- end -}}


{{- define "opsb.getBVDUser" -}}
{{ $bvdUser := (coalesce .Values.bvd.deployment.database.user .Values.global.database.user "cdfidmuser") -}}
{{- printf "%s" $bvdUser -}}
{{- end -}}

{{- define "opsb.getAECDB" -}}
{{ $aecDb := (coalesce .Values.aec.deployment.database.dbName .Values.global.database.dbName "aec") -}}
{{- printf "%s" $aecDb -}}
{{- end -}}

{{- define "opsb.getAECUser" -}}
{{ $aecUser := (coalesce .Values.aec.deployment.database.user .Values.global.database.user "aec") -}}
{{- printf "%s" $aecUser -}}
{{- end -}}

{{- define "opsb.getOBMEventDB" -}}
{{ $obmEventDb := (coalesce .Values.obm.deployment.eventDatabase.dbName "obm_event") -}}
{{- printf "%s" $obmEventDb -}}
{{- end -}}

{{- define "opsb.getOBMMgmtDB" -}}
{{ $obmMgmtDb := (coalesce .Values.obm.deployment.mgmtDatabase.dbName "obm_mgmt") -}}
{{- printf "%s" $obmMgmtDb -}}
{{- end -}}

{{- define "opsb.getOBMEventUser" -}}
{{ $obmEventUser := (coalesce .Values.obm.deployment.eventDatabase.user "obm_mgmt") -}}
{{- printf "%s" $obmEventUser -}}
{{- end -}}

{{- define "opsb.getOBMMgmtUser" -}}
{{ $obmMgmtUser := (coalesce .Values.obm.deployment.mgmtDatabase.user "obm_event") -}}
{{- printf "%s" $obmMgmtUser -}}
{{- end -}}

{{- define "opsb.getRtsmDB" -}}
{{ $rtsmDb := (coalesce .Values.ucmdbserver.deployment.database.dbName .Values.global.database.dbName "rtsm") -}}
{{- printf "%s" $rtsmDb -}}
{{- end -}}

{{- define "opsb.getRtsmUser" -}}
{{ $rtsmUser := (coalesce .Values.ucmdbserver.deployment.database.user .Values.global.database.user "rtsm") -}}
{{- printf "%s" $rtsmUser -}}
{{- end -}}

{{- define "opsb.getMonitoringAdminDB" -}}
{{ $monitoringAdminDB := (coalesce .Values.itomopsbridgemonitoringadmin.deployment.database.dbName .Values.global.database.dbName "postgres") -}}
{{- printf "%s" $monitoringAdminDB -}}
{{- end -}}

{{- define "opsb.getMonitoringAdminUser" -}}
{{ $monitoringAdminUser := (coalesce .Values.itomopsbridgemonitoringadmin.deployment.database.user .Values.global.database.user "cdfidmuser") -}}
{{- printf "%s" $monitoringAdminUser -}}
{{- end -}}

{{- define "opsb.getMonitornigSNFDB" -}}
{{ $monitornigSNFDB := (coalesce .Values.itommonitoringsnf.deployment.database.dbName .Values.global.database.dbName "postgres") -}}
{{- printf "%s" $monitornigSNFDB -}}
{{- end -}}

{{- define "opsb.getMonitoringSNFUser" -}}
{{ $monitoringSNFUser := (coalesce .Values.itommonitoringsnf.deployment.database.user .Values.global.database.user "cdfidmuser") -}}
{{- printf "%s" $monitoringSNFUser -}}
{{- end -}}

{{- define "opsb.getCredentialmanagerDB" -}}
{{ $credentialManagerDB := (coalesce .Values.credentialmanager.deployment.database.dbName .Values.global.database.dbName "credentialmanager") -}}
{{- printf "%s" $credentialManagerDB -}}
{{- end -}}

{{- define "opsb.getCredentialmanagerUser" -}}
{{ $credentialManagerUser := (coalesce .Values.credentialmanager.deployment.database.user .Values.global.database.user "credentialmanageruser") -}}
{{- printf "%s" $credentialManagerUser -}}
{{- end -}}

{{- define "opsb.getBtcdDB" -}}
{{ $btcdDB := (coalesce .Values.nommetricstransform.deployment.database.dbName .Values.global.database.dbName "btcd") -}}
{{- printf "%s" $btcdDB -}}
{{- end -}}

{{- define "opsb.getBtcdUser" -}}
{{ $btcdUser := (coalesce .Values.nommetricstransform.deployment.database.user .Values.global.database.user "btcd") -}}
{{- printf "%s" $btcdUser -}}
{{- end -}}

{{- define "opsb.generateVerticaRWPassword" -}}
{{- $secretName:= .Values.global.initSecrets | default "opsbridge-suite-secret" }}
{{- template "helm-lib.getSecretsDefaultsDict" ($dict:= (dict "namespace" .Release.Namespace "name" $secretName "map" .Values.secrets )) }}
{{- if .Release.IsUpgrade }}
{{- $existingPasswordFormat :=  (lookup "v1" "Secret" .Release.Namespace $secretName).data }}
{{- if $existingPasswordFormat }}
{{- if eq $existingPasswordFormat.passwordFormat "YmFzZTY0" }}
{{- $vertica_rw_pwd:= include "helm-lib.validatePassword" (merge (dict "key" "ITOMDI_DBA_PASSWORD_KEY" "special" "!@#^*()_+=[]{}?" "V" false ) $dict) }}
{{- printf "%s" $vertica_rw_pwd -}}
{{- else }}
{{- $vertica_rw_pwd:= include "helm-lib.validatePassword" (merge (dict "key" "ITOMDI_DBA_PASSWORD_KEY" "special" "!@#^*()_+=[]{}?" "V" false ) $dict) |b64enc }}
{{- printf "%s" $vertica_rw_pwd -}}
{{- end }}
{{- else }}
{{- $vertica_rw_pwd:= include "helm-lib.validatePassword" (merge (dict "key" "ITOMDI_DBA_PASSWORD_KEY" "special" "!@#^*()_+=[]{}?" "V" false ) $dict) |b64enc }}
{{- printf "%s" $vertica_rw_pwd -}}
{{- end }}
{{- else }}
{{- $vertica_rw_pwd:= include "helm-lib.validatePassword" (merge (dict "key" "ITOMDI_DBA_PASSWORD_KEY" "special" "!@#^*()_+=[]{}?" "V" false ) $dict) |b64enc }}
{{- printf "%s" $vertica_rw_pwd -}}
{{- end }}
{{- end -}}

{{- define "opsb.generateVerticaROPassword" -}}
{{- $secretName:= .Values.global.initSecrets | default "opsbridge-suite-secret" }}
{{- template "helm-lib.getSecretsDefaultsDict" ($dict:= (dict "namespace" .Release.Namespace "name" $secretName "map" .Values.secrets )) }}
{{- if .Release.IsUpgrade }}
{{- $existingPasswordFormat :=  (lookup "v1" "Secret" .Release.Namespace $secretName).data }}
{{- if $existingPasswordFormat }}
{{- if eq $existingPasswordFormat.passwordFormat "YmFzZTY0" }}
{{- $vertica_ro_pwd:= include "helm-lib.validatePassword" (merge (dict "key" "ITOMDI_RO_USER_PASSWORD_KEY" "special" "!@#^*()_+=[]{}?" "V" false ) $dict) }}
{{- printf "%s" $vertica_ro_pwd -}}
{{- else }}
{{- $vertica_ro_pwd:= include "helm-lib.validatePassword" (merge (dict "key" "ITOMDI_RO_USER_PASSWORD_KEY" "special" "!@#^*()_+=[]{}?" "V" false ) $dict) |b64enc }}
{{- printf "%s" $vertica_ro_pwd -}}
{{- end }}
{{- else }}
{{- $vertica_ro_pwd:= include "helm-lib.validatePassword" (merge (dict "key" "ITOMDI_RO_USER_PASSWORD_KEY" "special" "!@#^*()_+=[]{}?" "V" false ) $dict) |b64enc }}
{{- printf "%s" $vertica_ro_pwd -}}
{{- end }}
{{- else }}
{{- $vertica_ro_pwd:= include "helm-lib.validatePassword" (merge (dict "key" "ITOMDI_RO_USER_PASSWORD_KEY" "special" "!@#^*()_+=[]{}?" "V" false ) $dict) |b64enc }}
{{- printf "%s" $vertica_ro_pwd -}}
{{- end }}
{{- end -}}

{{- define "opsb.generateMonitoringPassword" -}}
{{- $secretName:= .Values.global.initSecrets | default "opsbridge-suite-secret" }}
{{- template "helm-lib.getSecretsDefaultsDict" ($dict:= (dict "namespace" .Release.Namespace "name" $secretName "map" .Values.secrets )) }}
{{- if .Release.IsUpgrade }}
{{- $existingPasswordFormat :=  (lookup "v1" "Secret" .Release.Namespace $secretName).data }}
{{- if $existingPasswordFormat }}
{{- if eq $existingPasswordFormat.passwordFormat "YmFzZTY0" }}
{{- $monitoring_pwd:= include "helm-lib.validatePassword" (merge (dict "key" "ITOMDI_MONITOR_PWD_KEY" "special" "!@#^*()_+=[]{}?" "V" false ) $dict) }}
{{- printf "%s" $monitoring_pwd -}}
{{- else }}
{{- $monitoring_pwd:= include "helm-lib.validatePassword" (merge (dict "key" "ITOMDI_MONITOR_PWD_KEY" "special" "!@#^*()_+=[]{}?" "V" false ) $dict) |b64enc }}
{{- printf "%s" $monitoring_pwd -}}
{{- end }}
{{- else }}
{{- $monitoring_pwd:= include "helm-lib.validatePassword" (merge (dict "key" "ITOMDI_MONITOR_PWD_KEY" "special" "!@#^*()_+=[]{}?" "V" false ) $dict) |b64enc }}
{{- printf "%s" $monitoring_pwd -}}
{{- end }}
{{- else }}
{{- $monitoring_pwd:= include "helm-lib.validatePassword" (merge (dict "key" "ITOMDI_MONITOR_PWD_KEY" "special" "!@#^*()_+=[]{}?" "V" false ) $dict) |b64enc }}
{{- printf "%s" $monitoring_pwd -}}
{{- end }}
{{- end -}}

{{- define "messagebus-external-ca.tlsCertResolve" -}}
{{ $cert := .Values.messagebus.externalCa.tls.cert  }}
{{- if (contains "-----BEGIN" $cert) }}
{{- $newVal := ( replace " " "\n" $cert | replace "\nCERTIFICATE" " CERTIFICATE" ) }}
{{- printf "%s" $newVal | b64enc }}
{{- else }}
{{- printf "%s" $cert }}
{{- end }}
{{- end -}}

{{- define "messagebus-external-ca.tlsKeyResolve" -}}
{{ $key := .Values.messagebus.externalCa.tls.key }}
{{- if (contains "-----BEGIN" $key) }}
{{- $newVal := ( replace " " "\n" $key) | replace "\nRSA"  " RSA" | replace "\nPRIVATE" " PRIVATE" | replace "\nKEY" " KEY" }}
{{- printf "%s" $newVal | b64enc}}
{{- else }}
{{- printf "%s" $key }}
{{- end }}
{{- end -}}

{{- define "itom-nginx-ingress-controller.tlsCert" -}}
{{ $cert := (coalesce (index .Values "itom-ingress-controller" "nginx" "tls" "cert") .Values.global.tls.cert) }}
{{- if (contains "-----BEGIN" $cert) }}
{{- $newVal := ( replace " " "\n" $cert | replace "\nCERTIFICATE" " CERTIFICATE" ) }}
{{- printf "%s" $newVal | b64enc }}
{{- else }}
{{- printf "%s" $cert }}
{{- end }}
{{- end -}}

{{- define "itom-nginx-ingress-controller.tlsKey" -}}
{{ $key := (coalesce (index .Values "itom-ingress-controller" "nginx" "tls" "key") .Values.global.tls.key) }}
{{- if (contains "-----BEGIN" $key) }}
{{- $newVal := ( replace " " "\n" $key) | replace "\nRSA"  " RSA" | replace "\nPRIVATE" " PRIVATE" | replace "\nKEY" " KEY" }}
{{- printf "%s" $newVal | b64enc}}
{{- else }}
{{- printf "%s" $key }}
{{- end }}
{{- end -}}


