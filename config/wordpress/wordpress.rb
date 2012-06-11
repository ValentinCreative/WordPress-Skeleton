require 'open-uri'
require 'capistrano/ext/set/helpers'

namespace :wordpress do
  desc "Setup WordPress"
  task :setup, :roles => :app do
    run "mkdir -p #{shared_path}/uploads && chgrp #{group} #{shared_path}/uploads && chmod 0770 #{shared_path}/uploads"
    run "mkdir -p #{shared_path}/config && chgrp #{group} #{shared_path}/config && chmod 0770 #{shared_path}/config"
    wordpress.config.generate
  end

  desc "Symlink WordPress uploads directory"
  task :symlink, :roles => :app do
    run "ln -nvfs #{shared_path}/uploads #{release_path}/public/content/uploads"
  end

  namespace :config do
    desc "Create WordPress config file"
    task :generate, :roles => :app do
      wp_secret_keys = open('https://api.wordpress.org/secret-key/1.1/salt/').read

      set :wp_db_name, prompt_with_default("Enter MySQL database name", "#{application}_#{stage}")
      set :wp_db_user, prompt_with_default("Enter MySQL user", "#{application}")
      set :wp_db_password, Capistrano::CLI.password_prompt("Enter MySQL password : ")

      file = File.join(File.dirname(__FILE__), "wp-config.php.erb")
      template = File.read(file)
      wp_config = ERB.new(template).result(binding)
      put wp_config, "#{shared_path}/config/wp-config.php", :mode => 0770
    end

    desc "Copy WordPress config file to current release"
    task :copy, :roles => :app do
      run "cp #{shared_path}/config/wp-config.php #{release_path}/public/wp-config.php"
    end
  end
end