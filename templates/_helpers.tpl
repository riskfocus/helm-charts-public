{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "flink.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "flink.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "flink.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "flink.labels" -}}
app.kubernetes.io/name: {{ include "flink.name" . }}
helm.sh/chart: {{ include "flink.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
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

{{/*
ServiceAccount for Jobmanager
*/}}
{{- define "jobmanager.serviceAccount" -}}
{{ default "jobmanager" .Values.jobmanager.serviceAccount.name }}
{{- end -}}

{{/*
ServiceAccount for Taskmanager
*/}}
{{- define "taskmanager.serviceAccount" -}}
{{ default "taskmanager" .Values.taskmanager.serviceAccount.name }}
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
Generate Flink Configuration.
We do it here to support HA mode where we cannot
provide jobmanager.rpc.address to Taskmanagers
*/}}
{{- define "flink.configuration" -}}
    taskmanager.numberOfTaskSlots: {{ .Values.taskmanager.numberOfTaskSlots }}
    blob.server.port: {{ .Values.jobmanager.ports.blob }}
    taskmanager.rpc.port: {{ .Values.taskmanager.ports.rpc }}
    jobmanager.heap.size: {{ .Values.jobmanager.heapSize }}
    taskmanager.heap.size: {{ .Values.taskmanager.heapSize }}
    {{- .Values.flink.params | nindent 4 }}
    {{- if .Values.flink.monitoring.enabled }}
    metrics.reporters: prom
    metrics.reporter.prom.class: org.apache.flink.metrics.prometheus.PrometheusReporter
    metrics.reporter.prom.port: {{ .Values.flink.monitoring.port }}
      {{- if .Values.flink.monitoring.system.enabled }}
    metrics.system-resource: true
    metrics.system-resource-probing-interval: {{ .Values.flink.monitoring.system.probingInterval }}
      {{- end }}
      {{- if .Values.flink.monitoring.latency.enabled }}
    metrics.latency.interval: {{ .Values.flink.monitoring.latency.probingInterval }}
      {{- end }}
      {{- if .Values.flink.monitoring.rocksdb.enabled }}
    state.backend.rocksdb.metrics.cur-size-active-mem-table: true
    state.backend.rocksdb.metrics.cur-size-all-mem-tables: true
    state.backend.rocksdb.metrics.estimate-live-data-size: true
    state.backend.rocksdb.metrics.size-all-mem-tables: true
    state.backend.rocksdb.metrics.estimate-num-keys: true
      {{- end }}
    {{- end }}
    {{- if .Values.flink.state.backend }}
    state.backend: {{ .Values.flink.state.backend }}
    {{- .Values.flink.state.params | nindent 4 }}
      {{- if eq .Values.flink.state.backend "rocksdb" }}
    {{- .Values.flink.state.rocksdb | nindent 4 }}
      {{- end }}
    {{- end }}
    {{- if .Values.jobmanager.highAvailability.enabled }}
    high-availability: zookeeper
    high-availability.zookeeper.quorum: {{ .Values.jobmanager.highAvailability.zookeeperConnect }}
    high-availability.zookeeper.path.root: /flink
    high-availability.cluster-id: /flink
    high-availability.storageDir: {{ .Values.jobmanager.highAvailability.storageDir }}
    high-availability.jobmanager.port: {{ .Values.jobmanager.highAvailability.syncPort }}
    {{- else }}
    jobmanager.rpc.address: {{ include "flink.fullname" . }}-jobmanager
    jobmanager.rpc.port: {{ .Values.jobmanager.ports.rpc }}
    {{- end }}
{{- end -}}