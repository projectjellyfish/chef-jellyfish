#
# Cookbook Name:: chef-jellyfish
# Recipe:: _ruby
#
# Copyright (c) 2015 Booz Allen Hamilton, All Rights Reserved.

directory "#{node.default['jellyfishuser']['home']}/.rbenv" do
  owner node.default['jellyfishuser']['user']
  group node.default['jellyfishuser']['group']
  mode '0755'
  action :create
end

git "#{node.default['jellyfishuser']['home']}/.rbenv" do
  repository 'https://github.com/sstephenson/rbenv.git'
  reference 'master'
  user node.default['jellyfishuser']['user']
  group node.default['jellyfishuser']['group']
  action :checkout
end

directory "#{node.default['jellyfishuser']['home']}/.rbenv/plugins/ruby-build" do
  owner node.default['jellyfishuser']['user']
  group node.default['jellyfishuser']['group']
  mode '0755'
  action :create
  recursive true
end

git "#{node.default['jellyfishuser']['home']}/.rbenv/plugins/ruby-build" do
  repository 'https://github.com/sstephenson/ruby-build.git'
  reference 'master'
  user node.default['jellyfishuser']['user']
  group node.default['jellyfishuser']['group']
  action :checkout
end

log 'These next steps will take a long time.'
bash 'rbenv-install' do
  code "source #{node.default['jellyfishuser']['home']}/.bash_profile; rbenv install #{node.default['ruby']['version']}"
  user node.default['jellyfishuser']['user']
  environment 'HOME' => node.default['jellyfishuser']['home'], 'USER' => node.default['jellyfishuser']['user']
  not_if { ::File.exist?("#{node.default['jellyfishuser']['home']}/.rbenv/versions/#{node.default['ruby']['version']}") }
end

bash 'rbenv-global' do
  code "source #{node.default['jellyfishuser']['home']}/.bash_profile; rbenv global #{node.default['ruby']['version']}"
  user node.default['jellyfishuser']['user']
  environment 'HOME' => node.default['jellyfishuser']['home'], 'USER' => node.default['jellyfishuser']['user']
end

bash 'gem-install-pg' do
  cwd "#{node.default['jellyfishuser']['home']}/api"
  code "source #{node.default['jellyfishuser']['home']}/.bash_profile; gem install pg -v '#{node.default['pg']['version']}' -- --with-pg-config=/usr/pgsql-#{node.default['postgresql']['version']}/bin/pg_config"
  user node.default['jellyfishuser']['user']
  environment 'HOME' => node.default['jellyfishuser']['home'], 'USER' => node.default['jellyfishuser']['user']
end

bash 'gem-install-bundler' do
  cwd "#{node.default['jellyfishuser']['home']}/api"
  code "source #{node.default['jellyfishuser']['home']}/.bash_profile; gem install bundler"
  user node.default['jellyfishuser']['user']
  environment 'HOME' => node.default['jellyfishuser']['home'], 'USER' => node.default['jellyfishuser']['user']
end
