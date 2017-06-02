class role::rgbank::web(
  $use_puppetconf_header = false
) {
  include rgbank::web::docker::image
}
