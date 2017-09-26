# distelli::agent
#
# Main class, includes all other classes.
#
# @param access_token [Sensitive] First half of the credentials required to authenticate your Distelli Agent for build or credential storage purposes. Default value: undef.
# @param secret_key [Sensitive] Second half of the credentials required to authenticate your Distelli Agent for build or credential storage purposes. Default value: undef.
# @param install_chocolatey [Boolean] This will install the Chocolatey package management system.  Chocolatey is needed to install 7zip on Windows.  Default value: false.
# @param endpoint [Optional[String]] This is the URL or IP address and port for the Distelli agent service. Default value: undef.
# @param distelli_user_home [Optional[String]] Home directory for the Distelli user and Distelli executables. Default value: undef.
# @param environments [Optional[String]] Distelli specific environments of which have access to this agent. Default value: undef.

class distelli::agent (
  Sensitive               $access_token,
  Sensitive               $secret_key,
  Boolean                 $install_chocolatey = false,
  Optional[String]        $endpoint           = undef,
  Optional[String]        $version            = undef,
  Optional[String]        $distelli_user_home = undef,
  Optional[Array[String]] $environments       = undef,
){

  if $::facts['os']['family'] == 'windows' {
    if install_chocolatey {
      class { ::distelli::deps :
        install_chocolatey => true,
      }
      include ::distelli::agent::windows
    }
    else {
      require ::distelli::deps
      include ::distelli::agent::windows
    }
  }
  else {
    include ::distelli::agent::nix
  }

}
