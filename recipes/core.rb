#
# Cookbook Name:: jellyfish
# Recipe:: core
#
# Copyright 2015, Booz Allen Hamilton
#
# All rights reserved - Do Not Redistribute
#
log "Create jellyfish user"
user "jellyfish" do
  comment "jellyfish user"
  shell "/bin/bash"
end

log "Install Pre-Requisites"
yum_package "git"
yum_package "gcc-c++"
yum_package "patch"
yum_package "readline"
yum_package "readline-devel"
yum_package "zlib"
yum_package "zlib-devel"
yum_package "libyaml-devel"
yum_package "libffi-devel"
yum_package "openssl-devel"
yum_package "make"
yum_package "bzip2"
yum_package "autoconf"
yum_package "automake"
yum_package "libtool"
yum_package "bison"
yum_package "sqlite-devel"
yum_package "unzip"

log "Install rbenv/rbenv-build/rbenv-vars"
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"
include_recipe "rbenv::rbenv_vars"

log "Installing rbenv ruby 2.1.5"
rbenv_ruby "2.1.5"


rbenv_gem "rails" do
  ruby_version "2.1.5"
end

#rbenv_gem "passenger" do
#  ruby_version "2.1.5"
#end

log "Install PostgreSQL"
remote_file "/opt/pgdg-redhat93-9.3-1.noarch.rpm" do
 source "http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-redhat93-9.3-1.noarch.rpm"
 mode "0644"
end

package "pgdg-redhat93-9.3-1.noarch.rpm" do
  action :install
  source  "/opt/pgdg-redhat93-9.3-1.noarch.rpm"
  provider Chef::Provider::Package::Rpm
end

yum_package "postgresql93-server"
yum_package "postgresql93-devel"
yum_package "postgresql93-contrib"

bash "gem instal pg" do
  cwd "/opt/"
  user "root"
  code <<-EOH
  source /etc/profile.d/rbenv.sh
  rbenv global 2.1.5
  /opt/rbenv/versions/2.1.5/bin/gem install pg -v '0.17.1' -- --with-pg-config=/usr/pgsql-9.3/bin/pg_config
  EOH
  creates "/opt/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/pg-0.18.1"
end

bash "gem instal sqlite3" do
  cwd "/opt/"
  user "root"
  code <<-EOH
  source /etc/profile.d/rbenv.sh
  rbenv global 2.1.5
  /opt/rbenv/versions/2.1.5/bin/gem install sqlite3 -v '1.3.10'
  EOH
  creates "/opt/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/sqlite3-1.3.10"
end

bash "sed requiretty sudoers" do
  cwd "/opt/"
  user "root"
  code <<-EOH
  sed -i 's/^.*requiretty/#Defaults requiretty/' /etc/sudoers
  EOH
  not_if ("grep requiretty /etc/sudoers|grep ^#Defaults")
end

log "Checkout the latest code"
remote_file "/opt/api-2.0.0.zip" do
  source "https://github.com/projectjellyfish/api/archive/2.0.0.zip"
  mode '0644'
end

bash "unzip api-2.0.0.zip" do
  cwd "/opt"
  user "root"
  code <<-EOH
  unzip api-2.0.0.zip
  EOH
  creates "/opt/api-2.0.0"
end

log "Application.yml configuration file"
template "/opt/api-2.0.0/config/application.yml" do
  source "application.yml.erb"
  mode '0644'
  owner 'root'
  group 'root'
end

log "Install bundler"
rbenv_gem "bundler" do
  ruby_version "2.1.5"
end

log "bundle api-2.0.0"
bash "bundle api-2.0.0" do
  cwd "/opt/api-2.0.0"
  user "root"
  code <<-EOH
  source /etc/profile.d/rbenv.sh && bundle
  EOH
  creates "/opt/rbenv/versions/2.1.5/lib/ruby/gems/2.1.0/gems/xml-simple-1.1.4"
end

log "Populate the database"
bash "postgresql 9.3 initdb " do
  cwd "/opt/api-2.0.0"
  user "root"
  code <<-EOH
  service postgresql-9.3 initdb
  EOH
  creates "/var/lib/pgsql/9.3/data/base/1"
end

service "postgresql-9.3" do
  action :start
end

bash "assign-postgres-password" do
  user 'postgres'
  code <<-EOH
  echo "ALTER ROLE postgres PASSWORD 'password';" | psql
  touch /tmp/alter_pgsql
  EOH
  action :run
  creates "/tmp/alter_pgsql"
end


template "/var/lib/pgsql/9.3/data/pg_hba.conf" do
  source "pg_hba.conf.erb"
  mode '0600'
  owner 'postgres'
  group 'postgres'
end


service "postgresql-9.3 restart" do
  action :restart
end

log "running rake tasks"
bash "rake tasks" do
  cwd "/opt/api-2.0.0"
  user "root"
  code <<-EOH
  source /etc/profile.d/rbenv.sh
  rake db:drop db:create db:migrate
  rake db:seed && touch /tmp/rake_db_create
  EOH
  creates "/tmp/rake_db_create"
end

log "starting rails"
bash "rails s" do
  cwd "/opt/api-2.0.0"
  user "root"
  code <<-EOH
  source /etc/profile.d/rbenv.sh && /opt/api-2.0.0/bin/rails s -d &
  touch /tmp/rails_started
  EOH
  creates "/tmp/rails_started"
end
