pipeline {
    agent any

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {

        stage ("clean workspace") {
            steps {
                cleanWs()
            }
        }

        stage ("Git Checkout") {
            steps {
                git branch: 'main', url: 'https://github.com/imsanju02k/jenkins-ci-cd.git'
            }
        }

       stage("Sonarqube Analysis") {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh """
                    $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectName=index-demo \
                    -Dsonar.projectKey=index-demo
                    """
                }
            }
        }

        stage("Code Quality Gate"){
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
            }
        }


        stage ("Trivy File Scan") {
            steps {
                sh "trivy fs . > trivy.txt"
            }
        }

        stage ("Build Docker Image") {
            steps {
                sh "docker build -t index-demo ."
            }
        }

        stage ("Trivy Image Scan") {
            steps {
                sh "trivy image index-demo > trivy-image.txt"
            }
        }

            stage ("Tag & Push to DockerHub") {
        steps {
            script {
                docker.withRegistry('', 'docker-cred') {
                    sh "docker tag index-demo sanjayshetty2k/index-demo:latest"
                    sh "docker push sanjayshetty2k/index-demo:latest"
                }
            }
        }
    }

        stage('Docker Scout Image') {
            steps {
                sh '''
                if command -v docker-scout >/dev/null 2>&1; then
                    docker-scout quickview sanjayshetty2k/index-demo:latest
                    docker-scout cves sanjayshetty2k/index-demo:latest
                    docker-scout recommendations sanjayshetty2k/index-demo:latest
                else
                    echo "Docker Scout not installed, skipping scan"
                fi
                '''
            }
}

        stage ("Deploy to Container") {
    steps {
        sh '''
        docker rm -f index-demo || true
        docker run -d --name index-demo -p 3000:80 sanjayshetty2k/index-demo:latest
        '''
    }
}

    }
}
