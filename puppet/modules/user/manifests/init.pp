class user {
  group { 'deploy':
    ensure => present,
  }
}