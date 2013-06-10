#
# wrapper that is specific for defining cobbler
# node definitions for Cisco's openstack installer.
#
# == Parameters
#   [node_type]
#     (required) The role of the machine to provision.
#   [mac]
#     (required) Mac address of machine. This attribute
#     is used during the PXE process to map this machine to
#     it's cobbler profile.
#   [ip]
#     (required) Ip address of the machine to be provisioned.
#   [power_address]
#      (optional) Address of power management service.
#   [power_user]
#      (optional) User used to authenticate with power service. Defaults to admin.
#   [power_password]
#      (optional) Password of 'power_user'. Defaults to password'
#   [power_type]
#     (optional) Type of power control used. Defaults to ipmitool.
#
define coi::cobbler_node(
  $node_type,
  $mac,
  $ip,
  $power_address,
  $power_id       = undef,
  $power_user     = 'admin',
  $power_password = 'password',
  $power_type     = 'ipmitool'
) {

  cobbler::node { $name:
    mac            => $mac,
    ip             => $ip,
    ### UCS CIMC Details ###
    # Change these parameters to match the management console settings
    # for your server
    power_address  => $power_address,
    power_user     => $power_user,
    power_password => $power_password,
    power_type     => $power_type,
    power_id       => $power_id,
    ### Advanced Users Configuration ###
    # These parameters typically should not be changed
    profile        => "precise-x86_64-auto",
    domain         => $::domain_name,
    node_type      => $node_type,
    preseed        => "cisco-preseed",
  }
}
