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
{{/*
Define the pulsar brroker service
*/}}
{{- define "pulsar.broker.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}
{{- end }}

{{/*
Define the service url
*/}}
{{- define "pulsar.broker.service.url" -}}
{{- if and .Values.tls.enabled .Values.tls.broker.enabled -}}
pulsar+ssl://{{ template "pulsar.broker.service" . }}.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.broker.ports.pulsarssl }}
{{- else -}}
pulsar://{{ template "pulsar.broker.service" . }}.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.broker.ports.pulsar }}
{{- end -}}
{{- end -}}

{{/*
Define the web service url
*/}}
{{- define "pulsar.web.service.url" -}}
{{- if and .Values.tls.enabled .Values.tls.broker.enabled -}}
https://{{ template "pulsar.broker.service" . }}.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.broker.ports.https }}
{{- else -}}
http://{{ template "pulsar.broker.service" . }}.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.broker.ports.http }}
{{- end -}}
{{- end -}}

{{/*
Define the hostname
*/}}
{{- define "pulsar.broker.hostname" -}}
${HOSTNAME}.{{ template "pulsar.broker.service" . }}.{{ .Release.Namespace }}.svc.cluster.local
{{- end -}}

{{/*
Define the broker znode
*/}}
{{- define "pulsar.broker.znode" -}}
{{ .Values.metadataPrefix }}/loadbalance/brokers/{{ template "pulsar.broker.hostname" . }}:{{ .Values.broker.ports.http }}
{{- end }}

{{/* 
Broker managedLedgerDefaultEnsembleSize is 1 if demo mode is enable. Else we default it to the value in values.yaml file.
*/}}
{{- define "pulsar.broker.managedLedgerDefaultEnsembleSize" -}}
{{- if eq (.Values.bookkeeper.replicaCount | int) 1 }}1{{- else }}{{ .Values.broker.configData.managedLedgerDefaultEnsembleSize }}{{- end -}}
{{- end -}}

{{/*
Define broker zookeeper client tls settings
*/}}
{{- define "pulsar.broker.zookeeper.tls.settings" -}}
{{- if and .Values.tls.enabled (or .Values.tls.zookeeper.enabled (and .Values.tls.broker.enabled .Values.components.kop)) }}
/pulsar/keytool/keytool.sh broker {{ template "pulsar.broker.hostname" . }} true;
{{- end }}
{{- end }}

{{/*
Define broker kop settings
*/}}
{{- define "pulsar.broker.kop.settings" -}}
{{- if .Values.components.kop }}
{{- if and .Values.tls.enabled .Values.tls.broker.enabled }}
export PULSAR_PREFIX_listeners="SSL://{{ template "pulsar.broker.hostname" . }}:{{ .Values.kop.ports.ssl }}";
{{- else }}
export PULSAR_PREFIX_listeners="PLAINTEXT://{{ template "pulsar.broker.hostname" . }}:{{ .Values.kop.ports.plaintext }}";
{{- end }}
{{- end }}
{{- end }}

{{/*
Define broker tls certs mounts
*/}}
{{- define "pulsar.broker.certs.volumeMounts" -}}
{{- if and .Values.tls.enabled (or .Values.tls.broker.enabled (or .Values.tls.bookie.enabled .Values.tls.zookeeper.enabled)) }}
{{- if or .Values.tls.zookeeper.enabled .Values.components.kop }}
- name: keytool
  mountPath: "/pulsar/keytool/keytool.sh"
  subPath: keytool.sh
{{- end }}
{{- end }}
{{- end }}

{{/*
Define broker tls certs volumes
*/}}
{{- define "pulsar.broker.certs.volumes" -}}
{{- if and .Values.tls.enabled (or .Values.tls.broker.enabled (or .Values.tls.bookie.enabled .Values.tls.zookeeper.enabled)) }}
{{- if or .Values.tls.zookeeper.enabled .Values.components.kop }}
- name: keytool
  configMap:
    name: "{{ template "pulsar.fullname" . }}-keytool-configmap"
    defaultMode: 0755
{{- end }}
{{- end }}
{{- end }}

{{/*
Define broker token mounts
*/}}
{{- define "pulsar.broker.token.volumeMounts" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
{{- if not .Values.auth.vault.enabled }}
- mountPath: "/pulsar/keys"
  name: token-keys
  readOnly: true
{{- end }}
- mountPath: "/pulsar/tokens"
  name: broker-token
  readOnly: true
{{- end }}
{{- end }}
{{- end }}

{{/*
Define broker token volumes
*/}}
{{- define "pulsar.broker.token.volumes" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
{{- if not .Values.auth.vault.enabled }}
- name: token-keys
  secret:
    {{- if not .Values.auth.authentication.jwt.usingSecretKey }}
    secretName: "{{ .Release.Name }}-token-asymmetric-key"
    {{- end}}
    {{- if .Values.auth.authentication.jwt.usingSecretKey }}
    secretName: "{{ .Release.Name }}-token-symmetric-key"
    {{- end}}
    items:
      {{- if .Values.auth.authentication.jwt.usingSecretKey }}
      - key: SECRETKEY
        path: token/secret.key
      {{- else }}
      - key: PUBLICKEY
        path: token/public.key
      - key: PRIVATEKEY
        path: token/private.key
      {{- end}}
{{- end }}
- name: broker-token
  secret:
    secretName: "{{ .Release.Name }}-token-{{ .Values.auth.superUsers.broker }}"
    items:
      - key: TOKEN
        path: broker/token
{{- end }}
{{- end }}
{{- end }}


{{/*
Define broker log mounts
*/}}
{{- define "pulsar.broker.log.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}-log4j2"
  mountPath: "{{ template "pulsar.home" .}}/conf/log4j2.yaml"
  subPath: log4j2.yaml
{{- end }}

{{/*
Define broker log volumes
*/}}
{{- define "pulsar.broker.log.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}-log4j2"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}"
{{- end }}

{{/*
Define function worker config volume mount
*/}}
{{- define "pulsar.function.worker.config.volumeMounts" -}}
{{- if .Values.components.functions }}
- name: "function-worker-config"
  mountPath: "{{ template "pulsar.home" . }}/conf/functions_worker.yml"
  subPath: functions_worker.yml
{{- end }}
{{- end }}

{{/*
Define function worker config volume
*/}}
{{- define "pulsar.function.worker.config.volumes" -}}
{{- if .Values.components.functions }}
- name: "function-worker-config"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.functions.component }}-configfile"
{{- end }}
{{- end }}

{{/*
Define custom runtime options mounts
*/}}
{{- define "pulsar.broker.runtime.volumeMounts" -}}
{{- end }}

{{/*
Define broker runtime volumes
*/}}
{{- define "pulsar.broker.runtime.volumes" -}}
{{- end }}

{{/*
Define gcs offload options mounts
*/}}
{{- define "pulsar.broker.offload.volumeMounts" -}}
{{- if .Values.broker.offload.gcs.enabled }}
- name: gcs-offloader-service-acccount
  mountPath: /pulsar/srvaccts
  readOnly: true
{{- end }}
{{- end }}

{{/*
Define gcs offload options mounts
*/}}
{{- define "pulsar.broker.offload.volumes" -}}
{{- if .Values.broker.offload.gcs.enabled }}
- name: gcs-offloader-service-acccount
  secret:
    secretName: "{{ .Release.Name }}-gcs-offloader-service-account"
    items:
      - key: gcs.json
        path: gcs.json
{{- end }}
{{- end }}

{{/*
Define Broker probe
*/}}
{{- define "pulsar.broker.probe" -}}
httpGet:
  path: /status.html
  {{- if and .Values.tls.enabled .Values.tls.broker.enabled }}
  port: {{ .Values.broker.ports.https }}
  scheme: HTTPS
  {{- else}}
  port: {{ .Values.broker.ports.http }}
  scheme: HTTP
  {{- end}}
{{- end }}

{{/*
 auth superusers broker
*/}}
{{- define "auth.superusers.broker" -}}
{{ if eq (.Values.auth.authorization.enabled | toString) "true" }}
  {{- if (((.Values.auth).superUsers).broker) -}}
    {{- printf "%s" .Values.auth.superUsers.broker -}}
  {{- else -}}
    {{- print "" -}}
  {{- end -}}
{{- else -}}
  {{- if ((.Values.global).externalAccessHost) -}}
    {{- if (not (empty .Values.global.externalAccessHost)) -}}
      {{- printf "%s" .Values.global.externalAccessHost  -}}
    {{- else -}}
      {{- print "Required value is not defined for global.externalAccessHost" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end }}