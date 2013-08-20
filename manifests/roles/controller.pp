class coi::roles::controller {
  include kickstack::controller
  include kickstack::network_controller
  include coi::profiles::openstack::test_file
  include coi::profiles::openstack::base
  include naginator::control_target
}
