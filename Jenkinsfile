pipeline {
    agent any
    
    environment {
        SONARQUBE_ENV = 'sonarqube'
        DOCKER_IMAGE = 'ma7moudsabra/qeema'
        // IMAGE_TAG will be set after checkout stage
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    // Get the exact Git tag for the current commit; fallback to 'latest' if no tag
                    env.GIT_TAG = sh(
                        script: "git describe --tags --exact-match || echo ''",
                        returnStdout: true
                    ).trim()
                    if (!env.GIT_TAG) {
                        echo "No Git tag found on this commit, using 'latest' as image tag."
                        env.IMAGE_TAG = 'latest'
                    } else {
                        echo "Git tag found: ${env.GIT_TAG}"
                        env.IMAGE_TAG = env.GIT_TAG
                    }
                }
            }
        }
        
        stage('Build JAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        
        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh """
                    echo "Building Docker image with tag: ${IMAGE_TAG}"
                    docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} .
                """
            }
        }
        
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh '''
                        echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
                        echo "Pushing Docker image: ${DOCKER_IMAGE}:${IMAGE_TAG}"
                        docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
                    '''
                }
            }
        }
        
        stage('Run Docker Container') {
            steps {
                sh """
                    if [ \$(docker ps -q -f name=${DOCKER_IMAGE}_container) ]; then
                        echo "Stopping existing container..."
                        docker stop ${DOCKER_IMAGE}_container
                        docker rm ${DOCKER_IMAGE}_container
                    fi
                    echo "Running new container with image: ${DOCKER_IMAGE}:${IMAGE_TAG}"
                    docker run -d -p 8000:8000 --name ${DOCKER_IMAGE}_container ${DOCKER_IMAGE}:${IMAGE_TAG}
                """
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}

