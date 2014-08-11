set :ssh_options, {
    :forward_agent => true,
    :keys => %W{
    #{ENV['HOME']}/.ssh/id_rsa
  }
}

server '192.241.227.64', user: "root", roles: %w{system}, no_release: true