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

  #
  # TODO I need to look more into this file to ensure
  # that it should be applied everywhere
  class { "naginator::base_target": }

}
