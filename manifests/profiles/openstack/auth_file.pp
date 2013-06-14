#
# Deploys the file /root/openrc which is
# populated with the environments required
# to authenticate with openstack.
#
class coi::profiles::openstack::auth_file (
  $admin_password           = hiera('admin_password'),
  $keystone_admin_token     = hiera('keystone_admin_token'),
  $controller_node_internal = hiera('controller_node_internal')
) {

  class { '::openstack::auth_file':
    admin_password       => $admin_password,
    keystone_admin_token => $keystone_admin_token,
    controller_node      => $controller_node_internal,
  }

}
