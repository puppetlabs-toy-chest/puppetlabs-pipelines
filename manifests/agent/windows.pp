# Install the Puppet Pipelines agent on Windows
#
# Do not use directly; use pipelines::agent.
class pipelines::agent::windows {
  $env = $facts['pipelines_env']

  if ! $pipelines::agent::install_dir {
    $install_dir = "${env['ProgramFiles']}\\Distelli"
  } else {
    $install_dir = $pipelines::agent::install_dir
  }

  if $pipelines::agent::version {
    $download_url = "${pipelines::agent::download_url}/${pipelines::agent::version}.ps1"
  } else {
    $download_url = "${pipelines::agent::download_url}.ps1"
  }
  $download_location = "${install_dir}\\distelli-download.ps1"
  $agent_conf_file = "${env['SystemDrive']}\\distelli.yml"

  exec { "mkdir ${install_dir}":
    command => "cmd.exe /c \"md \"${install_dir}\"\"",
    path    => $facts['path'],
    creates => $install_dir,
  }
  file { $download_location:
    source  => $download_url,
    require => Exec["mkdir ${install_dir}"],
  }
  exec { 'pipelines::agent download':
    provider    => powershell,
    subscribe   => [
      File[$download_location],
    ],
    refreshonly => true,
    path        => $facts['path'],
    environment => [
      "DISTELLI_INSTALL_DIR=${install_dir}",
    ],
    command     => "& \"${download_location}\"; Exit 0",
  }
  if $pipelines::agent::start_agent {
    $distelli_yml_vars = {
      access_token => $pipelines::agent::access_token,
      secret_key   => $pipelines::agent::secret_key,
      environments => $pipelines::agent::environments,
    }
    file { $agent_conf_file:
      ensure    => file,
      mode      => '0644',
      content   => epp('pipelines/distelli.yml.epp', $distelli_yml_vars),
      show_diff => false,
    }
    # Note that we need to use cmd.exe /c to work around an issue
    # with puppet on windows which would print this error:
    #   "Could not find command '%{exe}'"
    # ...probably because distelli.exe is a symlink.
    if $pipelines::agent::data_dir {
      $install_cmd = "cmd.exe /c \"${install_dir}\\distelli.exe\" agent -data-dir \"${pipelines::agent::data_dir}\" install -readyml"
    } else {
      $install_cmd = "cmd.exe /c \"${install_dir}\\distelli.exe\" agent install -readyml"
    }
    exec { 'pipelines::agent install':
      command     => $install_cmd,
      subscribe   => [
        Exec['pipelines::agent download'],
      ],
      refreshonly => true,
      path        => "${install_dir};${facts['path']}",
    }
  }
}
