class coi::roles::compute {

  include kickstack::compute
  include coi::profiles::openstack::base
  include naginator::compute_target

}
