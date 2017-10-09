class distelli::agent::nix inherits distelli::agent {

  if $distelli::agent::version {
    $version = $distelli::agent::version
  }
  else {
    $version = '3.66.33'
  }

  if $distelli::agent::user_home {
    $homedir = $distelli::agent::user_home
  }
  else {
    $homedir = '/home/distelli'
  }

  case $::facts['os']['architecture'] {
    'x86_64', 'amd64': {
      $archive         = "distelli.Linux-x86_64-${version}.gz"
      $url             = "https://s3.amazonaws.com/download.distelli.com/distelli.Linux-x86_64/${archive}"
      $agent_installer = "distelli.${::facts['kernel']}-x86_64-${version}"
    }
    'i686': {
      $archive         = "distelli.Linux-i686-${version}.gz"
      $url             = "https://s3.amazonaws.com/download.distelli.com/distelli.Linux-i686/${archive}"
      $agent_installer = "distelli.${::facts['kernel']}-i686-${version}"
    }
    default : {
      fail("distelli::agent - The ${::facts['os']['architecture']} architecture is not currently supported by the Distelli Module.  Please contact support@puppet.com")
    }
  }

  archive { "${homedir}/${archive}" :
    source       => $url,
    user         => 'distelli',
    group        => 'distelli',
    extract      => true,
    extract_path => $homedir,
    creates      => "${homedir}/${agent_installer}",
  }

  file { "${homedir}/${agent_installer}" :
    ensure  => file,
    owner   => 'distelli',
    group   => 'distelli',
    mode    => '0755',
    require => Archive["${homedir}/${archive}"],
  }

  file { '/etc/distelli.yml' :
    ensure  => file,
    owner   => 'distelli',
    group   => 'distelli',
    mode    => '0644',
    content => epp('distelli/distelli.yml.epp'),
    require => File["${homedir}/${agent_installer}"],
  }

  exec { 'Test agent executable' :
    command     => "${homedir}/${agent_installer} version",
    refreshonly => true,
    require     => File['/etc/distelli.yml'],
    subscribe   => File["${homedir}/${agent_installer}"],
  }

  exec { 'Install agent' :
    command     => "${homedir}/${agent_installer} agent install",
    refreshonly => true,
    subscribe   => Exec['Test agent executable'],
  }

}
