{{/* #configmap checks for shared optic reporting */}}

{{- define "opsb.deployReporting" -}}
{{- if (((.Values.global.services).opticReporting).deploy) }}
{{- $reportingDeploy := .Values.global.services.opticReporting.deploy }}
{{- printf "%v" $reportingDeploy -}}
{{- else }}
{{- printf "%v" "false" -}}
{{- end }}
{{- end }}

{{- define "opsb.deployOpticDL" -}}
{{- if (((.Values.global.services).opticDataLake).deploy) }}
{{- fail "Error: global.services.opticDataLake.deploy must be kept commented when using Optic DL or kept as false when using Shared Optic DL" }}
{{- else if (eq ((.Values.global.services.opticDataLake).deploy | toString) "false") }}
{{- $opticDLDeploy := .Values.global.services.opticDataLake.deploy }}
{{- printf "%v" $opticDLDeploy -}}
{{- end }}
{{- end }}

{{- define "opsb.deployOpticDLMessageBus" -}}
{{- if ((((.Values.global.services).opticDataLake).pulsar).deploy) }}
{{- fail "Error: global.services.opticDataLake.pulsar.deploy must be kept commented when using Optic DL Message Bus or kept as false when using Shared Optic DL Message Bus" }}
{{- else if (eq (((.Values.global.services.opticDataLake).pulsar).deploy | toString) "false") -}}
{{- $opticDLMessageBusDeploy := .Values.global.services.opticDataLake.pulsar.deploy }}
{{- printf "%v" $opticDLMessageBusDeploy -}}
{{- end }}
{{- end }}

{{- define "opsb.enableAEC" -}}
{{- if (((.Values.global.services).automaticEventCorrelation).deploy) }}
{{- $aec := .Values.global.services.automaticEventCorrelation.deploy }}
{{- printf "%v" $aec -}}
{{- else }}
{{- printf "%v" "false" -}}
{{- end }}
{{- end }}

{{- define "opsb.enableStakeholderDashboard" -}}
{{- if (((.Values.global.services).stakeholderDashboard).deploy) }}
{{- $bvd := .Values.global.services.stakeholderDashboard.deploy }}
{{- printf "%v" $bvd -}}
{{- else }}
{{- printf "%v" "false" -}}
{{- end }}
{{- end }}

{{- define "opsb.enableHyperscaleObservability" -}}
{{- if (((.Values.global.services).hyperscaleObservability).deploy) }}
{{- $cm := .Values.global.services.hyperscaleObservability.deploy }}
{{- printf "%v" $cm -}}
{{- else }}
{{- printf "%v" "false" -}}
{{- end }}
{{- end }}

{{- define "opsb.enableLightHyperscaleObservability" -}}
{{- if (((.Values.global.services).hyperscaleObservability).deployLightHSO) }}
{{- $cm := .Values.global.services.hyperscaleObservability.deployLightHSO }}
{{- printf "%v" $cm -}}
{{- else }}
{{- printf "%v" "false" -}}
{{- end }}
{{- end }}

{{- define "opsb.enableAgentlessMonitoring" -}}
{{- if (((.Values.global.services).agentlessMonitoring).deploy) }}
{{- $mcc := .Values.global.services.agentlessMonitoring.deploy }}
{{- printf "%v" $mcc -}}
{{- else }}
{{- printf "%v" "false" -}}
{{- end }}
{{- end }}

{{- define "opsb.enableOBM" -}}
{{- if (((.Values.global.services).obm).deploy) }}
{{- $obm := .Values.global.services.obm.deploy }}
{{- printf "%v" $obm -}}
{{- else }}
{{- printf "%v" "false" -}}
{{- end }}
{{- end }}

{{- define "opsb.enableApplicationMonitoring" -}}
{{- if (((.Values.global.services).applicationMonitoring).deploy) }}
{{- $stm := .Values.global.services.applicationMonitoring.deploy }}
{{- printf "%v" $stm -}}
{{- else }}
{{- printf "%v" "false" -}}
{{- end }}
{{- end }}

{{- define "opsb.enableAnomalyDetection" -}}
{{- if (((.Values.global.services).anomalyDetection).deploy) }}
{{- $ad := .Values.global.services.anomalyDetection.deploy }}
{{- printf "%v" $ad -}}
{{- else }}
{{- printf "%v" "false" -}}
{{- end }}
{{- end }}
