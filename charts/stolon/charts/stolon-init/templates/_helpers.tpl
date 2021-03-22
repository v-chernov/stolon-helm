helm.sh/chart: {{ .Chart.Name  }}-chart-{{ .Chart.Version }}
app.kubernetes.io/name: {{ .Chart.Name  }}-chart
app.kubernetes.io/instance: {{ .Chart.Name }}-project
app.kubernetes.io/version: {{ .Chart.Version }}
app.kubernetes.io/managed-by: Helm
