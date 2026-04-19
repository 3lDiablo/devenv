kafka:
  brokers:
    - "kafka-cluster-kafka-bootstrap:9092"
schemaRegistry:
  enabled: true
  urls:
    - "http://schema-registry:8081/apis/ccompat/v7"
kafkaConnect:
  enabled: true
  clusters:
    - name: "kafka-connect"
      url: "http://kafka-connect-api.infrastructure:8083"
