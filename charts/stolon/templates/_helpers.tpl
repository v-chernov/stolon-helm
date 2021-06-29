helm.sh/chart: {{ .Chart.Name  }}-chart-{{ .Chart.Version }}
app.kubernetes.io/name: {{ .Chart.Name  }}-chart
app.kubernetes.io/instance: {{ .Chart.Name }}-project
app.kubernetes.io/version: {{ .Chart.Version }}
app.kubernetes.io/managed-by: Helm

{{- define "stolon.rootPassword" -}}
  {{- if .Values.postgres_password -}}
    {{ default .Values.postgres_password }}
  {{- else -}}
   {{ default (randAlphaNum 30) }}
  {{- end -}}
{{- end -}}

{{- define "stolon.replicaPassword" -}}
  {{- if .Values.replication_password -}}
    {{ default .Values.replication_password }}
  {{- else -}}
   {{ default (randAlphaNum 30) }}
  {{- end -}}
{{- end -}}

{{- define "stolon.serviceAccount" -}}
  {{- if .Values.serviceAccount.name -}}
    {{ default .Values.serviceAccount.name }}
  {{- end -}}
{{- end -}}

{{- define "stolon.image" -}}
    {{ default .Values.image.registry }}/{{ default .Values.image.repository }}:{{ default .Values.image.tag }}-pg{{ default .Values.image.postgres }}
{{- end -}}


{{- define "stolon.cluster" -}}
    {{ default .Release.Name }}-{{ default .Release.Namespace }}
{{- end -}}

{{- define "sidecar.image" -}}
    {{ default .Values.sidecar.registry }}/{{ default .Values.sidecar.repository }}:{{ default .Values.sidecar.tag }}
{{- end -}}

{{- define "stolon.pullsecrets" -}}
{{- if .Values.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.image.pullSecrets }}
  - {{ . | toYaml}}
{{- end }}
{{- end }}
{{- end -}}

{{- define "stolon.config" -}}
{{- default .Release.Name -}}-config
{{- end -}}

{{- define "stolon.configPath" -}}
{{- default "/stolon-data/config" }}
{{- end -}}

{{ define "stolon.mounts" }}
- mountPath: "/etc/secrets/stolon"
  name: {{ .Release.Name }}
{{- if .Values.stolon }}
- mountPath: {{ include "stolon.configPath" . }}
  name: {{ include "stolon.config" . }}
{{- end }}
{{- end -}}

{{- define "stolon.configVolumes" }}
- name: {{ .Release.Name }}
  secret:
    secretName: {{ .Release.Name }}
{{- if .Values.stolon }}
- name: {{ include "stolon.config" . }}
  configMap:
    name: {{ .Release.Name }}-config
{{- end }}
{{- end }}

{{- define "stolon.ctl" }}
- name: STOLONCTL_CLUSTER_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['stolon-cluster']
- name: STOLONCTL_STORE_BACKEND
  value: "kubernetes"
- name: STOLONCTL_KUBE_RESOURCE_KIND
  value: "configmap"
{{- end }}

{{- define "stolon.data" }}
- name: STKEEPER_DATA_DIR
  value: "/stolon-data"
- name: STKEEPER_PG_SU_PASSWORDFILE
  value: "/stolon-data/password"
- name: STKEEPER_PG_REPL_PASSWORDFILE
  value: "/etc/secrets/stolon/replpassword"
{{- end }}

{{- define "psql.ctl" }}
- name: PGHOST
  value: "{{ .Release.Name }}"
- name: PGDATABASE
  value: "postgres"
{{- end }}

{{- define "check.node" -}}
psql postgresql://stolon:$(cat ${STKEEPER_PG_SU_PASSWORDFILE})@${POD_IP}:5432/${PGDATABASE} -c 'SELECT datname from pg_database'
{{- end -}}

{{- define "proxy.connect" -}}
psql postgresql://stolon:$(cat ${STKEEPER_PG_SU_PASSWORDFILE})@${PGHOST}:5432/${PGDATABASE}
{{- end -}}

{{- define "check.proxy" -}}
{{ include "proxy.connect" . }} -c 'SELECT datname from pg_database'
{{- end -}}

{{- define "logs" -}}
| tee --append ${STKEEPER_DATA_DIR}/startup.log
{{- end -}}

{{- define "data" -}}
echo $(date {{ .Values.logDataFormat }})
{{- end -}}
