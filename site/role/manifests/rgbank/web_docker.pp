class role::rgbank::web_docker {
  include profile::openssl
  include rgbank::web::docker::image
}
