node {
    // GCR 주소를 환경변수로 주입받음
    // 결과: asia-northeast3-docker.pkg.dev/alpine-guild-401310/spring-microservices
    def repoURL = "${REGISTRY_URL}/${PROJECT_ID}/${ARTIFACT_REGISTRY}"

    stage('Checkout') {
        checkout([$class: 'GitSCM',
            branches: [[name: '*/main']],
            extensions: [],
            userRemoteConfigs: [[credentialsId: 'git', 
            url: 'https://github.com/valorjj/config-server.git']]
        ])
    }

    stage('Build and Push Image to Google Cloud') {
        // jenkins 에 등록한 gcp 인증 정보
        withCredentials([file(credentialsId: 'gcp', variable: 'GC_KEY')]) {
            // 젠킨스에 업로드한 서비스 계정의 자격증명을 통해 Artifact Registry 를 인증한다. 
            sh("gcloud auth activate-service-account --key-file=${GC_KEY}")
            // credHelper 를 통해서 Artifact Registry 에서 도커를 사용할 수 있게한다.
            sh("gcloud auth configure-docker asia-northeast3-docker.pkg.dev")
            // gradle 에서 jib 작동 확인
            // 프로젝트 빌드 후 .jar 파일 생성, (build.gradle 에 변수 할당)
            sh("./gradlew clean jib -DREPO_URL=${REGISTRY_URL}/${PROJECT_ID}/${ARTIFACT_REGISTRY}") 
        }
    }

    stage('Deploy') {
        // 쿠버네티스 배포 파일에 변수 할당
        sh("sed -i 's|IMAGE_URL|${repoURL}|g' k8s/deployment.yml") 
        
        step([$class: 'KubernetesEngineBuilder',
            projectId: env.PROJECT_ID,
            clusterName: env.CLUSTER,
            location: env.ZONE,
            manifestPattern: 'k8s/deployment.yml',
            credentialsId: env.GOOGLE_SERVICE_ACCOUNT_CREDENTIAL,
            verifyDeployments: true])
    }
}