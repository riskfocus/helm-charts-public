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
    {{- if .Values.taskmanager.memoryProcessSize }}
    taskmanager.memory.process.size: {{ .Values.taskmanager.memoryProcessSize }}
    {{- end }}
    {{- if .Values.taskmanager.memoryFlinkSize }}
    taskmanager.memory.flink.size: {{ .Values.taskmanager.memoryFlinkSize }}
    {{- end }}
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
    high-availability.zookeeper.quorum: {{ tpl .Values.jobmanager.highAvailability.zookeeperConnect . }}
    high-availability.zookeeper.path.root: {{ .Values.jobmanager.highAvailability.zookeeperRootPath }}
    high-availability.cluster-id: {{ .Values.jobmanager.highAvailability.clusterId }}
    high-availability.storageDir: {{ .Values.jobmanager.highAvailability.storageDir }}
    high-availability.jobmanager.port: {{ .Values.jobmanager.highAvailability.syncPort }}
    {{- else }}
    jobmanager.rpc.address: {{ include "flink.fullname" . }}-jobmanager
    jobmanager.rpc.port: {{ .Values.jobmanager.ports.rpc }}
    {{- end }}
    {{- .Values.flink.params | nindent 4 }}
{{- end -}}
