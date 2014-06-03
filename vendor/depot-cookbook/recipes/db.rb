chef_gem "hipchat"

mysql_service 'default' do
   allow_remote_root true
   server_root_password node['mysql']['server_root_password']
   action :create
end
