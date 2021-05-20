pipeline {
    agent any
        stages{
        stage('Terraform INIT'){
            steps{
                sh 'cd ./infrastructure && terraform init'
            }
        }
        stage('Terraform Plan VM'){
            steps{
                sh 'cd ./infrastructure && terraform plan'
            }
        }
        stage('Terraform Apply VM'){
            steps{
                sh 'cd ./infrastructure && terraform apply --auto-approve'  
            }
        }
        stage('Debug host file'){
            steps{
                sh 'cd ./infrastructure/inventory && cat hosts'  
            }

    }
}