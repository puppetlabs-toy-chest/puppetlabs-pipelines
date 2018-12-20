# Install the Puppet Pipelines agent on Linux and macOS
#
# Do not use directly; use pipelines::agent.
class pipelines::agent::unix {
  if ! $pipelines::agent::install_dir {
    $install_dir = '/usr/local/bin'
  } else {
    $install_dir = $pipelines::agent::install_dir
  }

  if $pipelines::agent::version {
    $download_url = "${pipelines::agent::download_url}/${pipelines::agent::version}"
  } else {
    $download_url = $pipelines::agent::download_url
  }
  $download_location = '/tmp/client'
  $agent_conf_file = '/etc/distelli.yml'

  file { $download_location:
    ensure    => 'present',
    source    => $download_url,
    replace   => false,
    show_diff => false,
  }

  exec { 'pipelines::agent download':
    path        => $facts['path'],
    environment => [
      "DISTELLI_INSTALL_DIR=${install_dir}",
    ],
    command     => '/bin/bash -c $download_location',
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
    if $pipelines::agent::data_dir {
      $install_cmd = "distelli agent -data-dir \"${pipelines::agent::data_dir}\" install -readyml"
      $status_cmd = "distelli agent -data-dir \"${pipelines::agent::data_dir}\" status"
    } else {
      $install_cmd = 'distelli agent install -readyml'
      $status_cmd = 'distelli agent status'
    }
    exec { 'pipelines::agent install':
      command => $install_cmd,
      path    => "${install_dir}:${facts['path']}",
    }
  }
}
