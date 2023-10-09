node {
    def repourl = "${REGISTRY_URL}/${PROJECT_ID}/${ARTIFACT_REGISTRY}"

    stage('Checkout') {
        checkout([$class: 'GitSCM',
            branches: [[name: '*/main']],
            extensions: [],
            userRemoteConfigs: [[credentialsId: 'git', 
            url: 'https://github.com/valorjj/config-server.git']]
        ])
    }

    stage('Build and Push Image to Google Cloud') {


        /*
        현재 docker 에 대한 권한이없다고 나온다.
        그리고 sudo docker 명령어를 사용하면 로그인 하라고 나온다.
        credHelper 를 통해 로그인 되었다고 생각했는데 이 부분이 잘못되었을까?

        
        */

        // jenkins 에 등록한 gcp 인증 정보
        withCredentials([file(credentialsId: 'gcp', variable: 'GC_KEY')]) {
            sh 'whoami'

            // 해당 사용자가 도커를 사용할 권한을 얻도록 그룹에 추가한다.
            // 터미널에서는 id 명령어로 확인할 수 있다.
            // sh 'groupadd docker'
            // sh 'usermod -a -G docker ${USER}'
            // sh 'newgrp docker'
            // sh 'id'

            // 젠킨스에 업로드한 서비스 계정의 자격증명을 통해 Artifact Registry 를 인증한다. 
            sh 'gcloud auth activate-service-account --key-file=${GC_KEY}'
            // credHelper 를 통해서 Artifact Registry 에서 도커를 사용할 수 있게한다.
            sh 'gcloud auth configure-docker asia-northeast3-docker.pkg.dev'

            sh 'echo hi'
            
            // 프로젝트를 빌드한다.
            sh 'chmod +x gradlew'
            sh '''
            -DREPO_URL=${REGISTRY_URL}/${PROJECT_ID}/${ARTIFACT_REGISTRY}
            ./gradlew clean jib
            '''

        }
    }

    stage('Deploy') {
        // replace a IMAGE_URL to gcp artifact registry url in deployment.yml
        sh ("sed -i 's/IMAGE_URL/${repourl}/g' k8s/deployment.yml")
        step([$class: 'KubernetesEngineBuilder',
            projectId: env.PROJECT_ID,
            clusterName: env.CLUSTER,
            location: env.ZONE,
            manifestPattern: 'k8s/deployment.yml',
            credentialsId: env.PROJECT_ID,
            verifyDeployments: true])
    }
}