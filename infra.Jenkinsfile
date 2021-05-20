pipeline {
    agent any
        stages{
        stage('INIT'){
            steps{
                sh 'cd ./infrastructure && terraform init'
            }
        }
        stage('plan'){
            steps{
                sh 'cd ./infrastructure && terraform plan'
            }
        }
        stage('apply'){
            steps{
                sh 'cd ./infrastructure && terraform apply --auto-approve'
                
            }
        }
    }
}