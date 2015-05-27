## Name
chef-jellyfish

[![Build Status](https://travis-ci.org/projectjellyfish/chef-jellyfish.svg?branch=master)](https://travis-ci.org/projectjellyfish/chef-jellyfish)

## Purpose
To install and configure the jellyfish API & UX server

## Success Criteria
Working Jellyfish install, can hit webpage, see sample data, etc.

## App/Service
Jellyfish

## Required Steps
* Common setup (packages, user)
* Postgresql 9.4
* rbenv, ruby-build
* git code
* Ruby: bundler, pg_gem
* ENV vars
* Rake
* NGINX


## Getting started
````
mkdir -p ~/chef-repo/cookbooks
git clone https://github.com/projectjellyfish/chef-jellyfish.git
curl -L https://www.opscode.com/chef/install.sh | bash
sudo chef-client --local-mode --runlist 'recipe[chef-jellyfish]'
````