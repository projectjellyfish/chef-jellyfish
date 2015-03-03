#
# Cookbook Name:: chef-jellyfish
# Recipe:: ux
#
# Copyright 2015, Booz Allen Hamilton
#
# All rights reserved - Do Not Redistribute
#

log 'Create jellyfish user'

user 'jellyfish' do
  comment 'jellyfish user'
  shell '/bin/bash'
end

log 'Install Pre-Requisites'
yum_package 'git'
yum_package 'gcc-c++'
yum_package 'make'
yum_package 'ruby'
yum_package 'rubygems'
yum_package 'unzip'
gem_package 'sass'

log 'Install node.js and dependencies'
bash 'Install Node' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  curl -sL https://rpm.nodesource.com/setup | bash -
  yum install -y nodejs
  npm install --global gulp
  EOH
  creates '/usr/bin/gulp'
end

log 'Checkout and Unzip the latest UX Code'
remote_file "#{node['rbenv']['user_home']}/ux-master.zip" do
  source 'https://github.com/projectjellyfish/ux/archive/master.zip'
  mode '0644'
end

log 'Unzip ux-master and move it to ux'
bash 'unzip ux-master.zip' do
  cwd node['rbenv']['user_home']
  user node['jellyfish']['user']
  code <<-EOH
  /usr/bin/unzip ux-master.zip -d #{node['rbenv']['user_home']}/ux
  EOH
  creates "#{node['rbenv']['user_home']}/ux"
end

log 'Run gulp and Install into Production'
bash 'Install npm, forever and gulp production' do
  user 'root'
  cwd "#{node['rbenv']['user_home']}/ux"
  code <<-EOH
  /usr/bin/npm link
  /usr/bin/npm install -g
  /usr/bin/gulp production
  /usr/bin/npm install forever  -g
  EOH
  creates "#{node['rbenv']['user_home']}/ux/node_modules/winston"
end

log 'Set ENV settings'
template "#{node['rbenv']['user_home']}/ux/public/appConfig.js" do
  source 'appConfig.js.erb'
  owner node['jellyfish']['user']
  group node['jellyfish']['group']
  mode '0644'
end

log 'Change user permissions appVersion.js'
file "#{node['rbenv']['user_home']}/ux/public/appVersion.js" do
  owner node['jellyfish']['user']
  group node['jellyfish']['group']
  mode '0644'
end

log 'Run node'
bash 'run node' do
  user node['jellyfish']['user']
  cwd "#{node['rbenv']['user_home']}/ux"
  code <<-EOH
  /usr/bin/forever start app.js &
  touch /tmp/node_is_running
  EOH
  creates '/tmp/node_is_running'
end

log 'Install nginx'
cookbook_file '/etc/yum.repos.d/nginx.repo' do
  source 'nginx.repo'
  mode '0644'
  owner 'root'
  group 'root'
end

yum_package 'nginx'

cookbook_file '/etc/nginx/conf.d/default.conf' do
  source 'default.conf'
  mode '0644'
  owner 'root'
  group 'root'
end

service 'nginx' do
  action :start
end
