# Install the Puppet Pipelines agent
#
# @param access_token First half of the credentials to authenticate the agent.
# @param secret_key Second half of the credentials to authenticate the agent.
# @param version Version of the agent to install (optional).
# @param download_url The URL that contains the agent download. Defaults to the SaaS download url,
#     if running an on-premise instance you will need to set this.
# @param install_dir The directory in which the distelli executable will be downloaded into.
# @param data_dir The agent base directory, defaults to /distelli (or %systemdrive%\distelli on Windows).
# @param environments Pre-configure the agent so this server is added to a set of
#     PfA environments.
class pipelines::agent (
  Sensitive[String[1]]           $access_token,
  Sensitive[String[1]]           $secret_key,
  Boolean                        $start_agent    = true,
  Optional[String[1]]            $data_dir       = undef,
  Optional[String[1]]            $install_dir    = undef,
  String[1]                      $download_url   = 'https://pipelines.puppet.com/download/client',
  Optional[String[1]]            $version        = undef,
  Optional[Array[String[1]]]     $environments   = undef,
) {
  if 'windows' == $facts['kernel'] {
    $path_separator = ';'
    $env = $facts['pipelines_env']
    if $version {
      $final_download_url = "${download_url}/${version}.ps1"
    } else {
      $final_download_url = "${download_url}.ps1"
    }
    # TODO: Make Windows actually respect this!
    # Currently you can't set this on windows :(.
    $final_install_dir = "${env['ProgramFiles']}\\Distelli"
    $download_cmd = "type \"${final_install_dir}/distelli-download\" | powershell -NoProfile -ExecutionPolicy Bypass -Command -"
    $agent_conf_file = "${env['SystemDrive']}\\distelli.yml"
    $mkdir_cmd = "md"
  } else {
    $path_separator = ':'
    if $version {
      $final_download_url = "${download_url}/${version}"
    } else {
      $final_download_url = $download_url
    }
    if ! $install_dir {
      $final_install_dir = '/usr/local/bin'
    } else {
      $final_install_dir = $install_dir
    }
    $download_cmd = "cat \"${final_install_dir}/distelli-download\" | sh"
    $agent_conf_file = '/etc/distelli.yml'
    $mkdir_cmd = "mkdir -p"
  }
  exec { "mkdir ${final_install_dir}":
    provider => shell,
    command => "${mkdir_cmd} \"${final_install_dir}\"",
    path    => $facts['path'],
  }
  file { $final_install_dir:
    ensure => directory,
    require => Exec["mkdir ${final_install_dir}"],
  }
  file { "${final_install_dir}/distelli-download":
    source => $final_download_url,
  }
  exec { 'pipelines::agent download':
    creates     => "${final_install_dir}/distelli",
    subscribe   => [
      File["${final_install_dir}/distelli-download"],
    ],
    path        => $facts['path'],
    environment => [
      "DISTELLI_INSTALL_DIR=${final_install_dir}",
    ],
    command     => $download_cmd,
  }
  if $start_agent {
    $distelli_yml_vars = {
      access_token => $access_token,
      secret_key => $secret_key,
      environments => $environments,
    }
    file { $agent_conf_file:
      ensure    => file,
      mode      => '0644',
      content   => epp('pipelines/distelli.yml.epp', $distelli_yml_vars),
      show_diff => false,
    }
    $__cmd = 'distelli agent'
    if $data_dir {
      $_cmd = "${__cmd} -data-dir \"${data_dir}\""
    } else {
      $_cmd = $__cmd
    }
    $cmd = "${_cmd} install -readyml"
    exec { 'pipelines::agent install':
      command     => $cmd,
      subscribe   => [
        Exec['pipelines::agent download'],
      ],
      refreshonly => true,
      path        => "${final_install_dir}${path_separator}${facts['path']}",
    }
  }
}
