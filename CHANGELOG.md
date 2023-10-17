# Changelog

## [v1.0.0] - TBD

### Added

- Initial implementation
- Chart can be configured to support following scenarios:
    - Lightweight Face Identification System (LFIS) - single-tenant and multi-tenant
    - Edge stream processing - single tenant only
- Chart can be configured to use externally-managed rabbitmq (e.g. [AmazonMQ](https://aws.amazon.com/amazon-mq/)) or deploy a rabbitmq [subchart](https://github.com/bitnami/charts/tree/main/bitnami/rabbitmq)
- Support for pushing watchlist data to edge streams via EdgeStreamsStateSynchronizer
- Common labels with option to specify custom labels/annotation for objects
- PodDisruptionBudgets for deployments that can be scaled
