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
#=============================================================================
  #validateTenantAndDeploymentForAdmin
  #validate the character length for tenant and deployment
  {{- define "validateTenantAndDeploymentForAdmin" -}}
  {{- $tenant := .Values.global.di.tenant | default "provider" -}}
  {{- $deployment := .Values.global.di.deployment | default "default" -}}
  {{- $lengthTenant := len $tenant -}}
  {{- $lengthDeployment := len $deployment -}}
  {{- $total := add $lengthTenant $lengthDeployment -}}
  {{- if lt $total 71 -}}
    {{- cat "di.tenant: " -}}
    {{- $tenant -}}
    {{ cat "\ndi.deployment: " | indent 2 }}
    {{- $deployment }}
  {{- end -}}
  {{- end -}}

{{/*
admin service domain
*/}}
{{- define "admin.service_domain" -}}
        {{- if or (eq (lower (((((.Values.global).di).externalDNS).enabled)| toString)) "true") (eq (lower ((((((.Values.global).di).cloud).externalDNS).enabled)| toString)) "true") -}}
                {{- if (not (empty ((((.Values.global).di).externalAccessHost).administration))) -}}
                        {{- printf "external-dns.alpha.kubernetes.io/hostname: \"%s\"" .Values.global.di.externalAccessHost.administration -}}
                {{- else if (not (empty (((((.Values.global).di).cloud).externalAccessHost).administration))) -}}
                        {{- printf "external-dns.alpha.kubernetes.io/hostname: \"%s\"" .Values.global.di.cloud.externalAccessHost.administration -}}
                {{- else -}}
                        {{- print "" -}}
                {{- end -}}
        {{- else -}}
                {{- print "" -}}
        {{- end -}}
{{- end }}

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
MinIO/S3 Properties.
*/}}

{{- define "minio.host" -}}
{{- if .Values.diadmin.config.minio.host -}}
   {{- print .Values.diadmin.config.minio.host -}}
{{- else -}}
   {{- if eq (.Values.global.cluster.k8sProvider | toString) "aws" -}}
       {{- printf "s3.%s.amazonaws.com" .Values.diadmin.config.s3.region -}}
   {{- else -}}
       {{- print "itom-di-minio-svc" -}}
   {{- end -}}
{{- end -}}
{{- end -}}

{{- define "minio.port" -}}
{{- if .Values.diadmin.config.minio.port -}}
   {{- $mport := .Values.diadmin.config.minio.port | quote -}}
   {{- printf "%s" $mport -}}
{{- else -}}
   {{- if eq (.Values.global.cluster.k8sProvider | toString) "aws" -}}
       {{- $mport := "443" | quote -}}
       {{- printf "%s" $mport -}}
   {{- else -}}
       {{- $mport := "9000" | quote -}}
       {{- printf "%s" $mport -}}
   {{- end -}}
{{- end -}}
{{- end -}}

{{- define "minio.ssl" -}}
{{- if .Values.diadmin.config.minio.tlsEnabled -}}
   {{- $mssl := .Values.diadmin.config.minio.tlsEnabled | quote -}}
   {{- printf "%s" $mssl -}}
{{- else -}}
   {{- $mssl := "true" | quote -}}
   {{- printf "%s" $mssl -}}
{{- end -}}
{{- end -}}


{{- define "minio.nodePort" -}}
{{- if .Values.diadmin.config.minio.service.nodePort -}}
   {{- $mnodePort := .Values.diadmin.config.minio.service.nodePort | quote -}}
   {{- printf "%s" $mnodePort -}}
{{- else -}}
   {{- if eq (.Values.global.cluster.k8sProvider | toString) "aws" -}}
       {{- $mnodePort := "443" | quote -}}
       {{- printf "%s" $mnodePort -}}
   {{- else if eq (.Values.global.cluster.k8sProvider | toString) "azure" -}}
        {{- if .Values.diadmin.config.minio.port -}}
             {{- $mnodePort := .Values.diadmin.config.minio.port | quote -}}
             {{- printf "%s" $mnodePort -}}
        {{- else -}}
             {{- $mnodePort := "9000" | quote -}}
             {{- printf "%s" $mnodePort -}}
           {{- end -}}
   {{- else -}}
        {{- $mnodePort := "30006" | quote -}}
        {{- printf "%s" $mnodePort -}}
   {{- end -}}
{{- end -}}
{{- end -}}


{{/*
S3 Bucket Prefix Validation
*/}}
{{- define "validateS3BucketPrefix" -}}
{{- if regexMatch "^[a-z0-9][a-z0-9-]*$" .Values.diadmin.config.s3.bucketPrefix -}}
{{- if lt (len .Values.diadmin.config.s3.bucketPrefix) 37 -}}
{{- printf "admin.s3.bucketPrefix: \"%s\"" .Values.diadmin.config.s3.bucketPrefix -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
 admin cloud externalAccessHost
*/}}
{{- define "admin.cloud.externalAccessHost" -}}
{{- if (((((.Values.global).di).cloud).externalAccessHost).administration) -}}
{{- if (not (empty .Values.global.di.cloud.externalAccessHost.administration)) -}}
{{- printf "/%s" .Values.global.di.cloud.externalAccessHost.administration  -}}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}
{{- end }}


{{/*
 admin on-prem externalAccessHost
*/}}
{{- define "admin.externalAccessHost" -}}
{{- if ((((.Values.global).di).externalAccessHost).administration) -}}
{{- if (not (empty .Values.global.di.externalAccessHost.administration)) -}}
{{- printf "/%s" .Values.global.di.externalAccessHost.administration  -}}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
global externalAccessHost
*/}}
{{- define "admin.global.externalAccessHost" -}}
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

{{- define "admin.initContainers.resources" -}}
limits:
  cpu: "20m"
  memory: "20Mi"
requests:
  cpu: "5m"
  memory: "5Mi"
{{- end -}}

{{- define "validateClientAuthForMT" -}}
{{- if eq (lower (.Values.diadmin.config.admin.clientAuthEnabled | toString)) "true" -}}
{{- print "true" -}}
{{- end -}}
{{- end -}}