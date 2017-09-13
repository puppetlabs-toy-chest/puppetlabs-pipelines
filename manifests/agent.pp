class distelli::agent (
  String $access_token,
  String $secret_key,
  String $download_url = 'http://www.distelli.com/download/client',
  String $config_file  = '/etc/distelli.yml',
  Optional[String]        $endpoint     = undef,
  Optional[String]        $version      = undef,
  Optional[Array[String]] $environments = undef,
){
  require ::distelli::deps

  $installdir = '/home/distelli'
  $downloader = '/home/distelli/distelli_downloader.sh'
  $client_installer = '/usr/local/bin/distelli'

  if $version {
    $url = "${download_url}/${version}"
  }
  else {
    $url = $download_url
  }

  archive { $downloader :
    source  => $url,
    cleanup => false,
    creates => $downloader,
  }

  file { $downloader :
    ensure  => file,
    owner   => 'distelli',
    group   => 'distelli',
    mode    => '0755',
    require => Archive[$downloader],
  }

  exec { $downloader :
    command => "/usr/bin/env sh ${downloader}",
    require => File[$downloader],
    creates => $client_installer,
  }

  file { $config_file :
    ensure  => file,
    owner   => 'distelli',
    group   => 'distelli',
    mode    => '0644',
    content => epp('distelli/distelli.yml.epp'),
    require => Exec[$downloader],
  }

  exec { $client_installer :
    command => "${client_installer} agent install",
    require => File[$config_file],
    # creates => ,
  }

}
