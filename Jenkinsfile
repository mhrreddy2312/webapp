pipeline {
  agent any
  tools {

    maven 'M2_HOME'

  }
  stages {

    stage('Checkout SCM') {
      steps {
        checkout([$class: 'GitSCM', branches: [
          [name: '*/master']
        ], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [
          [url: 'https://github.com/mhrreddy2312/java_cicd.git']
        ]])

      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('sonar') {

          sh 'mvn clean install sonar:sonar    -Dsonar.projectKey=SampleProject1    -Dsonar.host.url=http://34.254.170.95:9000    -Dsonar.login=c6ec44dc2d48ef6163084f856587ea1bda76fa72'

        }
      }
    }

    stage('Build') {
      steps {

        sh "mvn package"
      }

    }

    stage('Release to aws') {

      steps {
        sh "pwd"
        withAWS(region: 'eu-west-1', credentials: 'aws-s3') {
          s3Upload(bucket: "ramanjulareddy", workingDir: 'webapp', includePathPattern: '**/*.war'); // pick your jar or whatever you need
          sh "pwd"
        }
      }
    }

    stage('Buid and Push Image') {

      steps {
        sshagent(['sshkey']) {

          sh "ssh -o StrictHostKeyChecking=no ec2-user@3.248.219.89 -C \"sudo ansible-playbook docker-playbook.yml\""
        }
      }

    }

    stage('Waiting for Approvals') {

      steps {

        input('Test Completed ? Please provide  Approvals for Prod Release ?')
      }

    }

    stage('Deploy to K8s') {

      steps {
        sshagent(['sshkey']) {

          sh "ssh -o StrictHostKeyChecking=no ec2-user@3.248.219.89 -C \"sudo anisble-playbook k8s-playbook.yaml\""
        }
      }

    }

  }
}
