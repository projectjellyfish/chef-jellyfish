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

# wrap in Ruby block because file doesn't exist at compile, will at execution.
rubyversion = 0
ruby_block 'Get Ruby version' do
  block do
    if File.exist?("#{node.default['jellyfishuser']['home']}/api/.ruby-version")
      f = File.open("#{node.default['jellyfishuser']['home']}/api/.ruby-version")

      f.each {|line|
        if mymatch = /(\d+\.\d+\.\d+)/.match(line)
          node.normal['rbversion'] = mymatch[1]
          rubyversion = mymatch[1]
          pp "ruby version: #{mymatch[1]}"
          break
        end
      }
      f.close

    end
  end
end

log 'These next steps will take a long time.'
bash 'rbenv-install' do
  code "source #{node.default['jellyfishuser']['home']}/.bash_profile; rbenv install \"\$\(cat #{node.default['jellyfishuser']['home']}/api/.ruby-version\)\""
  user node.default['jellyfishuser']['user']
  environment 'HOME' => node.default['jellyfishuser']['home'], 'USER' => node.default['jellyfishuser']['user']
  not_if { ::File.exist?("#{node.default['jellyfishuser']['home']}/.rbenv/versions/#{rubyversion}") }
end

bash 'rbenv-global' do
  code "source #{node.default['jellyfishuser']['home']}/.bash_profile; rbenv global \"\$\(cat node.default['jellyfishuser']['home']/api/.ruby-version\)\""
  user node.default['jellyfishuser']['user']
  environment 'HOME' => node.default['jellyfishuser']['home'], 'USER' => node.default['jellyfishuser']['user']
end

bash 'gem-install-bundler' do
  cwd "#{node.default['jellyfishuser']['home']}/api"
  code "source #{node.default['jellyfishuser']['home']}/.bash_profile; gem install bundler"
  user node.default['jellyfishuser']['user']
  environment 'HOME' => node.default['jellyfishuser']['home'], 'USER' => node.default['jellyfishuser']['user']
end

bash 'gem-install-pg' do
  cwd "#{node.default['jellyfishuser']['home']}/api"
  code "source #{node.default['jellyfishuser']['home']}/.bash_profile; gem install pg -v '0.17.1' -- --with-pg-config=/usr/pgsql-#{node.default['postgresql']['version']}/bin/pg_config"
  user node.default['jellyfishuser']['user']
  environment 'HOME' => node.default['jellyfishuser']['home'], 'USER' => node.default['jellyfishuser']['user']
end

bash 'bundle install' do
  cwd "#{node.default['jellyfishuser']['home']}/api"
  code "source #{node.default['jellyfishuser']['home']}/.bash_profile; bundle install"
  user node.default['jellyfishuser']['user']
  environment 'HOME' => node.default['jellyfishuser']['home'], 'USER' => node.default['jellyfishuser']['user']
end

# make .env file: need this at execute, does not exist at compile.
execute 'copy' do
  command "cp #{node.default['jellyfishuser']['home']}/api/.env.example #{node.default['jellyfishuser']['home']}/api/.env"
  user node.default['jellyfishuser']['user']
  environment 'HOME' => node.default['jellyfishuser']['home'], 'USER' => node.default['jellyfishuser']['user']
  not_if { ::File.exist?("#{node.default['jellyfishuser']['home']}/api/.env") }
end

execute 'secretkey' do
  command "sed -i.bak 's/^#\sDEVISE_SECRET_KEY\=.*/DEVISE_SECRET_KEY=#{node.default['rdkey']}/' #{node.default['jellyfishuser']['home']}/api/.env"
  only_if "grep '# DEVISE_SECRET_KEY=\\|Devise Secret Key\\|' #{node.default['jellyfishuser']['home']}/api/.env"
end
execute 'dbstring' do
  command "sed -i.bak 's/^DATABASE_URL\=.*/DATABASE_URL=postgres:\\/\\/#{node.default['postgresql']['jellyfish_user']}:#{node.default['postgresql']['jellyfish_dbpass']}@localhost:5432\\/#{node.default['postgresql']['jellyfish_db']}/' #{node.default['jellyfishuser']['home']}/api/.env"
  only_if "grep 'DATABASE_URL=postgres:\\/\\/#{node.default['postgresql']['jellyfish_user']}:#{node.default['postgresql']['jellyfish_dbpass']}@localhost:5432\\/#{node.default['postgresql']['jellyfish_db']}' #{node.default['jellyfishuser']['home']}/api/.env"
end

# DB Migrate

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
