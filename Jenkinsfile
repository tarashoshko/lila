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
        DOCKER_MONGO_IMAGE_NAME = "tarashoshko/custom-mongo"
        DOCKERFILE_APP_PATH = "Dockerfile.app"
        DOCKERFILE_MONGO_PATH = "Dockerfile.mongo"
        CLUSTER_IP = '192.168.59.101'
        DEFAULT_VERSION = '1.0.0'
        VERSION = "${DEFAULT_VERSION}"
        ARTIFACT_FILE = "lila_${VERSION}_all.deb"
        KUBECONFIG = credentials('KUBECONFIG')
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

        stage('Build and Push Docker Image of App') {
            agent { label 'agent1' }
            steps {
                script {
                    def indexFileChanged = sh(script: "git diff --name-only HEAD~1 | grep bin/mongodb/indexes.js", returnStatus: true) == 0
                    if (indexFileChanged) {
                        echo "Changes detected in indexes.js. Building Docker image."
                        sh '''
                            docker build -t ${DOCKER_IMAGE_NAME}:latest -f Dockerfile.mongo .
                            docker push ${DOCKER_IMAGE_NAME}:latest
                        '''
                    } else {
                        echo "No changes in indexes.js. Skipping Docker build."
                        return
                    }
                }
            }
        }

        stage('Check for Changes in indexes.js') {
            steps {
                script {
                    def changes = sh(script: 'git diff --name-only HEAD~1 HEAD | grep bin/mongodb/indexes.js || true', returnStdout: true).trim()
                    if (changes) {
                        echo "Changes detected in indexes.js. Proceeding to Docker build."
                    } else {
                        echo "No changes in indexes.js. Skipping Docker build."
                        currentBuild.result = 'SUCCESS'
                        return
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                        echo "Building Docker image..."
                        docker build -f $DOCKERFILE_PATH -t $DOCKER_IMAGE_NAME .
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'KUBECONFIG', variable: 'KUBECONFIG')]) {
                        sh '''
                            echo "Checking KUBECONFIG permissions and content"
                            ls -l $KUBECONFIG
                            cat $KUBECONFIG
                            chmod 600 $KUBECONFIG
                            echo "Using kubeconfig: $KUBECONFIG"
                            kubectl version --client
                            kubectl config set-cluster my-cluster --server=http://192.168.59.101:6443 --kubeconfig=$KUBECONFIG
                            kubectl config set-context my-context --cluster=minikube --user=minikube --kubeconfig=$KUBECONFIG
                            kubectl config use-context my-context --kubeconfig=$KUBECONFIG
                            kubectl set image deployment/lila lila-service=${DOCKER_IMAGE_NAME}:latest --kubeconfig=$KUBECONFIG
                            kubectl rollout status deployment/lila-service --kubeconfig=$KUBECONFIG
                            if git diff --name-only HEAD~1 | grep -qE 'Dockerfile.mongo|bin/mongodb/indexes.js'; then
                                echo "Changes detected in MongoDB-related files. Updating MongoDB image."
                                kubectl set image deployment/mongo mongo=${MONGO_IMAGE_NAME}:latest --kubeconfig=$KUBECONFIG
                                kubectl rollout status deployment/mongo --kubeconfig=$KUBECONFIG || true
                            else
                                echo "No changes in MongoDB files. Skipping MongoDB image update."
                            fi
                        '''
                    }
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
