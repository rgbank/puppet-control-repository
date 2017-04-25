properties([gitLabConnection('gitlab.inf.puppet.vm'), disableConcurrentBuilds()])
puppet.credentials 'pe-access-token'

node {
  dir('rbenv') {
    git url: 'https://github.com/sstephenson/rbenv.git'
  }

  dir('ruby-build') {
    git url: 'https://github.com/rbenv/ruby-build.git'
  }

  dir('control-repo') {
    git url: 'http://gitlab.inf.puppet.vm/rgbank/pmm-puppet-site.git', branch: env.BRANCH_NAME, credentialsId: 'casey-gitlab-credentials'

    stage('Lint Control Repo'){
      withEnv(['PATH+EXTRA=/usr/local/bin:../rbenv/bin:../ruby-build/bin']) {
        ansiColor('xterm') {
          sh(script: '''
            rbenv install 2.3.1
            rbenv global 2.3.1
            eval "$(rbenv init -)"
            bundle install
            bundle exec rake lint
          ''')
        }
      }
    }

    stage('Syntax Check Control Repo'){
      withEnv(['PATH+EXTRA=/usr/local/bin']) {
        ansiColor('xterm') {
          sh(script: '''
            rbenv install 2.3.1
            rbenv global 2.3.1
            eval "$(rbenv init -)"
            bundle install
            bundle exec rake syntax --verbose
          ''')
        }
      }
    }

    stage('Validate Puppetfile in Control Repo'){
      withEnv(['PATH+EXTRA=/usr/local/bin']) {
        ansiColor('xterm') {
          sh(script: '''
            rbenv install 2.3.1
            rbenv global 2.3.1
            eval "$(rbenv init -)"
            bundle install
            bundle exec rake r10k:syntax
          ''')
        }
      }
    }

    stage("Promote To Environment"){
      puppet.codeDeploy env.BRANCH_NAME
    }
  }

  if (env.BRANCH_NAME == 'production'){

    stage("Release To DEV"){
      puppet.job 'production', query: 'facts { name = "appenv" and value = "dev"}'
    }

    stage("Release To QA"){
      puppet.job 'production', query: 'facts { name = "appenv" and value = "qa"}'
    }

    stage("Release To Production"){
      input 'Ready to release to Production'
      puppet.job 'production', query: 'facts { name = "appenv" and value = "production"}'
    }

  }
}
