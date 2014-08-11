define deploy::directory(
    $owner,
    $group,
  ) {
  
  $dirs = [ 
    "${title}", 
    "${title}/releases", 
    "${title}/shared",
    "${title}/shared/log"
  ]

  file { $dirs:
    ensure  => directory,
    recurse => false,
    purge   => false,
    owner   => $owner,
    group   => $group,
    mode    => '755',
  }
}