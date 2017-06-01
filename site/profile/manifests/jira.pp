class profile::jira(
  $dbuser,
  $dbpass,
) {
  class { 'jira':
    javahome   => '/usr/lib/jvm/jre/',
    db         => 'mysql',
    dbname     => 'jira',
    dbport     => '3306',
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
