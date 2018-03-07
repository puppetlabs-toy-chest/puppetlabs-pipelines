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

### TL;DR

```puppet
class { 'pipelines::agent':
  access_token => Sensitive('super_long_access_token'),
  secret_key   => Sensitive('super_secret_key'),
}
```

### Credentials

In order to get up and running you must, at minimum, supply the Pipelines access
token and secret key. You can generate them in the Pipelines interface under
**Settings > Agent**.

You will likely want to use [Hiera eyaml][] or some other form of encryption so
that you don't have to put your credentials in your codebase in plain text.

### Windows requirements

On Windows, [7zip][] is required for the [archive module][] to extract the
Distelli executable. You have two options:

- Install [Chocolatey][] with Puppet by installing the [chocolatey module][],
  then add `include chocolatey` to your manifest.
- Install [7zip][] by some other means, then [set `seven_zip_provider` and
  friends][archive class usage] on the `archive` class.

Additionally, you *must* specify the `user_password` on Windows.

### Install, configure, and run on Linux and macOS

```puppet
class { 'pipelines::agent':
  access_token => Sensitive('super_long_access_token'),
  secret_key   => Sensitive('super_secret_key'),
}
```

### Install, configure, and run on Windows

```puppet
include chocolatey
class { 'pipelines::agent':
  access_token  => Sensitive('super_long_access_token'),
  secret_key    => Sensitive('super_secret_key'),
  user_password => Sensitive('secret_user_password'),
}
```

### Specify environments

```puppet
class { 'pipelines::agent':
  access_token => Sensitive('super_long_access_token'),
  secret_key   => Sensitive('super_secret_key'),
  environments => ['production', 'staging', 'development'],
}
```

### Specify endpoint

```puppet
class { 'pipelines::agent':
  access_token => Sensitive('super_long_access_token'),
  secret_key   => Sensitive('super_secret_key'),
  endpoint     => 'us-east-1c:ip-10-0-2-219.ec2.internal:7000',
}
```

### Specify agent version

```puppet
class { 'pipelines::agent':
  access_token => Sensitive('super_long_access_token'),
  secret_key   => Sensitive('super_secret_key'),
  version      => '3.66.33',
}
```

### Specify home directory for the agent user

```puppet
class { 'pipelines::agent':
  access_token => Sensitive('super_long_access_token'),
  secret_key   => Sensitive('super_secret_key'),
}
```

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


[Hiera eyaml]: https://github.com/voxpupuli/hiera-eyaml
[archive module]: https://forge.puppet.com/puppet/archive
[archive class usage]: https://forge.puppet.com/puppet/archive#usage
[Chocolatey]: https://www.chocolatey.org
[chocolatey module]: https://forge.puppet.com/chocolatey/chocolatey
[7zip]: http://www.7-zip.org/
