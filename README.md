# sf-lfis

![Version: 0.1.17](https://img.shields.io/badge/Version-0.1.17-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v5_4.21.0](https://img.shields.io/badge/AppVersion-v5_4.21.0-informational?style=flat-square)

SmartFace Lightweight Face Identification System (LFIS) is a lightweight, powerful, scalable, multi-platform and easy-to-deploy solution for facial biometrics use cases easily integrated to any third-party system via REST API. Available for fast cloud and on premise deployment.

**Homepage:** <https://www.innovatrics.com/face-recognition-solutions/>

## TL;DR

```
helm install sf-lfis oci://ghcr...
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
| https://nexus3.ba.innovatrics.net/repository/helm-sface | sf-tenant-operator | 0.1.1 |
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
| accessController.servicePort | int | `5050` |  |
| api.containerPort | int | `80` |  |
| api.dnsHost | string | `""` |  |
| api.enabled | bool | `true` |  |
| api.initMigration | bool | `true` |  |
| api.name | string | `"sf-api"` |  |
| api.servicePort | int | `80` |  |
| auth.configName | string | `"auth-config"` | config containing authorization configuration for APIs used when authentication is enabled |
| authApi.containerPort | int | `80` |  |
| authApi.dnsHost | string | `""` |  |
| authApi.enabled | bool | `false` |  |
| authApi.initMigration | bool | `true` |  |
| authApi.name | string | `"sf-auth-api"` |  |
| authApi.servicePort | int | `8098` |  |
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
| base.zmqContainerPort | int | `2406` |  |
| base.zmqServicePort | int | `2406` |  |
| countlyPublisher.clusterName | string | `""` |  |
| countlyPublisher.enabled | bool | `false` |  |
| countlyPublisher.imageTag | string | `"31"` |  |
| countlyPublisher.name | string | `"countly-publisher"` |  |
| database.connectionStringKey | string | `"cs"` |  |
| database.secretName | string | `"db-cs"` |  |
| detector.cpuRequests | string | `"750m"` |  |
| detector.name | string | `"sf-detector"` |  |
| edgeStreams.enabled | bool | `false` |  |
| edgeStreams.name | string | `"sf-edge-stream-processor"` |  |
| extractor.cpuRequests | string | `"750m"` |  |
| extractor.name | string | `"sf-extractor"` |  |
| faceMatcher.name | string | `"sf-face-matcher"` |  |
| graphqlApi.containerPort | int | `80` |  |
| graphqlApi.dnsHost | string | `""` |  |
| graphqlApi.enableAuth | bool | `false` |  |
| graphqlApi.initMigration | bool | `false` |  |
| graphqlApi.name | string | `"sf-graphql-api"` |  |
| graphqlApi.servicePort | int | `8097` |  |
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
| liveness.cpuRequests | string | `"750m"` |  |
| liveness.name | string | `"sf-liveness"` |  |
| matcher.cpuRequests | string | `"750m"` |  |
| matcher.name | string | `"sf-matcher"` |  |
| metrics.enabled | bool | `false` |  |
| metrics.monitorDiscoveryLabel.instance | string | `"primary"` |  |
| metrics.port | int | `4318` |  |
| metrics.portName | string | `"metrics"` |  |
| metrics.serviceDiscoveryLabels.sf-metrics | string | `"true"` |  |
| migration.enabled | bool | `true` |  |
| multitenancy.enabled | bool | `false` | enabled for multitenant deployment. Will include sf-tenant-operator subchart if enabled |
| rabbitmq | object | `{"auth":{"erlangCookie":"","password":"","username":"smartface"},"configMapName":"sf-rmq-connection","enabled":true,"existingSecretName":"","extraPlugins":"rabbitmq_stream rabbitmq_stream_management rabbitmq_mqtt","mqttDnsHost":"","secretKey":"rabbitmq-password"}` | config for rabbitmq subchart, see https://github.com/bitnami/charts/tree/main/bitnami/rabbitmq |
| rabbitmq.enabled | bool | `true` | configure if rabbitmq subchart should be included |
| rabbitmq.mqttDnsHost | string | `""` | hostname used for MQTT service - only relevant for edge streams |
| readonlyApi.authName | string | `"readonly-auth-api"` |  |
| readonlyApi.enabled | bool | `false` |  |
| readonlyApi.noAuthName | string | `"readonly-noauth-api"` |  |
| s3.bucketKey | string | `"name"` |  |
| s3.configName | string | `"s3-config"` |  |
| s3.regionKey | string | `"region"` |  |
| sf-tenant-operator | object | `{"config":{"configDir":"/etc/components","fileName":"appsettings.override.json","mapName":"operator-config"},"image":{"secretName":"sf-gitlab-registry-creds"},"installCrd":false}` | configuration for sf-tenant-operator subchart |
| station.containerPort | int | `80` |  |
| station.dnsHost | string | `""` |  |
| station.enabled | bool | `true` |  |
| station.imageVersion | string | `"v5_1.17.0"` |  |
| station.name | string | `"sf-station"` |  |
| station.servicePort | int | `8000` |  |
| stationAuth.configName | string | `"station-auth-config"` | config containing authorization configuration for SF Station used when authentication is enabled for SF Station |
| stationAuth.secretName | string | `"station-client-id"` |  |
| streamDataDbWorker.name | string | `"sf-stream-data-db-worker"` |  |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Innovatrics |  | <https://www.innovatrics.com/> |

## Source Code

* <https://github.com/innovatrics/smartface>

## Breaking changes

Upgrade guide to future major version will be here
