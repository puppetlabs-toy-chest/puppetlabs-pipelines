class distelli::deps (
  String $distelli_user_password       = 'changeme',
  String $distelli_user_shell          = '/bin/bash',
  Boolean $install_chocolatey          = false,
  Optional[String] $distelli_user_home = undef,
){
  if $::facts['os']['family'] == 'windows' {
    if $install_chocolatey {
      include ::chocolatey
    }
    else {
      notify { 'Distelli Agent module relies on the Archive module.  If requisite packages are not installed, Chocolatey will \
      be needed to install packages.' : }
    }

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

  include '::archive'

  if $::facts['os']['family'] != 'windows' {
    package { 'wget':
      ensure => present,
    }

    package { 'bzip2':
      ensure => present,
    }

    Archive {
      provider => 'wget',
      require  => Package['wget', 'bzip2'],
    }

    if $distelli_user_home == undef {
      $homedir = '/home/distelli'
    }
    else {
      $homedir = $distelli_user_home
    }

    user { 'distelli' :
      ensure     => present,
      comment    => 'Distelli User',
      shell      => $distelli_user_shell,
      password   => $distelli_user_password,
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

}
