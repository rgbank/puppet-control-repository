class profile::jira(
  $dbuser,
  $dbpass,
) {
  class { 'jira':
    javahome   => '/usr/lib/jvm/jre/',
    db         => 'mysql',
    dbuser     => $dbuser,
    dbpassword => $dbpass,
    dbtype     => 'mysql',
  }

  class { 'jira::facts': }

  mysql::db { 'jira':
    user     => $dbuser,
    password => $dbpass,
    host     => 'localhost',
  }
}
