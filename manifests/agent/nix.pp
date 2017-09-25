class distelli::agent::nix (
  $version      = '3.66.33',
  $download_url = 'https://www.distelli.com/download/client',
  $tempdir      = '/tmp',
){
  $agent_installer = "distelli.${::facts['kernel']}-${::facts['os']['architecture']}-${version}"

  require ::distelli::deps

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

  archive { "${::distelli::deps::homedir}/${archive}" :
    source       => $url,
    # cleanup      => false,
    extract      => true,
    extract_path => $::distelli::deps::homedir,
    creates      => "${::distelli::deps::homedir}/${agent_installer}",
  }

  file { "${::distelli::deps::homedir}/${agent_installer}" :
    ensure  => file,
    owner   => 'distelli',
    group   => 'distelli',
    mode    => '0755',
    require => Archive["${::distelli::deps::homedir}/${archive}"],
  }

  file { '/etc/distelli.yml' :
    ensure  => file,
    owner   => 'distelli',
    group   => 'distelli',
    mode    => '0644',
    content => epp('distelli/distelli.yml.epp'),
    # require => File["${::distelli::deps::homedir}/${agent_installer}"],
  }

  exec { 'Test agent executable' :
    command => "${::distelli::deps::homedir}/${agent_installer} version",
    require => File['/etc/distelli.yml'],
  }

  exec { 'Install agent' :
    command => "${::distelli::deps::homedir}/${agent_installer} agent install",
    require => Exec['Test agent executable'],
    # creates => "${tempdir}/${agent_installer}",
  }

}
