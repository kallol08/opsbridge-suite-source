{{- define "vault.cert" -}}
{{- printf "Common_Name:credential-manager,Additional_SAN:localhost,File_Name:dca-credential-manager" }}
{{- end }}

{{- define "getSecretName" -}}
{{- coalesce .Values.deployment.prometheus.tlsConfig.cert.secret.name .Values.global.prometheus.tlsConfig.cert.secret.name }}
{{- end }}

{{- define "monitoring.cert" -}}
{{- $secretName := (include "getSecretName" .) }}
{{- printf "Common_Name:credential-manager.%s,Secret:%s,UpdateSecret:true,File_Name:credential-manager" .Release.Namespace $secretName }}
{{- end }}

# validateGoTlsCiphers
# Template that takes the default or user provided TLS ciphers from the "helm-lib.getTlsCiphers" and validates that the list contains the ciphers required by GO
{{- define "validateGoTlsCiphers" -}}
  {{- if (eq (include "helm-lib.getTlsMinVersion" (dict "Values" .Values "format" "1")) "VersionTLS12") -}}
    {{- $providedCiphers := (include "helm-lib.getTlsCiphers" (dict "Values" .Values "format" "iana")) -}}
    {{- $splitCiphers := (split "," $providedCiphers) -}}
    {{- $isValid := false -}}
    {{- range $splitCiphers -}}
      {{- if (or (eq . "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256") (eq . "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256")) -}}
        {{- $isValid = true -}}
      {{- end -}}
    {{- end -}}
    {{- if eq $isValid false -}}
      {{- fail "Error: GO requires at least one of the following ciphers: TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256." }}
    {{- end -}}
  {{- end -}}
{{- end -}}
