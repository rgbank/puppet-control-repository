class profile::jira(
  $dbuser,
  $dbpass,
) {
  class { 'jira':
    javahome   => '/usr/lib/jvm/jre/',
    db         => 'postgresql',
    dbname     => 'jira',
    dbport     => '5432',
    dbuser     => $dbuser,
    dbpassword => $dbpass,
    dbdriver   => 'org.postgresql.Driver',
    dbtype     => 'postgres72',
  }

  class { 'jira::facts': }

  postgresql::server::db { 'jira':
    user     => $dbuser,
    password => postgresql_password($dbuser, $dbpass),
  }
}
