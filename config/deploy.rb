set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, ""
set :port, 54321
set :user, ""
#set :group, ""

set :scm, :git

set :branch do
  default_tag = `git tag`.split("\n").last

  tag = Capistrano::CLI.ui.ask "Tag to deploy: [#{default_tag}] "
  tag = default_tag if tag.empty?
  tag
end

set :git_enable_submodules, 1
set :copy_exclude, [".git", ".gitignore", ".gitmodules", "Capfile", "config/deploy.rb"]
set :repository, "%%REPO%%"
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
#set :deploy_env, 'production' // From https://github.com/capistrano/capistrano/wiki/2.x-Multistage-Extension

set :use_sudo, false

default_run_options[:pty] = true
set :ssh_options, { :forward_agent => true }

server "#{application}", :app

namespace :shared do
  desc "setup shared folders"
  task :setup, :roles => :app do
    run "mkdir -p #{shared_path}/uploads && chmod g+w #{shared_path}/uploads"
  end

  desc "symlink shared folders"
  task :create_symlink, :roles => :app do
    run "ln -nvfs #{shared_path}/uploads #{release_path}/public/content/uploads"
  end
end

namespace :nginx do
  desc "setup nginx config"
  task :setup, :roles => :app do
    run "ln -nvfs /etc/nginx/sites-enabled/#{application} /etc/nginx/sites-available/#{application}"
  end

  desc "symlink nginx config"
  task :create_symlink, :roles => :app do
    run "ln -nvfs #{current_path}/config/nginx.conf /etc/nginx/sites-available/#{application}"
  end
end

after "deploy:setup", "shared:setup", "nginx:setup"
after "deploy:create_symlink", "shared:create_symlink", "nginx:create_symlink"
