pipeline {
    agent { label 'podman' }

    triggers {
        pollSCM('H/2 * * * *')
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        REGISTRY = 'registry.assign.npatel355.300.ops:5000'
        IMAGE    = 'registry.assign.npatel355.300.ops:5000/bind-secondary'
    }

    stages {
        stage('Prepare') {
            steps {
                script {
                    def shortSha = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.TAG = "${env.BUILD_NUMBER}-${shortSha}"
                }
                echo "Image tag: ${env.TAG}"
            }
        }

        stage('Build') {
            steps {
                sh 'podman build -t "$IMAGE:$TAG" .'
            }
        }

        stage('CVE Scan') {
            steps {
                sh 'podman save -o image.tar "$IMAGE:$TAG"'
                sh 'trivy image --input image.tar --no-progress --format table --output trivy-report.txt'
                sh 'trivy image --input image.tar --no-progress --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1'
            }
        }

        stage('Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'registry-creds',
                                                  usernameVariable: 'REG_USER',
                                                  passwordVariable: 'REG_PASS')]) {
                    sh 'echo "$REG_PASS" | podman login --username "$REG_USER" --password-stdin "$REGISTRY"'
                    sh 'podman push "$IMAGE:$TAG"'
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'trivy-report.txt', allowEmptyArchive: true
            sh 'podman logout "$REGISTRY" || true'
            sh 'rm -f image.tar'
        }
    }
}
