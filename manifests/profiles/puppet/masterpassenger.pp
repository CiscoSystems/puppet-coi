# Class to configure a puppetmaster with passenger and Apache integration
#  - assumes trusty native packages for puppet, passenger, and Apache
#

class coi::profiles::puppet::masterpassenger(
  $modulepath = '/etc/puppet/modules:/usr/share/puppet/modules',
  $pluginsync = true,
  $autosign   = true,
  $certname   = hiera('puppet_master_address', $::fqdn),
  $manifest   = '/etc/puppet/manifests/site.pp',
) {

  package { 'puppet-common':
    ensure => present,
  }

  package { 'puppet':
    ensure  => present,
    require => Package['puppet-common'],
  }

  package { 'puppetmaster-common':
    ensure => present,
  }

  package { 'puppetmaster-passenger':
    ensure  => present,
    require => Package['puppetmaster-common'],
  }

#
# build the Apache vhost from a template
  file { "40-puppet-$certname.conf":
    ensure  => present,
    path    => "/etc/apache2/sites-available/40-puppet-$certname.conf",
    content => template('coi/puppetmaster.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [Package['httpd'], Package['puppetmaster-passenger']],
    notify  => Service['httpd'],
  }

  file{ "40-puppet-$::fqdn.conf symlink":
    ensure  => link,
    path    => "/etc/apache2/sites-enabled/40-puppet-$certname.conf",
    target  => "/etc/apache2/sites-available/40-puppet-$certname.conf",
    require => File["40-puppet-$certname.conf"],
    notify  => Service['httpd'],
  }

#
# load basic modules needed for Apache with Passenger

  define modulelink {
    file { "${title} load":
      ensure => link,
      path   => "/etc/apache2/mods-enabled/${title}.load",
      target => "/etc/apache2/mods-available/${title}.load",
      notify => Service['httpd'],
    }
  }

  define conflink {
    file { "${title} conf":
      ensure => link,
      path   => "/etc/apache2/mods-enabled/${title}.conf",
      target => "/etc/apache2/mods-available/${title}.conf",
      notify => Service['httpd'],
    }
  }

  # socache_shmcb is needed for ssl
  # access_compat is needed for Apache 2.2 style configs since we use 2.4
  modulelink { [ "socache_shmcb",
    "headers",
    "passenger",
    "ssl",
    "access_compat" ]: }

  conflink { [ "passenger", "ssl" ]: }

#
# basic puppet ini settings needed
  Ini_setting {
    path    => '/etc/puppet/puppet.conf',
    require => Package['puppet'],
    notify  => Service['httpd'],
    section => 'master',
  }

  ini_setting {'puppetmastermodulepath':
    ensure  => present,
    setting => 'modulepath',
    value   => $modulepath,
  }

  ini_setting {'puppetmastermanifest':
    ensure  => present,
    setting => 'manifest',
    value   => $manifest,
  }

  ini_setting {'puppetmasterautosign':
    ensure  => present,
    setting => 'autosign',
    value   => $autosign,
  }

  ini_setting {'puppetmastercertname':
    ensure  => present,
    setting => 'certname',
    value   => $certname,
  }

  ini_setting {'puppetmasterpluginsync':
    ensure  => present,
    setting => 'pluginsync',
    value   => $pluginsync,
  }

}
