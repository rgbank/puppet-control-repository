class profile::jira {
  class { 'jira':
      javahome =>  '/opt/java',
  }

  class { 'jira::facts': }
}
