class profile::jira(
  $dbuser,
  $dbpass,
) {
  class { 'jira':
    javahome   => '/usr/lib/jvm/jre/',
    db         => 'mysql',
    dbuser     => $dbuser,
    dbpassword => $dbpass,
    dbdriver   => 'com.mysql.jdbc.Driver',
    dbtype     => 'mysql',
  }

  class { 'jira::facts': }

  mysql::db { 'jira':
    user     => $dbuser,
    password => $dbpass,
    host     => 'localhost',
    grant    => ['ALL'],
  }
}
