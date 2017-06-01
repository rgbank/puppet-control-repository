class role::jira {
  include profile::jira
  include profile::java
  include profile::postgresql::server

  Class[profile::java] -> Class[profile::jira]
  Class[profile::postgresql::server] -> Class[profile::jira]
}
