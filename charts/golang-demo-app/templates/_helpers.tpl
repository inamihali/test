{{/* vim: set filetype=mustache: */}}

{{- define "ingressHostTarget" }}
{{- if eq .Values.global.env "staging" -}}
{{- printf "icscale-01-priv-stg.vip.dailymotion.com" -}}
{{- else if eq .Values.global.env "dev" -}}
{{- printf "icscale-01-priv-dev.vip.dailymotion.com" -}}
{{- else }}
{{- printf "icinfra-01-priv.vip.dailymotion.com" -}}
{{- end }}
{{- end }}

{{- define "ingressHost" }}
{{- if eq .Values.global.env "staging" -}}
{{- printf "-staging.kube.dm.gg" -}}
{{- else if eq .Values.global.env "dev" -}}
{{- printf "-dev.kube.dm.gg" -}}
{{- else }}
{{- printf ".dailymotion.com" -}}
{{- end }}
{{- end }}
