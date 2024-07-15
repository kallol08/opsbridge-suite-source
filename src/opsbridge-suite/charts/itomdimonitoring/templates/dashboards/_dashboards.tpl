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
Dashboards folder placement
*/}}
{{- define "dashboards.annotation.folder" -}}
k8s-sidecar-target-directory: {{ .Release.Namespace }}
{{- end }}

{{- define "pulsar.namespace.deployed" -}}
{{- if ((((.Values.global).services).opticDataLake).pulsar) -}}
	{{- if (((((.Values.global).services).opticDataLake).pulsar).deploy) -}}
		{{- if (eq ((((((.Values.global).services).opticDataLake).pulsar).deploy) | toString) "true") -}}
			{{- printf "%s" .Release.Namespace -}}
		{{- else if (eq ((((((.Values.global).services).opticDataLake).pulsar).deploy) | toString) "false") -}}
			{{- if (((((((.Values.global).services).opticDataLake).pulsar).externalPulsar).connectUsingNamespace).namespace) -}}
				{{- printf "%s" .Values.global.services.opticDataLake.pulsar.externalPulsar.connectUsingNamespace.namespace -}}
			{{- else -}}
				{{- printf "%s" .Release.Namespace -}}	
			{{- end -}}
		{{- end -}}
	{{- else -}}
			{{- if (((((((.Values.global).services).opticDataLake).pulsar).externalPulsar).connectUsingNamespace).namespace) -}}
				{{- printf "%s" .Values.global.services.opticDataLake.pulsar.externalPulsar.connectUsingNamespace.namespace -}}
			{{- else -}}
				{{- printf "%s" .Release.Namespace -}}	
			{{- end -}}
	{{- end -}}
{{- else -}}
	{{- printf "%s" .Release.Namespace -}}
{{- end -}}
{{- end -}}


{{- define "pulsarNamespace" -}}
	{{- if (not (empty .Values.global.di.pulsar.tenant)) -}}
		{{- printf "%s" .Values.global.di.pulsar.tenant -}}
	{{- else -}}
		{{- printf "public" -}}
	{{- end -}}
{{- end -}}






