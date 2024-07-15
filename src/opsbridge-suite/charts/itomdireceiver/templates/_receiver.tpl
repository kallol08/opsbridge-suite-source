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
receiver service domain
*/}}
{{- define "receiver.service_domain" -}}
        {{- if or (eq (lower (((((.Values.global).di).externalDNS).enabled)| toString)) "true") (eq (lower ((((((.Values.global).di).cloud).externalDNS).enabled)| toString)) "true") -}}
                {{- if (not (empty ((((.Values.global).di).externalAccessHost).receiver))) -}}
                        {{- printf "external-dns.alpha.kubernetes.io/hostname: \"%s\"" .Values.global.di.externalAccessHost.receiver -}}
                {{- else if (not (empty (((((.Values.global).di).cloud).externalAccessHost).receiver))) -}}
                        {{- printf "external-dns.alpha.kubernetes.io/hostname: \"%s\"" .Values.global.di.cloud.externalAccessHost.receiver -}}
                {{- else -}}
                        {{- print "" -}}
                {{- end -}}
        {{- else -}}
                {{- print "" -}}
        {{- end -}}
{{- end }}

{{/*
receiver cloud externalAccessHost
*/}}
{{- define "receiver.cloud.externalAccessHost" -}}
{{- if (((((.Values.global).di).cloud).externalAccessHost).receiver) -}}
{{- if (not (empty .Values.global.di.cloud.externalAccessHost.receiver)) -}}
{{- printf "/%s" .Values.global.di.cloud.externalAccessHost.receiver  -}}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
 receiver on-prem externalAccessHost
*/}}
{{- define "receiver.externalAccessHost" -}}
{{- if ((((.Values.global).di).externalAccessHost).receiver) -}}
{{- if (not (empty .Values.global.di.externalAccessHost.receiver)) -}}
{{- printf "/%s" .Values.global.di.externalAccessHost.receiver  -}}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
global externalAccessHost
*/}}
{{- define "receiver.global.externalAccessHost" -}}
{{- if ((.Values.global).externalAccessHost) -}}
{{- if (not (empty .Values.global.externalAccessHost)) -}}
{{- printf "%s" .Values.global.externalAccessHost  -}}
{{- else -}}
{{- print "Required value is not defined for global.externalAccessHost" -}}
{{- end -}}
{{- else -}}
{{- print "Required value is not defined for global.externalAccessHost" -}}
{{- end -}}
{{- end }}

{{- define "receiver.initContainers.resources" -}}
limits:
  cpu: "20m"
  memory: "20Mi"
requests:
  cpu: "5m"
  memory: "5Mi"
{{- end -}}


{{/*
Can alerts be deployed
*/}}
{{- define "receiver.alerts_deployment" -}}
{{- if and (eq (((((.Values.global).di).prometheus).alerts).enabled)  true)  (and (.Capabilities.APIVersions.Has "monitoring.coreos.com/v1") (eq  (((.Values.global).prometheus).deployPrometheusConfig)   true)) -}}
{{- printf "%t" true -}}
{{- else -}}
{{- printf "%t" false -}}
{{- end -}}
{{- end -}}

