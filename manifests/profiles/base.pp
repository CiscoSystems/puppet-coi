#
# this class stores base configurations
# that should be applied to all nodes
#
class coi::profiles::base {

  class { ntp:
    servers    => hiera('ntp_servers'),
    ensure     => running,
    autoupdate => true,
  }

  #
  # TODO I need to look more into this file to ensure
  # that it should be applied everywhere
  class { "naginator::base_target": }

}
