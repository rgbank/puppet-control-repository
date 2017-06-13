class profile::artifactory {
  class { 'artifactory':
     ajp_port => 8081,
  }
}
