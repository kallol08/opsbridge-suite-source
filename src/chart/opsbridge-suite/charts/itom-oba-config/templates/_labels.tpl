{{/* Labels for resources' top metadata */}}
{{ define "itom-oba-config.defaultLabels" }}
    app.kubernetes.io/name: itom-analytics-{{ .NameSuffix }}
    app.kubernetes.io/version: {{ .Version }}
    app.kubernetes.io/component: {{ .Component }}
    app.kubernetes.io/part-of: oba-config
    app.kubernetes.io/managed-by: {{ .HelmRelease }}
    itom.microfocus.com/capability: oba-config
    itom.microfocus.com/capability-version: {{ mustRegexReplaceAll "^([-A-Za-z0-9_.]+).*$" .Chart.Version "${1}" }}-{{ .Chart.AppVersion }}
    tier.itom.microfocus.com/backend: backend
{{- end }}