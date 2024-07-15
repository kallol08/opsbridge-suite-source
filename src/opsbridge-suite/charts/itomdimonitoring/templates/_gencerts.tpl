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
gen-certs Kubernetes Job spec
*/}}
{{- define "gencerts.job.spec" -}}
spec:
  ttlSecondsAfterFinished: 1200
  template:
    metadata:
      annotations:
        {{- if .Values.global.vaultAppRole }}
        pod.boostport.com/vault-approle: {{ .Release.Namespace }}-{{ .Values.global.vaultAppRole }}
        {{- else }}
        pod.boostport.com/vault-approle: {{ .Release.Namespace }}-default
        {{- end }}
        pod.boostport.com/vault-init-container: install
      labels:
        app.kubernetes.io/name: "{{ template "monitoring.fullname" . }}-{{ .Values.monitoring.gencerts.component }}"
        {{- include "monitoring.standardLabels" . | nindent 8 }}
    spec:
      restartPolicy: OnFailure
      serviceAccount: {{ template "monitoring.fullname" . }}-{{ .Values.monitoring.gencerts.component }}-sa
      serviceAccountName: {{ template "monitoring.fullname" . }}-{{ .Values.monitoring.gencerts.component }}-sa
      securityContext:
        runAsNonRoot: true
        runAsUser: {{ .Values.global.securityContext.user }}
        runAsGroup: {{ .Values.global.securityContext.fsGroup }}        
        seccompProfile:
          type: RuntimeDefault        
      initContainers:
      {{- $monname := (include "monitoring.fullname" .) }}
      {{- $gencertcompname := (include "gencert.component.name" .) }}
      {{- $certNames := printf "%s-%s" $monname $gencertcompname -}}
      {{- include "helm-lib.containers.vaultInit" (dict "certNames" $certNames "Values" .Values) | nindent 6 }}
      containers:
      - name: {{ template "monitoring.fullname" . }}-{{ .Values.monitoring.gencerts.component }}
        securityContext:       
          allowPrivilegeEscalation: false        
          capabilities:
            drop:
            - ALL
      {{- if and .Values.monitoring.gencerts.registry .Values.monitoring.gencerts.orgName }}
        image: {{ .Values.monitoring.gencerts.registry }}/{{ .Values.monitoring.gencerts.orgName }}/{{ .Values.monitoring.gencerts.image }}:{{ .Values.monitoring.gencerts.imageTag }}
      {{- else }}
        image: {{ .Values.global.docker.registry }}/{{ .Values.global.docker.orgName }}/{{ .Values.monitoring.gencerts.image }}:{{ .Values.monitoring.gencerts.imageTag }}
      {{- end }}
        imagePullPolicy: {{ .Values.global.docker.imagePullPolicy }}
        env:
        - name: TLS_CERT_FILE_PATH
          value: "/var/run/secrets/boostport.com/server.crt"
        - name: TLS_KEY_FILE_PATH
          value: "/var/run/secrets/boostport.com/server.key"
        - name: TLS_TRUST_FILE_PATH
          value: "/var/run/secrets/boostport.com/server-ca.crt"
        - name: NAMESPACE
          value: {{ .Release.Namespace }}
        - name: SECRET_NAME
          value: {{ .Values.global.prometheus.scrapeCertSecretName }}
        - name: CONFIGMAP_NAME
          value: "monitoring-ca-certificates"
        - name: GENCERTS_MODE
          value: {{ .gencertsMode }}
        resources:
          {{- include "monitoring.initContainers.resources" . | nindent 10 }}
        volumeMounts:
        - name: vault-token
          readOnly: true
          mountPath: /var/run/secrets/boostport.com
      volumes:
      - name: vault-token
        emptyDir: {}
        {{- $_ := unset . "gencertsMode" }}
{{- end -}}
