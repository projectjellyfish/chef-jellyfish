#
# Cookbook Name:: chef-jellyfish
# Recipe:: _common
#
# Copyright (c) 2015 Booz Allen Hamilton, All Rights Reserved.

require 'pp'

user node.default['jellyfishuser']['user'] do
  comment node.default['jellyfishuser']['user']
  supports 'manage_home' => true
  system false
  shell '/bin/bash'
  home node.default['jellyfishuser']['home']
  gid node.default['jellyfishuser']['group']
  action :create
end

template "#{node.default['jellyfishuser']['home']}/.bash_profile" do
  source 'bash_profile.erb'
  variables(
    'dbuser' => node.default['postgresql']['jellyfish_user'],
    'dbpasswd' => node.default['postgresql']['jellyfish_dbpass'],
    'dbname' => node.default['postgresql']['jellyfish_db'],
    'rails_env' => node.default['rails_env'],
    'home' => node.default['jellyfishuser']['home'],
    'devise_secret_key' => node.default['rdkey']
  )
end

package 'git'
package ['gcc-c++', 'patch', 'readline', 'readline-devel', 'zlib', 'zlib-devel']

# Turn on 'optional' to get libyaml-devel on RHEL 7
execute 'add optional repo' do
  command 'yum-config-manager --enable rhui-REGION-rhel-server-optional'
  # If optional repo is not available, can also get libyaml-devel this way:
  # wget ftp://mirror.switch.ch/pool/4/mirror/scientificlinux/7rolling/x86_64/os/Packages/libyaml-devel-0.1.4-10.el7.x86_64.rpm
  only_if "yum repolist disabled | grep -e \"rhui-REGION-rhel-server-optional\""
end

package ['libyaml-devel', 'libffi-devel', 'openssl-devel', 'make', 'bzip2', 'autoconf', 'automake', 'libtool', 'bison']

case node['platform']
when 'redhat', 'centos'
  if node['platform_version'].to_f < 5.4
    # >= 5.4 this is provided by glibc
    package 'iconv-devel'
  end
end

package ['sqlite-devel', 'libffi-devel', 'openssl-devel', 'ntp']

service 'ntpd'  do
  action [:enable, :start]
end
