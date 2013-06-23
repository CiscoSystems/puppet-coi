class coi::profiles::openstack::compute (
#  $db_host            => $controller_node_internal,
#  $keystone_host      => $controller_node_internal,
#  $quantum_host       => $controller_node_internal,
  $controller_node_internal = hiera('controller_node_internal'),
  $internal_address         = hiera('internal_ip'),
  $libvirt_type             = hiera('libvirt_type', 'kvm'),
  $multi_host               = hiera('multi_host', true),
  # rabbit
  #$rabbit_host              = hiera('controller_node_internal')
  $rabbit_password          = hiera('rabbit_password'),
  $rabbit_user              = hiera('rabbit_user', 'openstack_rabbit_user'),
  # nova
  $nova_user_password       = hiera('nova_user_password'),
  $nova_db_password         = hiera('nova_db_password'),
  #$glance_api_servers       = hiera('"${controller_node_internal}:9292"')
  #$vncproxy_host            = hiera('$controller_node_public')
  #$vnc_enabled              = hiera('true')
  # cinder parameters
  $cinder_db_password       = hiera('cinder_db_password'),
  #$manage_volumes           = hiera('true')
  #$volume_group             = hiera('cinder-volumes')
  #$setup_test_volume        = hiera('true')
  # quantum config
  #$quantum                  = hiera('true')
  $quantum_user_password    = hiera('quantum_user_password'),
  # Quantum OVS
  #$enable_ovs_agent         = hiera('true')
  $tunnel_ip                = hiera('tunnel_ip'),
  # Quantum L3 Agent
  #$enable_l3_agent          = hiera('false')
  #$enable_dhcp_agent        = hiera('false')
  # general
  #$enabled                  = hiera('true')
  $verbose                  = hiera('verbose', false),
  # TODO
  # this is only here b/c special permissions need to be added when we
  # use the packages from cisco's repo. This should just be here
  # temporarily until cisco updates to use the same version of
  # the libvirt package as upstream
  $package_repo             = hiera('package_repo', 'cisco_repo')
) inherits coi::profiles::openstack::base {

  class { '::openstack::compute':
    # keystone
    db_host            => $controller_node_internal,
    keystone_host      => $controller_node_internal,
    quantum_host       => $controller_node_internal,
    internal_address   => $internal_ip,
    libvirt_type       => $libvirt_type,
    multi_host         => $multi_host,
    # rabbit
    rabbit_host        => $controller_node_internal,
    rabbit_password    => $rabbit_password,
    rabbit_user        => $rabbit_user,
    # nova
    nova_user_password => $nova_user_password,
    nova_db_password   => $nova_db_password,
    glance_api_servers => "${controller_node_internal}:9292",
    vncproxy_host      => $controller_node_public,
    vnc_enabled        => true,
    # cinder parameters
    cinder_db_password    => $cinder_db_password,
    manage_volumes        => true,
    volume_group          => 'cinder-volumes',
    setup_test_volume     => true,
    # quantum config
    quantum                               => true,
    quantum_user_password => $quantum_user_password,
    # Quantum OVS
    enable_ovs_agent      => true,
    ovs_local_ip          => $tunnel_ip,
     # Quantum L3 Agent
    enable_l3_agent       => false,
    enable_dhcp_agent     => false,
    # general
    enabled               => true,
    verbose               => $verbose,
  }

  class { "naginator::compute_target": }

  # this is an example of something that needs to be
  # configured only when we use the cisco package repos.
  # I hope this is considered a temporary fix until we
  # can make our packages more similar to those in cloud
  # archive
  if $package_repo == 'cisco_repo' {
    realize File['/etc/libvirt/qemu.conf']
    realize Exec[ '/etc/init.d/libvirt-bin restart']
  }

}
