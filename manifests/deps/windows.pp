class distelli::deps::windows (
  $install_chocolatey     = $::distelli::agent::install_chocolatey,
  $distelli_user_home     = $::distelli::agent::user_home,
  $distelli_user_password = $::distelli::agent::user_password,
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

  if $distelli_user_password == undef {
    $password = 'changeme'
  }
  else {
    $password = $user_password
  }

  user { 'distelli' :
    ensure     => present,
    comment    => 'Distelli User',
    home       => $homedir,
    groups     => ['Users','Administrators'],
    password   => $password,
    managehome => true,
  }
}
