#
# Cookbook Name:: jellyfish
# Recipe:: ux
#
# Copyright 2015, Booz Allen Hamilton
#
# All rights reserved - Do Not Redistribute
#

cookbook_file "/etc/yum.repos.d/nginx.repo" do
  source "nginx.repo"
  mode '0644'
  owner 'root'
  group 'root'
end

yum_package "nginx"

cookbook_file "/etc/nginx/conf.d/default.conf" do
  source "default.conf"
  mode '0644'
  owner 'root'
  group 'root'
end

service "nginx" do
  action :start
end

bash "Install Node" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  curl -sL https://rpm.nodesource.com/setup | bash -
  yum install -y nodejs
  npm install --global gulp
  EOH
  creates "/usr/bin/gulp"
end

remote_file "/opt/ux-2.0.0.zip" do
  source "https://github.com/projectjellyfish/ux/archive/2.0.0.zip"
  mode '0644'
  checksum "a170cdb12cdbcc762381239f598d946d5baf9e20" # A SHA256 (or portion thereof) of the file.
end

bash "unzip ux-2.0.0.zip" do
  cwd "/opt"
  user "root"
  code <<-EOH
  unzip ux-2.0.0.zip
  EOH
  creates "/opt/ux-2.0.0"
end

yum_package "git"
yum_package "ruby"
yum_package "rubygems"
gem_package "sass"

log "Install into Production"
bash "Install Production" do
  user "root"
  cwd "/opt/ux-2.0.0"
  code <<-EOH
  npm install
  gulp production
  EOH
  creates "/opt/ux-2.0.0/node_modules/winston"
end

template "/opt/ux-2.0.0/public/appConfig.js" do
  source "appConfig.js.erb"
  mode '0644'
  owner 'root'
  group 'root'
end

log "Install forever"
bash "Install forever" do
  user "root"
  cwd "/opt/ux-2.0.0"
  code <<-EOH
  npm install forever  -g &
  EOH
  creates "/usr/bin/forever"
end

log "run node"
bash "run node" do
  user "root"
  cwd "/opt/ux-2.0.0"
  code <<-EOH
  forever start app.js 
  touch /tmp/node_is_running
  EOH
  creates "/tmp/node_is_running"
end
