# distelli::agent
#
# Main class, includes all other classes.
#
# @param access_token [Sensitive] First half of the credentials required to authenticate your Distelli Agent for build or credential storage purposes. Default value: undef.
# @param secret_key [Sensitive] Second half of the credentials required to authenticate your Distelli Agent for build or credential storage purposes. Default value: undef.
# @param install_chocolatey [Boolean] This will install the Chocolatey package management system.  Chocolatey is needed to install 7zip on Windows.  Default value: false.
# @param endpoint [Optional[String]] This is the URL or IP address and port for the Distelli agent service. Default value: undef.
# @param user_home [Optional[String]] Home directory for the Distelli user and Distelli executables. Default value: undef.
# @param user_password [Optional[String]] Password for the Distelli user and Distelli executables. Default value: undef.
# @param user_shell [Optional[String]] Preferred shell for the Distelli user and Distelli executables. Default value: undef.
# @param environments [Optional[String]] Distelli specific environments of which have access to this agent. Default value: undef.
# @param version [Optional[String]] Preferred version of Distelli agent to be instlled. Default value: undef.
class distelli::agent (
  Sensitive               $access_token,
  Sensitive               $secret_key,
  Boolean                 $install_chocolatey = false,
  Optional[String]        $endpoint           = undef,
  Optional[String]        $user_home          = undef,
  Optional[String]        $user_password      = undef,
  Optional[String]        $user_shell         = undef,
  Optional[Array[String]] $environments       = undef,
  Optional[String]        $version            = undef,
){

  if $::facts['os']['family'] != 'windows' and $install_chocolatey == true {
    warning('distelli::agent - "install_chocolatey" resource attribute was set to True for a non-Windows OS.  This will be ignored.')
  }

  if $::facts['os']['family'] == 'windows' {
    require ::distelli::deps::windows
    include ::distelli::agent::windows
  }
  elsif $::facts['os']['family'] == 'Darwin' {
    require ::distelli::deps::darwin
    include ::distelli::agent::darwin
  }
  elsif $::facts['os']['name'] == 'Solaris' {
    require ::distelli::deps::solaris
    include ::distelli::agent::nix
  }
  elsif $::facts['kernel'] == 'Linux' {
    require ::distelli::deps::nix
    include ::distelli::agent::nix
  }
  else {
    fail("${::facts['os']['family']} is not supported by the Distelli Module.  Please contact support@puppet.com")
  }

}
