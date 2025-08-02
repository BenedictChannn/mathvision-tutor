# Terraform: Export Cloud Run logs to BigQuery
# -------------------------------------------
# Creates a BigQuery dataset + table sink for Cloud Logging entries that
# include the custom labels from our Flask solver endpoints.
#
# Variables (provide via tfvars or environment):
#   project_id – GCP project
#   region      – GCP region (BigQuery dataset location)
#
# NOTE: Ensure Cloud Logging API and BigQuery are enabled in the project.

variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_bigquery_dataset" "logs" {
  dataset_id                 = "solver_logs"
  location                   = var.region
  delete_contents_on_destroy = true
}

# Log sink that routes logs with label app="mathvision-solver" to BigQuery
data "google_project" "project" {}

resource "google_logging_project_sink" "solver_to_bq" {
  name        = "solver-logs-bq-sink"
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${google_bigquery_dataset.logs.dataset_id}"
  filter      = "labels.app=\"mathvision-solver\""

  # Grant writer identity permission to the dataset
  bigquery_options {
    use_partitioned_tables = true
  }
}

resource "google_bigquery_dataset_iam_member" "sink_writer" {
  dataset_id = google_bigquery_dataset.logs.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.solver_to_bq.writer_identity
}
