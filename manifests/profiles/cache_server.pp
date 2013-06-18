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


  class { apt-cacher-ng:
    proxy           => $proxy,
    avoid_if_range  => true, # Some proxies have issues with range headers
                             # this stops us attempting to use them
                             # marginally less efficient with other proxies
  }

  # TODO what does this mean?
  if ! $default_gateway {
    # Prefetch the pip packages and put them somewhere the openstack nodes can fetch them

    include pip

    file {  "/var/www":
      ensure => 'directory',
    }

    file {  "/var/www/packages":
      ensure  => 'directory',
      require => File['/var/www'],
    }

    if($::proxy) {
      $proxy_pfx = "/usr/bin/env http_proxy=${::proxy} https_proxy=${::proxy} "
    } else {
      $proxy_pfx=""
    }
    exec { 'pip2pi':
      # Can't use package provider because we're changing its behaviour to use the cache
      command => "${proxy_pfx}/usr/bin/pip install pip2pi",
      creates => "/usr/local/bin/pip2pi",
      require => Package['python-pip'],
    }
    Package <| provider=='pip' |> {
      require => Exec['pip-cache']
    }
    exec { 'pip-cache':
      # All the packages that all nodes - build, compute and control - require from pip
      command => "${proxy_pfx}/usr/local/bin/pip2pi /var/www/packages collectd xenapi django-tagging graphite-web carbon whisper",
      creates => '/var/www/packages/simple', # It *does*, but you'll want to force a refresh if you change the line above
      require => Exec['pip2pi'],
    }
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
