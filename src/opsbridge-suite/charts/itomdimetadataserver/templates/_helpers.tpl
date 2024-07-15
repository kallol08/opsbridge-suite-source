#
# Copyright 2023 Open Text.
#
# The only warranties for products and services of Open Text and its affiliates and licensors (“Open Text”)
# are as may be set forth in the express warranty statements accompanying such products and services.
# Nothing herein should be construed as constituting an additional warranty. Open Text shall not be liable
# for technical or editorial errors or omissions contained herein. The information contained herein is subject
# to change without notice.
#
# Except as specifically indicated otherwise, this document contains confidential information and a valid
# license is required for possession, use or copying. If this work is provided to the U.S. Government,
# consistent with FAR 12.211 and 12.212, Commercial Computer Software, Computer Software
# Documentation, and Technical Data for Commercial Items are licensed to the U.S. Government under
# vendor’s standard commercial license.
#
#=============================================================================
  #validateTenantAndDeploymentForMetadataServer
  #validate the character length for tenant and deployment
  {{- define "validateTenantAndDeploymentForMetadataServer" -}}
  {{- $tenant := .Values.global.di.tenant | default "provider" -}}
  {{- $deployment := .Values.global.di.deployment | default "default" -}}
  {{- $lengthTenant := len $tenant -}}
  {{- $lengthDeployment := len $deployment -}}
  {{- $total := add $lengthTenant $lengthDeployment -}}
  {{- if lt $total 71 -}}
  {{ cat "- name: DI_TENANT" }}
  {{ cat "value: " | indent 12 }}
  {{- $tenant -}}
  {{ cat "\n- name: DI_DEPLOYMENT " | indent 12 }}
  {{ cat "value: " | indent 12 }}
  {{- $deployment -}}
  {{- end -}}
  {{- end -}}

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

{{- define "metadataServer.initContainers.resources" -}}
limits:
  cpu: "20m"
  memory: "20Mi"
requests:
  cpu: "5m"
  memory: "5Mi"
{{- end -}}
