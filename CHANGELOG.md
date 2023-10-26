# Changelog

## [v0.4.0]

### Added
- Common labels with option to specify custom labels/annotation for objects
- PodDisruptionBudgets for deployments that can be scaled
- Support for custom KEDA triggers

### Breaking change
- TODO Deployments and service use more standard pod selectors - this should be a breaking change because deployment selectors are immutable

## [v0.3.0]

### Added
- Support for pushing watchlist data to edge streams via EdgeStreamsStateSynchronizer

## [v0.2.0]

### Added
- Initial implementation
- Chart can be configured to support following scenarios:
    - Lightweight Face Identification System (LFIS) - single-tenant and multi-tenant
    - Edge stream processing - single tenant only
- Chart can be configured to use externally-managed rabbitmq (e.g. [AmazonMQ](https://aws.amazon.com/amazon-mq/)) or deploy a rabbitmq [subchart](https://github.com/bitnami/charts/tree/main/bitnami/rabbitmq)
