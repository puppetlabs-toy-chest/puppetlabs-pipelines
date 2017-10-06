class distelli::deps::windows {

  if $::distelli::agent::install_chocolatey {
    include ::chocolatey
  }
  else {
    notify { 'distelli::agent - Distelli Agent module relies on the Archive module.  If requisite packages are not installed, Chocolatey will \
    be needed to install those packages.' : }
  }

  include ::archive

  if $::distelli::agent::user_home {
    $homedir = $::distelli::agent::user_home
  }
  else {
    $homedir = 'C:/Users/distelli'
  }

  if $::distelli::agent::user_password {
    $password = $::distelli::agent::user_password
  }
  else {
    $password = 'changeme'
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
