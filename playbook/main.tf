# 1 Step: Инфраструктурная подготовка "google_compute_instance": terraform-staging  и terraform-production.
# 2 Step: Подготавливаем ./inventory/hosts с полученными ip адресами VM для ansible-playbook
# 3 Step: Запускаем ansible-playbook

# Ansible playbook для Staging и Production VM выполняет конфигурационный настройки подготовленых VM согласно ролям:
# STAGING environment: VM 'terraform-staging' для сборки war файла webapp (https://github.com/boxfuse/boxfuse-sample-java-war-hello.git) 
# внутри контейнера с последующей побликацией образа с артифактами в Dockerhub (https://hub.docker.com/repository/docker/nosferatus83/devops_final_prod) 
# PRODUCTION environment: VM 'terraform-production' берет Docker образ с Dockerhub и запускает контейнер => результат http://[terraform-production]:8080/hello-1.0/
 
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.66.1"
    }
  }
}

provider "google" {
  # Configuration options
  credentials = file("DevOps-gcp.json")
  project     = "cosmic-reserve-307720"
  region      = "europe-west3"
  zone        = "europe-west3-a"
}

resource "google_compute_instance" "terraform-staging" {
  name          = "terraform-staging"
  #machine_type = "e2-small" // 2vCPU, 2GB RAM
  machine_type  = "e2-medium" // 2vCPU, 4GB RAM
  #machine_type = "custom-6-20480" // 6vCPU, 20GB RAM / 6.5GB RAM per CPU, if needed more refer to next line
  #machine_type = "custom-2-15360-ext" // 2vCPU, 15GB RAM

  tags = ["http-server","https-server"]
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      size  = "10" // size in GB for Disk
      type  = "pd-balanced" // Available options: pd-standard, pd-balanced, pd-ssd
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
    ]
    connection {
      type     = "ssh"
      user     = "root"
      private_key = file("/root/.ssh/id_rsa")
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }
}

output "staging_public_ip" {
    value = google_compute_instance.terraform-staging.network_interface[0].access_config[0].nat_ip
}

resource "google_compute_instance" "terraform-production" {
  name          = "terraform-production"
  #machine_type = "e2-small" // 2vCPU, 2GB RAM
  machine_type  = "e2-medium" // 2vCPU, 4GB RAM
  #machine_type = "custom-6-20480" // 6vCPU, 20GB RAM / 6.5GB RAM per CPU, if needed more refer to next line
  #machine_type = "custom-2-15360-ext" // 2vCPU, 15GB RAM

  tags = ["http-server","https-server"]
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      size  = "10" // size in GB for Disk
      type  = "pd-balanced" // Available options: pd-standard, pd-balanced, pd-ssd
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
    ]
    connection {
      type     = "ssh"
      user     = "root"
      private_key = file("/root/.ssh/id_rsa")
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }
}

output "production_public_ip" {
    value = google_compute_instance.terraform-production.network_interface[0].access_config[0].nat_ip
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [google_compute_instance.terraform-production]

  create_duration = "30s" // Change to 90s
}

resource "null_resource" "ansible_hosts_provisioner" {
  depends_on = [time_sleep.wait_30_seconds]
  provisioner "local-exec" {
    interpreter = ["/bin/bash" ,"-c"]
    command = <<EOT
      export terraform_staging_public_ip=$(terraform output staging_public_ip);
      echo $terraform_staging_public_ip;
      export terraform_production_public_ip=$(terraform output production_public_ip);
      echo $terraform_production_public_ip;
      sed -i -e "s/staging_instance_ip/$terraform_staging_public_ip/g" ./inventory/hosts;
      sed -i -e "s/production_instance_ip/$terraform_production_public_ip/g" ./inventory/hosts;
      sed -i -e 's/"//g' ./inventory/hosts;
      export ANSIBLE_HOST_KEY_CHECKING=False
    EOT
  }
}

resource "time_sleep" "wait_5_seconds" {
  depends_on = [null_resource.ansible_hosts_provisioner]

  create_duration = "5s"
}

resource "null_resource" "ansible_playbook_provisioner" {
  depends_on = [time_sleep.wait_5_seconds]
  provisioner "local-exec" {
    command = "ansible-playbook -u root --vault-password-file 'vault_pass' --private-key '/root/.ssh/id_rsa' -i inventory/hosts main.yml"
  }
}

