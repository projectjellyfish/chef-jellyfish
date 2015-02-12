#
# Cookbook Name:: chef-jellyfish
# Recipe:: ux
#
# Copyright 2015, Booz Allen Hamilton
#
# All rights reserved - Do Not Redistribute
#

log "Create jellyfish user"

user "jellyfish" do
  comment "jellyfish user"
  shell "/bin/bash"
end

log "Install Pre-Requisites"
yum_package "git"
yum_package "gcc-c++"
yum_package "make"
yum_package "ruby"
yum_package "rubygems"
yum_package "unzip"
gem_package "sass"

log "Install node.js and dependencies"
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

log "Checkout and Unzip the latest UX Code"
remote_file "/opt/ux-2.0.0.zip" do
  source "https://github.com/projectjellyfish/ux/archive/2.0.0.zip"
  mode '0644'
end

bash "unzip ux-2.0.0.zip" do
  cwd "/opt"
  user "root"
  code <<-EOH
  unzip ux-2.0.0.zip
  EOH
  creates "/opt/ux-2.0.0"
end

log "Run gulp and Install into Production"
bash "Install Production" do
  user "root"
  cwd "/opt/ux-2.0.0"
  code <<-EOH
  /usr/bin/npm install
  /usr/bin/gulp production
  EOH
  creates "/opt/ux-2.0.0/node_modules/winston"
end

log "Set ENV settings"
template "/opt/ux-2.0.0/public/appConfig.js" do
  source "appConfig.js.erb"
  mode '0644'
  owner 'root'
  group 'root'
end

log "Install forever"

log "run node"
bash "Install forever" do
  user "root"
  cwd "/opt/ux-2.0.0"
  code <<-EOH
  /usr/bin/npm install forever  -g &
  EOH
  creates "/usr/bin/forever"
end

bash "run node" do
  user "root"
  cwd "/opt/ux-2.0.0"
  code <<-EOH
  /usr/bin/forever start app.js & 
  touch /tmp/node_is_running
  EOH
  creates "/tmp/node_is_running"
end

log "Install nginx"
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
