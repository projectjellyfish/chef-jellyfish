#
# Cookbook Name:: chef-jellyfish
# Recipe:: _nodejs
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
  package 'epel-release'
else
  package 'epel-release'
end

package %w(nodejs npm)
