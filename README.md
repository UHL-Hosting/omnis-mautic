# mautic-k8s
Mautic 6 deployment on Kubernetes

This repository includes a Docker image for running Mautic. The image now
installs Node.js 18 and npm in order to build Mautic's frontend assets during the
image build.

## Redis Connectivity

The chart relies on a Redis instance provided by the Bitnami `redis` chart.
If the liveness or readiness probes report errors connecting to Redis with a
message similar to:

```
Could not connect to Redis at <release>-redis-master-0.<release>-redis-headless.<namespace>.svc.cluster.local:6379: Name or service not known
```

make sure Redis is deployed using the `replication` architecture so the DNS
records match the expected hostname. You can enable this by setting the
`redis.architecture` value to `replication` in `values.yaml` or your custom
`values` file:

```yaml
redis:
  architecture: replication
```

## RabbitMQ password secret

This chart automatically creates a secret containing the RabbitMQ password. The secret name is controlled by `rabbitmq.auth.existingPasswordSecret` and defaults to `mautic-rabbitmq-password`.
