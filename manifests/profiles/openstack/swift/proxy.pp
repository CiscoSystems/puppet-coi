#
# Installs swift proxy.
#
# == Parameters
#  [swift_hash_suffix]
#  [swift_user_password]
#    Auth password for swift. (required)
#  [controller_node_address]
#    Address of controller node (used to connect to keystone)
#  [swift_public_address]
#    Ip address that swift proxy binds to.
#
class coi::profiles::openstack::swift::proxy(
  $swift_hash              = hiera('swift_hash'),
  $swift_user_password     = hiera('swift_user_password'),
  $controller_node_address = hiera('controller_node_address'),
  $swift_public_address    = hiera('swift_public_address'),
  $swift_internal_address  = hiera('swift_local_net_ip'),
) {

  class {'::openstack::swift::proxy':
    swift_proxy_net_ip      => $swift_public_address,
    swift_local_net_ip      => $swift_internal_address,
    keystone_host           => $controller_node_address,
    controller_node_address => $controller_node_address,
    swift_user_password     => $swift_user_password,
    swift_hash_suffix       => $swift_hash,
  }

}
