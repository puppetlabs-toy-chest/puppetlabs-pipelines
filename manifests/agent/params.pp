# Calculate correct defaults for pipelines::agent parameters
class pipelines::agent::params {
  case $facts['kernel'] {
    'Linux': {
      $user_home = '/home/distelli'
      $user_shell = '/bin/false'
      $user_group = 'distelli'
      $sudoers_path = '/etc/sudoers'
    }
    'Darwin': {
      $user_home = '/Users/distelli'
      $user_shell = '/usr/bin/false'
      $user_group = 'staff'
      $sudoers_path = '/private/etc/sudoers'
    }
    'windows': {
      $user_home = 'C:/Users/distelli'
      $user_shell = undef
    }
    default: {
      fail("pipelines::agent doesn't support OS ${facts['kernel']}")
    }
  }
}
