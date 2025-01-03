# smartface

![Version: 0.8.10](https://img.shields.io/badge/Version-0.8.10-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v5_4.29.0](https://img.shields.io/badge/AppVersion-v5_4.29.0-informational?style=flat-square)

SmartFace is a Scalable Facial Recognition Server Platform Able to Process Multiple Real-Time Video Streams. Currently the helm chart supports edge stream and Lightweight Face Identification System (LFIS) deployments

**Homepage:** <https://www.innovatrics.com/face-recognition-solutions/>

## TL;DR

```
helm install smartface oci://ghcr.io/innovatrics/sf-helm/smartface
```

## Prerequisites

The helm chart needs certain objects to be present in the cluster before it can be installed. Refer to `external-config.yaml` for examples for the required objects:

1. [Registry credentials secret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line)
    - Get the credentials from [Customer portal](https://customerportal.innovatrics.com)
    - The secret name must match `imagePullSecrets` value
    - see comments in `external-config.yaml` for commands to create kubernetes manifest with credentials

1. License file secret
    - Get the license file from [Customer portal](https://customerportal.innovatrics.com)
    - The secret name must match `license.secretName` value
    - see comments in `external-config.yaml` for commands to create kubernetes manifest with license file

1. Optionally [KEDA](https://keda.sh/) for autoscaling
    - see `autoscaling.*` values for more info

## Ingress

By default an ingress object is created with the helm chart. To configure the ingress please see the `ingress.*` values

## Tests

[Helm chart tests](https://helm.sh/docs/topics/chart_tests/) are included and can be run using `helm test` command. The aim of these tests is to touch most of the deployments to check wether SmartFace components deployed successfully and are working. Their successful completion is not a guarantee that the application is fully functional.

Based on the configured functionality of the helm chart (values) some tests might not be run as they might require functionality which is not deployed. Please see the test pod templates to see the impact of configured values to test pods which are run in the helm chart tests.

In case the tests fail please refer to the output of the test pod to identify the issue.

### Test data

During the tests some data (Watchlists / EdgeStreams) will be created in the deployed smartface. The tests will try to cleanup all data they created without touching any other data present in the system, but the note that the cleanup might fail for various reasons, resulting in test data being left behind in the system.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://ghcr.io/innovatrics/sf-helm | sf-tenant-management | 0.4.4 |
| oci://registry-1.docker.io/bitnamicharts | minio | 12.8.15 |
| oci://registry-1.docker.io/bitnamicharts | postgresql | 13.2.1 |
| oci://registry-1.docker.io/bitnamicharts | rabbitmq | 12.0.4 |

All chart dependencies are optional and can be disabled and supplemented with other (for example cloud-based) alternatives

### RabbitMQ
To use non-chart managed rabbitmq:
- set `rabbitmq.enabled=false`
- provide rabbitmq configuration via:
  - supplying values to `rabbitmq.rmqConfiguration` object
  - or creating ConfigMap and setting `rabbitmq.rmqConfiguration.existingConfigMapName`
  - see Sample objects for example
- create Secret with rabbitmq password
  - supply `rabbitmq.existingSecretName` value with name of existing secret
  - see Sample objects for example

#### Sample objects
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: "sf-rmq-connection"
data:
  hostname: "<hostname>"
  username: "<username>"
  port: "5671"
  useSsl: "true"
  streamsPort: "5552"
```

```
apiVersion: v1
kind: Secret
metadata:
  name: "rmq-pass"
stringData:
  rabbitmq-password: "<password>"
```

### S3
To use S3 bucket managed by AWS:
- set `minio.enabled=false`
- provide s3 configuration via:
  - supplying values to `configurations.s3` object
  - or creating ConfigMap and setting `configurations.s3.existingConfigMapName`
  - see Sample objects for example
- When using S3 bucket and running in AWS the authentication can be performed using could-native mechanisms:
  - to authenticate using EC2 instance profile set `configurations.s3.authType` to `InstanceProfile`
  - to authenticate using AssumedRole set `configurations.s3.authType` to `AssumedRole` (useful for example when using [EKS IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html))

#### Sample objects
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: "sf-s3-connection"
data:
  name: "smartface"
  region: "eu-central-1"
  folder: "sface"
  authType: "AssumedRole"
  useBucketRegion: "true"
```

### Postgresql
To use externally managed PgSQL instance:
- set `postgresql.enabled=false`
- provide databse configuration:
  - create a Secret - see `external-config.yaml` for example
  - secret name must match `configurations.database.secretName` value
  - key in the Secret must match `configurations.database.connectionStringKey` value
  - see Sample objects for example

#### Sample objects
```
apiVersion: v1
stringData:
  # supply pgsql server connection string - https://learn.microsoft.com/en-us/dotnet/framework/data/adonet/connection-strings
  cs: "Server=<hostname>;Database=<db-name>;Username=<username>;Password=<password>;"
kind: Secret
metadata:
  name: db-cs
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| VideoAggregator.annotations | object | `{}` | Annotations for VideoAggregator deployment |
| VideoAggregator.image.digest | string | `nil` | Overrides the image tag with an image digest |
| VideoAggregator.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| VideoAggregator.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| VideoAggregator.image.repository | string | `"innovatrics/smartface/sf-video-aggregator"` | Docker image repository |
| VideoAggregator.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| VideoAggregator.name | string | `"video-aggregator"` |  |
| VideoAggregator.nodeSelector | object | `{}` |  |
| VideoAggregator.pdb.create | bool | `false` | create PodDisruptionBudget for VideoAggregator component |
| VideoAggregator.pdb.maxUnavailable | string | `""` |  |
| VideoAggregator.pdb.minAvailable | int | `1` |  |
| VideoAggregator.podAnnotations | object | `{}` | Annotations for VideoAggregator pods |
| VideoAggregator.podLabels | object | `{}` | Additional labels for each VideoAggregator pod |
| VideoAggregator.replicas | int | `1` | number of replicas to use when autoscaling is not enabled for this component |
| VideoAggregator.resources.limits.memory | string | `"1500M"` |  |
| VideoAggregator.resources.requests.cpu | string | `"750m"` |  |
| VideoAggregator.resources.requests.memory | string | `"600M"` |  |
| VideoAggregator.tolerations | list | `[]` |  |
| VideoCollector.annotations | object | `{}` | Annotations for VideoCollector deployment |
| VideoCollector.image.digest | string | `nil` | Overrides the image tag with an image digest |
| VideoCollector.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| VideoCollector.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| VideoCollector.image.repository | string | `"innovatrics/smartface/sf-video-collector"` | Docker image repository |
| VideoCollector.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| VideoCollector.name | string | `"video-collector"` |  |
| VideoCollector.nodeSelector | object | `{}` |  |
| VideoCollector.pdb.create | bool | `false` | create PodDisruptionBudget for VideoCollector component |
| VideoCollector.pdb.maxUnavailable | string | `""` |  |
| VideoCollector.pdb.minAvailable | int | `1` |  |
| VideoCollector.podAnnotations | object | `{}` | Annotations for VideoCollector pods |
| VideoCollector.podLabels | object | `{}` | Additional labels for each VideoCollector pod |
| VideoCollector.replicas | int | `1` | number of replicas to use when autoscaling is not enabled for this component |
| VideoCollector.resources.limits.memory | string | `"1500M"` |  |
| VideoCollector.resources.requests.cpu | string | `"750m"` |  |
| VideoCollector.resources.requests.memory | string | `"600M"` |  |
| VideoCollector.tolerations | list | `[]` |  |
| VideoReader.annotations | object | `{}` | Annotations for VideoReader deployment |
| VideoReader.image.digest | string | `nil` | Overrides the image tag with an image digest |
| VideoReader.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| VideoReader.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| VideoReader.image.repository | string | `"innovatrics/smartface/sf-video-reader"` | Docker image repository |
| VideoReader.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| VideoReader.name | string | `"video-reader"` |  |
| VideoReader.nodeSelector | object | `{}` |  |
| VideoReader.pdb.create | bool | `false` | create PodDisruptionBudget for VideoReader component |
| VideoReader.pdb.maxUnavailable | string | `""` |  |
| VideoReader.pdb.minAvailable | int | `1` |  |
| VideoReader.podAnnotations | object | `{}` | Annotations for VideoReader pods |
| VideoReader.podLabels | object | `{}` | Additional labels for each VideoReader pod |
| VideoReader.replicas | int | `1` | number of replicas to use when autoscaling is not enabled for this component |
| VideoReader.resources.limits.memory | string | `"1500M"` |  |
| VideoReader.resources.requests.cpu | string | `"750m"` |  |
| VideoReader.resources.requests.memory | string | `"600M"` |  |
| VideoReader.tolerations | list | `[]` |  |
| accessController.annotations | object | `{}` | Annotations for accessController deployment |
| accessController.authContainerPort | int | `5051` |  |
| accessController.authServiceName | string | `"auth-access-controller"` |  |
| accessController.authServicePort | int | `5051` |  |
| accessController.containerPort | int | `80` |  |
| accessController.dnsHost | string | `""` |  |
| accessController.filterConfiguration.faceOrderConfiguration.enabled | bool | `true` |  |
| accessController.filterConfiguration.faceOrderConfiguration.order | int | `1` |  |
| accessController.filterConfiguration.openingDebounceConfiguration.openingDebounceEnabled | bool | `true` |  |
| accessController.filterConfiguration.openingDebounceConfiguration.openingDebounceMs | int | `4000` |  |
| accessController.filterConfiguration.spoofCheckConfiguration.denyingDebounceMs | int | `4000` |  |
| accessController.filterConfiguration.spoofCheckConfiguration.enabled | bool | `false` |  |
| accessController.image.digest | string | `nil` | Overrides the image tag with an image digest |
| accessController.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| accessController.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| accessController.image.repository | string | `"innovatrics/smartface/sf-access-controller"` | Docker image repository |
| accessController.image.tag | string | `"v5_1.13"` | Access Controller follows different versioning, so the chart app needs to be overridden |
| accessController.mqttConfig.enabled | bool | `true` |  |
| accessController.mqttConfig.sendImageData | bool | `false` |  |
| accessController.mqttConfig.topic | string | `"edge-stream/{sourceId}/access-notifications/{notificationType}"` |  |
| accessController.name | string | `"access-controller"` |  |
| accessController.nodeSelector | object | `{}` |  |
| accessController.podAnnotations | object | `{}` | Annotations for accessController pods |
| accessController.podLabels | object | `{}` | Additional labels for each accessController pod |
| accessController.resources.requests.cpu | string | `"100m"` |  |
| accessController.resources.requests.memory | string | `"100M"` |  |
| accessController.service.annotations | object | `{}` | Annotations for accessController Service |
| accessController.service.labels | object | `{}` | Additional labels for accessController Service |
| accessController.servicePort | int | `5050` |  |
| accessController.tolerations | list | `[]` |  |
| annotations | object | `{}` | Common annotations for all deployments/StatefulSets |
| api.annotations | object | `{}` | Annotations for api deployment |
| api.containerPort | int | `80` |  |
| api.dnsHost | string | `""` |  |
| api.enabled | bool | `true` |  |
| api.image.digest | string | `nil` | Overrides the image tag with an image digest |
| api.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| api.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| api.image.repository | string | `"innovatrics/smartface/sf-api"` | Docker image repository |
| api.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| api.initMigration | bool | `true` |  |
| api.name | string | `"api"` |  |
| api.nodeSelector | object | `{}` |  |
| api.pdb.create | bool | `false` | create PodDisruptionBudget for api component |
| api.pdb.maxUnavailable | string | `""` |  |
| api.pdb.minAvailable | int | `1` |  |
| api.podAnnotations | object | `{}` | Annotations for api pods |
| api.podLabels | object | `{}` | Additional labels for each api pod |
| api.replicas | int | `1` |  |
| api.resources.limits.memory | string | `"4G"` |  |
| api.resources.requests.cpu | string | `"250m"` |  |
| api.resources.requests.memory | string | `"300M"` |  |
| api.service.annotations | object | `{}` | Annotations for api Service |
| api.service.labels | object | `{}` | Additional labels for api Service |
| api.servicePort | int | `80` |  |
| api.tolerations | list | `[]` |  |
| authApi.annotations | object | `{}` | Annotations for authApi deployment |
| authApi.containerPort | int | `80` |  |
| authApi.dnsHost | string | `""` |  |
| authApi.enabled | bool | `false` |  |
| authApi.image.digest | string | `nil` | Overrides the image tag with an image digest |
| authApi.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| authApi.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| authApi.image.repository | string | `"innovatrics/smartface/sf-api"` | Docker image repository |
| authApi.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| authApi.initMigration | bool | `true` |  |
| authApi.name | string | `"auth-api"` |  |
| authApi.nodeSelector | object | `{}` |  |
| authApi.pdb.create | bool | `false` | create PodDisruptionBudget for authApi component |
| authApi.pdb.maxUnavailable | string | `""` |  |
| authApi.pdb.minAvailable | int | `1` |  |
| authApi.podAnnotations | object | `{}` | Annotations for authApi pods |
| authApi.podLabels | object | `{}` | Additional labels for each authApi pod |
| authApi.replicas | int | `1` | number of replicas to use when autoscaling is not enabled for this component |
| authApi.resources.limits.memory | string | `"4G"` |  |
| authApi.resources.requests.cpu | string | `"250m"` |  |
| authApi.resources.requests.memory | string | `"300M"` |  |
| authApi.service.annotations | object | `{}` | Annotations for authApi Service |
| authApi.service.labels | object | `{}` | Additional labels for authApi Service |
| authApi.servicePort | int | `8098` |  |
| authApi.tolerations | list | `[]` |  |
| autoscaling.api.enabled | bool | `true` | enables ScaledObject for rest API |
| autoscaling.api.maxReplicas | int | `3` |  |
| autoscaling.api.minReplicas | int | `1` |  |
| autoscaling.api.triggers | list | `[]` | provide additional triggers - see https://keda.sh/docs/2.12/concepts/scaling-deployments/#triggers |
| autoscaling.cron.api.nonWorkHoursReplicas | int | `1` |  |
| autoscaling.cron.api.workHoursReplicas | int | `2` |  |
| autoscaling.cron.detector.nonWorkHoursReplicas | int | `1` |  |
| autoscaling.cron.detector.workHoursReplicas | int | `2` |  |
| autoscaling.cron.enabled | bool | `false` | enables predefined workhours-based cron triggers on ScaledObjects |
| autoscaling.cron.extractor.nonWorkHoursReplicas | int | `1` |  |
| autoscaling.cron.extractor.workHoursReplicas | int | `2` |  |
| autoscaling.cron.objectDetector.nonWorkHoursReplicas | int | `1` |  |
| autoscaling.cron.objectDetector.workHoursReplicas | int | `2` |  |
| autoscaling.cron.schedules | object | `{"nonWorkHours":{"end":"0 8 * * 1-5","start":"0 17 * * 1-5"},"weekend":{"end":"0 8 * * 1","start":"0 0 * * 6,0"},"workHours":{"end":"0 17 * * 1-5","start":"0 8 * * 1-5"}}` | Schedules for scaling, cron expression format: "minute hour day-of-month month day-of-week" |
| autoscaling.cron.timezone | string | `"Europe/Bratislava"` | see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones |
| autoscaling.detector.enabled | bool | `true` | enables ScaledObject for detector |
| autoscaling.detector.maxReplicas | int | `3` |  |
| autoscaling.detector.minReplicas | int | `1` |  |
| autoscaling.detector.triggers | list | `[]` | provide additional triggers - see https://keda.sh/docs/2.12/concepts/scaling-deployments/#triggers |
| autoscaling.extractor.enabled | bool | `true` | enables ScaledObject for extractor |
| autoscaling.extractor.maxReplicas | int | `3` |  |
| autoscaling.extractor.minReplicas | int | `1` |  |
| autoscaling.extractor.triggers | list | `[]` | provide additional triggers - see https://keda.sh/docs/2.12/concepts/scaling-deployments/#triggers |
| autoscaling.objectDetector.enabled | bool | `true` | enables ScaledObject for detector |
| autoscaling.objectDetector.maxReplicas | int | `8` |  |
| autoscaling.objectDetector.minReplicas | int | `1` |  |
| autoscaling.objectDetector.triggers | list | `[]` | provide additional triggers - see https://keda.sh/docs/2.12/concepts/scaling-deployments/#triggers |
| autoscaling.rmq.api.requestsPerSecond | int | `17` |  |
| autoscaling.rmq.detector.requestsPerSecond | int | `15` |  |
| autoscaling.rmq.enabled | bool | `false` | enables predefined rabbitmq triggers based on requests per second on ScaledObjects |
| autoscaling.rmq.extractor.requestsPerSecond | int | `12` |  |
| autoscaling.rmq.hostSecretName | string | `"rmq-management-uri-with-creds"` |  |
| autoscaling.rmq.objectDetector.requestsPerSecond | int | `3` |  |
| autoscaling.rmq.triggerAuthName | string | `"keda-trigger-auth-rabbitmq-conn"` |  |
| base.annotations | object | `{}` | Annotations for base deployment |
| base.image.digest | string | `nil` | Overrides the image tag with an image digest |
| base.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| base.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| base.image.repository | string | `"innovatrics/smartface/sf-base"` | Docker image repository |
| base.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| base.name | string | `"base"` |  |
| base.nodeSelector | object | `{}` |  |
| base.podAnnotations | object | `{}` | Annotations for base pods |
| base.podLabels | object | `{}` | Additional labels for each base pod |
| base.resources.requests.cpu | string | `"100m"` |  |
| base.resources.requests.memory | string | `"100M"` |  |
| base.service.annotations | object | `{}` | Annotations for base Service |
| base.service.labels | object | `{}` | Additional labels for base Service |
| base.tolerations | list | `[]` |  |
| base.zmqContainerPort | int | `2406` |  |
| base.zmqServicePort | int | `2406` |  |
| configurations.apiAuth.audience | string | `""` | audience representing the API |
| configurations.apiAuth.authority | string | `""` | issuer of JWT which the API will trust |
| configurations.apiAuth.existingConfigMapName | string | `""` | supply to bring your own configmap. the configmap needs following keys: `authority`, `audience`, `oauth_token_url` and `oauth_authorize_url` |
| configurations.apiAuth.oauthAuthorizeUrl | string | `""` | used only for enabling OAuth flows in swagger UI |
| configurations.apiAuth.oauthTokenUrl | string | `""` | used only for enabling OAuth flows in swagger UI |
| configurations.database.connectionStringKey | string | `"cs"` | key within the existing secret which contains the connection string, see https://learn.microsoft.com/en-us/dotnet/framework/data/adonet/connection-strings |
| configurations.database.existingSecretName | string | `"db-cs"` | connection string needs to be provided as a dependency of the chart |
| configurations.faceTemplate.compatibilityVersion | string | `nil` |  |
| configurations.faceTemplate.extractionAlgorithm | string | `nil` |  |
| configurations.license.mountPath | string | `"/etc/innovatrics"` |  |
| configurations.license.secretName | string | `"iface-lic"` |  |
| configurations.license.volumeMountName | string | `"license"` |  |
| configurations.s3.authType | string | `"AssumedRole"` | type of authentication to be used. Currently `AssumedRole` and `InstanceProfile` are usable |
| configurations.s3.bucketFolder | string | `""` | prefix (folder) used for S3 objects |
| configurations.s3.bucketName | string | `""` | name of S3 bucket |
| configurations.s3.bucketRegion | string | `""` | system name of AWS region of S3 bucket e.g. `eu-central-1` |
| configurations.s3.existingConfigMapName | string | `""` | supply to bring your own configmap. the configmap needs following keys: `name`, `region`, `folder`, `authType` and `useBucketRegion` |
| configurations.s3.useBucketRegion | bool | `true` | mechanism to resolve bucket endpoint - if `true` then connection is made based on bucket region. If `false` then bucket endpoint needs to be set manually |
| configurations.stationAuth.configName | string | `"station-auth-config"` | config containing authorization configuration for SF Station used when authentication is enabled for SF Station |
| configurations.stationAuth.secretName | string | `"station-client-id"` |  |
| configurations.watchlistMemberLabels | list | `[]` | array of pre-defined watchlist member labels |
| countlyPublisher.annotations | object | `{}` | Annotations for countlyPublisher deployment |
| countlyPublisher.clusterName | string | `""` |  |
| countlyPublisher.enabled | bool | `false` |  |
| countlyPublisher.image.digest | string | `nil` | Overrides the image tag with an image digest |
| countlyPublisher.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| countlyPublisher.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| countlyPublisher.image.repository | string | `"innovatrics/smartface/sf-countly-publisher"` | Docker image repository |
| countlyPublisher.image.tag | string | `"45"` | Countly publisher follows different versioning, so the chart app needs to be overridden |
| countlyPublisher.name | string | `"countly-publisher"` |  |
| countlyPublisher.nodeSelector | object | `{}` |  |
| countlyPublisher.podAnnotations | object | `{}` | Annotations for countlyPublisher pods |
| countlyPublisher.podLabels | object | `{}` | Additional labels for each countlyPublisher pod |
| countlyPublisher.resources.requests.cpu | string | `"100m"` |  |
| countlyPublisher.resources.requests.memory | string | `"100M"` |  |
| countlyPublisher.service.annotations | object | `{}` | Annotations for countlyPublisher Service |
| countlyPublisher.service.labels | object | `{}` | Additional labels for countlyPublisher Service |
| countlyPublisher.tolerations | list | `[]` |  |
| dbSynchronizationLeader.annotations | object | `{}` | Annotations for dbSynchronizationLeader deployment |
| dbSynchronizationLeader.containerPort | int | `80` |  |
| dbSynchronizationLeader.dnsHost | string | `""` |  |
| dbSynchronizationLeader.enableAuth | bool | `false` |  |
| dbSynchronizationLeader.enabled | bool | `false` | features.multitenancy needs to be enabled since tenant operator is responsible for populating wlStream |
| dbSynchronizationLeader.image.digest | string | `nil` | Overrides the image tag with an image digest |
| dbSynchronizationLeader.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| dbSynchronizationLeader.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| dbSynchronizationLeader.image.repository | string | `"innovatrics/smartface/sf-db-synchronization-leader"` | Docker image repository |
| dbSynchronizationLeader.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| dbSynchronizationLeader.name | string | `"db-synchronization-leader"` |  |
| dbSynchronizationLeader.nodeSelector | object | `{}` |  |
| dbSynchronizationLeader.pdb.create | bool | `false` | create PodDisruptionBudget for dbSynchronizationLeader component |
| dbSynchronizationLeader.pdb.maxUnavailable | string | `""` |  |
| dbSynchronizationLeader.pdb.minAvailable | int | `1` |  |
| dbSynchronizationLeader.podAnnotations | object | `{}` | Annotations for dbSynchronizationLeader pods |
| dbSynchronizationLeader.podLabels | object | `{}` | Additional labels for each dbSynchronizationLeader pod |
| dbSynchronizationLeader.replicas | int | `1` |  |
| dbSynchronizationLeader.resources.limits.memory | string | `"4G"` |  |
| dbSynchronizationLeader.resources.requests.cpu | string | `"250m"` |  |
| dbSynchronizationLeader.resources.requests.memory | string | `"300M"` |  |
| dbSynchronizationLeader.service.annotations | object | `{}` | Annotations for dbSynchronizationLeader Service |
| dbSynchronizationLeader.service.labels | object | `{}` | Additional labels for dbSynchronizationLeader Service |
| dbSynchronizationLeader.servicePort | int | `8100` |  |
| dbSynchronizationLeader.tolerations | list | `[]` |  |
| detector.annotations | object | `{}` | Annotations for detector deployment |
| detector.image.digest | string | `nil` | Overrides the image tag with an image digest |
| detector.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| detector.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| detector.image.repository | string | `"innovatrics/smartface/sf-detector"` | Docker image repository |
| detector.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| detector.name | string | `"detector"` |  |
| detector.nodeSelector | object | `{}` |  |
| detector.pdb.create | bool | `false` | create PodDisruptionBudget for detector component |
| detector.pdb.maxUnavailable | string | `""` |  |
| detector.pdb.minAvailable | int | `1` |  |
| detector.podAnnotations | object | `{}` | Annotations for detector pods |
| detector.podLabels | object | `{}` | Additional labels for each detector pod |
| detector.replicas | int | `1` | number of replicas to use when autoscaling is not enabled for this component |
| detector.resources.limits.memory | string | `"1500M"` |  |
| detector.resources.requests.cpu | string | `"750m"` |  |
| detector.resources.requests.memory | string | `"600M"` |  |
| detector.tolerations | list | `[]` |  |
| detector.warmupDetectionAlgorithms | list | `["balanced_mask"]` | Determines which face detection models are loaded at startup. You can specify one or more detection modes. |
| edgeStreamProcessor.annotations | object | `{}` | Annotations for edgeStreamProcessor deployment |
| edgeStreamProcessor.image.digest | string | `nil` | Overrides the image tag with an image digest |
| edgeStreamProcessor.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| edgeStreamProcessor.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| edgeStreamProcessor.image.repository | string | `"innovatrics/smartface/sf-edge-stream-processor"` | Docker image repository |
| edgeStreamProcessor.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| edgeStreamProcessor.name | string | `"edge-stream-processor"` |  |
| edgeStreamProcessor.nodeSelector | object | `{}` |  |
| edgeStreamProcessor.pdb.create | bool | `false` | create PodDisruptionBudget for edgeStreamProcessor component |
| edgeStreamProcessor.pdb.maxUnavailable | string | `""` |  |
| edgeStreamProcessor.pdb.minAvailable | int | `1` |  |
| edgeStreamProcessor.podAnnotations | object | `{}` | Annotations for edgeStreamProcessor pods |
| edgeStreamProcessor.podLabels | object | `{}` | Additional labels for each edgeStreamProcessor pod |
| edgeStreamProcessor.replicas | int | `1` |  |
| edgeStreamProcessor.resources.requests.cpu | string | `"100m"` |  |
| edgeStreamProcessor.resources.requests.memory | string | `"100M"` |  |
| edgeStreamProcessor.tolerations | list | `[]` |  |
| edgeStreamsStateSync.annotations | object | `{}` | Annotations for edgeStreamsStateSync deployment |
| edgeStreamsStateSync.image.digest | string | `nil` | Overrides the image tag with an image digest |
| edgeStreamsStateSync.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| edgeStreamsStateSync.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| edgeStreamsStateSync.image.repository | string | `"innovatrics/smartface/sf-edge-streams-state-synchronizer"` | Docker image repository |
| edgeStreamsStateSync.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| edgeStreamsStateSync.name | string | `"edge-streams-state-synchronizer"` |  |
| edgeStreamsStateSync.nodeSelector | object | `{}` |  |
| edgeStreamsStateSync.podAnnotations | object | `{}` | Annotations for edgeStreamsStateSync pods |
| edgeStreamsStateSync.podLabels | object | `{}` | Additional labels for each edgeStreamsStateSync pod |
| edgeStreamsStateSync.resources.requests.cpu | string | `"100m"` |  |
| edgeStreamsStateSync.resources.requests.memory | string | `"100M"` |  |
| edgeStreamsStateSync.tolerations | list | `[]` |  |
| experimentalFeatures.qr.enabled | bool | `false` | enable qr modality |
| extractor.annotations | object | `{}` | Annotations for extractor deployment |
| extractor.image.digest | string | `nil` | Overrides the image tag with an image digest |
| extractor.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| extractor.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| extractor.image.repository | string | `"innovatrics/smartface/sf-extractor"` | Docker image repository |
| extractor.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| extractor.name | string | `"extractor"` |  |
| extractor.nodeSelector | object | `{}` |  |
| extractor.pdb.create | bool | `false` | create PodDisruptionBudget for extractor component |
| extractor.pdb.maxUnavailable | string | `""` |  |
| extractor.pdb.minAvailable | int | `1` |  |
| extractor.podAnnotations | object | `{}` | Annotations for extractor pods |
| extractor.podLabels | object | `{}` | Additional labels for each extractor pod |
| extractor.replicas | int | `1` | number of replicas to use when autoscaling is not enabled for this component |
| extractor.resources.limits.memory | string | `"1G"` |  |
| extractor.resources.requests.cpu | string | `"750m"` |  |
| extractor.resources.requests.memory | string | `"500M"` |  |
| extractor.tolerations | list | `[]` |  |
| faceMatcher.annotations | object | `{}` | Annotations for faceMatcher deployment |
| faceMatcher.image.digest | string | `nil` | Overrides the image tag with an image digest |
| faceMatcher.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| faceMatcher.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| faceMatcher.image.repository | string | `"innovatrics/smartface/sf-face-matcher"` | Docker image repository |
| faceMatcher.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| faceMatcher.name | string | `"face-matcher"` |  |
| faceMatcher.nodeSelector | object | `{}` |  |
| faceMatcher.pdb.create | bool | `false` | create PodDisruptionBudget for faceMatcher component |
| faceMatcher.pdb.maxUnavailable | string | `""` |  |
| faceMatcher.pdb.minAvailable | int | `1` |  |
| faceMatcher.podAnnotations | object | `{}` | Annotations for faceMatcher pods |
| faceMatcher.podLabels | object | `{}` | Additional labels for each faceMatcher pod |
| faceMatcher.replicas | int | `1` |  |
| faceMatcher.resources.requests.cpu | string | `"100m"` |  |
| faceMatcher.resources.requests.memory | string | `"100M"` |  |
| faceMatcher.tolerations | list | `[]` |  |
| features.edgeStreams.enabled | bool | `false` | sf-tenant-management.enabled needs to be enabled since tenant operator is responsible for populating wlStream |
| features.multitenancy.enabled | bool | `false` | enabled for multitenant deployment |
| features.objectDetection.enabled | bool | `false` | enable object detector, which can detect objects and pedestrian |
| features.offlineVideoProcessing.enabled | bool | `false` | enable offline video processing services |
| features.palms.enabled | bool | `false` | enable palm detector and palm extractor, which can work with palms |
| global.image.registry | string | `"registry.gitlab.com"` | Overrides the Docker registry globally for all images |
| graphqlApi.annotations | object | `{}` | Annotations for graphqlApi deployment |
| graphqlApi.containerPort | int | `80` |  |
| graphqlApi.dnsHost | string | `""` |  |
| graphqlApi.enableAuth | bool | `false` |  |
| graphqlApi.enabled | bool | `true` |  |
| graphqlApi.image.digest | string | `nil` | Overrides the image tag with an image digest |
| graphqlApi.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| graphqlApi.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| graphqlApi.image.repository | string | `"innovatrics/smartface/sf-graphql-api"` | Docker image repository |
| graphqlApi.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| graphqlApi.initMigration | bool | `false` |  |
| graphqlApi.name | string | `"graphql-api"` |  |
| graphqlApi.nodeSelector | object | `{}` |  |
| graphqlApi.pdb.create | bool | `false` | create PodDisruptionBudget for graphqlApi component |
| graphqlApi.pdb.maxUnavailable | string | `""` |  |
| graphqlApi.pdb.minAvailable | int | `1` |  |
| graphqlApi.podAnnotations | object | `{}` | Annotations for graphqlApi pods |
| graphqlApi.podLabels | object | `{}` | Additional labels for each graphqlApi pod |
| graphqlApi.replicas | int | `1` |  |
| graphqlApi.resources.limits.memory | string | `"4G"` |  |
| graphqlApi.resources.requests.cpu | string | `"250m"` |  |
| graphqlApi.resources.requests.memory | string | `"300M"` |  |
| graphqlApi.service.annotations | object | `{}` | Annotations for graphqlApi Service |
| graphqlApi.service.labels | object | `{}` | Additional labels for graphqlApi Service |
| graphqlApi.servicePort | int | `8097` |  |
| graphqlApi.tolerations | list | `[]` |  |
| imagePullSecrets | list | `[{"name":"sf-gitlab-registry-creds"}]` | docker secrets used to pull images with |
| ingress.annotations | string | `nil` | supply custom ingress annotation |
| ingress.certificateArn | string | `""` | only used if includeAlbAnnotations == true |
| ingress.class | string | `""` | set ingress class |
| ingress.enabled | bool | `true` | enable creation of ingress object |
| ingress.includeAlbAnnotations | bool | `false` | if enabled then the ingress will include default ALB annotations |
| jaegerTracing.enabled | bool | `true` |  |
| jaegerTracing.hostname | string | `"grafana-agent.monitoring.svc.cluster.local"` |  |
| liveness.annotations | object | `{}` | Annotations for liveness deployment |
| liveness.image.digest | string | `nil` | Overrides the image tag with an image digest |
| liveness.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| liveness.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| liveness.image.repository | string | `"innovatrics/smartface/sf-liveness"` | Docker image repository |
| liveness.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| liveness.name | string | `"liveness"` |  |
| liveness.nodeSelector | object | `{}` |  |
| liveness.pdb.create | bool | `false` | create PodDisruptionBudget for liveness component |
| liveness.pdb.maxUnavailable | string | `""` |  |
| liveness.pdb.minAvailable | int | `1` |  |
| liveness.podAnnotations | object | `{}` | Annotations for liveness pods |
| liveness.podLabels | object | `{}` | Additional labels for each liveness pod |
| liveness.replicas | int | `1` |  |
| liveness.resources.requests.cpu | string | `"750m"` |  |
| liveness.resources.requests.memory | string | `"200M"` |  |
| liveness.tolerations | list | `[]` |  |
| matcher.annotations | object | `{}` | Annotations for matcher deployment |
| matcher.image.digest | string | `nil` | Overrides the image tag with an image digest |
| matcher.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| matcher.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| matcher.image.repository | string | `"innovatrics/smartface/sf-matcher"` | Docker image repository |
| matcher.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| matcher.name | string | `"matcher"` |  |
| matcher.nodeSelector | object | `{}` |  |
| matcher.pdb.create | bool | `false` | create PodDisruptionBudget for matcher component. Only works when `features.multitenancy` is disabled as PDB is not compatible with tenant operator |
| matcher.pdb.maxUnavailable | string | `""` |  |
| matcher.pdb.minAvailable | int | `1` |  |
| matcher.podAnnotations | object | `{}` | Annotations for matcher pods |
| matcher.podLabels | object | `{}` | Additional labels for each matcher pod |
| matcher.replicas | int | `1` |  |
| matcher.resources.requests.cpu | string | `"750m"` |  |
| matcher.resources.requests.memory | string | `"200M"` |  |
| matcher.tolerations | list | `[]` |  |
| metrics.enabled | bool | `false` |  |
| metrics.monitorDiscoveryLabel.instance | string | `"primary"` |  |
| metrics.port | int | `4318` |  |
| metrics.portName | string | `"metrics"` |  |
| metrics.publishAllMetrics | bool | `true` |  |
| metrics.serviceDiscoveryLabels.sf-metrics | string | `"true"` |  |
| migration.enabled | bool | `true` |  |
| migration.initContainer.image.digest | string | `nil` | Overrides the image tag with an image digest |
| migration.initContainer.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| migration.initContainer.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| migration.initContainer.image.repository | string | `"innovatrics/smartface/sf-admin"` | Docker image repository |
| migration.initContainer.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| migration.initContainer.resources | object | `{}` |  |
| migration.skipWlStreamMigration | bool | `false` |  |
| minio | object | `{"defaultBuckets":"smartface","enabled":true}` | config for minio subchart, see https://github.com/bitnami/charts/tree/main/bitnami/minio |
| nameOverride | string | `nil` | Overrides the chart's name |
| objectDetector.annotations | object | `{}` | Annotations for object detector deployment |
| objectDetector.detectionAlgorithm | string | `"accurate"` |  |
| objectDetector.enabled | bool | `false` |  |
| objectDetector.image.digest | string | `nil` | Overrides the image tag with an image digest |
| objectDetector.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| objectDetector.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| objectDetector.image.repository | string | `"innovatrics/smartface/sf-object-detector"` | Docker image repository |
| objectDetector.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| objectDetector.name | string | `"object-detector"` |  |
| objectDetector.nodeSelector | object | `{}` |  |
| objectDetector.pdb.create | bool | `false` | create PodDisruptionBudget for object detector component |
| objectDetector.pdb.maxUnavailable | string | `""` |  |
| objectDetector.pdb.minAvailable | int | `1` |  |
| objectDetector.podAnnotations | object | `{}` | Annotations for object detector pods |
| objectDetector.podLabels | object | `{}` | Additional labels for each object detector pod |
| objectDetector.replicas | int | `1` | number of replicas to use when autoscaling is not enabled for this component |
| objectDetector.resources.limits.memory | string | `"1500M"` |  |
| objectDetector.resources.requests.cpu | string | `"750m"` |  |
| objectDetector.resources.requests.memory | string | `"600M"` |  |
| objectDetector.tolerations | list | `[]` |  |
| palmDetector.annotations | object | `{}` | Annotations for palm-detector deployment |
| palmDetector.image.digest | string | `nil` | Overrides the image tag with an image digest |
| palmDetector.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| palmDetector.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| palmDetector.image.repository | string | `"innovatrics/smartface/sf-palm-detector"` | Docker image repository |
| palmDetector.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| palmDetector.name | string | `"palm-detector"` |  |
| palmDetector.nodeSelector | object | `{}` |  |
| palmDetector.pdb.create | bool | `false` | create PodDisruptionBudget for palm-detector component |
| palmDetector.pdb.maxUnavailable | string | `""` |  |
| palmDetector.pdb.minAvailable | int | `1` |  |
| palmDetector.podAnnotations | object | `{}` | Annotations for palm-detector pods |
| palmDetector.podLabels | object | `{}` | Additional labels for each palm-detector pod |
| palmDetector.replicas | int | `1` | number of replicas to use when autoscaling is not enabled for this component |
| palmDetector.resources.limits.memory | string | `"1500M"` |  |
| palmDetector.resources.requests.cpu | string | `"750m"` |  |
| palmDetector.resources.requests.memory | string | `"600M"` |  |
| palmDetector.tolerations | list | `[]` |  |
| palmDetector.warmupDetectionAlgorithms | list | `["balanced_mask"]` | Determines which face detection models are loaded at startup. You can specify one or more detection modes. |
| palmExtractor.annotations | object | `{}` | Annotations for palm-extractor deployment |
| palmExtractor.image.digest | string | `nil` | Overrides the image tag with an image digest |
| palmExtractor.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| palmExtractor.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| palmExtractor.image.repository | string | `"innovatrics/smartface/sf-palm-extractor"` | Docker image repository |
| palmExtractor.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| palmExtractor.name | string | `"palm-extractor"` |  |
| palmExtractor.nodeSelector | object | `{}` |  |
| palmExtractor.pdb.create | bool | `false` | create PodDisruptionBudget for palm-extractor component |
| palmExtractor.pdb.maxUnavailable | string | `""` |  |
| palmExtractor.pdb.minAvailable | int | `1` |  |
| palmExtractor.podAnnotations | object | `{}` | Annotations for palm-extractor pods |
| palmExtractor.podLabels | object | `{}` | Additional labels for each palm-extractor pod |
| palmExtractor.replicas | int | `1` | number of replicas to use when autoscaling is not enabled for this component |
| palmExtractor.resources.limits.memory | string | `"1G"` |  |
| palmExtractor.resources.requests.cpu | string | `"750m"` |  |
| palmExtractor.resources.requests.memory | string | `"500M"` |  |
| palmExtractor.tolerations | list | `[]` |  |
| podAnnotations | object | `{}` | Common annotations for all pods |
| podLabels | object | `{}` | Common labels for all pods |
| postgresql | object | `{"enabled":true,"primary":{"initdb":{"scripts":{"create-database.sql":"CREATE DATABASE smartface"}}}}` | config for postgresql subchart, see https://github.com/bitnami/charts/tree/main/bitnami/postgresql |
| rabbitmq | object | `{"auth":{"erlangCookie":"","existingSecretName":"","password":"","secretKey":"rabbitmq-password","username":"smartface"},"enabled":true,"extraPlugins":"rabbitmq_stream rabbitmq_stream_management rabbitmq_mqtt","mqttConfiguration":{"existingConfigMapName":"","hostname":"","port":1883,"useSsl":false,"username":""},"mqttPublicService":{"enabled":false,"mqttDnsHost":""},"rmqConfiguration":{"existingConfigMapName":"","hostname":"","port":5672,"streamsPort":5552,"useSsl":false,"username":""},"service":{"extraPorts":[{"name":"mqtt","port":1883,"targetPort":1883},{"name":"rmq-stream","port":5552,"targetPort":5552}]}}` | config for rabbitmq subchart, see https://github.com/bitnami/charts/tree/main/bitnami/rabbitmq |
| rabbitmq.auth.erlangCookie | string | `""` | used by subchart |
| rabbitmq.auth.existingSecretName | string | `""` | supply to bring you own secret. The secret needs to contain rabbitmq password under the key with name defined in `rabbitmq.auth.secretKey` |
| rabbitmq.auth.password | string | `""` | used by subchart |
| rabbitmq.auth.secretKey | string | `"rabbitmq-password"` | define key of rabbitmq password in existing/provisioned secret |
| rabbitmq.auth.username | string | `"smartface"` | username of created user in case that `rabbitmq.enabled` is `true` |
| rabbitmq.enabled | bool | `true` | configure if rabbitmq subchart should be included |
| rabbitmq.mqttConfiguration | object | `{"existingConfigMapName":"","hostname":"","port":1883,"useSsl":false,"username":""}` | if rabbitmq subchart is not included, then we need user-supplied configuration to satisfy SmartFace dependency on MQTT broker when `features.edgeStreams.enabled` is `true` |
| rabbitmq.mqttConfiguration.existingConfigMapName | string | `""` | supply to bring your own configmap. The configmap needs following keys: `hostname`, `username`, `port`, and `useSsl`. Other configuration is not used if You provide existing config map. |
| rabbitmq.mqttConfiguration.hostname | string | `""` | hostname of existing MQTT broker |
| rabbitmq.mqttConfiguration.port | int | `1883` | port of existing MQTT broker |
| rabbitmq.mqttConfiguration.useSsl | bool | `false` | set to `true` if existing MQTT broker uses TLS |
| rabbitmq.mqttConfiguration.username | string | `""` | username for existing RabbitMQ instance |
| rabbitmq.mqttPublicService | object | `{"enabled":false,"mqttDnsHost":""}` | service to publicly expose mqtt interface to be used by edge streams. Currently requires ALB controller https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/ |
| rabbitmq.rmqConfiguration | object | `{"existingConfigMapName":"","hostname":"","port":5672,"streamsPort":5552,"useSsl":false,"username":""}` | if rabbitmq subchart is not included, then we need user-supplied configuration to satisfy SmartFace dependency on rabbitmq |
| rabbitmq.rmqConfiguration.existingConfigMapName | string | `""` | supply to bring your own configmap. The configmap needs following keys: `hostname`, `username`, `port`, `useSsl`, and optionally `streamsPort` when `features.edgeStreams.enabled` is `true`. Other configuration is not used if You provide existing config map. |
| rabbitmq.rmqConfiguration.hostname | string | `""` | hostname of existing RabbitMQ instance |
| rabbitmq.rmqConfiguration.port | int | `5672` | port of existing RabbitMQ instance |
| rabbitmq.rmqConfiguration.streamsPort | int | `5552` | port for RabbitMQ streams protocol used only when `features.edgeStreams.enabled` is `true` |
| rabbitmq.rmqConfiguration.useSsl | bool | `false` | set to `true` if existing RabbitMQ instance uses TLS |
| rabbitmq.rmqConfiguration.username | string | `""` | username for existing RabbitMQ instance |
| readonlyApi.authName | string | `"readonly-auth-api"` |  |
| readonlyApi.enabled | bool | `false` |  |
| readonlyApi.noAuthName | string | `"readonly-noauth-api"` |  |
| readonlyApi.nodeSelector | object | `{}` |  |
| readonlyApi.proxyContainer.resources | object | `{}` |  |
| readonlyApi.tolerations | list | `[]` |  |
| relayController.annotations | object | `{}` | Annotations for relayController deployment |
| relayController.containerPort | int | `8080` |  |
| relayController.dnsHost | string | `""` |  |
| relayController.image.digest | string | `nil` | Overrides the image tag with an image digest |
| relayController.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| relayController.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| relayController.image.repository | string | `"innovatrics/smartface/sf-relay-controller"` | Docker image repository |
| relayController.image.tag | string | `"0.1.0.21"` | Overrides the image tag whose default is the chart's appVersion |
| relayController.name | string | `"relay-controller"` |  |
| relayController.nodeSelector | object | `{}` |  |
| relayController.pdb.create | bool | `false` | create PodDisruptionBudget for relayController component |
| relayController.pdb.maxUnavailable | string | `""` |  |
| relayController.pdb.minAvailable | int | `1` |  |
| relayController.podAnnotations | object | `{}` | Annotations for relayController pods |
| relayController.podLabels | object | `{}` | Additional labels for each relayController pod |
| relayController.replicas | int | `1` |  |
| relayController.resources.requests.cpu | string | `"100m"` |  |
| relayController.resources.requests.memory | string | `"300M"` |  |
| relayController.service.annotations | object | `{}` | Annotations for api Service |
| relayController.service.labels | object | `{}` | Additional labels for api Service |
| relayController.servicePort | int | `8080` |  |
| relayController.tolerations | list | `[]` |  |
| revisionHistoryLimit | string | `nil` | Common revisionHistoryLimit for all deployments |
| serviceAccount.annotations | object | `{}` | Annotations for the service account |
| serviceAccount.automountServiceAccountToken | bool | `true` | Set this toggle to false to opt out of automounting API credentials for the service account |
| serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created |
| serviceAccount.imagePullSecrets | list | `[]` | Image pull secrets for the service account |
| serviceAccount.labels | object | `{}` | Labels for the service account |
| serviceAccount.name | string | `"sf-service-account"` | The name of the ServiceAccount to use. |
| serviceAnnotations | object | `{}` | Common annotations for all services |
| serviceLabels | object | `{}` | Common labels for all services |
| sf-tenant-management | object | `{"api":{"enabled":false,"name":"sf-tenant-api","servicePort":80},"apiDnsHost":"","config":{"configDir":"/etc/components","fileName":"appsettings.override.json","mapName":"operator-config"},"enabled":false,"imagePullSecrets":[{"name":"sf-gitlab-registry-creds"}],"installCrd":false}` | configuration for sf-tenant-management subchart |
| sf-tenant-management.enabled | bool | `false` | configure if sf-tenant-management subchart should be included |
| skipLookupBasedValidations | bool | `false` | due to ArgoCD limitations this can be used to skip validations that use the `lookup` helm function - for more information see https://github.com/argoproj/argo-cd/issues/5202 |
| station.annotations | object | `{}` | Annotations for station deployment |
| station.containerPort | int | `80` |  |
| station.dnsHost | string | `""` |  |
| station.enabled | bool | `false` |  |
| station.image.digest | string | `nil` | Overrides the image tag with an image digest |
| station.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| station.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| station.image.repository | string | `"innovatrics/smartface/sf-station"` | Docker image repository |
| station.image.tag | string | `"v5_1.29.0"` | Smartface Station follows different versioning, so the chart app needs to be overridden |
| station.name | string | `"station"` |  |
| station.nodeSelector | object | `{}` |  |
| station.podAnnotations | object | `{}` | Annotations for station pods |
| station.podLabels | object | `{}` | Additional labels for each station pod |
| station.resources.requests.cpu | string | `"100m"` |  |
| station.resources.requests.memory | string | `"100M"` |  |
| station.service.annotations | object | `{}` | Annotations for station Service |
| station.service.labels | object | `{}` | Additional labels for station Service |
| station.servicePort | int | `8000` |  |
| station.tolerations | list | `[]` |  |
| streamDataDbWorker.annotations | object | `{}` | Annotations for streamDataDbWorker deployment |
| streamDataDbWorker.image.digest | string | `nil` | Overrides the image tag with an image digest |
| streamDataDbWorker.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| streamDataDbWorker.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| streamDataDbWorker.image.repository | string | `"innovatrics/smartface/sf-streamdatadbworker"` | Docker image repository |
| streamDataDbWorker.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| streamDataDbWorker.name | string | `"stream-data-db-worker"` |  |
| streamDataDbWorker.nodeSelector | object | `{}` |  |
| streamDataDbWorker.pdb.create | bool | `false` | create PodDisruptionBudget for streamDataDbWorker component |
| streamDataDbWorker.pdb.maxUnavailable | string | `""` |  |
| streamDataDbWorker.pdb.minAvailable | int | `1` |  |
| streamDataDbWorker.podAnnotations | object | `{}` | Annotations for streamDataDbWorker pods |
| streamDataDbWorker.podLabels | object | `{}` | Additional labels for each streamDataDbWorker pod |
| streamDataDbWorker.replicas | int | `1` |  |
| streamDataDbWorker.resources.requests.cpu | string | `"100m"` |  |
| streamDataDbWorker.resources.requests.memory | string | `"100M"` |  |
| streamDataDbWorker.tolerations | list | `[]` |  |
| tests.authentication.tenant1.clientId | string | `""` |  |
| tests.authentication.tenant1.clientSecret | string | `""` |  |
| tests.authentication.tenant1.name | string | `""` |  |
| tests.authentication.tenant2.clientId | string | `""` |  |
| tests.authentication.tenant2.clientSecret | string | `""` |  |
| tests.authentication.tenant2.name | string | `""` |  |
| tests.image.digest | string | `nil` | Overrides the image tag with an image digest |
| tests.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| tests.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| tests.image.repository | string | `"innovatrics/smartface/sf-cloud-func-tests"` | Docker image repository |
| tests.image.tag | string | `nil` | Countly publisher follows different versioning, so the chart app needs to be overridden |
| tests.nodeSelector | object | `{}` |  |
| tests.podAnnotations | object | `{}` | Annotations for test pods |
| tests.podLabels | object | `{}` | Additional labels for test pods |
| tests.tolerations | list | `[]` |  |
| updateStrategy | object | `{}` | Common updateStrategy for all deployments |
| wlStreamPopulationJob.enabled | bool | `false` |  |
| wlStreamPopulationJob.image.digest | string | `nil` | Overrides the image tag with an image digest |
| wlStreamPopulationJob.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| wlStreamPopulationJob.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| wlStreamPopulationJob.image.repository | string | `"innovatrics/smartface/sf-admin"` | Docker image repository |
| wlStreamPopulationJob.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| wlStreamPopulationJob.nodeSelector | object | `{}` |  |
| wlStreamPopulationJob.resources | object | `{}` |  |
| wlStreamPopulationJob.tolerations | list | `[]` |  |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Innovatrics |  | <https://www.innovatrics.com/> |

## Source Code

* <https://github.com/innovatrics/sf-helm>
* <https://github.com/innovatrics/smartface>

## Breaking changes

### [v0.8.0]
- Changed default behavior for creating Authentication configuration. If you like to continue managing the previously created Authentication config map please use the `configurations.apiAuth.existingConfigMapName` field. Otherwise the ConfigMap will be managed by the helm chart using the values provided in `configurations.apiAuth`
  - This change also includes renaming previous field `configurations.apiAuth.configName` -> `configurations.apiAuth.existingConfigMapName`

### [v0.6.0]
- deployment of SmartFace Station is now disabled by default. To reenable previous behavior with deploying SmartFace Station please set the `station.enabled` value to `true`.
  - previous behavior with enabled SmartFace Station caused the installation of helm chart with default values to fail on validation because SmartFace Station is currently dependant on SmartFace API with enabled authentication, which in turn requires the existence of external authentication provider and correct configuration of relevant SmartFace services
- Changed default behavior for creating Authentication configuration. If you like to continue managing the previously created Authentication config map please use the `configurations.apiAuth.existingConfigMapName` field. Otherwise the ConfigMap will be managed by the helm chart using the values provided in `configurations.apiAuth`
  - This change also includes renaming previous field `configurations.apiAuth.configName` -> `configurations.apiAuth.existingConfigMapName`

### [v0.5.0]
- MinIO subchart is enabled and used by default. To keep using S3 bucket managed outside of this helm chart please set the `minio.enabled` value to `false` and provide configuration details via `configurations.s3`
- Postgresql subchart is enabled and used by default. To keep using PgSQL instance managed outside of this helm chart please set the `postgresql.enabled` value to `false` and provide configuration details via `configurations.database`

### [v0.4.0]
- Changed default behavior for creating S3 configuration. If you like to continue managing the previously created S3 config map please use the `configurations.s3.existingConfigMapName` field. Otherwise the ConfigMap will be managed by the helm chart using the values provided in `configurations.s3`
  - The ConfigMap keys for existing config map are no longer configurable, so if you want to keep using the ConfigMap not managed by this chart then please make sure that the key match what the helm chart expects
- Some values have had their keys changed or moved around:
  - database secret -> value key changed from `configurations.database.secretName` to `configurations.database.existingSecretName`
  - rmq secret values moved to auth parent object -> from `rabbitmq.existingSecretName` to `rabbitmq.auth.existingSecretName` and `rabbitmq.secretKey` to `rabbitmq.auth.secretKey`
  - rmq configuration reworked -> value key `rabbitmq.configMapName` and `rabbitmq.mqttConfigMapName` replaced with `existingConfigMapName` key in `rabbitmq.rmqConfiguration` and `rabbitmq.mqttConfiguration` objects respectively
  - mqtt dns host configuration changed -> value key `rabbitmq.mqttDnsHost` replaced with object with key `rabbitmq.mqttPublicService` that can be disabled
  - deployment selectors changed
  - autoscaling configuration reworked -> moved rmq and cron configuration related to services their respective sub-objects e.g. for detector from `autoscaling.detector` to `autoscaling.cron.detector` and `autoscaling.rmq.detector`
- Deployment label selectors and pod labels were modified to use a more standardized approach. Unfortunately since label selector are immutable and thus the helm release cannot be upgraded. Please first use `helm uninstall` and a fresh `helm install` for upgrading. For more information see the [official documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#label-selector-updates)
