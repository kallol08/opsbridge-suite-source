#
# The purpose of the macros in this file is to provide access to externally
# available services.  E.g. IDM can be a service which is deployed by a
# composition chart.  Or it can be an already-existing deployment of IDM
# in another namespace or even another external cluster.
#

#
# All the other macros which need cross-namespace access to a service
# use this one for the detailed implementation, passing in a service name.
#
{{- define "helm-lib.getOtherNsService" -}}
  {{- if .Values.global.services.sharedOpticReporting -}}
    {{- if .Values.global.services.namespace -}}
      {{- printf "%s.%s" .service .Values.global.services.namespace -}}
    {{- else -}}
      {{- if .Values.global.services.internal.host -}}
        {{- printf "%s" .Values.global.services.internal.host -}}
      {{- else -}}
        {{- if .Values.global.services.external.host -}}
          {{- printf "%s" .Values.global.services.external.host -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- else -}}
    {{- if (or (contains "itom-di" .service) (contains "itomdi" .service) (contains "bvd-www" .service) (contains "bvd-explore" .service) ) -}}
      {{- include "helm-lib.getsharedOpticOtherNsService" . -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

#
# New function has been added to support new design to access Shared optic parameter.
#

# This function gets called by other function(helm-lib.getOtherNsService) and
# it is used to access the new design to access shared optic parameter.
#
{{- define "helm-lib.getsharedOpticOtherNsService" -}}
  {{- if ((.Values.global.services).opticDataLake) -}}
    {{- if eq (((.Values.global.services).opticDataLake).deploy | toString) "false" -}}
      {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingNamespace).namespace) -}}
        {{- printf "%s.%s" .service .Values.global.services.opticDataLake.externalOpticDataLake.connectUsingNamespace.namespace -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).ingressControllerHost) -}}
        {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.ingressControllerHost -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingInternalAccessHost).internalAccessHost) -}}
        {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.connectUsingInternalAccessHost.internalAccessHost -}}
      {{- else if (((.Values.global.services.opticDataLake).externalOpticDataLake).externalAccessHost) -}}
        {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.externalAccessHost -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "helm-lib.getIdmAplsService" -}}
  {{- if .Values.global.services.sharedOpticReporting -}}
    {{- if .Values.global.services.namespace -}}
      {{- printf "%s.%s" .service .Values.global.services.namespace -}}
    {{- else -}}
      {{- if .Values.global.services.internal.host -}}
        {{- printf "%s" .Values.global.services.internal.host -}}
      {{- else -}}
        {{- if .Values.global.services.external.host -}}
          {{- printf "%s" .Values.global.services.external.host -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- else -}}
    {{- if (or (contains "itom-idm" .service) (contains "itom-autopass" .service) ) -}}
      {{- include "helm-lib.getsharedIdmAplsService" . -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

#
# New function has been added to support new design to access Shared optic parameter.
#

# This function gets called by other function(helm-lib.getIdmAplsService) and
# it is used to access the new design to access shared optic parameter.
#
{{- define "helm-lib.getsharedIdmAplsService" -}}
  {{- if ((.Values.global.services).opticDataLake) -}}
    {{- if eq (((.Values.global.services).opticDataLake).deploy | toString) "false" -}}
      {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingNamespace).namespace) -}}
        {{- if (or (.Values.global.services.opticDataLake.externalOpticDataLake.isIDMShared) (.Values.global.services.opticDataLake.externalOpticDataLake.isAutopassShared) ) -}}
            {{- printf "%s.%s" .service .Values.global.services.opticDataLake.externalOpticDataLake.connectUsingNamespace.namespace -}}
        {{- else -}}
            {{- printf "%s" .service -}}
        {{- end -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).ingressControllerHost) -}}
        {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.ingressControllerHost -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingInternalAccessHost).internalAccessHost) -}}
        {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.connectUsingInternalAccessHost.internalAccessHost -}}
      {{- else if (((.Values.global.services.opticDataLake).externalOpticDataLake).externalAccessHost) -}}
        {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.externalAccessHost -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "helm-lib.getOtherNsPulsarService" -}}
    {{- if (((((.Values.global.services.opticDataLake).pulsar).externalPulsar).connectUsingNamespace).namespace) -}}
        {{- printf "%s.%s" .service .Values.global.services.opticDataLake.pulsar.externalPulsar.connectUsingNamespace.namespace -}}
    {{- end -}}
{{- end -}}

# This macro defaults to external access host for shared optic reporting
{{- define "helm-lib.getExternalHost" -}}
  {{- include "helm-lib.getSharedOpticExternalHost" . -}}
{{- end -}}

#
# New function has been added to support new design to access Shared optic parameter.
#

# This function gets called by other function(helm-lib.getExternalHost) and
# it is used to access the new design to access shared optic parameter.
#
{{- define "helm-lib.getSharedOpticExternalHost" -}}
  {{- if ((.Values.global.services).opticDataLake) -}}
    {{- if eq (((.Values.global.services).opticDataLake).deploy | toString) "false" -}}
      {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).ingressControllerHost) -}}
        {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.ingressControllerHost -}}
      {{- else -}}
        {{- if (((.Values.global.services.opticDataLake).externalOpticDataLake).externalAccessHost) -}}
          {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.externalAccessHost -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "helm-lib.getExternalPort" -}}
  {{- include "helm-lib.getSharedOpticExternalPort" . -}}
{{- end -}}

#
# New function has been added to support new design to access Shared optic parameter.
#

# This function gets called by other function(helm-lib.getExternalPort) and
# it is used to access the new design to access shared optic parameter.
#
{{- define "helm-lib.getSharedOpticExternalPort" -}}
  {{- if ((.Values.global.services).opticDataLake) -}}
    {{- if eq (((.Values.global.services).opticDataLake).deploy | toString) "false" -}}
      {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).ingressControllerPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.ingressControllerPort | toString) -}}
      {{- else -}}
        {{- if (((.Values.global.services.opticDataLake).externalOpticDataLake).externalAccessPort) -}}
          {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.externalAccessPort | toString) -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

#
# If customer has internal network separate from external network, then
# the "internal host" would be on that internal network.  However if
# there is no internal network, then it is the same as the external
# host of the remote service.  Either way, we want to get access to
# a remote service on the Ingress port, e.g. AutoPass.
#
{{- define "helm-lib.getInternalHost" -}}
  {{- if ((.Values.global.services.internal).host) -}}
    {{- printf "%s" .Values.global.services.internal.host -}}
  {{- else -}}
    {{- if ((.Values.global.services.external).host) -}}
      {{- printf "%s" .Values.global.services.external.host -}}
    {{- else -}}
      {{- include "helm-lib.getSharedOpticInternalHost" . -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

#
# New function has been added to support new design to access Shared optic parameter.
#

# This function gets called by other function(helm-lib.getInternalHost) and
# it is used to access the new design to access shared optic parameter.
#
{{- define "helm-lib.getSharedOpticInternalHost" -}}
  {{- if ((.Values.global.services).opticDataLake) -}}
    {{- if eq (((.Values.global.services).opticDataLake).deploy | toString) "false" -}}
      {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).ingressControllerHost) -}}
        {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.ingressControllerHost -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingInternalAccessHost).internalAccessHost) -}}
        {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.connectUsingInternalAccessHost.internalAccessHost -}}
      {{- else if (((.Values.global.services.opticDataLake).externalOpticDataLake).externalAccessHost) -}}
        {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.externalAccessHost -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

#
# Note that "getInternalPort" just PREFERS an "internal" port over the external port.  It will return
# the external port if internal port is not defined.  If neither internal nor external ports are defined,
# then it will return nothing, and the caller must provide a "default" value.
#
{{- define "helm-lib.getInternalPort" -}}
  {{- if ((.Values.global.services).opticDataLake) -}}
    {{- if eq (.Values.global.services.opticDataLake.deploy | toString) "false" -}}
      {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).ingressControllerPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.ingressControllerPort | toString) -}}
      {{- else if (((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingInternalAccessHost).ingressControllerPort -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingInternalAccessHost.ingressControllerPort | toString) -}}
      {{- else if ((.Values.global.services.opticDataLake).externalOpticDataLake).externalAccessPort -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.externalAccessPort | toString) -}}
      {{- end -}}
    {{- end -}}

  {{- else if ((.Values.global.services.internal).port) -}}
    {{- printf "%s" (.Values.global.services.internal.port | toString) -}}
  {{- else -}}
    {{- if ((.Values.global.services.external).port) -}}
      {{- printf "%s" (.Values.global.services.external.port | toString) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{- define "helm-lib.getAplsHost" -}}
  {{- include "helm-lib.getIdmAplsService" (deepCopy . | merge (dict "service" "itom-autopass-lms"))  -}}
{{- end -}}


{{- define "helm-lib.getAplsPort" -}}
  {{- if (or ((((.Values.global.services).opticDataLake).externalOpticDataLake).connectUsingNamespace).namespace .Values.global.services.namespace) -}}
    {{- printf "5814" -}}
  {{- else -}}
    {{- include "helm-lib.getInternalPort" . -}}
  {{- end -}}
{{- end -}}


{{- define "helm-lib.getDiAdminHost" -}}
  {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).diAdminHost) -}}
    {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.diAdminHost -}}
  {{- else -}}
    {{- include "helm-lib.getOtherNsService" (deepCopy . | merge (dict "service" "itom-di-administration-svc"))  -}}
  {{- end -}}
{{- end -}}


#For cross namespace do nothing and return, so that default value set by the chart can be used, instead of using Nodeport 30004
{{- define "helm-lib.getDiAdminPort" -}}
  {{- if .Values.global.services.sharedOpticReporting -}}
    {{- if .Values.global.services.diAdminPort -}}
      {{- printf "%s" (.Values.global.services.diAdminPort | toString) -}}
    {{- else -}}
      {{- if not (.Values.global.services.namespace) -}}
          {{- printf "30004" -}}
      {{- end -}}
    {{- end -}}
  {{- else -}}
    {{- include "helm-lib.getSharedOpticAdminPort" . -}}
  {{- end -}}
{{- end -}}

#
# New function has been added to support new design to access Shared optic parameter.
#

# This function gets called by other function(helm-lib.getDiAdminPort) and
# it is used to access the new design to access shared optic parameter.
#
{{- define "helm-lib.getSharedOpticAdminPort" -}}
  {{- if ((.Values.global.services).opticDataLake) -}}
    {{- if eq (((.Values.global.services).opticDataLake).deploy | toString) "false" -}}
      {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingExternalAccessHost).diAdminPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingExternalAccessHost.diAdminPort | toString) -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingInternalAccessHost).diAdminPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingInternalAccessHost.diAdminPort | toString) -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).diAdminPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.diAdminPort | toString) -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingNamespace).namespace) -}}
        {{- printf "18443" -}}
      {{- else -}}
        {{- printf "30004" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "helm-lib.getDiDataAccessHost" -}}
  {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).diDataAccessHost) -}}
    {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.diDataAccessHost -}}
  {{- else -}}
    {{- include "helm-lib.getOtherNsService" (deepCopy . | merge (dict "service" "itom-di-data-access-svc"))  -}}
  {{- end -}}
{{- end -}}

#For cross namespace do nothing and return, so that default value set by the chart can be used, instead of using Nodeport 30003
{{- define "helm-lib.getDiDataAccessPort" -}}
  {{- if .Values.global.services.sharedOpticReporting -}}
    {{- if .Values.global.services.diDataAccessPort -}}
      {{- printf "%s" (.Values.global.services.diDataAccessPort | toString) -}}
    {{- else -}}
      {{- if not (.Values.global.services.namespace) -}}
          {{- printf "30003" -}}
      {{- end -}}
    {{- end -}}
  {{- else -}}
    {{- include "helm-lib.getSharedOpticDataAccessPort" . -}}
  {{- end -}}
{{- end -}}

#
# New function has been added to support new design to access Shared optic parameter.
#

# This function gets called by other function(helm-lib.getDiDataAccessPort) and
# it is used to access the new design to access shared optic parameter.
#
{{- define "helm-lib.getSharedOpticDataAccessPort" -}}
  {{- if ((.Values.global.services).opticDataLake) -}}
    {{- if eq (((.Values.global.services).opticDataLake).deploy | toString) "false" -}}
      {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingExternalAccessHost).diDataAccessPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingExternalAccessHost.diDataAccessPort | toString) -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingInternalAccessHost).diDataAccessPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingInternalAccessHost.diDataAccessPort | toString) -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).diDataAccessPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.diDataAccessPort | toString) -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingNamespace).namespace) -}}
        {{- printf "28443" -}}
      {{- else -}}
        {{- printf "30003" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "helm-lib.getDiReceiverHost" -}}
  {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).diReceiverHost) -}}
    {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.diReceiverHost -}}
  {{- else -}}
    {{- include "helm-lib.getOtherNsService" (deepCopy . | merge (dict "service" "itom-di-receiver-svc"))  -}}
  {{- end -}}
{{- end -}}

#For cross namespace do nothing and return, so that default value set by the chart can be used, instead of using Nodeport 30001
{{- define "helm-lib.getDiReceiverPort" -}}
  {{- if .Values.global.services.sharedOpticReporting -}}
    {{- if .Values.global.services.diReceiverPort -}}
      {{- printf "%s" (.Values.global.services.diReceiverPort | toString) -}}
    {{- else -}}
      {{- if not (.Values.global.services.namespace) -}}
          {{- printf "30001" -}}
      {{- end -}}
    {{- end -}}
  {{- else -}}
    {{- include "helm-lib.getSharedOpticReceiverPort" . -}}
  {{- end -}}
{{- end -}}

#
# New function has been added to support new design to access Shared optic parameter.
#

# This function gets called by other function(helm-lib.getDiReceiverPort) and
# it is used to access the new design to access shared optic parameter.
#
{{- define "helm-lib.getSharedOpticReceiverPort" -}}
  {{- if ((.Values.global.services).opticDataLake) -}}
    {{- if eq (((.Values.global.services).opticDataLake).deploy | toString) "false" -}}
      {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingExternalAccessHost).diReceiverPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingExternalAccessHost.diReceiverPort | toString) -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingInternalAccessHost).diReceiverPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingInternalAccessHost.diReceiverPort | toString) -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).diReceiverPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.diReceiverPort | toString) -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingNamespace).namespace) -}}
        {{- printf "5050" -}}
      {{- else -}}
        {{- printf "30001" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "helm-lib.getExternalDiReceiverHost" -}}
  {{- if .Values.global.services.sharedOpticReporting -}}
    {{- if .Values.global.services.external.host -}}
      {{- printf "%s" .Values.global.services.external.host -}}
    {{- end -}}
  {{- else -}}
    {{- include "helm-lib.getSharedOpticReceiverHost" . -}}
  {{- end -}}
{{- end -}}

#
# New function has been added to support new design to access Shared optic parameter.
#

# This function gets called by other function(helm-lib.getExternalDiReceiverHost) and
# it is used to access the new design to access shared optic parameter.
#
{{- define "helm-lib.getSharedOpticReceiverHost" -}}
  {{- if ((.Values.global.services).opticDataLake) -}}
    {{- if eq (((.Values.global.services).opticDataLake).deploy | toString) "false" -}}
      {{- if (((.Values.global.services.opticDataLake).externalOpticDataLake).externalAccessHost) -}}
        {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.externalAccessHost -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "helm-lib.getDiPulsarProxyHost" -}}
  {{- if eq ((((.Values.global.services).opticDataLake).pulsar).deploy | toString) "false" -}}
    {{- include "helm-lib.getOtherNsPulsarService" (deepCopy . | merge (dict "service" "itomdipulsar-proxy"))  -}}
  {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).diPulsarHost) -}}
    {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.diPulsarHost -}}
  {{- else -}}
    {{- include "helm-lib.getOtherNsService" (deepCopy . | merge (dict "service" "itomdipulsar-proxy"))  -}}
  {{- end -}}
{{- end -}}

#For cross namespace do nothing and return, so that default value set by the chart can be used, instead of using Nodeport 31051
{{- define "helm-lib.getDiPulsarProxyClientPort" -}}
  {{- if .Values.global.services.sharedOpticReporting -}}
    {{- if .Values.global.services.diPulsarProxyClientPort -}}
      {{- printf "%s" (.Values.global.services.diPulsarProxyClientPort | toString) -}}
    {{- else -}}
      {{- if not (.Values.global.services.namespace) -}}
          {{- printf "31051" -}}
      {{- end -}}
    {{- end -}}
  {{- else -}}
    {{- include "helm-lib.getSharedOpticPulsarProxyClientPort" . -}}
  {{- end -}}
{{- end -}}

#
# New function has been added to support new design to access Shared optic parameter.
#

# This function gets called by other function(helm-lib.getDiPulsarProxyClientPort) and
# it is used to access the new design to access shared optic parameter.
#
{{- define "helm-lib.getSharedOpticPulsarProxyClientPort" -}}
  {{- if ((.Values.global.services).opticDataLake) -}}
    {{- if eq (((.Values.global.services).opticDataLake).deploy | toString) "false" -}}
      {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingExternalAccessHost).diPulsarSslPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingExternalAccessHost.diPulsarSslPort | toString) -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingInternalAccessHost).diPulsarSslPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingInternalAccessHost.diPulsarSslPort | toString) -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).diPulsarSslPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.diPulsarSslPort | toString) -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingNamespace).namespace) -}}
        {{- printf "6651" -}}
      {{- else -}}
        {{- printf "31051" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

#For cross namespace do nothing and return, so that default value set by the chart can be used, instead of using Nodeport 31001
{{- define "helm-lib.getDiPulsarProxyWebPort" -}}
  {{- if .Values.global.services.sharedOpticReporting -}}
    {{- if .Values.global.services.diPulsarProxyWebPort -}}
      {{- printf "%s" (.Values.global.services.diPulsarProxyWebPort | toString) -}}
    {{- else -}}
      {{- if not (.Values.global.services.namespace) -}}
          {{- printf "31001" -}}
      {{- end -}}
    {{- end -}}
  {{- else -}}
    {{- include "helm-lib.getSharedOpticPulsarProxyWebPort" . -}}
  {{- end -}}
{{- end -}}

#
# New function has been added to support new design to access Shared optic parameter.
#

# This function gets called by other function(helm-lib.getDiPulsarProxyWebPort) and
# it is used to access the new design to access shared optic parameter.
#
{{- define "helm-lib.getSharedOpticPulsarProxyWebPort" -}}
  {{- if ((.Values.global.services).opticDataLake) -}}
    {{- if eq (((.Values.global.services).opticDataLake).deploy | toString) "false" -}}
      {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingExternalAccessHost).diPulsarWebPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingExternalAccessHost.diPulsarWebPort | toString) -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingInternalAccessHost).diPulsarWebPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingInternalAccessHost.diPulsarWebPort | toString) -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).diPulsarWebPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.diPulsarWebPort | toString) -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingNamespace).namespace) -}}
        {{- printf "8443" -}}
      {{- else -}}
        {{- printf "31001" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "helm-lib.getExternalIdmHost" -}}
  {{- include "helm-lib.getSharedOpticIdmHost" . -}}
{{- end -}}

#
# New function has been added to support new design to access Shared optic parameter.
#

# This function gets called by other function(helm-lib.getExternalIdmHost) and
# it is used to access the new design to access shared optic parameter.
#
{{- define "helm-lib.getSharedOpticIdmHost" -}}
  {{- if ((.Values.global.services).opticDataLake) -}}
    {{- if eq (((.Values.global.services).opticDataLake).deploy | toString) "false" -}}
      {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).ingressControllerHost) -}}
        {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.ingressControllerHost -}}
      {{- else -}}
        {{- if (((.Values.global.services.opticDataLake).externalOpticDataLake).externalAccessHost) -}}
          {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.externalAccessHost -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "helm-lib.getExternalIdmPort" -}}
  {{- include "helm-lib.getExternalPort" . -}}
{{- end -}}


#
# Internal host can use cross-namespace access, if allowed.  Otherwise
# look for internal network configuration.  If neither, then default
# to external host.
#
{{- define "helm-lib.getInternalIdmHost" -}}
  {{- if (((.Values.global.services.opticDataLake).externalOpticDataLake).isIDMShared) -}}
    {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).ingressControllerHost) -}}
      {{- printf "%s" .Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.ingressControllerHost -}}
    {{- else -}}
      {{- include "helm-lib.getIdmAplsService" (deepCopy . | merge (dict "service" "itom-idm-svc"))  -}}
    {{- end -}}
  {{- else -}}
    {{- printf "itom-idm-svc" -}}
  {{- end -}}
{{- end -}}

{{- define "helm-lib.getInternalIdmPort" -}}
  {{- if (((.Values.global.services.opticDataLake).externalOpticDataLake).isIDMShared) -}}
    {{- if .Values.global.services.namespace -}}
      {{- printf "18443" -}}
    {{- else if ((.Values.global.services.internal).port) -}}
      {{- printf "%s" (.Values.global.services.internal.port | toString) -}}
    {{- else if ((.Values.global.services.external).port) -}}
      {{- printf "%s" (.Values.global.services.external.port | toString) -}}
    {{- else -}}
      {{- include "helm-lib.getSharedOpticInternalIdmPort" . -}}
    {{- end -}}
  {{- else -}}
    {{- printf "18443" -}}
  {{- end -}}
{{- end -}}

#
# New function has been added to support new design to access Shared optic parameter.
#

# This function gets called by other functions (helm-lib.getInternalIdmPort) and
# it is used to access the new design to access shared optic parameter.
#
{{- define "helm-lib.getSharedOpticInternalIdmPort" -}}
  {{- if ((.Values.global.services).opticDataLake) -}}
    {{- if eq (((.Values.global.services).opticDataLake).deploy | toString) "false" -}}
      {{- if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingNamespace).namespace) -}}
        {{- printf "18443" -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingInternalAccessHost).ingressControllerPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingInternalAccessHost.ingressControllerPort | toString) -}}
      {{- else if ((((.Values.global.services.opticDataLake).externalOpticDataLake).connectUsingServiceFQDN).ingressControllerPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.connectUsingServiceFQDN.ingressControllerPort | toString) -}}
      {{- else if (((.Values.global.services.opticDataLake).externalOpticDataLake).externalAccessPort) -}}
        {{- printf "%s" (.Values.global.services.opticDataLake.externalOpticDataLake.externalAccessPort | toString) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

#For cross namespace do nothing and return, so that default value set by the chart can be used
#This method is invoked only by opticdl components and will not be called when opticdl is external
#
{{- define "helm-lib.getDiPulsarBrokerClientPort" -}}
  {{- if eq ((((.Values.global.services).opticDataLake).pulsar).deploy | toString) "false" -}}
    {{- if (((((.Values.global.services.opticDataLake).pulsar).externalPulsar).connectUsingNamespace).namespace) -}}
      {{- if .Values.global.services.diPulsarBrokerClientPort -}}
        {{- printf "%s" (.Values.global.services.diPulsarBrokerClientPort | toString) -}}   
      {{- else -}}
        {{- printf "6651" -}}
      {{- end -}}
    {{- end -}}
  {{- else -}}
    {{- printf "6651" -}}
  {{- end -}}
{{- end -}}

#This method is invoked only by opticdl components and will not be called when opticdl is external
#
{{- define "helm-lib.getDiPulsarBrokerHost" -}}
  {{- if eq ((((.Values.global.services).opticDataLake).pulsar).deploy | toString) "false" -}}
    {{- if (((((.Values.global.services.opticDataLake).pulsar).externalPulsar).connectUsingNamespace).namespace) -}}
      {{- include "helm-lib.getOtherNsPulsarService" (deepCopy . | merge (dict "service" "itomdipulsar-broker"))  -}}    
    {{- else -}}
      {{- printf "itomdipulsar-broker" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "itomdipulsar-broker" -}}
  {{- end -}}
{{- end -}}

#For cross namespace do nothing and return, so that default value set by the chart can be used.
#This method is invoked only by opticdl components and will not be called when opticdl is external
#
{{- define "helm-lib.getDiPulsarBrokerWebPort" -}}
  {{- if eq ((((.Values.global.services).opticDataLake).pulsar).deploy | toString) "false" -}}
    {{- if (((((.Values.global.services.opticDataLake).pulsar).externalPulsar).connectUsingNamespace).namespace) -}}
      {{- if .Values.global.services.diPulsarBrokerWebPort -}}
        {{- printf "%s" (.Values.global.services.diPulsarBrokerWebPort | toString) -}}   
      {{- else -}}
        {{- printf "8443" -}}
      {{- end -}}
    {{- end -}}
  {{- else -}}
    {{- printf "8443" -}}
  {{- end -}}
{{- end -}}

{{- define "helm-lib.getExternalBvdHost" -}}
  {{- include "helm-lib.getExternalHost" . -}}
{{- end -}}

{{- define "helm-lib.getExternalBvdPort" -}}
  {{- include "helm-lib.getExternalPort" . -}}
{{- end -}}

#
# Internal host can use cross-namespace access, if allowed.  Otherwise
# look for internal network configuration.  If neither, then default
# to external host.
#
{{- define "helm-lib.getInternalBvdHost" -}}
  {{- include "helm-lib.getOtherNsService" (deepCopy . | merge (dict "service" "bvd-www"))  -}}
{{- end -}}

{{- define "helm-lib.getBvdExploreHost" -}}
  {{- include "helm-lib.getOtherNsService" (deepCopy . | merge (dict "service" "bvd-explore"))  -}}
{{- end -}}

{{- define "helm-lib.getInternalBvdPort" -}}
  {{- if (or ((((.Values.global.services).opticDataLake).externalOpticDataLake).connectUsingNamespace).namespace .Values.global.services.namespace) -}}
    {{- printf "4000" -}}
  {{- else -}}
    {{- include "helm-lib.getInternalPort" . -}}
  {{- end -}}
{{- end -}}
