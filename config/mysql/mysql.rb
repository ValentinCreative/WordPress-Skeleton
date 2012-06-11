namespace :mysql do
  desc "Setup MySQL database"
  task :setup, :once => true do
    sql = <<-END_SQL.gsub(/\n/, '').gsub(/\s+/, ' ').strip
      CREATE DATABASE IF NOT EXISTS #{wp_db_name};
      GRANT ALL ON #{wp_db_name}.* TO '#{wp_db_user}'@'localhost' IDENTIFIED BY '#{wp_db_password}';
      FLUSH PRIVILEGES;
      END_SQL
    mysqladmin = prompt_with_default("Enter MySQL root account", "root")
    run %Q(mysql -u#{mysqladmin} -p -e "#{sql}") do |channel, stream, data|
      if data =~ /Enter password/i
        #prompt, and then send the response to the remote process
        channel.send_data(Capistrano::CLI.password_prompt("Enter MySQL #{mysqladmin} password : ") + "\n")
      end
    end
  end
end
