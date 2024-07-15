#
# The purpose of the macros in this file is to retrieve selected locales for BVD reports
# E.g: The macros will read the user-provided configuration in values.yaml
# and retrieve the selected inputs which can be used by service YAMLs and backend code
#

{{- define "helm-lib.getSelectedLocaleForBvd" -}}
   {{- if .Values.global.services.bvd.locales -}}
       {{- $value := .Values.global.services.bvd.locales }}
       {{- $value := regexReplaceAll "'+" $value "" }}
       {{- $value := regexReplaceAll "\\[+" $value "" }}
       {{- $value := regexReplaceAll "\\]+" $value "" }}
       {{- $value := regexReplaceAll "\"+" $value "" }}
       {{- $value := regexReplaceAll " +" $value "" }}
       {{- printf "%s" $value }}
   {{- end -}}
{{- end -}}
