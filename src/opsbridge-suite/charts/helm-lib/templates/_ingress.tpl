
{{/*
Outputs the necessary ingress annotation key/values for the deployment environment.
*/}}
{{- define "helm-lib.ingress.annotations" -}}
{{- if .Values.mf }}
    {{- $depEnv := .Values.mf.deploymentEnvironment -}}
    {{- if eq $depEnv "" -}}
    {{- $depEnv := "CDF" -}}
    {{- end -}}
    {{- if eq .Values.mf.deploymentEnvironment "EKS" -}}
    {{ template "helm-lib.ingress.aws-alb-ingress-annotations" . }}
    {{- end -}}
{{- end -}}
{{- end -}}


{{/*
Define the required ingress annotation block for EKS ALB Ingress. This just outputs the key value pairs.
It does not declare the annotation block itself.
*/}}
{{- define "helm-lib.ingress.aws-alb-ingress-annotations" -}}
{{- if and .Values.mf .Values.mf.ingress .Values.mf.ingress.alb }}
    kubernetes.io/ingress.class: "alb"
    alb.ingress.kubernetes.io/scheme: "internet-facing"
    alb.ingress.kubernetes.io/subnets: {{ required "mf.ingress.alb.subnets required!" .Values.mf.ingress.alb.subnets | quote }}
    alb.ingress.kubernetes.io/certificate-arn: {{ required "mf.ingress.alb.certificateARN required!" .Values.mf.ingress.alb.certificateARN | quote }}
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":{{ required "mf.ingress.alb.listenPort required!" .Values.mf.ingress.alb.listenPort }}}]'
{{- end -}}
{{- end -}}

{{/*
Name: helm-lib.ingress.tlsSecret
Description: Generate ingress.tls template
Examples:
  {{- include "helm-lib.ingress.tlsSecret" . |nindent 2 }}
*/}}
{{- define "helm-lib.ingress.tlsSecret" -}}
tls:
- secretName: {{ default "nginx-default-secret" ((.Values.global.expose).ingress).tlsSecretName | quote }}
  {{- if .Values.global.externalAccessHost  }}
  hosts:
  - {{  .Values.global.externalAccessHost }}
  {{- end -}}
{{- end -}}

{{/*
Name: helm-lib.ingress.commonAnnotations
Description: Generate some basic annnotation for all of ingress objects
Examples:
  {{- include "helm-lib.ingress.commonAnnotations" . |nindent 2 }}
*/}}
{{- define "helm-lib.ingress.commonAnnotations" -}}
kubernetes.io/ingress.class: "nginx"
{{ default "ingress.kubernetes.io" ((.Values.global).nginx).annotationPrefix }}/force-ssl-redirect: "true"
{{- end -}}
