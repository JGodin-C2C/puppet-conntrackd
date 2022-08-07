# # conntrackd::service
#
# @summary This class exists to coordinate all service management related actions,
# functionality and logical units in a central place.
#
# <b>Note:</b> "service" is the Puppet term and type for background processes
# in general and is used in a platform-independent way. E.g. "service" means
# "daemon" in relation to Unix-like systems.
#
# @api private
#
# This class may be imported by other classes to use its functionality:
#   class { 'conntrackd::service': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
# @author Ian Bissett <mailto:bisscuitt@gmail.com>
#
class conntrackd::service {
  assert_private()

  #### Service management

  if $conntrackd::ensure == 'present' {
    # set params: in operation
    case $conntrackd::status {
      # make sure service is currently running, start it on boot
      'enabled': {
        $service_ensure = 'running'
        $service_enable = true
      }
      # make sure service is currently stopped, do not start it on boot
      'disabled': {
        $service_ensure = 'stopped'
        $service_enable = false
      }
      # make sure service is currently running, do not start it on boot
      'running': {
        $service_ensure = 'running'
        $service_enable = false
      }
      # do not start service on boot, do not manage service
      'unmanaged': {
        $service_ensure = undef
        $service_enable = false
      }
      # unknown status
      # note: don't forget to update the parameter check in init.pp if you
      #       add a new or change an existing status.
      default: {
        fail("\"${conntrackd::status}\" is an unknown service status value")
      }
    }
  } else {
    # set params: removal

    # make sure the service is stopped and disabled (the removal itself will be
    # done by package.pp)
    $service_ensure = 'stopped'
    $service_enable = false
  }

  # action
  service { 'conntrackd':
    ensure     => $service_ensure,
    enable     => $service_enable,
    name       => $conntrackd::service_name,
    hasstatus  => $conntrackd::service_hasstatus,
    hasrestart => $conntrackd::service_hasrestart,
    pattern    => $conntrackd::service_pattern,
    status     => $conntrackd::service_status,
  }
}
