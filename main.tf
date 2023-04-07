resource "google_service_account" "default" {
    depends_on = [
      google_project_service.project, google_project_service.cloudmanager
    ]
    
  account_id   = "test-vm-sa"
  display_name = "Service Account"
}
#api enable
resource "google_project_service" "project" {
    depends_on = [
      google_project_service.cloudmanager
    ]
  project = "metal-node-383004"
  service = "iam.googleapis.com"

#   timeouts {
#     create = "30m"
#     update = "40m"
#   }

  #disable_dependent_services = true
}

resource "google_project_service" "cloudmanager" {
  project = "metal-node-383004"
  service = "cloudresourcemanager.googleapis.com"

#   timeouts {
#     create = "30m"
#     update = "40m"
#   }

  #disable_dependent_services = true
}

resource "google_compute_instance" "default" {
  name         = "test-vm"
  machine_type = "e2-medium"
  zone         = "europe-west1-b"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  // Local SSD disk
#   scratch_disk {
#     interface = "SCSI"
#   }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }
  
  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}