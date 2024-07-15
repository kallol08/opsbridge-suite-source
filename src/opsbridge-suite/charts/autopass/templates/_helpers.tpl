# All names (service name, deployment name, config map name, etc.) will be prefixed as per following rules:
#    if .Values.namePrefix is injected, then use that.
#    else if .Values.backwardsCompat flag is true, prefix with Helm Release.Name, as per previous releases.
#    else prefix with "itom", since we want to STOP (i.e. deprecate) using Helm Release.Name in service names.
#
{{- define "namePrefix" -}}
{{- if and (not .Values.namePrefix) .Values.backwardsCompatServiceName -}}
{{- printf "%s-itom" .Release.Name -}}
{{- else -}}
{{- default "itom" .Values.namePrefix -}}
{{- end -}}
{{- end -}}

{{/* RBAC */}}
{{/* Validate that only boolean values are provided via global.rbac values */}}
{{- define "autopass.rbac.validate.boolType" -}}
{{- if kindIs "bool" .Values.global.rbac.serviceAccountCreate -}}
true
{{- else -}}
{{- cat "\n\n[AutoPass] ERROR: The value of helm parameter 'global.rbac.serviceAccountCreate' is not of type boolean" | fail -}}
{{- end -}}
{{- if kindIs "bool" .Values.global.rbac.roleCreate -}}
true
{{- else -}}
{{- cat "\n\n[AutoPass] ERROR: The value of helm parameter 'global.rbac.roleCreate' is not of type boolean" | fail -}}
{{- end -}}
{{- end -}}

{{- define "autopass.rbac.sa.name" -}}
{{- if (include "autopass.rbac.validate.boolType" .) -}}
  {{- if and ( not .Values.global.rbac.serviceAccountCreate ) (not .Values.deployment.rbac.serviceAccount) -}}
    {{- cat "\n\n[AutoPass] ERROR: Detected global.rbac.serviceAccountCreate=false but no service account name provided via parameter 'deployment.rbac.serviceAccount'" | fail -}}
  {{- end -}}
  {{- $namePrefix := (include "namePrefix" .) -}}
  {{- if .Values.deployment.rbac.serviceAccount -}}
    {{- print .Values.deployment.rbac.serviceAccount -}}
  {{- else -}}
    {{- printf "%v-autopass-lms" $namePrefix -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "autopass.rbac.role.name" -}}
  {{- $namePrefix := (include "namePrefix" .) -}}
  {{- printf "%v-autopass-lms" $namePrefix -}}
{{- end -}}

{{/* IDM URL */}}
{{- define "autopass.idm.authUrl" -}}
{{- default ( printf "https://%s:%d/idm-service" .Values.global.externalAccessHost (int64 .Values.global.externalAccessPort) ) .Values.global.idm.idmAuthUrl -}}
{{- end -}}

{{- define "autopass.idm.serviceUrl" -}}
{{- default (include "autopass.idm.authUrl" .) .Values.global.idm.idmServiceUrl -}}
{{- end -}}

{{- define "apls.replicas" -}}
{{- if (kindIs "bool" .Values.deployment.replicas) -}}
    {{- cat "\n\n[AutoPass] ERROR: The value provided for deployment.replicas is not valid (range: >=1 and should be of type integer)" | fail -}}
{{- else -}}
    {{- if not (empty (.Values.deployment.replicas) ) -}}
        {{- if ( ge (int64 .Values.deployment.replicas ) 1 ) -}}
            {{- printf "%d" (int64 .Values.deployment.replicas ) -}}
        {{- else -}}
            {{- cat "\n\n[AutoPass] ERROR: The value provided for deployment.replicas is not valid (range: >=1 and should be of type integer)" | fail -}}
        {{- end -}}
    {{- else -}}
        {{- if eq (.Values.deployment.replicas | toString) "0" -}}
            {{- cat "\n\n[AutoPass] ERROR: The value provided for deployment.replicas is not valid (range: >=1 and should be of type integer)" | fail -}}
        {{- else -}}
            {{- printf "%d" (1) -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{- define "apls.isMT" -}}
{{- if (kindIs "bool" .Values.deployment.multiTenant) -}}
  {{- if .Values.deployment.multiTenant -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- else -}}
  {{- if not (empty (.Values.deployment.multiTenant) ) -}}
    {{- cat  "\n\n[APLS] ERROR: The value of parameter '.Values.deployment.multiTenant' must be of type: boolean" | fail -}}
  {{- else -}}
    {{- if (eq (toString .Values.deployment.multiTenant) "0") -}}
        {{- cat "\n\n[APLS] ERROR: When provided, the value of helm parameter '.Values.deployment.multiTenant' must be set to either 'true' or 'false'" | fail -}}
    {{- else -}}
        {{- printf "false" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

 {{- define "apls.cpu.validateInput" -}}
{{- if and (.Values.deployment.cpuRequest) (.Values.deployment.cpuLimit) -}}
  {{- $cpuRequest := ( int64 .Values.deployment.cpuRequest ) -}}
  {{- $cpuLimit := ( int64 .Values.deployment.cpuLimit ) -}}
  {{- if or (eq $cpuRequest 0) (eq $cpuLimit 0) -}}
    {{- cat "\n\n[APLS] ERROR: The CPU usage parameters cannot be set to '0' - recheck deployment.cpuRequest and/or deployment.cpuLimit" | fail -}}
  {{- end -}}
  {{- if not (le $cpuRequest $cpuLimit) -}}
    {{- cat "\n\n[APLS] ERROR: The value of deployment.cpuRequest must be <= deployment.cpuLimit" | fail -}}
  {{- end -}}
  true
{{- else -}}
  {{- if .Values.deployment.cpuRequest -}}
    {{- cat "\n\n[APLS] ERROR: Must define both CPU usage limits - missing value: deployment.cpuLimit" | fail -}}
  {{- else -}}
    {{- if .Values.deployment.cpuLimit -}}
      {{- cat "\n\n[APLS] ERROR: Must define both CPU usage limits - missing value: deployment.cpuRequest" | fail -}}
    {{- else -}}
      true
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "apls.cpuLimit" -}}
{{- if ( include "apls.cpu.validateInput" . ) -}}
  {{- if .Values.deployment.cpuLimit -}}
    {{- printf "%d%s" ( int64 .Values.deployment.cpuLimit ) "m" -}}
  {{- else -}}
    {{- if eq (include "apls.isMT" .) "true" -}}
      {{- printf "%d%s" (4500) "m" -}}
    {{- else -}}
      {{- printf "%d%s" (2000) "m" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "apls.cpuRequest" -}}
{{- if ( include "apls.cpu.validateInput" . ) -}}
  {{- if .Values.deployment.cpuRequest -}}
    {{- printf "%d%s" ( int64 .Values.deployment.cpuRequest ) "m" -}}
  {{- else -}}
    {{- if eq (include "apls.isMT" .) "true" -}}
      {{- printf "%d%s" (3000) "m" -}}
    {{- else -}}
      {{- printf "%d%s" (500) "m" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "apls.jvm.validateMemRange" -}}
{{- if and (.Values.deployment.initMemory) (.Values.deployment.maxMemory ) -}}
  {{- $initMem := ( int64 .Values.deployment.initMemory ) -}}
  {{- $maxMem := ( int64 .Values.deployment.maxMemory ) -}}
  {{- if (le $initMem $maxMem) -}}
    {{- if (ge $initMem 1524) -}}
      {{- if le $maxMem 20480 -}}
        true
      {{- else -}}
        {{- cat "\n\n[APLS] ERROR: The value for deployment.maxMemory must be <= 20480" | fail -}}
      {{- end -}}
    {{- else -}}
      {{- cat "\n\n[APLS] ERROR: The Value for deployment.initMemory cannot be less than 1524" | fail -}}
    {{- end -}}
  {{- else -}}
    {{- cat "\n\n[APLS] ERROR: The Value of deployment.initMemory must be <= deployment.maxMemory" | fail -}}
  {{- end -}}
{{- else -}}
  {{- if .Values.deployment.initMemory }}
    {{- cat "\n\n[APLS] ERROR: Cannot define only one limit of the JVM memory range - missing value: deployment.maxMemory" | fail -}}
  {{- else -}}
    {{- if .Values.deployment.maxMemory }}
      {{- cat "\n\n[APLS] ERROR: Cannot define only one limit of the JVM memory range - missing value: deployment.initMemory" | fail -}}
    {{- else -}}
      true
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "apls.containerMemoryRequestAndLimit" -}}
  {{- if .Values.deployment.maxAPLSmemory -}}
    {{- $jvmMaxMem := printf "%d" ( int64 .Values.deployment.maxAPLSmemory ) -}}
    {{- $delta := max 1024 (div (mul 25 $jvmMaxMem) 100) -}}
    {{- $containerMem := add $jvmMaxMem $delta -}}
    {{- printf "%d%s" $containerMem  "Mi" -}}
  {{- else -}}
    {{- if eq (include "apls.isMT" .) "true" -}}
      {{- printf "%d%s" (4096) "Mi" -}}
    {{- else -}}
      {{- printf "%d%s" (2048) "Mi" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "apls.jvmMem" -}}
  {{- if .Values.deployment.maxAPLSmemory -}}
    {{- $jvmMaxMem := printf "%d" ( int64 .Values.deployment.maxAPLSmemory ) -}}
    {{- printf "%s" $jvmMaxMem -}}
  {{- else -}}
    {{- if eq (include "apls.isMT" .) "true" -}}
      {{- printf "%d" (3096) -}}
    {{- else -}}
      {{- printf "%d" (1548) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{/* K8s Secret vs Vault */}}
{{- define "apls.secretStorageType" -}}
{{- default "k8s" .Values.deployment.secretStorage -}}
{{- end -}}

{{- define "apls.secretStorageName" -}}
{{- coalesce .Values.global.initSecrets .Values.global.secretStorageName "nom-secret" -}}
{{- end -}}
