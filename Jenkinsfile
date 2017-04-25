pipeline {
  agent { docker 'ruby:2.3' }

  stages {
    stage('Lint Control Repo') {
      steps {
        sh(script: '''
          bundle install
          bundle exec rake lint
        ''')
      }
    }

    stage('Syntax Check Control Repo'){
      steps {
        sh(script: '''
          bundle install
          bundle exec rake syntax --verbose
        ''')
      }
    }

    stage('Validate Puppetfile in Control Repo'){
      steps {
        sh(script: '''
          bundle install
          bundle exec rake r10k:syntax
        ''')
      }
    }

    stage("Promote To Environment"){
      steps {
        puppetCodeDeploy env.BRANCH_NAME, credentials: 'pe-access-token'
      }
    }

    stage("Release To DEV") {
      when { branch "production" }
      steps {
        puppetJob environment: 'production', query: 'facts { name = "appenv" and value = "dev"}', credentialsId: 'pe-access-token'
      }
    }

    stage("Release To QA"){
      when { branch "production" }
      steps {
        puppetJob environment: 'production', query: 'facts { name = "appenv" and value = "qa"}', credentialsId: 'pe-access-token'
      }
    }

    stage("Release To Production"){
      when { branch "production" }
      steps {
        input 'Ready to release to Production?'
        puppetJob environment: 'production', query: 'facts { name = "appenv" and value = "production"}', credentialsId: 'pe-access-token'
      }
    }

  }
}
