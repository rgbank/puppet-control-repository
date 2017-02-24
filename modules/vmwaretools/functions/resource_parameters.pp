function vmwaretools::resource_parameters(
  Hash[0, 0] $options, # does not take options
  Puppet::LookupContext $context
){

  $tool_version = $context.interpolate("%{vmwaretools::tools_version}")
  case $tool_version {
    /^3\..+/: {
      $real_service_name = $context.interpolate("%{vmwaretools::$service_name_4x}")
      $real_service_hasstatus = $context.interpolate("%{service_hasstatus_4x}")
      $real_service_package_name = $context.interpolate("%{package_name_4x}")
    }
    /^4\..+/: {
      $real_service_name = $service_name_4x
      $real_service_hasstatus = $context.interpolate("%{service_hasstatus_4x}")
      $real_service_package_name = $context.interpolate("%{package_name_4x}")
	  }
    /^5\..+/: {
      $real_service_name = $context.interpolate("%{service_name_5x}")
      $real_service_hasstatus = $context.interpolate("%{service_hasstatus_5x}")
      $real_service_package_name = $context.interpolate("%{package_name_5x}")
    }
  }

  $return_hash = {
    vmwaretools::service_name => $real_service_name,
    vmwaretools::service_hasstatus => $real_service_hasstatus,
    vmwaretools::package_name => $real_package_name
  }

  $return_hash
}
