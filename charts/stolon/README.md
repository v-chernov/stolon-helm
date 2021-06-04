# stolon-helm

Raw and dirty helm chart for Stolon

Created from examples from an official repo https://github.com/sorintlab/stolon

## Variables:

```yaml
postgres_replicas: 3 # number of keeper (PostgreSQL + Kubernetes API interaction module) instances
proxy_replicas: 1 # number of cluster proxy instances
sentinel_replicas: 1 # number of sentinel (Kubernetes healthcheck module) instances
postgres_version: 12 # major version of PostgreSQL

persistence:
  # storageClass: "-"
  size: 512Mi

image:
  registry: docker.io
  repository: sorintlab/stolon
  tag: master # SorintLab Stolon release
  postgres: 12 # major PostgreSQL version
  pullPolicy: IfNotPresent
  #pullSecrets:

sidecar:
  registry: docker.io
  repository: busybox
  tag: "1.32.0"

serviceAccount:
  create: false
  #name: default

rbac:
  create: false

databases: {} # databases created after installation. CronJob will overwrite all your manual settings like
              # manually overwritten passwords
  #keycloak:
  #  name: keycloak
  #  password: # if empty or undefined, will be generated random password (30 symbols)
databases_creation_schedule: "*/2 * * * *" # Cron string

openshift:
  enabled: false # if True, OpenShift/OKD support will enabled (non-root execution etc)

postgres_password: ""  # if empty, will be generated random password (30 symbols)
replication_password: "" # if empty, will be generated random password (30 symbols)
  # ATTENTION. if you don't use fixed postgres_password and replication_password values
  # stolon cluster will be unreachable for ~20 seconds after helm upgrade
  # because of generation of new passwords
```
