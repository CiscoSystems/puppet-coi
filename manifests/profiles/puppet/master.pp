#
# this profile configures a machine
# as a puppetmaster.
#
# It also sets up the repos used to install
# Puppet (this may not be required)
#
class coi::profiles::puppet::master inherits coi::profiles::base {

  $puppet_master_bind_address = hiera('puppet_master_address', $::fqdn)
  # installs puppet
  # I think I want to assume a puppet 3.x install

  include apache

  # the puppetdb package should not be installed
  # before our certificate is generated
  Exec['Certificate_Check'] -> Package['puppetdb']

  # we need to validate the puppetdb http connection
  # and not the https one b/c will not have access to
  # the certificate b/c we create it during the puppet
  # run
  Service['puppetdb'] -> Puppetdb_conn_validator['puppetdb_conn_http']
  puppetdb_conn_validator { 'puppetdb_conn_http':
    ensure          => present,
    puppetdb_server => $puppet_master_bind_address,
    puppetdb_port   => 8080,
    use_ssl         => false,
    timeout         => 240,
    notify          => Class['apache'],
  }

  # install puppet master
  class { '::puppet::master':
    certname    => $::fqdn,
    autosign    => true,
    modulepath  => '/etc/puppet/modules',
  }

  # install puppetdb and postgresql
  class { 'puppetdb':
    listen_address     => $puppet_master_bind_address,
    ssl_listen_address => $puppet_master_bind_address,
    database_password  => 'datapass',
  }

  # Configure the puppet master to use puppetdb.
  class { 'puppetdb::master::config':
    puppetdb_server   => $puppet_master_bind_address,
    puppetdb_port     => 8081,
    restart_puppet    => false,
    # I only want to validate with http
    strict_validation => false,
  }
}
