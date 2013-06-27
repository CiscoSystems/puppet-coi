#
# Installs the usual control server
# plus the tempest test suite
#
class coi::roles::controller::tempest {
  include coi::roles::controller
  include coi::profiles::openstack::tempest
}
