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
pulsar service domain
*/}}
{{- define "pulsar.service_domain" -}}
        {{- if or (eq (lower (((((.Values.global).di).externalDNS).enabled)| toString)) "true") (eq (lower ((((((.Values.global).di).cloud).externalDNS).enabled)| toString)) "true") -}}
                {{- if (not (empty ((((.Values.global).di).externalAccessHost).pulsar))) -}}
                        {{- printf "external-dns.alpha.kubernetes.io/hostname: \"%s\"" .Values.global.di.externalAccessHost.pulsar -}}
                {{- else if (not (empty (((((.Values.global).di).cloud).externalAccessHost).pulsar))) -}}
                        {{- printf "external-dns.alpha.kubernetes.io/hostname: \"%s\"" .Values.global.di.cloud.externalAccessHost.pulsar -}}
                {{- else -}}
                        {{- print "" -}}
                {{- end -}}
        {{- else -}}
                {{- print "" -}}
        {{- end -}}
{{- end }}

{{/*
pulsar cloud externalAccessHost
*/}}
{{- define "pulsar.di.externalAccessHost" -}}
    {{- if (not (empty .Values.global.di.cloud.externalAccessHost.pulsar)) -}}
        {{- printf "/%s" .Values.global.di.cloud.externalAccessHost.pulsar  -}}
    {{- else -}}
            {{- print "" -}}
    {{- end -}}
    {{- if (not (empty .Values.global.di.externalAccessHost.pulsar)) -}}
        {{- printf "/%s" .Values.global.di.externalAccessHost.pulsar  -}}
    {{- else -}}
            {{- print "" -}}
    {{- end -}}
{{- end }}

{{/*
pulsar proxy service type
*/}}
{{- define "pulsar.proxy_service_type" -}}

    {{- if eq (include  "helm-lib.service.getServiceType" . ) "LoadBalancer" -}}
			{{- print "LoadBalancer" -}}
	{{- else -}}
		{{- if .Values.ingress.proxy.enabled -}}
			{{- print "NodePort" -}}
		{{- else -}}
			{{- printf "%s" .Values.proxy.service.type -}}
		{{- end -}}
	{{- end -}}
{{- end -}}

{{/*
Define proxy token mounts
*/}}
{{- define "pulsar.proxy.token.volumeMounts" -}}
{{- if .Values.auth.authentication.enabled }}
{{- if eq .Values.auth.authentication.provider "jwt" }}
{{- if not .Values.auth.vault.enabled }}
- mountPath: "/pulsar/keys"
  name: token-keys
  readOnly: true
{{- end }}
- mountPath: "/pulsar/tokens"
  name: proxy-token
  readOnly: true
{{- end }}
{{- end }}
{{- end }}

{{/*
Define proxy token volumes
*/}}
{{- define "pulsar.proxy.token.volumes" -}}
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
      {{- end}}
{{- end }}
- name: proxy-token
  secret:
    secretName: "{{ .Release.Name }}-token-{{ .Values.auth.superUsers.proxy }}"
    items:
      - key: TOKEN
        path: proxy/token
{{- end }}
{{- end }}
{{- end }}

{{/*
Define proxy tls certs mounts
*/}}
{{- define "pulsar.proxy.certs.volumeMounts" -}}
{{- if and .Values.tls.enabled (or .Values.tls.proxy.enabled (or .Values.tls.bookie.enabled .Values.tls.zookeeper.enabled)) }}
{{- if or .Values.tls.zookeeper.enabled .Values.components.kop }}
- name: keytool
  mountPath: "/pulsar/keytool/keytool.sh"
  subPath: keytool.sh
{{- end }}
{{- end }}
{{- end }}

{{/*
Define proxy tls certs volumes
*/}}
{{- define "pulsar.proxy.certs.volumes" -}}
{{- if and .Values.tls.enabled (or .Values.tls.proxy.enabled (or .Values.tls.bookie.enabled .Values.tls.zookeeper.enabled)) }}
{{- if or .Values.tls.zookeeper.enabled .Values.components.kop }}
- name: keytool
  configMap:
    name: "{{ template "pulsar.fullname" . }}-keytool-configmap"
    defaultMode: 0755
{{- end }}
{{- end }}
{{- end }}

{{/*
Define proxy log mounts
*/}}
{{- define "pulsar.proxy.log.volumeMounts" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}-log4j2"
  mountPath: "{{ template "pulsar.home" . }}/conf/log4j2.yaml"
  subPath: log4j2.yaml
{{- end }}

{{/*
Define proxy log volumes
*/}}
{{- define "pulsar.proxy.log.volumes" -}}
- name: "{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}-log4j2"
  configMap:
    name: "{{ template "pulsar.fullname" . }}-{{ .Values.proxy.component }}"
{{- end }}
{{/*


{{/*
pulsar ingress target port for http endpoint
*/}}
{{- define "pulsar.proxy.ingress.targetPort.admin" -}}
{{- if and .Values.tls.enabled .Values.tls.proxy.enabled }}
{{- print "https" -}}
{{- else -}}
{{- print "http" -}}
{{- end -}}
{{- end -}}

{{/*
pulsar ingress target port for http endpoint
*/}}
{{- define "pulsar.proxy.ingress.targetPort.data" -}}
{{- if and .Values.tls.enabled .Values.tls.proxy.enabled }}
{{- print "pulsarssl" -}}
{{- else -}}
{{- print "pulsar" -}}
{{- end -}}
{{- end -}}

{{/*
Pulsar Broker Service URL
*/}}
{{- define "pulsar.proxy.broker.service.url" -}}
{{- if .Values.proxy.brokerServiceURL -}}
{{- .Values.proxy.brokerServiceURL -}}
{{- else -}}
pulsar://{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}:{{ .Values.broker.ports.pulsar }}
{{- end -}}
{{- end -}}

{{/*
Pulsar Web Service URL
*/}}
{{- define "pulsar.proxy.web.service.url" -}}
{{- if .Values.proxy.brokerWebServiceURL -}}
{{- .Values.proxy.brokerWebServiceURL -}}
{{- else -}}
http://{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}:{{ .Values.broker.ports.http }}
{{- end -}}
{{- end -}}

{{/*
Pulsar Broker Service URL TLS
*/}}
{{- define "pulsar.proxy.broker.service.url.tls" -}}
{{- if .Values.proxy.brokerServiceURLTLS -}}
{{- .Values.proxy.brokerServiceURLTLS -}}
{{- else -}}
pulsar+ssl://{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}:{{ .Values.broker.ports.pulsarssl }}
{{- end -}}
{{- end -}}

{{/*
Pulsar Web Service URL
*/}}
{{- define "pulsar.proxy.web.service.url.tls" -}}
{{- if .Values.proxy.brokerWebServiceURLTLS -}}
{{- .Values.proxy.brokerWebServiceURLTLS -}}
{{- else -}}
https://{{ template "pulsar.fullname" . }}-{{ .Values.broker.component }}:{{ .Values.broker.ports.https }}
{{- end -}}
{{- end -}}

{{/*
Define Proxy probe
*/}}
{{- define "pulsar.proxy.probe" -}}
httpGet:
  path: /status.html
  {{- if and .Values.tls.enabled .Values.tls.proxy.enabled }}
  port: {{ .Values.proxy.ports.https }}
  scheme: HTTPS
  {{- else}}
  port: {{ .Values.proxy.ports.http }}
  scheme: HTTP
  {{- end}}
{{- end }}

{{/*
 auth superusers proxy
*/}}
{{- define "auth.superusers.proxy" -}}
{{ if eq (.Values.auth.authorization.enabled | toString) "true" }}
  {{- if (((.Values.auth).superUsers).proxy) -}}
    {{- printf "%s" .Values.auth.superUsers.proxy -}}
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


