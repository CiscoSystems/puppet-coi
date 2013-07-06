#
# base class that installs components used by
# all openstack profiles.
#
class coi::profiles::openstack::base (
  $domain_name              = hiera('domain_name'),
  # connection information for build node
  $build_node_name          = hiera('build_node_name'),
  # connection information for controller
  $controller_hostname      = hiera('controller_hostname'),
  $controller_node_internal = hiera('controller_node_internal'),
  # information about which repos to use
  $package_repo             = hiera('package_repo', 'cisco_repo'),
  $openstack_release        = hiera('openstack_release', 'grizzly-proposed'),
  $openstack_repo_location  = hiera('openstack_repo_location', false),
  # optional external services
  $default_gateway          = hiera('default_gateway', false),
  $proxy                    = hiera('proxy', false),
  $public_interface         = hiera('public_interface')
) inherits coi::profiles::base {

  $build_node_fqdn = "${build_node_name}.${domain_name}"

  if ($osfamily == 'debian') {
    # Disable pipelining to avoid unfortunate interactions between apt and
    # upstream network gear that does not properly handle http pipelining
    # See https://bugs.launchpad.net/ubuntu/+source/apt/+bug/996151 for details
    file { '/etc/apt/apt.conf.d/00no_pipelining':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => 'Acquire::http::Pipeline-Depth "0";'
    }

    # Load apt prerequisites.  This is only valid on Ubuntu systmes

    if($package_repo == 'cisco_repo') {
      if ! $openstack_repo_location {
        fail("Parameter openstack_repo_location must be set when package_repo is cisco_repo")
      }
      apt::source { "cisco-openstack-mirror_grizzly":
        location    => $openstack_repo_location,
        release     => $openstack_release,
        repos       => "main",
        key         => "E8CC67053ED3B199",
        key_content => '-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.11 (GNU/Linux)

mQENBE/oXVkBCACcjAcV7lRGskECEHovgZ6a2robpBroQBW+tJds7B+qn/DslOAN
1hm0UuGQsi8pNzHDE29FMO3yOhmkenDd1V/T6tHNXqhHvf55nL6anlzwMmq3syIS
uqVjeMMXbZ4d+Rh0K/rI4TyRbUiI2DDLP+6wYeh1pTPwrleHm5FXBMDbU/OZ5vKZ
67j99GaARYxHp8W/be8KRSoV9wU1WXr4+GA6K7ENe2A8PT+jH79Sr4kF4uKC3VxD
BF5Z0yaLqr+1V2pHU3AfmybOCmoPYviOqpwj3FQ2PhtObLs+hq7zCviDTX2IxHBb
Q3mGsD8wS9uyZcHN77maAzZlL5G794DEr1NLABEBAAG0NU9wZW5TdGFja0BDaXNj
byBBUFQgcmVwbyA8b3BlbnN0YWNrLWJ1aWxkZEBjaXNjby5jb20+iQE4BBMBAgAi
BQJP6F1ZAhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRDozGcFPtOxmXcK
B/9WvQrBwxmIMV2M+VMBhQqtipvJeDX2Uv34Ytpsg2jldl0TS8XheGlUNZ5djxDy
u3X0hKwRLeOppV09GVO3wGizNCV1EJjqQbCMkq6VSJjD1B/6Tg+3M/XmNaKHK3Op
zSi+35OQ6xXc38DUOrigaCZUU40nGQeYUMRYzI+d3pPlNd0+nLndrE4rNNFB91dM
BTeoyQMWd6tpTwz5MAi+I11tCIQAPCSG1qR52R3bog/0PlJzilxjkdShl1Cj0RmX
7bHIMD66uC1FKCpbRaiPR8XmTPLv29ZTk1ABBzoynZyFDfliRwQi6TS20TuEj+ZH
xq/T6MM6+rpdBVz62ek6/KBcuQENBE/oXVkBCACgzyyGvvHLx7g/Rpys1WdevYMH
THBS24RMaDHqg7H7xe0fFzmiblWjV8V4Yy+heLLV5nTYBQLS43MFvFbnFvB3ygDI
IdVjLVDXcPfcp+Np2PE8cJuDEE4seGU26UoJ2pPK/IHbnmGWYwXJBbik9YepD61c
NJ5XMzMYI5z9/YNupeJoy8/8uxdxI/B66PL9QN8wKBk5js2OX8TtEjmEZSrZrIuM
rVVXRU/1m732lhIyVVws4StRkpG+D15Dp98yDGjbCRREzZPeKHpvO/Uhn23hVyHe
PIc+bu1mXMQ+N/3UjXtfUg27hmmgBDAjxUeSb1moFpeqLys2AAY+yXiHDv57ABEB
AAGJAR8EGAECAAkFAk/oXVkCGwwACgkQ6MxnBT7TsZng+AgAnFogD90f3ByTVlNp
Sb+HHd/cPqZ83RB9XUxRRnkIQmOozUjw8nq8I8eTT4t0Sa8G9q1fl14tXIJ9szzz
BUIYyda/RYZszL9rHhucSfFIkpnp7ddfE9NDlnZUvavnnyRsWpIZa6hJq8hQEp92
IQBF6R7wOws0A0oUmME25Rzam9qVbywOh9ZQvzYPpFaEmmjpCRDxJLB1DYu8lnC4
h1jP1GXFUIQDbcznrR2MQDy5fNt678HcIqMwVp2CJz/2jrZlbSKfMckdpbiWNns/
xKyLYs5m34d4a0it6wsMem3YCefSYBjyLGSd/kCI/CgOdGN1ZY1HSdLmmjiDkQPQ
UcXHbA==
=v6jg
-----END PGP PUBLIC KEY BLOCK-----',
        proxy => $proxy,
      }

      apt::pin { "cisco":
        priority => '990',
        originator => 'Cisco'
      }
    } elsif($package_repo == 'cloud_archive') {
      if $location {
        $cloud_archive_location = $location
      } else {
        $cloud_archive_location = 'http://ubuntu-cloud.archive.canonical.com/ubuntu'
      }
      apt::source { 'openstack_cloud_archive':
        location          => $cloud_archive_location,
        release           => $openstack_release,
        repos             => 'main',
        required_packages => 'ubuntu-cloud-keyring',
      }
    } else {
      fail("Unsupported package repo ${package_repo}")
    }
  }
  elsif ($osfamily == 'redhat') {

    yumrepo { 'cisco-openstack-mirror':
      descr    => 'Cisco Openstack Repository',
      baseurl  => $location,
      gpgcheck => '0', #TODO: Add gpg key
      enabled  => '1';
    }

    include openstack::repo::rdo

    # add a resource dependency so yumrepo loads before package
    Yumrepo <| |> -> Package <| |>
  }

  include pip

  # Ensure that the pip packages are fetched appropriately when we're using an
  # install where there's no direct connection to the net from the openstack
  # nodes
  if ! $default_gateway {
    Package <| provider=='pip' |> {
      install_options => "--index-url=http://${build_node_name}/packages/simple/",
    }
  } else {
    if($proxy) {
      Package <| provider=='pip' |> {
        # TODO(ijw): untested
        install_options => "--proxy=$proxy"
      }
    }
  }
  # (the equivalent work for apt is done by the cobbler boot, which sets this up as
  # a part of the installation.)


  # /etc/hosts entries for the controller nodes
  host { $controller_hostname:
    ip => $controller_node_internal
  }

  class { 'collectd':
    #graphitehost         => $build_node_fqdn,
    #management_interface => $public_interface,
  }
}
