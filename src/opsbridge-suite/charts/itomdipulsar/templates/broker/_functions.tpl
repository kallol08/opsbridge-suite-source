{{/* # */}}
{{/* # Copyright 2023 Open Text. */}}
{{/* # */}}
{{/* # The only warranties for products and services of Open Text and its affiliates and  */}}
{{/* # licensors (“Open Text”) are as may be set forth in the express warranty statements  */}}
{{/* # accompanying such products and services. Nothing herein should be construed as */}}
{{/* # constituting an additional warranty. Open Text shall not be liable for technical or */}}
{{/* # editorial errors or omissions contained herein. The information contained herein is  */}}
{{/* # subject to change without notice. */}}
{{/* # */}}
{{/* # Except as specifically indicated otherwise, this document contains confidential  */}}
{{/* # information and a valid license is required for possession, use or copying. If this work  */}}
{{/* # is provided to the U.S. Government, consistent with FAR 12.211 and 12.212, Commercial Computer  */}}
{{/* # Software, Computer Software Documentation, and Technical Data for Commercial Items are licensed to */}}
{{/* # the U.S. Government under vendor’s standard commercial license. */}}
{{/* # */}}
{{/*
The namespace to run functions
*/}}
{{- define "pulsar.functions.namespace" -}}
{{- if .Values.functions.jobNamespace }}
{{- .Values.functions.jobNamespace }}
{{- else }}
{{- template "pulsar.namespace" . }}
{{- end }}
{{- end }}

{{/*
The pulsar root directory of functions image
*/}}
{{- define "pulsar.functions.pulsarRootDir" -}}
{{- if .Values.functions.pulsarRootDir }}
{{- .Values.functions.pulsarRootDir }}
{{- else }}
{{- template "pulsar.home" . }}
{{- end }}
{{- end }} 
