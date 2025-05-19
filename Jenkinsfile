pipeline {
    agent any
    environment {
        SONARQUBE_ENV = 'sonarqube'
        DOCKER_IMAGE = 'ma7moudsabra/qeema'
        IMAGE_TAG = "${env.GIT_TAG ?: 'latest'}"
    }
    
    // Add trigger to handle GitHub webhooks
    triggers {
        githubPush()
    }
    
    stages {
        stage('Check Event Type') {
            steps {
                script {
                    // Print webhook payload for debugging
                    echo "GitHub Event: ${env.GITHUB_EVENT_NAME ?: 'N/A'}"
                    echo "Ref Type: ${env.GITHUB_REF_TYPE ?: 'N/A'}"
                    echo "Git Branch: ${env.GIT_BRANCH ?: 'N/A'}"
                    echo "Ref: ${env.GITHUB_REF ?: 'N/A'}"
                }
            }
        }
        
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    // Try multiple methods to get tag name
                    if (env.GITHUB_REF_TYPE == 'tag') {
                        env.GIT_TAG = env.GITHUB_REF
                        echo "Tag from GitHub webhook: ${env.GIT_TAG}"
                    } else {
                        env.GIT_TAG = sh(script: "git describe --tags --exact-match 2>/dev/null || echo ''", returnStdout: true).trim()
                        echo "Tag from git command: ${env.GIT_TAG}"
                    }
                    
                    // If still no tag found, check if we're on a tag
                    if (!env.GIT_TAG && env.GIT_BRANCH?.contains('tags/')) {
                        env.GIT_TAG = env.GIT_BRANCH.split('tags/')[1]
                        echo "Tag extracted from branch name: ${env.GIT_TAG}"
                    }
                    
                    // Update IMAGE_TAG
                    env.IMAGE_TAG = env.GIT_TAG ?: 'latest'
                    echo "Final IMAGE_TAG: ${env.IMAGE_TAG}"
                }
            }
        }
        
        stage('Verify Tag Build') {
            when {
                anyOf {
                    // Build only when it's a tag creation event
                    expression { env.GITHUB_REF_TYPE == 'tag' }
                    // Or when branch contains tags (fallback)
                    expression { env.GIT_BRANCH?.contains('tags/') }
                    // Or when we successfully detected a tag
                    expression { env.GIT_TAG && env.GIT_TAG != '' }
                }
            }
            steps {
                echo "This is a tag build. Proceeding with pipeline..."
                echo "Building tag: ${env.GIT_TAG}"
            }
        }
        
        stage('Build JAR') {
            when {
                anyOf {
                    expression { env.GITHUB_REF_TYPE == 'tag' }
                    expression { env.GIT_BRANCH?.contains('tags/') }
                    expression { env.GIT_TAG && env.GIT_TAG != '' }
                }
            }
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        
        stage('SonarQube Scan') {
            when {
                anyOf {
                    expression { env.GITHUB_REF_TYPE == 'tag' }
                    expression { env.GIT_BRANCH?.contains('tags/') }
                    expression { env.GIT_TAG && env.GIT_TAG != '' }
                }
            }
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh 'mvn sonar:sonar'
                }
            }
        }
        
        stage('Build Docker Image') {
            when {
                anyOf {
                    expression { env.GITHUB_REF_TYPE == 'tag' }
                    expression { env.GIT_BRANCH?.contains('tags/') }
                    expression { env.GIT_TAG && env.GIT_TAG != '' }
                }
            }
            steps {
                sh """
                docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} .
                """
            }
        }
        
        stage('Push Docker Image') {
            when {
                anyOf {
                    expression { env.GITHUB_REF_TYPE == 'tag' }
                    expression { env.GIT_BRANCH?.contains('tags/') }
                    expression { env.GIT_TAG && env.GIT_TAG != '' }
                }
            }
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
            when {
                anyOf {
                    expression { env.GITHUB_REF_TYPE == 'tag' }
                    expression { env.GIT_BRANCH?.contains('tags/') }
                    expression { env.GIT_TAG && env.GIT_TAG != '' }
                }
            }
            steps {
                sh """
                if [ \$(docker ps -q -f name=${DOCKER_IMAGE}_container) ]; then
                    docker stop ${DOCKER_IMAGE}_container
                    docker rm ${DOCKER_IMAGE}_container
                fi
                docker run -d -p 8000:8080 --name ${DOCKER_IMAGE}_container ${DOCKER_IMAGE}:${IMAGE_TAG}
                """
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        failure {
            echo "Pipeline failed. Check the logs above."
        }
        success {
            echo "Pipeline completed successfully for tag: ${env.GIT_TAG ?: 'N/A'}"
        }
    }
}
