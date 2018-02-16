# Install the Puppet Pipelines agent on Windows
#
# Do not use directly; use pipelines::agent.
class pipelines::agent::windows (
  $tempdir = 'C:/Users/distelli/AppData/Local/Temp/1',
) {
  $version = $pipelines::agent::version
  $workdir = 'C:/Program Files/Distelli'
  $distelli_exec = 'distelli-1.exe'

  if $facts['os']['hardware'] == 'x86_64' {
    $archive = "distelli.Windows-AMD64-${version}.gz"
    $url = "https://s3.amazonaws.com/download.distelli.com/distelli.Windows-AMD64/${archive}"
  }
  else {
    $archive = "distelli.Windows-x86-${version}.gz"
    $url = "https://s3.amazonaws.com/download.distelli.com/distelli.Windows-x86/${archive}"
  }

  if $pipelines::agent::user_groups {
    $user_groups = ['Users','Administrators'] + $pipelines::agent::user_groups
  }
  else {
    $user_groups = ['Users','Administrators']
  }

  user { 'distelli':
    ensure     => present,
    comment    => 'Puppet Pipelines User',
    home       => $pipelines::agent::user_home,
    groups     => $user_groups,
    password   => $pipelines::agent::user_password,
    managehome => true,
  }

  archive { "${tempdir}/${archive}":
    source       => $url,
    creates      => "${tempdir}/distelli",
    extract      => true,
    extract_path => $tempdir,
    require      => User['distelli'],
  }

  file { $workdir:
    ensure => directory,
    owner  => 'distelli',
    group  => 'Administrators',
  }

  exec { 'pipelines::agent::windows Copy executable':
    command   => "Copy-Item ${tempdir}/distelli \$ENV:ProgramFiles/Distelli/${distelli_exec}",
    unless    => "If (Test-Path -Path \$ENV:ProgramFiles/Distelli/${distelli_exec}) { exit 0 } else { exit 1 }",
    provider  => powershell,
    logoutput => true,
    require   => File[$workdir],
    subscribe => Archive["${tempdir}/${archive}"],
  }

  file { ["${workdir}/distelli.exe",  "${workdir}/dagent.exe", "${workdir}/dtk.exe"]:
    ensure  => link,
    target  => "${workdir}/${distelli_exec}",
    require => Exec['pipelines::agent::windows Copy executable'],
  }

  exec { 'pipelines::agent::windows Test distelli.exe execution':
    command     => '& $ENV:ProgramFiles/Distelli/distelli.exe version',
    provider    => powershell,
    logoutput   => true,
    refreshonly => true,
    subscribe   => File["${workdir}/distelli.exe"],
  }

  file { 'C:/distelli.yml':
    ensure    => file,
    owner     => 'distelli',
    group     => 'Administrators',
    mode      => '0644',
    content   => epp('pipelines/distelli.yml.epp'),
    show_diff => false,
  }

  exec { 'pipelines::agent::windows Start distelli':
    command     => 'C:/Progra~1/Distelli/distelli.exe agent install',
    subscribe   => [
      File['C:/distelli.yml'],
      Exec['pipelines::agent::windows Test distelli.exe execution']
    ],
    refreshonly => true,
  }
}
