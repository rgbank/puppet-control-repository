class role::rgbank::web(
  $use_puppetconf_header = false
) {
  include profile::openssl
  include profile::common
  include profile::apache::remove
  include profile::nginx
  include profile::mysql::client
  include profile::git
  
  Class['profile::common'] -> Class['profile::nginx']
  Class['profile::apache::remove'] -> Class['profile::nginx']
}
