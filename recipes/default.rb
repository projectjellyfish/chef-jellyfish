#
# Cookbook Name:: chef-jellyfish
# Recipe:: default
#
# Copyright 2015, Booz Allen Hamilton
#
# All rights reserved - Do Not Redistribute
#

user 'jellyfish' do
  comment 'Project Jellyfish User'
  system true
  shell '/bin/false'
end

if node['jellyfish']['api']['enabled'] == true
  log 'jellyfish api enabled'
  include_recipe 'chef-jellyfish::api'
end

if node['jellyfish']['ux']['enabled'] == true
  log 'jellyfish ux enabled'
  include_recipe 'chef-jellyfish::ux'
end
