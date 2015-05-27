
# Which version of postgres:
default['postgresql']['version'] = "9.4"

# Load sample data?
default['sampledata'] = true

# Our random api secret key
default['rdkey'] = 'd2924512f097d80a1c33cfa416c01cfe93b90912b83ad8dd254205e83915979e3bb08d38cad2e43dcd6db2f4aea53d8c6c41545dc6daaa50dbca9cc7f2612342'

# The Rails Enviroment to use
default['rails_env'] = 'production'

# Postgres Details:
default['postgresql']['jellyfish_dbpass'] = 'myPassword'
default['postgresql']['jellyfish_db']     = 'jellyfish_production'
default['postgresql']['jellyfish_user']   = 'jellyfish'

# -- End Config Vars --
# These are the repo urls for Postgres,
# from here: http://yum.postgresql.org/repopackages.php#pg94
#
# if need different version or platform, add here.
default['postgresql']['pgdg']['repo_rpm_url'] = {
  "9.4" => {
    "amazon" => {
      "2014" => {
        "i386" => "http://yum.postgresql.org/9.4/redhat/rhel-6-i386/pgdg-redhat94-9.4-1.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-redhat94-9.4-1.noarch.rpm"
      },
      "2013" => {
        "i386" => "http://yum.postgresql.org/9.4/redhat/rhel-6-i386/pgdg-redhat94-9.4-1.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-redhat94-9.4-1.noarch.rpm"
      }
    },
    "redhat" => {
      "7" => {
        "x86_64" => "http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-redhat94-9.4-1.noarch.rpm"
      },
      "6" => {
        "x86_64" => "http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-redhat94-9.4-1.noarch.rpm"
      },
    },
    "centos" => {
      "7" => {
        "x86_64" => "http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-1.noarch.rpm"
      },
      "6" => {
        "i386" => "http://yum.postgresql.org/9.4/redhat/rhel-6-i386/pgdg-centos94-9.4-1.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-1.noarch.rpm"
      }
    }
  }
}
