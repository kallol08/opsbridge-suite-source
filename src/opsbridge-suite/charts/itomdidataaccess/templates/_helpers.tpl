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
Vertica Database Properties.
*/}}

{{- define "vertica.host" -}}
{{- $vhost := "itom-di-vertica-svc" | quote -}}
{{- if (eq (.Values.global.vertica.embedded | toString) "true") }}
{{- printf "%s" $vhost -}}
{{- else -}}
{{- $vhost := .Values.global.vertica.host | quote -}}
{{- printf "%s" $vhost -}}
{{- end -}}
{{- end -}}

{{- define "vertica.rwuser" -}}
{{- $vrwuser := "dbadmin" | quote -}}
{{- if (eq (.Values.global.vertica.embedded | toString) "true") }}
{{- printf "%s" $vrwuser -}}
{{- else -}}
{{- $vrwuser := .Values.global.vertica.rwuser | quote -}}
{{- printf "%s" $vrwuser -}}
{{- end -}}
{{- end -}}

{{- define "vertica.rouser" -}}
{{- $vrouser := "dbadmin" | quote -}}
{{- if (eq (.Values.global.vertica.embedded | toString) "true") }}
{{- printf "%s" $vrouser -}}
{{- else -}}
{{- $vrouser := .Values.global.vertica.rouser | quote -}}
{{- printf "%s" $vrouser -}}
{{- end -}}
{{- end -}}

{{- define "vertica.db" -}}
{{- $vdb := "itomdb" | quote -}}
{{- if (eq (.Values.global.vertica.embedded | toString) "true") }}
{{- printf "%s" $vdb -}}
{{- else -}}
{{- $vdb := .Values.global.vertica.db | quote -}}
{{- printf "%s" $vdb -}}
{{- end -}}
{{- end -}}

{{- define "vertica.port" -}}
{{- $vport := "5444" | quote -}}
{{- if (eq (.Values.global.vertica.embedded | toString) "true") }}
{{- printf "%s" $vport -}}
{{- else -}}
{{- $vport := .Values.global.vertica.port | quote -}}
{{- printf "%s" $vport -}}
{{- end -}}
{{- end -}}

{{/*
data access service domain
*/}}
{{- define "dataaccess.service_domain" -}}
        {{- if or (eq (lower (((((.Values.global).di).externalDNS).enabled)| toString)) "true") (eq (lower ((((((.Values.global).di).cloud).externalDNS).enabled)| toString)) "true") -}}
                {{- if (not (empty ((((.Values.global).di).externalAccessHost).dataAccess))) -}}
                        {{- printf "external-dns.alpha.kubernetes.io/hostname: \"%s\"" .Values.global.di.externalAccessHost.dataAccess -}}
                {{- else if (not (empty (((((.Values.global).di).cloud).externalAccessHost).dataAccess))) -}}
                        {{- printf "external-dns.alpha.kubernetes.io/hostname: \"%s\"" .Values.global.di.cloud.externalAccessHost.dataAccess -}}
                {{- else -}}
                        {{- print "" -}}
                {{- end -}}
        {{- else -}}
                {{- print "" -}}
        {{- end -}}
{{- end }}

{{- define "externalaccess.port" -}}
{{- if eq (lower .Values.global.cluster.k8sProvider) "azure" -}}
{{- $port := "28443" | quote -}}
{{- printf "%s" $port -}}
{{- else -}}
{{- $port := .Values.didataaccess.config.accessNodePort | quote -}}
{{- printf "%s" $port -}}
{{- end -}}
{{- end -}}

{{/*
 data-access cloud externalAccessHost
*/}}
{{- define "dataaccess.cloud.externalAccessHost" -}}
{{- if (((((.Values.global).di).cloud).externalAccessHost).dataAccess) -}}
{{- if (not (empty .Values.global.di.cloud.externalAccessHost.dataAccess)) -}}
{{- printf "/%s" .Values.global.di.cloud.externalAccessHost.dataAccess  -}}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}
{{- end }}


{{/*
 data-access on-prem externalAccessHost
*/}}
{{- define "dataaccess.externalAccessHost" -}}
{{- if ((((.Values.global).di).externalAccessHost).dataAccess) -}}
{{- if (not (empty .Values.global.di.externalAccessHost.dataAccess)) -}}
{{- printf "/%s" .Values.global.di.externalAccessHost.dataAccess  -}}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
global externalAccessHost
*/}}
{{- define "dataaccess.global.externalAccessHost" -}}
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

{{- define "dataaccess.initContainers.resources" -}}
limits:
  cpu: "20m"
  memory: "20Mi"
requests:
  cpu: "5m"
  memory: "5Mi"
{{- end -}}
