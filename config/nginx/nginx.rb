namespace :nginx do
  desc "Setup nginx"
  task :setup, :roles => :app do
    run "mkdir -p #{shared_path}/log && chgrp #{group} #{shared_path}/log && chmod 0770 #{shared_path}/log"
    nginx.config
    run "ln -nvfs #{shared_path}/config/nginx.conf /etc/nginx/sites-available/#{domain}"
  end

  desc "Enable site"
  task :enable, :roles => :app do
    run "ln -nvfs /etc/nginx/sites-available/#{domain} /etc/nginx/sites-enabled/#{domain}"
  end

  desc "Disable site"
  task :disable, :roles => :app do
    run "rm /etc/nginx/sites-enabled/#{domain}"
  end

  desc "Reload config"
  task :reload, :roles => :app do
    run "/etc/init.d/nginx reload"
  end

  desc "Create nginx config"
  task :config, :roles => :app do
    file = File.join(File.dirname(__FILE__), "nginx.conf.erb")
    template = File.read(file)
    nginx_conf = ERB.new(template, nil, '-').result(binding)
    put nginx_conf, "#{shared_path}/config/nginx.conf", :mode => 0770
  end
end