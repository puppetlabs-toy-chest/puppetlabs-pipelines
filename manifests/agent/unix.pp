# Install the Puppet Pipelines agent on Linux and macOS
#
# Do not use directly; use pipelines::agent.
class pipelines::agent::unix {
  $version = $pipelines::agent::version
  $user_home = $pipelines::agent::user_home
  $user_group = $pipelines::agent::user_group
  $sudoers_path = $pipelines::agent::sudoers_path

  $prefix = "distelli.${facts['kernel']}-${facts['os']['hardware']}"
  $executable = "${prefix}-${version}"
  $url = "https://s3.amazonaws.com/download.distelli.com/${prefix}/${executable}.gz"

  user { 'distelli':
    ensure   => present,
    comment  => 'Puppet Pipelines User',
    home     => $user_home,
    shell    => $pipelines::agent::user_shell,
    groups   => $pipelines::agent::user_groups,
    password => $pipelines::agent::user_password,
    system   => true,
  }

  if $pipelines::agent::manage_sudoers {
    file_line { 'pipelines::agent::unix sudoersd_include':
      path => $sudoers_path,
      line => "#includedir ${sudoers_path}.d",
    }

    file { "${sudoers_path}.d/distelli":
      ensure  => file,
      content => "distelli ALL=(ALL) NOPASSWD:ALL\nDefaults:distelli !requiretty\n",
      mode    => '0400',
      owner   => 'root',
      require => [
        User['distelli'],
        File_line['pipelines::agent::unix sudoersd_include']
      ],
    }
  }

  archive { "${user_home}/${executable}.gz":
    source       => $url,
    user         => 'distelli',
    group        => $user_group,
    extract      => true,
    extract_path => $user_home,
    creates      => "${user_home}/${executable}",
    require      => File[$user_home],
  }

  if ! defined(File['/opt']) {
    file { '/opt':
      ensure => directory,
      owner  => 'root',
      group  => 0,
      mode   => '0755',
    }
  }

  file {
    default:
      owner => 'distelli',
      group => $user_group,
      mode  => '0755',
    ;
    $user_home:
      ensure => directory,
    ;
    "${user_home}/${executable}":
      ensure  => file,
      require => Archive["${user_home}/${executable}.gz"],
    ;
    "${user_home}/distelli":
      ensure  => link,
      target  => "${user_home}/${executable}",
      require => File["${user_home}/${executable}"],
    ;
  }

  file { '/etc/distelli.yml':
    ensure    => file,
    owner     => 'distelli',
    group     => $user_group,
    mode      => '0644',
    content   => epp('pipelines/distelli.yml.epp'),
    show_diff => false,
  }

  exec { 'pipelines::agent::unix Test agent executable':
    command     => "${user_home}/distelli version",
    refreshonly => true,
    subscribe   => File["${user_home}/distelli"],
  }

  exec { 'pipelines::agent::unix Install agent':
    command   => "${user_home}/distelli agent install",
    unless    => "${user_home}/distelli agent status",
    subscribe => Exec['pipelines::agent::unix Test agent executable'],
  }

  service { 'distelli-agent':
    ensure    => running,
    restart   => "${user_home}/distelli agent start",
    start     => "${user_home}/distelli agent start",
    status    => "${user_home}/distelli agent status | /usr/bin/grep Running",
    stop      => "${user_home}/distelli agent stop",
    provider  => 'base',
    subscribe => [
      Exec['pipelines::agent::unix Install agent'],
      File['/etc/distelli.yml'],
    ],
  }
}
