include_recipe "git"

package "ruby-devel"
package "mysql-devel"

include_recipe "passenger_apache2::mod_rails"
include_recipe "passenger_apache2"
include_recipe 'chef-sugar::default'


db_server = search(:node, "tags:*depot-db-server*").first



deploy_revision "/var/www/depot" do
  repo 'https://github.com/nsdavidson/depot.git'
  environment "RAILS_ENV" => "production"
  revision "HEAD"
  action :deploy
  migration_command "rake db:migrate"
  migrate true
  before_migrate do
    directory "/var/www/depot/shared/config" do
      recursive true
      owner "root"
      group "root"
      mode "0755"
      action :create
    end

    template "/var/www/depot/shared/config/database.yml" do
      source "database.yml.erb"
      owner "root"
      group "root"
      mode "0644"
      variables ({ :db_host => best_ip_for(db_server) })
    end

    execute "bundle_install" do
      cwd release_path
      command "bundle install --without development test doc"
      creates "/tmp/something"
      action :run
    end
    
  end

  restart_command "service httpd restart"
end


web_app "depot" do
  docroot '/var/www/depot'
  cookbook "passenger"

  server_name node[:fqdn]
  rails_env "production"
end