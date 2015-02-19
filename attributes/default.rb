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

# PostgreSQL RPM repo file
default['pgdg_rpm'] = 'http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-redhat93-9.3-1.noarch.rpm'
