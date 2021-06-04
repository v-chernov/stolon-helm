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

{{ define "stolon.passwordMount" }}
- mountPath: "/etc/secrets/stolon"
  name: {{ .Release.Name }}
{{- end -}}
