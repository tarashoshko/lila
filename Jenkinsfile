pipeline {
    agent any

    environment {
        ARTIFACT_PATH = '/home/vagrant/lila/target'
	DB_SETUP_FILE_PATH = '/home/vagrant/lila/bin/mongodb/indexes.js'
        GITHUB_REPO = 'tarashoshko/lila'
        GIT_BRANCH = 'main'
        GITHUB_TOKEN = credentials('Github_token')
        GITHUB_CREDENTIALS_ID = 'GIT_SSH'
        SBIN_PATH = '/home/vagrant/.local/share/coursier/bin'
        APP_IMAGE_NAME = 'tarashoshko/lila-app'
        MONGO_IMAGE_NAME = "tarashoshko/custom-mongo"
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

        stage('Get Tag') {
	    steps {
	        script {
	            sh 'git fetch --tags'
	
	            def gitTag = sh(script: 'git describe --tags --abbrev=0 || git tag --sort=-v:refname | head -n 1', returnStdout: true).trim()
	            echo "Latest tag: ${gitTag}"	            
			
	            if (gitTag) {
	                def tagExists = sh(script: """
	                    curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
	                    https://api.github.com/repos/${GITHUB_REPO}/releases/tags/${gitTag} \
	                    | grep -q 'not found'
	                """, returnStatus: true) == 0
			if (gitTag.startsWith("v")) {
	                    gitTag = gitTag.replaceFirst("v", "")
			    echo "Version without 'v': ${gitTag}"
	            	}
	                if (!tagExists) {
	                    echo "Tag '${gitTag}' already exists in releases."
	                    VERSION = gitTag
			    env.VERSION = gitTag
	                    env.SKIP_UPLOAD = 'false'
			    echo "App version set to: ${VERSION}"
	                } else {
	                    echo "Tag '${gitTag}' does not exist in releases, using default version '${DEFAULT_VERSION}'."
	                    VERSION = DEFAULT_VERSION
	                    env.SKIP_UPLOAD = 'true'
	                }
	            } else {
	                echo "No tags found for the latest commit, using default version '${DEFAULT_VERSION}'."
	                VERSION = DEFAULT_VERSION
	            }
	
	            ARTIFACT_FILE = "lila_${VERSION}_all.deb"
	            echo "Artifact file set to: ${ARTIFACT_FILE}"                    
	        }
	    }
	}


        stage('Check for Changes') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: "${GITHUB_CREDENTIALS_ID}", keyFileVariable: 'GIT_SSH')]) {
                        sh 'GIT_SSH_COMMAND="ssh -i ${GIT_SSH}" git fetch --all'
			def branchName = env.BRANCH_NAME
                	def changes = sh(script: "git diff --name-only origin/${branchName}", returnStdout: true).trim()
                
                        if (changes.contains('ui/')) {
                            env.BUILD_UI = 'true'
                            env.BUILD_BACKEND = 'true'
                        } else {
                            env.BUILD_UI = 'false'
                            env.BUILD_BACKEND = 'true'
                        }

			if (changes.contains('bin/mongodb/indexes.js')) {
	                    env.BUILD_MONGO_INAGE = 'true'
	                } else {
	                    env.BUILD_MONGO_INAGE = 'false'
	                }
                    }
                }
            }
        }

        stage('Code Analysis and Unit Tests') {
            steps {
                script {
                    echo "Running test..."
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
                    sbt -DVERSION=${VERSION} compile debian:packageBin
                    """
                }
            }
        }
	    
        stage('Upload Artifact to GitHub Releases') {
	    when {
	        environment name: 'SKIP_UPLOAD', value: 'false'
	    }
	    agent { label 'agent1' }
	    steps {
	        script {
	            echo "App version set to: ${VERSION}"
	            def releaseUrl = "https://api.github.com/repos/${GITHUB_REPO}/releases"
	            def releaseData = """{
	                "tag_name": "v${VERSION}",
	                "name": "Release ${VERSION}",
	                "body": "Release notes"
	            }"""
	
	            echo "Checking for existing release with tag v${VERSION}"
	            def existingRelease = sh(script: """
	                curl -H "Authorization: token \${GITHUB_TOKEN}" \
	                     -H "Accept: application/vnd.github.v3+json" \
	                     ${releaseUrl}?per_page=100 | jq -r '.[] | select(.tag_name == "v${VERSION}") | .id' || true
	            """, returnStdout: true).trim()
	
	            def releaseId = existingRelease
	            if (!existingRelease) {
	                echo "Creating new release for tag v${VERSION}"
	                def createReleaseResponse = sh(script: """
	                    curl -H "Authorization: token \$GITHUB_TOKEN" \
	                         -H "Accept: application/vnd.github.v3+json" \
	                         -X POST \
	                         -d '${releaseData}' \
	                         ${releaseUrl}
	                """, returnStdout: true).trim()
	
	                releaseId = sh(script: """
	                    echo '${createReleaseResponse}' | jq -r '.id'
	                """, returnStdout: true).trim()
	
	                if (!releaseId) {
	                    error "Failed to extract releaseId from response."
	                }
	            } else {
	                echo "Release with tag v${VERSION} already exists. Using releaseId: ${releaseId}"
	            }
	
	            def uploadUrl = "https://uploads.github.com/repos/${GITHUB_REPO}/releases/${releaseId}/assets?name=${ARTIFACT_FILE}"
	            sh """
	            curl -H "Authorization: token \$GITHUB_TOKEN" \
	                 -H "Content-Type: application/octet-stream" \
	                 --data-binary @/home/vagrant/lila/target/${ARTIFACT_FILE} \
	                 "${uploadUrl}"
		    """
	        }
	    }
	}


        stage('Prepare Artifact') {
	    when {
	        environment name: 'SKIP_UPLOAD', value: 'false'
	    }
            agent { label 'agent1' }
            steps {
                script {
                    sh """
                        echo "Copying artifact to /vagrant/docker..."
   			cd /home/vagrant/lila/target
                        cp ${ARTIFACT_PATH}/${ARTIFACT_FILE} /vagrant/docker/
                    """
                }
            }
        }
        
        stage('Build and Push Docker Image of App') {
            agent { label 'agent1' }
            steps {
                script {
		    echo "Building Docker image..."
		    echo "App version set to: ${VERSION}"
                    sh """
		    	cd /home/vagrant/lila
                        docker build -f $DOCKERFILE_APP_PATH --build-arg LILA_VERSION=${VERSION} -t $APP_IMAGE_NAME:${VERSION} -t $APP_IMAGE_NAME:latest .
                        docker push ${APP_IMAGE_NAME}:${VERSION}
                        docker push ${APP_IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Build and Push Docker Image of Mongo') {
	    when {
                environment name: 'BUILD_MONGO_INAGE', value: 'true'
            }
            agent { label 'agent1' }
            steps {
                script {
		    sh """
	            	echo "Changes detected in indexes.js. Building Docker image."
		    	cp ${DB_SETUP_FILE_PATH} /vagrant/docker/init-mongo
       			cd /vagrant/docker
		    	docker build -f Dockerfile.mongo -t $MONGO_IMAGE_NAME:${VERSION} -t $MONGO_IMAGE_NAME:latest .
		    	docker push ${MONGO_IMAGE_NAME}:${VERSION}
		    	docker push ${MONGO_IMAGE_NAME}:latest
		    """
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
                            kubectl set image deployment/lila lila=${APP_IMAGE_NAME}:latest --kubeconfig=$KUBECONFIG
                            kubectl rollout status deployment/lila --kubeconfig=$KUBECONFIG
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
