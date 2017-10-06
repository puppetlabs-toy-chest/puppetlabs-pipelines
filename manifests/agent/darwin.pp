class distelli::agent::darwin inherits distelli::agent {
  $url = "https://s3.amazonaws.com/download.distelli.com/distelli.Darwin-x86_64/distelli.Darwin-x86_64-${version}.gz"

  if $distelli::agent::version {
    $version = $distelli::agent::version
  }
  else {
    $version = '3.66.33'
  }

  exec { 'extract-distelli':
    command => "curl -sSL ${url} | gunzip -c > /usr/local/bin/distelli",
    creates => '/usr/local/bin/distelli',
    path    => '/usr/bin',
  }

  file { '/usr/local/bin/distelli':
    ensure  => file,
    owner   => 'root',
    group   => 'wheel',
    mode    => '0755',
    require => Exec['extract-distelli'],
  }

  file { ['/usr/local/bin/dagent','/usr/local/bin/dtk']:
    ensure  => link,
    target  => '/usr/local/bin/distelli',
    require => Exec['extract-distelli'],
  }

  file { '/etc/distelli.yml' :
    ensure  => file,
    owner   => 'distelli',
    group   => 'staff',
    mode    => '0644',
    content => epp('distelli/distelli.yml.epp'),
    require => Exec['extract-distelli'],
  }

  exec { 'install-distelli' :
    command => '/usr/local/bin/distelli agent install',
    unless  => '/usr/local/bin/distelli agent status',
    require => File['/etc/distelli.yml','/usr/local/bin/distelli'],
  }

  service { 'distelli-agent':
    ensure   => running,
    restart  => '/usr/local/bin/distelli agent start',
    start    => '/usr/local/bin/distelli agent start',
    status   => '/usr/local/bin/distelli agent status | /usr/bin/grep Running',
    stop     => '/usr/local/bin/distelli agent stop',
    provider => 'base',
    require  => Exec['install-distelli'],
  }

}
