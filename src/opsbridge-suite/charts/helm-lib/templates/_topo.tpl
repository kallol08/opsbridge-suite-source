{{- define "helm-lib.network.topologySpreadConstraints" -}}
{{- if and (semverCompare ">= 1.25.0-0" .Capabilities.KubeVersion.Version) (.Values.global.topologySpreadConstraintsDefaults).enabled (.Values.global.topologySpreadConstraintsDefaults).template }}
{{- $default := .Values.global.topologySpreadConstraintsDefaults.template -}}
{{- $labelValue := .labelValue -}}
{{/*if subchart set topologySpreadConstraints in values.yaml. */}}
{{- if (.Values.deployment).topologySpreadConstraints }}
topologySpreadConstraints:
  {{- range (.Values.deployment).topologySpreadConstraints }}
  - maxSkew: {{ coalesce .maxSkew $default.maxSkew "1" }}
    topologyKey: {{ coalesce .topologyKey $default.topologyKey "node" }}
    labelSelector:
      matchLabels:
        {{ required "A valid labelSelector is required!" (coalesce .labelSelector $labelValue) }}
    whenUnsatisfiable: {{ coalesce .whenUnsatisfiable $default.whenUnsatisfiable "ScheduleAnyway" }}
    {{- if or .nodeAffinityPolicy $default.nodeAffinityPolicy }}
    nodeAffinityPolicy: {{ coalesce .nodeAffinityPolicy $default.nodeAffinityPolicy }}
    {{- end }}
    {{- if or .nodeTaintsPolicy $default.nodeTaintsPolicy }}
    nodeTaintsPolicy: {{  coalesce .nodeTaintsPolicy $default.nodeTaintsPolicy }}
    {{- end }}
  {{- end }}
{{/*Subchart does not provide topologySpreadConstraints key in values.yaml and .Values.global.topologySpreadConstraintsDefaults.enabled is true. */}}
{{- else }}
topologySpreadConstraints:
  - maxSkew: {{ coalesce $default.maxSkew "1" }}
    topologyKey: {{ coalesce $default.topologyKey "node" }}
    labelSelector:
      matchLabels:
        {{ required "A valid labelSelector is required!"  $labelValue }}
    whenUnsatisfiable: {{ coalesce $default.whenUnsatisfiable "DoNotSchedule" }}
    {{- if $default.nodeAffinityPolicy }}
    nodeAffinityPolicy: $default.nodeAffinityPolicy
    {{- end }}
    {{- if $default.nodeTaintsPolicy }}
    nodeTaintsPolicy: $default.nodeTaintsPolicy
    {{- end }}
{{- end }}
{{- end -}}
{{- end -}}