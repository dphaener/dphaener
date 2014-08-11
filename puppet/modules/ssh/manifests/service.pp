class ssh::service {
  service { 'ssh':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => Class["ssh::config"],
  }
}