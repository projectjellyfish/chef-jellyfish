# Enable the install of Jellyfish-API
default['jellyfish']['api']['enabled'] = 'true'

# Enable the install of Jellyfish-UX
default['jellyfish']['ux']['enabled'] = 'true'

# The CORS for Jellyfish-API
# Comma seperated list of host that you want to be able to access Jellyfish API
default['jellyfish']['api']['cors_allow_origin'] = 'localhost:*'

# The URL of the Jellyfish-API that UX should be using
# Single FQDN: https://some-host.company.com:port (if port is different that
# the standard port)
default['jellyfish']['ux']['app_config_js'] = 'localhost:3030'

default['jellyfish']['user'] = 'jellyfish'
default['jellyfish']['group'] = 'jellyfish'
default['jellyfish']['ruby_version'] = '2.2.0'

# PostgreSQL RPM repo file
default['pgdg_rpm'] = 'http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-redhat93-9.3-1.noarch.rpm'

# rbenv variables
default['rbenv']['user']           = 'jellyfish'
default['rbenv']['group']          = 'jellyfish'
default['rbenv']['manage_home']    = true
default['rbenv']['group_users']    = []
default['rbenv']['git_repository'] = 'https://github.com/sstephenson/rbenv.git'
default['rbenv']['git_revision']   = 'master'
default['rbenv']['install_prefix'] = '/home/jellyfish'
default['rbenv']['root_path']      = "#{node['rbenv']['install_prefix']}/.rbenv"
default['rbenv']['user_home']      = "/home/#{node['rbenv']['user']}"
default['rbenv']['gems_directory'] = "#{node['rbenv']['root_path']}/version/#{node['jellyfish']['ruby_version']}/lib/ruby/gems/#{node['jellyfish']['ruby_version']}/gems"

default['ruby_build']['git_repository'] = 'https://github.com/sstephenson/ruby-build.git'
default['ruby_build']['git_revision']   = 'master'

default['rbenv_vars']['git_repository'] = 'https://github.com/sstephenson/rbenv-vars.git'
default['rbenv_vars']['git_revision']   = 'master'
