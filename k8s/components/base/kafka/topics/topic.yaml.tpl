apiVersion: kafka.strimzi.io/v1
kind: KafkaTopic
metadata:
  name: __TOPIC_NAME__
  namespace: __NAMESPACE__
  labels:
    strimzi.io/cluster: __CLUSTER_NAME__
spec:
  partitions: __PARTITIONS__
  replicas: __REPLICAS__
  config: {} # Will be populated by yq
