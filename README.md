Jellyfish Cookbook
=======================

* Core installs Jellyfish-API, and the following: rbenv, ruby 2.1.5, PostgreSQL 9.3.x, Nginx
* UX installs Jellyfish-UX, and the following: node, git, npm, gulp

####Requirements

Tested with RHEL 6.5, but it should work on any RHEL 6.X variant.

* Chef 11
* Centos / Redhat 6.x
* Ruby >= 2.1.5
* Node >= v0.10.36
* npm >= 1.4.28
* nvm >= 0.20.0

####Cookbook

- `rbenv` - Use rbenv to pick a Ruby version for your application and guarantee that your development environment matches production. Put rbenv to work with Bundler for painless Ruby upgrades and bulletproof deployments.

- `ngninx` - Installs nginx from package OR source code and sets up configuration handling similar to Debians Apache2 scripts.

####Attributes

````
default["jellyfish"]["core"]["enabled"] 
default["jellyfish"]["ux"]["enabled"] 
default["jellyfish"]["core"]["cors_allow_origin"]
default["jellyfish"]["ux"]["app_config_js"]
````

####Usage

Simply add recipe[jellyfish] to a run list.

####License

See LICENSE