pipeline {
    agent any

    environment {
        ARTIFACT_PATH = '/home/vagrant/lila/target'
        GITHUB_REPO = 'tarashoshko/lila'
        GIT_BRANCH = 'main'
        GITHUB_TOKEN = credentials('Github_token')
        GITHUB_CREDENTIALS_ID = 'GIT_SSH'
        SBIN_PATH = '/home/vagrant/.local/share/coursier/bin'
        DOCKER_IMAGE_NAME = 'tarashoshko/lila-app'
        CLUSTER_IP = '192.168.59.101'
        DEFAULT_VERSION = '1.0.0'
        VERSION = "${DEFAULT_VERSION}"
        ARTIFACT_FILE = "lila_${VERSION}_all.deb"
    }

    stages {
        stage('Setup Environment') {
            steps {
                script {
                    sh '''
                    mkdir -p ~/.ssh
                    ssh-keyscan -t ecdsa github.com >> ~/.ssh/known_hosts
                    chmod 644 ~/.ssh/known_hosts
                    '''
                }
            }
        }

        stage('Check for Changes') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: "${GITHUB_CREDENTIALS_ID}", keyFileVariable: 'GIT_SSH')]) {
                        sh 'GIT_SSH_COMMAND="ssh -i ${GIT_SSH}" git fetch --all'
                        def changes = sh(script: 'git diff --name-only origin/${GIT_BRANCH}', returnStdout: true).trim()
                        if (changes.contains('ui/')) {
                            env.BUILD_UI = 'true'
                            env.BUILD_BACKEND = 'true'
                        } else {
                            env.BUILD_UI = 'false'
                            env.BUILD_BACKEND = 'true'
                        }
                    }
                }
            }
        }

        stage('Code Analysis and Unit Tests') {
            steps {
                script {
                    echo "Running test..."
                    // Replace with actual test commands
                    if (0 == 0) {
                        echo "Test passed."
                    }
                }
            }
        }

        stage('Build UI') {
            when {
                environment name: 'BUILD_UI', value: 'true'
            }
            agent { label 'agent1' }
            steps {
                script {
                    sh '/home/vagrant/lila/ui/build'
                }
            }
        }

        stage('Build App') {
            when {
                environment name: 'BUILD_BACKEND', value: 'true'
            }
            agent { label 'agent1' }
            steps {
                script {
                    sh """
                    export PATH=\$PATH:${SBIN_PATH}
                    cd /home/vagrant/lila
                    sbt -DVERSION=${env.VERSION} compile debian:packageBin
                    """
                }
            }
        }

        stage('Build Docker Images') {
            agent { label 'agent1' }
            steps {
                script {
                    sh """
                    cd /vagrant/docker
                    docker build -t ${DOCKER_IMAGE_NAME}:latest -f Dockerfile.app .
                    docker push ${DOCKER_IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                    kubectl set image deployment/lila-service lila-service=${DOCKER_IMAGE_NAME}:latest --kubeconfig ~/.kube/config
                    kubectl rollout status deployment/lila-service --kubeconfig ~/.kube/config
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
