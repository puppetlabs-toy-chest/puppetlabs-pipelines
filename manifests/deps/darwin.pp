class distelli::deps::darwin inherits distelli::agent {
  $distelli_user_home     => $::distelli::agent::distelli_user_home,
  $distelli_user_shell    => $::distelli::agent::distelli_user_shell,
  $distelli_user_password => $::distelli::agent::distelli_user_password,
){

  # TODO packages need work
  package { 'wget':
    ensure => present,
  }

  # TODO packages need work
  package { 'bzip2':
    ensure => present,
  }

  Archive {
    provider => 'wget',
    require  => Package['wget', 'bzip2'],
  }

  if $::distelli::agent::distelli_user_home == undef {
    $homedir = '/Users/distelli'
  }
  else {
    $homedir = $::distelli::agent::distelli_user_home
  }

  if $::distelli::agent::distelli_user_password == undef {
    $password = 'changeme'
  }
  else {
    $password = $::distelli::agent::distelli_user_password
  }

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
    password   => $password,
    home       => $homedir,
    managehome => true,
  }

  file_line { 'sudoersd_include':
    path => '/etc/sudoers',
    line => '#includedir /etc/sudoers.d',
  }

  file { '/etc/sudoers.d/distelli' :
    ensure  => file,
    content => "distelli ALL=(ALL) NOPASSWD:ALL\nDefaults:distelli !requiretty\n",
    mode    => '0400',
    owner   => 'root',
    require => [ User['distelli'], File_line['sudoersd_include'] ],
  }

}
