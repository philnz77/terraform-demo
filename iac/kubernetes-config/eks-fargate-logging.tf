resource "kubernetes_namespace" "fargate_logging" {
  metadata {
    name = "aws-observability"
    labels = {
      aws-observability = "enabled"
    }
  }
}

resource "kubernetes_config_map" "fargate_logging" {
  metadata {
    namespace = kubernetes_namespace.fargate_logging.metadata[0].name
    name = "aws-logging"
  }
  data = {
    flb_log_cw: "false"
    "filters.conf" : <<EOT
[FILTER]
  Name parser
  Match *
  Key_name log
  Parser crio
[FILTER]
  Name kubernetes
  Match kube.*
  Merge_Log On
  Keep_Log Off
  Buffer_Size 0
  Kube_Meta_Cache_TTL 300s
EOT
    "output.conf" : <<EOT
[OUTPUT]
  Name cloudwatch_logs
  Match kube.*
  region ${local.region}
  log_group_name ${local.fargate_log_group_name}
  log_stream_prefix fg-
  log_retention_days 1
  auto_create_group false
EOT
    "parsers.conf" : <<EOT
[PARSER]
    Name crio
    Format Regex
    Regex ^(?<time>[^ ]+) (?<stream>stdout|stderr) (?<logtag>P|F) (?<log>.*)$
    Time_Key    time
    Time_Format %Y-%m-%dT%H:%M:%S.%L%z
EOT
  }
}