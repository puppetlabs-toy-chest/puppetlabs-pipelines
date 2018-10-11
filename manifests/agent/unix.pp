# Install the Puppet Pipelines agent on Linux and macOS
#
# Do not use directly; use pipelines::agent.
class pipelines::agent::unix {

  #   $cmd_prefix = "true && "
  #   $cmd_postfix = ""
  #   $path_separator = ':'
  #   if $version {
  #     $final_download_url = "${download_url}/${version}"
  #   } else {
  #     $final_download_url = $download_url
  #   }
  #   if ! $install_dir {
  #     $final_install_dir = '/usr/local/bin'
  #   } else {
  #     $final_install_dir = $install_dir
  #   }
  #   $download_location = "${final_install_dir}/distelli-download"
  #   $download_cmd = "cat \"${download_location}\" | sh"
  #   $agent_conf_file = '/etc/distelli.yml'
  #   $mkdir_cmd = "mkdir -p"

  # exec { "mkdir ${final_install_dir}":
  #   command => "${cmd_prefix}${mkdir_cmd} \"${final_install_dir}\"${cmd_postfix}",
  #   path    => $facts['path'],
  #   onlyif  => "${cmd_prefix}${mkdir_onlyif}${cmd_postfix}"
  # }
  # file { $final_install_dir:
  #   ensure => directory,
  #   require => Exec["mkdir ${final_install_dir}"],
  # }
  # file { $download_location:
  #   source => $final_download_url,
  # }
  # exec { 'pipelines::agent download':
  #   creates     => "${final_install_dir}/distelli",
  #   subscribe   => [
  #     File[$download_location],
  #   ],
  #   path        => $facts['path'],
  #   environment => [
  #     "DISTELLI_INSTALL_DIR=${final_install_dir}",
  #   ],
  #   command     => "${cmd_prefix}$download_cmd${cmd_postfix}",
  # }
  # if $start_agent {
  #   $distelli_yml_vars = {
  #     access_token => $access_token,
  #     secret_key => $secret_key,
  #     environments => $environments,
  #   }
  #   file { $agent_conf_file:
  #     ensure    => file,
  #     mode      => '0644',
  #     content   => epp('pipelines/distelli.yml.epp', $distelli_yml_vars),
  #     show_diff => false,
  #   }
  #   $__cmd = 'distelli agent'
  #   if $data_dir {
  #     $_cmd = "${__cmd} -data-dir \"${data_dir}\""
  #   } else {
  #     $_cmd = $__cmd
  #   }
  #   $cmd = "${_cmd} install -readyml"
  #   exec { 'pipelines::agent install':
  #     command     => "${cmd_prefix}$cmd${cmd_postfix}",
  #     subscribe   => [
  #       Exec['pipelines::agent download'],
  #     ],
  #     refreshonly => true,
  #     path        => "${final_install_dir}${path_separator}${facts['path']}",
  #   }
  # }
}
