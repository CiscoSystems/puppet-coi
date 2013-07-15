#
# Params 
#
class coi::roles::params {

  case $::osfamily {
    'Redhat': {
      $enable_cobbler = false
      $enable_cache   = false
    }
    'Debian': {
      $enable_cobbler = true
      $enable_cache   = true
    }
    default: {
      fail("unsupported osfamily: $::osfamily")
    }
  }
}
