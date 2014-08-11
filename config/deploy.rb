# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'dphaener'
set :repo_url, 'git@github.com:dphaener/dphaener.git'
set :deploy_to, '/home/app/dphaener'
set :scm, :git

set :ssh_options, {
    :forward_agent => true
}

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.1.2'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, %w{web app job db sidekiq cron}

set :unicorn_pid, "/tmp/unicorn.dphaener.pid"
set :unicorn_rack_env, -> { fetch(:rails_env) }
set :unicorn_roles, :web

set :sidekiq_role, [:sidekiq]
set :whenever_roles, [:cron]

set :linked_files, %w{config/database.yml config/services.yml}

namespace :puppet do
  task :install do
    on roles(:all) do
      sudo :wget, "http://apt.puppetlabs.com/puppetlabs-release-precise.deb"
      sudo :dpkg, "-i", "puppetlabs-release-precise.deb"
      sudo :"apt-get", "update"
      sudo :"apt-get", "install", "-y", "puppet-common"
      execute :rm, "puppetlabs-release-precise.deb"
    end
  end

  task :upload do
    run_locally do
      execute :tar, "czf", "puppet.tgz", "puppet/"
    end

    on roles(:all) do
      upload! "puppet.tgz", "/tmp"

      within "/tmp" do
        execute :tar, "xzf", "/tmp/puppet.tgz"
        sudo :rm, "-rf", "/etc/puppet"
        sudo :mv, "/tmp/puppet/", "/etc/puppet"
      end
    end

    run_locally do
      execute :rm, "puppet.tgz"
    end
  end

  task :apply do
    on roles(:all) do
      sudo :puppet, "apply", "/etc/puppet/manifests/site.pp"
    end
  end

  task :upload_and_apply do
    invoke "puppet:upload"
    invoke "puppet:apply"
  end
end

namespace :ssl do
  task :upload do
    run_locally do
      within "config/deploy" do
        execute :tar, "czf", "certs.tgz", "certs/"
      end
    end

    on roles(:all) do
      upload! "config/deploy/certs.tgz", "/tmp"

      within "/tmp" do
        execute :tar, "xzf", "/tmp/certs.tgz"
        sudo :mv, "/tmp/certs/*", "/etc/ssl"
        sudo :rm, "-rf", "/tmp/certs"
      end
    end

    run_locally do
      execute :rm, "config/deploy/certs.tgz"
    end
  end
end

namespace :deploy do
  desc 'Start application'
  task :start do
    invoke 'unicorn:start'
  end

  desc 'Stop application'
  task :stop do
    invoke 'unicorn:stop'
  end

  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
  end

  after :publishing, :restart

  namespace :db do
    desc "Update the database.yml file"
    task :setup do
      on roles(:all) do
        file = File.join("config", "deploy", "config", "database.yml")
        execute :mkdir, "-p", "#{shared_path}/config"
        upload! file, "#{shared_path}/config/database.yml"
      end
    end
  end

  namespace :services do
    desc "Update the services.yml file"
    task :setup do
      on roles(:all) do
        file = File.join("config", "deploy", "config", "services.yml")
        execute :mkdir, "-p", "#{shared_path}/config"
        upload! file, "#{shared_path}/config/services.yml"
      end
    end
  end

  desc 'Upload config files'
  task :setup do
    invoke 'deploy:db:setup'
    invoke 'deploy:services:setup'
  end
end
