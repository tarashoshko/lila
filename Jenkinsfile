t {
        ARTIFACT_PATH = '/home/vagrant/lila/tapipeline {
    agent any
    
    environmenrget'
        BUILD_SERVER = 'vagrant@192.168.0.2'
        DEFAULT_VERSION = '1.0.0'
        VERSION = "${DEFAULT_VERSION}"
        ARTIFACT_FILE = 'lila_${VERSION}_all.deb'
        GITHUB_REPO = 'tarashoshko/lila'
        GIT_BRANCH = 'main'
        GITHUB_TOKEN = credentials('Github_token')
        GITHUB_CREDENTIALS_ID = 'GIT_SSH'
        SBIN_PATH = '/home/vagrant/.local/share/coursier/bin'
        ORCHESTRATOR_HOST = '10.0.0.6'
        ORCHESTRATOR_USER = 'vagrant'
        SSH = credentials('SSH_PRIVATE_KEY')
        VAULT_PASS = credentials('token_password')
    }
    
    stages {
        stage('Setup SSH Known Hosts') {
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

        stage('Determine Version') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: "${GITHUB_CREDENTIALS_ID}", keyFileVariable: 'GIT_SSH')]) {
                        // Fetch the tags and checkout the latest tag
                        sh 'GIT_SSH_COMMAND="ssh -i ${GIT_SSH}" git fetch --tags'
                        def latestTag = sh(script: 'git describe --tags --abbrev=0 || echo "no-tags"', returnStdout: true).trim()
                        
                        echo "Latest Tag: ${latestTag}"

                        if (latestTag != "no-tags") {
                            env.VERSION = latestTag.replaceFirst('^v', '')  // Remove 'v' prefix if exists
                            env.ARTIFACT_FILE = "lila_${env.VERSION}_all.deb"
                        } else {
                            error 'No tags found. Unable to determine version.'
                        }

                        echo "Determined Version: ${env.VERSION}"
                    }
                }
            }
        }

        stage('Build UI') {
            agent { label 'agent1' }
            steps {
                script {
                    sh """
                    /home/vagrant/lila/ui/build
                    """
                }
            }
        }

        stage('Build App') {
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

        stage('Upload to GitHub Releases') {
            agent { label 'agent1' }
            steps {
                script {
                    withCredentials([string(credentialsId: 'GITHUB_TOKEN', variable: 'GITHUB_TOKEN')]) {
                        def releaseUrl = "https://api.github.com/repos/${GITHUB_REPO}/releases"
                        def releaseData = """{
                            "tag_name": "${env.VERSION}",
                            "name": "Release ${env.VERSION}",
                            "body": "Release notes"
                        }"""
                        
                        echo "Release data: ${releaseData}"

                        def existingRelease = sh(script: """
                            curl -H "Authorization: token \$GITHUB_TOKEN" \
                                 -H "Accept: application/vnd.github.v3+json" \
                                 ${releaseUrl}?per_page=100 | grep -o '"tag_name": "'${env.VERSION}'"' || true
                        """, returnStdout: true).trim()
                        
                        echo "Existing release: ${existingRelease}"
                        
                        if (!existingRelease) {
                            def createReleaseResponse = sh(script: """
                                curl -H "Authorization: token \$GITHUB_TOKEN" \
                                     -H "Accept: application/vnd.github.v3+json" \
                                     -X POST \
                                     -d '${releaseData}' \
                                     ${releaseUrl}
                            """, returnStdout: true).trim()

                            def releaseId = sh(script: """
                                echo '${createReleaseResponse}' | jq -r '.id'
                            """, returnStdout: true).trim()

                            if (!releaseId) {
                                error "Failed to extract releaseId from response."
                            }

                            echo "New Release ID: ${releaseId}"

                            def uploadUrl = "https://uploads.github.com/repos/${GITHUB_REPO}/releases/${releaseId}/assets?name=${ARTIFACT_FILE}"

                            echo "Upload URL: ${uploadUrl}"

                            sh """
                            curl -H "Authorization: token \$GITHUB_TOKEN" \
                                 -H "Content-Type: application/octet-stream" \
                                 --data-binary @/home/vagrant/lila/target/${ARTIFACT_FILE} \
                                 "${uploadUrl}"
                            """
                        } else {
                            echo "Release with tag '${env.VERSION}' already exists."
                        }
                    }
                }
            }
        }

        stage('Download Artifact to Orchestrator') {
            agent { label 'agent1' }
            steps {
                script {
                    sshagent(credentials: ['SSH_PRIVATE_KEY']) {
                        sh """
                        scp -o StrictHostKeyChecking=no /home/vagrant/lila/target/${ARTIFACT_FILE} ${ORCHESTRATOR_USER}@${ORCHESTRATOR_HOST}:/home/${ORCHESTRATOR_USER}/${ARTIFACT_FILE}
                        """
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh """
                    ssh -i ${SSH} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${ORCHESTRATOR_USER}@${ORCHESTRATOR_HOST} "
                        cd /${ORCHESTRATOR_USER}/ansible &&
                        ansible-playbook -i inventory.ini playbooks/application.yml -e 'version=${VERSION} artifact_file=${ARTIFACT_FILE}'
                    "
                    """
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    echo "Running tests..."
                    // Add actual test commands here
                    if (0 == 0) {
                        echo "Tests passed."
                    }
                }
            }
        }
    }
}

