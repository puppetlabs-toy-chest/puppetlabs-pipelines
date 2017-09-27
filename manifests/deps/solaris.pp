class distelli::deps::solaris inherits distelli::agent {

  # package { 'wget':
  #   ensure => present,
  # }
  #
  # package { 'bzip2':
  #   ensure => present,
  # }

  Archive {
    provider => 'wget',
    require  => Package['wget', 'bzip2'],
  }

  if $distelli::agent::user_home {
    $homedir = $distelli::agent::user_home
  }
  else {
    $homedir = '/export/home/distelli'
  }

  if $distelli::agent::user_password {
    $password = $distelli::agent::user_password
  }
  else {
    $password = 'changeme'
  }

  if $distelli::agent::user_shell {
    $shell = $distelli::agent::user_shell
  }
  else {
    $shell = '/bin/bash'
  }

  group { 'distelli' :
    ensure => present,
  }

  user { 'distelli' :
    ensure     => present,
    comment    => 'Distelli User',
    gid        => 'distelli',
    shell      => $shell,
    password   => $password,
    home       => $homedir,
    managehome => true,
  }

  # file { $homedir :
  #   ensure => directory,
  #   owner  => 'distelli',
  #   group  => 'distelli',
  # }

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
