# Enable the install of Jellyfish-API
default["jellyfish"]["core"]["enabled"] = "true"

# Enable the install of Jellyfish-UX
default["jellyfish"]["ux"]["enabled"] = "true"

# The CORS for Jellyfish-API
# Comma seperated list of host that you want to be able to access Jellyfish API
default["jellyfish"]["core"]["cors_allow_origin"] = "127.0.0.1:5050,localhost:5050,localhost:80,localhost:443"

# The URL of the Jellyfish-API that UX should be using
# Single FQDN: https://some-host.company.com:port (if port is different that the standard port)
default["jellyfish"]["ux"]["app_config_js"] = "localhost:3030"

