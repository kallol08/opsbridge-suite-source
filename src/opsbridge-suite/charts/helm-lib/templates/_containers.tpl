#===========================================================================
# This file contains may shared componet container definitions list such as vault-init, vault-renew, etc
#===========================================================================

{{/* ===========================================================================
Name: helm-lib.containers.vaultRenew()
Parameters:
  Values:        Mandatory, the value must be . which is used to read the vault-renew image information from chart values.yaml
  containerName: Optional, default: vault-renew. container name for vault renew
  imageName:     Optional, image name of vault-renew. if not set or empty, will be taken from .Values.global.vaultRenew.image
  imageTag:      Optional, image name of vault-renew. if not set or empty, will be taken from .Values.global.vaultRenew.imageTag
  volumeName:    Optional, default: vault-token. where vault token files is placed, this volume name must be aligned with vault-init and pod volumes definition
  limitsCpu:     Optional, default: 100m
  limitsMemory:  Optional, default: 50Mi
  requestsCpu:   Optional, default: 5m
  requestsMemory: Optional,default: 5Mi  
  runAsNonRoot:  Optional, default: true
  allowPrivilegeEscalation: Optional, default: false
  readOnlyRootFilesystem: Optional, default: true
Description: Construct the yaml template for vault-renew containers
Examples: 
  {{- include "helm-lib.containers.vaultRenew" (dict "Values" .Values) | nindent 6 }}
  {{- include "helm-lib.containers.vaultRenew" (dict "imageName" "vault-renew" "kubernetes-vault-renew" "imageTag" "1.0.0-2" "Values" .Values) | nindent 6 }}
  {{- include "helm-lib.containers.vaultRenew" (dict "containerName" "vault-renew" "volumeName" "vault-token-volume" "Values" .Values) | nindent 6 }}
  {{- include "helm-lib.containers.vaultRenew" (dict "limitsCpu" "50m" "requestsMemory" "10Mi" "Values" .Values) | nindent 6 }}
*/}}
{{- define "helm-lib.containers.vaultRenew" -}}
- name: {{ default "vault-renew" .containerName }}
  image: {{ .Values.global.docker.registry }}/{{ .Values.global.docker.orgName }}/{{ default .Values.global.vaultRenew.image .imageName }}:{{ default .Values.global.vaultRenew.imageTag .imageTag }}
  imagePullPolicy: {{ default "IfNotPresent" ((.Values.global.docker).imagePullPolicy) }}
  securityContext:
    runAsNonRoot: {{ default true .runAsNonRoot }}
    runAsUser: {{ default 1999 ((.Values.global.securityContext).user) }}
    runAsGroup: {{ default 1999 ((.Values.global.securityContext).fsGroup) }}
    readOnlyRootFilesystem: {{ default true .readOnlyRootFilesystem }}
    allowPrivilegeEscalation: {{ default false .allowPrivilegeEscalation }}
    seccompProfile:
      type: RuntimeDefault
    capabilities:
      drop:
      - ALL
  resources:
    limits:
      cpu: {{ default "100m" .limitsCpu }}
      memory: {{ default "50Mi" .limitsMemory }}
    requests:
      cpu: {{ default "5m" .requestsCpu }}
      memory: {{ default "5Mi" .requestsMemory }}
  volumeMounts:
  - name: {{ default "vault-token" .volumeName }}
    mountPath: /var/run/secrets/boostport.com
{{- end -}}

{{/* ===========================================================================
Name: helm-lib.containers.vaultInit()
Parameters:
  Values:        Mandatory, the value must be . which is used to read the vault-init image information from chart values.yaml
  commonName:    Mandatory, subject common name. "itom-demo1". one of certNames or commonName must be provided
  additionalSANs: Optional, subject alternative names. for example: "itom-demo1/itom-demo1.core/${HOSNAME}.svc.cluster.local"
      ${HOSTNAME} will be replaced with pod name automatically
  containerName: Optional, default: install. container name for vault init
  imageName:     Optional, image name of vault-init. if not set or empty, will be taken from .Values.global.vaultInit.image
  imageTag:      Optional, image name of vault-init. if not set or empty, will be taken from .Values.global.vaultInit.imageTag
  volumeName:    Optional, default: vault-token. where vault token files is placed, this volume name must be aligned with vault-init and pod volumes definition
  limitsCpu:     Optional, default: 20m
  limitsMemory:  Optional, default: 20Mi
  requestsCpu:   Optional, default: 5m
  requestsMemory: Optional,default: 5Mi
  runAsNonRoot:  Optional, default: true
  allowPrivilegeEscalation: Optional, default: false
  readOnlyRootFilesystem: Optional, default: true
  certNames:     Optional, Deprecated by commonName. certificate names list. for example: "Common_Name:itom-demo1,Additional_SAN:itom-demo1/itom-demo1.core"
Description: Construct the yaml template for vault-init containers
Examples: 
  {{- include "helm-lib.containers.vaultInit" (dict "commonName" "itom-demo1" "Values" .Values) | nindent 6 }}  
  {{- include "helm-lib.containers.vaultInit" (dict "commonName" "itom-demo1" additionalSANs "itom-demo1/itom-demo1.${HOSTNAME}"  "Values" .Values) | nindent 6 }}  
  {{- include "helm-lib.containers.vaultInit" (dict "certNames" "Common_Name:itom-demo1,Additional_SAN:itom-demo1/itom-demo1.core" "Values" .Values) | nindent 6 }}  
  {{- include "helm-lib.containers.vaultInit" (dict "imageName" "kubernetes-vault-init" "imageTag" "1.0.0-2" "Values" .Values) | nindent 6 }}
  {{- include "helm-lib.containers.vaultInit" (dict "containerName" "install" "volumeName" "vault-token" "Values" .Values) | nindent 6 }}
*/}}
{{- define "helm-lib.containers.vaultInit" -}}
- name: {{ default "install" .containerName }}
  image: {{ .Values.global.docker.registry }}/{{ .Values.global.docker.orgName }}/{{ default .Values.global.vaultInit.image .imageName }}:{{ default .Values.global.vaultInit.imageTag .imageTag }}
  imagePullPolicy: {{ default "IfNotPresent" ((.Values.global.docker).imagePullPolicy) }}  
  env:
  - name: POD_NAME
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
  - name: POD_IP
    valueFrom:
      fieldRef:
        apiVersion: v1
        fieldPath: status.podIP
  {{- if .certTtl }}
  - name: CERT_TTL
    value: {{ .certTtl | quote }}
  {{- end }}  
  {{- if .commonName }}
  - name: CERT_COMMON_NAME
    value: {{ printf "Common_Name:%s,Additional_SAN:%s" .commonName (default .commonName .additionalSANs) }}
  {{- else if .certNames }}
  - name: CERT_COMMON_NAME
    value: {{ printf "%s" (.certNames) }}
  {{- end }}
  {{- if ((.Values.global.vault).realmList) }}
  - name: VAULT_REALM_LIST
    value: {{ ((.Values.global.vault).realmList) }}
  {{- end }}
  securityContext:
    runAsNonRoot: {{ default true .runAsNonRoot }}
    runAsUser: {{ default 1999 ((.Values.global.securityContext).user) }}
    runAsGroup: {{ default 1999 ((.Values.global.securityContext).fsGroup) }}
    readOnlyRootFilesystem: {{ default true .readOnlyRootFilesystem }}    
    allowPrivilegeEscalation: {{ default false .allowPrivilegeEscalation }}
    seccompProfile:
      type: RuntimeDefault
    capabilities:
      drop:
      - ALL
  resources:
    limits:
      cpu: {{ default "50m" .limitsCpu }}
      memory: {{ default "50Mi" .limitsMemory }}
    requests:
      cpu: {{ default "5m" .requestsCpu }}
      memory: {{ default "5Mi" .requestsMemory }}
  volumeMounts:
  - mountPath: /var/run/secrets/boostport.com
    name: {{ default "vault-token" .volumeName }}
{{- end -}}

{{/* ===========================================================================
Name: helm-lib.containers.stunnel()
  Values:           Mandatory, the value must be . which is used to read the stunnel image information from chart values.yaml
  containerName:    Optional, container name for stunnel. default: stunnel
  imageName:        Optional, image name of stunnel. if not set or empty, will be taken from .Values.global.stunnel.image
  imageTag:         Optional, image name of stunnel. if not set or empty, will be taken from .Values.global.stunnel.imageTag
  allowPrivilegeEscalation: Optional, default: false
  readOnlyRootFilesystem: Optional, default: true
  limitsCpu:        Optional, default: 100m
  limitsMemory:     Optional, default: 150Mi
  requestsCpu:      Optional, default: 10m
  requestsMemory:   Optional, default: 5Mi
  certFileBaseName: Optional, default: "server"
  listeningPort:    Mandatory, a port for stunnel to listen
  targetPort:       Mandatory, a port which stunnel will transfer data to
Description: Construct the yaml template for stunnel containers
Examples:
  {{- include "helm-lib.containers.stunnel" (dict "listeningPort" "8088" "targetPort" "8080" "Values" .Values) | nindent 6 }}
*/}}
{{- define "helm-lib.containers.stunnel" -}}
- name: {{ default "stunnel" .containerName }}
  image: {{ .Values.global.docker.registry }}/{{ .Values.global.docker.orgName }}/{{ default ((.Values.global.stunnel).image) .imageName }}:{{ default ((.Values.global.stunnel).imageTag) .imageTag }}
  imagePullPolicy: {{ default "IfNotPresent" ((.Values.global.docker).imagePullPolicy) }}
  securityContext:
    allowPrivilegeEscalation: {{ default false .allowPrivilegeEscalation }}
    readOnlyRootFilesystem: {{ default true .readOnlyRootFilesystem }}
    capabilities:
      drop:
      - ALL
  resources:
    limits:
      cpu: {{ default "100m" .limitsCpu }}
      memory: {{ default "150Mi" .limitsMemory }}
    requests:
      cpu: {{ default "10m" .requestsCpu }}
      memory: {{ default "5Mi" .requestsMemory }}
  env:
    - name: CERT_FILE_BASE_NAME
      value: {{ default "server" .certFileBaseName }}
    - name: PROXY_LISTENING_PORT
      value: {{ required "listening port of stunnel required!" .listeningPort | quote }}
    - name: PROXY_TARGET_PORT
      value: {{ required "target port of stunnel required!" .targetPort | quote }}
    {{- include "helm-lib.getTlsEnvVars" (dict "Values" .Values "separator" ":" "cipherFormat" "openssl") | nindent 4 }}
  volumeMounts:
    - name: vault-token
      mountPath: /var/run/secrets/boostport.com
    - name: tlsproxy
      mountPath: /tlsproxy
{{- end -}}

#===========================================================================
# This macro creates a "waitfor" definition which is expected to be part of the pod's "initContainer" section.
# The required parameters are "service" and "port", with optional parameter for "interval" (default value
# is 5 seconds between connection attempts).  As you can see in the code below, this expands into a
# "nc -z SERVICE PORT" call, inside a "forever" loop, until it succeeds.
#
{{- define "helm-lib.waitFor" -}}
{{- $serviceName := .service | lower -}}
{{- $port := .port | toString -}}
{{- $interval := .interval | default "5" -}}
{{- $waitForContainerName := (printf "waitfor-%s-%v" (trunc ((sub 54 (len $port))|int) (replace "." "-" $serviceName)) $port) }}
- name: {{ $waitForContainerName }}
  {{- if .Values.global.toolsBase }}
  image: {{ .Values.global.docker.registry }}/{{ .Values.global.docker.orgName }}/{{ .Values.global.toolsBase.image }}:{{ .Values.global.toolsBase.imageTag }}
  {{- else }}
  image: {{ .Values.global.docker.registry }}/{{ .Values.global.docker.orgName }}/{{ .Values.global.opensuse.image }}:{{ .Values.global.opensuse.imageTag }}
  {{- end }}
  imagePullPolicy: {{ .Values.global.docker.imagePullPolicy }}
  command: [ "sh", "-c", "until nc -z {{$serviceName}} {{$port}} -w 5 ; do echo waiting for {{$serviceName}}:{{$port}}...; sleep {{$interval}}; done; exit 0"]
  {{- if or (.addSecurityContext) (eq (.addSecurityContext | toString) "<nil>") }}
  securityContext:
    runAsNonRoot: {{ default true .runAsNonRoot }}
    runAsUser: {{ default 1999 ((.Values.global.securityContext).user) }}
    runAsGroup: {{ default 1999 ((.Values.global.securityContext).fsGroup) }}
    readOnlyRootFilesystem: {{ default true .readOnlyRootFilesystem }}
    allowPrivilegeEscalation: {{ default false .allowPrivilegeEscalation }}
    seccompProfile:
      type: RuntimeDefault
    capabilities:
      drop:
      - ALL
  {{- end }}
  resources:
    limits:
      cpu: {{ default "50m" .limitsCpu }}
      memory: {{ default "50Mi" .limitsMemory }}
    requests:
      cpu: {{ default "5m" .requestsCpu }}
      memory: {{ default "5Mi" .requestsMemory }}
{{- end -}}

#===========================================================================
# This macro is similar to the above, but intended to wait for multiple services.  The above macro can be
# called multiple times, each waiting for a single service, and each creating a new initContainer reference.
# Whereas this macro can only be called ONCE (an error will occur if it is called twice, since the
# "name" of the initContainer is not unique).  But this macro creates a single initContainer which
# waits for multiple services.
#
# The required parameter is "services" which is a space separated value of service:port values, e.g.
#      services = foo-svc:123 bar-svc:456 abc-svc:789
# It also has the optional "maxtries" (default to 24) and "interval" (default to 5 seconds).
#
{{- define "helm-lib.waitForMany" -}}
{{- $services := .services -}}
{{- $interval := .interval | default "5" -}}
- name: waitfor-dependencies
  {{- if .Values.global.toolsBase }}
  image: {{ .Values.global.docker.registry }}/{{ .Values.global.docker.orgName }}/{{ .Values.global.toolsBase.image }}:{{ .Values.global.toolsBase.imageTag }}
  {{- else }}
  image: {{ .Values.global.docker.registry }}/{{ .Values.global.docker.orgName }}/{{ .Values.global.opensuse.image }}:{{ .Values.global.opensuse.imageTag }}
  {{- end }}
  imagePullPolicy: {{ .Values.global.docker.imagePullPolicy }}
  command: [ "sh", "-c", "for svc in {{.services}} ; do until nc -z ${svc%:*} ${svc#*:} -w 5 ; do echo waiting for $svc...; sleep {{$interval}}; done; done; exit 0"]
  {{- if or (.addSecurityContext) (eq (.addSecurityContext | toString) "<nil>") }}
  securityContext:
    runAsNonRoot: {{ default true .runAsNonRoot }}
    runAsUser: {{ default 1999 ((.Values.global.securityContext).user) }}
    runAsGroup: {{ default 1999 ((.Values.global.securityContext).fsGroup) }}
    readOnlyRootFilesystem: {{ default true .readOnlyRootFilesystem }}
    allowPrivilegeEscalation: {{ default false .allowPrivilegeEscalation }}
    seccompProfile:
      type: RuntimeDefault
    capabilities:
      drop:
      - ALL
  {{- end }}
  resources:
    limits:
      cpu: {{ default "50m" .limitsCpu }}
      memory: {{ default "50Mi" .limitsMemory }}
    requests:
      cpu: {{ default "5m" .requestsCpu }}
      memory: {{ default "5Mi" .requestsMemory }}
{{- end -}}


#===========================================================================
# This macro creates an init container that runs a GET REST call on a provided URL and compares the http status code
# with an injected value. The GET call is executed every X seconds until the received status code matches the
# injected value, and when these two values don't match it logs the response.
#
# Required parameters:
# "service" - the value provided here will be used for naming the init container - eg: waitfor-$service
# "url" - the url against which the GET call is performed - eg: https://foo.bar.net:443/12345/api/version
# "code" - the expected status code for the check to succeed
#
# Optional parameter:
# "interval" - seconds to wait between check attempts
{{- define "helm-lib.waitForServiceUrl" -}}
{{- $name := .service | lower | nospace | trunc 55 -}}
{{- $url := .url | nospace -}}
{{- $code := .code -}}
{{- $interval := .interval | default "5" -}}
- name: waitfor-{{$name}}
  {{- if .Values.global.toolsBase }}
  image: {{ .Values.global.docker.registry }}/{{ .Values.global.docker.orgName }}/{{ .Values.global.toolsBase.image }}:{{ .Values.global.toolsBase.imageTag }}
  {{- else }}
  image: {{ .Values.global.docker.registry }}/{{ .Values.global.docker.orgName }}/{{ .Values.global.opensuse.image }}:{{ .Values.global.opensuse.imageTag }}
  {{- end }}
  imagePullPolicy: {{ .Values.global.docker.imagePullPolicy }}
  command: [ "sh", "-c", "unready=true; while ${unready}; do code=$(curl -o /dev/null --silent -k -w '%{http_code}' {{$url}}); if [ ${code} -eq 200 ]; then unready=false; echo \"Connected to {{$url}}, Status: ${code}\"; else unready=true;  echo \"Waitting for {{$url}}, Reason: $code\"; sleep {{$interval}}; fi; done" ]
  {{- if or (.addSecurityContext) (eq (.addSecurityContext | toString) "<nil>") }}
  securityContext:
    runAsNonRoot: {{ default true .runAsNonRoot }}
    runAsUser: {{ default 1999 ((.Values.global.securityContext).user) }}
    runAsGroup: {{ default 1999 ((.Values.global.securityContext).fsGroup) }}
    readOnlyRootFilesystem: {{ default true .readOnlyRootFilesystem }}
    allowPrivilegeEscalation: {{ default false .allowPrivilegeEscalation }}
    seccompProfile:
      type: RuntimeDefault
    capabilities:
      drop:
      - ALL
  {{- end }}
  resources:
    limits:
  {{- if or .Values.global.toolsBase .Values.global.opensuse }}
      cpu: {{ default "50m" .limitsCpu }}
  {{- else }}
      cpu: {{ default "500m" .limitsCpu }}
  {{- end }}
      memory: {{ default "50Mi" .limitsMemory }}
    requests:
      cpu: {{ default "5m" .requestsCpu }}
      memory: {{ default "5Mi" .requestsMemory }}
{{- end -}}


#===========================================================================
# This macro is a convenience macro to wait for "itom-vault" service, on port 8200.
#
{{- define "helm-lib.waitForVault" -}}
{{- include "helm-lib.waitFor" ( dict "service" "itom-vault" "port" "8200" "Values" .Values) }}
{{- end -}}

#===========================================================================
# This macro is a convenience macro to wait for "itom-vault" service without cdf default security context setting, on port 8200.
#
{{- define "helm-lib.waitForVaultNoSecurityContext" -}}
{{- include "helm-lib.waitFor" ( dict "addSecurityContext" false "service" "itom-vault" "port" "8200" "Values" .Values) }}
{{- end -}}
