class profile::jenkins {

  class { '::jenkins':
    configure_firewall => true,
  }

  #jenkins::job { "control-repo":
  #  ensure  => present,
  #  enabled => true,
  #  config  => epp('profile/jenkins_job_config.epp'),
  #}

  jenkins::plugin { 'puppet-enterprise-pipeline': }
  jenkins::plugin { 'build-pipeline-plugin': }
  jenkins::plugin { 'plain-credentials': }
  jenkins::plugin { 'workflow-basic-steps': }
  jenkins::plugin { 'workflow-aggregator': }
  jenkins::plugin { 'workflow-scm-step': }
  jenkins::plugin { 'workflow-support': }
  jenkins::plugin { 'workflow-api': }
  jenkins::plugin { 'scm-api': }
  jenkins::plugin { 'ace-editor': }
  jenkins::plugin { 'jquery-detached': }
  jenkins::plugin { 'script-security': }
  jenkins::plugin { 'workflow-cps': }
  jenkins::plugin { 'workflow-step-api': }
  jenkins::plugin { 'copyartifact': }
  jenkins::plugin { 'matrix-project': }

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
