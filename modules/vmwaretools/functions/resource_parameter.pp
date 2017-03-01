function vmwaretools::resource_parameter(
  $key,
  Hash[0, 0] $options, # does not take options
  Puppet::LookupContext $context
){

  $valid_keys = ['vmwaretools::service_name', 'vmwaretools::service_hasstatus', 'vmwaretools::package_name']

  if !($key in $valid_keys) {
    $context.not_found()
  } else {

    $tool_version = $context.interpolate("%{hiera('vmwaretools::tools_version')}")
    case $tool_version {
      /^3(\.+\d*)*/: {
        $service_name = $context.interpolate("%{hiera('vmwaretools::$service_name_4x')}")
        $service_hasstatus = $context.interpolate("%{hiera('vmwaretools::service_hasstatus_4x')}")
        $package_name = $context.interpolate("%{hiera('vmwaretools::package_name_4x')}")
        $repobasharch = $context.interpolate("%{hiera('vmwaretools::repobasearch_4x')}")
      }
      /^4(\.+\d*)*/: {
        $service_name = $context.interpolate("%{hiera('vmwaretools::service_name_4x')}")
        $service_hasstatus = $context.interpolate("%{hiera('vmwaretools::service_hasstatus_4x')}")
        $package_name = $context.interpolate("%{hiera('vmwaretools::package_name_4x')}")
        $repobasharch = $context.interpolate("%{hiera('vmwaretools::repobasearch_4x')}")
      }
      /^5(\.+\d*)*/: {
        $service_name = $context.interpolate("%{hiera('vmwaretools::service_name_5x')}")
        $service_hasstatus = $context.interpolate("%{hiera('vmwaretools::service_hasstatus_5x')}")
        $package_name = $context.interpolate("%{hiera('vmwaretools::package_name_5x')}")
        $repobasharch = $context.interpolate("%{hiera('vmwaretools::repobasearch_5x')}")
      }
      default: { #If no tools_version specified, assume latest
        $service_name = $context.interpolate("%{hiera('vmwaretools::service_name_5x')}")
        $service_hasstatus = $context.interpolate("%{hiera('vmwaretools::service_hasstatus_5x')}")
        $package_name = $context.interpolate("%{hiera('vmwaretools::package_name_5x')}")
        $repobasharch = $context.interpolate("%{hiera('vmwaretools::repobasearch_5x')}")
      }
    }

    $parameter_hash = {
      vmwaretools::service_name      => $service_name,
      vmwaretools::service_hasstatus => $service_hasstatus,
      vmwaretools::package_name      => $package_name
      vmwaretools::repobasearch      => $repobasearch,
    }

    $parameter_hash[$key]
  }
}
