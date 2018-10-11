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
    contain pipelines::agent::windows
  } else {
    contain pipelines::agent::unix
  }
}
