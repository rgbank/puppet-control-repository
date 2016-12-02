class profile::gitlab {
  include profile::firewall
  
  firewall { '100 allow https':
    proto  => 'tcp',
    dport  => '443',
    action => 'accept',
  }

  class { 'gitlab':
    external_url => 'http://gitlab.inf.puppet.vm',
  }
}
