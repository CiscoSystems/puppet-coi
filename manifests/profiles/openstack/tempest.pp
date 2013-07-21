# Class coi::profiles::openstack::tempest
#
#   this class can be combined with the openstack::controller
#   profile in order to configure a controller to run tempest.
#
#   It both installs/configures tempest and sets up requiered
#   resource for tempest.
#
# == Parameters
#   [identity_uri]
#     Uri that can be used for authentication.
#   [username]
#     User that will be created and used for tests.
#   [password]
#     Password for test user.
#   [tenant_name]
#     Tenant created for tempest tests.
#   [alt_username]
#     A second user created for tempest tests.
#   [alt_password]
#     Password for alt user.
#   [alt_tenant_name]
#     Second tenant create for alt user.
#   [admin_username]
#     Username of existing admin user.
#   [admin_password]
#     Password for admin user.
#   [admin_tenant_name]
#     Existing tenant that admin belongs to.
#   [image_name]
#     Name of image that will be created and used for tests.
#   [image_source]
#     Location of image to install.
#   [image_ssh_user]
#     User on created instances accessible via ssh.
#   [floating_range]
#     Floating ip range to use for testing.
#   [configure_tempest]
#     Whether tempest should be configured.
#   [setup_venv]
#     Whether tempest virtual env should be configured
#     This can take a very long time and cause timeouts.
#   [setup_ovs_bridge]
#     Add an IP to the OVS public bridge interface
#   [resize_available]
#     Configures whether or not tempest should run VM resizing tests. These tests
#     are not supported on the Cirros image.
#     (Optional) Defaults to true.
#   [tempest_revision]
#     The revision of tempest to checkout and use for testing.
#     (Optional). Defaults to stable/grizzly.
#
class coi::profiles::openstack::tempest (
  $identity_uri  = join(['http://',hiera('controller_node_public'),':5000/v2.0/'], ""),

  $username          = hiera('tempest_username', 'user1'),
  $password          = hiera('tempest_password', 'user1_password'),
  $tenant_name       = hiera('tempest_tenant_name', 'tenant1'),

  $alt_username      = hiera('tempest_alt_username', 'user2'),
  $alt_password      = hiera('tempest_alt_password', 'user2_password'),
  $alt_tenant_name   = hiera('tempest_alt_tenant_name', 'tenant2'),

  $admin_username    = hiera('admin_username', 'admin'),
  $admin_password    = hiera('admin_password'),
  $admin_tenant_name = hiera('admin_tenant_name', 'admin'),

  $image_name        = hiera('tempest_image_name', 'cirros'),
  $image_source      = hiera('tempest_image_source',
                  '    http://download.cirros-cloud.net/0.3.1/cirros-0.3.1-x86_64-disk.img'),
  $image_ssh_user    = hiera('tempest_image_ssh_user', 'cirros'),

  $floating_range    = hiera('floating_range', '172.16.2.128/28'),
  $configure_tempest = hiera('configure_tempest', 'true'),
  $setup_venv        = hiera('setup_venv', false),
  $setup_ovs_bridge  = hiera('setup_ovs_bridge', true),
  # tempest parameters
  $resize_available  = hiera('resize_available', true),
  $tempest_revision  = hiera('tempest_revision', 'stable/grizzly')
)
{
  class { 'openstack::provision':
    identity_uri      => $identity_uri,

    username          => $username,
    password          => $password,
    tenant_name       => $tenant_name,

    alt_username      => $alt_username,
    alt_password      => $alt_password,
    alt_tenant_name   => $alt_tenant_name,

    admin_username    => $admin_username,
    admin_password    => $admin_password,
    admin_tenant_name => $admin_tenant_name,

    image_name        => $image_name,
    image_source      => $image_source,
    image_ssh_user    => $image_ssh_user,
    floating_range    => $floating_range,

    configure_tempest => $configure_tempest,
    setup_venv        => $setup_venv,
    setup_ovs_bridge  => $setup_ovs_bridge,

    resize_available  => $resize_available,
    version_to_test   => $tempest_revision,

    require           => [ Service['keystone'],
                           Service['glance-api'],
                           Service['glance-registry']
                         ],

  }
}
