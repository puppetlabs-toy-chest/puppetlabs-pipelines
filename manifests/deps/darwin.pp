class distelli::deps::darwin inherits distelli::agent {

  if $::distelli::agent::user_shell == undef {
    $shell = '/bin/bash'
  }
  else {
    $shell = $::distelli::agent::user_shell
  }

  if $::distelli::agent::user_home {
    $home = $::distelli::agent::user_home
  }
  else {
    $home = '/Users/distelli'
  }

  if $::distelli::agent::user_password {
    $password = $::distelli::agent::user_home
  }
  else {
    $password = undef
  }

  user { 'distelli' :
    ensure   => present,
    comment  => 'Distelli User',
    home     => $home,
    shell    => $shell,
    password => $password,
  }

  file { '/private/etc/sudoers.d/distelli' :
    ensure  => file,
    content => "distelli ALL=(ALL) NOPASSWD:ALL\nDefaults:distelli !requiretty\n",
    mode    => '0400',
    owner   => 'root',
    require => User['distelli'],
  }

}
