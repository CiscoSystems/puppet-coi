#
# this is the COI build server.
#
class coi::roles::build_server (
  $enable_cobbler      = hiera('enable_cobbler', $::coi::roles::params::enable_cobbler),
  $enable_cache        = hiera('enable_cache', $::coi::roles::params::enable_cache),
  $enable_monitoring   = hiera('enable_monitoring', true),
  ){
  include coi::profiles::puppet::master

  if ($enable_monitoring) {
    include coi::profiles::monitoring_server
  }

  if ($enable_cobbler) {
    include coi::profiles::cobbler_server
  }

  if ($enable_cache) {
    include coi::profiles::cache_server
  }

}
