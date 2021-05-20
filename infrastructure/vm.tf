#файл шаблон для создания пустых инстансев в гугл клауде
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.66.1"
    }
  }
}

provider "google" {
  project     = "cosmic-reserve-307720"
  region      = "europe-west3"
  zone      = "europe-west3-a"
}

resource "google_compute_instance" "DevOps_Final" {
  count=2
  name         = "vm-${count.index + 1}"
  machine_type = "e2-small" // 2vCPU, 2GB RAM
  tags = ["http-server","https-server"]
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      size = "10" // size in GB for Disk
      type = "pd-balanced" // Available options: pd-standard, pd-balanced, pd-ssd
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP and external static IP
      #nat_ip = google_compute_address.static.address
    }
  }

  metadata = {
    ssh-keys = "root:${file("/root/.ssh/id_rsa.pub")}" // Point to ssh public key for user root
  }

    provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install python3 -y",
      "sudo apt install docker.io -y",
    ]
    connection {
      type     = "ssh"
      user     = "root"
      private_key = file("/root/.ssh/id_rsa")
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }
}

  // A variable for extracting the external IP address of the instance
  output "ip_build" {
  value = google_compute_instance.vm-1.network_interface.0.access_config.0.nat_ip
}
  output "ip_prod" {
  value = google_compute_instance.vm-2.network_interface.0.access_config.0.nat_ip
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [google_compute_instance.DevOps_Final]

  create_duration = "30s" // Change to 90s
}

resource "null_resource" "ansible_hosts_provisioner" {
  depends_on = [time_sleep.wait_30_seconds]
  provisioner "local-exec" {
    interpreter = ["/bin/bash" ,"-c"]
    command = <<EOT
      export gcp_public_ip_build=$(terraform output ip_build);
      export gcp_public_ip_prod=$(terraform output ip_prod);
      echo $gcp_public_ip_build;
      echo $gcp_public_ip_prod;
      sed -i -e "s/gcp_instance_ip_build/$gcp_public_ip_build/g" ./inventory/hosts;
      sed -i -e "s/gcp_instance_ip_prod/$gcp_public_ip_prod/g" ./inventory/hosts;
      sed -i -e 's/"//g' ./inventory/hosts;
      export ANSIBLE_HOST_KEY_CHECKING=False
    EOT
  }
}

/*
resource "time_sleep" "wait_5_seconds" {
  depends_on = [null_resource.ansible_hosts_provisioner]

  create_duration = "5s"
}

resource "null_resource" "ansible_playbook_provisioner" {
  depends_on = [time_sleep.wait_5_seconds]
  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook -u root --private-key './key1' -i inventory/hosts site.yml;
      export ANSIBLE_HOST_KEY_CHECKING=False
    EOT
  }
}
*/