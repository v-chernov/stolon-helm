# stolon-helm

Raw and dirty helm chart for Stolon

Created from examples from an official repo https://github.com/sorintlab/stolon

## Variables

```yaml
postgres_replicas: 3 # number of keeper (PostgreSQL + Kubernetes API interaction module) instances
proxy_replicas: 1 # number of cluster proxy instances
sentinel_replicas: 1 # number of sentinel (Kubernetes healthcheck module) instances

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

# if not empty, generate Stolon JSON config
# full reference in https://github.com/sorintlab/stolon/blob/master/doc/cluster_spec.md
# config apply after keeper restart
stolon:
  automaticPgRestart: false
  # most PostgreSQL parameters maps as pgSettings
  # use official docs for understanding them: https://www.postgresql.org/docs/12/config-setting.html
  pgSettings:
    wal_level: logical

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

## Be careful with your data!

In this configuration, cluster health is dependent from configMap named 
`stolon-cluster-{{ .Release.Name }}-{{ .Release.Namespace }}`

For example, if you installed your cluster with command
`helm install -n test-namespace stolon %CHART_LOCATION%`,
you can get if as `kubectl get configmap -n test-namespace stolon-cluster-stolon-test-namespace -o=yaml`

All cluster information stores in annotations of this configMap

If you delete this configMap, stolon-sentinel service automatically recover it.

But if you delete this configMap and scale down stolon-sentinel Deployment to 0, you will lose your cluster.

We strongly recommended use more than one stolon-sentinel for prevent this.

You must re-initialize it as existingCluster to recover in a manual mode.
If you just use `stolonctl init` command for it, you lose everything (and yes, your PostgreSQL data also will be lost).

### Steps:
1. Create backup of all data if keeper is running. If you haven't got any running keeper, just
   `cp -rp /stolon-data/postgres /stolon-data/postgres_backup && cp /stolon-data/password /stolon-data/postgres_backup`
2. Get backup of your cluster config. Backups stored on keepers in `/stolon-data/cluster_backup`
3. Edit this config. You must add parameters  `"initMode": "existing","existingConfig":{"keeperUID":"0"}` into JSON
4. Put edited config to one of the Stolon nodes, f.ex. {{ .Release.Name }}-keeper-0 into 
   `/stolon-data/cluster_backup/reinit.json`
5. Run reinitialization command, f.ex `stolonctl init -f /stolon-data/cluster_backup/reinit.json`
6. After some restarts you will get working reinitialized cluster

The original documentation can be found in https://github.com/sorintlab/stolon/blob/master/doc/initialization.md

## PostgreSQL settings apply

You cannot auto apply PostgreSQL settings now because most of important settings needs restart of the cluster nodes
with unknown effects of it.

PostgreSQL's settings apply after creating of pod (f.ex after a manual restart) by separate command

You can use setting like

```yaml
stolon:
    automaticPgRestart: true
```

for restarting your nodes with new settings, but we strongly recommend don't use this feature.

## Users

By default, Stolon use 2 system cluster users: `stolon` as a superuser and `repluser` as a system replication user.

If you want to perform the total destroy of the cluster you can just execute 
`ALTER USER stolon WITH PASSWORD 'somepassword'`. After it, PostgreSQL nodes will be restarted and couldn't 
recover ever.
