{{- /* Copyright 2020-2023 Open Text */ -}}

{{/* vim: set filetype=mustache: */}}

{{/* Common labels */}}
{{- define "obm.labels" -}}
app: {{ .Values.deployment.name }}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
itom.microfocus.com/capability: {{ .Values.global.evtsvc.capability | default "obm" | quote }}
itom.microfocus.com/capability-version: {{ .Values.global.evtsvc.version | quote }}
tier.itom.microfocus.com/backend: backend
tier.itom.microfocus.com/frontend: frontend
{{- end -}}

{{- define "obm.rcp.labels" -}}
app: {{ .Values.deployment.name }}-rcp
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
itom.microfocus.com/capability: {{ .Values.global.evtsvc.capability | default "obm" | quote }}
itom.microfocus.com/capability-version: {{ .Values.global.evtsvc.version | quote }}
tier.itom.microfocus.com/backend: backend
tier.itom.microfocus.com/frontend: frontend
{{- end -}}

{{- define "obm.scripting-host.labels" -}}
app: {{ .Values.deployment.name }}-scripting-host
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.Version | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
itom.microfocus.com/capability: {{ .Values.global.evtsvc.capability | default "obm" | quote }}
itom.microfocus.com/capability-version: {{ .Values.global.evtsvc.version | quote }}
tier.itom.microfocus.com/backend: backend
{{- end -}}

{{- define "obm.ingress.prefix" -}}
{{- .Values.global.nginx.annotationPrefix | default "ingress.kubernetes.io" | trim -}}
{{- end }}

{{- define "obm.getManagementPacks" -}}
{{-   $selectedMps := list -}}
{{-   range $k, $v := .Values.params.managementPacks -}}
{{-     if $v -}}
{{-        $selectedMps = append $selectedMps $k -}}
{{-      end -}}
{{-   end -}}
{{-   join "," $selectedMps | quote -}}
{{- end -}}

{{- define "obm.getMemoryOverrides" -}}
{{-   $overrides := list -}}
{{-   range $k, $v := .Values.deployment.memoryOverrides -}}
{{-     if (not (empty $v)) -}}
{{-        $overrides = append $overrides (print $k "=" $v) -}}
{{-      end -}}
{{-   end -}}
{{-   join "," $overrides | quote -}}
{{- end -}}

{{- define "obm.reloaderAnnotation" -}}
{{-   $reloaderCMs := list .Values.global.tlsTruststore -}}
{{-   if (eq "true" (include "helm-lib.dbTlsEnabled" . | lower)) -}}
{{-     $reloaderCMs = append $reloaderCMs .Values.global.database.tlsTruststore -}}
{{-   end -}}
{{-   $reloaderCMs = uniq $reloaderCMs -}}
{{-   if $reloaderCMs -}}
configmap.reloader.stakater.com/reload: {{ join "," $reloaderCMs | quote }}
{{-   end -}}
{{- end -}}

{{- define "obm.siToBytes" -}}
{{-   $arg := . -}}
{{-   $factors := dict -}}
{{-   $_ := set $factors "b" 1 -}}
{{-   $_ := set $factors "B" 1 -}}
{{-   $_ := set $factors "k" 1000 -}}
{{-   $_ := set $factors "K" 1000 -}}
{{-   $_ := set $factors "m" (mul 1000 1000) -}}
{{-   $_ := set $factors "M" (mul 1000 1000) -}}
{{-   $_ := set $factors "g" (mul 1000 1000 1000) -}}
{{-   $_ := set $factors "G" (mul 1000 1000 1000) -}}
{{-   $_ := set $factors "Ki" 1024 -}}
{{-   $_ := set $factors "Mi" (mul 1024 1024) -}}
{{-   $_ := set $factors "Gi" (mul 1024 1024 1024) -}}
{{-   if (typeIs "string" $arg) -}}
{{-     $suffix := regexReplaceAllLiteral "^[0-9]*" $arg "" -}}
{{-     $f := empty $suffix | ternary 1 (get $factors $suffix) -}}
{{-     if empty $f -}}
{{-       printf "\n%s is invalid. Supported suffixes are %s" $arg (keys $factors | sortAlpha | toString) | fail -}}
{{-     end -}}
{{-     mulf ($arg | trimSuffix $suffix | default "0" | float64) $f | floor | int64 -}}
{{-   else -}}
{{-     $arg -}}
{{-   end -}}
{{- end -}}

{{- define "obm.mgmtDb" -}}
{{-   if (eq .Values.global.database.type "oracle") -}}
{{-     .Values.deployment.mgmtDatabase.user -}}
{{-   else -}}
{{-     .Values.deployment.mgmtDatabase.dbName -}}
{{-   end -}}
{{- end -}}

{{- define "obm.eventDb" -}}
{{-   if (eq .Values.global.database.type "oracle") -}}
{{-     .Values.deployment.eventDatabase.user -}}
{{-   else -}}
{{-     .Values.deployment.eventDatabase.dbName -}}
{{-   end -}}
{{- end -}}

{{- define "obm.mgmtUser" -}}
{{-   .Values.deployment.mgmtDatabase.user -}}
{{- end -}}

{{- define "obm.eventUser" -}}
{{-   .Values.deployment.eventDatabase.user -}}
{{- end -}}

{{- define "obm.mgmtUserKey" -}}
{{-   .Values.deployment.mgmtDatabase.userPasswordKey -}}
{{- end -}}

{{- define "obm.eventUserKey" -}}
{{-   .Values.deployment.eventDatabase.userPasswordKey -}}
{{- end -}}

{{/*
  Override artemis resources function
*/}}

{{- define "evtsvc-artemis.resources" -}}
{{- $sizes := get .Values.deployment.sizes (upper .Values.deployment.size) -}}
requests:
  memory: {{ $sizes.minMemory }}
  cpu: {{ $sizes.minCpu }}
limits:
  memory: {{ $sizes.maxMemory }}
  cpu: {{ $sizes.maxCpu }}
{{- end -}}

