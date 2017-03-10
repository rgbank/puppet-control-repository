class vmwaretools::repo (
  $tools_version,
  $reposerver,
  $repopath,
  $just_prepend_repopath,
  $priority,
  $protect,
  $gpgkey_url,
  $proxy,
  $proxy_username,
  $proxy_password,
  $ensure,
  $repobasearch,
) {
  # Validate our booleans
  validate_bool($just_prepend_repopath)

  case $ensure {
    /(present)/: {
      $repo_enabled = '1'
    }
    /(absent)/: {
      $repo_enabled = '0'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  # We use $::operatingsystem and not $::osfamily because certain things
  # (like Fedora) need to be excluded.
  case $::operatingsystem {
    'RedHat', 'CentOS', 'Scientific', 'OracleLinux', 'OEL': {
      if ( $just_prepend_repopath == true ) {
        $baseurl_url = "${reposerver}${repopath}/esx/${tools_version}/${vmwaretools::params::baseurl_string}${vmwaretools::params::majdistrelease}/${repobasearch}/"
      } else {
        $baseurl_url = "${reposerver}${repopath}/"
      }

      yumrepo { 'vmware-tools':
        descr          => "VMware Tools ${tools_version} - ${vmwaretools::params::baseurl_string}${vmwaretools::params::majdistrelease} ${repobasearch}",
        enabled        => $repo_enabled,
        gpgcheck       => '1',
        gpgkey         => $gpgkey_url,
        baseurl        => $baseurl_url,
        priority       => $priority,
        protect        => $protect,
        proxy          => $proxy,
        proxy_username => $proxy_username,
        proxy_password => $proxy_password,
      }

      # Deal with the people who wipe /etc/yum.repos.d .
      file { '/etc/yum.repos.d/vmware-tools.repo':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
      }
    }
    'SLES', 'SLED': {
      if ( $repopath == $repopath ) or ( $just_prepend_repopath == true ) {
        $baseurl_url = "${reposerver}${repopath}/esx/${tools_version}/${vmwaretools::params::baseurl_string}${vmwaretools::params::distrelease}/${repobasearch}/"
      } else {
        $baseurl_url = "${reposerver}${repopath}/"
      }

      zypprepo { 'vmware-tools':
        descr       => "VMware Tools ${tools_version} - ${vmwaretools::params::baseurl_string}${vmwaretools::params::distrelease} ${repobasearch}",
        enabled     => $repo_enabled,
        gpgcheck    => '1',
        gpgkey      => $gpgkey_url,
        baseurl     => $baseurl_url,
        priority    => $priority,
        autorefresh => 1,
        notify      => Exec['vmware-import-gpgkey'],
      }

      file { '/etc/zypp/repos.d/vmware-tools.repo':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
      }

      exec { 'vmware-import-gpgkey':
        path        => '/bin:/usr/bin:/sbin:/usr/sbin',
        command     => "rpm --import ${gpgkey}",
        refreshonly => true,
      }
    }
    'Ubuntu': {
      if ( $repopath == $vmwaretools::params::repopath ) or ( $just_prepend_repopath == true ) {
        $baseurl_url = "${reposerver}${repopath}/esx/${tools_version}/${vmwaretools::params::baseurl_string}"
      } else {
        $baseurl_url = "${reposerver}${repopath}/"
      }

      include '::apt'
      apt::source { 'vmware-tools':
        ensure     => $ensure,
        comment    => "VMware Tools ${tools_version} - ${vmwaretools::params::baseurl_string} ${::lsbdistcodename}",
        location   => $baseurl_url,
        key_source => $gpgkey,
        #key        => '0xC0B5E0AB66FD4949',
        key        => '36E47E1CC4DCC5E8152D115CC0B5E0AB66FD4949',
      }
    }
    default: { }
  }
}
