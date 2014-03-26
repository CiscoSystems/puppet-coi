#
# This class 
#
# ==Parameters
#
#  [enabled_services]
#    List of services that should have databases created.
#    Accepts elements: cinder,glance,keystone,nova,network and ceilometer.
#
class coi::profiles::openstack::databases::mysql(
  $enabled_services = [
    'cinder', 'glance', 'keystone', 'nova', 'neutron', 'ceilometer'
  ],
) {

  # delete swift to be nice to users, b/c they may have it
  # as one of their enabled_services
  $real_enabled_services = delete($enabled_services, 'swift')

  coi::databases { $real_enabled_services:
    db_type => 'mysql',
  }

}
