# Wrapper class to get puppetmaster, puppetdb, passenger, and Apache configured
#

class coi::profiles::puppet::master(
  $puppetdb_listen_address    = '0.0.0.0',
  $puppetdb_port              = 8083,
  $puppetdb_ssl_port          = 8081,
  $puppetdb_database_password = 'datapass',
  $puppet_master_bind_address = hiera('puppet_master_address', $::fqdn),
  $modulepath                 = '/etc/puppet/modules:/usr/share/puppet/modules',
  $pluginsync                 = true,
  $autosign                   = true,
  $manifest                   = '/etc/puppet/manifests/site.pp',
) {

  class { 'coi::profiles::puppet::masterpassenger':
    modulepath => $modulepath,
    pluginsync => $pluginsync,
    autosign   => $autosign,
    certname   => $puppet_master_bind_address,
    manifest   => $manifest,
  }

  class { 'coi::profiles::puppet::masterpuppetdb':
    puppetdb_listen_address    => $puppetdb_listen_address,
    puppetdb_port              => $puppetdb_port,
    puppetdb_ssl_port          => $puppetdb_ssl_port,
    puppetdb_database_password => $puppetdb_database_password,
    puppet_master_bind_address => $puppet_master_bind_address,
  }

#
# configure passenger before puppetdb
  Class['coi::profiles::puppet::masterpassenger'] -> Class['coi::profiles::puppet::masterpuppetdb']

#
# and all this before cobbler, for now
  Class['coi::profiles::puppet::masterpuppetdb'] -> Service<|title == cobbler|>

}
