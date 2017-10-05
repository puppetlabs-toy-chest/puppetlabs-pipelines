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
  elsif $::facts['kernel'] == 'SunOS' {
    $homedir = '/export/home/distelli'
  }
  else {
    $homedir = '/home/distelli'
  }

  $agent_installer = "distelli.${::facts['kernel']}-${::facts['os']['architecture']}-${version}"

  case $::facts['os']['family'] {
    'Darwin': {
      $archive = "distelli.Darwin-${version}.gz"
      $url     = "https://s3.amazonaws.com/download.distelli.com/distelli.Darwin-x86_64/${archive}"
    }
    'RedHat', 'Debian': {
      if $::facts['os']['architecture'] == 'x86_64' {
        $archive = "distelli.Linux-x86_64-${version}.gz"
        $url     = "https://s3.amazonaws.com/download.distelli.com/distelli.Linux-x86_64/${archive}"
      }
      else {
        $archive = "distelli.Linux-i686-${version}.gz"
        $url     = "https://s3.amazonaws.com/download.distelli.com/distelli.Linux-i686/${archive}"
      }
    }
    'Solaris': {
      $archive = "distelli.SunOS-i86pc-${version}.gz"
      $url     = "https://s3.amazonaws.com/download.distelli.com/distelli.SunOS-i86pc/${archive}"
    }
    default: {
      fail("Unsupported OS family: ${::facts['os']['family']}, please contact support@puppet.com to add it")
    }
  }

  archive { "${homedir}/${archive}" :
    source       => $url,
    # cleanup      => false,
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
    command => "${homedir}/${agent_installer} version",
    require => File['/etc/distelli.yml'],
  }

  exec { 'Install agent' :
    command => "${homedir}/${agent_installer} agent install",
    require => Exec['Test agent executable'],
    # creates => "${tempdir}/${agent_installer}",
  }

}
