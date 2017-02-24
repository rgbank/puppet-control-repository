# == Class: vmwaretools
#
# This class handles installing the VMware Tools Operating System Specific
# Packages.  http://packages.vmware.com/
#
# === Parameters:
#
# [*tools_version*]
#   The version of VMware Tools to install.  Possible values can be found here:
#   http://packages.vmware.com/tools/esx/index.html
#   Default: latest
#
# [*disable_tools_version*]
#   Whether to report the version of the tools back to vCenter/ESX.
#   Default: true (ie do not report)
#
# [*manage_repository*]
#   Whether to allow the repo to be manged by the module or out of band (ie
#   RHN Satellite/Pulp).
#   Default: true (ie let the module manage it)
#
# [*reposerver*]
#   The server which holds the software repository.  Customize this if you
#   mirror public repos to your internal network.
#   Default: http://packages.vmware.com
#
# [*repopath*]
#   The path on *reposerver* where the repository can be found.  Customize
#   this if you mirror public repos to your internal network.
#   Default: /tools
#
# [*just_prepend_repopath*]
#   Whether to prepend the overridden *repopath* onto the default *repopath*
#   or completely replace it.  Only works if *repopath* is specified.
#   Default: 0 (false)
#
# [*gpgkey_url*]
#   The URL where the public GPG key resides for the repository NOT including
#   the GPG public key file itself (ending with a trailing /).
#   Default: ${reposerver}${repopath}/
#
# [*priority*]
#   Give packages in this repository a different weight.  Requires
#   yum-plugin-priorities to be installed.
#   Default: 50
#
# [*protect*]
#   Protect packages in this YUM repository from being overridden by packages
#   in non-protected repositories.
#   Default: 0 (false)
#
# [*proxy*]
#   The URL to the proxy server for this repository.
#   Default: absent
#
# [*proxy_username*]
#   The username for the proxy.
#   Default: absent
#
# [*proxy_password*]
#   The password for the proxy.
#   Default: absent
#
# [*ensure*]
#   Ensure if present or absent.
#   Default: present
#
# [*autoupgrade*]
#   Upgrade package automatically, if there is a newer version.
#   Default: false
#
# [*package*]
#   Name of the package.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# [*service_ensure*]
#   Ensure if service is running or stopped.
#   Default: running
#
# [*service_name*]
#   Name of VMware Tools service
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# [*service_enable*]
#   Start service at boot.
#   Default: true
#
# [*service_hasstatus*]
#   Service has status command.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# [*service_hasrestart*]
#   Service has restart command.
#   Default: true
#
# [*scsi_timeout*]
#   This will adjust the scsi timout value set in udev rules.  This file is
#   created by the VMWare Tools installer.
#   Defualt: 180
#
# === Actions:
#
# Removes old VMwareTools package or runs vmware-uninstall-tools.pl if found.
# Installs a VMWare package repository.
# Installs the OSP.
# Starts the vmware-tools service.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#   class { 'vmwaretools':
#     tools_version => '4.0u3',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
# Geoff Davis <gadavis@ucsd.edu>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
# Copyright (C) 2012 The Regents of the University of California
#
class vmwaretools (
  String $tools_version,
  Boolean $disable_tools_version,
  Boolean $manage_repository,
  String $reposerver,
  String $repopath,
  Boolean $just_prepend_repopath,
  Integer $priority,
  Integer $protect,
  String $gpgkey_url,
  String $proxy,
  String $proxy_username,
  String $proxy_password,
  String $ensure,
  Boolean $autoupgrade,
  String $package_name,
  String $package_ensure,
  String $service_ensure,
  String $service_name,
  Boolean $service_enable,
  Boolean $service_hasstatus,
  Boolean $service_hasrestart,
  Integer $scsi_timeout,
  String $udevrefresh_command,
) {

  if $manage_repository {
    class { '::vmwaretools::repo':
      ensure                => $ensure,
      tools_version         => $tools_version,
      reposerver            => $real_reposerver,
      repopath              => $real_repopath,
      just_prepend_repopath => $just_prepend_repopath,
      gpgkey_url            => $gpgkey_url,
      priority              => $priority,
      protect               => $protect,
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

  file_line { 'disable-tools-version':
    path    => '/etc/vmware-tools/tools.conf',
    line    => $disable_tools_version ? {
      false   => 'disable-tools-version = "false"',
      default => 'disable-tools-version = "true"',
    },
    match   => '^disable-tools-version\s*=.*$',
    require => Package[$package_name],
    notify  => Service[$service_name],
  }

  service { $service_name:
    ensure     => $service_ensure,
    hasrestart => true,
    hasstatus  => true,
    start      => "/sbin/start ${service_name}",
    stop       => "/sbin/stop ${service_name}",
    status     => "/sbin/status ${service_name} | grep -q 'start/'",
    restart    => "/sbin/restart ${service_name}",
    require    => Package[$package_name],
  }
}
