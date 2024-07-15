{{/* External certificate volume definition */}}
{{ define "aec.defineExternalPulsarCertVolume" }}
{{- if .Values.global.di.pulsar }}
{{- if .Values.global.di.pulsar.client }}
{{- if .Values.global.di.pulsar.client.tenantAdminSecret }}
- name: pulsar-client-cert-secret-volume
  projected:
    sources:
      - secret:
          name: {{ .Values.global.di.pulsar.client.tenantAdminSecret | quote}}
{{ end }}
{{ end }}
{{ end }}
{{ end }}

{{ define "aec.useExternalPulsarCertVolume" }}
{{- if .Values.global.di.pulsar }}
{{- if .Values.global.di.pulsar.client }}
{{- if .Values.global.di.pulsar.client.tenantAdminSecret }}
- name: pulsar-client-cert-secret-volume
  mountPath: /var/run/secrets/shared-pulsar
{{ end }}
{{ end }}
{{ end }}
{{ end }}

{{ define "aec.setExternalPulsarCertEnv" }}
{{- if .Values.global.di.pulsar }}
{{- if .Values.global.di.pulsar.client }}
{{- if .Values.global.di.pulsar.client.tenantAdminSecret }}
- name: "PULSAR_TLS_KEY_FILE"
  valueFrom:
    configMapKeyRef:
      name: itom-analytics-config
      key: tls.pulsar-key-file
- name: "PULSAR_TLS_CERT_FILE"
  valueFrom:
    configMapKeyRef:
      name: itom-analytics-config
      key: tls.pulsar-cert-file
{{ end }}
{{ end }}
{{ end }}
{{ end }}
