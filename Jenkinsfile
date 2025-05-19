edit pipeline {
    agent any

    environment {
        SONARQUBE_ENV = 'sonarqube'               
        DOCKER_IMAGE = 'ma7moudsabra/qeema'    
        IMAGE_TAG = "v${BUILD_NUMBER}"
    }


    stages {
        stage('Checkout') {
            when {
                branch 'dev'
            }
            steps {
                checkout scm
            }
        }

        stage('Build JAR') {
            when {
                branch 'dev'
            }
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Scan') {
            when {
                branch 'dev'
            }
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Wait for Quality Gate') {
            when {
                branch 'dev'
            }
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
            when {
                branch 'dev'
            }
            steps {
                sh """
                docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} .
                docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} ${DOCKER_IMAGE}:latest
                """
            }
        }

        stage('Push Docker Image') {
            when {
                branch 'dev'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh """
                    echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
                    docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
                    docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        // Added stage to print current branch
        stage('Print Current Branch') {
            steps {
                echo "Current branch: ${env.BRANCH_NAME}"
                sh 'echo "Current branch in shell: $BRANCH_NAME"'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}

