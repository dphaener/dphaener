class nginx::config {
  
  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Class["nginx::service"],
  }
  
  file { "/etc/nginx":
    ensure => directory,
  }
  
  file { "/etc/nginx/includes":
    ensure => directory,
    mode   => '0644',
  }
  
  file { "/etc/nginx/conf.d":
    ensure => directory,
  }
  
  file { "/etc/nginx/nginx.conf":
    ensure  => present,
    content => template('nginx/nginx.conf.erb'),
  }
  
  file { "/etc/nginx/mime.types":
    ensure  => present,
    content => template('nginx/mime.types.erb'),
  }
}