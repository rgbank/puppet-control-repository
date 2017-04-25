pipeline {
  agent { docker 'ruby:2.3' }

  dir('control-repo') {
    git url: 'http://gitlab.inf.puppet.vm/rgbank/pmm-puppet-site.git', branch: env.BRANCH_NAME, credentialsId: 'casey-gitlab-credentials'

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
        sh(script: '''
          bundle install
          bundle exec rake r10k:syntax
        ''')
      }
    }

    stage("Promote To Environment"){
      puppet.codeDeploy env.BRANCH_NAME, credentials: 'pe-access-token'
    }

    stage("Release To DEV") {
      when { branch "production" }
      steps {
        puppet.job 'production', query: 'facts { name = "appenv" and value = "dev"}', credentials: 'pe-access-token'
      }
    }

    stage("Release To QA"){
      when { branch "production" }
      steps {
        puppet.job 'production', query: 'facts { name = "appenv" and value = "qa"}', credentials: 'pe-access-token'
      }
    }

    stage("Release To Production"){
      when { branch "production" }
      steps {
        input 'Ready to release to Production?'
        puppet.job 'production', query: 'facts { name = "appenv" and value = "production"}', credentials: 'pe-access-token'
      }
    }

  }
}

