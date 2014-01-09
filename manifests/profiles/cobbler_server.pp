#
# Configures the cobbler server that is used by Cisco's
# openstack installer.
#
# [build_node_name]
#   Hostname of the build node.
# [cobbler_node_ip]
#   The ip address of the node that is on the same network as the nodes
#   that it prvisions.
# [node_subnet]
# [node_netmask]
# [node_gateway]
# [domain_name]
# [cobbler_proxy]
# [proxy]
# [admin_user]
# [admin_password]
# [autostart_puppet]
# [ucsm_port]
# [public_interface]
# [private_interface
# [external_interface]
# [install_drive]
# [node_dns]
# [ip]
# [dns_service]
# [dhcp_service]
#
class coi::profiles::cobbler_server(
  $build_node_name   = hiera('build_node_name'),

  ########### Build Node Cobbler Variables ############
  # Change these 5 parameters to define the IP address and other network settings of your build node
  # The cobbler node *must* have this IP configured and it *must* be on the same network as
  # the hosts to install
  $cobbler_node_ip  = hiera('cobbler_node_ip'),
  $node_subnet      = hiera('node_subnet'),
  $node_netmask     = hiera('node_netmask', '255.255.255.0'),
  # This gateway is optional - if there's a gateway providing a default route, put it here
  # If not, comment it out
  $node_gateway     = hiera('node_gateway'),
  # This domain name will be the name your build and compute nodes use for the local DNS
  # It doesn't have to be the name of your corporate DNS - a local DNS server on the build
  # node will serve addresses in this domain - but if it is, you can also add entries for
  # the nodes in your corporate DNS environment they will be usable *if* the above addresses
  # are routeable from elsewhere in your network.
  $domain_name      = hiera('domain_name'),
  # This setting likely does not need to be changed
  # To speed installation of your OpenStack nodes, it configures your build node to function
  # as a caching proxy storing the Ubuntu install files used to deploy the OpenStack nodes
  $cobbler_proxy    = hiera('cobbler_proxy', "http://${cobbler_node_ip}:3142/"),
  # This setting likely does not need to be changed
  # To speed installation of your OpenStack nodes, it configures your build node to function
  # as a caching proxy storing the Ubuntu install files used to deploy the OpenStack nodes
  $proxy            = hiera('proxy_node', false),

  ####### Preseed File Configuration #######
  # This will build a preseed file called 'cisco-preseed' in /etc/cobbler/preseeds/
  # The preseed file automates the installation of Ubuntu onto the OpenStack nodes
  #
  # The following variables may be changed by the system admin:
  # 1) admin_user
  $admin_user       = hiera('admin_user', 'localadmin'),
  # 2) password_crypted
  $password_crypted = hiera('password_crypted'),
  # Default user is: localadmin
  # Default SHA-512 hashed password is "ubuntu": $6$UfgWxrIv$k4KfzAEMqMg.fppmSOTd0usI4j6gfjs0962.JXsoJRWa5wMz8yQk4SfInn4.WZ3L/MCt5u.62tHDGB36EhiKF1
  # To generate a new SHA-512 hashed password, run the following replacing
  # the word "password" with your new password. Then use the result as the
  # $password_crypted variable
  # python -c "import crypt, getpass, pwd; print crypt.crypt('password', '\$6\$UfgWxrIv\$')"
  # 3) autostart_puppet -- whether the puppet agent will auto start
  $autostart_puppet = hiera('autostart_puppet', true),

  # If the setup uses the UCS Bseries blades, enter the port on which the
  # ucsm accepts requests. By default the UCSM is enabled to accept requests
  # on port 443 (https). If https is disabled and only http is used, set
  # $ucsm_port = '80'
  $ucsm_port        = hiera('ucsm_port', '443'),

  # These next three parameters specify the networking hardware used in each node
  # Current assumption is that all nodes have the same network interfaces and are
  # cabled identically
  #
  # Specify which interface in each node is the API Interface
  # This is also known as the Management Interface
  $public_interface   = hiera('public_interface', 'eth0'),
  # Define the interface used for vm networking connectivity when nova-network is being used.
  # Quantum does not require this value, so using eth0 will typically be fine.
  $private_interface  = hiera('private_interface', 'eth0'),
  # Specify the interface used for external connectivity such as floating IPs (only in network/controller node)
  $external_interface = hiera('external_interface', 'eth1'),

  # Select the drive on which Ubuntu and OpenStack will be installed in each node. Current assumption is
  # that all nodes will be installed on the same device name
  $install_drive    = hiera('install_drive', '/dev/sda'),

  # Select partition sizes for / and /var if desired.
  $root_part_size   = hiera('root_part_size', '32768'),
  $var_part_size    = hiera('var_part_size', '131072'),
  $enable_var       = hiera('enable_var', true),
  $enable_vol_space = hiera('enable_vol_space', true),

  ### Advanced Users Configuration ###
  # These four settings typically do not need to be changed
  # In the default deployment, the build node functions as the DNS and static DHCP server for
  # the OpenStack nodes. These settings can be used if alternate configurations are needed
  $node_dns         = hiera('node_dns', false),
  $ip               = hiera('cobbler_ip', false),
  $dns_service      = hiera('dns_service', 'dnsmasq'),
  $dhcp_service     = hiera('dhcp_service', 'dnsmasq'),
  $nodes            = hiera('cobbler_nodes', {}),
) inherits coi::profiles::base {

  # create all of the managed nodes
  create_resources('coi::cobbler_node', $nodes)

  if ! $node_dns {
    $node_dns_real = $cobbler_node_ip
  } else {
    $node_dns_real = $node_dns
  }

  if ! $ip {
    $ip_real = $cobbler_node_ip
  } else {
    $ip_real = $ip
  }

  $build_node_fqdn = "${build_node_name}.${domain_name}"

  # Enable ipv6 router edvertisement
  # TODO, I would like more docs here about why this is required
  $ipv6_ra          = hiera('ipv6_ra', '')
  if ($ipv6_ra == "") {
    $ra='0'
  } else {
    $ra = $ipv6_ra
  }

  # Enable network interface bonding. This will only enable the bonding module in the OS,
  # it won't actually bond any interfaces. Edit the networking interfaces template to set
  # up interface bonds as required after setting this to true should bonding be required.
  $interface_binding = hiera('interface_bonding', false)
  if ($interface_bonding == 'true'){
    $bonding = "echo 'bonding' >> /target/etc/modules"
  } else {
    $bonding = 'echo "no bonding configured"'
  }

  $interfaces_file=regsubst(template('coi/interfaces.erb'), '$', "\\n\\", "G")
  $cobbler_node_fqdn = "${build_node_name}.${domain_name}"

  ##### END VARIABLE SETUP #####

  ##### START CONFIGURATION #####

  host { $build_node_fqdn:
    host_aliases => $build_node_name,
    ip           => $cobbler_node_ip
  }

  ####### Preseed File Configuration #######
  cobbler::ubuntu::preseed { "cisco-preseed":
    admin_user       => $admin_user,
    password_crypted => $password_crypted,
    packages         => "openssh-server vim vlan lvm2 ntp rubygems",
    ntp_server       => $build_node_fqdn,
    late_command     => sprintf('
sed -e "/logdir/ a pluginsync=true" -i /target/etc/puppet/puppet.conf ; \
sed -e "/logdir/ a server=%s" -i /target/etc/puppet/puppet.conf ; \
echo -e "server %s iburst" > /target/etc/ntp.conf ; \
echo "8021q" >> /target/etc/modules ; \
%s ; \
echo "net.ipv6.conf.default.autoconf=%s" >> /target/etc/sysctl.conf ; \
echo "net.ipv6.conf.default.accept_ra=%s" >> /target/etc/sysctl.conf ; \
echo "net.ipv6.conf.all.autoconf=%s" >> /target/etc/sysctl.conf ; \
echo "net.ipv6.conf.all.accept_ra=%s" >> /target/etc/sysctl.conf ; \
ifconf="`tail +11 </etc/network/interfaces`" ; \
echo -e "%s
" > /target/etc/network/interfaces ; \
', $cobbler_node_fqdn, $cobbler_node_fqdn, $bonding,
     $ra,$ra,$ra,$ra, $interfaces_file),
    proxy            => "http://${cobbler_node_fqdn}:3142/",
    expert_disk      => true,
    diskpart         => [$install_drive],
    boot_disk        => $install_drive,
    autostart_puppet => $autostart_puppet,
    root_part_size   => $root_part_size,
    var_part_size    => $var_part_size,
    enable_var       => $enable_var,
    enable_vol_space => $enable_vol_space
  }

  class { 'cobbler':
    node_subnet      => $node_subnet,
    node_netmask     => $node_netmask,
    node_gateway     => $node_gateway,
    node_dns         => $node_dns_real,
    ip               => $ip_real,
    dns_service      => $dns_service,
    dhcp_service     => $dhcp_service,
  # change these two if a dynamic DHCP pool is needed
    dhcp_ip_low      => false,
    dhcp_ip_high     => false,
    domain_name      => $domain_name,
    password_crypted => $password_crypted,
    ucsm_port        => $ucsm_port,
  }

  # This will load the Ubuntu Server OS into cobbler
  # COE supprts only Ubuntu precise x86_64
  cobbler::ubuntu { "precise":
    proxy => $proxy,
  }
}
