chef-jellyfish Cookbook
=======================

[![Build Status](https://travis-ci.org/projectjellyfish/chef-jellyfish.svg?branch=master)](https://travis-ci.org/projectjellyfish/chef-jellyfish)

Allows for the install of Project Jellyfish

#### Requirements

Tested RHEL 6.5 Should work on any RHEL 6.X variant.

* Chef 11
* Centos / Redhat
* Ruby >= 2.1.5
* Node >= v0.10.36
* npm >= 1.4.28
* nvm >= 0.20.0

####Cookbook


####Attributes

default["jellyfish"]["core"]["enabled"] 
default["jellyfish"]["ux"]["enabled"] 
default["jellyfish"]["core"]["cors_allow_origin"]
default["jellyfish"]["ux"]["app_config_js"]

####Usage

Simply add recipe[jellyfish] to a run list.


####License

See LICENSE
