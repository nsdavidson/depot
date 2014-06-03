include_recipe "git"

package "ruby-devel"
package "mysql-devel"

chef_gem "hipchat"

include_recipe "passenger_apache2::mod_rails"
include_recipe "passenger_apache2"
include_recipe 'chef-sugar::default'

gem_package "bundler"

db_server = search(:node, "tags:*depot-db-server*").first

deploy_revision "/var/www/depot" do
  repo 'https://github.com/nsdavidson/depot.git'
  environment "RAILS_ENV" => "production"
  revision "HEAD"
  action :deploy
  migration_command "/usr/local/bin/bundle exec /usr/local/bin/rake db:create db:migrate db:seed RAILS_ENV=production"
  migrate true
  before_migrate do
    directory "/var/www/depot/shared/config" do
      recursive true
      owner "apache"
      group "apache"
      mode "0755"
      action :create
    end

    template "/var/www/depot/shared/config/database.yml" do
      source "database.yml.erb"
      owner "apache"
      group "apache"
      mode "0644"
      variables ({ :db_host => best_ip_for(db_server) })
    end

    execute "bundle_install" do
      cwd release_path
      command "/usr/local/bin/bundle install --without development test doc"
      action :run
    end
    
  end

  restart_command "service httpd restart"
end

directory "/var/www/depot/current/tmp/cache" do
  recursive true
  owner "apache"
  group "apache"
  mode "0777"
  action :create
end

web_app "depot" do
  docroot '/var/www/depot/current/public'
  template 'depot.conf.erb'

  server_name node[:fqdn]
  server_aliases [ "depot", node[:hostname] ]
  rails_env "production"
end