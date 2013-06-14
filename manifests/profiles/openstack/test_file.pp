#
# deploys a basic file that can be used to test openstack deployments.
#
class coi::profiles::openstack::test_file (
  $test_file_image_type = hiera('test_file_image_type', 'kvm')
) inherits coi::profiles::openstack::auth_file {

  # TODO : this should be able to configure
  # whether we are testing quantum or nova_networks
  class { '::openstack::test_file':
    image_type => $test_file_image_type,
  }

}
