#
# Cookbook Name:: chef-jellyfish
# Recipe:: _postgresql
#
# Copyright (c) 2015 Kevin M Kingsbury, All Rights Reserved.


#exclude=postgresql*
#log "Platform version: " + node['platform_version'].to_f.to_s
if node.default['platform'] == 'centos'
 baseplat = ''
 case node['platform']
 when "redhat"
  baseplat = 'RHEL'
 when  "centos"
  baseplat = 'CentOS'
 end

 execute "add excludes base" do
  command "/bin/sed -i.bak 's/name=#{baseplat}-\$releasever - Base/name=#{baseplat}-\$releasever - Base\\\nexcludes=postgresql\*/' /etc/yum.repos.d/#{baseplat}-Base.repo"
  not_if "grep -A 6 '#{baseplat}-\$releasever - Base' /etc/yum.repos.d/#{baseplat}-Base.repo | grep 'postgresql\*'"
 end

 execute "add excludes updates" do
  command "/bin/sed -i.bak 's/name=v-\$releasever - Updates/name=#{baseplat}-\$releasever - Updates\\\nexcludes=postgresql\*/' /etc/yum.repos.d/#{baseplat}-Base.repo"
  not_if "grep -A 6 '#{baseplat}-\$releasever - Updates' /etc/yum.repos.d/#{baseplat}-Base.repo | grep 'postgresql\*' "
 end
end

#http://yum.postgresql.org/repopackages.php#pg94
#http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-1.noarch.rpm

# All this needs to be wrapped in a "If cent..."
pp "version: " +node['postgresql']['version'].to_s
platform_version = node['platform_version'].to_s.split(".")[0]
pp "Platform Version: " + platform_version
pp "platform: "+ node['platform'].to_s
pp "Machine: " + node['kernel']['machine'].to_s

ver = node['postgresql']['version'].to_s
plat = node['platform'].to_s
mach = node['kernel']['machine'].to_s

pname = node.default['postgresql']['pgdg']['repo_rpm_url'][ver][plat][platform_version][mach].split("/")[-1]
nodecimal = node['postgresql']['version'].to_s.sub '.', ''

# Install Repo:
pp "Here's the URl: " + node.default['postgresql']['pgdg']['repo_rpm_url'][ver][plat][platform_version][mach]

remote_file "#{Chef::Config[:file_cache_path]}/#{pname}" do
    source node.default['postgresql']['pgdg']['repo_rpm_url'][ver][plat][platform_version][mach]
    action :create
end

rpm_package "postgresqlrpm" do
    source "#{Chef::Config[:file_cache_path]}/#{pname}"
    action :install
end

#if install, initdb"
package 'postgresql'+nodecimal+'-server'

#other packages
package ['postgresql'+nodecimal+'-contrib', 'postgresql'+nodecimal+'-devel']

if (node['platform'] == 'redhat' || node['platform'] == 'centos') && node['platform_version'].to_f >= 7.0
  execute "psqlinitdb" do
    command "/usr/pgsql-9.4/bin/postgresql94-setup initdb"
    only_if do Dir['/var/lib/pgsql/'+ver+'/data/*'].empty? end
  end

  #/var/run/postgresql
else
  execute "psqlinitdb" do
    command "service postgresql-"+ver+" initdb"
    only_if do Dir['/var/lib/pgsql/'+ver+'/data/*'].empty? end
  end
end

#service postgresql-9.4 initdb
service "postgresql-"+ver do
  action [ 'enable', 'start']
end

execute "identipv4" do
  command "/bin/sed -i.bak 's/host\\(\\s*\\)all\\(\\s*\\)all\\(\\s*\\)127\\.0\\.0\\.1\\/32\\(\\s*\\)ident/host\\1all\\2all\\3127\\.0\\.0\\.1\\/32\\4md5/' /var/lib/pgsql/#{ver}/data/pg_hba.conf"
  only_if "grep 'host\s*all\s*all\s*127\.0\.0\.1\/32\s*ident' /var/lib/pgsql/#{ver}/data/pg_hba.conf"
  notifies :restart, "service[postgresql-#{ver}]", :immediate
end

execute "identipv6" do
  command "/bin/sed -i.bak 's/host\\(\\s*\\)all\\(\\s*\\)all\\(\\s*\\)\\:\\:1\\/128\\(\\s*\\)ident/host\\1all\\2all\\3::1\\/128\\4md5/' /var/lib/pgsql/#{ver}/data/pg_hba.conf"
  only_if "grep 'host\s*all\s*all\s*::1\/128\s*ident' /var/lib/pgsql/#{ver}/data/pg_hba.conf"
end

#service postgresql-9.4 restart
service "postgresql-"+ver do
  action [ 'restart']
end



#two commands: create user and alter is piggybacked
execute "create-database-user" do
    code = <<-EOH
    psql -c "select * from pg_user where usename='#{node.default['postgresql']['jellyfish_user']}'" | grep -c #{node.default['postgresql']['jellyfish_user']}
    EOH
    command "psql -c \"CREATE USER #{node.default['postgresql']['jellyfish_user']} WITH PASSWORD '#{node.default['postgresql']['jellyfish_dbpass']}';  ALTER USER #{node.default['postgresql']['jellyfish_user']} WITH SUPERUSER;\""
    not_if code, :user => 'postgres'
    user 'postgres'
end

#two commands: create db and grant user on the db is piggybacked
execute "create-database" do
    exists = <<-EOH
    psql -c "select * from pg_database WHERE datname='#{node.default['postgresql']['jellyfish_db']}'" | grep -c #{node.default['postgresql']['jellyfish_db']}
    EOH
    command "createdb  -O #{node.default['postgresql']['jellyfish_user']} -E utf8 -T template1 #{node.default['postgresql']['jellyfish_db']}; psql -c \"GRANT ALL PRIVILEGES ON DATABASE #{node.default['postgresql']['jellyfish_db']} to #{node.default['postgresql']['jellyfish_user']};\""
    not_if exists, :user => 'postgres'
    user 'postgres'
end
