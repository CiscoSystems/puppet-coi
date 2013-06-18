#
# this is the COI build server.
#
class coi::roles::build_server {
  #include coi::profiles::puppet::master
  #include coi::profiles::monitoring_server
  include coi::profiles::cobbler_server
  #include coi::profiles::cache_server
}
