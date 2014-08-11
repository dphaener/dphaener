# Set environment to development unless something else is specified
env = ENV["RAILS_ENV"] || "development"

# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.
worker_processes (env == "production" ? 8 : 4)

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
listen "/tmp/dphaener.socket", :backlog => 64

# Preload our app for more speed
preload_app true

# nuke workers after 300 seconds instead of 60 seconds (the default)
timeout 300

pid "/tmp/unicorn.dphaener.pid"

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
working_directory "/home/app/dphaener/current"

# feel free to point this anywhere accessible on the filesystem
user 'app', 'deploy'
shared_path = "/home/app/dphaener/shared"

stderr_path "#{shared_path}/log/unicorn.stderr.log"
stdout_path "#{shared_path}/log/unicorn.stdout.log"

before_fork do |server, worker|
  # the following is highly recommended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true",
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

  # when using a forking server (Unicorn, Resque, Pipemaster, etc)
  # you don’t want your forked processes using the same sequence number.
  # Make sure to increment the sequence number each time a worker forks.
  # UUID.generator.next_sequence

  # When in Unicorn, this block needs to go in unicorn's `after_fork` callback
  # (see https://github.com/mperham/sidekiq/wiki/Advanced-Options)
  # UPDATE: Per mperham, this is no longer required to be in after_fork
  # if env == "production"
  #   Sidekiq.configure_client do |config|
  #     config.redis = { :url => 'redis://10.34.102.101:6379', :namespace => 'drip' }
  #   end
  # end

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end

before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "/home/app/dphaener/current/Gemfile"
end