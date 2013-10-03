#
# hosts all services that centrally collect monitoring data
#
class coi::profiles::monitoring_server(
  # TODO why is build_node_fqdn for?
  # why would it not just be fqdn?
  # should this default to 0.0.0.0 ?
  #$graphitehost  => hiera('build_node_fqdn', $::fqdn)
)  inherits coi::profiles::base {

  include apache

  class { 'naginator': }

  class { 'graphite':
    gr_apache_port   => 8190,
 #  graphitehost  => $graphitehost,
  }
}
