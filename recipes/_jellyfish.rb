#
# Cookbook Name:: chef-jellyfish
# Recipe:: _jellyfish
#
# Copyright (c) 2015 Kevin M Kingsbury, All Rights Reserved.

git "/home/jellyfish/api" do
  repository "https://github.com/projectjellyfish/api.git"
  reference "master"
  user "jellyfish"
  group "users"
  action :checkout
end
