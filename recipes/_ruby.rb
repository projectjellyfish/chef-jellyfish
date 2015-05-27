#
# Cookbook Name:: chef-jellyfish
# Recipe:: _ruby
#
# Copyright (c) 2015 Booz Allen Hamilton, All Rights Reserved.

directory "/home/jellyfish/.rbenv" do
  owner 'jellyfish'
  group 'users'
  mode '0755'
  action :create
end

git "/home/jellyfish/.rbenv" do
  repository "https://github.com/sstephenson/rbenv.git"
  reference "master"
  user "jellyfish"
  group "users"
  action :checkout
end

directory "/home/jellyfish/.rbenv/plugins/ruby-build" do
  owner 'jellyfish'
  group 'users'
  mode '0755'
  action :create
  recursive true
end

git "/home/jellyfish/.rbenv/plugins/ruby-build" do
  repository "https://github.com/sstephenson/ruby-build.git"
  reference "master"
  user "jellyfish"
  group "users"
  action :checkout
end

template '/home/jellyfish/.bash_profile' do
  source 'bash_profile.erb'
  variables({
    'dbuser' => node.default['postgresql']['jellyfish_user'],
    'dbpasswd' =>node.default['postgresql']['jellyfish_dbpass'],
    'dbname' => node.default['postgresql']['jellyfish_db'],
    'rails_env' => node.default['rails_env']
  })
end

# wrap in Ruby block because file doesn't exist at compile, will at execution.
rubyversion = 0
ruby_block "Get Ruby version" do
  block do
    # node.normal['rbversion'] = File.read("/home/jellyfish/api/.ruby-version")
    if File.exists?("/home/jellyfish/api/.ruby-version")
      # Read the CWM version from file.
      f = File.open("/home/jellyfish/api/.ruby-version")

      pattern = /(\d+\.\d+\.\d+)/

      f.each {|line|
        if match = pattern.match(line)
          node.normal['rbversion'] = match[1]
          rubyversion = match[1]
          pp  "ruby version: "+ match[1].to_s
          break
        end
      }
      f.close


    end
  end
end


log "These next steps will take a long time."
bash "rbenv-install" do
  code "source /home/jellyfish/.bash_profile; rbenv install \"\$\(cat /home/jellyfish/api/.ruby-version\)\""
  user 'jellyfish'
  environment  ({ 'HOME' => "/home/jellyfish/", 'USER' => 'jellyfish' })
  not_if do ::File.exists?("/home/jellyfish/.rbenv/versions/#{rubyversion}") end
end

bash "rbenv-global" do
  code "source /home/jellyfish/.bash_profile; rbenv global \"\$\(cat /home/jellyfish/api/.ruby-version\)\""
  user 'jellyfish'
  environment  ({ 'HOME' => "/home/jellyfish/", 'USER' => 'jellyfish' })
end

bash "gem-install-bundler" do
  code "source /home/jellyfish/.bash_profile; gem install bundler"
  user 'jellyfish'
  environment  ({ 'HOME' => "/home/jellyfish/", 'USER' => 'jellyfish' })
end

bash "gem-install-pg" do
  code "source /home/jellyfish/.bash_profile; gem install pg -v '0.17.1' -- --with-pg-config=/usr/pgsql-#{node.default['postgresql']['version']}/bin/pg_config"
  user 'jellyfish'
  environment  ({ 'HOME' => "/home/jellyfish/", 'USER' => 'jellyfish' })
end

bash "bundle install" do
  cwd "/home/jellyfish/api"
  code "source /home/jellyfish/.bash_profile; bundle install"
  user 'jellyfish'
  environment  ({ 'HOME' => "/home/jellyfish/", 'USER' => 'jellyfish' })
end


# make .env file: need this at execute, does not exist at compile.
execute "copy" do
  command "cp /home/jellyfish/api/.env.example /home/jellyfish/api/.env"
  user 'jellyfish'
  environment  ({ 'HOME' => "/home/jellyfish/", 'USER' => 'jellyfish' })
  not_if do ::File.exists?("/home/jellyfish/api/.env") end
end




execute "secretkey" do
  command "/bin/sed -i.bak 's/^#\sDEVISE_SECRET_KEY\=.*/DEVISE_SECRET_KEY=#{node.default['rdkey']}/' /home/jellyfish/api/.env"
  only_if "grep '# DEVISE_SECRET_KEY=\\|Devise Secret Key\\|' /home/jellyfish/api/.env"
end
execute "dbstring" do
  command "/bin/sed -i.bak 's/^DATABASE_URL\=.*/DATABASE_URL=postgres:\\/\\/#{node.default['postgresql']['jellyfish_user']}:#{node.default['postgresql']['jellyfish_dbpass']}@localhost:5432\\/#{node.default['postgresql']['jellyfish_db']}/' /home/jellyfish/api/.env"
  only_if "grep 'DATABASE_URL=postgres:\\/\\/#{node.default['postgresql']['jellyfish_user']}:#{node.default['postgresql']['jellyfish_dbpass']}@localhost:5432\\/#{node.default['postgresql']['jellyfish_db']}' /home/jellyfish/api/.env"
end

#breakpoint "before bash rake db:migrate" do
#  action :break
#end

#bash "rake db:migrate" do
#  code "source /home/jellyfish/.bash_profile; bundle exec rake sync_environment; rake db:migrate"
#  cwd "/home/jellyfish/api"
#  user 'jellyfish'
#  environment  ({ 'HOME' => "/home/jellyfish/", 'USER' => 'jellyfish' })
#end

bash "rake db:migrate" do
  code       "source /home/jellyfish/.bash_profile; rake db:migrate"
  cwd           '/home/jellyfish/api'
  environment   ({ 'HOME' => "/home/jellyfish/", 'USER' => 'jellyfish', 'RAILS_ENV' => 'production', 'RBENV_SHELL'=> 'bash' })
  user 'jellyfish'
end

#breakpoint "after bash rake db:migrate" do
#  action :break
#end

bash "rake db:seed" do
  code "source /home/jellyfish/.bash_profile;  rake db:seed"
  cwd "/home/jellyfish/api"
  user 'jellyfish'
  environment  ({ 'HOME' => "/home/jellyfish/", 'USER' => 'jellyfish', 'RAILS_ENV' => 'production', 'RBENV_SHELL'=> 'bash'  })
end

if node.default['sampledata'] == true
  log "Loading Sample Data"
  bash "rake sample:demo" do
    code "source /home/jellyfish/.bash_profile;  rake sample:demo"
    user 'jellyfish'
    cwd "/home/jellyfish/api"
    environment  ({ 'HOME' => "/home/jellyfish/", 'USER' => 'jellyfish', 'RAILS_ENV' => 'production', 'RBENV_SHELL'=> 'bash'  })
  end
else
  log "Skipping Sample Data"
end

#this won't exit ever unless we & it
#bash "rails s" do
#  code "source /home/jellyfish/.bash_profile;  rails s"
#  cwd "/home/jellyfish/api"
#  user 'jellyfish'
#  environment  ({ 'HOME' => "/home/jellyfish/", 'USER' => 'jellyfish' })
#end
