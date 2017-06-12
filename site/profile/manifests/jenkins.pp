class profile::jenkins {

  class { '::jenkins':
    configure_firewall => true,
  }

  jenkins::plugin { 'workflow-scm-step': }
  jenkins::plugin { 'workflow-step-api': }
  jenkins::plugin { 'workflow-support': }
  jenkins::plugin { 'workflow-cps': }
  jenkins::plugin { 'workflow-durable-task-step': }
  jenkins::plugin { 'workflow-api': }
  jenkins::plugin { 'workflow-basic-steps': }
  jenkins::plugin { 'ace-editor': }
  jenkins::plugin { 'bouncycastle-api': }
  jenkins::plugin { 'display-url-api': }
  jenkins::plugin { 'durable-task': }
  jenkins::plugin { 'jquery-detached': }
  jenkins::plugin { 'mailer': }
  jenkins::plugin { 'scm-api': }
  jenkins::plugin { 'script-security': }
  jenkins::plugin { 'plain-credentials': }
  jenkins::plugin { 'structs': }
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
