class distelli::agent::windows (
  $version = '3.66.33',
  $tempdir = 'C:/Users/distelli/AppData/Local/Temp/1',
){

  if $::facts['os']['hardware'] == 'x86_64' {
    $archive = "distelli.Windows-AMD64-${version}.gz"
    $url = "https://s3.amazonaws.com/download.distelli.com/distelli.Windows-AMD64/${archive}"
  }
  else {
    $archive = "distelli.Windows-x86-${version}.gz"
    $url = "https://s3.amazonaws.com/download.distelli.com/distelli.Windows-x86/${archive}"
  }

  $workdir = 'C:/Program Files/Distelli'

  archive { "${tempdir}/${archive}" :
    source       => $url,
    # cleanup      => false,
    creates      => "${tempdir}/distelli",
    extract      => true,
    extract_path => $tempdir,
    require      => User['distelli'],
  }

  file { $workdir :
    ensure  => directory,
    owner   => 'distelli',
    group   => 'Administrators',
    require => User['distelli'],
  }

  # Requires fqdn_rand_string function from puppetlabs/stdlib
  $distelli_exec = "distelli-${fqdn_rand_string(5)}.exe"

  exec { 'Copy executable' :
    command   => "Copy-Item ${tempdir}/distelli \$ENV:ProgramFiles/Distelli/${distelli_exec}",
    unless    => "If (Test-Path -Path \$ENV:ProgramFiles/Distelli/${distelli_exec}) { exit 0 } else { exit 1}",
    provider  => powershell,
    require   => File[$workdir],
    logoutput => true,
  }

  file { ["${workdir}/distelli.exe",  "${workdir}/dagent.exe", "${workdir}/dtk.exe"] :
    ensure  => link,
    target  => "${workdir}/${distelli_exec}",
    require => Exec['Copy executable'],
  }

  exec { 'Test distelli.exe execution' :
    command     => "& \$ENV:ProgramFiles/Distelli/distelli.exe version",
    provider    => powershell,
    subscribe   => File["${workdir}/distelli.exe"],
    logoutput   => true,
    refreshonly => true,
  }

  file { 'C:/distelli.yml' :
    ensure  => file,
    owner   => 'distelli',
    group   => 'Administrators',
    mode    => '0644',
    content => epp('distelli/distelli.yml.epp'),
    require => Exec['Test distelli.exe execution'],
  }

  exec { 'Start distelli' :
    command     => "C:/Progra~1/Distelli/distelli.exe agent install",
    subscribe   => [ File['C:/distelli.yml'], Exec['Test distelli.exe execution'] ],
    refreshonly => true,
  }

}
