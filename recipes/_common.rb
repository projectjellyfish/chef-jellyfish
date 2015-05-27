#
# Cookbook Name:: chef-jellyfish
# Recipe:: _common
#
# Copyright (c) 2015 Kevin M Kingsbury, All Rights Reserved.
require 'pp'

user 'jellyfish' do
  comment 'jellyfish'
  supports :manage_home => true
  system false
  shell '/bin/bash'
  home '/home/jellyfish'
  action :create
end


package 'git'
package ['gcc-c++', 'patch', 'readline', 'readline-devel', 'zlib', 'zlib-devel']
package ['libyaml-devel', 'libffi-devel', 'openssl-devel', 'make']
package ['bzip2', 'autoconf', 'automake', 'libtool', 'bison']


#log "Platform version: " + node['platform_version'].to_f.to_s
case node['platform']
when "redhat", "centos"
 if node['platform_version'].to_f < 5.4
    #>= 5.4 this is provided by glibc
     package 'iconv-devel'
 end
end

package ['sqlite-devel', 'libffi-devel', 'openssl-devel']
package 'ntp'

service "ntpd"  do
  action [ :enable, :start ]
end
