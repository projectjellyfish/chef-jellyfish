chef-jellyfish Cookbook
=======================

[![Build Status](https://travis-ci.org/projectjellyfish/chef-jellyfish.svg?branch=master)](https://travis-ci.org/projectjellyfish/chef-jellyfish)

Pulls down the latest Project Jellyfish code, builds the code, installs the dependencies, and then starts nginx, rails, and node.

Requirements
------------
### Platforms
Tested on RHEL 6.5 and CentOS 6.5. Should work on any Red Hat family distribution.

###Cookbooks
 - rbenv
 - nginx

Attributes
----------
######Attributes specifically for Project Jellyfish
- `default["jellyfish"]["api"]["enabled"]` - Enable the install of Jellyfish API
- `default["jellyfish"]["ux"]["enabled"]` - Enable the install of Jellyfish UX
- `default["jellyfish"]["api"]["cors_allow_origin"]` - Comma seperated list of host that you want to be able to access Jellyfish API
- `default["jellyfish"]["ux"]["app_config_js"]` - Single FQDN: https://some-host.company.com:port (if port is different that the standard port)

Usage
-----
Simply add recipe[jellyfish] to a run list or add the cookbook to a role you have created. 


Deploying a Project Jellyfish Server
-----------

This section details "quick deployment" steps.

1. Install Chef Client


          curl -L https://www.opscode.com/chef/install.sh | sudo bash

2. Create a Chef repo folder and a cookbooks folder under the /tmp directory


          mkdir -p /tmp/chef/cookbooks
          cd /tmp/chef/

3. Create a solo.rb file, run the commands below



          cat <<EOF > /tmp/chef/solo.rb
                    file_cache_path "/tmp/chef"
                    cookbook_path "/tmp/chef/cookbooks"
          EOF
 


4. Create a manageiq.json file, this will be the attributes file and contains the run_list, run the commands below


          cat <<EOF > /tmp/chef/chef-jellyfish.json
          {
                    "run_list": [
                    "recipe[chef-jellyfish]"
                    ]
          }
          EOF

4. Install dependencies:

        cd /tmp/chef/cookbooks
        
        knife cookbook site download rbenv
        tar xvfz rbenv-*.tar.gz
        rm -f rbenv-*.tar.gz    
        
        knife cookbook site download nginx
        tar xvfz nginx-*.tar.gz
        rm -f nginx-*.tar.gz     
        
        knife cookbook site download apt
        tar xvfz apt-*.tar.gz
        rm -f apt-*.tar.gz
        
        knife cookbook site download yum-epel
        tar xvfz yum-epel-*.tar.gz
        rm -f yum-epel-*.tar.gz
        
        knife cookbook site download runit
        tar xvfz runit-*.tar.gz
        rm -f runit-*.tar.gz
        
        knife cookbook site download ohai
        tar xvfz ohai-*.tar.gz
        rm -f ohai-*.tar.gz
        
        knife cookbook site download build-essential
        tar xvfz build-essential-*.tar.gz
        rm -f build-essential-*.tar.gz
       
        knife cookbook site download bluepill
        tar xvfz bluepill-*.tar.gz
        rm -f bluepill-*.tar.gz
        
        knife cookbook site download yum
        tar xvfz yum-*.tar.gz
        rm -f yum-*.tar.gz
        
        knife cookbook site download rsyslog
        tar xvfz rsyslog-*.tar.gz
        rm -f rsyslog-*.tar.gz
        
        knife cookbook site download git
        tar xvfz git-*.tar.gz
        rm -f git-*.tar.gz
        
        knife cookbook site download dmg
        tar xvfz dmg-*.tar.gz
        rm -f dmg-*.tar.gz
        
        knife cookbook site download windows
        tar xvfz windows-*.tar.gz
        rm -f windows-*.tar.gz
        
        
6. Download and extract the cookbook:

          yum install -y wget
          wget https://github.com/projectjellyfish/chef-jellyfish/archive/master.tar.gz
          tar xvfz master
          rm master
          mv chef-jellyfish-master/ chef-jellyfish
    
7. Run Chef-solo:

          cd /tmp/chef
          chef-solo -c solo.rb -j chef-jellyfish.json

License & Authors
-----------------
- Author:: Thomas A. McGonagle

```text
Copyright:: 2014, Booz Allen Hamilton

For more information on the license, please refer to the LICENSE.txt file in the repo
```
