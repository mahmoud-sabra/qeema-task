pipeline {
    
    agent any
    environment {
        SONARQUBE_ENV = 'sonarqube'
        DOCKER_IMAGE = 'ma7moudsabra/qeema'
        IMAGE_TAG = "${env.GIT_TAG ?: 'latest'}"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    // Get tags pointing at the current commit (HEAD)
                    env.GIT_TAG = sh(script: "git tag --points-at HEAD", returnStdout: true).trim()
                    
                    // If multiple tags, use first one
                    if (env.GIT_TAG.contains('\n')) {
                        env.GIT_TAG = env.GIT_TAG.split('\n')[0]
                    }
                    
                    echo "Detected Git tag: ${env.GIT_TAG ?: 'none'}"
                    
                    if (!env.GIT_TAG) {
                        error("No tag found on this commit. Aborting build.")
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
                docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} .
                """
            }
        }
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh '''
                    echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
                    docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
                    '''
                }
            }
        }
        stage('Run Docker Container') {
            steps {
                sh """
                if [ \$(docker ps -q -f name=${DOCKER_IMAGE}_container) ]; then
                    docker stop ${DOCKER_IMAGE}_container
                    docker rm ${DOCKER_IMAGE}_container
                fi
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

