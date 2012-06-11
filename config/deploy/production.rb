set :domain, "example.com"
set :aliases, %w(www.example.com)
server "", :app, :web, :db, :primary => true