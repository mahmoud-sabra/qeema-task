pipeline {
    agent any
    environment {
        SONARQUBE_ENV = 'sonarqube'
        DOCKER_IMAGE = 'ma7moudsabra/qeema'
        IMAGE_TAG = 'latest'  // Will be updated based on tag detection
    }
    
    triggers {
        githubPush()
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Check if Tag Build') {
            steps {
                script {
                    // Simple check: if this commit has a tag, proceed
                    def hasTag = sh(
                        script: "git tag --points-at HEAD",
                        returnStdout: true
                    ).trim()
                    
                    if (!hasTag) {
                        echo "No tag found on current commit. Skipping build."
                        currentBuild.result = 'ABORTED'
                        currentBuild.description = "Skipped - Not a tag build"
                        error('Not a tag build')
                    }
                    
                    env.GIT_TAG = hasTag.split('\n')[0] // Get first tag if multiple
                    env.IMAGE_TAG = env.GIT_TAG
                    echo "Building for tag: ${env.GIT_TAG}"
                    echo "Docker image will be tagged as: ${env.IMAGE_TAG}"
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
                echo "Deploying container with image: ${DOCKER_IMAGE}:${IMAGE_TAG}"
                
                # Stop and remove existing container if it exists
                if [ \$(docker ps -q -f name=${DOCKER_IMAGE}_container) ]; then
                    echo "Stopping existing container..."
                    docker stop ${DOCKER_IMAGE}_container
                    docker rm ${DOCKER_IMAGE}_container
                fi
                
                # Run new container
                echo "Starting new container..."
                docker run -d -p 8000:8080 --name ${DOCKER_IMAGE}_container ${DOCKER_IMAGE}:${IMAGE_TAG}
                
                # Verify container is running
                sleep 3
                if [ \$(docker ps -q -f name=${DOCKER_IMAGE}_container) ]; then
                    echo "✅ Container started successfully"
                    docker ps -f name=${DOCKER_IMAGE}_container
                else
                    echo "❌ Container failed to start"
                    docker logs ${DOCKER_IMAGE}_container
                    exit 1
                fi
                """
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            script {
                echo "✅ Pipeline completed successfully for tag: ${env.GIT_TAG ?: 'N/A'}"
                currentBuild.description = "Successfully built tag: ${env.GIT_TAG ?: 'N/A'}"
            }
        }
        failure {
            script {
                echo "❌ Pipeline failed for tag: ${env.GIT_TAG ?: 'N/A'}"
                currentBuild.description = "Failed building tag: ${env.GIT_TAG ?: 'N/A'}"
            }
        }
        aborted {
            script {
                echo "🛑 Pipeline was aborted - Not a tag build"
                currentBuild.description = "Aborted - Not a tag build"
            }
        }
    }
}

