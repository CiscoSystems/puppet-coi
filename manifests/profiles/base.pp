#
# this class stores base configurations
# that should be applied to all nodes
#
# == Parameters
#   [ntp_servers]
#     List of ntp servers to use for time synchronization.
#
class coi::profiles::base(
  $ntp_servers = hiera('ntp_servers'),
) {

  class { ntp:
    servers => $ntp_servers,
  }

}
