class distelli::agent (
  Sensitive $access_token,
  Sensitive $secret_key,
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
