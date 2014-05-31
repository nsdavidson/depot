include_recipe "git"
include_recipe "build-essential"

package "mysql-devel"

db_server = search(:node, "tags:*depot-db-server*").first

application "depot" do
  path '/var/www/depot'
  repository 'git://github.com/nsdavidson/depot.git'

  rails do
    bundler true
    database do
      database "depot"
      username "depot"
      password "depot!"
      host db_server
    end
  end

  unicorn
end