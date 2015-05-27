#
# Cookbook Name:: chef-jellyfish
# Recipe:: default
#
# Copyright (c) 2015 Kevin M Kingsbury, All Rights Reserved.


# User home & Packages
include_recipe 'chef-jellyfish::_common'

# Postgres94 & User, DB
include_recipe 'chef-jellyfish::_postgresql'

# Git code
include_recipe 'chef-jellyfish::_jellyfish'

# Rbenv and Ruby-build into /home/jellyfish/.rbenv
include_recipe 'chef-jellyfish::_ruby'

# Nginx
include_recipe 'chef-jellyfish::_nginx'



bash "start api" do
  code "source /home/jellyfish/.bash_profile; bundle exec puma -e development -d -b unix:///tmp/myapp_puma.sock"
  user 'jellyfish'
  environment  ({ 'HOME' => "home/jellyfish", 'USER' => 'jellyfish', 'RAILS_ENV' => 'production', 'RBENV_SHELL'=> 'bash' })
  cwd "/home/jellyfish/api"
end


## Updates the budgets for projects
#rake upkeep:update_budgets

# Pull down AWS pricing (not used at the moment)
#rake upkeep:get_aws_od_pricing

# Get the status of VM's from ManageIQ
#rake upkeep:poll_miq_vms

# Run the delayed job workers (this is what processes the orders to the various systems
#rake jobs:work
