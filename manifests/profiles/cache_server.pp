#
# configures the proxies used by openstack nodes
#
# == Parameters
#  [default_gateway]
#  [proxy]
#    External proxy to use.
#
class coi::profiles::cache_server(
  $default_gateway = hiera('default_gateway', false),
  $proxy           = hiera('proxy', undef)
) inherits coi::profiles::base {

  Exec {
    path => ['/bin','/usr/bin','/sbin','/usr/sbin','/usr/local/bin']
  }

  class { apt-cacher-ng:
    proxy     => $proxy,
    avoid_if_range  => true, # Some proxies have issues with range headers
                             # this stops us attempting to use them
                             # marginally less efficient with other proxies
  }


  # TODO what does this mean?
  if ! $default_gateway {
   include apache

   #
   # TODO - this is one of the few differneces between this and ciscos code
   #   for some reason, the default apache config was missing...
    file { '/etc/apache2/sites-enabled/default':
      ensure => link,
      target => '/etc/apache2/sites-available/default',
      notify => Service['httpd'],
    }
  }

}
