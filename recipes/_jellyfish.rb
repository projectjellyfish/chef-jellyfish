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
