name             'chef-jellyfish'
maintainer       'Booz Allen Hamilton'
maintainer_email 'jellyfishopensource@bah.com'
license          'Apache 2.0'
description      'Installs/Configures Jellyfish'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'
supports         'rhel'
supports         'centos'


depends 'rbenv'
depends 'nginx'