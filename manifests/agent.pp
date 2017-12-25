# Install the Puppet Pipelines agent
#
# On Windows you will need to install chocolately (`include chocolately`), or
# configure the `archive` class so it can find 7zip.
#
# @param access_token First half of the credentials to authenticate the agent.
# @param secret_key Second half of the credentials to authenticate the agent.
# @param version Version of the agent to install.
# @param manage_sudoers Whether to manage the agent users's sudo access.
# @param user_home Home directory for the agent user and executables.
# @param user_shell Shell for the agent user. Defaults to false on Linux and
#   macOS to prevent logins as the agent user.
# @param user_password Password for the agent user. This must be set on Windows.
# @param endpoint The URL or IP address and port for the agent service.
# @param environments Pipelines environments that have access to this agent.
class pipelines::agent (
  Sensitive[String[1]]           $access_token,
  Sensitive[String[1]]           $secret_key,
  String[1]                      $version        = '3.66.33',
  Boolean                        $manage_sudoers = true,
  String[1]                      $user_home      = $pipelines::agent::params::user_home,
  Optional[String[1]]            $user_shell     = $pipelines::agent::params::user_shell,
  Optional[Sensitive[String[1]]] $user_password  = undef,
  Optional[String[1]]            $endpoint       = undef,
  Optional[Array[String[1]]]     $environments   = undef,
) inherits pipelines::agent::params {
  case $facts['kernel'] {
    'Linux':   { contain pipelines::agent::unix }
    'Darwin':  { contain pipelines::agent::unix }
    'windows': { contain pipelines::agent::windows }
    default:   { fail("pipelines::agent doesn't support OS ${facts['kernel']}") }
  }
}
