# smartface

![Version: 0.3.0](https://img.shields.io/badge/Version-0.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v5_4.22.0](https://img.shields.io/badge/AppVersion-v5_4.22.0-informational?style=flat-square)

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
1. S3 bucket
    - Create an S3 bucket
    - Create a ConfigMap - see `external-config.yaml` for example
    - ConfigMap name must match `configurations.s3.configName` value
    - keys in the ConfigMap must match `configurations.s3.*Key` values
1. pgsql server
    - Create a PgSql server
    - Create a Secret - see `external-config.yaml` for example
    - Secret name must match `configurations.database.secretName` value
    - key in the Secret must match `configurations.database.connectionStringKey` value
1. Optionally [KEDA](https://keda.sh/) for autoscaling
    - see `autoscaling.*` values for more info

## Ingress

By default an ingress object is created with the helm chart. To configure the ingress please see the `ingress.*` values

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://ghcr.io/innovatrics/sf-helm | sf-tenant-operator | 0.1.1 |
| oci://registry-1.docker.io/bitnamicharts | rabbitmq | 12.0.4 |

All chart dependencies are optional and can be disabled and supplemented with other (for example cloud-based) alternatives

### RabbitMQ
To use non-chart managed rabbitmq:
- set `rabbitmq.enabled=false`
- create ConfigMap with rabbitmq connection details
    - ConfigMap name must match `rabbitmq.configMapName` value
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
```

```
apiVersion: v1
kind: Secret
metadata:
  name: "rmq-pass"
stringData:
  rabbitmq-password: "<password>"
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| accessController.authContainerPort | int | `5051` |  |
| accessController.authServiceName | string | `"sf-auth-access-controller"` |  |
| accessController.authServicePort | int | `5051` |  |
| accessController.containerPort | int | `80` |  |
| accessController.dnsHost | string | `""` |  |
| accessController.image.digest | string | `nil` | Overrides the image tag with an image digest |
| accessController.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| accessController.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| accessController.image.repository | string | `"innovatrics/smartface/sf-access-controller"` | Docker image repository |
| accessController.image.tag | string | `"v5_1.9.1"` | Access Controller follows different versioning, so the chart app needs to be overridden |
| accessController.name | string | `"sf-access-controller"` |  |
| accessController.nodeSelector | object | `{}` |  |
| accessController.resources.requests.cpu | string | `"100m"` |  |
| accessController.resources.requests.memory | string | `"100M"` |  |
| accessController.servicePort | int | `5050` |  |
| accessController.tolerations | list | `[]` |  |
| api.containerPort | int | `80` |  |
| api.dnsHost | string | `""` |  |
| api.enabled | bool | `true` |  |
| api.image.digest | string | `nil` | Overrides the image tag with an image digest |
| api.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| api.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| api.image.repository | string | `"innovatrics/smartface/sf-api"` | Docker image repository |
| api.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| api.initMigration | bool | `true` |  |
| api.name | string | `"sf-api"` |  |
| api.nodeSelector | object | `{}` |  |
| api.replicas | int | `1` |  |
| api.resources.limits.memory | string | `"4G"` |  |
| api.resources.requests.cpu | string | `"250m"` |  |
| api.resources.requests.memory | string | `"300M"` |  |
| api.servicePort | int | `80` |  |
| api.tolerations | list | `[]` |  |
| authApi.containerPort | int | `80` |  |
| authApi.dnsHost | string | `""` |  |
| authApi.enabled | bool | `false` |  |
| authApi.image.digest | string | `nil` | Overrides the image tag with an image digest |
| authApi.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| authApi.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| authApi.image.repository | string | `"innovatrics/smartface/sf-api"` | Docker image repository |
| authApi.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| authApi.initMigration | bool | `true` |  |
| authApi.name | string | `"sf-auth-api"` |  |
| authApi.nodeSelector | object | `{}` |  |
| authApi.replicas | int | `1` | number of replicas to use when autoscaling is not enabled for this component |
| authApi.resources.limits.memory | string | `"4G"` |  |
| authApi.resources.requests.cpu | string | `"250m"` |  |
| authApi.resources.requests.memory | string | `"300M"` |  |
| authApi.servicePort | int | `8098` |  |
| authApi.tolerations | list | `[]` |  |
| autoscaling.api.enabled | bool | `true` | enables ScaledObject for rest API |
| autoscaling.api.maxReplicas | int | `3` |  |
| autoscaling.api.minReplicas | int | `1` |  |
| autoscaling.api.nonWorkHoursReplicas | int | `1` | for cron trigger |
| autoscaling.api.rmqRps | int | `17` | for RMQ trigger |
| autoscaling.api.workHoursReplicas | int | `2` | for cron trigger |
| autoscaling.cron.enabled | bool | `false` | enables predefined cron trigger on ScaledObjects |
| autoscaling.cron.timezone | string | `"Europe/Bratislava"` | see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones |
| autoscaling.detector.enabled | bool | `true` | enables ScaledObject for detector |
| autoscaling.detector.maxReplicas | int | `3` |  |
| autoscaling.detector.minReplicas | int | `1` |  |
| autoscaling.detector.nonWorkHoursReplicas | int | `1` | for cron trigger |
| autoscaling.detector.rmqRps | int | `15` | for RMQ trigger |
| autoscaling.detector.workHoursReplicas | int | `2` | for cron trigger |
| autoscaling.extractor.enabled | bool | `true` | enables ScaledObject for extractor |
| autoscaling.extractor.maxReplicas | int | `3` |  |
| autoscaling.extractor.minReplicas | int | `1` |  |
| autoscaling.extractor.nonWorkHoursReplicas | int | `1` | for cron trigger |
| autoscaling.extractor.rmqRps | int | `12` | for RMQ trigger |
| autoscaling.extractor.workHoursReplicas | int | `2` | for cron trigger |
| autoscaling.rmq.enabled | bool | `false` | enables rabbitmq triggers on ScaledObjects |
| autoscaling.rmq.hostSecretName | string | `"rmq-management-uri-with-creds"` |  |
| autoscaling.rmq.triggerAuthName | string | `"keda-trigger-auth-rabbitmq-conn"` |  |
| base.image.digest | string | `nil` | Overrides the image tag with an image digest |
| base.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| base.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| base.image.repository | string | `"innovatrics/smartface/sf-base"` | Docker image repository |
| base.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| base.name | string | `"sf-base"` |  |
| base.nodeSelector | object | `{}` |  |
| base.resources.requests.cpu | string | `"100m"` |  |
| base.resources.requests.memory | string | `"100M"` |  |
| base.tolerations | list | `[]` |  |
| base.zmqContainerPort | int | `2406` |  |
| base.zmqServicePort | int | `2406` |  |
| configurations.apiAuth.configName | string | `"auth-config"` | config containing authorization configuration for APIs used when authentication is enabled |
| configurations.database.connectionStringKey | string | `"cs"` |  |
| configurations.database.secretName | string | `"db-cs"` |  |
| configurations.license.mountPath | string | `"/etc/innovatrics"` |  |
| configurations.license.secretName | string | `"iface-lic"` |  |
| configurations.license.volumeMountName | string | `"license"` |  |
| configurations.s3.authTypeKey | string | `"authType"` |  |
| configurations.s3.bucketKey | string | `"name"` |  |
| configurations.s3.configName | string | `"s3-config"` |  |
| configurations.s3.folderKey | string | `"folder"` |  |
| configurations.s3.regionKey | string | `"region"` |  |
| configurations.s3.useBucketRegionKey | string | `"useBucketRegion"` |  |
| configurations.stationAuth.configName | string | `"station-auth-config"` | config containing authorization configuration for SF Station used when authentication is enabled for SF Station |
| configurations.stationAuth.secretName | string | `"station-client-id"` |  |
| countlyPublisher.clusterName | string | `""` |  |
| countlyPublisher.enabled | bool | `false` |  |
| countlyPublisher.image.digest | string | `nil` | Overrides the image tag with an image digest |
| countlyPublisher.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| countlyPublisher.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| countlyPublisher.image.repository | string | `"innovatrics/smartface/sf-countly-publisher"` | Docker image repository |
| countlyPublisher.image.tag | string | `"31"` | Countly publisher follows different versioning, so the chart app needs to be overridden |
| countlyPublisher.name | string | `"countly-publisher"` |  |
| countlyPublisher.nodeSelector | object | `{}` |  |
| countlyPublisher.resources.requests.cpu | string | `"100m"` |  |
| countlyPublisher.resources.requests.memory | string | `"100M"` |  |
| countlyPublisher.tolerations | list | `[]` |  |
| detector.image.digest | string | `nil` | Overrides the image tag with an image digest |
| detector.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| detector.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| detector.image.repository | string | `"innovatrics/smartface/sf-detector"` | Docker image repository |
| detector.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| detector.name | string | `"sf-detector"` |  |
| detector.nodeSelector | object | `{}` |  |
| detector.replicas | int | `1` | number of replicas to use when autoscaling is not enabled for this component |
| detector.resources.limits.memory | string | `"1500M"` |  |
| detector.resources.requests.cpu | string | `"750m"` |  |
| detector.resources.requests.memory | string | `"600M"` |  |
| detector.tolerations | list | `[]` |  |
| edgeStreamProcessor.image.digest | string | `nil` | Overrides the image tag with an image digest |
| edgeStreamProcessor.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| edgeStreamProcessor.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| edgeStreamProcessor.image.repository | string | `"innovatrics/smartface/sf-edge-stream-processor"` | Docker image repository |
| edgeStreamProcessor.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| edgeStreamProcessor.name | string | `"sf-edge-stream-processor"` |  |
| edgeStreamProcessor.nodeSelector | object | `{}` |  |
| edgeStreamProcessor.operationMode.livenessDataStrategy | string | `"ServerOnly"` | Possible values are `EdgeStreamOnly` or `ServerOnly` |
| edgeStreamProcessor.operationMode.matchingDataStrategy | string | `"ServerOnly"` | Possible values are `EdgeStreamOnly` or `ServerOnly` |
| edgeStreamProcessor.replicas | int | `1` |  |
| edgeStreamProcessor.resources.requests.cpu | string | `"100m"` |  |
| edgeStreamProcessor.resources.requests.memory | string | `"100M"` |  |
| edgeStreamProcessor.tolerations | list | `[]` |  |
| edgeStreamsStateSync.image.digest | string | `nil` | Overrides the image tag with an image digest |
| edgeStreamsStateSync.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| edgeStreamsStateSync.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| edgeStreamsStateSync.image.repository | string | `"innovatrics/smartface/sf-edge-streams-state-synchronizer"` | Docker image repository |
| edgeStreamsStateSync.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| edgeStreamsStateSync.name | string | `"sf-edge-streams-state-synchronizer"` |  |
| edgeStreamsStateSync.nodeSelector | object | `{}` |  |
| edgeStreamsStateSync.resources.requests.cpu | string | `"100m"` |  |
| edgeStreamsStateSync.resources.requests.memory | string | `"100M"` |  |
| edgeStreamsStateSync.tolerations | list | `[]` |  |
| edgeStreamsStateSync.wlStreamPopulationJob.enabled | bool | `false` |  |
| edgeStreamsStateSync.wlStreamPopulationJob.image.digest | string | `nil` | Overrides the image tag with an image digest |
| edgeStreamsStateSync.wlStreamPopulationJob.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| edgeStreamsStateSync.wlStreamPopulationJob.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| edgeStreamsStateSync.wlStreamPopulationJob.image.repository | string | `"innovatrics/smartface/sf-admin"` | Docker image repository |
| edgeStreamsStateSync.wlStreamPopulationJob.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| edgeStreamsStateSync.wlStreamPopulationJob.nodeSelector | object | `{}` |  |
| edgeStreamsStateSync.wlStreamPopulationJob.resources | object | `{}` |  |
| edgeStreamsStateSync.wlStreamPopulationJob.tolerations | list | `[]` |  |
| extractor.image.digest | string | `nil` | Overrides the image tag with an image digest |
| extractor.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| extractor.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| extractor.image.repository | string | `"innovatrics/smartface/sf-extractor"` | Docker image repository |
| extractor.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| extractor.name | string | `"sf-extractor"` |  |
| extractor.nodeSelector | object | `{}` |  |
| extractor.replicas | int | `1` | number of replicas to use when autoscaling is not enabled for this component |
| extractor.resources.limits.memory | string | `"1G"` |  |
| extractor.resources.requests.cpu | string | `"750m"` |  |
| extractor.resources.requests.memory | string | `"500M"` |  |
| extractor.tolerations | list | `[]` |  |
| faceMatcher.image.digest | string | `nil` | Overrides the image tag with an image digest |
| faceMatcher.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| faceMatcher.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| faceMatcher.image.repository | string | `"innovatrics/smartface/sf-face-matcher"` | Docker image repository |
| faceMatcher.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| faceMatcher.name | string | `"sf-face-matcher"` |  |
| faceMatcher.nodeSelector | object | `{}` |  |
| faceMatcher.replicas | int | `1` |  |
| faceMatcher.resources.requests.cpu | string | `"100m"` |  |
| faceMatcher.resources.requests.memory | string | `"100M"` |  |
| faceMatcher.tolerations | list | `[]` |  |
| features.edgeStreams.enabled | bool | `false` |  |
| features.multitenancy.enabled | bool | `false` | enabled for multitenant deployment. Will include sf-tenant-operator subchart if enabled |
| global.image.registry | string | `"registry.gitlab.com"` | Overrides the Docker registry globally for all images |
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
| graphqlApi.name | string | `"sf-graphql-api"` |  |
| graphqlApi.nodeSelector | object | `{}` |  |
| graphqlApi.replicas | int | `1` |  |
| graphqlApi.resources.limits.memory | string | `"4G"` |  |
| graphqlApi.resources.requests.cpu | string | `"250m"` |  |
| graphqlApi.resources.requests.memory | string | `"300M"` |  |
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
| liveness.image.digest | string | `nil` | Overrides the image tag with an image digest |
| liveness.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| liveness.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| liveness.image.repository | string | `"innovatrics/smartface/sf-liveness"` | Docker image repository |
| liveness.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| liveness.name | string | `"sf-liveness"` |  |
| liveness.nodeSelector | object | `{}` |  |
| liveness.replicas | int | `1` |  |
| liveness.resources.requests.cpu | string | `"750m"` |  |
| liveness.resources.requests.memory | string | `"200M"` |  |
| liveness.tolerations | list | `[]` |  |
| matcher.image.digest | string | `nil` | Overrides the image tag with an image digest |
| matcher.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| matcher.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| matcher.image.repository | string | `"innovatrics/smartface/sf-matcher"` | Docker image repository |
| matcher.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| matcher.name | string | `"sf-matcher"` |  |
| matcher.nodeSelector | object | `{}` |  |
| matcher.replicas | int | `1` |  |
| matcher.resources.requests.cpu | string | `"750m"` |  |
| matcher.resources.requests.memory | string | `"200M"` |  |
| matcher.tolerations | list | `[]` |  |
| metrics.enabled | bool | `false` |  |
| metrics.monitorDiscoveryLabel.instance | string | `"primary"` |  |
| metrics.port | int | `4318` |  |
| metrics.portName | string | `"metrics"` |  |
| metrics.serviceDiscoveryLabels.sf-metrics | string | `"true"` |  |
| migration.enabled | bool | `true` |  |
| migration.initContainer.image.digest | string | `nil` | Overrides the image tag with an image digest |
| migration.initContainer.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| migration.initContainer.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| migration.initContainer.image.repository | string | `"innovatrics/smartface/sf-admin"` | Docker image repository |
| migration.initContainer.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| migration.initContainer.resources | object | `{}` |  |
| rabbitmq | object | `{"auth":{"erlangCookie":"","password":"","username":"smartface"},"configMapName":"sf-rmq-connection","enabled":true,"existingSecretName":"","extraPlugins":"rabbitmq_stream rabbitmq_stream_management rabbitmq_mqtt","mqttConfigMapName":"sf-mqtt-connection","mqttDnsHost":"","secretKey":"rabbitmq-password","service":{"extraPorts":[{"name":"mqtt","port":1883,"targetPort":1883},{"name":"rmq-stream","port":5552,"targetPort":5552}]}}` | config for rabbitmq subchart, see https://github.com/bitnami/charts/tree/main/bitnami/rabbitmq |
| rabbitmq.enabled | bool | `true` | configure if rabbitmq subchart should be included |
| rabbitmq.mqttDnsHost | string | `""` | hostname used for MQTT service - only relevant for edge streams |
| readonlyApi.authName | string | `"readonly-auth-api"` |  |
| readonlyApi.enabled | bool | `false` |  |
| readonlyApi.noAuthName | string | `"readonly-noauth-api"` |  |
| readonlyApi.nodeSelector | object | `{}` |  |
| readonlyApi.proxyContainer.resources | object | `{}` |  |
| readonlyApi.tolerations | list | `[]` |  |
| serviceAccount.annotations | object | `{}` | Annotations for the service account |
| serviceAccount.automountServiceAccountToken | bool | `true` | Set this toggle to false to opt out of automounting API credentials for the service account |
| serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created |
| serviceAccount.imagePullSecrets | list | `[]` | Image pull secrets for the service account |
| serviceAccount.labels | object | `{}` | Labels for the service account |
| serviceAccount.name | string | `"sf-service-account"` | The name of the ServiceAccount to use. |
| sf-tenant-operator | object | `{"config":{"configDir":"/etc/components","fileName":"appsettings.override.json","mapName":"operator-config"},"image":{"secretName":"sf-gitlab-registry-creds"},"installCrd":false}` | configuration for sf-tenant-operator subchart |
| skipLookupBasedValidations | bool | `false` | due to ArgoCD limitations this can be used to skip validations that use the `lookup` helm function - for more information see https://github.com/argoproj/argo-cd/issues/5202 |
| station.containerPort | int | `80` |  |
| station.dnsHost | string | `""` |  |
| station.enabled | bool | `true` |  |
| station.image.digest | string | `nil` | Overrides the image tag with an image digest |
| station.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| station.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| station.image.repository | string | `"innovatrics/smartface/sf-station"` | Docker image repository |
| station.image.tag | string | `"v5_1.20.0"` | Smartface Station follows different versioning, so the chart app needs to be overridden |
| station.name | string | `"sf-station"` |  |
| station.nodeSelector | object | `{}` |  |
| station.resources.requests.cpu | string | `"100m"` |  |
| station.resources.requests.memory | string | `"100M"` |  |
| station.servicePort | int | `8000` |  |
| station.tolerations | list | `[]` |  |
| streamDataDbWorker.image.digest | string | `nil` | Overrides the image tag with an image digest |
| streamDataDbWorker.image.pullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| streamDataDbWorker.image.registry | string | `nil` | The Docker registry, overrides `global.image.registry` |
| streamDataDbWorker.image.repository | string | `"innovatrics/smartface/sf-streamdatadbworker"` | Docker image repository |
| streamDataDbWorker.image.tag | string | `nil` | Overrides the image tag whose default is the chart's appVersion |
| streamDataDbWorker.name | string | `"sf-stream-data-db-worker"` |  |
| streamDataDbWorker.nodeSelector | object | `{}` |  |
| streamDataDbWorker.replicas | int | `1` |  |
| streamDataDbWorker.resources.requests.cpu | string | `"100m"` |  |
| streamDataDbWorker.resources.requests.memory | string | `"100M"` |  |
| streamDataDbWorker.tolerations | list | `[]` |  |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Innovatrics |  | <https://www.innovatrics.com/> |

## Source Code

* <https://github.com/innovatrics/sf-helm>
* <https://github.com/innovatrics/smartface>

## Breaking changes

Upgrade guide to future major version will be here
