class coi::profiles::openstack::tempest (
  $identity_host  = hiera('controller_node_public'),
  $admin_password = hiera('admin_password'),
  $image_host     = hiera('controller_node_public'),
)
{
    class { '::tempest':
      require => [ Service['keystone'],
                   Service['glance-api'],
                   Service['glance-registry']
                 ],
      identity_host  => $identity_host,
      admin_password => $admin_password,
      image_host     => $image_host
    }
}
