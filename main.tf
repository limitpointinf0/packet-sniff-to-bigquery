// Configure the Google Cloud provider
provider "google" {
    credentials = file(var.creds_path)
    project     = var.project
    region      = var.region
}

resource "random_id" "instance_id" {
    byte_length = 8
}

// Sender VM
resource "google_compute_instance" "sender" {
    name         = "sender-vm-${random_id.instance_id.hex}"
    machine_type = var.size
    zone         = var.zone

    boot_disk {
        initialize_params {
            image = var.image
        }
    }

    metadata_startup_script = var.init

    metadata = {
        ssh-keys = "chris:${file("~/.ssh/id_rsa.pub")}"
    }

    network_interface {
        network = var.net
        // has an external ip
        access_config {}
    }
}

// Bucket
resource "google_storage_bucket" "bucket" {
  name = var.pub_sub_name
}
resource "google_storage_bucket_object" "archive" {
  name   = "pstobq.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./function/pstobq.zip"
}

//Big Query
resource "google_bigquery_dataset" "network" {
    dataset_id                  = var.bq_dataset
    friendly_name               = "network data"
    description                 = "Contains data from packet sniffs"
    location                    = "EU"
    default_table_expiration_ms = 3600000
}

resource "google_bigquery_table" "bqpackets" {
    dataset_id = google_bigquery_dataset.network.dataset_id
    table_id   = var.bq_table
    schema = <<EOF
[
  {
    "name": "datetime",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "datetime of sniff"
  },
  {
    "name": "source",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "source ip"
  },
  {
    "name": "destination",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "destination ip"
  }
]
EOF

}

//Pub Sub Topic
resource "google_pubsub_topic" "packetsniff" {
    name = "packets"
}

//Functions
# resource "google_cloudfunctions_function" "funcpacketsniff" {
#     name                  = "funcpacketsniff"
#     runtime               = "Python37"
#     available_memory_mb   = 128
#     source_archive_bucket = google_storage_bucket.bucket.name
#     source_archive_object = google_storage_bucket_object.archive.name
#     entry_point           = "pubsub_to_bigq"
#     event_trigger {
#         event_type = "google.pubsub.topic.publish"
#         resource = google_pubsub_topic.packetsniff.name
#         failure_policy {    
#           retry = false
#         }
#     }
# }

# resource "google_cloudfunctions_function_iam_member" "invoker" {
#   project        = google_cloudfunctions_function.funcpacketsniff.project
#   region         = google_cloudfunctions_function.funcpacketsniff.region
#   cloud_function = google_cloudfunctions_function.funcpacketsniff.name

#   role   = "roles/cloudfunctions.invoker"
#   member = "allUsers"
# }

output "sender-ip" {
    value = google_compute_instance.sender.network_interface.0.access_config.0.nat_ip
}