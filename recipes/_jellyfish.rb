#
# Cookbook Name:: chef-jellyfish
# Recipe:: _jellyfish
#
# Copyright (c) 2015 Booz Allen Hamilton, All Rights Reserved.

git "#{node.default['jellyfishuser']['home']}/api" do
  repository 'https://github.com/projectjellyfish/api.git'
  reference 'master'
  user node.default['jellyfishuser']['user']
  group node.default['jellyfishuser']['group']
  action 'checkout'
end

# Get Ruby set and Installed
include_recipe 'chef-jellyfish::_ruby'

#
bash 'bundle install' do
  cwd "#{node.default['jellyfishuser']['home']}/api"
  code "source #{node.default['jellyfishuser']['home']}/.bash_profile; bundle install"
  user node.default['jellyfishuser']['user']
  environment 'HOME' => node.default['jellyfishuser']['home'], 'USER' => node.default['jellyfishuser']['user']
end

# If DB has stuff and load sample is "true", then need to drop that db first
if node.default['sampledata'] == true
  log('check for drop')
  execute 'empty before sample' do
    code = "psql -d #{node.default['postgresql']['jellyfish_db']} -c \"SELECT  \"staff\".\"email\" FROM \"staff\" WHERE \"staff\".\"email\" = 'unused@projectjellyfish.org'\" | grep -q 'unused@projectjellyfish.org'"
    command "source #{node.default['jellyfishuser']['home']}/.bash_profile; rake db:reset"
    only_if code, 'user' => 'postgres', 'cwd' => node.default['postgresql']['dir']
    environment 'HOME' => node.default['jellyfishuser']['home'], 'USER' => node.default['jellyfishuser']['user'], 'RAILS_ENV' => node.default['rails_env'], 'RBENV_SHELL' => 'bash'
    cwd "#{node.default['jellyfishuser']['home']}/api"
    user node.default['jellyfishuser']['user']
  end
end

bash 'rake db:migrate' do
  code "source #{node.default['jellyfishuser']['home']}/.bash_profile; rake db:migrate"
  cwd "#{node.default['jellyfishuser']['home']}/api"
  environment 'HOME' => node.default['jellyfishuser']['home'], 'USER' => node.default['jellyfishuser']['user'], 'RAILS_ENV' => node.default['rails_env'], 'RBENV_SHELL' => 'bash'
  user node.default['jellyfishuser']['user']
end

bash 'rake db:seed' do
  code "source #{node.default['jellyfishuser']['home']}/.bash_profile;  rake db:seed"
  cwd "#{node.default['jellyfishuser']['home']}/api"
  user node.default['jellyfishuser']['user']
  environment 'HOME' => node.default['jellyfishuser']['home'], 'USER' => node.default['jellyfishuser']['user'], 'RAILS_ENV' => node.default['rails_env'], 'RBENV_SHELL' => 'bash'
end

if node.default['sampledata'] == true
  log 'Loading Sample Data'
  bash 'rake sample:demo' do
    code "source #{node.default['jellyfishuser']['home']}/.bash_profile;  rake sample:demo"
    user node.default['jellyfishuser']['user']
    cwd "#{node.default['jellyfishuser']['home']}/api"
    environment 'HOME' => node.default['jellyfishuser']['home'], 'USER' => 'jellyfish', 'RAILS_ENV' => node.default['rails_env'], 'RBENV_SHELL' => 'bash'
  end
else
  log 'Skipping Sample Data'
end
