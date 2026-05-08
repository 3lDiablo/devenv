# Specifies the version of Grafana's provisioning API.
apiVersion: 1
# A list of datasources to provision.
datasources:
- name: Prometheus
  type: prometheus
  # access: proxy means that the Grafana backend will proxy all requests from the
  # browser to the datasource. This is the most common and secure access mode.
  access: proxy
  # The URL of the Prometheus server. Since Grafana and Prometheus are in the
  # same namespace, we can use the Kubernetes internal DNS name (http://<service-name>:<port>).
  url: http://prometheus:PROMETHEUS_PORT
  # Makes this the default datasource for new panels in Grafana.
  isDefault: true
  # Prevents users from editing this datasource from within the Grafana UI.
  # Configuration should be managed declaratively here.
  editable: false
