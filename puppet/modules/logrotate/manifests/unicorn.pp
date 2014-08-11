define logrotate::unicorn(
    $app_directory,
    $pid_file,
  ) {

	file { "/etc/logrotate.d/${name}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    content => template('logrotate/unicorn.erb'),
  }
}