#===========================================================================
# serviceName(instance:INSTANCE, suffix:SUFFIX)
# If "global.instance.INSTANCE" is defined, which is a Helm release name,
# then that specific instance of the desired service is returned.  Otherwise,
# the current Helm release name is prepended to the service name.  For example:
#
#   serviceName(instance:myService, suffix:mySuffix) will yield:
#       RELEASE_NAME-mySuffix            if global.instance.myService is not defined
#       FOO-mySuffix                     When global.instance.myService==FOO
#
#   similarly, serviceName(instance:zookeeper, suffix:zk-svc) will yield:
#       RELEASE_NAME-zk-svc              if global.instance.zookeeper is not defined
#       cold-fish-zk-svc                 When global.instance.zookeeper==cold-fish
#
{{- define "helm-lib.serviceName" -}}
{{- $instanceName := cat ".Values.global.instance." .instance | nospace -}}
{{- $evalInstanceName := cat "{{ " $instanceName " }}" -}}
{{- if tpl $evalInstanceName . -}}
{{- $serviceName := cat $evalInstanceName "-" .suffix | nospace -}}
{{- tpl $serviceName . -}}
{{- else -}}
{{- cat .Release.Name "-" .suffix | nospace -}}
{{- end -}}
{{- end -}}


#===========================================================================
# Returns the name of the zookeeper service (using "global.instance.zookeeper").
# For example: "cold-fish-zk-svc".
#
{{- define "helm-lib.serviceName.zookeeper" -}}
{{- include "helm-lib.serviceName" ( dict "instance" "zookeeper" "suffix" "zk-svc" "Release" .Release "Values" .Values "Template" .Template) }}
{{- end -}}


#===========================================================================
# Returns the name of the Postgres service (using "global.instance.postgres").
# For example: "cold-fish-itom-postgresql.NAMESPACE".
#
{{- define "helm-lib.serviceName.postgres" -}}
{{- include "helm-lib.serviceName" (dict "instance" "postgres" "suffix" "itom-postgresql" "Release" .Release "Values" .Values "Template" .Template) }}.{{ .Release.Namespace -}}
{{- end -}}
