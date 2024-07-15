#===========================================================================
# confirmEula()
# This function will confirm that the customer has accepted the EULA, by
# setting "acceptEula=true".  The default will be "false", of course.
# If EULA is not accepted, then deployment of the chart will exit with error.
#
{{- define "helm-lib.confirmEula" -}}
{{- if not (kindIs "bool" .Values.acceptEula) -}}
{{- cat "\n\nERROR: You must accept the Open Text EULA by setting acceptEula=true" | fail -}}
{{- else -}}
{{- if .Values.acceptEula -}}
acceptedEULA: {{ .Values.acceptEula | quote }}
{{- else -}}
{{- cat "\n\nERROR: You must accept the Open Text EULA by setting acceptEula=true" | fail -}}
{{- end -}}
{{- end -}}
{{- end -}}


#===========================================================================
# injectVar(varName:VARName, Values:Values, Template:Template)
# Enables a global configmap to be defined, in the composition chart, and service
# charts will inherit values from that config map.  If the global.configMap is not
# defined, then the properties become normal "values.yaml" properties.  Example:
#
# injectVar(varName:"foo.bar.env1") expands to equivalent of:
#
#    if (global.configMap) {
#        valueFrom:
#          configMapRef:
#            name: my-configmap     # whatever the value of global.configMap is
#            key: foo.bar.env1
#    } else {
#        value: foo.bar.env1
#    }
# 
{{- define "helm-lib.injectVar" -}}
{{- $varName := .varName -}}
{{- if .Values.global.configMap -}}
valueFrom:
  configMapKeyRef:
{{ cat "    name:" .Values.global.configMap }}
{{ cat "    key:" $varName }}
{{- else -}}
{{- $fullVarName := cat "{{ .Values." .varName " | quote }}" | nospace -}}
{{- $fullVarValue := tpl $fullVarName . }}
{{- cat "value:" $fullVarValue -}}
{{- end -}}
{{- end -}}

#===========================================================================
# apiVersion(kind:kind)
# Get apiVersion according to the provided kind value and based on current kubernetes minor version from 15 to 19.
#
{{- define "helm-lib.apiVersion" -}}
{{- $gvk21 := dict "Binding" "v1" "ComponentStatus" "v1" "ConfigMap" "v1" "Endpoints" "v1" "Event" "v1" "LimitRange" "v1" "Namespace" "v1" "Node" "v1" "PersistentVolumeClaim" "v1" "PersistentVolume" "v1" "Pod" "v1" "PodTemplate" "v1" "ReplicationController" "v1" "ResourceQuota" "v1" "Secret" "v1" "ServiceAccount" "v1" "Service" "v1" "MutatingWebhookConfiguration" "admissionregistration.k8s.io/v1" "ValidatingWebhookConfiguration" "admissionregistration.k8s.io/v1" "CustomResourceDefinition" "apiextensions.k8s.io/v1" "APIService" "apiregistration.k8s.io/v1" "ControllerRevision" "apps/v1" "DaemonSet" "apps/v1" "Deployment" "apps/v1" "ReplicaSet" "apps/v1" "StatefulSet" "apps/v1" "TokenReview" "authentication.k8s.io/v1" "LocalSubjectAccessReview" "authorization.k8s.io/v1" "SelfSubjectAccessReview" "authorization.k8s.io/v1" "SelfSubjectRulesReview" "authorization.k8s.io/v1" "SubjectAccessReview" "authorization.k8s.io/v1" "HorizontalPodAutoscaler" "autoscaling/v1" "CronJob" "batch/v1beta1" "Job" "batch/v1" "CertificateSigningRequest" "certificates.k8s.io/v1" "Lease" "coordination.k8s.io/v1" "EndpointSlice" "discovery.k8s.io/v1beta1" "Ingress" "networking.k8s.io/v1" "FlowSchema" "flowcontrol.apiserver.k8s.io/v1alpha1" "PriorityLevelConfiguration" "flowcontrol.apiserver.k8s.io/v1alpha1" "IngressClass" "networking.k8s.io/v1" "NetworkPolicy" "networking.k8s.io/v1" "RuntimeClass" "node.k8s.io/v1beta1" "PodDisruptionBudget" "policy/v1" "PodSecurityPolicy" "policy/v1beta1" "ClusterRoleBinding" "rbac.authorization.k8s.io/v1" "ClusterRole" "rbac.authorization.k8s.io/v1" "RoleBinding" "rbac.authorization.k8s.io/v1" "Role" "rbac.authorization.k8s.io/v1" "PriorityClass" "scheduling.k8s.io/v1" "CSIDriver" "storage.k8s.io/v1" "CSINode" "storage.k8s.io/v1" "StorageClass" "storage.k8s.io/v1" "VolumeAttachment" "storage.k8s.io/v1" -}}
{{- $gvk19 := dict "Binding" "v1" "ComponentStatus" "v1" "ConfigMap" "v1" "Endpoints" "v1" "Event" "v1" "LimitRange" "v1" "Namespace" "v1" "Node" "v1" "PersistentVolumeClaim" "v1" "PersistentVolume" "v1" "Pod" "v1" "PodTemplate" "v1" "ReplicationController" "v1" "ResourceQuota" "v1" "Secret" "v1" "ServiceAccount" "v1" "Service" "v1" "MutatingWebhookConfiguration" "admissionregistration.k8s.io/v1" "ValidatingWebhookConfiguration" "admissionregistration.k8s.io/v1" "CustomResourceDefinition" "apiextensions.k8s.io/v1" "APIService" "apiregistration.k8s.io/v1" "ControllerRevision" "apps/v1" "DaemonSet" "apps/v1" "Deployment" "apps/v1" "ReplicaSet" "apps/v1" "StatefulSet" "apps/v1" "TokenReview" "authentication.k8s.io/v1" "LocalSubjectAccessReview" "authorization.k8s.io/v1" "SelfSubjectAccessReview" "authorization.k8s.io/v1" "SelfSubjectRulesReview" "authorization.k8s.io/v1" "SubjectAccessReview" "authorization.k8s.io/v1" "HorizontalPodAutoscaler" "autoscaling/v1" "CronJob" "batch/v1beta1" "Job" "batch/v1" "CertificateSigningRequest" "certificates.k8s.io/v1" "Lease" "coordination.k8s.io/v1" "EndpointSlice" "discovery.k8s.io/v1beta1" "Ingress" "networking.k8s.io/v1" "FlowSchema" "flowcontrol.apiserver.k8s.io/v1alpha1" "PriorityLevelConfiguration" "flowcontrol.apiserver.k8s.io/v1alpha1" "IngressClass" "networking.k8s.io/v1" "NetworkPolicy" "networking.k8s.io/v1" "RuntimeClass" "node.k8s.io/v1beta1" "PodDisruptionBudget" "policy/v1beta1" "PodSecurityPolicy" "policy/v1beta1" "ClusterRoleBinding" "rbac.authorization.k8s.io/v1" "ClusterRole" "rbac.authorization.k8s.io/v1" "RoleBinding" "rbac.authorization.k8s.io/v1" "Role" "rbac.authorization.k8s.io/v1" "PriorityClass" "scheduling.k8s.io/v1" "CSIDriver" "storage.k8s.io/v1" "CSINode" "storage.k8s.io/v1" "StorageClass" "storage.k8s.io/v1" "VolumeAttachment" "storage.k8s.io/v1" -}}
{{- $gvk18 := dict "Binding" "v1" "ComponentStatus" "v1" "ConfigMap" "v1" "Endpoints" "v1" "Event" "v1" "LimitRange" "v1" "Namespace" "v1" "Node" "v1" "PersistentVolumeClaim" "v1" "PersistentVolume" "v1" "Pod" "v1" "PodTemplate" "v1" "ReplicationController" "v1" "ResourceQuota" "v1" "Secret" "v1" "ServiceAccount" "v1" "Service" "v1" "MutatingWebhookConfiguration" "admissionregistration.k8s.io/v1" "ValidatingWebhookConfiguration" "admissionregistration.k8s.io/v1" "CustomResourceDefinition" "apiextensions.k8s.io/v1" "APIService" "apiregistration.k8s.io/v1" "ControllerRevision" "apps/v1" "DaemonSet" "apps/v1" "Deployment" "apps/v1" "ReplicaSet" "apps/v1" "StatefulSet" "apps/v1" "TokenReview" "authentication.k8s.io/v1" "LocalSubjectAccessReview" "authorization.k8s.io/v1" "SelfSubjectAccessReview" "authorization.k8s.io/v1" "SelfSubjectRulesReview" "authorization.k8s.io/v1" "SubjectAccessReview" "authorization.k8s.io/v1" "HorizontalPodAutoscaler" "autoscaling/v1" "CronJob" "batch/v1beta1" "Job" "batch/v1" "CertificateSigningRequest" "certificates.k8s.io/v1beta1" "Lease" "coordination.k8s.io/v1beta1" "EndpointSlice" "discovery.k8s.io/v1beta1" "Ingress" "networking.k8s.io/v1beta1" "FlowSchema" "flowcontrol.apiserver.k8s.io/v1alpha1" "PriorityLevelConfiguration" "flowcontrol.apiserver.k8s.io/v1alpha1" "IngressClass" "networking.k8s.io/v1beta1" "NetworkPolicy" "networking.k8s.io/v1" "RuntimeClass" "node.k8s.io/v1beta1" "PodDisruptionBudget" "policy/v1beta1" "PodSecurityPolicy" "policy/v1beta1" "ClusterRoleBinding" "rbac.authorization.k8s.io/v1" "ClusterRole" "rbac.authorization.k8s.io/v1" "RoleBinding" "rbac.authorization.k8s.io/v1" "Role" "rbac.authorization.k8s.io/v1" "PriorityClass" "scheduling.k8s.io/v1" "CSIDriver" "storage.k8s.io/v1" "CSINode" "storage.k8s.io/v1" "StorageClass" "storage.k8s.io/v1" "VolumeAttachment" "storage.k8s.io/v1" -}}
{{- $gvk17 := dict "Binding" "v1" "ComponentStatus" "v1" "ConfigMap" "v1" "Endpoints" "v1" "Event" "v1" "LimitRange" "v1" "Namespace" "v1" "Node" "v1" "PersistentVolumeClaim" "v1" "PersistentVolume" "v1" "Pod" "v1" "PodTemplate" "v1" "ReplicationController" "v1" "ResourceQuota" "v1" "Secret" "v1" "ServiceAccount" "v1" "Service" "v1" "MutatingWebhookConfiguration" "admissionregistration.k8s.io/v1" "ValidatingWebhookConfiguration" "admissionregistration.k8s.io/v1" "CustomResourceDefinition" "apiextensions.k8s.io/v1" "APIService" "apiregistration.k8s.io/v1" "ControllerRevision" "apps/v1" "DaemonSet" "apps/v1" "Deployment" "apps/v1" "ReplicaSet" "apps/v1" "StatefulSet" "apps/v1" "TokenReview" "authentication.k8s.io/v1" "LocalSubjectAccessReview" "authorization.k8s.io/v1" "SelfSubjectAccessReview" "authorization.k8s.io/v1" "SelfSubjectRulesReview" "authorization.k8s.io/v1" "SubjectAccessReview" "authorization.k8s.io/v1" "HorizontalPodAutoscaler" "autoscaling/v1" "CronJob" "batch/v1beta1" "Job" "batch/v1" "CertificateSigningRequest" "certificates.k8s.io/v1beta1" "Lease" "coordination.k8s.io/v1beta1" "EndpointSlice" "discovery.k8s.io/v1beta1" "Ingress" "networking.k8s.io/v1beta1" "FlowSchema" "flowcontrol.apiserver.k8s.io/v1alpha1" "PriorityLevelConfiguration" "flowcontrol.apiserver.k8s.io/v1alpha1" "NetworkPolicy" "networking.k8s.io/v1" "RuntimeClass" "node.k8s.io/v1beta1" "PodDisruptionBudget" "policy/v1beta1" "PodSecurityPolicy" "policy/v1beta1" "ClusterRoleBinding" "rbac.authorization.k8s.io/v1" "ClusterRole" "rbac.authorization.k8s.io/v1" "RoleBinding" "rbac.authorization.k8s.io/v1" "Role" "rbac.authorization.k8s.io/v1" "PriorityClass" "scheduling.k8s.io/v1" "CSIDriver" "storage.k8s.io/v1beta1" "CSINode" "storage.k8s.io/v1" "StorageClass" "storage.k8s.io/v1" "VolumeAttachment" "storage.k8s.io/v1" -}}
{{- $gvk16 := dict "Binding" "v1" "ComponentStatus" "v1" "ConfigMap" "v1" "Endpoints" "v1" "Event" "v1" "LimitRange" "v1" "Namespace" "v1" "Node" "v1" "PersistentVolumeClaim" "v1" "PersistentVolume" "v1" "Pod" "v1" "PodTemplate" "v1" "ReplicationController" "v1" "ResourceQuota" "v1" "Secret" "v1" "ServiceAccount" "v1" "Service" "v1" "MutatingWebhookConfiguration" "admissionregistration.k8s.io/v1" "ValidatingWebhookConfiguration" "admissionregistration.k8s.io/v1" "CustomResourceDefinition" "apiextensions.k8s.io/v1" "APIService" "apiregistration.k8s.io/v1" "ControllerRevision" "apps/v1" "DaemonSet" "apps/v1" "Deployment" "apps/v1" "ReplicaSet" "apps/v1" "StatefulSet" "apps/v1" "TokenReview" "authentication.k8s.io/v1" "LocalSubjectAccessReview" "authorization.k8s.io/v1" "SelfSubjectAccessReview" "authorization.k8s.io/v1" "SelfSubjectRulesReview" "authorization.k8s.io/v1" "SubjectAccessReview" "authorization.k8s.io/v1" "HorizontalPodAutoscaler" "autoscaling/v1" "CronJob" "batch/v1beta1" "Job" "batch/v1" "CertificateSigningRequest" "certificates.k8s.io/v1beta1" "Lease" "coordination.k8s.io/v1" "EndpointSlice" "discovery.k8s.io/v1alpha1" "Ingress" "networking.k8s.io/v1beta1" "NetworkPolicy" "networking.k8s.io/v1" "RuntimeClass" "node.k8s.io/v1beta1" "PodDisruptionBudget" "policy/v1beta1" "PodSecurityPolicy" "policy/v1beta1" "ClusterRoleBinding" "rbac.authorization.k8s.io/v1" "ClusterRole" "rbac.authorization.k8s.io/v1" "RoleBinding" "rbac.authorization.k8s.io/v1" "Role" "rbac.authorization.k8s.io/v1" "PriorityClass" "scheduling.k8s.io/v1" "CSIDriver" "storage.k8s.io/v1beta1" "CSINode" "storage.k8s.io/v1beta1" "StorageClass" "storage.k8s.io/v1" "VolumeAttachment" "storage.k8s.io/v1" -}}
{{- $gvk15 := dict "Binding" "v1" "ComponentStatus" "v1" "ConfigMap" "v1" "Endpoints" "v1" "Event" "v1" "LimitRange" "v1" "Namespace" "v1" "Node" "v1" "PersistentVolumeClaim" "v1" "PersistentVolume" "v1" "Pod" "v1" "PodTemplate" "v1" "ReplicationController" "v1" "ResourceQuota" "v1" "Secret" "v1" "ServiceAccount" "v1" "Service" "v1" "MutatingWebhookConfiguration" "admissionregistration.k8s.io/v1beta1" "ValidatingWebhookConfiguration" "admissionregistration.k8s.io/v1beta1" "CustomResourceDefinition" "apiextensions.k8s.io/v1beta1" "APIService" "apiregistration.k8s.io/v1" "ControllerRevision" "apps/v1" "DaemonSet" "apps/v1" "Deployment" "apps/v1" "ReplicaSet" "apps/v1" "StatefulSet" "apps/v1" "TokenReview" "authentication.k8s.io/v1" "LocalSubjectAccessReview" "authorization.k8s.io/v1" "SelfSubjectAccessReview" "authorization.k8s.io/v1" "SelfSubjectRulesReview" "authorization.k8s.io/v1" "SubjectAccessReview" "authorization.k8s.io/v1" "HorizontalPodAutoscaler" "autoscaling/v1" "CronJob" "batch/v1beta1" "Job" "batch/v1" "CertificateSigningRequest" "certificates.k8s.io/v1beta1" "Lease" "coordination.k8s.io/v1" "Ingress" "networking.k8s.io/v1beta1" "NetworkPolicy" "networking.k8s.io/v1" "RuntimeClass" "node.k8s.io/v1beta1" "PodDisruptionBudget" "policy/v1beta1" "PodSecurityPolicy" "policy/v1beta1" "ClusterRoleBinding" "rbac.authorization.k8s.io/v1" "ClusterRole" "rbac.authorization.k8s.io/v1" "RoleBinding" "rbac.authorization.k8s.io/v1" "Role" "rbac.authorization.k8s.io/v1" "PriorityClass" "scheduling.k8s.io/v1" "CSIDriver" "storage.k8s.io/v1beta1" "CSINode" "storage.k8s.io/v1beta1" "StorageClass" "storage.k8s.io/v1" "VolumeAttachment" "storage.k8s.io/v1" -}}
{{- if ge .Capabilities.KubeVersion.Minor "21" -}}
{{ get $gvk21 .kind }}
{{- else if ge .Capabilities.KubeVersion.Minor "19" -}}
{{ get $gvk19 .kind }}
{{- else if eq .Capabilities.KubeVersion.Minor "18" -}}
{{ get $gvk18 .kind }}
{{- else if eq .Capabilities.KubeVersion.Minor "17" -}}
{{ get $gvk17 .kind }}
{{- else if eq .Capabilities.KubeVersion.Minor "16" -}}
{{ get $gvk16 .kind }}
{{- else if le .Capabilities.KubeVersion.Minor "15" -}}
{{ get $gvk15 .kind }}
{{- end -}}
{{- end -}}

#===========================================================================
# getObjectName(name:name, Release:Release, Values:Values)
# This macro can generate the objectName follow the rules as below.
#
# The objectName consists of namePrefix and name:
# 1. All names (service name, deployment name, config map name, etc.) will be prefixed as per following rules:
# if `.Values.namePrefix` is injected, then use that.
# else if `.Values.backwardsCompat` flag is true, prefix with Helm Release.Name, as per previous releases.
# else prefix with "itom", since we want to STOP (i.e. deprecate) using Helm Release.Name in service names.
# 2. Pass the name in via "name".
#
# Here is an example of the call:
#
# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   name: {{ include "helm-lib.getObjectName" (dict "name" "nginx-ingress" "Release" .Release "Values" .Values ) }}
#
{{- define "helm-lib.getObjectName" -}}
{{- $name := .name -}}
{{- if and (not .Values.namePrefix) .Values.backwardsCompatServiceName -}}
{{- printf "%s-itom-%s" .Release.Name $name | trunc 63  | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" (default "itom" .Values.namePrefix) $name | trunc 63  | trimSuffix "-" -}}
{{- end -}}
{{- end -}}



{{/*===========================================================================
   * helm-lib.dig(map:.Values, key:<varToFind>, default:<defaultValue>)
   *
   * Used to look for a Helm variable by name, "digging" into the Map structure.
   * For example, to look for ".Values.global.foo.bar.abc.xyz", where any point
   * along the way (foo, foo.bar, foo.bar.abc, etc.) might be undefined:
   *
   * (include "helm-lib.dig" (dict "map" .Values "key" "global.foo.bar.abc.xyz" "default" "some-default")
   *
   */}}
{{- define "helm-lib.dig" -}}
  {{- $mapToCheck := index . "map" -}}
  {{- $keyToFind := index . "key" -}}
  {{- $default := index . "default" -}}
  {{- $keySet := (splitList "." $keyToFind) -}}
  {{- $firstKey := first $keySet -}}
  {{- if hasKey $mapToCheck $firstKey -}}
    {{- if eq 1 (len $keySet) -}}{{/* The final key in the set implies we're done */}}
      {{- index $mapToCheck $firstKey -}}
    {{- else }}{{/* More keys to check, recurse */}}
      {{- include "helm-lib.dig" (dict "map" (index $mapToCheck $firstKey) "key" (join "." (rest $keySet)) "default" $default) }}
    {{- end }}
  {{- else }}
    {{- $default -}}
  {{- end }}
{{- end }}


{{/*===========================================================================
   * helm-lib.failOldParam(oldParam:<oldParam>, newParam:<newParam>, Values:Values)
   *
   * Used to look for old Helm keys, which might be defined in existing customer values.yaml
   * file.  However, the suite has changed to some new Helm key, so usage of old key is
   * considered fatal, and inform the customer to switch to the new key.  Example:
   *
   * (include "helm-lib.failOldParam" (dict "oldParam" "global.some.old.key" "newParam" "global.some.other.new.key" "Values" .Values))
   *
   */}}
{{- define "helm-lib.failOldParam" }}
  {{- $value := include "helm-lib.dig" (dict "map" .Values "key" .oldParam "default" "NOT_DEFINED") }}
  {{- if (not (or (eq $value "NOT_DEFINED") (eq (toString $value) "<no value>") (eq (toString $value) ""))) }}
    {{- printf "Old Helm key found: %s, switch to new key: %s" .oldParam .newParam | fail }}
  {{- end }}
{{- end }}


{{/*===========================================================================
   * helm-lib.mustBeNullOrTrue(param:<Param>, Values:Values)
   *
   * This is for Helm variables which must be either "true" or not defined at all.  Even
   * the mere mention of the variable name in any context will "define" it as empty string,
   * and this is VERY BAD when used as a conditional for subchart deployment.  This is
   * because those "condition" statements "dependencies" in Helm "Chart.yaml" are not
   * real boolean evaluations.  If a variable is defined, even if empty string, it will
   * short-circuit the implied "OR" statement in a comma-separated list of conditions.
   * Example:
   *
   * (include "helm-lib.mustBeNullOrTrue" (dict "param" "some.key.must.be.nullOrTrue" "Values" .Values))
   *
   */}}
{{- define "helm-lib.mustBeNullOrTrue" -}}
  {{- $value := include "helm-lib.dig" (dict "map" .Values "key" .param "default" "NOT_DEFINED") -}}
  {{- if (not (eq $value "NOT_DEFINED")) -}}
    {{- if (not (eq $value "true")) -}}
      {{- printf "Error: Helm key %s must be \"true\" or undefined, current value is \"%s\" which is not allowed" .param $value | fail -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*===========================================================================
   * helm-lib.getTlsCiphers(Values:Values,seperator:<seperator>,format:<output format>)
   *
   * This macro will concatenate cipher name from cipher list of global.tls.tlsCiphers to a string separated by <separator>.
   * When "format" is "openssl", this macro will map "iana" cipher names to "openssl" cipher name.
   *
   * Parameters:
   *   Values:    Optional, the value must be .Values which is used to read the cipher list from chart values.yaml
   *   separator: Optional, default: ","
   *   format:    Optional, possible values are [iana|openssl], default "iana"
   *
   * Examples:
   *   {{ include "helm-lib.getTlsCiphers" . }}
   *   {{ include "helm-lib.getTlsCiphers" (dict "Values" .Values "separator" ":") }}
   *   {{ include "helm-lib.getTlsCiphers" (dict "Values" .Values "separator" ":" "format" "openssl") }}
   *
   */}}
{{- define "helm-lib.getTlsCiphers" -}}
  {{- $format := (default "iana" .format) -}}
  {{- $ciphers := (default (list "TLS_AES_128_GCM_SHA256" "TLS_AES_256_GCM_SHA384" "TLS_CHACHA20_POLY1305_SHA256" "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256" "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384" "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256" "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384" "TLS_AES_128_CCM_8_SHA256" "TLS_AES_128_CCM_SHA256") ((.Values.global).tls).tlsCiphers) -}}
  {{- if (eq $format "openssl") -}}
    {{- $maps := dict "TLS_AES_256_GCM_SHA384" "TLS_AES_256_GCM_SHA384" "TLS_CHACHA20_POLY1305_SHA256" "TLS_CHACHA20_POLY1305_SHA256" "TLS_AES_128_GCM_SHA256" "TLS_AES_128_GCM_SHA256" "TLS_AES_128_CCM_8_SHA256" "TLS_AES_128_CCM_8_SHA256" "TLS_AES_128_CCM_SHA256" "TLS_AES_128_CCM_SHA256" "TLS_RSA_WITH_CAMELLIA_256_CBC_SHA" "CAMELLIA256-SHA" "TLS_SRP_SHA_RSA_WITH_AES_128_CBC_SHA" "SRP-RSA-AES-128-CBC-SHA" "TLS_ECDHE_ECDSA_WITH_AES_256_CCM" "ECDHE-ECDSA-AES256-CCM" "TLS_PSK_WITH_AES_256_CBC_SHA" "PSK-AES256-CBC-SHA" "TLS_GOSTR341094_WITH_NULL_GOSTR3411" "GOST2001-GOST89-GOST89" "TLS_ECDHE_ECDSA_WITH_AES_128_CCM_8" "ECDHE-ECDSA-AES128-CCM8" "TLS_DH_DSS_WITH_CAMELLIA_256_CBC_SHA" "DH-DSS-CAMELLIA256-SHA" "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384" "ECDHE-RSA-AES256-SHA384" "TLS_ECDHE_PSK_WITH_NULL_SHA256" "ECDHE-PSK-NULL-SHA256" "TLS_PSK_WITH_CHACHA20_POLY1305_SHA256" "PSK-CHACHA20-POLY1305" "TLS_PSK_WITH_RC4_128_SHA" "PSK-RC4-SHA" "TLS_RSA_WITH_NULL_SHA256" "NULL-SHA256" "TLS_ECDH_anon_WITH_AES_128_CBC_SHA" "AECDH-AES128-SHA" "TLS_DH_anon_WITH_DES_CBC_SHA" "ADH-DES-CBC-SHA" "TLS_RSA_WITH_RC4_128_MD5" "RC4-MD5" "TLS_DH_anon_WITH_RC4_128_MD5" "ADH-RC4-MD5" "TLS_SRP_SHA_WITH_AES_256_CBC_SHA" "SRP-AES-256-CBC-SHA" "TLS_DHE_DSS_WITH_AES_256_CBC_SHA256" "DHE-DSS-AES256-SHA256" "TLS_RSA_WITH_AES_128_CCM" "AES128-CCM" "TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256" "ECDH-RSA-AES128-GCM-SHA256" "TLS_PSK_WITH_NULL_SHA" "PSK-NULL-SHA" "SSL_CK_IDEA_128_CBC_WITH_MD5" "IDEA-CBC-MD5" "TLS_DH_RSA_WITH_AES_128_CBC_SHA" "DH-RSA-AES128-SHA" "TLS_SRP_SHA_WITH_AES_128_CBC_SHA" "SRP-AES-128-CBC-SHA" "TLS_DH_anon_WITH_AES_128_GCM_SHA256" "ADH-AES128-GCM-SHA256" "SSL_CK_RC2_128_CBC_WITH_MD5" "RC2-CBC-MD5" "SSL_CK_DES_192_EDE3_CBC_WITH_SHA" "DES-CBC3-SHA" "TLS_DH_DSS_WITH_AES_128_GCM_SHA256" "DH-DSS-AES128-GCM-SHA256" "TLS_ECDHE_RSA_WITH_NULL_SHA" "ECDHE-RSA-NULL-SHA" "TLS_RSA_WITH_RC4_128_SHA" "RC4-SHA" "TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA" "EDH-DSS-DES-CBC3-SHA" "TLS_RSA_PSK_WITH_CHACHA20_POLY1305_SHA256" "RSA-PSK-CHACHA20-POLY1305" "TLS_RSA_WITH_NULL_MD5" "NULL-MD5" "TLS_KRB5_WITH_IDEA_CBC_MD5" "KRB5-IDEA-CBC-MD5" "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256_OLD" "ECDHE-ECDSA-CHACHA20-POLY1305-OLD" "SSL_CK_RC4_128_EXPORT40_WITH_MD5" "EXP-RC4-MD5" "TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384" "ECDH-ECDSA-AES256-SHA384" "TLS_ECDH_anon_WITH_AES_256_CBC_SHA" "AECDH-AES256-SHA" "TLS_DHE_DSS_WITH_AES_256_CBC_SHA" "DHE-DSS-AES256-SHA" "TLS_PSK_WITH_AES_256_CCM_8" "PSK-AES256-CCM8" "TLS_RSA_EXPORT_WITH_RC2_CBC_40_MD5" "EXP-RC2-CBC-MD5" "TLS_PSK_WITH_AES_256_CCM" "PSK-AES256-CCM" "TLS_RSA_WITH_AES_256_CBC_SHA" "AES256-SHA" "TLS_ECDHE_ECDSA_WITH_NULL_SHA" "ECDHE-ECDSA-NULL-SHA" "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256" "ECDHE-RSA-CHACHA20-POLY1305" "TLS_DHE_PSK_WITH_AES_128_CCM" "DHE-PSK-AES128-CCM" "TLS_GOSTR341001_WITH_NULL_GOSTR3411" "GOST94-NULL-GOST94" "TLS_ECDHE_PSK_WITH_CHACHA20_POLY1305_SHA256" "ECDHE-PSK-CHACHA20-POLY1305" "TLS_DH_RSA_WITH_SEED_CBC_SHA" "DH-RSA-SEED-SHA" "TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA256" "DHE-RSA-CAMELLIA128-SHA256" "TLS_RSA_EXPORT1024_WITH_RC4_56_MD5" "EXP1024-RC4-MD5" "TLS_RSA_WITH_AES_256_CCM_8" "AES256-CCM8" "TLS_ECDH_RSA_WITH_RC4_128_SHA" "ECDH-RSA-RC4-SHA" "TLS_DHE_RSA_WITH_AES_256_CBC_SHA" "DHE-RSA-AES256-SHA" "TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA" "DHE-RSA-CAMELLIA256-SHA" "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256" "ECDHE-ECDSA-AES128-GCM-SHA256" "TLS_DHE_DSS_WITH_AES_128_GCM_SHA256" "DHE-DSS-AES128-GCM-SHA256" "TLS_RSA_WITH_AES_128_CBC_SHA" "AES128-SHA" "TLS_DH_anon_WITH_AES_256_CBC_SHA256" "ADH-AES256-SHA256" "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA" "ECDHE-RSA-AES128-SHA" "TLS_RSA_PSK_WITH_CAMELLIA_256_CBC_SHA384" "RSA-PSK-CAMELLIA256-SHA384" "TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA" "ECDH-ECDSA-AES256-SHA" "TLS_DH_RSA_WITH_AES_128_CBC_SHA256" "DH-RSA-AES128-SHA256" "TLS_DHE_RSA_WITH_AES_256_CCM_8" "DHE-RSA-AES256-CCM8" "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256" "DHE-RSA-AES128-GCM-SHA256" "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA" "ECDHE-ECDSA-AES256-SHA" "TLS_DH_DSS_WITH_AES_128_CBC_SHA256" "DH-DSS-AES128-SHA256" "TLS_DH_anon_WITH_3DES_EDE_CBC_SHA" "ADH-DES-CBC3-SHA" "TLS_DHE_RSA_WITH_CHACHA20_POLY1305_SHA256" "DHE-RSA-CHACHA20-POLY1305" "TLS_KRB5_EXPORT_WITH_RC4_40_SHA" "EXP-KRB5-RC4-SHA" "TLS_ECDHE_RSA_WITH_CAMELLIA_128_CBC_SHA256" "ECDHE-RSA-CAMELLIA128-SHA256" "TLS_ECDH_RSA_WITH_NULL_SHA" "ECDH-RSA-NULL-SHA" "TLS_KRB5_EXPORT_WITH_DES_CBC_40_SHA" "EXP-KRB5-DES-CBC-SHA" "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256" "ECDHE-RSA-AES128-GCM-SHA256" "TLS_DHE_DSS_WITH_RC4_128_SHA" "DHE-DSS-RC4-SHA" "TLS_DHE_DSS_WITH_AES_256_GCM_SHA384" "DHE-DSS-AES256-GCM-SHA384" "TLS_PSK_WITH_AES_128_CCM_8" "PSK-AES128-CCM8" "TLS_ECDHE_PSK_WITH_NULL_SHA" "ECDHE-PSK-NULL-SHA" "TLS_ECDHE_PSK_WITH_AES_256_CBC_SHA" "ECDHE-PSK-AES256-CBC-SHA" "TLS_RSA_EXPORT_WITH_RC4_40_MD5" "EXP-RC4-MD5" "TLS_RSA_WITH_28147_CNT_GOST94" "GOST-GOST94" "TLS_ECDHE_ECDSA_WITH_CAMELLIA_128_CBC_SHA256" "ECDHE-ECDSA-CAMELLIA128-SHA256" "TLS_SRP_SHA_RSA_WITH_AES_256_CBC_SHA" "SRP-RSA-AES-256-CBC-SHA" "TLS_EMPTY_RENEGOTIATION_INFO_SCSV" "TLS_FALLBACK_SCSV" "TLS_DHE_PSK_WITH_AES_256_CCM" "DHE-PSK-AES256-CCM" "TLS_KRB5_EXPORT_WITH_DES_CBC_40_MD5" "EXP-KRB5-DES-CBC-MD5" "TLS_DHE_RSA_WITH_AES_128_CCM" "DHE-RSA-AES128-CCM" "TLS_ECDHE_RSA_WITH_RC4_128_SHA" "ECDHE-RSA-RC4-SHA" "TLS_PSK_WITH_3DES_EDE_CBC_SHA" "PSK-3DES-EDE-CBC-SHA" "TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA" "ECDH-ECDSA-AES128-SHA" "TLS_ECDHE_PSK_WITH_RC4_128_SHA" "ECDHE-PSK-RC4-SHA" "TLS_RSA_EXPORT1024_WITH_RC4_56_SHA" "EXP1024-RC4-SHA" "TLS_DHE_DSS_WITH_CAMELLIA_256_CBC_SHA" "DHE-DSS-CAMELLIA256-SHA" "TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256" "ECDH-ECDSA-AES128-SHA256" "TLS_KRB5_WITH_DES_CBC_MD5" "KRB5-DES-CBC-MD5" "TLS_ECDHE_PSK_WITH_3DES_EDE_CBC_SHA" "ECDHE-PSK-3DES-EDE-CBC-SHA" "SSL_CK_DES_64_CFB64_WITH_MD5_1" "DES-CFB-M1" "TLS_DHE_RSA_WITH_AES_128_CBC_SHA256" "DHE-RSA-AES128-SHA256" "TLS_ECDHE_PSK_WITH_AES_128_CBC_SHA" "ECDHE-PSK-AES128-CBC-SHA" "TLS_DH_DSS_WITH_AES_256_GCM_SHA384" "DH-DSS-AES256-GCM-SHA384" "TLS_GOSTR341001_WITH_28147_CNT_IMIT" "GOST2001-GOST89-GOST89" "TLS_KRB5_WITH_RC4_128_SHA" "KRB5-RC4-SHA" "TLS_DH_anon_WITH_CAMELLIA_128_CBC_SHA" "ADH-CAMELLIA128-SHA" "TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384" "ECDH-RSA-AES256-SHA384" "TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA" "ECDH-ECDSA-DES-CBC3-SHA" "TLS_ECDHE_RSA_WITH_CAMELLIA_256_CBC_SHA384" "ECDHE-RSA-CAMELLIA256-SHA384" "TLS_SRP_SHA_RSA_WITH_3DES_EDE_CBC_SHA" "SRP-RSA-3DES-EDE-CBC-SHA" "SSL_CK_RC2_128_CBC_EXPORT40_WITH_MD5" "EXP-RC2-CBC-MD5" "TLS_DHE_DSS_WITH_CAMELLIA_128_CBC_SHA256" "DHE-DSS-CAMELLIA128-SHA256" "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA" "ECDHE-ECDSA-AES128-SHA" "TLS_DH_DSS_WITH_AES_256_CBC_SHA" "DH-DSS-AES256-SHA" "TLS_DH_DSS_WITH_CAMELLIA_128_CBC_SHA256" "DH-DSS-CAMELLIA128-SHA256" "TLS_ECDHE_PSK_WITH_CAMELLIA_128_CBC_SHA256" "ECDHE-PSK-CAMELLIA128-SHA256" "TLS_RSA_WITH_CAMELLIA_128_CBC_SHA" "CAMELLIA128-SHA" "TLS_DH_RSA_EXPORT_WITH_DES40_CBC_SHA" "EXP-DH-RSA-DES-CBC-SHA" "TLS_RSA_WITH_AES_256_CBC_SHA256" "AES256-SHA256" "TLS_SRP_SHA_DSS_WITH_AES_128_CBC_SHA" "SRP-DSS-AES-128-CBC-SHA" "TLS_KRB5_WITH_RC4_128_MD5" "KRB5-RC4-MD5" "TLS_DH_anon_EXPORT_WITH_RC4_40_MD5" "EXP-ADH-RC4-MD5" "TLS_DH_DSS_WITH_DES_CBC_SHA" "DH-DSS-DES-CBC-SHA" "TLS_RSA_WITH_3DES_EDE_CBC_SHA" "DES-CBC3-SHA" "TLS_KRB5_EXPORT_WITH_RC2_CBC_40_SHA" "EXP-KRB5-RC2-CBC-SHA" "TLS_PSK_DHE_WITH_AES_128_CCM_8" "DHE-PSK-AES128-CCM8" "TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA" "DHE-RSA-CAMELLIA128-SHA" "TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA" "ECDH-RSA-DES-CBC3-SHA" "TLS_DHE_RSA_WITH_AES_256_CBC_SHA256" "DHE-RSA-AES256-SHA256" "TLS_DH_anon_EXPORT_WITH_DES40_CBC_SHA" "EXP-ADH-DES-CBC-SHA" "TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA" "AECDH-DES-CBC3-SHA" "TLS_ECDHE_PSK_WITH_AES_256_CBC_SHA384" "ECDHE-PSK-AES256-CBC-SHA384" "TLS_RSA_WITH_DES_CBC_SHA" "DES-CBC-SHA" "TLS_DH_anon_WITH_SEED_CBC_SHA" "ADH-SEED-SHA" "TLS_ECDH_ECDSA_WITH_CAMELLIA_256_CBC_SHA384" "ECDH-ECDSA-CAMELLIA256-SHA384" "SSL_CK_DES_64_CBC_WITH_SHA" "DES-CBC-SHA" "TLS_RSA_WITH_AES_256_CCM" "AES256-CCM" "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384" "ECDHE-ECDSA-AES256-GCM-SHA384" "TLS_DH_RSA_WITH_CAMELLIA_128_CBC_SHA" "DH-RSA-CAMELLIA128-SHA" "SSL_CK_RC4_64_WITH_MD5" "RC4-64-MD5" "TLS_DH_anon_WITH_AES_256_CBC_SHA" "ADH-AES256-SHA" "TLS_DHE_DSS_WITH_DES_CBC_SHA" "EDH-DSS-DES-CBC-SHA" "TLS_ECDHE_ECDSA_WITH_RC4_128_SHA" "ECDHE-ECDSA-RC4-SHA" "TLS_KRB5_WITH_DES_CBC_SHA" "KRB5-DES-CBC-SHA" "TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256" "ECDH-ECDSA-AES128-GCM-SHA256" "TLS_PSK_WITH_CAMELLIA_256_CBC_SHA384" "PSK-CAMELLIA256-SHA384" "TLS_RSA_EXPORT1024_WITH_RC2_CBC_56_MD5" "EXP1024-RC2-CBC-MD5" "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256" "ECDHE-ECDSA-AES128-SHA256" "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256" "ECDHE-ECDSA-CHACHA20-POLY1305" "TLS_DH_RSA_WITH_DES_CBC_SHA" "DH-RSA-DES-CBC-SHA" "TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA" "EDH-RSA-DES-CBC3-SHA" "TLS_PSK_WITH_AES_128_CCM" "PSK-AES128-CCM" "TLS_RSA_WITH_CAMELLIA_128_CBC_SHA256" "CAMELLIA128-SHA256" "TLS_DHE_RSA_WITH_CHACHA20_POLY1305_SHA256_OLD" "DHE-RSA-CHACHA20-POLY1305-OLD" "TLS_ECDH_ECDSA_WITH_RC4_128_SHA" "ECDH-ECDSA-RC4-SHA" "TLS_DHE_RSA_WITH_AES_128_CCM_8" "DHE-RSA-AES128-CCM8" "TLS_DH_RSA_WITH_AES_256_GCM_SHA384" "DH-RSA-AES256-GCM-SHA384" "TLS_DHE_PSK_WITH_CAMELLIA_256_CBC_SHA384" "DHE-PSK-CAMELLIA256-SHA384" "SSL_CK_DES_192_EDE3_CBC_WITH_MD5" "DES-CBC3-MD5" "TLS_SRP_SHA_DSS_WITH_AES_256_CBC_SHA" "SRP-DSS-AES-256-CBC-SHA" "TLS_DHE_DSS_WITH_CAMELLIA_128_CBC_SHA" "DHE-DSS-CAMELLIA128-SHA" "TLS_RSA_WITH_IDEA_CBC_SHA" "IDEA-CBC-SHA" "TLS_ECDH_RSA_WITH_AES_256_CBC_SHA" "ECDH-RSA-AES256-SHA" "TLS_DHE_RSA_WITH_AES_128_CBC_SHA" "DHE-RSA-AES128-SHA" "TLS_RSA_PSK_WITH_NULL_SHA" "RSA-PSK-NULL-SHA" "TLS_RSA_EXPORT_WITH_DES40_CBC_SHA" "EXP-DES-CBC-SHA" "TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA" "ECDHE-RSA-DES-CBC3-SHA" "TLS_GOSTR341094_WITH_28147_CNT_IMIT" "GOST94-GOST89-GOST89" "TLS_DH_RSA_WITH_CAMELLIA_128_CBC_SHA256" "DH-RSA-CAMELLIA128-SHA256" "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384" "ECDHE-ECDSA-AES256-SHA384" "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384" "DHE-RSA-AES256-GCM-SHA384" "TLS_ECDH_RSA_WITH_CAMELLIA_128_CBC_SHA256" "ECDH-RSA-CAMELLIA128-SHA256" "TLS_DHE_DSS_EXPORT1024_WITH_RC4_56_SHA" "EXP1024-DHE-DSS-RC4-SHA" "SSL_CK_RC4_128_WITH_MD5" "RC4-MD5" "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256" "ECDHE-RSA-AES128-SHA256" "TLS_DHE_PSK_WITH_CAMELLIA_128_CBC_SHA256" "DHE-PSK-CAMELLIA128-SHA256" "TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA" "ECDHE-ECDSA-DES-CBC3-SHA" "TLS_ECDHE_PSK_WITH_CAMELLIA_256_CBC_SHA384" "ECDHE-PSK-CAMELLIA256-SHA384" "TLS_RSA_EXPORT1024_WITH_DES_CBC_SHA" "EXP1024-DES-CBC-SHA" "TLS_DH_RSA_WITH_AES_256_CBC_SHA" "DH-RSA-AES256-SHA" "TLS_PSK_WITH_AES_128_CBC_SHA" "PSK-AES128-CBC-SHA" "TLS_DH_DSS_EXPORT_WITH_DES40_CBC_SHA" "EXP-DH-DSS-DES-CBC-SHA" "TLS_ECDHE_ECDSA_WITH_AES_256_CCM_8" "ECDHE-ECDSA-AES256-CCM8" "TLS_RSA_PSK_WITH_CAMELLIA_128_CBC_SHA256" "RSA-PSK-CAMELLIA128-SHA256" "TLS_PSK_WITH_CAMELLIA_128_CBC_SHA256" "PSK-CAMELLIA128-SHA256" "TLS_RSA_WITH_AES_128_CCM_8" "AES128-CCM8" "TLS_ECDHE_PSK_WITH_NULL_SHA384" "ECDHE-PSK-NULL-SHA384" "TLS_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA" "EXP-EDH-RSA-DES-CBC-SHA" "TLS_DH_anon_WITH_AES_128_CBC_SHA256" "ADH-AES128-SHA256" "TLS_DHE_RSA_WITH_SEED_CBC_SHA" "DHE-RSA-SEED-SHA" "TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384" "ECDH-ECDSA-AES256-GCM-SHA384" "TLS_ECDH_anon_WITH_RC4_128_SHA" "AECDH-RC4-SHA" "TLS_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA" "EXP-EDH-DSS-DES-CBC-SHA" "TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256" "ECDH-RSA-AES128-SHA256" "TLS_GOSTR341094_RSA_WITH_28147_CNT_MD5" "GOST-MD5" "TLS_ECDH_ECDSA_WITH_CAMELLIA_128_CBC_SHA256" "ECDH-ECDSA-CAMELLIA128-SHA256" "TLS_DHE_PSK_WITH_CHACHA20_POLY1305_SHA256" "DHE-PSK-CHACHA20-POLY1305" "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA" "ECDHE-RSA-AES256-SHA" "TLS_DH_RSA_WITH_CAMELLIA_256_CBC_SHA" "DH-RSA-CAMELLIA256-SHA" "TLS_DH_DSS_WITH_AES_128_CBC_SHA" "DH-DSS-AES128-SHA" "TLS_DHE_DSS_WITH_SEED_CBC_SHA" "DHE-DSS-SEED-SHA" "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384" "ECDHE-RSA-AES256-GCM-SHA384" "TLS_DH_RSA_WITH_3DES_EDE_CBC_SHA" "DH-RSA-DES-CBC3-SHA" "TLS_DH_anon_WITH_CAMELLIA_256_CBC_SHA" "ADH-CAMELLIA256-SHA" "TLS_SRP_SHA_WITH_3DES_EDE_CBC_SHA" "SRP-3DES-EDE-CBC-SHA" "TLS_DHE_DSS_WITH_AES_128_CBC_SHA" "DHE-DSS-AES128-SHA" "TLS_DH_anon_WITH_AES_256_GCM_SHA384" "ADH-AES256-GCM-SHA384" "TLS_RSA_WITH_SEED_CBC_SHA" "SEED-SHA" "TLS_KRB5_EXPORT_WITH_RC2_CBC_40_MD5" "EXP-KRB5-RC2-CBC-MD5" "TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384" "ECDH-RSA-AES256-GCM-SHA384" "TLS_DHE_DSS_WITH_AES_128_CBC_SHA256" "DHE-DSS-AES128-SHA256" "TLS_ECDHE_PSK_WITH_AES_128_CBC_SHA256" "ECDHE-PSK-AES128-CBC-SHA256" "TLS_DH_DSS_WITH_3DES_EDE_CBC_SHA" "DH-DSS-DES-CBC3-SHA" "TLS_ECDH_RSA_WITH_CAMELLIA_256_CBC_SHA384" "ECDH-RSA-CAMELLIA256-SHA384" "TLS_DHE_DSS_EXPORT1024_WITH_DES_CBC_SHA" "EXP1024-DHE-DSS-DES-CBC-SHA" "TLS_KRB5_WITH_IDEA_CBC_SHA" "KRB5-IDEA-CBC-SHA" "TLS_KRB5_WITH_3DES_EDE_CBC_MD5" "KRB5-DES-CBC3-MD5" "TLS_DH_RSA_WITH_AES_256_CBC_SHA256" "DH-RSA-AES256-SHA256" "TLS_ECDH_ECDSA_WITH_NULL_SHA" "ECDH-ECDSA-NULL-SHA" "TLS_RSA_WITH_AES_256_GCM_SHA384" "AES256-GCM-SHA384" "TLS_SRP_SHA_DSS_WITH_3DES_EDE_CBC_SHA" "SRP-DSS-3DES-EDE-CBC-SHA" "TLS_DHE_PSK_WITH_NULL_SHA" "DHE-PSK-NULL-SHA" "TLS_DH_DSS_WITH_CAMELLIA_128_CBC_SHA" "DH-DSS-CAMELLIA128-SHA" "TLS_DH_DSS_WITH_AES_256_CBC_SHA256" "DH-DSS-AES256-SHA256" "SSL_CK_DES_64_CBC_WITH_MD5" "DES-CBC-MD5" "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256_OLD" "ECDHE-RSA-CHACHA20-POLY1305-OLD" "TLS_RSA_WITH_AES_128_CBC_SHA256" "AES128-SHA256" "TLS_RSA_WITH_AES_128_CBC_SHA256" "AES128-SHA256" "TLS_RSA_WITH_AES_128_GCM_SHA256" "AES128-GCM-SHA256" "TLS_DH_DSS_WITH_SEED_CBC_SHA" "DH-DSS-SEED-SHA" "TLS_RSA_WITH_NULL_SHA" "NULL-SHA" "TLS_DHE_RSA_WITH_DES_CBC_SHA" "EDH-RSA-DES-CBC-SHA" "TLS_KRB5_WITH_3DES_EDE_CBC_SHA" "KRB5-DES-CBC3-SHA" "TLS_DHE_RSA_WITH_AES_256_CCM" "DHE-RSA-AES256-CCM" "TLS_DH_RSA_WITH_AES_128_GCM_SHA256" "DH-RSA-AES128-GCM-SHA256" "TLS_DH_anon_WITH_CAMELLIA_128_CBC_SHA256" "ADH-CAMELLIA128-SHA256" "TLS_ECDH_RSA_WITH_AES_128_CBC_SHA" "ECDH-RSA-AES128-SHA" "TLS_DH_anon_WITH_AES_128_CBC_SHA" "ADH-AES128-SHA" "TLS_ECDHE_ECDSA_WITH_AES_128_CCM" "ECDHE-ECDSA-AES128-CCM" "TLS_ECDH_anon_WITH_NULL_SHA" "AECDH-NULL-SHA" "TLS_PSK_DHE_WITH_AES_256_CCM_8" "DHE-PSK-AES256-CCM8" "TLS_ECDHE_ECDSA_WITH_CAMELLIA_256_CBC_SHA384" "ECDHE-ECDSA-CAMELLIA256-SHA38" "TLS_KRB5_EXPORT_WITH_RC4_40_MD5" "EXP-KRB5-RC4-MD5" -}}
    {{- $converted := list -}}
    {{- range $ciphers -}}
      {{- $opensslCipher := (get $maps .) -}}
      {{- if $opensslCipher -}}
        {{- $converted = append $converted $opensslCipher -}}
      {{- end -}}
    {{- end -}}
    {{ join (default ":" .separator) $converted }}
  {{- else -}}
    {{ join (default "," .separator) $ciphers }}
  {{- end -}}
{{- end -}}

{{/*===========================================================================
   * helm-lib.getTlsMinVersion(Values:Values,format:<output format>)
   *
   * This macro will convert minimum tls version from global.tls.tlsMinVersion to a specified format.
   *
   * Parameters:
   *   Values:    Optional, the value must be .Values which is used to read the minimum tls version from chart values.yaml
   *   format:    Optional, default "0". 
   *              "0": "TLSv1.2";
   *              "1": "VersionTLS12";
   *              "2": "tls1.2";
   *
   * Examples:
   *   {{ include "helm-lib.getTlsMinVersion" . }}
   *   {{ include "helm-lib.getTlsMinVersion" (dict "Values" .Values "format" "1") }} 
   *   {{ include "helm-lib.getTlsMinVersion" (dict "Values" .Values "format" "2") }}
   *
   */}}
{{- define "helm-lib.getTlsMinVersion" -}}
  {{- $format := (default "0" .format) -}}
  {{- $originVersion := (default "TLSv1.2" ((.Values.global).tls).tlsMinVersion) -}}
  {{- $maps := dict "TLSv1.2" "TLSv1.2" "TLSv1.3" "TLSv1.3" -}}
  {{- if (eq $format "1") -}}
    {{- $maps = dict "TLSv1.2" "VersionTLS12" "TLSv1.3" "VersionTLS13" -}}
  {{- end -}}
  {{- if (eq $format "2") -}}
    {{- $maps = dict "TLSv1.2" "tls1.2" "TLSv1.3" "tls1.3" -}}
  {{- end -}}
  {{- $version := get $maps $originVersion -}}
  {{- if $version -}}
    {{ $version }}
  {{- else -}}
    {{- fail "value global.tls.tlsMinVersion must be either 'TLSv1.2' or 'TLSv1.3'" -}}
  {{- end -}}
{{- end -}}

{{/*===========================================================================
   * helm-lib.getTlsEnvVars(seperator:<seperator>,format:<output format>)
   *
   * This macro generates the tls values as pod environment variable name/key pair. 
   *   if global.tls.tlsMinVersion is empty, use TLSv1.2 as default value
   *   if global.tls.tlsCiphers is empty, use default ciphers
   * Parameters:
   *   separator:      Optional, default: "," for iana, ":" for openssl
   *   cipherFormat:   Optional, possible values are [iana|openssl], default "iana"
   *   versionFormat:  Optional, default "0". "0": "TLSv1.2"; "1": "VersionTLS12";
   * Examples:
   *  {{- include "helm-lib.getTlsEnvVars" . | nindent 2 }}
   *  {{- include "helm-lib.getTlsEnvVars" (dict "Values" .Values ) | nindent 2 }}
   *  {{- include "helm-lib.getTlsEnvVars" (dict "Values" .Values "cipherFormat" "openssl" "separator" ":") | nindent 2 }}
   *  {{- include "helm-lib.getTlsEnvVars" (dict "Values" .Values "cipherFormat" "openssl" "separator" ":" "versionFormat" "1") | nindent 2 }}
   *
*/}}   
{{- define "helm-lib.getTlsEnvVars" -}}
- name: TLS_MIN_VERSION
  value: {{ include "helm-lib.getTlsMinVersion" (dict "format" (default "0" .versionFormat) "Values" .Values) }}
- name: TLS_CIPHERS
  value: {{ include "helm-lib.getTlsCiphers" (dict "format" (default "iana" .cipherFormat) "separator" (default "," .separator) "Values" .Values) }}
{{- end }}



{{/*======================================================================
   * helm-lib.getTlsCertNameFromRealm(Values:Values)
   *
   * This macro returns the name of the certificate file that should be used by ServiceMonitors
   *  if global.vault.realmList is empty, the macro returns "RID_ca.crt"
   *  if global.vault.realmList is not empty, it takes the first certificate type from the comma-separated value.
   * Parameters:
   *   Values:    Mandatory, the value must be .Values which is used to read the realm list from chart's values.yaml
   * Examples:
   *   {{- include "helm-lib.getTlsCertNameFromRealm" (dict Values .Values) }} will return RID if global.vault.realmList is "RID:365,RE:365"
   */}}
{{- define "helm-lib.getTlsCertNameFromRealmList" -}}
{{- if and (.Values.global) (.Values.global.vault) (.Values.global.vault.realmList) }}
{{-   $source := .Values.global.vault.realmList }}
{{-   $values := splitList "," $source }}
{{-   $certType := index $values 0 }}
{{-   $certName := index (splitList ":" $certType) 0 }}
{{-   printf "%s_ca.crt" $certName }}
{{- else }}
{{-   printf "RID_ca.crt" }}
{{- end }}
{{- end -}}

