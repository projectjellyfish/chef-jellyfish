#
# Cookbook Name:: chef-jellyfish
# Recipe:: api
#
# Copyright 2015, Booz Allen Hamilton
#
# All rights reserved - Do Not Redistribute
#
node.set['rbenv']['root']          = rbenv_root_path
node.set['ruby_build']['prefix'] = "#{node['rbenv']['root']}/plugins/ruby_build"
node.set['ruby_build']['bin_path'] = "#{node['ruby_build']['prefix']}/bin"

log 'Create jellyfish user'
user node['jellyfish']['user'] do
  comment 'jellyfish user'
  shell '/bin/bash'
end.run_action(:create)

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
yum_package 'unzip' do
  action :install
end.run_action(:install)

log 'Checkout the latest code'
remote_file "#{node['rbenv']['user_home']}/api-master.zip" do
  source 'https://github.com/projectjellyfish/api/archive/master.zip'
  mode '0644'
end.run_action(:create)

bash 'unzip api-master.zip' do
  cwd node['rbenv']['user_home']
  user node['jellyfish']['user']
  code <<-EOH
  unzip api-master.zip
  EOH
  creates "#{node['rbenv']['user_home']}/api-master"
end.run_action(:run)

bash 'mv api-master api' do
  cwd node['rbenv']['user_home']
  user node['jellyfish']['user']
  code <<-EOH
   mv #{node['rbenv']['user_home']}/api-master #{node['rbenv']['user_home']}/api
  EOH
  creates "#{node['rbenv']['user_home']}/api"
end.run_action(:run)

ruby_version = File.read("#{node['rbenv']['user_home']}/api/.ruby-version").strip
log("ruby version #{ruby_version}")
node.set['gd1'] = "#{node['rbenv']['root_path']}/version/#{ruby_version}"
node.set['gd2'] = "/lib/ruby/gems/#{ruby_version}/gems"
node.set['rbenv']['gem_directory'] = "#{node['gd1']}/#{node['gd2']}"
node.set['gem_exec'] = "#{node['rbenv']['ver_dir']}/#{ruby_version}/bin/gem"
node.set['rbenv']['installed'] = "#{node['rbenv']['ver_dir']}/#{ruby_version}"

directory "#{node['rbenv']['user_home']}/.rbenv" do
  owner node['jellyfish']['user']
  group node['jellyfish']['group']
  mode '0755'
  action :create
end

git "#{node['rbenv']['user_home']}/.rbenv" do
  repository 'https://github.com/sstephenson/rbenv.git'
  revision 'master'
  action :sync
  user node['rbenv']['user']
  group node['rbenv']['group']
end

template "#{node['rbenv']['user_home']}/.bash_profile" do
  source 'bash_profile.erb'
  mode '0644'
  notifies :create, 'ruby_block[initialize_rbenv]', :immediately
end

ruby_block 'initialize_rbenv' do
  block do
    ENV['RBENV_ROOT'] = node['rbenv']['root']
    # rubocop:disable Metrics/LineLength, Style/StringLiterals
    ENV['PATH'] = "#{node['rbenv']['root']}/bin:#{node['rbenv']['root']}/shims:#{node['ruby_build']['bin_path']}:#{ENV['PATH']}"
    # rubocop:enable Metrics/LineLength, Style/StringLiterals
  end
  action :nothing
end

# rbenv init creates these directories as root because it is called
# from /etc/profile.d/rbenv.sh But we want them to be owned by rbenv
# check https://github.com/sstephenson/rbenv/blob/master/libexec/rbenv-init#L71
%w(shims versions plugins).each do |dir_name|
  directory "#{node['rbenv']['root']}/#{dir_name}" do
    owner node['rbenv']['user']
    group node['rbenv']['group']
    mode '2775'
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

log "Installing Ruby #{ruby_version}"
bash "install ruby #{ruby_version}" do
  cwd node['rbenv']['user_home']
  user node['rbenv']['user']
  code <<-EOH
   source #{node['rbenv']['user_home']}/.bash_profile
   #{node['rbenv']['exec']} install #{ruby_version}
  EOH
  creates node['rbenv']['installed']
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
bash 'gem install pg' do
  cwd node['rbenv']['user_home']
  user node['rbenv']['user']
  code <<-EOH
   source #{node['rbenv']['user_home']}/.bash_profile
   #{node['rbenv']['exec']} global #{ruby_version}
   #{node['gem_exec']} install pg -v '0.17.1' \
   -- --with-pg-config=/usr/pgsql-9.3/bin/pg_config
  EOH
  creates "#{node['rbenv']['gem_directory']}/pg-0.17.1"
end

log 'Install gem sqlite3'
bash 'gem install sqlite3' do
  cwd node['rbenv']['user_home']
  user node['rbenv']['user']
  code <<-EOH
  source #{node['rbenv']['user_home']}/.bash_profile
   #{node['rbenv']['exec']} global #{ruby_version}
   #{node['gem_exec']} install sqlite3 -v '1.3.10'
  EOH
  creates "#{node['rbenv']['gem_directory']}/sqlite3-1.3.10"
end

log 'Application.yml configuration file'
template "#{node['rbenv']['user_home']}/api/.env" do
  source 'dotEnv.erb'
  mode '0644'
  owner node['jellyfish']['user']
  group node['jellyfish']['user']
end

log 'Install bundler'
bash 'gem instal bundler' do
  cwd "#{node['rbenv']['user_home']}/.rbenv/"
  user 'root'
  code <<-EOH
  source #{node['rbenv']['user_home']}/.bash_profile
  #{node['rbenv']['exec']} global #{ruby_version}
  #{node['gem_exec']} install bundler
  EOH
  creates "#{node['rbenv']['gem_directory']}/bundler-1.8.3"
end

log 'bundle api'
bash 'bundle api' do
  cwd "#{node['rbenv']['user_home']}/api"
  user node['jellyfish']['user']
  code <<-EOH
  source #{node['rbenv']['user_home']}/.bash_profile && bundle
  EOH
  creates "#{node['rbenv']['gem_directory']}/xml-simple-1.1.4"
end

log 'Populate the database'
bash 'postgresql 9.3 initdb ' do
  cwd "#{node['rbenv']['user_home']}/api"
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
  cwd "#{node['rbenv']['user_home']}/api"
  user node['jellyfish']['user']
  code <<-EOH
  source #{node['rbenv']['user_home']}/.bash_profile.sh
  rake db:drop db:create db:migrate
  rake db:seed && touch /tmp/rake_db_create
  EOH
  creates '/tmp/rake_db_create'
end

log 'Starting rails'
bash 'rails s -d' do
  cwd "#{node['rbenv']['user_home']}/api"
  user node['jellyfish']['user']
  code <<-EOH
  source #{node['rbenv']['user_home']}/.bash_profile
  #{node['rbenv']['user_home']}/api/bin/rails s -d &
  touch /tmp/rails_started
  EOH
  creates '/tmp/rails_started'
end
