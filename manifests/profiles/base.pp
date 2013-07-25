#
# this class stores base configurations
# that should be applied to all nodes
#
# == Parameters
#   [ntp_server]
#     List of ntp servers to use for time synchronization.
#
class coi::profiles::base(
  $ntp_servers = hiera('ntp_servers'),
) {

  class { ntp:
    servers    => $ntp_servers,
    autoupdate => true,
  }

  #
  # TODO I need to look more into this file to ensure
  # that it should be applied everywhere
  class { "naginator::base_target": }

}
