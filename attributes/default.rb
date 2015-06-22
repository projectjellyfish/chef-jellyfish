
# What version of Ruby do we need to install?
default['ruby']['version'] = '2.2.2'

# Which version of postgres:
default['postgresql']['version'] = '9.4'

# Which version of pg gem:
default['pg']['version'] = '0.18.2'

# Load sample data?
default['sampledata'] = true

# Our random api secret key
self.class.send(:include, Opscode::OpenSSL::Password)
default['rdkey'] = secure_password(128)

pp "Key: #{default['rdkey']}"
# The Rails Enviroment to use
default['rails_env'] = 'production'

default['jellyfishuser']['user'] = 'jellyfish'
default['jellyfishuser']['home'] = '/home/jellyfish'
default['jellyfishuser']['group'] = 'users'

# Postgres Details:
default['postgresql']['jellyfish_dbpass'] = 'myPassword'
default['postgresql']['jellyfish_db']     = 'jellyfish_production'
default['postgresql']['jellyfish_user']   = 'jellyfish'
default['postgresql']['dir']   = '/var/lib/pgsql'
# @todo: Ability to use an external PostgreSQL server

# -- End Config Vars --
# These are the repo urls for Postgres,
# from here: http://yum.postgresql.org/repopackages.php#pg94
#
# if need different version or platform, add here.
default['postgresql']['pgdg']['repo_rpm_url'] = {
  '9.4' => {
    'amazon' => {
      '2014' => {
        'i386' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-i386/pgdg-redhat94-9.4-1.noarch.rpm',
        'x86_64' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-redhat94-9.4-1.noarch.rpm'
      },
      '2013' => {
        'i386' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-i386/pgdg-redhat94-9.4-1.noarch.rpm',
        'x86_64' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-redhat94-9.4-1.noarch.rpm'
      }
    },
    'redhat' => {
      '7' => {
        'x86_64' => 'http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-redhat94-9.4-1.noarch.rpm'
      },
      '6' => {
        'x86_64' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-redhat94-9.4-1.noarch.rpm'
      }
    },
    'centos' => {
      '7' => {
        'x86_64' => 'http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-1.noarch.rpm'
      },
      '6' => {
        'i386' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-i386/pgdg-centos94-9.4-1.noarch.rpm',
        'x86_64' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-1.noarch.rpm'
      }
    }
  }
}
