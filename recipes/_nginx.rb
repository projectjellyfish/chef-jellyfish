#
# Cookbook Name:: chef-jellyfish
# Recipe:: _nginx
#
# Copyright (c) 2015 Booz Allen Hamilton, All Rights Reserved.

if node['platform'] == 'centos' && node['platform_version'].to_f >= 6.0 && node['platform_version'].to_f < 7.0
  package 'epel-release'
  execute 'epelfix' do
    command "sed -i 's/mirrorlist=https/mirrorlist=http/' /etc/yum.repos.d/epel.repo"
  end
elsif node['platform'] == 'redhat' && node['platform_version'].to_f >= 6.0 && node['platform_version'].to_f < 7.0
  remote_file "#{Chef::Config[:file_cache_path]}/epel-release-6-8.noarch.rpm" do
    source 'http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm'
    action :create
  end

  rpm_package 'epelrpm' do
    source "#{Chef::Config[:file_cache_path]}/epel-release-6-8.noarch.rpm"
    action :install
  end
else
  package 'epel-release'
end

package 'epel-release'

# Now use yum to install Nginx and httpd-tools:
package ['nginx', 'httpd-tools']

# get rid of default, suppliment with our own
file '/etc/nginx/conf.d/default.conf' do
  action :delete
  only_if { ::File.exist?('/etc/nginx/conf.d/default.conf') }
end

template '/etc/nginx/conf.d/jellyfish-api.conf' do
  source 'jellyfish-api.conf.erb'
  variables(
    'home' => node.default['jellyfishuser']['home']
  )
  notifies :restart, 'service[nginx]', :immediately
end

# start
service 'nginx' do
  action [:start, :enable]
end
