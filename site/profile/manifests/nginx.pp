class profile::nginx {
  class { 'php': 
    composer => false,
  }
  class { 'nginx': 
    names_hash_bucket_size => 128,
  }

  Class['php'] -> Class['nginx']
}
