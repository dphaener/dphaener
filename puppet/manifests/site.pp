class app_server {
  include ssh, git, user, nginx
  
  $ruby_version = "2.1.2"
  
  # Create the app deployment user
  user::deployer { "app":
    uid => "1001",
  }
  
  # Create the app deployment directory
  deploy::directory { "/home/app/dphaener":
    owner   => "app",
    group   => "deploy",
  }
  
  # Install rbenv in the home directory
  rbenv::install { "app":
    group => "deploy",
  }
  
  # Compile and install the desired ruby version
  rbenv::compile { $ruby_version:
    user  => "app",
    group => "deploy",
  }
  
  # Set the local ruby version for the app user
  file { "/home/app/.ruby-version":
    ensure  => present,
    content => $ruby_version,
    owner   => "app",
    group   => "deploy",
    mode    => "640",
    require => Rbenv::Compile[$ruby_version],
  }
  
  # Install postgres
  package { "postgresql":
    ensure => present,
  }
  
  package { "libpq-dev":
    ensure  => present,
    require => Package["postgresql"],
  }
  
  # Install and run redis
  class { "redis":
    version => "2.6.11",
  }

  # Install FreeTDS
  package { "freetds-dev":
    ensure => present,
  }

  # Install node.js
  package { "nodejs":
    ensure => present,
  }

  # Rotate logs
  logrotate::unicorn { "dphaener":
    app_directory => "/home/app/dphaener/current",
    pid_file => "/tmp/unicorn.dphaener.pid",
  }

  logrotate::nginx { "dphaener":
    app_directory => "/home/app/dphaener/current",
    pid_file => "/run/nginx.pid"
  }

  cron { 'restart nginx':
    name => "restart_nginx",
    ensure => present,
    command => "/bin/check_restart.sh",
    user => "root",
    minute => "*/5"
  }
}

node default {
  include app_server

  file { "/etc/nginx/conf.d/dphaener.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("nginx/conf.d/production.erb"),
    notify  => Class["nginx::service"],
  }
}