class distelli::deps (
  String $distelli_user_home  = '/home/distelli',
  String $distelli_user_shell = '/bin/bash',
){
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

    user { 'distelli' :
      ensure     => present,
      comment    => 'Distelli User',
      shell      => $distelli_user_shell,
      home       => $distelli_user_home,
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
