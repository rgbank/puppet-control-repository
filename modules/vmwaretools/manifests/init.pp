class vmwaretools (
  String  $tools_version,
  Boolean $disable_tools_version,
  Boolean $manage_repository,
  String  $reposerver,
  String  $repopath,
  Boolean $just_prepend_repopath,
  Integer $repopriority,
  Integer $repoprotect,
  String  $gpgkey_url,
  String  $proxy,
  String  $proxy_username,
  String  $proxy_password,
  String  $ensure,
  String  $package_ensure,
  String  $service_ensure,
  Boolean $service_enable,
  Boolean $service_hasstatus,
  Boolean $service_hasrestart,
  Integer $scsi_timeout,
  String  $udevrefresh_command,
  Variant[String,Undef] $service_name,
  Variant[String,Undef] $package_name,
) {

  if $manage_repository {
    class { '::vmwaretools::repo':
      ensure                => $ensure,
      tools_version         => $tools_version,
      reposerver            => $reposerver,
      repopath              => $repopath,
      just_prepend_repopath => $just_prepend_repopath,
      gpgkey_url            => $gpgkey_url,
      priority              => $priority,
      protect               => $repoprotect,
      proxy                 => $proxy,
      proxy_username        => $proxy_username,
      proxy_password        => $proxy_password,
      before                => Package[$package_name],
    }
  }

  package { 'VMwareTools':
    ensure => 'absent',
    before => Package[$package_name],
  }

  exec { 'vmware-uninstall-tools':
    command => '/usr/bin/vmware-uninstall-tools.pl && rm -rf /usr/lib/vmware-tools',
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    onlyif  => 'test -f /usr/bin/vmware-uninstall-tools.pl',
    before  => [ Package[$package_name], Package['VMwareTools'], ],
  }

  # TODO: remove Exec["vmware-uninstall-tools-local"]?
  exec { 'vmware-uninstall-tools-local':
    command => '/usr/local/bin/vmware-uninstall-tools.pl && rm -rf /usr/local/lib/vmware-tools',
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    onlyif  => 'test -f /usr/local/bin/vmware-uninstall-tools.pl',
    before  => [ Package[$package_name], Package['VMwareTools'], ],
  }

  package { $package_name:
    ensure  => $package_ensure,
  }

  file { '/etc/udev/rules.d/99-vmware-scsi-udev.rules':
    ensure  => present,
    content => template('vmwaretools/udev-rules.erb'),
    require => Package[$package_name],
    notify  => Exec['udevrefresh'],
  }

  exec { 'udevrefresh':
    refreshonly => true,
    command     => $udevrefresh_command,
  }

  if $service_name {
    service { $service_name:
      ensure     => $service_ensure,
      hasrestart => $service_hasrestart,
      hasstatus  => $service_hasstatus,
      start      => "/sbin/start ${service_name}",
      stop       => "/sbin/stop ${service_name}",
      status     => "/sbin/status ${service_name} | grep -q 'start/'",
      restart    => "/sbin/restart ${service_name}",
      require    => Package[$package_name],
    }
  }
}
