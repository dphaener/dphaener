define user::deployer(
    $uid,
    $group = "deploy",
  ) {
  
  user { $title:
    ensure     => present,
    uid        => $uid,
    gid        => $group,
    shell      => "/bin/bash",
    home       => "/home/${title}",
    managehome => true,
    require    => Group[$group],
  }
  
  # ssh_authorized_key { "${title}_deployer_key":
  #   ensure => present,
  #   key    => template("user/keys/deployer_rsa.pub"),
  #   type   => "ssh-rsa",
  #   user   => $title,
  # }

  file { "/home/${title}/.ssh":
    ensure  => directory,
    mode    => "600",
    owner   => $title,
    require => User[$title],
  }

  file { "/home/${title}/.ssh/authorized_keys":
    ensure  => present,
    content => template("user/ssh/authorized_keys"),
    mode    => "600",
    owner   => $title,
    require => File["/home/${title}/.ssh"],
  }
}