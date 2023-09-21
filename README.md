# smartface

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v5_4.21.0](https://img.shields.io/badge/AppVersion-v5_4.21.0-informational?style=flat-square)

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
    - The secret name must match `image.secretName` value
    - see comments in `external-config.yaml` for commands to create kubernetes manifest with credentials
1. License file secret
    - Get the license file from [Customer portal](https://customerportal.innovatrics.com)
    - The secret name must match `license.secretName` value
    - see comments in `external-config.yaml` for commands to create kubernetes manifest with license file
1. S3 bucket
    - Create an S3 bucket
    - Create a ConfigMap - see `external-config.yaml` for example
    - ConfigMap name must match `s3.configName` value
    - keys in the ConfigMap must match `s3.bucketKey` and `s3.regionKey` values
1. pgsql server
    - Create a PgSql server
    - Create a Secret - see `external-config.yaml` for example
    - Secret name must match `database.secretName` value
    - key in the Secret must match `database.connectionStringKey` value
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
| accessController.imageVersion | string | `"v5_1.9.1"` |  |
| accessController.name | string | `"sf-access-controller"` |  |
| accessController.nodeSelector | object | `{}` |  |
| accessController.resources.requests.cpu | string | `"100m"` |  |
| accessController.resources.requests.memory | string | `"100M"` |  |
| accessController.servicePort | int | `5050` |  |
| accessController.tolerations | list | `[]` |  |
| api.containerPort | int | `80` |  |
| api.dnsHost | string | `""` |  |
| api.enabled | bool | `true` |  |
| api.initMigration | bool | `true` |  |
| api.name | string | `"sf-api"` |  |
| api.nodeSelector | object | `{}` |  |
| api.resources.limits.memory | string | `"4G"` |  |
| api.resources.requests.cpu | string | `"250m"` |  |
| api.resources.requests.memory | string | `"300M"` |  |
| api.servicePort | int | `80` |  |
| api.tolerations | list | `[]` |  |
| auth.configName | string | `"auth-config"` | config containing authorization configuration for APIs used when authentication is enabled |
| authApi.containerPort | int | `80` |  |
| authApi.dnsHost | string | `""` |  |
| authApi.enabled | bool | `false` |  |
| authApi.initMigration | bool | `true` |  |
| authApi.name | string | `"sf-auth-api"` |  |
| authApi.nodeSelector | object | `{}` |  |
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
| base.name | string | `"sf-base"` |  |
| base.nodeSelector | object | `{}` |  |
| base.resources.requests.cpu | string | `"100m"` |  |
| base.resources.requests.memory | string | `"100M"` |  |
| base.tolerations | list | `[]` |  |
| base.zmqContainerPort | int | `2406` |  |
| base.zmqServicePort | int | `2406` |  |
| countlyPublisher.clusterName | string | `""` |  |
| countlyPublisher.enabled | bool | `false` |  |
| countlyPublisher.imageTag | string | `"31"` |  |
| countlyPublisher.name | string | `"countly-publisher"` |  |
| countlyPublisher.nodeSelector | object | `{}` |  |
| countlyPublisher.resources.requests.cpu | string | `"100m"` |  |
| countlyPublisher.resources.requests.memory | string | `"100M"` |  |
| countlyPublisher.tolerations | list | `[]` |  |
| database.connectionStringKey | string | `"cs"` |  |
| database.secretName | string | `"db-cs"` |  |
| detector.name | string | `"sf-detector"` |  |
| detector.nodeSelector | object | `{}` |  |
| detector.resources.limits.memory | string | `"1500M"` |  |
| detector.resources.requests.cpu | string | `"750m"` |  |
| detector.resources.requests.memory | string | `"600M"` |  |
| detector.tolerations | list | `[]` |  |
| edgeStreams.enabled | bool | `false` |  |
| edgeStreams.name | string | `"sf-edge-stream-processor"` |  |
| edgeStreams.nodeSelector | object | `{}` |  |
| edgeStreams.resources.requests.cpu | string | `"100m"` |  |
| edgeStreams.resources.requests.memory | string | `"100M"` |  |
| edgeStreams.tolerations | list | `[]` |  |
| extractor.name | string | `"sf-extractor"` |  |
| extractor.nodeSelector | object | `{}` |  |
| extractor.resources.limits.memory | string | `"1G"` |  |
| extractor.resources.requests.cpu | string | `"750m"` |  |
| extractor.resources.requests.memory | string | `"500M"` |  |
| extractor.tolerations | list | `[]` |  |
| faceMatcher.name | string | `"sf-face-matcher"` |  |
| faceMatcher.nodeSelector | object | `{}` |  |
| faceMatcher.resources.requests.cpu | string | `"100m"` |  |
| faceMatcher.resources.requests.memory | string | `"100M"` |  |
| faceMatcher.tolerations | list | `[]` |  |
| graphqlApi.containerPort | int | `80` |  |
| graphqlApi.dnsHost | string | `""` |  |
| graphqlApi.enableAuth | bool | `false` |  |
| graphqlApi.initMigration | bool | `false` |  |
| graphqlApi.name | string | `"sf-graphql-api"` |  |
| graphqlApi.nodeSelector | object | `{}` |  |
| graphqlApi.resources.limits.memory | string | `"4G"` |  |
| graphqlApi.resources.requests.cpu | string | `"250m"` |  |
| graphqlApi.resources.requests.memory | string | `"300M"` |  |
| graphqlApi.servicePort | int | `8097` |  |
| graphqlApi.tolerations | list | `[]` |  |
| image.registry | string | `"registry.gitlab.com/innovatrics/smartface/"` | registry to pull SmartFace images from |
| image.secretName | string | `"sf-gitlab-registry-creds"` | docker secret to pull SmartFace images with |
| ingress.annotations | string | `nil` | supply custom ingress annotation |
| ingress.certificateArn | string | `""` | only used if includeAlbAnnotations == true |
| ingress.class | string | `""` | set ingress class |
| ingress.enabled | bool | `true` | enable creation of ingress object |
| ingress.includeAlbAnnotations | bool | `false` | if enabled then the ingress will include default ALB annotations |
| jaeger.enabled | bool | `true` |  |
| jaeger.hostname | string | `"grafana-agent.monitoring.svc.cluster.local"` |  |
| license.mountPath | string | `"/etc/innovatrics"` |  |
| license.secretName | string | `"iface-lic"` |  |
| license.volumeMountName | string | `"license"` |  |
| liveness.name | string | `"sf-liveness"` |  |
| liveness.nodeSelector | object | `{}` |  |
| liveness.resources.requests.cpu | string | `"750m"` |  |
| liveness.resources.requests.memory | string | `"200M"` |  |
| liveness.tolerations | list | `[]` |  |
| matcher.name | string | `"sf-matcher"` |  |
| matcher.nodeSelector | object | `{}` |  |
| matcher.resources.requests.cpu | string | `"750m"` |  |
| matcher.resources.requests.memory | string | `"200M"` |  |
| matcher.tolerations | list | `[]` |  |
| metrics.enabled | bool | `false` |  |
| metrics.monitorDiscoveryLabel.instance | string | `"primary"` |  |
| metrics.port | int | `4318` |  |
| metrics.portName | string | `"metrics"` |  |
| metrics.serviceDiscoveryLabels.sf-metrics | string | `"true"` |  |
| migration.enabled | bool | `true` |  |
| migration.initContainer.resources | object | `{}` |  |
| multitenancy.enabled | bool | `false` | enabled for multitenant deployment. Will include sf-tenant-operator subchart if enabled |
| rabbitmq | object | `{"auth":{"erlangCookie":"","password":"","username":"smartface"},"configMapName":"sf-rmq-connection","enabled":true,"existingSecretName":"","extraPlugins":"rabbitmq_stream rabbitmq_stream_management rabbitmq_mqtt","mqttDnsHost":"","secretKey":"rabbitmq-password"}` | config for rabbitmq subchart, see https://github.com/bitnami/charts/tree/main/bitnami/rabbitmq |
| rabbitmq.enabled | bool | `true` | configure if rabbitmq subchart should be included |
| rabbitmq.mqttDnsHost | string | `""` | hostname used for MQTT service - only relevant for edge streams |
| readonlyApi.authName | string | `"readonly-auth-api"` |  |
| readonlyApi.enabled | bool | `false` |  |
| readonlyApi.noAuthName | string | `"readonly-noauth-api"` |  |
| readonlyApi.nodeSelector | object | `{}` |  |
| readonlyApi.proxyContainer.resources | object | `{}` |  |
| readonlyApi.tolerations | list | `[]` |  |
| s3.authTypeKey | string | `"authType"` |  |
| s3.bucketKey | string | `"name"` |  |
| s3.configName | string | `"s3-config"` |  |
| s3.endpointTypeKey | string | `"endpointType"` |  |
| s3.folderKey | string | `"folder"` |  |
| s3.regionKey | string | `"region"` |  |
| serviceAccount.annotations | object | `{}` | Annotations for the service account |
| serviceAccount.automountServiceAccountToken | bool | `true` | Set this toggle to false to opt out of automounting API credentials for the service account |
| serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created |
| serviceAccount.imagePullSecrets | list | `[]` | Image pull secrets for the service account |
| serviceAccount.labels | object | `{}` | Labels for the service account |
| serviceAccount.name | string | `"sf-service-account"` | The name of the ServiceAccount to use. |
| sf-tenant-operator | object | `{"config":{"configDir":"/etc/components","fileName":"appsettings.override.json","mapName":"operator-config"},"image":{"secretName":"sf-gitlab-registry-creds"},"installCrd":false}` | configuration for sf-tenant-operator subchart |
| station.containerPort | int | `80` |  |
| station.dnsHost | string | `""` |  |
| station.enabled | bool | `true` |  |
| station.imageVersion | string | `"v5_1.17.0"` |  |
| station.name | string | `"sf-station"` |  |
| station.nodeSelector | object | `{}` |  |
| station.resources.requests.cpu | string | `"100m"` |  |
| station.resources.requests.memory | string | `"100M"` |  |
| station.servicePort | int | `8000` |  |
| station.tolerations | list | `[]` |  |
| stationAuth.configName | string | `"station-auth-config"` | config containing authorization configuration for SF Station used when authentication is enabled for SF Station |
| stationAuth.secretName | string | `"station-client-id"` |  |
| streamDataDbWorker.name | string | `"sf-stream-data-db-worker"` |  |
| streamDataDbWorker.nodeSelector | object | `{}` |  |
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
