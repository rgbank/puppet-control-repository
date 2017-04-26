class profile::artifactory {
  class { 'artifactory':
     serverAlias => [ 'artifactory', 'artifactory.inf.puppet.vm' ]
  }
}
