#
# Cookbook Name:: chef-jellyfish
# Recipe:: _postgresql
#
# Copyright (c) 2015 Booz Allen Hamilton, All Rights Reserved.
if node.default['platform'] == 'centos'
  baseplat = ''
  case node['platform']
  when 'redhat'
    baseplat = 'RHEL'
  when  'centos'
    baseplat = 'CentOS'
  end

  # exclude=postgresql* to base and updates
  execute 'add excludes base' do
    command "sed -i.bak 's/name=#{baseplat}-\$releasever - Base/name=#{baseplat}-\$releasever - Base\\\nexcludes=postgresql\*/' /etc/yum.repos.d/#{baseplat}-Base.repo"
    not_if "grep -A 6 '#{baseplat}-\$releasever - Base' /etc/yum.repos.d/#{baseplat}-Base.repo | grep 'postgresql\*'"
  end

  execute 'add excludes updates' do
    command "/bin/sed -i.bak 's/name=v-\$releasever - Updates/name=#{baseplat}-\$releasever - Updates\\\nexcludes=postgresql\*/' /etc/yum.repos.d/#{baseplat}-Base.repo"
    not_if "grep -A 6 '#{baseplat}-\$releasever - Updates' /etc/yum.repos.d/#{baseplat}-Base.repo | grep 'postgresql\*' "
  end
end

# Substitute in our vars to get the Repo from the Config Array..."
pp "version: #{node['postgresql']['version']}"
platform_version = node['platform_version'].to_s.split('.')[0]
pp "Platform Version: #{platform_version}"
pp "platform: #{node['platform']}"
pp "Machine: #{node['kernel']['machine']}"

ver = node['postgresql']['version'].to_s
plat = node['platform'].to_s
mach = node['kernel']['machine'].to_s

pname = node.default['postgresql']['pgdg']['repo_rpm_url'][ver][plat][platform_version][mach].split('/')[-1]
nodecimal = node['postgresql']['version'].to_s.sub '.', ''

# Install Repo:
pp "Here's the URl: " + node.default['postgresql']['pgdg']['repo_rpm_url'][ver][plat][platform_version][mach]

remote_file "#{Chef::Config[:file_cache_path]}/#{pname}" do
  source node.default['postgresql']['pgdg']['repo_rpm_url'][ver][plat][platform_version][mach]
  action :create
end

rpm_package 'postgresqlrpm' do
  source "#{Chef::Config[:file_cache_path]}/#{pname}"
  action :install
end

package "postgresql#{nodecimal}-server"

# other packages
package ["postgresql#{nodecimal}-contrib", "postgresql#{nodecimal}-devel"]

if (node['platform'] == 'redhat' || node['platform'] == 'centos') && node['platform_version'].to_f >= 7.0
  execute 'psqlinitdb' do
    command "/usr/pgsql-#{node['postgresql']['version']}/bin/postgresql#{nodecimal}-setup initdb"
    only_if { Dir["/var/lib/pgsql/#{ver}/data/*"].empty? }
  end
else
  execute 'psqlinitdb' do
    command "service postgresql-#{ver} initdb"
    only_if { Dir["/var/lib/pgsql/#{ver}/data/*"].empty? }
  end
end

service "postgresql-#{ver}" do
  action [:enable, :start]
end

# fix the pg_hba.conf
template "/var/lib/pgsql/#{ver}/data/pg_hba.conf" do
  source 'pg_hba.conf.erb'
  notifies :restart, "service[postgresql-#{ver}]", :immediate
end

# two commands: create user and alter is piggybacked
execute 'create-database-user' do
  code = <<-EOH
  psql -c "select * from pg_user where usename='#{node.default['postgresql']['jellyfish_user']}'" | grep -c #{node.default['postgresql']['jellyfish_user']}
  EOH
  command "psql -c \"CREATE USER #{node.default['postgresql']['jellyfish_user']} WITH PASSWORD '#{node.default['postgresql']['jellyfish_dbpass']}';  ALTER USER #{node.default['postgresql']['jellyfish_user']} WITH SUPERUSER;\""
  not_if code, 'user' => 'postgres'
  user 'postgres'
end

# two commands: create db and grant user on the db is piggybacked
execute 'create-database' do
  exists = <<-EOH
  psql -c "select * from pg_database WHERE datname='#{node.default['postgresql']['jellyfish_db']}'" | grep -c #{node.default['postgresql']['jellyfish_db']}
  EOH
  command "createdb  -O #{node.default['postgresql']['jellyfish_user']} -E utf8 -T template1 #{node.default['postgresql']['jellyfish_db']}; psql -c \"GRANT ALL PRIVILEGES ON DATABASE #{node.default['postgresql']['jellyfish_db']} to #{node.default['postgresql']['jellyfish_user']};\""
  not_if exists, 'user' => 'postgres'
  user 'postgres'
end
