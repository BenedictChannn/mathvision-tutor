# Terraform: Alerting policy for high latency
# ------------------------------------------
# Fires when average latency_ms logged by solver exceeds 15000 (15 s) over a 5-minute window.

resource "google_monitoring_alert_policy" "latency_high" {
  display_name = "Solver latency > 15s"

  combiner = "OR"

  conditions {
    display_name = "latency_ms_mean"

    condition_threshold {
      filter   = "metric.type=\"logging.googleapis.com/user/latency_ms\" resource.type=\"global\" labels.app=\"mathvision-solver\""
      comparison       = "COMPARISON_GT"
      threshold_value  = 15000
      duration         = "0s"
      trigger {
        count = 1
      }
      aggregations {
        alignment_period     = "300s" # 5 minutes
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MEAN"
      }
    }
  }

  notification_channels = [] # TODO: provide email / Slack channel
}