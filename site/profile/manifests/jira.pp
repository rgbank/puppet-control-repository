class profile::jira {
  class { 'jira':
      javahome =>  '/usr/lib/jvm/jre/',
  }

  class { 'jira::facts': }
}
