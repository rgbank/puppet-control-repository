class role::jira {
  include profile::jira
  include profile::java

  Class[profile::java] -> Class[profile::jira]
}
