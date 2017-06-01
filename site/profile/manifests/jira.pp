class profile::jira(
  $dbuser,
  $dbpass,
) {
  class { 'jira':
    javahome   => '/usr/lib/jvm/jre/',
    db         => 'mysql',
    dbuser     => $dbuser,
    dbpassword => $dbpass,
  }

  class { 'jira::facts': }
  class { 'jira::mysql_connector': }

  mysql::db { 'jira':
    user     => $dbuser,
    password => $dbpass,
    host     => 'localhost',
  }
}
