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

  ### Cisco Repository Setup ###
  # These parameters will be used to set up the apt repo supplied
  # by Cobbler to nodes being provisioned.  
  # * The 'openstack_release' parameter should correspond to the
  #   OpenStack release name you want to install (e.g. 'havana').
  # * The 'openstack_repo_location' parameter should be the complete
  #   URL of the repository you want to use to fetch OpenStack
  #   packages (e.g. http://openstack-repo.cisco.com/openstack/cisco).
  # * The 'supplemental_repo' parameter should be the complete URL
  #   of the repository you want to use for supplemental packages
  #   (e.g. http://openstack-repo.cisco.com/openstack/cisco_supplemental).
  # * The 'pocket' parameter should be the repo pocket to use for both
  #   the supplmental and main repos.  Setting this to an empty string
  #   will point you to the stable pocket, or you can specify the
  #   proposed pocket ('-proposed') or a snapshot ('/snapshots/h.0').
  $openstack_release       = 'havana',
  $openstack_repo_location = 'http://openstack-repo.cisco.com/openstack/cisco',
  $supplemental_repo       = 'http://openstack-repo.cisco.com/openstack/cisco_supplemental',
  $pocket                  = '',

  ### Advanced Users Configuration ###
  # These four settings typically do not need to be changed
  # In the default deployment, the build node functions as the DNS and static DHCP server for
  # the OpenStack nodes. These settings can be used if alternate configurations are needed
  $node_dns         = hiera('node_dns', false),
  $ip               = hiera('cobbler_ip', false),
  $dns_service      = hiera('dns_service', 'dnsmasq'),
  $dhcp_service     = hiera('dhcp_service', 'dnsmasq'),
  $nodes            = hiera('cobbler_nodes', {}),
  $time_zone        = hiera('time_zone', 'UTC'),

  # If you want to ensure that a specific Ubuntu kernel version is installed
  # and that it is the default GRUB boot selection when nodes boot for the
  # first time, use this setting to to specify the name of the
  # linux-image package you want to load (ex: "linux-image-3.2.0-51-generic").
  # Note that this feature has only been tested with Ubuntu's generic
  # kernel images.
  $load_kernel_pkg = hiera('load_kernel_pkg', false),

  # If you wish to specify kernel boot parameters, add them here.
  # The text you enter here will be placed in the /etc/default/grub
  # file's GRUB_CMDLINE_LINUX_DEFAULT line.  It is suggested that you
  # use the 'elevator=deadline' paramter as shown below if you plan
  # to use iSCSI-backed Cinder due to known kernel issues with cloning
  # volumes (refer to https://bugs.launchpad.net/bugs/1212250).
  $kernel_boot_params = hiera('kernel_boot_params',
                              'quiet splash'),

  # If you wish to specify a list of modules that should be added to the
  # /etc/modules file so they are automatically loaded into the kernel
  # at boot time, add them as a list here.  It is suggested that you
  # use at least the 8021q module (support for VLAN tagging which is
  # required by many Neutron plugins and provider network scenarios)
  # and the vhost_net which substantially improves KVM's networking
  # performance.
  $kernel_module_list = hiera('kernel_module_list', ['8021q', 'vhost_net'])
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

  # Enable the loading of a custom kernel package if requested.
  if $load_kernel_pkg {
    $kernel_cmd = "in-target /usr/bin/apt-get install -y $load_kernel_pkg ; \\
export kernel_ver=`echo '$load_kernel_pkg'|/bin/sed 's/linux-image-//'` ; \\
export prev_starts_at=`grep -n Previous /target/boot/grub/grub.cfg | /target/usr/bin/cut -f1 -d:` ; \\
export kern_starts_at=`grep -n \"Ubuntu, with Linux \$kernel_ver'\" /target/boot/grub/grub.cfg|/target/usr/bin/cut -f1 -d:` ; \\
if [ \"\$prev_starts_at\" ] && [ \"\$prev_starts_at\" -lt \"\$kern_starts_at\" ] ; \\
then \\
in-target /bin/sed -i \"/GRUB_DEFAULT=/ s/[0-9]/\\\"Previous Linux versions>Ubuntu, with Linux \$kernel_ver\\\"/\" /etc/default/grub ; \\
else \\
in-target /bin/sed -i \"/GRUB_DEFAULT=/ s/[0-9]/\\\"Ubuntu, with Linux \$kernel_ver\\\"/\" /etc/default/grub ; \\
fi ; \\
in-target /usr/sbin/update-grub ; "
  } else {
    $kernel_cmd = ''
  }

  # Enable custom kernel boot commands if requested.
  if $kernel_boot_params {
    $kernel_boot_params_cmd ="in-target /bin/sed -i \"s/GRUB_CMDLINE_LINUX_DEFAULT=\\\"[a-zA-Z ]\\\+\\\"/GRUB_CMDLINE_LINUX_DEFAULT=\\\"$kernel_boot_params\\\"/\" /etc/default/grub ; \\
in-target /usr/sbin/update-grub ; "
  } else {
    $kernel_boot_params_cmd = ''
  }

  # Enable autoloading of a list of custom kernel modules if requested.
  # Note that this list gets put into an "echo" command in the preseed
  # file's late_command, so we don't join it with a true newline here.
  if $kernel_module_list {
    $kernel_module_string = join($kernel_module_list, "\\n\\\n")
  } else {
    $kernel_module_string = ''
  }

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

  # Detect and correct for Bug #1269856.  h.0 users may inadvertently get
  # hold of this code and have a main repository URL specified in their
  # data/hiera_data/vendor/cisco_coi_common.yaml and/or
  # data/hiera_data/enable_ha/true.yaml files that doesn't include
  # '/cisco' at the end.  We need to munge this to prevent a backward
  # compat breakage.
  if ($openstack_repo_location == 'http://openstack-repo.cisco.com/openstack') {
    $openstack_repo_location_real = "${openstack_repo_location}/cisco"
    warning("openstack_repo_location has changed format and was set to a known bad value (see bug #1269856), setting to $openstck_repo_location_real")
  }
  elsif ($openstack_repo_location == 'ftp://ftpeng.cisco.com/openstack'){
    $openstack_repo_location_real = "${openstack_repo_location}/cisco"
    warning("openstack_repo_location has changed format and was set to a known bad value (see bug #1269856), setting to $openstck_repo_location_real")
  }
  else {
    $openstack_repo_location_real = $openstack_repo_location
  }

  ##### END VARIABLE SETUP #####

  ##### START CONFIGURATION #####

  host { $build_node_fqdn:
    host_aliases => $build_node_name,
    ip           => $cobbler_node_ip
  }

  ####### Preseed File Configuration #######
  cobbler::ubuntu::preseed { "cisco-preseed":
    admin_user              => $admin_user,
    password_crypted        => $password_crypted,
    packages                => "openssh-server vim vlan lvm2 ntp rubygems",
    ntp_server              => $build_node_fqdn,
    time_zone               => $time_zone,
    openstack_release       => $openstack_release,
    openstack_repo_location => $openstack_repo_location_real,
    supplemental_repo       => $supplemental_repo,
    pocket                  => $pocket,
    late_command            => sprintf('
sed -e "/logdir/ a pluginsync=true" -i /target/etc/puppet/puppet.conf ; \
sed -e "/logdir/ a server=%s" -i /target/etc/puppet/puppet.conf ; \
echo -e "server %s iburst" > /target/etc/ntp.conf ; \
echo -e "%s" >> /target/etc/modules ; \
sed -e "s/^ //g" -i /target/etc/modules ; \
%s ; \
echo "net.ipv6.conf.default.autoconf=%s" >> /target/etc/sysctl.conf ; \
echo "net.ipv6.conf.default.accept_ra=%s" >> /target/etc/sysctl.conf ; \
echo "net.ipv6.conf.all.autoconf=%s" >> /target/etc/sysctl.conf ; \
echo "net.ipv6.conf.all.accept_ra=%s" >> /target/etc/sysctl.conf ; \
ifconf="`tail +11 </etc/network/interfaces`" ; \
echo -e "%s
" > /target/etc/network/interfaces ; \
sed -e "s/^ //g" -i /target/etc/network/interfaces ; \
%s \
%s \
', $cobbler_node_fqdn, $cobbler_node_fqdn, $kernel_module_string, $bonding,
      $ra,$ra,$ra,$ra, $interfaces_file, $kernel_cmd, $kernel_boot_params_cmd),
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
