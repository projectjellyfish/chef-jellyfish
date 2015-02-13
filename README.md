chef-jellyfish Cookbook
=======================

[![Build Status](https://travis-ci.org/projectjellyfish/chef-jellyfish.svg?branch=master)](https://travis-ci.org/projectjellyfish/chef-jellyfish)

Pulls down the latest Project Jellyfish code, builds the code, installs the dependencies, and then starts nginx, rails, and node.

Requirements
------------
### Platforms
Tested on RHEL 6.5 and CentOS 6.5. Should work on any Red Hat family distribution.

###Cookbooks
-rbenv


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

3. Create a solo.rb file


          vi /tmp/chef/solo.rb
         
               file_cache_path "/tmp/chef/"
               cookbook_path "/tmp/chef/cookbooks"

4. Create a manageiq.json file, this will be the attributes file and contains the run_list


          vi /tmp/chef/chef-jellyfish.json
        
                {
                  "run_list": [
                  "recipe[chef-jellyfish]"
                 ]
                }


4. Install dependencies:

        cd /tmp/chef/cookbooks
        
        knife cookbook site download rbenv
        tar xvfz rbenv-*.tar.gz
        rm -f rbenv-*.tar.gz        
        
       
6. Download and extract the cookbook:

          yum install -y wget
          wget https://github.com/projectjellyfish/chef-jellyfish/archive/master.zip
          tar xvfz master.tar.gz 
          rm -rf master.tar.gz 
          mv chef-jellyfish-master/ chef-jellyfish
    
7. Run Chef-solo:

          cd /tmp/chef
          chef-solo -c solo.rb -j manageiq.json

License & Authors
-----------------
- Author:: Thomas A. McGonagle

```text
Copyright:: 2014, Booz Allen Hamilton

For more information on the license, please refer to the LICENSE.txt file in the repo
```
