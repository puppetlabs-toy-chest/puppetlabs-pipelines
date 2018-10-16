# puppetlabs-pipelines: Configure the Puppet Pipelines agent

The Pipelines module installs, configures, and manages the agent for [Puppet
Pipelines](https://puppet.com/products/puppet-pipelines-applications) on
Linux, macOS, and Windows. It can be used on build, application, and key
management servers.

#### Table of Contents

1. [Usage](#usage)
1. [Reference](#reference)
1. [Contributing](#contributing)

## Usage

```puppet
class { 'pipelines::agent':
  access_token => Sensitive('super_long_access_token'),
  secret_key   => Sensitive('super_secret_key'),
  download_url => 'https://pfa.example.com/download/client',
  start_agent  => true,
  data_dir     => '/home/distelli/data',
  install_dir  => '/home/distelli/bin',
  environments => ['production', 'staging', 'development'],
  version      => '3.68.0',
}
```

### access_token and secret_key (required)

These are the only required parameters. You can obtain these credentials in the Pipelines
interface under **Settings > Agent**.

You will likely want to use [Hiera eyaml][] or some other form of encryption so
that you don't have to put your credentials in your codebase in plain text.

### download_url (required for on-premise installs)

If you have an on-premise installation of pipelines, you are required to specify
a download URL to install from so that the agent which is downloaded has the
proper endpoints embedded within it.

### start_agent (optional)

You can specify the `start_agent => false` parameter if you only want the
`distelli` binary to be installed.

### data_dir (optional)

By default, the agent stores all data under the `/distelli` or
`%SystemDrive%\Distelli.yml` directory on Windows. You can specify a different directory
with the `data_dir` option. This option is useful if:

* You want to run multiple agents on the same host.
* You want to restrict the permissions of the distelli user.

### install_dir (optional)

By default the executable is installed in `/usr/local/bin` or `%ProgramFiles%\Distelli` on
Windows. You can specify a different install directory with the `install_dir` option.

### environments (optional)

This is a list of PfA environments to "join" when the agent starts.

### version (not recommended)

If you want to "pin" a particular verson of the agent you can use this option,
although it is not recommended since not all pipeline products support multiple
concurrent agent versions.

## Reference

### Classes

#### Public classes

* `pipelines::agent`: Main class, includes all other classes.

#### Private classes

* `pipelines::agent::unix`: Handles the install on Linux and macOS.
* `pipelines::agent::windows`: Handles the install on Windows.

## Contributing

Puppet modules on the Puppet Forge are open projects, and community
contributions are essential for keeping them great. Please follow our guidelines
when contributing changes.

For more information, see Puppet's [module contribution
guide.](https://docs.puppet.com/forge/contributing.html)

### Contributors

To see who's already involved, see the [list of
contributors.](https://github.com/puppetlabs/puppetlabs-pipelines/graphs/contributors)

Special thanks to:

* [Eric Williamson](https://github.com/ericwilliamson)
* [Reid Vandewiele](https://github.com/reidmv)
* [Ethan Brown](https://github.com/Iristyle)
* [Michael Lombardi](https://github.com/michaeltlombardi)
* [Bill Hurt](https://github.com/RandomNoun7)
* [James Pogran](https://github.com/jpogran)

[Hiera eyaml]: https://github.com/voxpupuli/hiera-eyaml
