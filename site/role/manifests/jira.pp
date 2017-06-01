class role::jira {
  include profile::jira
  include profile::java
  include profile::mysql::server

  Class[profile::java] -> Class[profile::jira]
}
