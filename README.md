# jenkins-terraform-ansible
Pipeline flow:
Agent: Launch Jenkins agent in Docker container with Terraform and Ansible (base image: nosferatus83/devops-final-jagent);
- Stage 1: Clone Terraform manifest and Ansible Playbook form GitHub;
Base repo with Terraform manifest and Ansible Playbook in Folder = infrastructure
- Stage 2: Copy GCP authentication json form Jenkins secrets to working directory;
- Stage 3: Encrypt Dockerhub password with Ansible Vault;
- Stage 4: Execute Terraform Init, Plan and Apply.

Terraform and Ansible flow:
Terraform deploys two VM instances (Staging and Production) at Google Cloud (GCP), forms custom inventory for Ansible
and then invokes Ansible playbook with roles.
Ansible playbook sets Staging and Production VM configurations according to designated roles:
STAGING environment: VM 'terraform-staging' is used to build web application "Boxfuse" inside Docker container
and push docker image with artifact to Dockerhub
PRODUCTION environment: VM 'terraform-production' is used to pull Docker image with artifact and start docker container

How to prepare your environment:
- Get VM Ubuntu 20.04 LTS
- Install and setup Jenkins, execute following commands:
apt update
apt upgrade
apt install docker.io
apt install openjdk-11-jdk -y
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian binary/ > \
      /etc/apt/sources.list.d/jenkins.list'
apt update
apt install jenkins

- Jenkins Admin password:
cat /var/lib/jenkins/secrets/initialAdminPassword

- Set additional permissions for docker agents:
chmod 777 /var/run/docker.sock

