{{- define "ucmdb.ingress.annotationPrefix" -}}
{{- $nginx := .Values.global.nginx | default dict -}}
{{- default "ingress.kubernetes.io" ($nginx.annotationPrefix) -}}
{{- end -}}

{{- define "ucmdb.ingress.annotations" -}}
kubernetes.io/ingress.class: "nginx"
{{ include "ucmdb.ingress.annotationPrefix" . }}/affinity: "cookie"
{{ include "ucmdb.ingress.annotationPrefix" . }}/affinity-mode: "persistent"
{{ include "ucmdb.ingress.annotationPrefix" . }}/session-cookie-hash: "sha1"
{{- if .Values.ingress.cookieName }}
{{ include "ucmdb.ingress.annotationPrefix" . }}/session-cookie-name: {{ .Values.ingress.cookieName | quote }}
{{- end }}
{{- if .Values.ingress.secureBackends }}
{{ include "ucmdb.ingress.annotationPrefix" . }}/secure-backends: "true"
{{ include "ucmdb.ingress.annotationPrefix" . }}/backend-protocol: "HTTPS"
{{- end }}
{{- if .Values.ingress.proxyTimeout }}
{{ include "ucmdb.ingress.annotationPrefix" . }}/proxy-connect-timeout: {{ .Values.ingress.proxyTimeout | quote }}
{{ include "ucmdb.ingress.annotationPrefix" . }}/proxy-read-timeout: {{ .Values.ingress.proxyTimeout | quote }}
{{ include "ucmdb.ingress.annotationPrefix" . }}/proxy-send-timeout: {{ .Values.ingress.proxyTimeout | quote }}
{{- end }}
{{- if .Values.ingress.proxyBodySize }}
{{ include "ucmdb.ingress.annotationPrefix" . }}/proxy-body-size: {{ .Values.ingress.proxyBodySize | quote }}
{{- end -}}
{{- end -}}

{{- define "ucmdb.ingress.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1/Ingress" -}}
networking.k8s.io/v1
{{- else -}}
networking.k8s.io/v1beta1
{{- end -}}
{{- end -}}

{{- define "ucmdb.ingress.backend" -}}
{{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1/Ingress" -}}
pathType: Prefix
backend:
  service:
    name: {{ .serviceName }}
    port:
      number: {{ .servicePort }}
{{- else -}}
backend:
  serviceName: {{ .serviceName }}
  servicePort: {{ .servicePort }}
{{- end }}
{{- end -}}