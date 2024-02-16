# Helm Chart for Netbox

NetBox is the leading solution for modeling and documenting modern networks. By combining the traditional disciplines of IP address management
(IPAM) and datacenter infrastructure management (DCIM) with powerful APIs and extensions, NetBox provides the ideal "source of truth" to power
network automation. Read on to discover why thousands of organizations worldwide put NetBox at the heart of their infrastructure.

[Overview of Netbox](https://docs.netbox.dev/en/stable/)

**Note:** This repository was forked from [bootc/netbox-chart](https://github.com/bootc/netbox-chart) at versions
v5.0.0 and up are from this fork will have diverged from any changes in the original fork. A list of changes can be seen in the CHANGELOG.

**This chart is not maintained by the upstream project and any issues with the chart should be raised [here](https://github.com/startechnica/apps/issues/new/choose)**

## TL;DR

```console
helm repo add startechnica https://startechnica.github.io/apps
helm install netbox startechnica/netbox
```
⚠️ **WARNING:** Please see [Production Usage](#production-usage) below before using this chart for production environment.

## Prerequisites

- Kubernetes 1.25.0+ (a [current](https://kubernetes.io/releases/) version)
- Helm 3.10.0+ (a version [compatible](https://helm.sh/docs/topics/version_skew/) with your cluster)
- This chart works with NetBox 3.5.0+ (3.6.4+ recommended)

## Installing the Chart

To install the chart with the release name `netbox` and default configuration:

```console
helm repo add startechnica https://startechnica.github.io/apps
helm install netbox \
    --set postgresql.auth.password=<db-password> \
    --set postgresql.auth.postgresPassword=<posgres-password> \
    --set redis.auth.password=<redis-password> \
    --set superuser.password=<superuser-password> \
    --set superuser.apiToken=<superuser-api-token> \
    --set secretKey=<secret-key> \
    startechnica/netbox
```

The default configuration includes the required PostgreSQL and Redis database
services, but both should be managed externally in production deployments; see below.

### Production Usage

Always [use an existing Secret](#using-an-existing-secret) and supply all
passwords and secret keys yourself to avoid Helm re-generating any of them for
you.

I strongly recommend setting both `postgresql.enabled` and `redis.enabled` to
`false` and using a separate external PostgreSQL and Redis instance. This
de-couples those services from the chart's bundled versions which may have
complex upgrade requirements. I also recommend using a clustered PostgreSQL
server (e.g. using CloudNativePG
[Postgres Operator](https://cloudnative-pg.io/)) and Redis
with Sentinel (e.g. using [Aaron Layfield](https://github.com/DandyDeveloper)'s
[redis-ha chart](https://github.com/DandyDeveloper/charts/tree/master/charts/redis-ha)).

Set `persistence.enabled` to `false` and use the S3 `storageBackend` for object
storage. This works well with Minio or Ceph RGW as well as Amazon S3. See 
[Using extraConfig for S3 storage configuration](#using-extraconfig-for-s3-storage-configuration) and 
[Persistent storage pitfalls](#persistent-storage-pitfalls), below.

Run multiple replicas of the NetBox web front-end to avoid interruptions during
upgrades or at other times when the pods need to be restarted. There's no need
to have multiple workers (`worker.replicaCount`) for better availability. Set
up `affinity.podAntiAffinity` to avoid multiple NetBox pods being colocated on
the same node, for example:

```yaml
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app.kubernetes.io/component: server
            app.kubernetes.io/instance: netbox
            app.kubernetes.io/name: netbox
        topologyKey: kubernetes.io/hostname
```

## Uninstalling the Chart

To uninstall/delete the `netbox` deployment on `netbox` namespace:

```console
helm delete netbox --namespace netbox
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Breaking Changes

### From 5.0.0 to 5.0.5

  * The `extraEnvs` setting has been renamed to `extraEnvVars`.
  * The `extraContainers` setting has been renamed to `sidecars`.
  * The `extraInitContainers` setting has been renamed to `initContainers`.
  * The `housekeeping.securityContext` setting has been renamed to `housekeeping.containerSecurityContext`
  * The `init` setting has been renamed to `initDirs`.
  * The `ingress.className` setting has been renamed to `ingress.ingressClassName`.
  * The `ingress.hosts` setting has been renamed to `ingress.extraHosts`.
  * The `metricsEnabled` setting has been renamed to `metrics.enabled`.
  * The `securityContext` setting has been renamed to `podSecurityContext` and `containerSecurityContext`.
  * The `serviceMonitor` setting has been renamed to `metrics.serviceMonitor`.
  * The `superuser.password: admin` setting has been changed to `superuser.password: ""`.
  * The `superuser.passwordSecretKey` setting has been renamed to `superuser.existingSecretPasswordKey`.
  * The `worker.autoscaling.targetCPUUtilizationPercentage` setting has been renamed to `worker.autoscaling.targetCPU`.
  * The `worker.autoscaling.targetMemoryUtilizationPercentage` setting has been renamed to `worker.autoscaling.targetMemory`.
  * The `worker.extraEnvs` setting has been renamed to `worker.extraEnvVars`.

## Upgrading

### Bundled PostgreSQL

When upgrading or changing settings and using the bundled Bitnami PostgreSQL
sub-chart, you **must** provide the `postgresql.auth.password` at minimum.
Ideally you should also supply the `postgresql.auth.postgresPassword` and,
if using replication, the `postgresql.auth.replicationPassword`. Please see the
[upstream documentation](https://github.com/bitnami/charts/tree/master/bitnami/postgresql#upgrading)
for further information.

### From 4.x to 5.x

* NetBox has been updated to 3.6.4, but older 3.5+ versions should still work (this is not tested or supported, however).
* **Potentially breaking changes:**
  * The `jobResultRetention` setting has been renamed `jobRetention` to match the change in NetBox 3.5.
  * The `remoteAuth.backend` setting has been renamed `remoteAuth.backends` and is now an array.
  * The `remoteAuth.autoCreateUser` setting now defaults to `false`.
  * NAPALM support has been moved into a plugin since NetBox 3.5, so all NAPALM configuration has been **removed from this chart**.
  * Please consult the [NetBox](https://docs.netbox.dev/en/stable/release-notes/) and [netbox-docker](https://github.com/netbox-community/netbox-docker) release notes in case there are any other changes that may affect your configuration.
* The Bitnami [PostgreSQL](https://github.com/bitnami/charts/tree/main/bitnami/postgresql) sub-chart was upgraded from 10.x to 13.x; please read the upstream upgrade notes if you are using the bundled PostgreSQL.
* The Bitnami [Redis](https://github.com/bitnami/charts/tree/main/bitnami/redis) sub-chart was upgraded from 15.x to 18.x; please read the upstream upgrade notes if you are using the bundled Redis.

### From 3.x to 4.x

* NetBox 3.0.0 or above is required
* The Bitnami [Redis](https://github.com/bitnami/charts/tree/master/bitnami/redis) sub-chart was upgraded from 12.x to 15.x; please read the upstream upgrade notes if you are using the bundled Redis
* The `cacheTimeout` and `releaseCheck.timeout` settings were removed

### From 2.x to 3.x

* NetBox 2.10.4 or above is required
* Kubernetes 1.14 or above is required
* Helm v3 or above is now required
* The `netbox` Deployment selectors are changed, so the Deployment **must** be deleted on upgrades
* The Bitnami [PostgreSQL](https://github.com/bitnami/charts/tree/master/bitnami/postgresql) sub-chart was upgraded from 8.x to 10.x; please read the upstream upgrade notes if you are using the bundled PostgreSQL
* The Bitnami [Redis](https://github.com/bitnami/charts/tree/master/bitnami/redis) sub-chart was upgraded from 10.x to 12.x; please read the upstream upgrade notes if you are using the bundled Redis
* The NGINX container is removed, on account of upstream's migration from Gunicorn to NGINX Unit
* The `webhooksRedis` configuration key in `values.yaml` has been renamed to `tasksRedis` to match the upstream name
* The `redis_password` key in the Secret has been renamed to `redis_tasks_password`

### From 1.x to 2.x

If you use an external Redis you will need to update your configuration values
due to the chart reflecting upstream changes in how it uses Redis. There are
now separate Redis configuration blocks for webhooks and for caching, though
they can both point at the same Redis instance as long as the database numbers
are different.

### From 0.x to 1.x

The chart dependencies on PostgreSQL and Redis have been upgraded, so you may
need to take action depending on how you have configured the chart. The
PostgreSQL chart was upgraded from 5.x.x to 7.x.x, and Redis from 8.x.x to
9.x.x.

## Configurations

The following table lists the configurable parameters for this chart and their default values.

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
| `commonLabels`             | Labels to add to all deployed objects                                                                             | `{}`            |
| `commonAnnotations`        | Annotations to add to all deployed objects                                                                        | `{}`            |
| `schedulerName`            | Name of the Kubernetes scheduler (other than default)                                                             | `""`            |
| `enableServiceLinks`       | If set to false, disable Kubernetes service links in the pod spec                                                 | `false`         |
| `dnsPolicy`                | DNS Policy for pod https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/                       | `""`            |
| `dnsConfig`                | DNS Configuration pod  https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/                   | `{}`            |
| `clusterDomain`            | Kubernetes DNS Domain name to use                                                                                 | `cluster.local` |
| `extraDeploy`              | Array of extra objects to deploy with the release (evaluated as a template)                                       | `[]`            |
| `diagnosticMode.enabled`   | Enable diagnostic mode (all probes will be disabled and the command will be overridden)                           | `false`         |
| `diagnosticMode.command`   | Command to override all containers in the deployment                                                              | `[]`            |
| `diagnosticMode.args`      | Args to override all containers in the deployment                                                                 | `[]`            |


### Netbox server parameters

| Parameter                                       | Description                                                              | Default                                      |
| ------------------------------------------------|--------------------------------------------------------------------------|----------------------------------------------|
| `image.registry`                                | NetBox container image registry                                          | `docker.io`                                  |
| `image.repository`                              | NetBox container image repository                                        | `netboxcommunity/netbox`                     |
| `image.tag`                                     | NetBox container image tag                                               | `v3.7.2-2.8.0`                               |
| `image.digest`                                  | NetBox image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag        | `"`                               |
| `image.pullPolicy`                              | NetBox container image pull policy                                       | `IfNotPresent`                               |
| `image.pullSecrets`                             | NetBox container image pull secret                                       | `[]`                                         |
| `image.debug`                                   | Enable image debug mode                                                  | `false`                                      |
| `command`                                       | Override default container command (useful when using custom images)     | `[]`                                         |
| `args`                                          | Override default container args (useful when using custom images)        | `[]`                                         |
| `extraEnvVars`                                  | Array with extra environment variables to add Netbox server pods         | `[]`                                         |
| `extraEnvVarsCM`                                | ConfigMap containing extra environment variables for Netbox server pods  | `""`                                         |
| `extraEnvVarsSecret`                            | Secret containing extra environment variables (in case of sensitive data) for Netbox server pods              | `""`                                      |
| `extraEnvVarsSecrets`                           | List of secrets with extra environment variables for Netbox server pods  | `[]`                                         |
| `replicaCount`                                  | The desired number of NetBox pods                                        | `1`                                          |
| `superuser.name`                                | Initial super-user account to create                                     | `admin`                                      |
| `superuser.email`                               | Email address for the initial super-user account                         | `admin@example.com`                          |
| `superuser.password`                            | Password for the initial super-user account                              | `admin`                                      |
| `superuser.apiToken`                            | API token created for the initial super-user account                     | `""`                                         |
| `skipStartupScripts`                            | Skip [netbox-docker startup scripts]                                     | `true`                                       |
| `allowedHosts`                                  | List of valid FQDNs for this NetBox instance                             | `["*"]`                                      |
| `admins`                                        | List of admins to email about critical errors                            | `[]`                                         |
| `allowTokenRetrieval`                           | Permit the retrieval of API tokens after their creation                  | `false`                                      |
| `authPasswordValidators`                        | Configure validation of local user account passwords                     | `[]`                                         |
| `allowedUrlSchemes`                             | URL schemes that are allowed within links in NetBox                      | *see `values.yaml`*                          |
| `banner.top`                                    | Banner text to display at the top of every page                          | `""`                                         |
| `banner.bottom`                                 | Banner text to display at the bottom of every page                       | `""`                                         |
| `banner.login`                                  | Banner text to display on the login page                                 | `""`                                         |
| `basePath`                                      | Base URL path if accessing NetBox within a directory                     | `""`                                         |
| `changelogRetention`                            | Maximum number of days to retain logged changes (0 = forever)            | `90`                                         |
| `customValidators`                              | Custom validators for NetBox field values                                | `{}`                                         |
| `defaultUserPreferences`                        | Default preferences for newly created user accounts                      | `{}`                                         |
| `cors.originAllowAll`                           | [CORS]: allow all origins                                                | `false`                                      |
| `cors.originWhitelist`                          | [CORS]: list of origins authorised to make cross-site HTTP requests      | `[]`                                         |
| `cors.originRegexWhitelist`                     | [CORS]: list of regex strings matching authorised origins                | `[]`                                         |
| `csrf.cookieName`                               | Name of the CSRF authentication cookie                                   | `csrftoken`                                  |
| `csrf.trustedOrigins`                           | A list of trusted origins for unsafe (e.g. POST) requests                | `[]`                                         |
| `debug`                                         | Enable NetBox debugging (NOT for production use)                         | `false`                                      |
| `defaultLanguage`                               | Set the default preferred language/locale                                | `en-us`                                      |
| `dbWaitDebug`                                   | Show details of errors that occur when applying migrations               | `false`                                      |
| `email.server`                                  | SMTP server to use to send emails                                        | `localhost`                                  |
| `email.port`                                    | TCP port to connect to the SMTP server on                                | `25`                                         |
| `email.username`                                | Optional username for SMTP authentication                                | `""`                                         |
| `email.password`                                | Password for SMTP authentication (see also `existingSecretName`)         | `""`                                         |
| `email.useSSL`                                  | Use SSL when connecting to the server                                    | `false`                                      |
| `email.useTLS`                                  | Use TLS when connecting to the server                                    | `false`                                      |
| `email.sslCertFile`                             | SMTP SSL certificate file path (e.g. in a mounted volume)                | `""`                                         |
| `email.sslKeyFile`                              | SMTP SSL key file path (e.g. in a mounted volume)                        | `""`                                         |
| `email.timeout`                                 | Timeout for SMTP connections, in seconds                                 | `10`                                         |
| `email.from`                                    | Sender address for emails sent by NetBox                                 | `""`                                         |
| `enforceGlobalUnique`                           | Enforce unique IP space in the global table (not in a VRF)               | `false`                                      |
| `exemptViewPermissions`                         | A list of models to exempt from the enforcement of view permissions      | `[]`                                         |
| `fieldChoices`                                  | Configure custom choices for certain built-in fields                     | `{}`                                         |
| `graphQlEnabled`                                | Enable the GraphQL API                                                   | `true`                                       |
| `httpProxies`                                   | HTTP proxies NetBox should use when sending outbound HTTP requests       | `null`                                       |
| `internalIPs`                                   | IP addresses recognized as internal to the system                        | `['127.0.0.1', '::1']`                       |
| `jobRetention`                                  | The number of days to retain job results (scripts and reports)           | `90`                                         |
| `logging`                                       | Custom Django logging configuration                                      | `{}`                                         |
| `loginPersistence`                              | Enables users to remain authenticated to NetBox indefinitely             | `false`                                      |
| `loginRequired`                                 | Permit only logged-in users to access NetBox                             | `false` (unauthenticated read-only access)   |
| `loginTimeout`                                  | How often to re-authenticate users                                       | `1209600` (14 days)                          |
| `logoutRedirectUrl`                             | View name or URL to which users are redirected after logging out         | `home`                                       |
| `maintenanceMode`                               | Display a "maintenance mode" banner on every page                        | `false`                                      |
| `mapsUrl`                                       | The URL to use when mapping physical addresses or GPS coordinates        | `https://maps.google.com/?q=`                |
| `maxPageSize`                                   | Maximum number of objects that can be returned by a single API call      | `1000`                                       |
| `storageBackend`                                | Django-storages backend class name                                       | `null`                                       |
| `storageConfig`                                 | Django-storages backend configuration                                    | `{}`                                         |
| `metricsEnabled`                                | Expose Prometheus metrics at the `/metrics` HTTP endpoint                | `false`                                      |
| `paginateCount`                                 | The default number of objects to display per page in the web UI     | `50`                                         |
| `plugins`                                       | Additional plugins to load into NetBox                              | `[]`                                         |
| `pluginsConfig`                                 | Configuration for the additional plugins                            | `{}`                                         |
| `powerFeedDefaultAmperage`                      | Default amperage value for new power feeds                          | `15`                                         |
| `powerFeedMaxUtilisation`                       | Default maximum utilisation percentage for new power feeds          | `80`                                         |
| `powerFeedDefaultVoltage`                       | Default voltage value for new power feeds                           | `120`                                        |
| `preferIPv4`                                    | Prefer devices' IPv4 address when determining their primary address | `false`                                      |
| `rackElevationDefaultUnitHeight`                | Rack elevation default height in pixels                             | `22`                                         |
| `rackElevationDefaultUnitWidth`                 | Rack elevation default width in pixels                              | `220`                                        |
| `releaseCheck.url`                              | Release check URL (GitHub API URL; see `values.yaml`)               | `null` (disabled by default)                 |
| `rqDefaultTimeout`                              | Maximum execution time for background tasks, in seconds             | `300` (5 minutes)                            |
| `sessionCookieName`                             | The name to use for the session cookie                              | `"sessionid"`                                |
| `enableLocalization`                            | Localization                                                        | `false`                                      |
| `timeZone`                                      | The time zone NetBox will use when dealing with dates and times     | `UTC`                                        |
| `dateFormat`                                    | Django date format for long-form date strings                       | `"N j, Y"`                                   |
| `shortDateFormat`                               | Django date format for short-form date strings                      | `"Y-m-d"`                                    |
| `timeFormat`                                    | Django date format for long-form time strings                       | `"g:i a"`                                    |
| `shortTimeFormat`                               | Django date format for short-form time strings                      | `"H:i:s"`                                    |
| `dateTimeFormat`                                | Django date format for long-form date and time strings              | `"N j, Y g:i a"`                             |
| `shortDateTimeFormat`                           | Django date format for short-form date and time strongs             | `"Y-m-d H:i"`                                |
| `extraConfig`                                   | Additional NetBox configuration (see `values.yaml`)                 | `[]`                                         |
| `secretKey`                                     | Django secret key used for sessions and password reset tokens       | `""` (generated)                             |
| `existingSecretName`                            | Use an existing Kubernetes `Secret` for secret values (see below)   | `""` (use individual chart values)           |
| `overrideUnitConfig`                            | Override the NGINX Unit application server configuration            | `{}` (*see values.yaml*)                     |
| `imagePullSecrets`                              | List of `Secret` names containing private registry credentials      | `[]`                                         |
| `persistence.enabled`                           | Enable storage persistence for uploaded media (images)              | `true`                                       |
| `persistence.existingClaim`                     | Use an existing `PersistentVolumeClaim` instead of creating one     | `""`                                         |
| `persistence.subPath`                           | Mount a sub-path of the volume into the container, not the root     | `""`                                         |
| `persistence.storageClass`                      | Set the storage class of the PVC (use `-` to disable provisioning)  | `""`                                         |
| `persistence.selector`                          | Set the selector for PVs, if desired                                | `{}`                                         |
| `persistence.accessMode`                        | Access mode for the volume                                          | `ReadWriteOnce`                              |
| `persistence.size`                              | Size of persistent volume to request                                | `1Gi`                                        |
| `reportsPersistence.enabled`                    | Enable storage persistence for NetBox reports                       | `false`                                      |
| `reportsPersistence.existingClaim`              | Use an existing `PersistentVolumeClaim` instead of creating one     | `""`                                         |
| `reportsPersistence.subPath`                    | Mount a sub-path of the volume into the container, not the root     | `""`                                         |
| `reportsPersistence.storageClass`               | Set the storage class of the PVC (use `-` to disable provisioning)  | `""`                                         |
| `reportsPersistence.selector`                   | Set the selector for PVs, if desired                                | `{}`                                         |
| `reportsPersistence.accessMode`                 | Access mode for the volume                                          | `ReadWriteOnce`                              |
| `reportsPersistence.size`                       | Size of persistent volume to request                                | `1Gi`                                        |
| `scriptsPersistence.enabled`                    | Enable storage persistence for NetBox scripts                       | `false`                                      |
| `scriptsPersistence.existingClaim`              | Use an existing `PersistentVolumeClaim` instead of creating one     | `""`                                         |
| `scriptsPersistence.subPath`                    | Mount a sub-path of the volume into the container, not the root     | `""`                                         |
| `scriptsPersistence.storageClass`               | Set the storage class of the PVC (use `-` to disable provisioning)  | `""`                                         |
| `scriptsPersistence.selector`                   | Set the selector for PVs, if desired                                | `{}`                                         |
| `scriptsPersistence.accessMode`                 | Access mode for the volume                                          | `ReadWriteOnce`                              |
| `scriptsPersistence.size`                       | Size of persistent volume to request                                | `1Gi`                                        |
| `podAnnotations`                                | Additional annotations for NetBox pods                              | `{}`                                         |
| `podLabels`                                     | Additional labels for NetBox pods                                   | `{}`                                         |
| `podSecurityContext`                            | Security context for NetBox pods                                    | *see `values.yaml`*                          |
| `securityContext`                               | Security context for NetBox containers                              | *see `values.yaml`*                          |
| `resources`                                     | Configure resource requests or limits for NetBox                    | `{}`                                         |
| `automountServiceAccountToken`                  | Whether to automatically mount the serviceAccount token in the main container or not | `false`                     |
| `topologySpreadConstraints`                     | Configure Pod Topology Spread Constraints for NetBox                | `[]`                                         |
| `readinessProbe.enabled`                        | Enable Kubernetes readinessProbe, see [readiness probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-readiness-probes) | *see `values.yaml`* |
| `readinessProbe.initialDelaySeconds`            | Number of seconds                                                   |  *see `values.yaml`*                         |
| `readinessProbe.timeoutSeconds`                 | Number of seconds                                                   |  *see `values.yaml`*                         |
| `readinessProbe.periodSeconds`                  | Number of seconds                                                   |  *see `values.yaml`*                         |
| `readinessProbe.successThreshold`               | Number of seconds                                                   |  *see `values.yaml`*                         |
| `autoscaling.enabled`                           | Whether to enable the HorizontalPodAutoscaler                       | `false`                                      |
| `autoscaling.minReplicas`                       | Minimum number of replicas when autoscaling is enabled              | `1`                                          |
| `autoscaling.maxReplicas`                       | Maximum number of replicas when autoscaling is enabled              | `100`                                        |
| `autoscaling.targetCPUUtilizationPercentage`    | Target CPU utilisation percentage for autoscaling                   | `80`                                         |
| `autoscaling.targetMemoryUtilizationPercentage` | Target memory utilisation percentage for autoscaling                | `null`                                       |
| `nodeSelector`                                  | Node labels for pod assignment                                      | `{}`                                         |
| `tolerations`                                   | Toleration labels for pod assignment                                | `[]`                                         |
| `updateStrategy`                                | Configure deployment update strategy                                | `{}` (defaults to `RollingUpdate`)           |
| `affinity`                                      | Affinity settings for pod assignment                                | `{}`                                         |
| `extraEnvs`                                     | Additional environment variables to set in the NetBox container     | `[]`                                         |
| `extraVolumeMounts`                             | Additional volumes to mount in the NetBox container                 | `[]`                                         |
| `extraVolumes`                                  | Additional volumes to reference in pods                             | `[]`                                         |
| `extraContainers`                               | Additional sidecar containers to be added to pods                   | `[]`                                         |
| `extraInitContainers`                           | Additional init containers to run before starting main containers   | `[]`                                         |

### Netbox worker parameters

| Name                                                       | Description                                                                                                              | Value                            |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | -------------------------------- |
| `worker.image.registry`                                    | Netbox Worker image registry                                                                                             | `docker.io`                      |
| `worker.image.repository`                                  | Netbox Worker image repository                                                                                           | `netboxcommunity/netbox`         |
| `worker.image.tag`                                         | NetBox Worker container image tag                                                                                        | `v3.7.2-2.8.0`                               |
| `worker.image.digest`                                      | Netbox Worker image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag            | `""`                             |
| `worker.image.pullPolicy`                                  | Netbox Worker image pull policy                                                                                          | `IfNotPresent`                   |
| `worker.image.pullSecrets`                                 | Netbox Worker image pull secrets                                                                                         | `[]`                             |
| `worker.image.debug`                                       | Enable image debug mode                                                                                                  | `false`                          |
| `worker.command`                                           | Override default container command (useful when using custom images)                                                     | `[]`                             |
| `worker.args`                                              | Override default container args (useful when using custom images)                                                        | `[]`                             |
| `worker.extraEnvVars`                                      | Array with extra environment variables to add Netbox worker pods                                                         | `[]`                             |
| `worker.extraEnvVarsCM`                                    | ConfigMap containing extra environment variables for Netbox worker pods                                                  | `""`                             |
| `worker.extraEnvVarsSecret`                                | Secret containing extra environment variables (in case of sensitive data) for Netbox worker pods                         | `""`                             |
| `worker.extraEnvVarsSecrets`                               | List of secrets with extra environment variables for Netbox worker pods                                                  | `[]`                             |
| `worker.containerPorts.http`                               | Netbox worker HTTP container port                                                                                        | `""`                             |
| `worker.replicaCount`                                      | Number of Netbox worker replicas                                                                                         | `1`                              |
| `worker.livenessProbe.enabled`                             | Enable livenessProbe on Netbox worker containers                                                                         | `true`                           |
| `worker.livenessProbe.initialDelaySeconds`                 | Initial delay seconds for livenessProbe                                                                                  | `180`                            |
| `worker.livenessProbe.periodSeconds`                       | Period seconds for livenessProbe                                                                                         | `20`                             |
| `worker.livenessProbe.timeoutSeconds`                      | Timeout seconds for livenessProbe                                                                                        | `5`                              |
| `worker.livenessProbe.failureThreshold`                    | Failure threshold for livenessProbe                                                                                      | `6`                              |
| `worker.livenessProbe.successThreshold`                    | Success threshold for livenessProbe                                                                                      | `1`                              |
| `worker.readinessProbe.enabled`                            | Enable readinessProbe on Netbox worker containers                                                                        | `true`                           |
| `worker.readinessProbe.initialDelaySeconds`                | Initial delay seconds for readinessProbe                                                                                 | `30`                             |
| `worker.readinessProbe.periodSeconds`                      | Period seconds for readinessProbe                                                                                        | `10`                             |
| `worker.readinessProbe.timeoutSeconds`                     | Timeout seconds for readinessProbe                                                                                       | `5`                              |
| `worker.readinessProbe.failureThreshold`                   | Failure threshold for readinessProbe                                                                                     | `6`                              |
| `worker.readinessProbe.successThreshold`                   | Success threshold for readinessProbe                                                                                     | `1`                              |
| `worker.startupProbe.enabled`                              | Enable startupProbe on Netbox worker containers                                                                          | `false`                          |
| `worker.startupProbe.initialDelaySeconds`                  | Initial delay seconds for startupProbe                                                                                   | `60`                             |
| `worker.startupProbe.periodSeconds`                        | Period seconds for startupProbe                                                                                          | `10`                             |
| `worker.startupProbe.timeoutSeconds`                       | Timeout seconds for startupProbe                                                                                         | `1`                              |
| `worker.startupProbe.failureThreshold`                     | Failure threshold for startupProbe                                                                                       | `15`                             |
| `worker.startupProbe.successThreshold`                     | Success threshold for startupProbe                                                                                       | `1`                              |
| `worker.customLivenessProbe`                               | Custom livenessProbe that overrides the default one                                                                      | `{}`                             |
| `worker.customReadinessProbe`                              | Custom readinessProbe that overrides the default one                                                                     | `{}`                             |
| `worker.customStartupProbe`                                | Custom startupProbe that overrides the default one                                                                       | `{}`                             |
| `worker.resources.limits`                                  | The resources limits for the Netbox worker containers                                                                    | `{}`                             |
| `worker.resources.requests`                                | The requested resources for the Netbox worker containers                                                                 | `{}`                             |
| `worker.podSecurityContext.enabled`                        | Enabled Netbox worker pods' Security Context                                                                             | `true`                           |
| `worker.podSecurityContext.fsGroupChangePolicy`            | Set filesystem group change policy                                                                                       | `Always`                         |
| `worker.podSecurityContext.sysctls`                        | Set kernel settings using the sysctl interface                                                                           | `[]`                             |
| `worker.podSecurityContext.supplementalGroups`             | Set filesystem extra groups                                                                                              | `[]`                             |
| `worker.podSecurityContext.fsGroup`                        | Set Netbox worker pod's Security Context fsGroup                                                                         | `1000`                           |
| `worker.containerSecurityContext.enabled`                  | Enabled Netbox worker containers' Security Context                                                                       | `true`                           |
| `worker.containerSecurityContext.seLinuxOptions`           | Set SELinux options in container                                                                                         | `nil`                            |
| `worker.containerSecurityContext.runAsUser`                | Set Netbox worker containers' Security Context runAsUser                                                                 | `1000`                           |
| `worker.containerSecurityContext.runAsNonRoot`             | Set Netbox worker containers' Security Context runAsNonRoot                                                              | `true`                           |
| `worker.containerSecurityContext.privileged`               | Set worker container's Security Context privileged                                                                       | `false`                          |
| `worker.containerSecurityContext.allowPrivilegeEscalation` | Set worker container's Security Context allowPrivilegeEscalation                                                         | `false`                          |
| `worker.containerSecurityContext.capabilities.drop`        | List of capabilities to be dropped                                                                                       | `["ALL"]`                        |
| `worker.containerSecurityContext.seccompProfile.type`      | Set container's Security Context seccomp profile                                                                         | `RuntimeDefault`                 |
| `worker.lifecycleHooks`                                    | for the Netbox worker container(s) to automate configuration before or after startup                                     | `{}`                             |
| `worker.automountServiceAccountToken`                      | Mount Service Account token in pod                                                                                       | `false`                          |
| `worker.hostAliases`                                       | Deployment pod host aliases                                                                                              | `[]`                             |
| `worker.podLabels`                                         | Add extra labels to the Netbox worker pods                                                                               | `{}`                             |
| `worker.podAnnotations`                                    | Add extra annotations to the Netbox worker pods                                                                          | `{}`                             |
| `worker.affinity`                                          | Affinity for Netbox worker pods assignment (evaluated as a template)                                                     | `{}`                             |
| `worker.nodeAffinityPreset.key`                            | Node label key to match. Ignored if `worker.affinity` is set.                                                            | `""`                             |
| `worker.nodeAffinityPreset.type`                           | Node affinity preset type. Ignored if `worker.affinity` is set. Allowed values: `soft` or `hard`                         | `""`                             |
| `worker.nodeAffinityPreset.values`                         | Node label values to match. Ignored if `worker.affinity` is set.                                                         | `[]`                             |
| `worker.nodeSelector`                                      | Node labels for Netbox worker pods assignment                                                                            | `{}`                             |
| `worker.podAffinityPreset`                                 | Pod affinity preset. Ignored if `worker.affinity` is set. Allowed values: `soft` or `hard`.                              | `""`                             |
| `worker.podAntiAffinityPreset`                             | Pod anti-affinity preset. Ignored if `worker.affinity` is set. Allowed values: `soft` or `hard`.                         | `soft`                           |
| `worker.tolerations`                                       | Tolerations for Netbox worker pods assignment                                                                            | `[]`                             |
| `worker.topologySpreadConstraints`                         | Topology Spread Constraints for pod assignment spread across your cluster among failure-domains. Evaluated as a template | `[]`                             |
| `worker.priorityClassName`                                 | Priority Class Name                                                                                                      | `""`                             |
| `worker.schedulerName`                                     | Use an alternate scheduler, e.g. "stork".                                                                                | `""`                             |
| `worker.terminationGracePeriodSeconds`                     | Seconds Netbox worker pod needs to terminate gracefully                                                                  | `""`                             |
| `worker.updateStrategy.type`                               | Netbox worker deployment strategy type                                                                                   | `RollingUpdate`                  |
| `worker.updateStrategy.rollingUpdate`                      | Netbox worker deployment rolling update configuration parameters                                                         | `{}`                             |
| `worker.sidecars`                                          | Add additional sidecar containers to the Netbox worker pods                                                              | `[]`                             |
| `worker.initContainers`                                    | Add additional init containers to the Netbox worker pods                                                                 | `[]`                             |
| `worker.extraVolumeMounts`                                 | Optionally specify extra list of additional volumeMounts for the Netbox worker pods                                      | `[]`                             |
| `worker.extraVolumes`                                      | Optionally specify extra list of additional volumes for the Netbox worker pods                                           | `[]`                             |
| `worker.extraVolumeClaimTemplates`                         | Optionally specify extra list of volumesClaimTemplates for the Netbox worker statefulset                                 | `[]`                             |
| `worker.podDisruptionBudget.create`                        | Deploy a podDisruptionBudget object for the Netbox worker pods                                                           | `false`                          |
| `worker.podDisruptionBudget.minAvailable`                  | Maximum number/percentage of unavailable Netbox worker replicas                                                          | `1`                              |
| `worker.podDisruptionBudget.maxUnavailable`                | Maximum number/percentage of unavailable Netbox worker replicas                                                          | `""`                             |
| `worker.autoscaling.enabled`                               | Whether enable horizontal pod autoscaler                                                                                 | `false`                          |
| `worker.autoscaling.minReplicas`                           | Configure a minimum amount of pods                                                                                       | `1`                              |
| `worker.autoscaling.maxReplicas`                           | Configure a maximum amount of pods                                                                                       | `3`                              |
| `worker.autoscaling.targetCPU`                             | Define the CPU target to trigger the scaling actions (utilization percentage)                                            | `80`                             |
| `worker.autoscaling.targetMemory`                          | Define the memory target to trigger the scaling actions (utilization percentage)                                         | `80`                             |
| `worker.networkPolicy.enabled`                             | Specifies whether a NetworkPolicy should be created                                                                      | `true`                           |
| `worker.networkPolicy.allowExternal`                       | Don't require client label for connections                                                                               | `true`                           |
| `worker.networkPolicy.extraIngress`                        | Add extra ingress rules to the NetworkPolice                                                                             | `[]`                             |
| `worker.networkPolicy.extraEgress`                         | Add extra ingress rules to the NetworkPolicy                                                                             | `[]`                             |
| `worker.networkPolicy.ingressNSMatchLabels`                | Labels to match to allow traffic from other namespaces                                                                   | `{}`                             |
| `worker.networkPolicy.ingressNSPodMatchLabels`             | Pod labels to match to allow traffic from other namespaces                                                               | `{}`                             |
| `extraWorkers`                                             | Extra objects to deploy as worker (evaluated as a template)                                                              | `[]`                             |

### Netbox housekeeping parameters

| Parameter                                       | Description                                                         | Default                                      |
| ------------------------------------------------|---------------------------------------------------------------------|----------------------------------------------|
| `housekeeping.enabled`                          | Whether the [Housekeeping][housekeeping] `CronJob` should be active | `true`                                       |
| `housekeeping.concurrencyPolicy`                | ConcurrencyPolicy for the Housekeeping CronJob.                     | `Forbid`                                     |
| `housekeeping.failedJobsHistoryLimit`           | Number of failed jobs to keep in history                            | `5`                                          |
| `housekeeping.restartPolicy`                    | Restart Policy for the Housekeeping CronJob.                        | `OnFailure`                                  |
| `housekeeping.schedule`                         | Schedule for the CronJob in [Cron syntax][cron syntax].             | `0 0 * * *` (Midnight daily)                 |
| `housekeeping.successfulJobsHistoryLimit`       | Number of successful jobs to keep in history                        | `5`                                          |
| `housekeeping.suspend`                          | Whether to suspend the CronJob                                      | `false`                                      |
| `housekeeping.podAnnotations`                   | Additional annotations for housekeeping CronJob pods                | `{}`                                         |
| `housekeeping.podLabels`                        | Additional labels for housekeeping CronJob pods                     | `{}`                                         |
| `housekeeping.podSecurityContext`               | Security context for housekeeping CronJob pods                      | *see `values.yaml`*                          |
| `housekeeping.securityContext`                  | Security context for housekeeping CronJob containers                | *see `values.yaml`*                          |
| `housekeeping.automountServiceAccountToken`     | Whether to automatically mount the serviceAccount token in the housekeeping container or not | `false`             |
| `housekeeping.resources`                        | Configure resource requests or limits for housekeeping CronJob      | `{}`                                         |
| `housekeeping.nodeSelector`                     | Node labels for housekeeping CronJob pod assignment                 | `{}`                                         |
| `housekeeping.tolerations`                      | Toleration labels for housekeeping CronJob pod assignment           | `[]`                                         |
| `housekeeping.affinity`                         | Affinity settings for housekeeping CronJob pod assignment           | `{}`                                         |
| `housekeeping.extraEnvs`                        | Additional environment variables to set in housekeeping CronJob     | `[]`                                         |
| `housekeeping.extraVolumeMounts`                | Additional volumes to mount in the housekeeping CronJob             | `[]`                                         |
| `housekeeping.extraVolumes`                     | Additional volumes to reference in housekeeping CronJob pods        | `[]`                                         |
| `housekeeping.extraContainers`                  | Additional sidecar containers to be added to housekeeping CronJob   | `[]`                                         |
| `housekeeping.extraInitContainers`              | Additional init containers for housekeeping CronJob pods            | `[]`                                         |

### Traffic Exposure Parameters

| Name                               | Description                                                                                                                      | Value                    |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `service.type`                     | Netbox service type                                                                                                              | `ClusterIP`              |
| `service.ports.http`               | Netbox service HTTP port                                                                                                         | `80`                     |
| `service.nodePorts.http`           | Node port for HTTP                                                                                                               | `""`                     |
| `service.sessionAffinity`          | Control where client requests go, to the same pod or round-robin                                                                 | `None`                   |
| `service.sessionAffinityConfig`    | Additional settings for the sessionAffinity                                                                                      | `{}`                     |
| `service.clusterIP`                | Netbox service Cluster IP                                                                                                        | `""`                     |
| `service.loadBalancerIP`           | Netbox service Load Balancer IP                                                                                                  | `""`                     |
| `service.loadBalancerSourceRanges` | Netbox service Load Balancer sources                                                                                             | `[]`                     |
| `service.externalTrafficPolicy`    | Netbox service external traffic policy                                                                                           | `Cluster`                |
| `service.annotations`              | Additional custom annotations for Netbox service                                                                                 | `{}`                     |
| `service.extraPorts`               | Extra port to expose on Netbox service                                                                                           | `[]`                     |
| `ingress.enabled`                  | Enable ingress record generation for Netbox                                                                                      | `false`                  |
| `ingress.ingressClassName`         | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)                                                    | `""`                     |
| `ingress.pathType`                 | Ingress path type                                                                                                                | `ImplementationSpecific` |
| `ingress.apiVersion`               | Force Ingress API version (automatically detected if not set)                                                                    | `""`                     |
| `ingress.hostname`                 | Default host for the ingress record                                                                                              | `netbox.local`           |
| `ingress.path`                     | Default path for the ingress record                                                                                              | `/`                      |
| `ingress.annotations`              | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. | `{}`                     |
| `ingress.tls`                      | Enable TLS configuration for the host defined at `ingress.hostname` parameter                                                    | `false`                  |
| `ingress.selfSigned`               | Create a TLS secret for this ingress record using self-signed certificates generated by Helm                                     | `false`                  |
| `ingress.extraHosts`               | An array with additional hostname(s) to be covered with the ingress record                                                       | `[]`                     |
| `ingress.extraPaths`               | An array with additional arbitrary paths that may need to be added to the ingress under the main host                            | `[]`                     |
| `ingress.extraTls`                 | TLS configuration for additional hostname(s) to be covered with this ingress record                                              | `[]`                     |
| `ingress.secrets`                  | Custom TLS certificates as secrets                                                                                               | `[]`                     |
| `ingress.extraRules`               | Additional rules to be covered with this ingress record                                                                          | `[]`                     |
| `gateway.enabled`                  |                                                                           | `false`                     |
| `gateway.dedicated`                |                                                                           | `false`                     |
| `gateway.gatewayApi.create`        |                                                                           | `false`                     |
| `gateway.name`                     |                                                                           | `""`                        |
| `gateway.namespace`                |                                                                           | `""`                        |
| `gateway.gatewayClassName`         |                                                                           | `istio`                     |
| `gateway.listeners`                |                                                                           | `[]`                        |
| `gateway.existingGateway`          |                                                                           | `""`                        |
| `gateway.existingServiceEntry`     |                                                                           | `""`                        |
| `gateway.existingVirtualService`   |                                                                           | `""`                        |
| `gateway.extraRoute`               |                                                                           | `[]`                        |

### RBAC parameters

| Name                                          | Description                                                            | Value   |
| --------------------------------------------- | ---------------------------------------------------------------------- | ------- |
| `serviceAccount.create`                       | Enable creation of ServiceAccount for Netbox pods                      | `true`  |
| `serviceAccount.name`                         | The name of the ServiceAccount to use.                                 | `""`    |
| `serviceAccount.automountServiceAccountToken` | Allows auto mount of ServiceAccountToken on the serviceAccount created | `false` |
| `serviceAccount.imagePullSecrets`             | Add an imagePullSecrets attribute to the serviceAccount                | `""`    |
| `serviceAccount.annotations`                  | Additional custom annotations for the ServiceAccount                   | `{}`    |
| `rbac.create`                                 | Create Role and RoleBinding                                            | `false` |
| `rbac.rules`                                  | Custom RBAC rules to set                                               | `[]`    |

### Netbox metrics parameters

| Name                                                        | Description                                                                                           | Value            |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------| -----------------|
| `metrics.enabled`                                           | Whether or enable Django exporter to expose Netbox metrics                                            | `false`          |
| `metrics.service.ports.http`                                | Netbox exporter metrics service port                                                                  | `9112`           |
| `metrics.service.clusterIP`                                 | Static clusterIP or None for headless services                                                        | `""`             |
| `metrics.service.sessionAffinity`                           | Control where client requests go, to the same pod or round-robin                                      | `None`           |
| `metrics.service.annotations`                               | Annotations for the Netbox exporter service                                                           | `{}`             |
| `metrics.serviceMonitor.enabled`                            | if `true`, creates a Prometheus Operator ServiceMonitor (requires `metrics.enabled` to be `true`)     | `false`          |
| `metrics.serviceMonitor.namespace`                          | Namespace in which Prometheus is running                                                              | `""`             |
| `metrics.serviceMonitor.interval`                           | Interval at which metrics should be scraped                                                           | `""`             |
| `metrics.serviceMonitor.scrapeTimeout`                      | Timeout after which the scrape is ended                                                               | `""`             |
| `metrics.serviceMonitor.labels`                             | Additional labels that can be used so ServiceMonitor will be discovered by Prometheus                 | `{}`             |
| `metrics.serviceMonitor.selector`                           | Prometheus instance selector labels                                                                   | `{}`             |
| `metrics.serviceMonitor.relabelings`                        | RelabelConfigs to apply to samples before scraping                                                    | `[]`             |
| `metrics.serviceMonitor.metricRelabelings`                  | MetricRelabelConfigs to apply to samples before ingestion                                             | `[]`             |
| `metrics.serviceMonitor.honorLabels`                        | Specify honorLabels parameter to add the scrape endpoint                                              | `false`          |
| `metrics.serviceMonitor.jobLabel`                           | The name of the label on the target service to use as the job name in prometheus.                     | `""`             |
| `metrics.networkPolicy.enabled`                             | Specifies whether a NetworkPolicy should be created                                                   | `true`           |
| `metrics.networkPolicy.allowExternal`                       | Don't require client label for connections                                                            | `true`           |
| `metrics.networkPolicy.extraIngress`                        | Add extra ingress rules to the NetworkPolicy                                                          | `[]`             |
| `metrics.networkPolicy.extraEgress`                         | Add extra ingress rules to the NetworkPolicy                                                          | `[]`             |
| `metrics.networkPolicy.ingressNSMatchLabels`                | Labels to match to allow traffic from other namespaces                                                | `{}`             |
| `metrics.networkPolicy.ingressNSPodMatchLabels`             | Pod labels to match to allow traffic from other namespaces                                            | `{}`             |
| `worker.metrics.enabled`                                    | Whether or enable Django exporter to expose Netbox worker metrics                                     | `false`          |

### Remote Authentication parameters

| Name                                            | Description                                                                         | Value                                        |
| ----------------------------------------------- | ----------------------------------------------------------------------------------- | -------------------------------------------- |
| `remoteAuth.enabled`                            | Enable remote authentication support                                                | `false`                                      |
| `remoteAuth.backends`                           | Remote authentication backend classes                                               | `[netbox.authentication.RemoteUserBackend]`  |
| `remoteAuth.header`                             | The name of the HTTP header which conveys the username                              | `HTTP_REMOTE_USER`                           |
| `remoteAuth.userFirstName`                      | HTTP header which contains the user's first name                                    | `HTTP_REMOTE_USER_FIRST_NAME`                |
| `remoteAuth.userLastName`                       | HTTP header which contains the user's last name                                     | `HTTP_REMOTE_USER_LAST_NAME`                 |
| `remoteAuth.userEmail`                          | HTTP header which contains the user's email address                                 | `HTTP_REMOTE_USER_EMAIL`                     |
| `remoteAuth.autoCreateUser`                     | Enables the automatic creation of new users                                         | `false`                                      |
| `remoteAuth.autoCreateGroups`                   | Enables the automatic creation of new groups                                        | `false`                                      |
| `remoteAuth.defaultGroups`                      | A list of groups to assign to newly created users                                   | `[]`                                         |
| `remoteAuth.defaultPermissions`                 | A list of permissions to assign newly created users                                 | `{}`                                         |
| `remoteAuth.groupSyncEnabled`                   | Sync remote user groups from an HTTP header set by a reverse proxy                  | `false`                                      |
| `remoteAuth.groupHeader`                        | The name of the HTTP header which conveys the groups to which the user belongs      | `HTTP_REMOTE_USER_GROUP`                     |
| `remoteAuth.superuserGroups`                    | The list of groups that promote an remote User to Superuser on login                | `[]`                                         |
| `remoteAuth.superusers`                         | The list of users that get promoted to Superuser on login                           | `[]`                                         |
| `remoteAuth.staffGroups`                        | The list of groups that promote an remote User to Staff on login                    | `[]`                                         |
| `remoteAuth.staffUsers`                         | The list of users that get promoted to Staff on login                               | `[]`                                         |
| `remoteAuth.groupSeparator`                     | The Seperator upon which `remoteAuth.groupHeader` gets split into individual groups | `\|`                        |
| `remoteAuth.ldap.enabled`                       | Enable LDAP remote auth backend support and configurations                          | `""`                                         |
| `remoteAuth.ldap.serverUri`                     | see [django-auth-ldap](https://django-auth-ldap.readthedocs.io)                     | `""`                                         |
| `remoteAuth.ldap.startTls`                      | if StarTLS should be used                                                           | *see values.yaml*                            |
| `remoteAuth.ldap.ignoreCertErrors`              | if Certificate errors should be ignored                                             | *see values.yaml*                            |
| `remoteAuth.ldap.bindDn`                        | Distinguished Name to bind with                                                     | `""`                                         |
| `remoteAuth.ldap.bindPassword`                  | Password for bind DN                                                                | `""`                                         |
| `remoteAuth.ldap.userDnTemplate`                | see [AUTH_LDAP_USER_DN_TEMPLATE](https://django-auth-ldap.readthedocs.io/en/latest/reference.html#auth-ldap-user-dn-template) | *see values.yaml* |
| `remoteAuth.ldap.userSearchBaseDn`              | see base_dn of [django_auth_ldap.config.LDAPSearch](https://django-auth-ldap.readthedocs.io/en/latest/reference.html#django_auth_ldap.config.LDAPSearch) | *see values.yaml* |
| `remoteAuth.ldap.userSearchAttr`                | User attribute name for user search                                                 | `sAMAccountName`                             |
| `remoteAuth.ldap.groupSearchBaseDn`             | base DN for group search                                                            | *see values.yaml*                            |
| `remoteAuth.ldap.groupSearchClass`              | [django-auth-ldap](https://django-auth-ldap.readthedocs.io) for group search        | `group`                             |
| `remoteAuth.ldap.groupType`                     | see [AUTH_LDAP_GROUP_TYPE](https://django-auth-ldap.readthedocs.io/en/latest/reference.html#auth-ldap-group-type) | `GroupOfNamesType` |
| `remoteAuth.ldap.requireGroupDn`                | DN of a group that is required for login                                            | `null`                                       |
| `remoteAuth.ldap.findGroupPerms`                | see [AUTH_LDAP_FIND_GROUP_PERMS](https://django-auth-ldap.readthedocs.io/en/latest/reference.html#auth-ldap-find-group-perms) | true |
| `remoteAuth.ldap.mirrorGroups`                  | see [AUTH_LDAP_MIRROR_GROUPS](https://django-auth-ldap.readthedocs.io/en/latest/reference.html#auth-ldap-mirror-groups) | `null` |
| `remoteAuth.ldap.cacheTimeout`                  | see [AUTH_LDAP_MIRROR_GROUPS_EXCEPT](https://django-auth-ldap.readthedocs.io/en/latest/reference.html#auth-ldap-mirror-groups-except) | `null` |
| `remoteAuth.ldap.isAdminDn`                     | required DN to be able to login in Admin-Backend, "is_staff"-Attribute of [AUTH_LDAP_USER_FLAGS_BY_GROUP](https://django-auth-ldap.readthedocs.io/en/latest/reference.html#auth-ldap-user-flags-by-group) | *see values.yaml* |
| `remoteAuth.ldap.isSuperUserDn`                 | required DN to receive SuperUser privileges, "is_superuser"-Attribute of [AUTH_LDAP_USER_FLAGS_BY_GROUP](https://django-auth-ldap.readthedocs.io/en/latest/reference.html#auth-ldap-user-flags-by-group) | *see values.yaml* |
| `remoteAuth.ldap.attrFirstName`                 | first name attribute of users, "first_name"-Attribute of [AUTH_LDAP_USER_ATTR_MAP](https://django-auth-ldap.readthedocs.io/en/latest/reference.html#auth-ldap-user-attr-map) | `givenName` |
| `remoteAuth.ldap.attrLastName`                  | last name attribute of users, "last_name"-Attribute of [AUTH_LDAP_USER_ATTR_MAP](https://django-auth-ldap.readthedocs.io/en/latest/reference.html#auth-ldap-user-attr-map) | `sn` |
| `remoteAuth.ldap.attrMail`                      | mail attribute of users, "email_name"-Attribute of [AUTH_LDAP_USER_ATTR_MAP](https://django-auth-ldap.readthedocs.io/en/latest/reference.html#auth-ldap-user-attr-map) | `mail` |


### Database parameters

| Name                                         | Description                                                                                            | Value             |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------ | ----------------- |
| `postgresql.enabled`                         | Switch to enable or disable the PostgreSQL helm chart                                                  | `true`            |
| `postgresql.auth.enablePostgresUser`         | Assign a password to the "postgres" admin user. Otherwise, remote access will be blocked for this user | `true`            |
| `postgresql.auth.username`                   | Name for a custom user to create                                                                       | `netbox`          |
| `postgresql.auth.password`                   | Password for the custom user to create                                                                 | `""`              |
| `postgresql.auth.database`                   | Name for a custom database to create                                                                   | `netbox`          |
| `postgresql.auth.existingSecret`             | Name of existing secret to use for PostgreSQL credentials                                              | `""`              |
| `postgresql.architecture`                    | PostgreSQL architecture (`standalone` or `replication`)                                                | `standalone`      |
| `externalDatabase.host`                      | Database host                                                                                          | `localhost`       |
| `externalDatabase.port`                      | Database port number                                                                                   | `5432`            |
| `externalDatabase.user`                      | Non-root username for Netbox                                                                           | `""`              |
| `externalDatabase.password`                  | Password for the non-root username for Netbox                                                          | `""`              |
| `externalDatabase.database`                  | Netbox database name                                                                                   | `""`              |
| `externalDatabase.existingSecretName`        | Name of an existing secret resource containing the database credentials                                | `""`              |
| `externalDatabase.existingSecretPasswordKey` | Name of an existing secret key containing the database credentials                                     | `db-password`     |
| `externalDatabase.sslMode`                   | PostgreSQL client SSL Mode setting                                                                     | `prefer`          |
| `externalDatabase.connMaxAge`                | The lifetime of a database connection, as an integer of seconds                                        | `300`             |
| `externalDatabase.disableServerSideCursors`  | Disable the use of server-side cursors transaction pooling                                             | `false`           |
| `externalDatabase.targetSessionAttrs`        | Determines whether the session must have certain properties                                            | `read-write`      |
| `redis.enabled`                              | Switch to enable or disable the Redis&reg; helm                                                        | `true`            |
| `redis.auth.enabled`                         | Enable password authentication                                                                         | `true`            |
| `redis.auth.password`                        | Redis&reg; password                                                                                    | `""`              |
| `redis.auth.existingSecret`                  | The name of an existing secret with Redis&reg; credentials                                             | `""`              |
| `redis.architecture`                         | Redis&reg; architecture. Allowed values: `standalone` or `replication`                                 | `standalone`      |
| `externalRedis.host`                         | Redis&reg; host                                                                                        | `localhost`       |
| `externalRedis.port`                         | Redis&reg; port number                                                                                 | `6379`            |
| `externalRedis.username`                     | Redis&reg; username                                                                                    | `""`              |
| `externalRedis.password`                     | Redis&reg; password                                                                                    | `""`              |
| `externalRedis.existingSecretName`           | Name of an existing secret resource containing the Redis&trade credentials                             | `""`              |
| `externalRedis.existingSecretPasswordKey`    | Name of an existing secret key containing the Redis&trade credentials                                  | `""`              |
| `tasksRedis.database`                        | Redis database number used for NetBox task queue                                                       | `0`                      |
| `tasksRedis.ssl`                             | Enable SSL when connecting to Redis                                                                    | `false`                  |
| `tasksRedis.insecureSkipTlsVerify`           | Skip TLS certificate verification when connecting to Redis                                             | `false`                  |
| `tasksRedis.caCertPath`                      | Path to CA certificates bundle for Redis (needs mounting manually)                                     | `""`                     |
| `tasksRedis.host`                            | Redis host to use when `redis.enabled` is `false`                                                      | `"netbox-redis-master"`  |
| `tasksRedis.port`                            | Port number for external Redis                                                                         | `6379`                   |
| `tasksRedis.sentinels`                       | List of sentinels in `host:port` form (`host` and `port` not used)                                     | `[]`                     |
| `tasksRedis.sentinelService`                 | Sentinel master service name                                                                           | `"netbox-redis"`         |
| `tasksRedis.sentinelTimeout`                 | Sentinel connection timeout, in seconds                                                                | `300` (5 minutes)        |
| `tasksRedis.username`                        | Username for external Redis                                                                            | `""`                     |
| `tasksRedis.password`                        | Password for external Redis (see also `existingSecretName`)                                            | `""`                     |
| `tasksRedis.existingSecretName`              | Fetch password for external Redis from a different `Secret`                                            | `""`                     |
| `tasksRedis.existingSecretPasswordKey`       | Key to fetch the password in the above `Secret`                                                        | `redis-task-password`    |
| `cachingRedis.database`                      | Redis database number used for caching views                                                           | `1`                      |
| `cachingRedis.ssl`                           | Enable SSL when connecting to Redis                                                                    | `false`                  |
| `cachingRedis.insecureSkipTlsVerify`         | Skip TLS certificate verification when connecting to Redis                                             | `false`                  |
| `cachingRedis.caCertPath`                    | Path to CA certificates bundle for Redis (needs mounting manually)                                     | `""`                     |
| `cachingRedis.host`                          | Redis host to use when `redis.enabled` is `false`                                                      | `"netbox-redis"`         |
| `cachingRedis.port`                          | Port number for external Redis                                                                         | `6379`                   |
| `cachingRedis.sentinels`                     | List of sentinels in `host:port` form (`host` and `port` not used)                                     | `[]`                     |
| `cachingRedis.sentinelService`               | Sentinel master service name                                                                           | `"netbox-redis"`         |
| `cachingRedis.sentinelTimeout`               | Sentinel connection timeout, in seconds                                                                | `300` (5 minutes)        |
| `cachingRedis.username`                      | Username for external Redis                                                                            | `""`                     |
| `cachingRedis.password`                      | Password for external Redis (see also `existingSecretName`)                                            | `""`                     |
| `cachingRedis.existingSecretName`            | Fetch password for external Redis from a different `Secret`                                            | `""`                     |
| `cachingRedis.existingSecretPasswordKey`     | Key to fetch the password in the above `Secret`                                                        | `redis-caching-password` |


### Init container 

| Name                                         | Description                                                                                            | Value             |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------ | ----------------- |
| `initDirs.image.repository`                     | Init container image repository                                     | `busybox`                                    |
| `initDirs.image.tag`                            | Init container image tag                                            | `1.32.1`                                     |
| `initDirs.image.pullPolicy`                     | Init container image pull policy                                    | `IfNotPresent`                               |
| `initDirs.resources`                            | Configure resource requests or limits for init container            | `{}`                                         |
| `initDirs.securityContext`                      | Security context for init container                                 | *see `values.yaml`*                          |

[netbox-docker startup scripts]: https://github.com/netbox-community/netbox-docker/tree/master/startup_scripts
[CORS]: https://github.com/ottoyiu/django-cors-headers
[housekeeping]: https://demo.netbox.dev/static/docs/administration/housekeeping/
[cron syntax]: https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#cron-schedule-syntax

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install` or provide a YAML file containing the values for the above parameters:

```console
helm install --name my-release startechnica/netbox --values values.yaml
```

## Persistent storage pitfalls

Persistent storage for media is enabled by default, but unless you take special
care you will run into issues. The most common issue is that one of the NetBox
pods gets stuck in the `ContainerCreating` state. There are several ways around
this problem:

1. For production usage it is recommended to **disable** persistent storage by setting
   `persistence.enabled` to `false` and using the S3 `storageBackend` instead. This can
   be used with any S3-compatible storage provider including Amazon S3, MinIo,
   Ceph RGW, and many others. See further down for an example of this.
2. Use a `ReadWriteMany` volume that can be mounted by several pods across
   nodes simultaneously.
3. Configure pod affinity settings to keep all the pods on the same node. This
   allows a `ReadWriteOnce` volume to be mounted in several pods at the same time.
4. Disable persistent storage of `media` altogether and just manage without. The
   storage functionality is only needed to store uploaded image attachments.

To configure the pod affinity to allow using a `ReadWriteOnce` volume you can
use the following example configuration:

```yaml
affinity:
  podAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels:
          app.kubernetes.io/name: netbox
      topologyKey: kubernetes.io/hostname


housekeeping:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app.kubernetes.io/name: netbox
        topologyKey: kubernetes.io/hostname

worker:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app.kubernetes.io/name: netbox
        topologyKey: kubernetes.io/hostname
```

## Using an Existing Secret

Rather than specifying passwords and secrets as part of the Helm release values,
you may pass these to NetBox using a pre-existing `Secret` resource. When using
this, the `Secret` must contain the following keys:

| Key                    | Description                                                   | Remarks                                                                                           |
| -----------------------|---------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| `db-password`          | The password for the external PostgreSQL database             | If `postgresql.enabled` is `false` and `externalDatabase.existingSecretName` is unset             |
| `email-password`       | SMTP user password                                            | Yes, but the value may be left blank if not required                                              |
| `ldap-bind-password`   | Password for LDAP bind DN                                     | If `remoteAuth.enabled` is `true` and `remoteAuth.backend` is `netbox.authentication.LDAPBackend` |
| `redis-tasks-password` | Password for the external Redis tasks database                | If `redis.enabled` is `false` and `tasksRedis.existingSecretName` is unset                        |
| `redis-cache-password` | Password for the external Redis cache database                | If `redis.enabled` is `false` and `cachingRedis.existingSecretName` is unset                      |
| `secret-key`           | Django secret key used for sessions and password reset tokens | Required! Auto generated if left blank                                                            |
| `superuser-password`   | Password for the initial super-user account                   | Required! Auto generated if left blank                                                            |
| `superuser-api-token`  | API token created for the initial super-user account          | Required! Auto generated if left blank                                                            |

## Using extraConfig for S3 storage configuration

If you want to use S3 as your storage backend and not have the config in the `values.yaml` (credentials!)
you can use an existing secret that is then referenced under the `extraConfig` key.

The secret would look like this:

```yaml
apiVersion: v1
kind: Secret
metadata:
  labels:
    app.kubernetes.io/instance: netbox
  name: netbox-extra
stringData:
  s3-config.yaml: |
    STORAGE_CONFIG:
      AWS_S3_ENDPOINT_URL: <endpoint-URL>
      AWS_S3_REGION_NAME: <region>
      AWS_STORAGE_BUCKET_NAME: <bucket-name>
      AWS_ACCESS_KEY_ID: <access-key>
      AWS_SECRET_ACCESS_KEY: <secret-key>
```

And the secret then has to be referenced like this:

```yaml
extraConfig:
  - secret: # same as pod.spec.volumes.secret
      secretName: netbox-extra
```

## Authentication
* [Single Sign On](docs/auth.md#configuring-sso)
* [LDAP Authentication](docs/auth.md#using-ldap-authentication)

## License

> The following notice applies to all files contained within this Helm Chart and
> the Git repository which contains it:
>
> Copyright 2019-2020 Chris Boot
>
> Licensed under the Apache License, Version 2.0 (the "License");
> you may not use this file except in compliance with the License.
> You may obtain a copy of the License at
>
>     http://www.apache.org/licenses/LICENSE-2.0
>
> Unless required by applicable law or agreed to in writing, software
> distributed under the License is distributed on an "AS IS" BASIS,
> WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
> See the License for the specific language governing permissions and
> limitations under the License.
