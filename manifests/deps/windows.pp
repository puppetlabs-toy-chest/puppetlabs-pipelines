class distelli::deps::windows (
  $install_chocolatey     = $::distelli::agent::install_chocolatey,
  $distelli_user_home     = $::distelli::agent::distelli_user_home,
  $distelli_user_password = $::distelli::agent::distelli_user_password,
  ){
  if $install_chocolatey {
    include ::chocolatey
  }
  else {
    notify { 'Distelli Agent module relies on the Archive module.  If requisite packages are not installed, Chocolatey will \
    be needed to install packages.' : }
  }

  include ::archive

  if $distelli_user_home == undef {
    $homedir = 'C:/Users/distelli'
  }
  else {
    $homedir = $distelli_user_home
  }

  user { 'distelli' :
    ensure     => present,
    comment    => 'Distelli User',
    home       => $homedir,
    groups     => ['Users','Administrators'],
    password   => $distelli_user_password,
    managehome => true,
  }
}
