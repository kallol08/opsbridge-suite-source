#===========================================================================
# internalLBAnnotations()
# https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
#
{{- define "helm-lib.service.internalLBAnnotations" -}}
{{- $provider := include "helm-lib.service.getKubernetesProvider" . }}

{{- if eq $provider "aws" }}
service.beta.kubernetes.io/aws-load-balancer-internal: "true"
service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
{{- else if eq $provider "azure" }}
service.beta.kubernetes.io/azure-load-balancer-internal: "true"
{{- else if eq $provider "alicloud" }}
service.beta.kubernetes.io/alibaba-cloud-loadbalancer-address-type: "intranet"
{{- else if eq $provider "gcp" }}
cloud.google.com/load-balancer-type: "Internal"
{{- else if eq $provider "oci" }}
service.beta.kubernetes.io/oci-load-balancer-internal: "true"
{{- else if eq $provider "openshift" }}
service.beta.kubernetes.io/openstack-internal-load-balancer: "true"
{{- else if eq $provider "none" }}
{{- end }}
{{ include "helm-lib.service.getInternalLBAnnotations" . }}
{{- end }}

#===========================================================================
# getKubernetesProvider()
#
{{- define "helm-lib.service.getKubernetesProvider" -}}
{{- $provider := "" -}}
{{- if .Values.global.cluster -}}
  {{- if .Values.global.cluster.k8sProvider -}}
    {{- $provider = .Values.global.cluster.k8sProvider -}}
  {{- end -}}
{{- end -}}
{{- if and ( .Values.global.k8sProvider) (not $provider) -}}
  {{- $provider = .Values.global.k8sProvider -}}
{{- end -}}
{{- if not $provider -}}
{{- $provider = "cdf" -}}
{{- end -}}
{{- printf "%s" $provider -}}
{{- end -}}

#====================================================================================
# Returns the value of the serviceType based on the provider
# The following ServiceTypes are supported for network communication:
# NodePort, ClusterIP, Load Balancer
#
# getServiceType()
{{- define "helm-lib.service.getServiceType" -}}
  {{- $exposeType := "" -}}
  {{- if (.Values.expose).type -}}
    {{- $exposeType = .Values.expose.type -}}
  {{- else if (.Values.global.expose).type -}}
    {{- $exposeType = .Values.global.expose.type -}}
  {{- end -}}

  {{- $provider := include "helm-lib.service.getKubernetesProvider" . -}}

  {{ $serviceType := "" -}}
  {{- if or (eq "aws" $provider) (eq "azure" $provider) -}}
    {{- $serviceType = (default "LoadBalancer" $exposeType) -}}
  {{- else }}
    {{- $serviceType = (default "NodePort" $exposeType) -}}
  {{- end -}}
  {{- printf "%s" $serviceType -}}
{{- end -}}

#====================================================================================
# Returns the LoadBalancer IP address
# This is only applicable when the serviceType is 'LoadBalancer'
# getLoadBalancerIP()
{{- define "helm-lib.service.getLoadBalancerIP" -}}
{{- $serviceType := include "helm-lib.service.getServiceType" . -}}
{{- if and (((.Values.global.expose).internalLoadBalancer).ip) (eq $serviceType "LoadBalancer") -}}
  {{- printf "loadBalancerIP: %s" .Values.global.expose.internalLoadBalancer.ip | nindent 2 -}}
{{- end -}}
{{- end -}}

#====================================================================================
# Returns the LoadBalancer Source Ranges
# Specify the IP ranges that are allowed to access the load balancer
# getLoadBalancerSourceRanges()
{{- define "helm-lib.service.getLoadBalancerSourceRanges" -}}
{{- if (((.Values.global.expose).internalLoadBalancer).sourceRanges) -}}
  {{- printf "loadBalancerSourceRanges: "  | nindent 2 -}}
  {{- toYaml .Values.global.expose.internalLoadBalancer.sourceRanges | nindent 2 -}}
{{- end -}}
{{- end -}}

#=====================================================================================
# Returns the Internal LoadBalancer annotations
# Specify the annotations
# getInternalLBAnnotations()

{{- define "helm-lib.service.getInternalLBAnnotations" -}}
    {{- if ((((.Values.global).expose).internalLoadBalancer).annotations) -}}
        {{- range $key, $val := .Values.global.expose.internalLoadBalancer.annotations -}}
            {{- printf "%s: \"%s\"\n" $key $val -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

#====================================================================================
# Returns the external LoadBalancer IP address
# This is only applicable when the serviceType is 'LoadBalancer'
# getExternalLoadBalancerIP()
{{- define "helm-lib.service.getExternalLoadBalancerIP" -}}
{{- $serviceType := include "helm-lib.service.getServiceType" . -}}
{{- if and (((.Values.global.expose).externalLoadBalancer).ip) (eq $serviceType "LoadBalancer") -}}
  {{- printf "loadBalancerIP: %s" .Values.global.expose.externalLoadBalancer.ip | nindent 2 -}}
{{- end -}}
{{- end -}}

#=====================================================================================
# Returns the External LoadBalancer annotations
# Specify the annotations
# getExternalLBAnnotations()

{{- define "helm-lib.service.getExternalLBAnnotations" -}}
    {{- if ((((.Values.global).expose).externalLoadBalancer).annotations) -}}
        {{- range $key, $val := .Values.global.expose.externalLoadBalancer.annotations -}}
            {{- printf "%s: \"%s\"\n" $key $val -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

#=====================================================================================
# Returns the External LoadBalancer Source Ranges
# Specify the IP ranges that are allowed to access the load balancer
# getExternalLBSourceRanges()

{{- define "helm-lib.service.getExternalLBSourceRanges" -}}
{{- if (((.Values.global.expose).externalLoadBalancer).sourceRanges) -}}
  {{- printf "loadBalancerSourceRanges: "  | nindent 2 -}}
  {{- toYaml .Values.global.expose.externalLoadBalancer.sourceRanges | nindent 2 -}}
{{- end -}}
{{- end -}}

#=====================================================================================
# Returns the External LoadBalancer ExternalIPs
# Specify the externalIPs that are allowed to access the load balancer
# getExternalLBExternalIPs()

{{- define "helm-lib.service.getExternalLBExternalIPs" -}}
{{- if (((.Values.global.expose).externalLoadBalancer).externalIPs) -}}
  {{- printf "externalIPs: "  | nindent 2 -}}
  {{- toYaml .Values.global.expose.externalLoadBalancer.externalIPs | nindent 2 -}}
{{- end -}}
{{- end -}}

#=====================================================================================
# Returns the IpFamiliy and IpFamilies yaml snippet for k8s service
# Specify the annotations
# getIpConfig()

{{- define "helm-lib.service.getIpConfig" -}}
  {{- if ((((.Values.global).expose).ipConfig).ipFamilyPolicy) -}}
    {{- printf "ipFamilyPolicy: %s\n" .Values.global.expose.ipConfig.ipFamilyPolicy -}}
  {{- end -}}
  {{- if ((((.Values.global).expose).ipConfig).ipFamilies) -}}
    {{- printf "ipFamilies: \n" -}}
    {{- toYaml .Values.global.expose.ipConfig.ipFamilies  -}}
  {{- end -}}
{{- end -}}
