//Pipeline: Agent: Конвейерный агент запускается в Docker контейнере с Terraform и Ansible
// (образ собирается из jenkins-agent\Dockerfile => https://hub.docker.com/repository/docker/nosferatus83/devops-final-jagent/general)

//Stage 1: Terraform и Ansible Playbook расположены в Folder = playbook
//Stage 2: Копируем GCP ключ из креденшинал Jenkins => DevOps-gcp.json;
    // GCP Authentication => Необходимо получить GCP ключ в json файле через Console https://console.cloud.google.com/apis/credentials/serviceaccountkey и поместить его в креденшинал Jenkins
// Stage 3: Шифрованый Dockerhub токен dockerhub_token при помощи Ansible Vault записываем в ./roles/dockerhub_connect/defaults/main.yml;
    // Dockerhub Authentication: Необходимо в DockerHub получить токен (https://docs.docker.com/docker-hub/access-tokens/) потом этот токен поместить в креденшинал Jenkins. 
    // Выполнить его шифрование: ansible-vault encrypt_string "your_dockerhub_password" --name "dockerhub_token" --vault-password-file vault_pass
    // Токен будет храниться в vault_pass. Поместить 'dockerhub_token' в переменную ./roles/dockerhub_connect/defaults/main.yml
//Stage 4: Настраиваем VM инфраструктуру: Terraform Init, Plan and Apply.
//Stage 5: В настроенной VM инфраструктуре выполняем сборку WAR, который заворачиваем в образ контейнера, данный артифакт выгружается в DockerHub  и в последствии деплоится на Production: ansible-playbook.

//Terraform и Ansible Playbook: Terraform разворачивает 2 VM (Staging and Production) в Google Cloud (GCP) после запускает Ansible playbook с ролями. 
//Ansible playbook для Staging и Production VM выполняет конфигурационный настройки подготовленых VM согласно ролям:
//STAGING environment: VM 'terraform-staging' для сборки war файла "Puzzle15" (https://github.com/Nosferatus83/DevOps-Final-App (c) https://github.com/venkaDaria)
//внутри контейнера с последующей побликацией образа с артифактами в Dockerhub (https://hub.docker.com/repository/docker/nosferatus83/devops_final_prod) 
//PRODUCTION environment: VM 'terraform-production' берет Docker образ с Dockerhub и запускает контейнер => результат http://[terraform-production]:80

pipeline {

  agent {

    docker {
      image 'nosferatus83/devops-final-jagent'
      //Use arguments to map sockets and user Root
      args  '-v /var/run/docker.sock:/var/run/docker.sock -u 0:0'
      //Use to automate authentication at Docker Hub
      registryCredentialsId '0423836f-27d7-48c6-b5fe-59511220d527'
    }
  }

  stages {

    //Stage 1
    stage('Get Playbook form GitHub') {
      steps{
        //Use 'git: Git' to clone Terraform manifest and Ansible playbook Folder =playbook
        git 'https://github.com/Nosferatus83/DevOps-Final.git'
      }
    }

    //Stage 2
    stage('Init GCP authentication JSON file') {
      steps {
        //Inject GCP authentication json to agent
        withCredentials([file(credentialsId: 'af8540c9-9e75-404a-a862-45f7a7106c23', variable: 'gcp_auth')]) {
          sh 'cd ./playbook && cp \$gcp_auth DevOps-gcp.json'
        }
      }
    }


    //Stage 3
    stage('Init Dockerhub token') {
      steps {
        //Encrypt Dockerhub password with Ansible Vault and export output to Ansible Role defaults
        withCredentials([string(credentialsId: '72fc7148-4206-4a05-a91d-147ab3b7ddd8', variable: 'encrypt')]) {
          sh 'cd ./playbook && ansible-vault encrypt_string $encrypt --name dockerhub_token --vault-password-file vault_pass >>./roles/dockerhub_connect/defaults/main.yml'
        }
      }
    }

    //Stage 4
    stage('RUN Terraform (prepared VM infra)') {
      steps {
        // Execute init, plan and apply for Terraform ./playbook/main.tf
        sh 'cd ./playbook && terraform init -input=false'
        sh 'cd ./playbook && terraform plan -out=tfplan -input=false -destroy'
        sh 'cd ./playbook && terraform apply -input=false tfplan'
        sh 'cd ./playbook && terraform apply -input=false -auto-approve'
      }
    }

    //Stage 5
    stage('RUN Ansible-playbook (build, deploy)') {
      steps {
        // Execute Ansible-playbook ./playbook/main.yml
        sh "cd ./playbook && ansible-playbook -u root --vault-password-file 'vault_pass' --private-key '/root/.ssh/id_rsa' -i inventory/hosts main.yml"
      }
    }


  }
}