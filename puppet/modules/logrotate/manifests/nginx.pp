define logrotate::nginx(
$app_directory,
$pid_file,
) {

    file { "/etc/logrotate.d/nginx":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        content => template('logrotate/nginx.erb'),
    }
}