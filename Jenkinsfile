properties([
    parameters([
        [$class: 'ChoiceParameter',
            choiceType: 'PT_CHECKBOX',
            filterLength: 1,
            filterable: false,
            name: 'RUN_STAGES',
            script: [
                $class: 'GroovyScript',
                fallbackScript: [
                    classpath: [],
                    sandbox: false,
                    script: 'return ["Checking the pipeline error"]'
                ],
                script: [
                    classpath: [],
                    sandbox: false,
                    script: 'return ["Clean Ws","Git check out","Docker","Run the project","Deploy"]'
                ]
            ]
        ]
    ])
])



pipeline {
    agent any          
    environment {
        HARBOR_URL = 'harbor.aits.vn:5000'
        HARBOR_PROJECT = 'aits-alearning-test'
        IMAGE_NAME_FE = 'alearning_web'
        IMAGE_NAME_BE = 'alearning_api'
        CONTAINER_BE = 'alearning_be'
        CONTAINER_FE = 'alearning_fe'
        //HARBOR_CRED = credentials('harbor_cred')
    }
    stages{
        stage('Clean Ws') {
            when {
                expression { return params.RUN_STAGES.contains('Clean Ws')}
            }
            steps {
                cleanWs() 
            }
        }
        stage('Git check out') {
             when {
                expression { return params.RUN_STAGES.contains('Git check out')}
            }
            steps{
                echo "Find the git link and get it"
                git branch: 'development', changelog: false, poll: false, url: 'ssh://git@gitlab.aits.vn:2222/aits/alearning/alearning-web.git'
            }
        }
        stage('Set build tag'){
            when {
                expression { return params.RUN_STAGES.contains('Docker')}
            }
            steps {
                script {
                    env.BUILD_TAG = new Date().format('HH-mm--dd-MM-yyyy')
                }
            }
        }

        stage('Docker build backend') {
             when {
                expression { return params.RUN_STAGES.contains('Docker')}
             }
             steps {
                 script {
                    sh 'docker stop ${CONTAINER_BE} && docker rm ${CONTAINER_BE} || true ' 
                    sh 'docker rmi -f  ${IMAGE_NAME_BE} || true'
                    def dockerImage = docker.build("${IMAGE_NAME_BE}", "--no-cache" "-f Dockerfile_BE . ")
                 }
             }
        }


        stage('Docker build frontend') {
             when {
                expression { return params.RUN_STAGES.contains('Docker')}
             }
             steps {
                    sh 'docker stop ${CONTAINER_FE} && docker rm ${CONTAINER_FE} || true ' 
                    sh 'docker rmi -f  ${IMAGE_NAME_FE} || true'
                 script {
                    def dockerImage = docker.build("${IMAGE_NAME_FE}","--no-cache" "-f Dockerfile_FE . ")
                 }
             }
        }

        stage('Push to habor') {
            when {
                expression { return params.RUN_STAGES.contains('Docker')}
            }
            steps {
                sh 'docker login harbor.aits.vn:5000 || true'
                sh 'docker tag ${IMAGE_NAME_FE} ${HARBOR_URL}/${HARBOR_PROJECT}/${IMAGE_NAME_FE}:${BUILD_TAG} ' 
                sh 'docker tag ${IMAGE_NAME_BE} ${HARBOR_URL}/${HARBOR_PROJECT}/${IMAGE_NAME_BE}:${BUILD_TAG} ' 
                sh 'docker push ${HARBOR_URL}/${HARBOR_PROJECT}/${IMAGE_NAME_FE}:${BUILD_TAG} ' 
                sh 'docker push ${HARBOR_URL}/${HARBOR_PROJECT}/${IMAGE_NAME_BE}:${BUILD_TAG} ' 
                
            }
        }
        
        
        stage('Deploy') {
            when {
                expression { return params.RUN_STAGES.contains('Deploy')}
            }
            steps{
                script {
                    sh 'docker image ls || true '
                    sh 'docker ps -a   || true '
                    sh 'docker run -t -d --name ${CONTAINER_FE} -p 0.0.0.0:4200:80  -p [::]:4200:80  ${IMAGE_NAME_FE}'
                    sh 'docker run -t -d --name ${CONTAINER_BE} -p 0.0.0.0:8441:80 -p [::]:8441:80   ${IMAGE_NAME_BE}'
                    
                }
                echo 'Deploy on habor ... or deploy on production .... successfully'
            }
        }
    }
}
