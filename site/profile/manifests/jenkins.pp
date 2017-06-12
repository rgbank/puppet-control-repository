class profile::jenkins {

  class { '::jenkins':
    configure_firewall => true,
  }

  #jenkins::job { "control-repo":
  #  ensure                                               => present,
  #  enabled                                              => true,
  #  config                                               => epp('profile/jenkins_job_config.epp'),
  #}

  jenkins::plugin { 'workflow-scm-step': }
  jenkins::plugin { 'workflow-step-api': }
  jenkins::plugin { 'workflow-support': }
  jenkins::plugin { 'ace-editor': }
  jenkins::plugin { 'bouncycastle-api': }
  jenkins::plugin { 'display-url-api': }
  jenkins::plugin { 'durable-task': }
  jenkins::plugin { 'jquery-detached': }
  jenkins::plugin { 'mailer': }
  jenkins::plugin { 'scm-api': }
  jenkins::plugin { 'script-security': version => '1.28', }
  jenkins::plugin { 'plain-credentials': version => '1.4', }
  jenkins::plugin { 'structs': version => '1.7', }
  jenkins::plugin { 'workflow-api': version => '2.17', }
  jenkins::plugin { 'workflow-basic-steps': version => '2.5', }
  jenkins::plugin { 'workflow-cps': version  => '2.17', }
  jenkins::plugin { 'workflow-durable-task-step': version =>  '2.4', }
  jenkins::plugin { 'copyartifact': }
  jenkins::plugin { 'matrix-project': }
  jenkins::plugin { 'git': }
  jenkins::plugin { 'ssh-agent': }
  jenkins::plugin { 'puppet-enterprise-pipeline': }

  file {'/var/www/html/builds':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => Class['jenkins'],
  }

  file {'/var/www/html/builds/rgbank':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => Class['jenkins'],
  }
}
