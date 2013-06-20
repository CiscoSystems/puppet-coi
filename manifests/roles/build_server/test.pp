#
# Slight derivation of the build server
# that also installs all of the required
# clients, auth file, and a file that can
# run some basic tests
#
class coi::roles::build_server::test {
  include coi::roles::build_server
  include coi::profiles::openstack::test_file
}
