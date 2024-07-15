{{ define "aec.cacertBundler" }}
- name: cacert-bundler
  image: {{ .Values.global.docker.registry }}/{{ .Values.global.docker.orgName }}/{{ .Values.aecImages.cacertBundler.image }}:{{ .Values.aecImages.cacertBundler.imageTag }}
  resources:
    limits:
      cpu: "100m"
      memory: "50Mi"
    requests:
      cpu: "5m"
      memory: "5Mi"
  env:
  - name: "OUTPUT_PATH"
    value: "{{ .Values.cacerts.folder }}/{{ .Values.cacerts.file }}"
  - name: "CACERTS"
    value: /var/run/secrets/boostport.com/issue_ca.crt{{ if (hasKey .Values.global "tlsTruststore") }}:{{ .Values.externalCerts.path }}{{ end }}
  volumeMounts:
  - name: "vault-token"
    mountPath: /var/run/secrets/boostport.com
{{- if (hasKey .Values.global "tlsTruststore") }}
  - name: {{ .Values.externalCerts.volumeName }}
    mountPath: {{ .Values.externalCerts.path }}
{{- end }}
  - name: {{ .Values.cacerts.volumeName }}
    mountPath: {{ .Values.cacerts.folder }}
{{ end }}

{{ define "aec.waitForPulsar" }}
- name: wait-for-pulsar
  image: {{ coalesce .Values.aecImages.aecInitializer.dockerRegistry .Values.docker.registry .Values.global.docker.registry -}}
  / {{- coalesce .Values.aecImages.aecInitializer.orgName .Values.docker.orgName .Values.global.docker.orgName -}}
  / {{- .Values.aecImages.aecInitializer.image -}}
  : {{- .Values.aecImages.aecInitializer.imageTag }}
  imagePullPolicy: {{ .Values.global.docker.imagePullPolicy }}
  resources:
    limits:
      cpu: "100m"
      memory: "50Mi"
    requests:
      cpu: "5m"
      memory: "5Mi"
  command:
  - /scripts/wait-for-pulsar-topics.sh
  securityContext:
    allowPrivilegeEscalation: false
  env:
    - name: PULSAR_HOST
      value: {{ include "helm-lib.getDiPulsarProxyHost" . | default "itomdipulsar-proxy" }}
    - name: PULSAR_ADMIN_PORT
      value: {{ include "helm-lib.getDiPulsarProxyWebPort" . | default "8443" | quote }}
    - name: PULSAR_TENANT
      value: {{ ((.Values.global.di).pulsar).tenant | default "public" }}
    - name: PULSAR_NAMESPACE
      value: {{ ((.Values.global.di).pulsar).namespace | default "default" }}
{{ include "aec.setExternalPulsarCertEnv" . | indent 4 }}
  volumeMounts:
{{- if (hasKey .Values.global "tlsTruststore") }}
    - name: {{ .Values.externalCerts.volumeName }}
      mountPath: /service/conf/additionalCAs
      readOnly: true
{{- end }}
{{ include "aec.useExternalPulsarCertVolume" . | indent 4 }}
    - name: vault-token
      mountPath: /var/run/secrets/boostport.com
{{ end }}

{{ define "aec.waitForResourcePools" }}
- name: wait-for-resource-pools
  image: {{ coalesce .Values.aecImages.aecInitializer.dockerRegistry .Values.docker.registry .Values.global.docker.registry -}}
  / {{- coalesce .Values.aecImages.aecInitializer.orgName .Values.docker.orgName .Values.global.docker.orgName -}}
  / {{- .Values.aecImages.aecInitializer.image -}}
  : {{- .Values.aecImages.aecInitializer.imageTag }}
  imagePullPolicy: {{ .Values.global.docker.imagePullPolicy }}
  resources:
    limits:
      cpu: "100m"
      memory: "60Mi"
    requests:
      cpu: "5m"
      memory: "5Mi"
  command:
    - /home/main
    - waitForResourcePools
  securityContext:
    allowPrivilegeEscalation: false
  env:
  - name: "IS_VERTICA_EMBEDDED"
    value: "{{ .Values.global.vertica.embedded }}"
  - name: "EXTERNAL_VERTICA_HOSTNAMES"
    value: {{ .Values.global.vertica.host }}
  - name: "EXTERNAL_VERTICA_PORT"
    value: "{{ .Values.global.vertica.port }}"
  - name: "EXTERNAL_VERTICA_DB"
    value: {{ .Values.global.vertica.db }}
  - name: "EXTERNAL_VERTICA_USERNAME"
    value: {{ .Values.global.vertica.rwuser }}
  - name: "EXTERNAL_VERTICA_PASS_KEY"
    value: {{ .Values.global.vertica.rwuserkey }}
  - name: "EXTERNAL_VERTICA_TLS_MODE"
    value: "{{ .Values.global.vertica.tlsEnabled }}"
  - name: "EXTERNAL_VERTICA_CACERT_PATH"
    value: {{ .Values.cacerts.folder }}/{{ .Values.cacerts.file }}
  - name: "AEC_BACKGROUND_POOL"
    value: {{ include "aec.backgroundResourcepool" . | quote }}
  - name: "AEC_INTERACTIVE_POOL"
    value: {{ include "aec.interactiveResourcepool" . | quote }}
  volumeMounts:
  - name: vault-token
    mountPath: /var/run/secrets/boostport.com
{{- if (hasKey .Values.global "tlsTruststore") }}
  - name: {{ .Values.externalCerts.volumeName }}
    mountPath: /service/conf/vertica
    readOnly: true
{{- end }}
  - name: {{ .Values.cacerts.volumeName }}
    mountPath: {{ .Values.cacerts.folder }}
{{ end }}

{{ define "aec.externalCertsVolume" }}
{{- if (hasKey .Values.global "tlsTruststore") }}
- name: {{ .Values.externalCerts.volumeName }}
  configMap:
    name: {{ .Values.global.tlsTruststore }}
    optional: true
{{- end }}
{{- end }}
