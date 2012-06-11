require 'capistrano/ext/set/helpers'

set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

def prompt_with_default(prompt, default)
  value = Capistrano::CLI.ui.ask("#{prompt} [#{default}] : ")
  value = default if value.to_s.empty?
  return value
end

load 'config/wordpress/wordpress'
load 'config/nginx/nginx'
load 'config/mysql/mysql'

set :application, "example"
set :port, 54321
set :user, "deploy"
set :group, "www-data"
set :use_sudo, false

default_run_options[:pty] = true
set :ssh_options, { :forward_agent => true }

set :scm, :git

set :branch do
  default_tag = `git tag`.split("\n").last
  default_tag = "master" if default_tag.nil?

  prompt_with_default("Tag to deploy", "#{default_tag}")
end

set :repository, "git://github.com/user/#{application}.git"
set :git_enable_submodules, 1
set :copy_exclude, [".git", ".gitignore", ".gitmodules", "Capfile", "config/deploy.rb", "config/deploy"]
set(:deploy_to) { "/var/www/#{domain}" } # defer the variable setting, see http://stackoverflow.com/q/4137493/13601
set :deploy_via, :remote_cache

set :keep_releases, 5

after "deploy:setup", "wordpress:setup", "mysql:setup", "nginx:setup"
after "deploy:symlink", "wordpress:config:copy", "wordpress:symlink", "nginx:enable"
after "deploy:update", "deploy:cleanup"