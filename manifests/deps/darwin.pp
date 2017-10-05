class distelli::deps::darwin inherits distelli::agent {

  if $::distelli::agent::distelli_user_shell == undef {
    $shell = '/bin/bash'
  }
  else {
    $shell = $::distelli::agent::distelli_user_shell
  }

  user { 'distelli' :
    ensure     => present,
    comment    => 'Distelli User',
    shell      => $shell,
  }

  file { '/private/etc/sudoers.d/distelli' :
    ensure  => file,
    content => "distelli ALL=(ALL) NOPASSWD:ALL\nDefaults:distelli !requiretty\n",
    mode    => '0400',
    owner   => 'root',
    require => User['distelli'],
  }

}
