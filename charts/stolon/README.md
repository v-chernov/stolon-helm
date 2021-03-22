# stolon-helm

Raw and dirty helm chart for Stolon

Created from examples from an official repo https://github.com/sorintlab/stolon

## Variables:

```yaml
postgres_replicas: 3 # number of keeper (PostgreSQL + Kubernetes API interaction module) instances
proxy_replicas: 1 # number of cluster proxy instances
sentinel_replicas: 1 # number of sentinel (Kubernetes healthcheck module) instances
postgres_storage_size: 512Mi
postgres_version: 12 # major version of PostgreSQL

global:
  postgres_version: 12
  image_repo: ''
  pgSettings:

databases: {} # databases created after installation. CronJob will overwrite all your manual settings like
              # manually overwritten passwords
  #keycloak:
  #  name: keycloak
  #  password: # if empty or undefined, will be generated random password (30 symbols)
databases_creation_schedule: "5"

openshift:
  enabled: false # if True, OpenShift/OKD support will enabled (non-root execution etc)

postgres_password: ""  # if empty, will be generated random password (30 symbols)

```
