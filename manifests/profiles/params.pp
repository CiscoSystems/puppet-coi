#
# Params 
#
class coi::profiles::params {

  case $::osfamily {
    'Redhat': {
      $pip2pi_path = "/usr/local/bin/pip2pi"
    }
    'Debian': {
      $pip2pi_path = "/usr/bin/pip2pi"
    }
    default: {
      fail("unsupported osfamily: $::osfamily")
    }
  }
}
