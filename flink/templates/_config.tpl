{{/*
ServiceAccount for Jobmanager
*/}}
{{- define "jobmanager.serviceAccount" -}}
{{ default ( printf "%s-jobmanager" ( include "flink.fullname" . ) ) .Values.jobmanager.serviceAccount.name }}
{{- end -}}

{{/*
ServiceAccount for Taskmanager
*/}}
{{- define "taskmanager.serviceAccount" -}}
{{ default ( printf "%s-taskmanager" ( include "flink.fullname" . ) ) .Values.taskmanager.serviceAccount.name }}
{{- end -}}

{{/*
Generate command for Jobmanager
*/}}
{{- define "jobmanager.command" -}}
{{ $cmd := .Values.jobmanager.command }}
{{- if .Values.jobmanager.highAvailability.enabled }}
{{ $cmd = (tpl .Values.jobmanager.highAvailability.command .) }}
{{- end }}
{{- if .Values.jobmanager.additionalCommand -}}
{{ printf "%s && %s" .Values.jobmanager.additionalCommand $cmd }}
{{- else }}
{{ $cmd }}
{{- end -}}
{{- end -}}

{{/*
Generate command for Taskmanager
*/}}
{{- define "taskmanager.command" -}}
{{ $cmd := .Values.taskmanager.command }}
{{- if .Values.taskmanager.additionalCommand -}}
{{ printf "%s && %s" .Values.taskmanager.additionalCommand $cmd }}
{{- else }}
{{ $cmd }}
{{- end -}}
{{- end -}}

{{/*
Check if specific namespace is passed if false
then .Release.Namespace will be used
*/}}
{{- define "serviceMonitor.namespace" -}}
{{- if .Values.prometheus.serviceMonitor.namespace -}}
{{ .Values.prometheus.serviceMonitor.namespace }}
{{- else -}}
{{ .Release.Namespace }}
{{- end -}}
{{- end -}}
