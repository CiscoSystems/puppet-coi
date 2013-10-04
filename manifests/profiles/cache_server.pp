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
    # Prefetch the pip packages and put them somewhere the openstack nodes can fetch them

    include pip
    include coi::profiles::params

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
      command => "${proxy_pfx}pip install pip2pi",
      unless => 'which pip2pi',
      require => Package['python-pip'],
    }
    Package <| provider=='pip' |> {
      require => Exec['pip-cache']
    }

    ensure_resource('package', 'python-twisted', {'ensure' => 'installed' })

    exec { 'pip-cache':
      # All the packages that all nodes - build, compute and control - require from pip
      command => "${proxy_pfx}pip2pi /var/www/packages collectd xenapi django-tagging graphite-web carbon whisper",
      creates => '/var/www/packages/simple', # It *does*, but you'll want to force a refresh if you change the line above
      require => [Exec['pip2pi'], Package['python-twisted']],
    }


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
