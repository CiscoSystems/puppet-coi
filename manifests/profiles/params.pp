#
# Params 
#
class coi::profiles::params {

  case $::osfamily {
    'Redhat': {
    }
    'Debian': {
    }
    default: {
      fail("unsupported osfamily: $::osfamily")
    }
  }
}
