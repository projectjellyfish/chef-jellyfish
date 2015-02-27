#
# Cookbook Name:: chef-jellyfish
# Recipe:: api
#
# Copyright 2015, Booz Allen Hamilton
#
# All rights reserved - Do Not Redistribute
#
node.set['rbenv']['root']          = rbenv_root_path
node.set['ruby_build']['prefix']   = "#{node['rbenv']['root']}/plugins/ruby_build"
node.set['ruby_build']['bin_path'] = "#{node['ruby_build']['prefix']}/bin"

log 'Create jellyfish user'
user 'jellyfish' do
  comment 'jellyfish user'
  shell '/bin/bash'
end

log 'Install Pre-Requisites'
yum_package 'git'
yum_package 'gcc-c++'
yum_package 'patch'
yum_package 'readline'
yum_package 'readline-devel'
yum_package 'zlib'
yum_package 'zlib-devel'
yum_package 'libyaml-devel'
yum_package 'libffi-devel'
yum_package 'openssl-devel'
yum_package 'make'
yum_package 'bzip2'
yum_package 'autoconf'
yum_package 'automake'
yum_package 'libtool'
yum_package 'bison'
yum_package 'sqlite-devel'
yum_package 'unzip'

log 'Checkout the latest code'
remote_file "#{node['rbenv']['user_home']}/api-master.zip" do
  source 'https://github.com/projectjellyfish/api/archive/master.zip'
  mode '0644'
end

bash 'unzip api-master.zip' do
  cwd "#{node['rbenv']['user_home']}"
  user 'jellyfish'
  code <<-EOH
  unzip api-master.zip
  EOH
  creates "#{node['rbenv']['user_home']}/api-master"
end

bash 'mv api-master api' do
  cwd "#{node['rbenv']['user_home']}"
  user 'jellyfish'
  code <<-EOH
   mv #{node['rbenv']['user_home']}/api-master #{node['rbenv']['user_home']}/api
  EOH
  creates "#{node['rbenv']['user_home']}/api"
end

directory  "#{node['rbenv']['user_home']}/.rbenv" do
  owner 'jellyfish'
  group 'jellyfish'
  mode '0755'
  action :create
end

git  "#{node['rbenv']['user_home']}/.rbenv" do
  repository 'https://github.com/sstephenson/rbenv.git'
  revision "master"
  action :sync
  user 'jellyfish'
  group 'jellyfish'
end



template "/home/jellyfish/.bash_profile" do
  source "bash_profile.erb"
  mode "0644"
  notifies :create, "ruby_block[initialize_rbenv]", :immediately
end

ruby_block "initialize_rbenv" do
  block do
    ENV['RBENV_ROOT'] = node['rbenv']['root']
    ENV['PATH'] = "#{node['rbenv']['root']}/bin:#{node['rbenv']['root']}/shims:#{node['ruby_build']['bin_path']}:#{ENV['PATH']}"
  end

  action :nothing
end

# rbenv init creates these directories as root because it is called
# from /etc/profile.d/rbenv.sh But we want them to be owned by rbenv
# check https://github.com/sstephenson/rbenv/blob/master/libexec/rbenv-init#L71
%w{shims versions plugins}.each do |dir_name|
  directory "#{node['rbenv']['root']}/#{dir_name}" do
    owner node['rbenv']['user']
    group node['rbenv']['group']
    mode "2775"
    action [:create]
  end
end

git node['ruby_build']['prefix'] do
  repository node['ruby_build']['git_repository']
  reference node['ruby_build']['git_revision']
  action :sync
  user node['rbenv']['user']
  group node['rbenv']['group']
end

log 'Installing Ruby 2.2.0'
bash 'install ruby 2.2.0' do
  cwd '/home/jellyfish'
  user 'jellyfish'
  code <<-EOH
   source /home/jellyfish/.bash_profile && /home/jellyfish/.rbenv/bin/rbenv install 2.2.0
  EOH
  creates '/home/jellyfish/.rbenv/versions/2.2.0'
end

log 'Install PostgreSQL'
remote_file '/opt/pgdg-redhat93-9.3-1.noarch.rpm' do
  source node['pgdg_rpm']
  mode '0644'
end

package 'pgdg-redhat93-9.3-1.noarch.rpm' do
  action :install
  source '/opt/pgdg-redhat93-9.3-1.noarch.rpm'
  provider Chef::Provider::Package::Rpm
end

yum_package 'postgresql93-server'
yum_package 'postgresql93-devel'
yum_package 'postgresql93-contrib'

log 'Install gem pg'
bash 'gem instal pg' do
  cwd '/home/jellyfish/'
  user 'jellyfish'
  code <<-EOH
   source /home/jellyfish/.bash_profile
   /home/jellyfish/.rbenv/bin/rbenv global 2.2.0
   /home/jellyfish/.rbenv/versions/2.2.0/bin/gem install pg -v '0.17.1' -- \
   --with-pg-config=/usr/pgsql-9.3/bin/pg_config
  EOH
  creates '/home/jellyfish/.rbenv/versions/2.2.0/lib/ruby/gems/2.2.0/gems/pg-0.17.1'
end

log 'Install gem sqlite3'
bash 'gem instal sqlite3' do
  cwd '/home/jellyfish/'
  user 'jellyfish'
  code <<-EOH
  source /home/jellyfish/.bash_profile
  /home/jellyfish/.rbenv/bin/rbenv global 2.2.0
  /home/jellyfish/.rbenv/versions/2.2.0/bin/gem install sqlite3 -v '1.3.10'
  EOH
  creates '/home/jellyfish/.rbenv/versions/2.2.0/lib/ruby/gems/2.2.0/gems/sqlite3-1.3.10'
end

#bash 'sed requiretty sudoers' do
#  cwd '/opt/'
#  user 'root'
#  code <<-EOH
#  sed -i 's/^.*requiretty/#Defaults requiretty/' /etc/sudoers
#  EOH
#  not_if('grep requiretty /etc/sudoers|grep ^#Defaults')
#end


log 'Application.yml configuration file'
template '/home/jellyfish/api/.env' do
  source 'dotEnv.erb'
  mode '0644'
  owner 'jellyfish'
  group 'jellyfish'
end

log 'Install bundler'
bash 'gem instal bundler' do
  cwd '/home/jellyfish/.rbenv/'
  user 'root'
  code <<-EOH
  source /home/jellyfish/.bash_profile
  /home/jellyfish/.rbenv/bin/rbenv global 2.2.0
  /home/jellyfish/.rbenv//versions/2.2.0/bin/gem install bundler
  EOH
  creates '/home/jellyfish/.rbenv/versions/2.2.0/lib/ruby/gems/2.2.0/gems/bundler'
end

log 'bundle api'
bash 'bundle api' do
  cwd '/home/jellyfish/api'
  user 'jellyfish'
  code <<-EOH
  source /home/jellyfish/.bash_profile && bundle
  EOH
  creates '/home/jellyfish/.rbenv/versions/2.2.0/lib/ruby/gems/2.2.0/gems/xml-simple-1.1.4'
end

log 'Populate the database'
bash 'postgresql 9.3 initdb ' do
  cwd '/home/jellyfish/api'
  user 'root'
  code <<-EOH
  service postgresql-9.3 initdb
  EOH
  creates '/var/lib/pgsql/9.3/data/base/1'
end

log 'Convfiguring postgres database'
service 'postgresql-9.3' do
  action :start
end

log 'Template pg_hba.conf'
template '/var/lib/pgsql/9.3/data/pg_hba.conf' do
  source 'pg_hba.conf.erb'
  mode '0600'
  owner 'postgres'
  group 'postgres'
end

service 'postgresql-9.3 restart' do
  action :restart
end

log 'Running rake tasks'
bash 'rake tasks' do
  cwd '/home/jellyfish/api'
  user 'jellyfish'
  code <<-EOH
  source /home/jellyfish/.bash_profile.sh
  rake db:drop db:create db:migrate
  rake db:seed && touch /tmp/rake_db_create
  EOH
  creates '/tmp/rake_db_create'
end

log 'Starting rails'
bash 'rails s -d' do
  cwd '/home/jellyfish/api'
  user 'jellyfish'
  code <<-EOH
  source /home/jellyfish/.bash_profile && /home/jellyfish/api/bin/rails s -d &
  touch /tmp/rails_started
  EOH
  creates '/tmp/rails_started'
end

