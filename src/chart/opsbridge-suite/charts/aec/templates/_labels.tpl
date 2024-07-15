{{/* Labels for resources' top metadata */}}
{{ define "aec.defaultLabels" }}
    app.kubernetes.io/name: itom-analytics-{{ .NameSuffix }}
    app.kubernetes.io/version: {{ .Version | quote }}
    app.kubernetes.io/component: {{ .Component }}
    app.kubernetes.io/part-of: aec
    app.kubernetes.io/managed-by: {{ .HelmRelease }}
    itom.microfocus.com/capability: aec
    itom.microfocus.com/capability-version: {{ mustRegexReplaceAll "^([-A-Za-z0-9_.]+).*$" .Chart.Version "${1}" }}-{{ .Chart.AppVersion }}
    tier.itom.microfocus.com/backend: backend
{{- end }}
