# Class to configure puppetdb and a puppetmaster to use that puppetdb
#  - assumes that puppetdb and puppetmaster are colocated
#  - assumes trusty native packages for puppet w/ supplemental puppetdb
#      packages from the Cisco repo
#

class coi::profiles::puppet::masterpuppetdb(
  $puppetdb_listen_address    = '0.0.0.0',
  $puppetdb_port              = 8083,
  $puppetdb_ssl_port          = 8081,
  $puppetdb_database_password = 'datapass',
  $puppet_master_bind_address = hiera('puppet_master_address', $::fqdn),
) {

#
# install puppetdb and postgresql
  class { 'puppetdb':
    listen_address     => $puppetdb_listen_address,
    listen_port        => $puppetdb_port,
    ssl_listen_address => $puppetdb_listen_address,
    ssl_listen_port    => $puppetdb_ssl_port,
    database_password  => $puppetdb_database_password,
  }

#
# configure puppet to use puppetdb
  class { 'puppetdb::master::config':
    puppetdb_server   => $puppet_master_bind_address,
    puppetdb_port     => $puppetdb_ssl_port,
    restart_puppet    => false,
    # only validate with http
    strict_validation => false,
  }

#
# configure storeconfigs and reports with puppetdb
  Ini_setting {
    path    => '/etc/puppet/puppet.conf',
    require => [Package['puppet'], Package['puppetdb']],
    notify  => Service['httpd'],
    section => 'main',
    ensure  => present,
  }

  ini_setting { 'puppetmainstoreconfigs':
    setting => 'storeconfigs',
    value   => 'true',
  }

  ini_setting { 'puppetmainstoreconfigs_backend':
    setting => 'storeconfigs_backend',
    value   => 'puppetdb',
  }

  ini_setting { 'puppetmasterreports':
    setting => 'reports',
    value   => 'store,puppetdb',
    section => 'master',
  }
}
