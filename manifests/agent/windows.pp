# Install the Puppet Pipelines agent on Windows
#
# Do not use directly; use pipelines::agent.
class pipelines::agent::windows {
  $env = $facts['pipelines_env']
  $program_dir = "${env['ProgramFiles']}\\Distelli"
  $configuration_path = "${env['SystemDrive']}\\distelli.yml"

  $version = $pipelines::agent::version
  $architecture = $facts['os']['hardware'] ? {
    'x86_64' => 'AMD64',
    default  => 'x86',
  }

  $prefix = "distelli.Windows-${architecture}"
  $archive = "${prefix}-${version}.gz"
  $url = "https://s3.amazonaws.com/download.distelli.com/${prefix}/${archive}"

  if $pipelines::agent::user_groups {
    $user_groups = ['Users','Administrators'] + $pipelines::agent::user_groups
  } else {
    $user_groups = ['Users','Administrators']
  }

  user { 'distelli':
    ensure   => present,
    comment  => 'Puppet Pipelines User',
    groups   => $user_groups,
    password => $pipelines::agent::user_password,
  }

  file { $program_dir:
    ensure => directory,
    owner  => 'distelli',
    group  => 'Administrators',
  }

  archive { "${env['TEMP']}\\${archive}":
    source       => $url,
    creates      => "${program_dir}\\distelli",
    extract      => true,
    extract_path => $program_dir,
    require      => User['distelli'],
  }

  file { "${program_dir}\\distelli-1.exe":
    source    => "${program_dir}\\distelli",
    subscribe => Archive["${env['TEMP']}\\${archive}"],
  }

  file {
    default:
      ensure  => link,
      target  => "${program_dir}\\distelli-1.exe",
      require => File["${program_dir}\\distelli-1.exe"],
    ;
    "${program_dir}\\distelli.exe":;
    "${program_dir}\\dagent.exe":;
    "${program_dir}\\dtk.exe":;
  }

  exec { 'pipelines::agent::windows Test distelli.exe execution':
    command     => "\"${program_dir}\\distelli.exe\" version",
    logoutput   => true,
    refreshonly => true,
    subscribe   => File["${program_dir}\\distelli.exe"],
  }

  file { $configuration_path:
    ensure    => file,
    owner     => 'distelli',
    group     => 'Administrators',
    mode      => '0644',
    content   => epp('pipelines/distelli.yml.epp'),
    show_diff => false,
  }

  exec { 'pipelines::agent::windows Start distelli':
    command     => "\"${program_dir}\\distelli.exe\" agent install",
    subscribe   => [
      File[$configuration_path],
      Exec['pipelines::agent::windows Test distelli.exe execution']
    ],
    refreshonly => true,
  }
}
