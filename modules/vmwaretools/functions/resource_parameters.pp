function vmwaretools::resource_parameters(
  Hash[0, 0] $options, # does not take options
  Puppet::LookupContext $context
){

  case $::os['family'] {
    'RedHat': {
      case $::os[name] {
        'RedHat', 'CentOS', 'OEL', 'OracleLinux', 'Scientific': {
				
          case $::os[release][major] {
            '3', '4', '5', '6', '7': { }
            default: {
              notice "Your operating system ${os[name]} ${os[release][major]} is unsupported and will not have the VMware Tools OSP installed."
            }
          }
          $package_name_4x = 'vmware-tools-nox'
          # TODO: OSP 5.0+ rhel5 i386 also has vmware-tools-esx-kmods-PAE
          $package_name_5x = [
            'vmware-tools-esx-nox',
            'vmware-tools-esx-kmods',
          ]
          $service_name_4x = 'vmware-tools'
          $service_name_5x = 'vmware-tools-services'
          $service_hasstatus_4x = false
          $service_hasstatus_5x = true
        }
        default: {
          notice "Your operating system ${os[name]} is unsupported and will not have the VMware Tools OSP installed."
        }
      }
    }
    'Suse': {
      case $::os[name] {
        'SLES', 'SLED': {
          # TODO: tools 3.5 and 4.x use either sles11 or sles11sp1 while tools >=5 use sles11.1
          if ($::os[release][major] == '9') or  ($::os[release][major] == '11') {
            $distrelease = $::os[release][full]
          } else {
            $distrelease = $::os[release][major]
          }
          case $::os[release][major] {
            '9', '10', '11': {
              $supported = true
            }
            default: {
              notice "Your operating system ${os[name]} is unsupported and will not have the VMware Tools OSP installed."
            }
          }
          $package_name_4x = 'vmware-tools-nox'
          $package_name_5x = [
            'vmware-tools-esx-nox',
            'vmware-tools-esx-kmods-default',
          ]
          $service_name_4x = 'vmware-tools'
          $service_name_5x = 'vmware-tools-services'
          $service_hasstatus_4x = false
          $service_hasstatus_5x = true
          $repobasearch_4x = $::architecture ? {
            'i386'  => 'i586',
            default => $::architecture,
          }
          $repobasearch_5x = $::architecture ? {
            'i386'  => 'i586',
            default => $::architecture,
          }
        }
        default: {
          notice "Your operating system ${os[name]} is unsupported and will not have the VMware Tools OSP installed."
        }
      }
    }
    'Debian': {
      case $::os[name] {
        'Ubuntu': {
          case $::lsbdistcodename {
            'hardy', 'intrepid', 'jaunty', 'karmic', 'lucid', 'maverick', 'natty', 'oneric', 'precise': {
            }
            default: {
              $context.explain("Your operating system ${os[name]} is unsupported and will not have the VMware Tools OSP installed.")
              $context.not_found()
            }
          }
          $package_name_4x = 'vmware-tools-nox'
          $package_name_5x = [
            'vmware-tools-esx-nox',
            'vmware-tools-esx-kmods-3.8.0-29-generic',
          ]
          $service_name_4x = 'vmware-tools'
          $service_name_5x = 'vmware-tools-services'
          $service_hasstatus_4x = false
          $service_hasstatus_5x = true
        }
        default: {
          notice "Your operating system ${os[name]} is unsupported and will not have the VMware Tools OSP installed."
        }
      }
    }
    default: {
      notice "Your operating system ${os[name]} is unsupported and will not have the VMware Tools OSP installed."
    }
  }

  $tool_version = $context.interpolate("%{vmwaretools::tools_version}")
  case $tool_version {
    /^3\..+/: {
      $real_service_name = $service_name_4x
      $real_service_hasstatus = $service_hasstatus_4x
      $real_service_package_name = $package_name_4x
    }
    /^4\..+/: {
      $real_service_name = $service_name_4x
      $real_service_hasstatus = $service_hasstatus_4x
      $real_service_package_name = $package_name_4x
	  }
    /^5\..+/: {
      $real_service_name = $service_name_5x
      $real_service_hasstatus = $service_hasstatus_5x
      $real_service_package_name = $package_name_5x
    }
  }

  $return_hash = {
    vmwaretools::service_name => $real_service_name,
    vmwaretools::service_hasstatus => $real_service_hasstatus,
    vmwaretools::package_name => $real_package_name
  }

  $return_hash
}
