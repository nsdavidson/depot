include_recipe "nginx"
include_recipe "chef-sugar"

chef_gem "hipchat"

app_servers = search(:node, "tags:*depot-app-server*")
app_server_list = []
app_servers.each do |node|
  app_server_list << best_ip_for(node)
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

template "/etc/nginx/conf.d/default.conf" do
  source "default.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables ({ :app_servers => app_server_list })
  notifies :restart, "service[nginx]"
end

