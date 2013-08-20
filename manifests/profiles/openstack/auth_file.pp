#
# Deploys the file /root/openrc which is
# populated with the environments required
# to authenticate with openstack.
#
class coi::profiles::openstack::auth_file (
  $admin_password           = hiera('admin_password'),
  $controller_node_internal = hiera('auth_internal_address')
) {

  # WARNING - this may cause a conflict b/c this installs the collecd agent
  # which may already be installed
  include coi::profiles::openstack::base
  class { 'openstack::client':
    ceilometer => false,
  }


  class { '::openstack::auth_file':
    admin_password       => $admin_password,
    controller_node      => $controller_node_internal,
  }

}
