pipeline {
    agent any
        stages{
        stage('INIT'){
            steps{
                sh 'cd ./infrastructure && sudo terraform init'
            }
        }
        stage('plan'){
            steps{
                sh 'cd ./infrastructure && sudo terraform plan'
            }
        }
        stage('apply'){
            steps{
                sh 'cd ./infrastructure && sudo terraform apply --auto-approve'
            }
        }
    }
}