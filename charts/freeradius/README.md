<!--- app-name: FreeRADIUS -->

# Helm chart for FreeRADIUS

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/startechnica)](https://artifacthub.io/packages/search?repo=startechnica)
![Version](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square)
![Type](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion](https://img.shields.io/badge/AppVersion-3.2.8-informational?style=flat-square)

FreeRADIUS is a modular, high performance free RADIUS suite developed and distributed under the GNU General Public License, version 2, and is free for download and use.

[Overview of FreeRADIUS](https://freeradius.org/)

**This chart is not maintained by the upstream project and any issues with the chart should be raised [here](https://github.com/startechnica/apps/issues/new/choose)**

## TL;DR

```console
helm repo add startechnica https://startechnica.github.io/apps
helm install my-release startechnica/freeradius
```

## Prerequisites

- Kubernetes 1.22+
- Helm 3.10.0+

## Installing the Chart

To install the chart with the release name `my-release` on `my-release` namespace:

```console
helm repo add startechnica https://startechnica.github.io/apps
helm install my-release startechnica/freeradius --namespace my-release --create-namespace
```

These commands deploy FreeRADIUS on the Kubernetes cluster in the default configuration.

> **Tip**: List all releases using `helm list -A`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release --namespace my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Global parameters

| Name                       | Description                                                                                                             | Value |
| -------------------------  | ----------------------------------------------------------------------------------------------------------------------- | ----- |
| `global.imageRegistry`     | Global Docker image registry                                                                                            | `""`  |
| `global.imagePullSecrets`  | Global Docker registry secret names as an array                                                                         | `[]`  |
| `global.storageClass`      | Global StorageClass for Persistent Volume(s)                                                                            | `""`  |
| `global.namespaceOverride` | Override the namespace for resource deployed by the chart, but can itself be overridden by the local namespaceOverride  | `""`  |


### Common parameters

| Name                       | Description                                                                                                       | Value           |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------------- |
| `kubeVersion`              | Force target Kubernetes version (using Helm capabilities if not set)                                              | `""`            |
| `nameOverride`             | String to partially override common.names.fullname template with a string (will prepend the release name)         | `""`            |
| `namespaceOverride`        | String to fully override common.names.namespace                                                                   | `""`            |
| `fullnameOverride`         | String to fully override common.names.fullname template with a string                                             | `""`            |
| `commonAnnotations`        | Annotations to add to all deployed objects                                                                        | `{}`            |
| `commonLabels`             | Labels to add to all deployed objects                                                                             | `{}`            |
| `schedulerName`            | Name of the Kubernetes scheduler (other than default)                                                             | `""`            |
| `clusterDomain`            | Kubernetes DNS Domain name to use                                                                                 | `cluster.local` |
| `extraDeploy`              | Array of extra objects to deploy with the release (evaluated as a template)                                       | `[]`            |
| `diagnosticMode.enabled`   | Enable diagnostic mode (all probes will be disabled and the command will be overridden)                           | `false`         |
| `diagnosticMode.command`   | Command to override all containers in the deployment                                                              | `[]`            |
| `diagnosticMode.args`      | Args to override all containers in the deployment                                                                 | `[]`            |
   
   
### FreeRADIUS parameters

| Name                                          | Description                                                                                                              | Value                          |
| ----------------------------------------------| -------------------------------------------------------------------------------------------------------------------------| -------------------------------|
| `image.registry`                              | FreeRADIUS image registry                                                                                                | `docker.io`                    |
| `image.repository`                            | FreeRADIUS image repository                                                                                              | `freeradius/freeradius-server` |
| `image.tag`                                   | FreeRADIUS image tag (immutable tags are recommended)                                                                    | `3.2.3`                        |
| `image.pullPolicy`                            | FreeRADIUS image pull policy                                                                                             | `IfNotPresent`                 |
| `image.pullSecrets`                           | Specify docker-registry secret names as an array                                                                         | `[]`                           |
| `image.debug`                                 | Set to true if you would like to see extra information on logs                                                           | `false`                        |
| `hostAliases`                                 | Deployment pod host aliases                                                                                              | `[]`                           |
| `command`                                     | Override default container command (useful when using custom images)                                                     | `[]`                           |
| `args`                                        | Override default container args (useful when using custom images)                                                        | `[]`                           |
| `extraEnvVars`                                | Extra environment variables to be set on FreeRADIUS containers                                                           | `[]`                           |
| `extraEnvVarsCM`                              | ConfigMap with extra environment variables                                                                               | `""`                           |
| `extraEnvVarsSecret`                          | Secret with extra environment variables                                                                                  | `""`                           |
| `service.type`                                | Kubernetes service type                                                                                                  | `ClusterIP`                    |
| `service.clusterIP`                           | Specific cluster IP when service type is cluster IP. Use `None` for headless service                                     | `""`                           |
| `service.ports.auth`                          | FreeRADIUS Authentication and Authorization service port                                                                 | `1812`                         |
| `service.ports.acct`                          | FreeRADIUS Accounting service port                                                                                       | `1813`                         |
| `service.ports.coa`                           | FreeRADIUS CoA service port                                                                                              | `3799`                         |
| `service.ports.radsec`                        | FreeRADIUS RadSec service port                                                                                           | `2083`                         |
| `service.ports.status`                        | FreeRADIUS Status service port                                                                                           | `18121`                        |
| `service.nodePorts.auth`                      | Specify the nodePort value for the LoadBalancer and NodePort for Authentication service types.                           | `""`                           |
| `service.nodePorts.acct`                      | Specify the nodePort value for the LoadBalancer and NodePort for Accounting service types.                               | `""`                           |
| `service.nodePorts.coa`                       | Specify the nodePort value for the LoadBalancer and NodePort for CoA service types.                                      | `""`                           |
| `service.nodePorts.radsec`                    | Specify the nodePort value for the LoadBalancer and NodePort for RadSec service types.                                   | `""`                           |
| `service.nodePorts.status`                    | Specify the nodePort value for the LoadBalancer and NodePort for Status service types.                                   | `""`                           |
| `service.extraPorts`                          | Extra ports to expose (normally used with the `sidecar` value)                                                           | `[]`                           |
| `service.externalIPs`                         | External IP list to use with ClusterIP service type                                                                      | `[]`                           |
| `service.loadBalancerIP`                      | `loadBalancerIP` if service type is `LoadBalancer`                                                                       | `""`                           |
| `service.loadBalancerSourceRanges`            | Addresses that are allowed when svc is `LoadBalancer`                                                                    | `[]`                           |
| `service.externalTrafficPolicy`               | FreeRADIUS service external traffic policy                                                                               | `Cluster`                      |
| `service.annotations`                         | Additional annotations for FreeRADIUS service                                                                            | `{}`                           |
| `service.sessionAffinity`                     | Session Affinity for Kubernetes service, can be `None` or `ClientIP`                                                     | `None`                         |
| `service.sessionAffinityConfig`               | Additional settings for the sessionAffinity                                                                              | `{}`                           |
| `serviceAccount.create`                       | Specify whether a ServiceAccount should be created                                                                       | `false`                        |
| `serviceAccount.name`                         | Name of the service account to use. If not set and create is true, a name is generated using the fullname template.      | `""`                           |
| `serviceAccount.automountServiceAccountToken` | Automount service account token for the server service account                                                           | `false`                        |
| `serviceAccount.annotations`                  | Annotations for service account. Evaluated as a template. Only used if `create` is `true`.                               | `{}`                           |
| `command`                                     | Override default container command (useful when using custom images)                                                     | `[]`                           |
| `extraEnvVars`                                | Array containing extra env vars to configure FreeRADIUS                                                                  | `[]`                           |
| `extraEnvVarsCM`                              | ConfigMap containing extra env vars to configure FreeRADIUS                                                              | `""`                           |
| `extraEnvVarsSecret`                          | Secret containing extra env vars to configure FreeRADIUS                                                                 | `""`                           |
| `rbac.create`                                 | Specify whether RBAC resources should be created and used                                                                | `false`                        |
| `podSecurityContext.enabled`                  | Enable security context                                                                                                  | `true`                         |
| `podSecurityContext.fsGroup`                  | Group ID for the container filesystem                                                                                    | `101`                          |
| `podSecurityContext.runAsUser`                | User ID for the container                                                                                                | `101`                          |
| `containerSecurityContext.enabled`            | Enabled FreeRADIUS container Security Context                                                                            | `true`                         |
| `containerSecurityContext.runAsUser`          | Set FreeRADIUS container Security Context runAsUser                                                                      | `101`                          |
| `containerSecurityContext.runAsNonRoot`       | Set FreeRADIUS container Security Context runAsNonRoot                                                                   | `true`                         |
| `tls.enabled`                                 | Enable TLS support for replication traffic                                                                               | `false`                        |
| `tls.autoGenerated`                           | Generate automatically self-signed TLS certificates                                                                      | `false`                        |
| `tls.autoGenerator.certmanager.enabled`       |                                                                                                                          | `false`                        |
| `tls.certificatesSecret`                      | Name of the secret that contains the certificates                                                                        | `"false"`                           |
| `tls.certFilename`                            | Certificate filename                                                                                                     | `""`                           |
| `tls.certKeyFilename`                         | Certificate key filename                                                                                                 | `""`                           |
| `tls.certCAFilename`                          | CA Certificate filename                                                                                                  | `""`                           |
| `configuration`                               | Configuration for the FreeRADIUS server (`radiusd.conf`)                                                                 | `""`                           |
| `configurationsConfigMap`                     | ConfigMap with the FreeRADIUS configuration files (Note: Overrides `configurations`). The value is evaluated as a template. | `""`                        |
| `initdbScripts`                               | Specify dictionary of scripts to be run at first boot                                                                    | `{}`                           |
| `initdbScriptsConfigMap`                      | ConfigMap with the initdb scripts (Note: Overrides `initdbScripts`)                                                      | `""`                           |
| `extraFlags`                                  | FreeRADIUS additional command line flags                                                                                 | `""`                           |
| `replicaCount`                                | Desired number of cluster nodes                                                                                          | `3`                            |
| `podLabels`                                   | Extra labels for FreeRADIUS pods                                                                                         | `{}`                           |
| `podAnnotations`                              | Annotations for FreeRADIUS  pods                                                                                         | `{}`                           |
| `podAffinityPreset`                           | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                      | `""`                           |
| `podAntiAffinityPreset`                       | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                 | `soft`                         |
| `nodeAffinityPreset.type`                     | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                | `""`                           |
| `nodeAffinityPreset.key`                      | Node label key to match. Ignored if `affinity` is set.                                                                   | `""`                           |
| `nodeAffinityPreset.values`                   | Node label values to match. Ignored if `affinity` is set.                                                                | `[]`                           |
| `affinity`                                    | Affinity for pod assignment                                                                                              | `{}`                           |
| `nodeSelector`                                | Node labels for pod assignment                                                                                           | `{}`                           |
| `tolerations`                                 | Tolerations for pod assignment                                                                                           | `[]`                           |
| `topologySpreadConstraints`                   | Topology Spread Constraints for pods assignment                                                                          | `[]`                           |
| `lifecycleHooks`                              | for the galera container(s) to automate configuration before or after startup                                            | `{}`                           |
| `containerPorts.auth`                         | Auth database container port                                                                                             | `1812`                         |
| `containerPorts.acct`                         | Acct cluster container port                                                                                              | `1813`                         |
| `containerPorts.coa`                          | CoA container port                                                                                                       | `3799`                         |
| `containerPorts.radsec`                       | RadSec container port                                                                                                    | `2083`                         |
| `containerPorts.status`                       | Status container port                                                                                                    | `18121`                        |
| `persistence.enabled`                         | Enable persistence using PVC                                                                                             | `true`                         |
| `persistence.existingClaim`                   | Provide an existing `PersistentVolumeClaim`                                                                              | `""`                           |
| `persistence.subPath`                         | Subdirectory of the volume to mount                                                                                      | `""`                           |
| `persistence.mountPath`                       | Path to mount the volume at                                                                                              | `/startechnica/freeradius`     |
| `persistence.selector`                        | Selector to match an existing Persistent Volume (this value is evaluated as a template)                                  | `{}`                           |
| `persistence.storageClass`                    | Persistent Volume Storage Class                                                                                          | `""`                           |
| `persistence.annotations`                     | Persistent Volume Claim annotations                                                                                      | `{}`                           |
| `persistence.labels`                          | Persistent Volume Claim Labels                                                                                           | `{}`                           |
| `persistence.accessModes`                     | Persistent Volume Access Modes                                                                                           | `["ReadWriteOnce"]`            |
| `persistence.size`                            | Persistent Volume Size                                                                                                   | `8Gi`                          |
| `priorityClassName`                           | Priority Class Name for Statefulset                                                                                      | `""`                           |
| `initContainers`                              | Additional init containers (this value is evaluated as a template)                                                       | `[]`                           |
| `sidecars`                                    | Add additional sidecar containers (this value is evaluated as a template)                                                | `[]`                           |
| `extraVolumes`                                | Extra volumes                                                                                                            | `[]`                           |
| `extraVolumeMounts`                           | Mount extra volume(s)                                                                                                    | `[]`                           |
| `resources.limits`                            | The resources limits for the container                                                                                   | `{}`                           |
| `resources.requests`                          | The requested resources for the container                                                                                | `{}`                           |
| `livenessProbe.enabled`                       | Turn on and off liveness probe                                                                                           | `true`                         |
| `livenessProbe.initialDelaySeconds`           | Delay before liveness probe is initiated                                                                                 | `120`                          |
| `livenessProbe.periodSeconds`                 | How often to perform the probe                                                                                           | `10`                           |
| `livenessProbe.timeoutSeconds`                | When the probe times out                                                                                                 | `1`                            |
| `livenessProbe.failureThreshold`              | Minimum consecutive failures for the probe                                                                               | `3`                            |
| `livenessProbe.successThreshold`              | Minimum consecutive successes for the probe                                                                              | `1`                            |
| `readinessProbe.enabled`                      | Turn on and off readiness probe                                                                                          | `true`                         |
| `readinessProbe.initialDelaySeconds`          | Delay before readiness probe is initiated                                                                                | `30`                           |
| `readinessProbe.periodSeconds`                | How often to perform the probe                                                                                           | `10`                           |
| `readinessProbe.timeoutSeconds`               | When the probe times out                                                                                                 | `1`                            |
| `readinessProbe.failureThreshold`             | Minimum consecutive failures for the probe                                                                               | `3`                            |
| `readinessProbe.successThreshold`             | Minimum consecutive successes for the probe                                                                              | `1`                            |
| `startupProbe.enabled`                        | Turn on and off startup probe                                                                                            | `false`                        |
| `startupProbe.initialDelaySeconds`            | Delay before startup probe is initiated                                                                                  | `120`                          |
| `startupProbe.periodSeconds`                  | How often to perform the probe                                                                                           | `10`                           |
| `startupProbe.timeoutSeconds`                 | When the probe times out                                                                                                 | `1`                            |
| `startupProbe.failureThreshold`               | Minimum consecutive failures for the probe                                                                               | `48`                           |
| `startupProbe.successThreshold`               | Minimum consecutive successes for the probe                                                                              | `1`                            |
| `customStartupProbe`                          | Custom liveness probe for the Web component                                                                              | `{}`                           |
| `customLivenessProbe`                         | Custom liveness probe for the Web component                                                                              | `{}`                           |
| `customReadinessProbe`                        | Custom rediness probe for the Web component                                                                              | `{}`                           |
| `podDisruptionBudget.create`                  | Specifies whether a Pod disruption budget should be created                                                              | `false`                        |
| `podDisruptionBudget.minAvailable`            | Minimum number / percentage of pods that should remain scheduled                                                         | `1`                            |
| `podDisruptionBudget.maxUnavailable`          | Maximum number / percentage of pods that may be made unavailable                                                         | `""`                           |
| `metrics.enabled`                             | Start a side-car prometheus exporter                                                                                     | `false`                        |
| `metrics.image.registry`                      | FreeRADIUS Prometheus exporter image registry                                                                            | `""`                           |
| `metrics.image.repository`                    | FreeRADIUS Prometheus exporter image repository                                                                          | `""`                           |
| `metrics.image.tag`                           | FreeRADIUS Prometheus exporter image tag (immutable tags are recommended)                                                | `""`                           |
| `metrics.image.pullPolicy`                    | FreeRADIUS Prometheus exporter image pull policy                                                                         | `IfNotPresent`                 |
| `metrics.image.pullSecrets`                   | FreeRADIUS Prometheus exporter image pull secrets                                                                        | `[]`                           |
| `metrics.extraFlags`                          | FreeRADIUS Prometheus exporter additional command line flags                                                             | `[]`                           |
| `metrics.resources.limits`                    | The resources limits for the container                                                                                   | `{}`                           |
| `metrics.resources.requests`                  | The requested resources for the container                                                                                | `{}`                           |
| `metrics.service.type`                        | Prometheus exporter service type                                                                                         | `ClusterIP`                    |
| `service.ports.metrics`                       | Prometheus exporter service port (top-level ports inventory)                                                             | `9812`                         |
| `metrics.service.annotations`                 | Prometheus exporter service annotations                                                                                  | `{}`                           |
| `metrics.service.loadBalancerIP`              | Load Balancer IP if the Prometheus metrics server type is `LoadBalancer`                                                 | `""`                           |
| `metrics.service.clusterIP`                   | Prometheus metrics service Cluster IP                                                                                    | `""`                           |
| `metrics.service.loadBalancerSourceRanges`    | Prometheus metrics service Load Balancer sources                                                                         | `[]`                           |
| `metrics.service.externalTrafficPolicy`       | Prometheus metrics service external traffic policy                                                                       | `Cluster`                      |
| `metrics.serviceMonitor.enabled`              | if `true`, creates a Prometheus Operator ServiceMonitor (also requires `metrics.enabled` to be `true`)                   | `false`                        |
| `metrics.serviceMonitor.namespace`            | Optional namespace which Prometheus is running in                                                                        | `""`                           |
| `metrics.serviceMonitor.jobLabel`             | The name of the label on the target service to use as the job name in prometheus.                                        | `""`                           |
| `metrics.serviceMonitor.interval`             | How frequently to scrape metrics (use by default, falling back to Prometheus' default)                                   | `""`                           |
| `metrics.serviceMonitor.scrapeTimeout`        | Timeout after which the scrape is ended                                                                                  | `""`                           |
| `metrics.serviceMonitor.selector`             | ServiceMonitor selector labels                                                                                           | `{}`                           |
| `metrics.serviceMonitor.relabelings`          | RelabelConfigs to apply to samples before scraping                                                                       | `[]`                           |
| `metrics.serviceMonitor.metricRelabelings`    | MetricRelabelConfigs to apply to samples before ingestion                                                                | `[]`                           |
| `metrics.serviceMonitor.honorLabels`          | honorLabels chooses the metric's labels on collisions with target labels                                                 | `false`                        |
| `metrics.serviceMonitor.labels`               | ServiceMonitor extra labels                                                                                              | `{}`                           |
| `metrics.prometheusRule.enabled`              | If `true`, creates a Prometheus Operator PrometheusRule (also requires `metrics.enabled`, and makes little sense without `metrics.serviceMonitor.enabled`)                                     | `false`                        |
| `metrics.prometheusRule.namespace`            | Namespace in which to create the PrometheusRule (defaults to the release namespace)                                                                                                           | `""`                           |
| `metrics.prometheusRule.additionalLabels`     | Extra labels merged onto the PrometheusRule so the Prometheus Operator's `ruleSelector` picks it up                                                                                           | `{app: prometheus-operator, release: prometheus}` |
| `metrics.prometheusRule.groups`               | Verbatim `spec.groups` list passthrough (additive with `rules`)                                                                                                                               | `[]`                           |
| `metrics.prometheusRule.rules`                | PrometheusRule rules rendered under a single group named after the chart fullname (default set targets `bvantagelimited/freeradius_exporter` metric names)                                    | See `values.yaml`              |


### Modules parameters

| Name                                       | Description                                         | Value             |
| ------------------------------------------ | --------------------------------------------------- | ----------------- |
| `modules.sql.enabled`                  | Enable FreeRADIUS SQL module                        | `false`           |
| `modules.sql.dialect`                  | The driver module used to execute the queries.      | `mysql`           |
| `modules.sql.table.acct1`              | Tables containing 'accounting' items                | `radacct`         |
| `modules.sql.table.acct2`              | Tables containing 'accounting' items                | `radacct`         |
| `modules.sql.table.authcheck`          | Tables containing 'check' items                     | `radcheck`        |
| `modules.sql.table.authreply`          | Tables containing 'reply' items                     | `radreply`        |
| `modules.sql.table.client`             | Table to keep radius client info                    | `nas`             |
| `modules.sql.table.groupcheck`         | Tables containing 'check' items                     | `radgroupcheck`   |
| `modules.sql.table.groupreply`         | Tables containing 'reply' items                     | `radgroupreply`   |
| `modules.sql.table.postauth`           | Allow for storing data after authentication         | `radpostauth`     |
| `modules.sql.table.usergroup`          | Table to keep group info                            | `radusergroup`    |
| `modules.sql.tls.enabled`              | Enable FreeRADIUS SQL TLS module                    | `false`           |
| `modules.sql.tls.autoGenerated`        |                                                     | `false`           |
| `modules.sql.tls.certificatesSecret`   |                                                     | `""`              |
| `modules.sql.tls.certFilename`         |                                                     | `""`              |
| `modules.sql.tls.certKeyFilename`      |                                                     | `""`              |
| `modules.sql.tls.certCAFilename`       |                                                     | `""`              |
| `modules.sql.tls.existingTlsSecret`    |                                                     | `""`              |


### Custom FreeRADIUS enabled sites parameters

| Name                                       | Description                                                                     | Value             |
| ------------------------------------------ | ------------------------------------------------------------------------------- | ----------------- |
| `sites.default.enabled`               | Enable the `default` virtual server (the main auth/acct server)                                    | `true`    |
| `sites.default.existingConfigMap`     | BYO ConfigMap (key `default`) mounted at `sites-enabled/default`; skips chart rendering            | `""`      |
| `sites.innerTunnel.enabled`           | Enable the `inner-tunnel` virtual server (EAP-TTLS/PEAP inner identity)                            | `true`    |
| `sites.innerTunnel.existingConfigMap` | BYO ConfigMap (key `inner-tunnel`) mounted at `sites-enabled/inner-tunnel`; skips chart rendering  | `""`      |
| `sites.coa.enabled`                   | Enable the `coa` virtual server (Change-of-Authorization)                                          | `false`   |
| `sites.coa.existingConfigMap`         | BYO ConfigMap (key `coa`) mounted at `sites-enabled/coa`; skips chart rendering                    | `""`      |
| `sites.status.enabled`                | Enable the `status` virtual server                                                                 | `true`    |
| `sites.status.listen`                 | Listen address for the status server                                                               | `0.0.0.0` |
| `sites.status.secret`                 | Shared secret for the status `radclient` (auto-generated when empty)                               | `""`      |
| `sites.status.existingConfigMap`      | BYO ConfigMap (key `status`) mounted at `sites-enabled/status`; skips chart rendering              | `""`      |
| `sites.dhcp.enabled`                  | Enable the `dhcp` virtual server                                                                   | `false`   |
| `sites.dhcp.existingConfigMap`        | BYO ConfigMap (key `dhcp`) mounted at `sites-enabled/dhcp`; skips chart rendering                  | `""`      |
| `sites.tls.enabled`                   | Enable the RADSEC virtual server                                                                   | `false`   |
| `sites.tls.cipher`                    | TLS cipher suite passed to the RADSEC server (`DEFAULT` keeps the image default)                   | `DEFAULT` |
| `sites.tls.privateKeyPassword`        | Password for the RADSEC private key when it is password-protected                                  | `""`      |
| `sites.tls.existingConfigMap`         | BYO ConfigMap (key `tls`) mounted at `sites-enabled/tls`; skips chart rendering                    | `""`      |


### Keycloak integration parameters

| Name                       | Description                                                                                                            | Value                      |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| `keycloak.enabled`         | Render the Keycloak auth configs + Secret and mount them into the pod                                                 | `false`                    |
| `keycloak.mode`            | Auth backend: `lua` (ROPC + introspection + role mapping via rlm_lua) or `rest` (ROPC-only via rlm_rest, no roles)    | `lua`                      |
| `keycloak.url`             | Base URL of the Keycloak server                                                                                       | `https://auth.example.com` |
| `keycloak.realm`           | Keycloak realm holding the users (required when enabled)                                                              | `""`                       |
| `keycloak.clientId`        | OIDC client_id with Direct Access Grants enabled                                                                      | `freeradius`               |
| `keycloak.clientSecret`    | Secret for a confidential client. Stored in a Secret and injected via `$ENV{KC_CLIENT_SECRET}`; empty = public client | `""`                       |
| `keycloak.scope`           | Optional OAuth scope appended to the token request                                                                    | `""`                       |
| `keycloak.connectTimeout`  | Socket timeout (seconds) for Keycloak HTTPS calls (lua: `https.TIMEOUT`; rest: `connect_timeout`)                     | `4.0`                      |
| `keycloak.wireDefaultSite` | Auto-wire the `default` virtual server's authorize section to call the Keycloak auth module                           | `true`                     |
| `keycloak.roleAttribute`   | (lua mode) Control attribute the Lua mapper populates with role names (one value per role)                            | `Class`                    |
| `keycloak.denyWithoutRole` | (lua mode) Reject the request when no `roleMappings` entry matches                                                    | `false`                    |
| `keycloak.roleMappings`    | (lua mode) Ordered role→reply map (first match wins): `role` + `reply` (list of unlang `Attr := value` lines)         | `[]`                       |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
helm install my-release \
  --set imagePullPolicy=Always \
  startechnica/freeradius
```

The above command sets the `imagePullPolicy` to `Always`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
helm install my-release startechnica/freeradius -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Configuration and installation details

### Adding extra environment variables

In case you want to add extra environment variables (useful for advanced operations like custom init scripts), you can use the `extraEnvVars` property.

```yaml
extraEnvVars:
  - name: LOG_LEVEL
    value: error
```

Alternatively, you can use a ConfigMap or a Secret with the environment variables. To do so, use the `extraEnvVarsCM` or the `extraEnvVarsSecret` values.

### Setting Pod's affinity

This chart allows you to set your custom affinity using the `affinity` parameter. Find more information about Pod's affinity in the [kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity).

### Deploying extra resources

There are cases where you may want to deploy extra objects, such a ConfigMap containing your app's configuration or some extra deployment with a micro service used by your app. For covering this case, the chart allows adding the full specification of other objects using the `extraDeploy` parameter.

### Redis-backed cache

The `rlm_cache` module (`modules.cache`) defaults to the in-memory `rbtree`
driver, which is per-pod. To share cache state across replicas, switch it to the
`redis` driver and bundle a Redis. The **minimum** values are:

```yaml
redis:
  enabled: true        # bundle a Bitnami Redis (auth is on by default)

modules:
  cache:
    enabled: true
    driver: redis      # default is rbtree (in-memory, per-pod)
```

Regardless of driver, `rlm_cache` refuses to load without a non-empty
`update { }` section, so `modules.cache.update` is **required**. It holds the
attributes to cache in FreeRADIUS map syntax (`<list>:<attr> <op> <value>`, one
per line) and defaults to `&reply: += &reply:` (cache the whole reply list).
Override it for what you actually need to cache.

With `redis.enabled: true` the chart auto-wires the connection: the cache targets
the bundled `<release>-redis-master` Service and injects the Redis password from
the subchart's Secret as `$ENV{FREERADIUS_MODS_REDIS_PASSWORD}` — you don't set a
host or password yourself. You do **not** need `modules.redis.enabled` (that only
adds the `%{redis:...}` xlat); the cache reuses the connection settings under
`modules.redis` on its own.

To point the cache at an **external** Redis instead, leave `redis.enabled: false`
and set the connection under `modules.redis` (e.g. `modules.redis.server`).

### Keycloak (OIDC) authentication

FreeRADIUS can authenticate users against a Keycloak realm using the OAuth2
Resource Owner Password Credentials (ROPC) grant. Because ROPC needs the
cleartext password, this only works for password-based flows — **PAP**, or
**EAP-TTLS/PAP** as the inner method. MSCHAPv2/PEAP cannot authenticate against
Keycloak. Enable **Direct Access Grants** on the Keycloak client.

Two backends are available via `keycloak.mode`:

| Mode            | Roles                         | Module              | Image needs                                  |
| --------------- | ----------------------------- | ------------------- | -------------------------------------------- |
| `lua` (default) | Yes — via token introspection | `rlm_lua` script    | `rlm_lua`, `lua-cjson`, `luasec`/`luasocket` |
| `rest`          | No (auth-only)                | `rlm_rest` instance | `rlm_rest` with raw-body (`data`) support    |

#### lua mode (default — full role mapping)

```yaml
keycloak:
  enabled: true
  url: https://auth.example.com
  realm: corp
  clientId: freeradius
  clientSecret: "<confidential-client-secret>"   # omit for a public client
  roleMappings:
    - role: network-admin        # a *client* role on `clientId`
      reply:
        - 'Service-Type := Administrative-User'
        - 'Cisco-AVPair := "shell:priv-lvl=15"'
    - role: wifi-user
      reply:
        - 'Tunnel-Type:0 := VLAN'
        - 'Tunnel-Medium-Type:0 := IEEE-802'
        - 'Tunnel-Private-Group-Id:0 := "10"'
  denyWithoutRole: true          # reject users with no matching role
```

The Lua script validates the password (ROPC), then reads the user's client
roles via RFC 7662 token introspection and exposes them to the
`keycloak_authorize` unlang policy, which maps the first matching role to the
reply attributes above. `roleAttribute` (default `Class`) is the control
attribute the script populates with role names.

#### rest mode (auth-only, no roles)

```yaml
keycloak:
  enabled: true
  mode: rest
  url: https://auth.example.com
  realm: corp
  clientId: freeradius
  clientSecret: "<confidential-client-secret>"
```

A pure `rlm_rest` instance performs the ROPC POST; HTTP 200 accepts, 401
rejects. `roleMappings` is ignored. The image's `rlm_rest` must support a raw
request body (`data`) and the `%{urlquote:...}` xlat. The JSON token response
is not consumed, so `radiusd -X` will print harmless "skipping unknown
attribute" lines for `access_token` etc.

By default (`wireDefaultSite: true`) the `default` virtual server's authorize
section is wired automatically. Set it to `false` to call `keycloak_authorize`
(lua) or `keycloak_rest` (rest) from your own site config.

### Auto-generated credentials

When you don't supply them, the chart auto-generates several credentials into the chart-managed Secret (`<release>-freeradius`):

- `sites-status-secret` — shared secret for the RADIUS `status` virtual server (probes + metrics exporter).
- `sites-tls-privkey-password` — RADSEC private-key passphrase (only when `tls.enabled` AND `sites.tls.privateKeyPassword` is set).
- `mods-eap-tls-privkey-password` — EAP private-key passphrase (only when `modules.eap.enabled` AND `modules.eap.tlsConfig.private_key_password` is set).
- `mods-rest-password`, `database-password` — when the matching feature is enabled.

These use the `lookup`-based "manage" pattern: on a normal `helm install` / `helm upgrade` **against a live cluster**, the existing value is read back and preserved, so it stays stable across releases.

> **⚠️ They are regenerated on every apply in `helm template`-based workflows.** Helm's `lookup` returns nothing when there is no live API connection — i.e. during `helm template`, `helm install --dry-run` (client), `helm diff`, and GitOps tools that render with `helm template` (Argo CD, Flux in template mode). In those workflows a **fresh random value is produced on every render/sync**, which rotates the status secret and the RADSEC key passphrase out from under running pods and can break probes, the metrics exporter, and RADSEC until the pods restart with the new values.

To make these deterministic, pin them explicitly instead of relying on auto-generation:

```yaml
# Option A — set the values directly
sites:
  status:
    secret: "<your-status-secret>"
  tls:
    privateKeyPassword: "<your-radsec-key-password>"

# Option B — bring your own Secret for everything
auth:
  existingSecret: my-freeradius-credentials

# Option C — per-credential Secrets (e.g. managed by an external operator)
auth:
  existingSecretPerPassword:
    keyMapping:
      sitesStatusSecret: status-secret
    sitesStatusSecret:
      name: freeradius-status
```

#### Auto-generated TLS certificates behave the same way

The same limitation applies to the chart's **self-signed TLS material** — the shared internal CA (`<release>-freeradius-tls-ca`) and every leaf it signs (in-pod RADSEC `tls.yaml`, SQL `sql-tls.yaml`, REST `rest-tls.yaml`, gateway `gateway-tls.yaml`). The CA is recovered via `lookup` (`freeradius.tls.ca.init`) and falls back to `genCA` when there is no live cluster, so in `helm template`-based workflows a **fresh CA + fresh leaf certificates are minted on every render/sync**. That rotates the CA out from under anything that already trusts it — RADSEC clients, SQL/REST peers — until they re-fetch.

> **Note:** this churn applies only to the **genCA fallback**. When the cert-manager API is present on the cluster (and `tls.certManager.create`, the default), the RADSEC/gateway certificates are issued through cert-manager — which owns the lifecycle, so there is no per-render churn. The genCA path is used only when cert-manager is absent or `tls.certManager.create: false`.

The deterministic escape hatches mirror the password ones:

```yaml
# Option A — let cert-manager own issuance (recommended; cert-manager,
# not Helm, manages the Certificate, so no churn on re-render). With the
# cert-manager API present this is the default behaviour: certManager.create
# is true, and an empty issuerRef.name makes the chart bootstrap its own CA.
tls:
  enabled: true
  autoGenerated: true
  certManager:
    create: true            # default; set false to force the genCA path
    # issuerRef:            # optional — omit to bootstrap a chart-managed CA
    #   kind: ClusterIssuer
    #   name: my-issuer

# Option B — bring your own certificate Secret (per TLS context)
tls:
  certificatesSecret: my-radsec-tls
modules:
  sql:
    tls:
      certificatesSecret: my-sql-tls
  rest:
    tls:
      certificates_secret: my-rest-tls
```

## Troubleshooting

Find more information about how to deal with common errors related to Startechnica's Helm charts in [this troubleshooting guide](https://startechnica.github.io/doc/troubleshoot-helm-chart-issues).

## Upgrading

### Unreleased

#### cert-manager is auto-detected; `tls.certManager.create` now defaults to `true`

The chart now picks its TLS issuance mechanism automatically. When the
cert-manager API is present on the cluster, RADSEC and gateway certificates are
issued through cert-manager; when it is absent, the chart falls back to its
in-template self-signed genCA path. `tls.certManager.create` (now `true` by
default) acts as an **override** — set it to `false` to force the genCA path
even where cert-manager is installed.

`tls.certManager.issuerRef.name` now defaults to `""`. Empty means the chart
bootstraps its own CA (a self-signed `Issuer` → CA `Certificate` → CA
`Issuer`, in `templates/Issuer.yaml`); set it to reference a pre-existing
Issuer/ClusterIssuer and skip the bootstrap.

```yaml
# Before (1.1.0)
tls:
  certManager:
    create: true                 # required to use cert-manager at all
    issuerRef:
      kind: ClusterIssuer
      name: selfsigned-issuer     # had to pre-exist

# After (Unreleased) — cert-manager used automatically when its API is present
tls:
  enabled: true
  autoGenerated: true
  # certManager.create defaults to true; issuerRef.name defaults to "" → the
  # chart bootstraps its own CA. To use an existing issuer instead:
  # certManager:
  #   issuerRef:
  #     kind: ClusterIssuer
  #     name: my-issuer
```

> **⚠️ Behaviour change.** If you previously left `tls.certManager.create`
> unset (it defaulted to `false`) **and** cert-manager is installed in your
> cluster **and** you use `tls.autoGenerated: true`, you will now get
> cert-manager-issued certificates instead of the chart's self-signed genCA
> material. To keep the old self-signed behaviour, set
> `tls.certManager.create: false` explicitly.

### To 1.1.0 (breaking)

This is a major release. Most users with existing `values.yaml` overrides
will need to migrate the keys below. The full change list is in
[CHANGELOG.md](CHANGELOG.md).

These notes apply to upgrades from **any pre-1.1.0 release**. The most recent
prior release, **1.0.3**, still used the old `modsEnabled` / `sitesEnabled` /
`ingress` / `configuration` / `tls.autoGenerator` keys, so the migrations below
are required coming from 1.0.x just as much as from 0.x. The `# Before` blocks
are labelled `≤ 1.0.3` accordingly.

#### 1. Cert-manager keys consolidated under `tls.certManager.*`

Cert-manager-driven TLS issuance is now configured in one canonical
location and covers both the in-pod RADSEC certificate and the
gateway-namespace certificate.

```yaml
# Before (≤ 1.0.3)
tls:
  autoGenerator:
    certmanager:
      enabled: true
      issuerKind: ClusterIssuer
      issuerName: letsencrypt

# After (1.1.0)
tls:
  certManager:
    create: true
    issuerRef:
      group: cert-manager.io
      kind: ClusterIssuer
      name: letsencrypt
```

#### 2. The `ingress:` block is gone — use `gateway.hostnames`

FreeRADIUS doesn't speak HTTP, so the chart no longer renders an Ingress.
Hostnames previously set under `ingress.hostname` / `ingress.extraHosts`
(which the Certificate, istio Gateway, and VirtualService templates read
from) now live under `gateway.hostnames`.

```yaml
# Before (≤ 1.0.3)
ingress:
  hostname: radius.example.com
  extraHosts:
    - name: radius2.example.com

# After (1.1.0)
gateway:
  enabled: true
  hostnames:
    - radius.example.com
    - radius2.example.com
```

#### 3. Gateway shape: flat → nested

The flat gateway knobs have been replaced with a nested form. The new
`gateway.implementation` flag picks between the two resource sets.

```yaml
# Before (≤ 1.0.3)
gateway:
  enabled: true
  gatewayApi: false        # if true → gateway-api; else → istio
  name: ""
  namespace: ""

# After (1.1.0)
gateway:
  enabled: true
  implementation: gateway-api   # or "istio"
  gateway:
    create: true
    name: ""
    namespace: ""
```

#### 4. Gateway TLS knobs moved to `gateway.tls.*`

The istio Gateway's TLS material is now configured under `gateway.tls`
rather than via `tls.secretName` / `sitesEnabled.tls.enabled`. In 1.1.0 the
`sitesEnabled:` block became `sites:` (see Upgrading #10) and RADSEC
enablement moved from the per-site `enabled` flag to the top-level
`tls.enabled`.

```yaml
# Before (≤ 1.0.3)
sitesEnabled:
  tls:
    enabled: true
tls:
  secretName: my-existing-tls

# After (1.1.0)
tls:
  enabled: true                       # enables RADSEC on the pod
gateway:
  enabled: true
  tls:
    enabled: true                     # renders the Gateway's TLS listener
    existingSecret: my-existing-tls   # BYO Secret (gateway-side)
    selfSigned: false
```

`sites.tls.{cipher,privateKeyPassword}` remain — only the
`enabled` flag moved.

#### 5. SQL TLS / RADSEC TLS Secret keys renamed

The two `existingTlsSecret` / `existingSecretName` keys have been renamed
to `certificatesSecret` for consistency. The old keys still work via a
fallback in the helpers and are slated for removal in the next major bump.

```yaml
# Before (≤ 1.0.3)
tls:
  existingSecretName: my-radsec-tls
modsEnabled:
  sql:
    tls:
      existingTlsSecret: my-sql-tls

# After (1.1.0)
tls:
  certificatesSecret: my-radsec-tls
modules:
  sql:
    tls:
      certificatesSecret: my-sql-tls
```

#### 6. UDPRoute + TLSRoute replace HTTPRoute-style attachment

When using the Gateway API path, the chart now renders dedicated
`UDPRoute` resources for the auth/acct/coa ports and a `TLSRoute` for
RADSEC. UDPRoute support is uneven across GatewayClasses — Cilium and
Envoy Gateway support it, Istio currently does not. On clusters without
UDPRoute, fall back to `gateway.implementation: istio` (which uses
plain UDP listeners) or disable `gateway.udpRoute.enabled`.

#### 7. Removed unused keys

The following were removed without deprecation since they were never
consumed by any template:

- `gateway.dedicated`
- `gateway.extraRoute`
- `tls.secretName`
- `auth.{createClientUser,clientUser,clientUserPassword}`

#### 8. `modsEnabled:` renamed to `modules:`

The top-level Helm key for module enablement was renamed to drop the upstream
FreeRADIUS terminology drift (`mods-enabled` is the daemon's runtime path,
not a useful key name in values). Rename your overrides verbatim — every
sub-key under it (`sql`, `rest`, `json`, `pam`) keeps its shape.

```yaml
# Before (≤ 1.0.3)
modsEnabled:
  sql:
    enabled: true
    dialect: mysql
  rest:
    enabled: true
    connect_uri: https://api.example.com/radius

# After (1.1.0)
modules:
  sql:
    enabled: true
    dialect: mysql
  rest:
    enabled: true
    connect_uri: https://api.example.com/radius
```

Related chart-internal changes (only matter if you override templates):

- Each enabled module renders into its OWN ConfigMap
  (`templates/modules/<name>.yaml`, named `<release>-mods-<name>`) and is
  mounted at `mods-enabled/<name>` via its own pod volume
  `freeradius-mods-<name>`, with a per-module `checksum/configmap-mods-<name>`
  pod annotation. There is no aggregated `<release>-modules` ConfigMap — Helm
  upgrade creates the per-module ConfigMaps and removes any old aggregated one.

The in-container mount path `/etc/freeradius/mods-enabled/<name>` is
**unchanged** — that's the FreeRADIUS daemon's runtime path and isn't ours
to rename. Module config is now rendered directly from `.Values` into each
module ConfigMap (no `FREERADIUS_MODS_*` env-var indirection); only secrets
(DB/REST passwords, the EAP private-key passphrase) are injected as `$ENV{}`
by the Deployment.

#### 9. `sitesEnabled:` renamed to `sites:` (and `files/sites-available/` → `files/sites/`)

Same shape as the `modsEnabled:` → `modules:` rename in #8 — dropping the
upstream daemon-path terminology (`sites-enabled` is the runtime path, not
a useful key name in values). Sub-keys (`coa`, `status`, `tls`) keep their
shape.

```yaml
# Before (≤ 1.0.3)
sitesEnabled:
  coa:
    enabled: true
  status:
    enabled: true
    listen: 0.0.0.0

# After (1.1.0)
sites:
  coa:
    enabled: true
  status:
    enabled: true
    listen: 0.0.0.0
```

Chart-internal renames (only matter if you override templates):

- Source directory `files/sites-available/` → `files/sites/`.
- Template file `templates/configmap/sites-enabled.yaml` → `templates/configmap/sites.yaml`.
- K8s resource names (`<release>-sites` ConfigMap, `freeradius-sites`
  volume, `checksum/configmap-sites` annotation) were already in the short
  form and are unchanged.

The in-container mount path `/etc/freeradius/sites-enabled/<name>` is
**unchanged** — FreeRADIUS daemon convention.

#### 10. Bundled PostgreSQL subchart + dialect-aware backend selection

The chart now ships a `postgresql:` subchart block alongside the existing
`mariadb:` block. Pick exactly one backend; the chart's hard validator
(`freeradius.validate.sql.backend`) rejects two-subchart setups, mismatched
dialect/subchart pairs, `sqlite + subchart`, and "no backend at all".

```yaml
# Before (≤ 1.0.3 — postgresql users were forced to use externalDatabase)
modsEnabled:
  sql:
    dialect: postgresql
mariadb:
  enabled: false
externalDatabase:
  host: my-pg.example.com
  port: 5432
  user: freeradius_user
  database: freeradius_db
  existingSecret: pg-credentials

# After (1.1.0 — bundled PostgreSQL subchart)
modules:
  sql:
    dialect: postgresql
postgresql:
  enabled: true
  auth:
    username: freeradius_user
    database: freeradius_db
    # password auto-generated and stored in the postgresql subchart's Secret
  architecture: standalone
```

`externalDatabase.port` now defaults to `""` (empty); when left empty, the
chart picks `3306` for mysql and `5432` for postgresql automatically. Any
explicit value still wins. The connection helpers were renamed from
`freeradius.mariadb.{host,port,name,user,secretName,secretKey}` to
`freeradius.sql.{...}` — this only affects users who override templates,
not values.

## License

Copyright &copy; 2026 Startechnica

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.