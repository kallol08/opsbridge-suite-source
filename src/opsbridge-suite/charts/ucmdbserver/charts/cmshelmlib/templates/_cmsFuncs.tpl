{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ucmdb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ucmdb.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ucmdb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "ucmdb.labels" -}}
app: {{ include "ucmdb.name" . }}
app.kubernetes.io/name: {{ include "ucmdb.name" . }}
helm.sh/chart: {{ include "ucmdb.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
annotations
*/}}
{{- define "ucmdb.pod.annotations" -}}
{{- if .Values.global.vaultAppRole -}}
pod.boostport.com/vault-approle: {{ .Release.Namespace }}-{{ .Values.global.vaultAppRole }}
{{- else -}}
pod.boostport.com/vault-approle: {{ .Release.Namespace }}-default
{{- end }}
pod.boostport.com/vault-init-container: install
{{- end -}}

{{- define "ucmdb.deployment.annotations" -}}
deployment.microfocus.com/default-replica-count: {{ coalesce .replicaCount 1 | quote }}
deployment.microfocus.com/runlevel: UP
{{- end -}}

{{/*
securityContext
*/}}
{{- define "ucmdb.pod.securityContext" -}}
runAsUser: {{ default 1999 (int (.Values.global.securityContext).user) }}
fsGroup: {{ default 1999 (int (.Values.global.securityContext).fsGroup) }}
runAsGroup: {{ default 1999 (int (.Values.global.securityContext).fsGroup) }}
supplementalGroups: [{{ default 1999 (int (.Values.global.securityContext).fsGroup) }}]
{{- end -}}

{{- define "ucmdb.container.securityContext" -}}
runAsNonRoot: {{ default true .runAsNonRoot }}
privileged: {{ default false .privileged }}
allowPrivilegeEscalation: {{ default false .allowPrivilegeEscalation }}
runAsUser: {{ default 1999 (int (.Values.global.securityContext).user) }}
runAsGroup: {{ default 1999 (int (.Values.global.securityContext).fsGroup) }}
{{- end -}}

{{/*
env
*/}}
{{- define "ucmdb.env" -}}
- name: MY_NODE_NAME
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
- name: MY_POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: MY_POD_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
- name: MY_POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
{{- if .Values.global.securityContext.user }}
- name: UCMDB_UID
  value: {{ .Values.global.securityContext.user | quote }}
{{- end }}
{{- if .Values.global.securityContext.fsGroup }}
- name: UCMDB_GID
  value: {{ .Values.global.securityContext.fsGroup | quote }}
{{- end -}}
{{- end -}}

{{/*
cms orgName
*/}}
{{- define "ucmdb.docker.orgName" -}}
{{- if .Values.global.cms -}}
  {{- if .Values.global.cms.docker -}}
  {{- coalesce .Values.global.cms.docker.orgName .Values.global.docker.orgName -}}
  {{- else -}}
  {{- .Values.global.docker.orgName -}}
  {{- end -}}
{{- else -}}
{{- .Values.global.docker.orgName -}}
{{- end -}}
{{- end -}}

{{/*
resources
*/}}
{{- define "ucmdb.defaultResourceConfig" -}}
{{- if not .Values.global.size -}}
  {{- cat "\nERROR: Deployment size is not defined" | fail -}}
{{- else -}}
  {{- $resourceFile := cat "resources/" .Values.global.size ".yaml" | nospace -}}
  {{- $resourceRef := tpl (.Files.Get $resourceFile) . -}}
  {{- if $resourceRef -}}
    {{- $resourceRef -}}
  {{- else -}}
    {{- cat "\nERROR: Default resource cannot be found on size " .Values.global.size | fail -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
# All names (service name, deployment name, config map name, etc.) will be prefixed as per following rules:
#    if .Values.namePrefix is injected, then use that.
#    else if .Values.backwardsCompat flag is true, prefix with Helm Release.Name, as per previous releases.
#    else prefix with "itom", since we want to STOP (i.e. deprecate) using Helm Release.Name in service names.
#
*/}}
{{- define "namePrefix" -}}
{{- if and (not .Values.namePrefix) .Values.backwardsCompatServiceName -}}
{{- printf "%s-itom" .Release.Name -}}
{{- else -}}
{{- default "itom" .Values.namePrefix -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account
*/}}
{{- define "ucmdb.serviceAccountName" -}}
    {{ coalesce  .Values.deployment.rbac.serviceAccount .Values.global.rbac.serviceAccount (printf "%s-%s" (include "namePrefix" .) (default .Chart.Name .Values.nameOverride)) }}
{{- end -}}

{{/*
Record the installation version
*/}}
{{- define "ucmdb.installVersion" -}}
  {{- if .Chart.AppVersion }}
    {{- $yaml := lookup "apps/v1" "Deployment" .Release.Namespace .name -}}
    {{- $currentVersion := .Chart.AppVersion -}}
    {{- $defaultVersion := .default -}}
    {{- if $yaml -}}
      {{- $installedVersion := get (get (get $yaml "metadata" | default dict) "labels" | default dict) "installed-version" -}}
      {{- if $installedVersion -}}
        {{- printf "%s" $installedVersion -}}
      {{- else -}}
        {{- printf "%s" ( .Release.IsInstall | ternary $currentVersion $defaultVersion ) -}}
      {{- end -}}
    {{- else -}}
      {{- printf "%s" $currentVersion -}}
    {{- end -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{/*
Convert service chart appVersion to semver format. E.g. 11.6.7.23 -> 11.6.7-23
*/}}
{{- define "ucmdb.versionConvertor" -}}
  {{- $versionList := splitList "." .version -}}
  {{- if gt (len $versionList) 3 -}}
    {{- printf "%s-%s" ((slice $versionList 0 3) | join ".") ((slice $versionList 3) | join ".") -}}
  {{- else -}}
    {{- .version -}}
  {{- end -}}
{{- end -}}

{{/* Affinity check if it is empty */}}
{{- define "ucmdb.affinity.validate" -}}
{{- cat ( .Values.affinity ) -}}
{{- end -}}

{{/* Affinity setting, by default we will use the service name, can be overrode by affinity={} */}}
{{- define "ucmdb.affinity.inject" -}}
{{- if not (eq (include "ucmdb.affinity.validate" . ) "") -}}
{{- with ( .Values.affinity ) }}affinity:  {{ toYaml . | nindent 2 }}
{{- end -}}
{{- else -}}
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - {{ include "ucmdb.name" . }}
        topologyKey: "kubernetes.io/hostname"
    {{- if .Values.workLoad }}
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: workLoad
            operator: In
            values:
            - {{ .Values.workLoad }}
        topologyKey: "kubernetes.io/hostname"
    {{- end }}
{{- end -}}
{{- end -}}