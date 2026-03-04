pipeline {
    agent any

    environment {
        IMAGE_NAME = "imsanju02k/index-demo"
    }

    stages {

        stage('Checkout') {
            steps {
                git 'https://github.com/imsanju02k/jenkins-ci-cd.git'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                    sonar-scanner \
                    -Dsonar.projectKey=index-demo \
                    -Dsonar.sources=.
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:latest .'
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh 'docker run --rm aquasec/trivy image $IMAGE_NAME:latest'
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push $IMAGE_NAME:latest
                    '''
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                docker stop indexapp || true
                docker rm indexapp || true
                docker run -d -p 80:80 --name indexapp $IMAGE_NAME:latest
                '''
            }
        }
    }
}
