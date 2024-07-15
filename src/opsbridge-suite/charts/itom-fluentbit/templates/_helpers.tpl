{{/* vim: set filetype=mustache: */}}
{{/*
  All names (service name, deployment name, config map name, etc.) will be prefixed as per following rules:
    if .Values.namePrefix is injected, then use that.
    else if .Values.backwardsCompat flag is true, prefix with Helm Release.Name, as per previous releases.
    else prefix with "itom", since we want to STOP (i.e. deprecate) using Helm Release.Name in service names.
*/}}
{{- define "namePrefix" -}}
{{- if and (not .Values.namePrefix) .Values.backwardsCompatServiceName -}}
  {{- printf "%s-itom" .Release.Name -}}
{{- else -}}
  {{- default "itom" .Values.namePrefix -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "itom-fluentbit.serviceAccountName" -}}
{{- if .Values.global.rbac.serviceAccountCreate -}}
    {{ default (printf "%s-%s" (include "namePrefix" .) "fluentbit") .Values.deployment.rbac.serviceAccountName }}
{{- else -}}
    {{ default "default" .Values.deployment.rbac.serviceAccountName }}
{{- end -}}
{{- end -}}

{{- define "receiverCertResolve" -}}
{{ $cert := .Values.logging.output.receiver.caCert }}
{{- if (contains "-----BEGIN" $cert) }}
  {{- printf "%s" $cert }}
{{- else }}
  {{- printf "%s" $cert | b64dec }}
{{- end -}}
{{- end -}}

{{/*
add time to logs
*/}}
{{- define "itom-fluentbit.time" -}}
{{ now | date "2006-01-02T15:04:05.000Z" }}
{{- end -}}

{{/*
generate fluentbit output plugin name
*/}}
{{- define "itom-fluentbit.outputPlugin" -}}
{{- if or (eq (lower .Values.logging.output.receiver.type) "elasticsearch") (eq (lower .Values.logging.output.receiver.type) "es") -}}
  {{- print "es"  }}
{{- else if eq (lower .Values.logging.output.receiver.type) "splunk" -}}
  {{- print "splunk"  }}
{{- else if or (eq (lower .Values.logging.output.receiver.type) "http") (eq (lower .Values.logging.output.receiver.type) "oba") -}}
  {{- print "http"  }}
{{- else if eq (lower .Values.logging.output.receiver.type) "file" -}}
  {{- print "file"  }}
{{- else if eq (lower .Values.logging.output.receiver.type) "stdout" -}}
  {{- print "stdout"  }}
{{- else -}}
  {{- $errorMsg := printf "%s  ERROR Unsupport logging receiver type %s" (include "itom-fluentbit.time" .) .Values.logging.output.receiver.type }}
  {{- fail $errorMsg -}}
{{- end -}}
{{- end -}}

{{/*
generate parserd url map
example:
    scheme:   'http'
    host:     'server.com:8080'
    path:     '/api'
    query:    'list=false'
    opaque:   nil
    fragment: 'anchor'
    userinfo: 'admin:secret'
*/}}
{{- define "itom-fluentbit.urlpreCheck" -}}
{{- if and (empty .Values.logging.output.receiver.url) (and (ne .Values.logging.output.receiver.type "file") (ne .Values.logging.output.receiver.type "stdout"))}}
  {{- fail (printf "%s ERROR Receiver Url cannot be empty !" (include "itom-fluentbit.time" .) ) -}}
{{- end -}}
{{- end -}}

{{/*
generate runtime name (cri.name)
*/}}
{{- define "itom-fluentbit.criName" -}}
{{- if .Values.logging.cri.name -}}
  {{- print .Values.logging.cri.name -}}
{{- else if or (hasPrefix "cdf-" .Values.global.cluster.k8sProvider) (eq .Values.global.cluster.k8sProvider "cdf") -}}
  {{- print "containerd" -}}
{{- else if or (eq (lower .Values.global.cluster.k8sProvider) "azure") (eq (lower .Values.global.cluster.k8sProvider) "gcp") -}}
  {{- print "containerd" -}}
{{- else if eq (lower .Values.global.cluster.k8sProvider) "openshift" -}}
  {{- print "crio" -}}
{{- else if or (eq (lower .Values.global.cluster.k8sProvider) "generic") (eq (lower .Values.global.cluster.k8sProvider) "aws") -}}
  {{- print "docker" -}}
{{- else -}}
  {{- $errorMsg := printf "%s  ERROR: rumtime name should be defined." (include "itom-fluentbit.time" .) }}
  {{- fail $errorMsg -}}
{{- end -}}
{{- end -}}

{{/*
generate fluentbit config input path string
*/}}
{{- define "itom-fluentbit.genInputPath" -}}
{{- $baseContainPath := print "/fluentbit/containers/*_" }}
{{- if .Values.daemonSet.namespaceFilter.includes -}}
  {{- print  (printf "%s%s_*.log" $baseContainPath (((trimSuffix "," (nospace .Values.daemonSet.namespaceFilter.includes )) | replace "," "_*.log, ") | replace " " $baseContainPath)) -}}
{{- else -}}
  {{- print "/fluentbit/containers/*.log" -}}
{{- end -}}
{{- end -}}

{{/*
Name: itom-fluentbit.tlsVerify.enabled
Description: return tlsVerify setting
*/}}
{{- define "itom-fluentbit.tlsVerify.enabled" -}}
{{- if (((.Values.logging).output).receiver).tlsVerify -}}
  {{- if kindIs "bool" .Values.logging.output.receiver.tlsVerify -}}
    {{- printf "%s" "On" -}}
  {{- else if (eq  (lower .Values.logging.output.receiver.tlsVerify) "on") -}}
    {{- printf "%s" "On" -}}
  {{- else -}}
    {{- printf "%s" "Off" -}}
  {{- end -}}
{{- else -}}
  {{- printf "%s" "Off" -}}
{{- end -}}
{{- end -}}