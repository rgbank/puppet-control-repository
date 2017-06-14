class profile::docker {
  include docker

  group { 'docker':
    ensure => present,
  }
}
