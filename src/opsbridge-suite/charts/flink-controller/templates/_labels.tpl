{{/* Labels for resources' top metadata */}}
{{ define "flink-controller.defaultLabels" }}
    app.kubernetes.io/name: itom-analytics-{{ .NameSuffix }}
    app.kubernetes.io/version: {{ .Version | quote }}
    app.kubernetes.io/component: {{ .Component }}
    app.kubernetes.io/part-of: flink-controller
    app.kubernetes.io/managed-by: {{ .HelmRelease }}
    itom.microfocus.com/capability: flink-controller
    itom.microfocus.com/capability-version: {{ mustRegexReplaceAll "^([-A-Za-z0-9_.]+).*$" .Chart.Version "${1}" }}-{{ .Chart.AppVersion }}
    tier.itom.microfocus.com/backend: backend
{{- end }}
