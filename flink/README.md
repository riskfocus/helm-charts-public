# Apache Flink Helm Chart

This is an implementation of https://ci.apache.org/projects/flink/flink-docs-stable/ops/deployment/kubernetes.html

## Pre Requisites:

* Kubernetes 1.3 with alpha APIs enabled and support for storage classes

* PV support on underlying infrastructure

* Requires at least `v2.0.0-beta.1` version of helm to support
  dependency management with requirements.yaml

## StatefulSet Details

* https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/

## StatefulSet Caveats

* https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#limitations

## Chart Details

This chart will do the following:

* Implement a dynamically scalable Flink(Jobmanagers and Taskmanagers) cluster using Kubernetes StatefulSets

* Implement a dynamically scalable zookeeper cluster as another Kubernetes StatefulSet required for the Flink cluster above

### Installing the Chart

To install the chart with the release name `my-flink` in the default
namespace:

```
$ helm repo add riskfocus https://riskfocus.github.io/helm-charts-public
$ helm repo update
$ helm install --name my-flink riskfoucs/flink
```

If using a dedicated namespace(recommended) then make sure the namespace
exists with:

```
$ helm repo add riskfocus https://riskfocus.github.io/helm-charts-public
$ helm repo update
$ helm install --name my-flink --namespace flink riskfoucs/flink
```

This chart can includes a ZooKeeper chart as a dependency to the Flink
cluster Jobmanagers HA mode in its `requirement.yaml`. The chart can be customized using the
following configurable parameters(other parameters can be found in values.yaml):

| Parameter                                | Description                                                                                                                                                              | Default                |
|------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------|
| `image.repository`                       | Flink Container image name                                                                                                                                               | `flink`                |
| `image.tag`                              | Flink Container image tag                                                                                                                                                | `1.9.1-scala_2.12`     |
| `image.PullPolicy`                       | Flink Containers pull policy                                                                                                                                             | `IfNotPresent`         |
| `flink.monitoring.enabled`               | Enable flink monitoring                                                                                                                                                  | `true`                 |
| `jobmanager.highAvailability.enabled`    | Enabled jobmanager HA mode key                                                                                                                                           | `false`                |
| `jobmanager.highAvailability.storageDir` | storageDir for Jobmanager in HA mode                                                                                                                                     | `null`                 |
| `jobmanager.replicaCount`                | Jobmanagers count context                                                                                                                                                | `1`                    |
| `jobmanager.heapSize`                    | Jobmanager HeapSize options                                                                                                                                             | `1g`                   |
| `jobmanager.resources`                   | Jobmanager resources                                                                                                                                                     | `{}`                 |
| `taskmanager.resources`    | Taskmanager Resources key                                                                                                                                           | `{}`                |
| `taskmanager.heapSize` | Taskmanager heapSize mode                                                                                                                                     | `1g`                 |
| `jobmanager.replicaCount`                | Taskmanager count context                                                                                                                                                | `1`                    |
| `taskmanager.numberOfTaskSlots`                   | Number of Taskmanager taskSlots resources                                                                                                                                                     | `1`                 |
| `taskmanager.resources`                   | Taskmanager resources                                                                                                                                                     | `{}`                 |
| `zookeeper.enabled`                      | If True, installs Zookeeper Chart                                                                                                                                        | `false`                 |
| `zookeeper.resources`                    | Zookeeper resource requests and limits                                                                                                                                   | `{}`                   |
| `zookeeper.env`                          | Environmental variables provided to Zookeeper Zookeeper                                                                                                                  | `{ZK_HEAP_SIZE: "1G"}` |
| `zookeeper.storage`                      | Zookeeper Persistent volume size                                                                                                                                         | `2Gi`                  |
| `zookeeper.image.PullPolicy`             | Zookeeper Container pull policy                                                                                                                                          | `IfNotPresent`         |
| `zookeeper.url`                          | URL of Zookeeper Cluster (unneeded if installing Zookeeper Chart)                                                                                                        | `""`                   |
| `zookeeper.port`                         | Port of Zookeeper Cluster                                                                                                                                                | `2181`                 |
| `zookeeper.affinity`                     | Defines affinities and anti-affinities for pods as defined in: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity preferences | `{}`                   |
| `zookeeper.nodeSelector`                 | Node labels for pod assignment                                                                                                                                           | `{}`                   |

### Install with HA

You can install this chart with enabled HA based on Zookeeper by provided follow parameters:
```
$ helm install --name my-flink riskfoucs/flink --set \
zookeeper.enabled=true,jobmanager.replicaCount=2,jobmanager.highAvailability.enabled=true,jobmanager.highAvailability.storageDir=s3://MY_BUCKET/flink/jobmanager
```
* storageDir can be different for your installation, see 
  https://ci.apache.org/projects/flink/flink-docs-stable/ops/config.html#high-availability-storagedir
