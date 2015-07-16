#
# Cookbook Name:: chef-jellyfish
# Recipe:: _nginx
#
# Copyright (c) 2015 Booz Allen Hamilton, All Rights Reserved.

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
