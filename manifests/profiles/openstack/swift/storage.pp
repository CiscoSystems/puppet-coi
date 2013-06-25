#
# Installs a swift storage node
#
# == Parameters
#  [swift_hash_suffix]
#    Shared secret used by swift nodes.
#  [storage_zone]
#    Zone that storage node is located in. A swift cluster must
#    have at least one node in the same number of zones set
#    as number_replicas
#  [swift_local_net_ip]
#    Ip address where internal swift traffic will flow.
#  [storage_type]
#    Type of storage to be configured for swift node.
#  [storage_devices]
#    Storage devices swift will utilize.
#
class coi::profiles::openstack::swift::storage(
  $swift_hash         = hiera('swift_hash'),
  $swift_zone         = hiera('swift_zone'),
  $swift_local_net_ip = hiera('swift_local_net_ip'),
  $storage_type       = hiera('storage_type'),
  $storage_devices    = hiera('storage_devices')
) {

  class {'openstack::swift::storage-node':
    swift_zone         => $swift_zone,
    swift_local_net_ip => $swift_local_net_ip,
    storage_type       => $storage_type,
    storage_devices    => $storage_devices,
    swift_hash_suffix  => $swift_hash,
  }

}
