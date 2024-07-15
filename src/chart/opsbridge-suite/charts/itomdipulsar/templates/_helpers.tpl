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
pulsar home
*/}}
{{- define "pulsar.home" -}}
{{- if or (eq .Values.global.docker.orgName "streamnative/platform") (eq .Values.global.docker.orgName "streamnative/platform-all") }}
{{- print "/sn-platform" -}}
{{- else }}
{{- print "/pulsar" -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "pulsar.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand to the namespace pulsar installs into.
*/}}
{{- define "pulsar.namespace" -}}
{{- default .Release.Namespace .Values.namespace -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pulsar.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
set the current component variables
*/}}
{{- define "pulsar.setCurrentComponentFull" -}}
{{- $_ := set . "currentComponentFull" (printf "%s-%s" (include "pulsar.fullname" .) (.componentFullSuffix | default .currentComponent)) -}}
{{- $_ := unset . "componentFullSuffix" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pulsar.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the common labels.
*/}}
{{- define "pulsar.standardLabels" -}}
app: {{ template "pulsar.name" . }}
chart: {{ template "pulsar.chart" . }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
cluster: {{ template "pulsar.fullname" . }}
app.kubernetes.io/name: {{ .currentComponentFull }}
app.kubernetes.io/managed-by: {{.Release.Name}}
app.kubernetes.io/version: {{.Chart.Version}}
itom.microfocus.com/capability: itom-data-ingestion
tier.itom.microfocus.com/backend: backend
component: {{ .currentComponent }}
{{- end }}

{{/*
Create the common labels.
*/}}
{{- define "pulsar.pdbLabels" -}}
app: {{ template "pulsar.name" . }}
chart: {{ template "pulsar.chart" . }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
cluster: {{ template "pulsar.fullname" . }}
app.kubernetes.io/name: {{ .currentComponentFull }}
app.kubernetes.io/managed-by: Helm
app.kubernetes.io/version: {{.Chart.Version}}
itom.microfocus.com/capability: itom-data-ingestion
tier.itom.microfocus.com/backend: backend
component: {{ .currentComponent }}
{{- end }}

{{/*
Create the template annotations.
*/}}
{{- define "pulsar.template.annotations" -}}
deployment.microfocus.com/default-replica-count: "1"
deployment.microfocus.com/runlevel: UP
{{- end }}

{{/*
Create extra template annotations for itom-chart-reloader.
*/}}
{{- define "pulsar.template.reloaderannotations" -}}
{{- if .Values.global.apiClient.authorizedClientCAs }}
configmap.reloader.stakater.com/reload: "{{ .Values.global.apiClient.authorizedClientCAs }}"
{{- end }}
{{- end }}

{{/*
Create the match labels.
*/}}
{{- define "pulsar.matchLabels" -}}
app: {{ template "pulsar.name" . }}
release: {{ .Release.Name }}
component: {{ .currentComponent }}
{{- end }}

{{/*
Pulsar Cluster Name.
*/}}
{{- define "pulsar.cluster" -}}
{{- if .Values.pulsar_metadata.clusterName }}
{{- .Values.pulsar_metadata.clusterName }}
{{- else }}
{{- template "pulsar.fullname" . }}
{{- end }}
{{- end }}


{{/*
Define coso init volumes
*/}}
{{- define "pulsar.coso.init.volumes" -}}
- name: cosoinit
  configMap:
    name: "{{ template "pulsar.fullname" . }}-cosoinit-configmap"
    defaultMode: 0755
{{- end }}

{{/*
Define Open Text Init script mount
*/}}
{{- define "pulsar.coso.init.volumeMounts" -}}
- name: cosoinit
  mountPath: "/pulsar/bin/coso-init.sh"
  subPath: coso-init.sh
{{- end }}

{{/*
Define coso external cert volumes
*/}}
{{- define "pulsar.coso.externalcert.volumes" -}}
{{- if .Values.global.apiClient.authorizedClientCAs }}
- name: cosoexternalcert
  configMap:
    name: {{ .Values.global.apiClient.authorizedClientCAs }}
{{- else }}
- name: cosoexternalcert
  secret:
    secretName: itomdipulsar-client-ca-certs-secret
{{- end }}
{{- end }}

{{/*
Define coso external cert mount
*/}}
{{- define "pulsar.coso.externalcert.volumeMounts" -}}
- name: cosoexternalcert
  mountPath: "/pulsar/ssl/custom/ca"
{{- end }}


{{/*
Define Wait for zookeeper init container
*/}}
{{- define "pulsar.zookeeper.wait.init" -}}
- name: wait-zookeeper-ready
  securityContext:
    runAsNonRoot: true
    runAsUser: {{ .Values.global.securityContext.user | int64 }}
    runAsGroup: {{ .Values.global.securityContext.fsGroup | int64 }}                
    seccompProfile:
      type: RuntimeDefault
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL
  image: {{ .Values.global.docker.registry }}/{{ .Values.global.docker.orgName }}/{{ .Values.pulsar.image }}:{{ .Values.pulsar.imageTag }}
  imagePullPolicy: {{ .Values.global.docker.imagePullPolicy }}
  resources:
    requests:
       memory: 512Mi
       cpu: 0.1
    limits:
       memory: 2Gi
       cpu: 0.5
  command: ["sh", "-c"]
  args:
    - >-
      source bin/coso-init.sh;
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled }}
      until bin/pulsar zookeeper-shell -server {{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}:{{ .Values.zookeeper.ports.clientTls }} ls /; do
{{- else }}
      until bin/pulsar zookeeper-shell -server {{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}:{{ .Values.zookeeper.ports.client }} ls /; do
{{- end }}
        sleep 3;
      done;
  volumeMounts:
  {{- include "pulsar.coso.init.volumeMounts" . | nindent 2 }}
  {{- include "pulsar.bastion.certs.volumeMounts" . | nindent 2 }}
  - name: tmp
    mountPath: /pulsar/tmp
  - name: conf
    mountPath: /pulsar/conf
  - name: logs
    mountPath: /pulsar/logs
  - name: ssl
    mountPath: /pulsar/ssl
  - name: vault-token
    mountPath: /var/run/secrets/boostport.com
{{- end }}

{{/*
Define Wait for zookeeper init container with node info
*/}}
{{- define "pulsar.zookeeper.wait.init.node" -}}
- name: wait-zookeeper-ready
  securityContext:
    runAsNonRoot: true
    runAsUser: {{ .Values.global.securityContext.user | int64 }}
    runAsGroup: {{ .Values.global.securityContext.fsGroup | int64 }}                
    seccompProfile:
      type: RuntimeDefault
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL
  image: {{ .Values.global.docker.registry }}/{{ .Values.global.docker.orgName }}/{{ .Values.pulsar.image }}:{{ .Values.pulsar.imageTag }}
  imagePullPolicy: {{ .Values.global.docker.imagePullPolicy }}
  resources:
    requests:
      memory: 512Mi
      cpu: 0.1
    limits:
      memory: 2Gi
      cpu: 0.5
  command: ["sh", "-c"]
  args:
    - >-
      source bin/coso-init.sh;
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled }}
      until bin/pulsar zookeeper-shell -server {{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}:{{ .Values.zookeeper.ports.clientTls }} ls /admin/clusters/{{ template "pulsar.fullname" . }}; do
{{- else }}
      until bin/pulsar zookeeper-shell -server {{ template "pulsar.fullname" . }}-{{ .Values.zookeeper.component }}:{{ .Values.zookeeper.ports.client }}  ls /admin/clusters/{{ template "pulsar.fullname" . }}; do
{{- end }}
        sleep 3;
      done;
  volumeMounts:
  {{- include "pulsar.coso.init.volumeMounts" . | nindent 2 }}
  {{- include "pulsar.bastion.certs.volumeMounts" . | nindent 2 }}
  - name: tmp
    mountPath: /pulsar/tmp
  - name: conf
    mountPath: /pulsar/conf
  - name: logs
    mountPath: /pulsar/logs
  - name: ssl
    mountPath: /pulsar/ssl
  - name: vault-token
    mountPath: /var/run/secrets/boostport.com
{{- end }}


{{/*
zookeeper data local storage
*/}}
{{- define "zookeeper.data_local_storage" -}}
    {{- if eq (include  "helm-lib.service.getServiceType" . ) "LoadBalancer" -}}
		{{- print "false" -}}
	{{- else -}}
		{{- printf "%t" .Values.zookeeper.volumes.data.local_storage -}}
	{{- end }}
{{- end }}

{{/*
zookeeper datalog local storage
*/}}
{{- define "zookeeper.datalog_local_storage" -}}
    {{- if eq (include  "helm-lib.service.getServiceType" . ) "LoadBalancer" -}}
		{{- print "false" -}}
	{{- else -}}
		{{- printf "%t" .Values.zookeeper.volumes.dataLog.local_storage -}}
	{{- end }}
{{- end }}

{{/*
bookkeeper ledgers local storage
*/}}
{{- define "bookkeeper.ledgers_local_storage" -}}
    {{- if eq (include  "helm-lib.service.getServiceType" . ) "LoadBalancer" -}}
		{{- print "false" -}}
	{{- else -}}
		{{- printf "%t" .Values.bookkeeper.volumes.ledgers.local_storage -}}
	{{- end }}
{{- end }}

{{/*
bookkeeper journal local storage
*/}}
{{- define "bookkeeper.journal_local_storage" -}}
    {{- if eq (include  "helm-lib.service.getServiceType" . ) "LoadBalancer" -}}
		{{- print "false" -}}
	{{- else -}}
		{{- printf "%t" .Values.bookkeeper.volumes.journal.local_storage -}}
	{{- end }}
{{- end }}


{{/*
Define coso Set Bookie Rack volumes
*/}}
{{- define "pulsar.coso.pulsarbookierack.volumes" -}}
- name: pulsarsetbookierack
  configMap:
    name: "{{ template "pulsar.fullname" . }}-pulsarsetbookierack-configmap"
    defaultMode: 0755
{{- end }}

{{/*
Define Open Text Init script mount
*/}}
{{- define "pulsar.coso.pulsarbookierack.volumeMounts" -}}
- name: pulsarsetbookierack
  mountPath: "/pulsar/bin/pulsar-set-bookie-rack.sh"
  subPath: pulsar-set-bookie-rack.sh
{{- end }}

{{/*
is aws deployment
*/}}
{{- define "pulsar.is_aws_deployment" -}}
    {{- if eq (lower .Values.global.cluster.k8sProvider) "aws" -}}
        {{- printf "%t" true -}}
    {{- else -}}
        {{- printf "%t" false -}}
    {{- end -}}
{{- end -}}


{{/*
Calculate bytes from value using suffix
*/}}
{{- define "pulsar.calculateBytesFromSuffix" -}}
{{- $numeric := regexFind "^[0-9]+" (toString .) -}}
{{- $suffix := regexReplaceAll "^([0-9]+)" (toString .) "" -}}
{{- $factor := 1 -}}
{{- if eq $suffix "Ki" -}}
  {{- $factor = 1024 -}}
{{- else if eq $suffix "k" -}}
  {{- $factor = 1000 -}}
{{- else if eq $suffix "Mi" -}}
  {{- $factor = mul 1024 1024 -}}
{{- else if eq $suffix "M" -}}
  {{- $factor = mul 1000 1000 -}}
{{- else if eq $suffix "Gi" -}}
  {{- $factor = mul 1024 1024 1024 -}}
{{- else if eq $suffix "G" -}}
  {{- $factor = mul 1000 1000 1000 -}}
{{- else if eq $suffix "Ti" -}}
  {{- $factor = mul 1024 1024 1024 1024 -}}
{{- else if eq $suffix "T" -}}
  {{- $factor = mul 1000 1000 1000 1000 -}}
{{- else if eq $suffix "Pi" -}}
  {{- $factor = mul 1024 1024 1024 1024 1024 -}}
{{- else if eq $suffix "P" -}}
  {{- $factor = mul 1000 1000 1000 1000 1000 -}}
{{- else if eq $suffix "Ei" -}}
  {{- $factor = mul 1024 1024 1024 1024 1024 1024 -}}
{{- else if eq $suffix "E" -}}
  {{- $factor = mul 1000 1000 1000 1000 1000 1000 -}}
{{- else if ne $suffix "" -}}
  {{- fail (printf "unexpected suffix: %s" $suffix) -}}
{{- end -}}

{{- mul $numeric $factor -}}
{{- end -}}

{{/*
 auth superusers client
*/}}
{{- define "auth.superusers.client" -}}
{{ if eq (.Values.auth.authorization.enabled | toString) "true" }}
  {{- if (((.Values.auth).superUsers).client) -}}
    {{- printf "%s" .Values.auth.superUsers.client -}}
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


{{/*

Define pulsar multi az cluster role name
*/}}
{{- define "pulsar.multiazClusterRoleName" -}}
	{{- if eq (((.Values.global).rbac).clusterRoleCreate) true }}
		{{- (printf "%s-%s-%s" (include "pulsar.fullname" .) ( .Release.Namespace ) "multiaz") -}}
	{{- else -}}
		{{- printf "%s" ((((.Values.deployment).rbac).multiAZClusterRole) | default "itomdipulsar-multiaz-cr") -}}
	{{- end -}}
{{- end -}}

{{/*
Define pulsar multi-az service account role name
*/}}
{{- define "pulsar.multiazServiceAccountRoleName" -}}
	{{- if eq (((.Values.global).rbac).roleCreate) true }}
		{{- (printf "%s-%s-%s" (include "pulsar.fullname" .) ( .Release.Namespace ) "multiaz") -}}
	{{- else -}}
		{{- printf "%s" ((((.Values.deployment).rbac).multiAZRole) | default "itomdipulsar-multiaz") -}}
	{{- end -}}
{{- end -}}

{{/*
Define pulsar common role name
*/}}
{{- define "pulsar.commonClusterRoleName" -}}
	{{- if eq (((.Values.global).rbac).clusterRoleCreate) true }}
			{{- (printf "%s-%s" (include "pulsar.fullname" .) ( .Release.Namespace )) -}}
	{{- else -}}
		{{- printf "%s" ((((.Values.deployment).rbac).commonClusterRole) | default "itomdipulsar-cr") -}}
	{{- end -}}
{{- end -}}


{{/*
Can alerts be deployed
*/}}
{{- define "pulsar.alerts_deployment" -}}
{{- if and (eq (((((.Values.global).di).prometheus).alerts).enabled) true)  (and (.Capabilities.APIVersions.Has "monitoring.coreos.com/v1") (eq  (((.Values.global).prometheus).deployPrometheusConfig)  true)) -}}
{{- printf "%t" true -}}
{{- else -}}
{{- printf "%t" false -}}
{{- end -}}
{{- end -}}


{{/*
Define pulsar mutliaz job service account
*/}}
{{- define "pulsar.multiazServiceAccount" -}}
	{{- $multiazsa := (printf "%s-%s-%s" (include "pulsar.fullname" .) ( .Release.Namespace) "multiaz-sa") -}}

	{{- if eq (((.Values.global).rbac).serviceAccountCreate) true }}
		{{- printf "%s" $multiazsa   -}}
	{{- else -}}
		{{- printf "%s" ((((.Values.deployment).rbac).multiAZServiceAccount) | default "itomdipulsar-multiaz-sa") -}}
	{{- end -}}
    
{{- end -}}


{{/*
Define execution of multi-az job
*/}}

{{- define "pulsar.multiazJobExecution" -}}
	{{- if  (ne (len (lookup "rbac.authorization.k8s.io/v1" "ClusterRole" "{{ .Release.Namespace }}"  (include "pulsar.multiazClusterRoleName" .) ) ) 0) }}
		{{ (printf  "echo \"%s Cluster role exists.\";" (include "pulsar.multiazClusterRoleName" .)) }}
		{{- if  eq .Values.itomdipulsar.configureDataPlacementPolicy true  }}
			{{ println "echo \"Data Placement Policy is enabled. Configuring the bookie racks.\";" }}
			{{ println "bin/pulsar-set-bookie-rack.sh;" -}}
		{{- else -}}
			{{ println "echo \"Data Placement Policy is disabled. NOT Configuring the bookie racks.\";" }}
			{{ println "exit 0;" }}
		{{- end -}}
	{{- else -}}
		{{ printf "echo \"%s Cluster role DOES NOT exists.\";" (include "pulsar.multiazClusterRoleName" .) }}
		{{- if  eq (((.Values.global).rbac).clusterRoleCreate) true -}}
			{{ println "echo \"Cluster Role Creation is enabled.\";" -}}
			{{- if  eq .Values.itomdipulsar.configureDataPlacementPolicy true  }}
				{{ println "echo \"Data Placement Policy and Cluster Role Creation is enabled. Configuring the bookie racks.\";" }}
				{{ println "bin/pulsar-set-bookie-rack.sh;" }}
			{{- else -}}
				{{ println "echo \"Data Placement Policy is disabled. NOT Configuring the bookie racks.\";" }}
				{{ println "exit 0;" }}
			{{- end -}}
		{{- else -}}
			{{- if eq .Values.itomdipulsar.configureDataPlacementPolicy true  -}}
				{{ println "echo \"Cluster Role Creation is disabled and Cluster role does not exist. Data Placement Policy is enabled. NOT Configuring the bookie racks.\";" }}
				{{ println "exit 0;" }}
			{{- else -}}
				{{ println "echo \"Cluster Role Creation is disabled and Cluster role does not exist. Data Placement Policy is disabled. NOT Configuring the bookie racks.\";" }}
				{{ println "exit 0;" }}
			{{- end -}}
		{{- end -}}
	{{- end -}}
{{- end -}}

{{/*
Get the minimum write quorum based on deployment -managedLedgerDefaultAckQuorum
*/}}
{{- define "pulsar.bookkeeper.minAckQuorum" -}}
        {{- if eq (((.Values.bookkeeper).replicaCount)|default "3" | int) 1 }}
                {{- printf "%d" 1 -}}
        {{- else }}
                {{- printf "%d" ((((.Values.broker).configData).managedLedgerDefaultAckQuorum)| default "2" |int) -}}
        {{- end -}}
{{- end -}}

