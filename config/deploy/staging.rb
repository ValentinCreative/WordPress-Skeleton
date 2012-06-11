set :domain, "staging.example.com"
set :aliases, %w()
server "", :app, :web, :db, :primary => true

set :wp_debug, true