#
# this profile configures a machine
# as a puppetmaster.
#
# [*puppetlabs_repo*]
# (optional) Sets the apt/yum repository from which
# puppet master will be installed to be puppetlabs
# Default: true
#
# [*puppetdb_listen_address*]
# (optional) Sets the hostname or IP address on which
# PuppetDB will listen.
# Default: 0.0.0.0
#
# [*puppetdb_port*]
# (optional) Sets the port on which puppetdb should listen
# for unencrypted incoming connections.  Note that port
# 8080 is used by Swift proxy, so this is set to 8083 by
# default to avoid conflicts.
# Default: 8083
#
# [*puppetdb_ssl_port*]
# (optional) Sets the port on which puppetdb should listen
# for encrypted incoming connections.
# Default: 8081

class coi::profiles::puppet::master (
  $puppetlabs_repo         = hiera('puppetlabs_repo', true),
  $puppetdb_listen_address = '0.0.0.0',
  $puppetdb_port           = 8083,
  $puppetdb_ssl_port       = 8081,
) inherits coi::profiles::base {

  $puppet_master_bind_address = hiera('puppet_master_address', $::fqdn)
  # installs puppet
  # I think I want to assume a puppet 3.x install

  # if this is not set, make sure nodes are all pointing at an apt/yum repo
  # that has puppet > 3.2
  if $puppetlabs_repo {
    include puppet::repo::puppetlabs
  }

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
    puppetdb_port   => $puppetdb_port,
    use_ssl         => false,
    timeout         => 240,
    notify          => Class['apache'],
  }

  # install puppet master
  class { '::puppet::master':
    certname    => $::fqdn,
    autosign    => true,
    modulepath  => '/etc/puppet/modules:/usr/share/puppet/modules',
  }

  # install puppetdb and postgresql
  class { 'puppetdb':
    listen_address     => $puppetdb_listen_address,
    listen_port        => $puppetdb_port,
    ssl_listen_address => $puppetdb_listen_address,
    ssl_listen_port    => $puppetdb_ssl_port,
    database_password  => 'datapass',
    
  }

  # Configure the puppet master to use puppetdb.
  class { 'puppetdb::master::config':
    puppetdb_server   => $puppet_master_bind_address,
    puppetdb_port     => $puppetdb_ssl_port,
    restart_puppet    => false,
    # I only want to validate with http
    strict_validation => false,
  }

  # Add puppetdb storeconfigs settings to puppet.conf [main] also
  # so that puppet agent runs will use storeconfigs
  Ini_setting {
    path    => $::puppet::params::puppet_conf,
    require => File[$::puppet::params::puppet_conf],
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

}
