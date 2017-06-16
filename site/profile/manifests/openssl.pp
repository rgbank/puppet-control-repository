class profile::openssl {
  package { 'openssl':
    ensure => '1.0.1e-60.el7_3.1',
  }
}
