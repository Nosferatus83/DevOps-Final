# Сертификационная работа по DevOps (jenkins,terraform,ansible,docker)

Задача: Написать Jenkins pipeline, который разворачивает инстансы в GCP, производит на них сборку Java приложения (terraform-staging) и деплоит приложение на
прод (terraform-production). Необходимо использовать код Terraform и Ansible. Приложение должно быть собрано и развернуто в Docker.

Pipeline:
Agent: Конвейерный агент запускается в Docker контейнере с Terraform и Ansible (образ собирается из jenkins-agent\Dockerfile => https://hub.docker.com/repository/docker/nosferatus83/devops-final-jagent/general)

- Stage 1: Terraform и Ansible Playbook расположены в Folder = playbook
- Stage 2: Копируем GCP ключ из креденшинал Jenkins => DevOps-gcp.json;
- Stage 3: Шифрованый Dockerhub токен dockerhub_token при помощи Ansible Vault записываем в ./roles/dockerhub_connect/defaults/main.yml;
- Stage 4: Настраиваем VM инфраструктуру: Terraform Init, Plan and Apply.
- Stage 5 (NEW): В настроенной VM инфраструктуре выполняем сборку WAR, который заворачиваем в образ контейнера, данный артифакт выгружается в DockerHub  и в последствии деплоится на Production: ansible-playbook.
![Image alt](https://github.com/nosferatus83/DevOps-Final/raw/master/pipeline.png)

Terraform и Ansible Playbook:
Terraform разворачивает 2 VM (Staging and Production) в Google Cloud (GCP) после запускает Ansible playbook с ролями.
Ansible playbook для Staging и Production VM выполняет конфигурационный настройки подготовленых VM согласно ролям:
STAGING environment: VM 'terraform-staging' для сборки war файла "Puzzle15" (https://github.com/Nosferatus83/DevOps-Final-App (c) https://github.com/venkaDaria) внутри контейнера с последующей побликацией образа с артифактами в Dockerhub (https://hub.docker.com/repository/docker/nosferatus83/devops_final_prod)
PRODUCTION environment: VM 'terraform-production' берет Docker образ с Dockerhub и запускает контейнер => результат http://[terraform-production]:80

![Image alt](https://github.com/nosferatus83/DevOps-Final/raw/master/webapp.png)

How to prepare your environment:
- Get VM Ubuntu 20.04 LTS
- Install and setup Jenkins, execute following commands:
     - apt update
     - apt install docker.io
     - apt install openjdk-11-jdk -y
     - wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
     - sh -c 'echo deb https://pkg.jenkins.io/debian binary/ > \ /etc/apt/sources.list.d/jenkins.list'
     - apt update
     - apt install jenkins

- Jenkins Admin password:
     - cat /var/lib/jenkins/secrets/initialAdminPassword

- Set additional permissions for docker agents:
     - chmod 777 /var/run/docker.sock

