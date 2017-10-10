# puppetlabs-distelli_agent

#### Table of Contents


1. [Module Description - What the module does and why it is useful](#module-description)
1. [Setup - The basics of getting started with the Distelli agent](#setup)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)


## Module description

The Distelli module currently installs, configures, and manages the Distelli Agent service across \*nix-centric and Windows based operating systems.

## Usage

All parameters for the Distelli module are contained within the main `::distelli::agent` class, so for any function of the module, set the options you want. See the common usages below for examples.

### Beginning with Distelli Agent

### Credential Requirements

In order to get up and running you must at minimum supply the Distelli Access Token and Distelli Secret Key respectively

You will likely want to involve [Hiera](https://docs.puppet.com/puppet/4.10/hiera_intro.html) with some form of encryption enabled to pass in these sensitive items to ensure your credentials are safeguarded.

### Installation requirements

Since [7zip](http://www.7-zip.org/) is required to allow the [Archive](https://forge.puppet.com/puppet/archive) module to extract the Distelli executable.  On \*nix platforms, this module will automatically use the package management system associated with your OS distribution (i.e., YUM and RedHat family).  On Windows, there is not an official package management system.  Therefore you have two options:

- Install [7zip](http://www.7-zip.org/) tool by some other means
- Allow this module to install [Chocolatey](https://www.chocolatey.org), a Windows package management system, to install [7zip](http://www.7-zip.org/)

### Install, configure, and run on OS with inherent package management system

```puppet
class { '::distelli::agent':
  access_token => Sensitive('super_long_access_token'),
  secret_key   => Sensitive('super_secret_key'),
}
```

### Install, configure, and run on Windows without [7zip](http://www.7-zip.org/) currently installed:

```puppet
class { '::distelli::agent':
access_token => Sensitive('super_long_access_token'),
secret_key   => Sensitive('super_secret_key'),
  install_chocolatey => true,
}
```

### Specify environments

```puppet
class { '::distelli::agent':
access_token => Sensitive('super_long_access_token'),
secret_key   => Sensitive('super_secret_key'),
  environments => ['production', 'staging', 'development'],
}
```

### Specify endpoint

```puppet
class { '::distelli::agent':
  access_token => Sensitive('super_long_access_token'),
  secret_key   => Sensitive('super_secret_key'),
  endpoint     => 'us-east-1c:ip-10-0-2-219.ec2.internal:7000',
}
```

### Specify Distelli Agent version

```puppet
class { '::distelli::agent':
  access_token => Sensitive('super_long_access_token'),
  secret_key   => Sensitive('super_secret_key'),
  version      => '3.66.33',
}
```

### Specify home directory for Distelli user

```puppet
class { '::distelli::agent':
  access_token => Sensitive('super_long_access_token'),
  secret_key   => Sensitive('super_secret_key'),
  distelli_user_home => '/opt/distelli',
}
```

## Reference

### Classes

#### Public classes

* distelli::agent: Main class, includes all other classes.

#### Private classes

* distelli::agent::deps:    Handles all pre-requisites.
* distelli::agent::nix:     Handles the install on \*nix based operating systems.
* distelli::agent::windows: Handles the install on Windows based operating systems.

### Parameters

The following parameters are available in the `::distelli::agent` class:

#### `access_token`

Required.

Data type: Sensitive.

First half of the credentials required to authenticate your Distelli Agent for build or credential storage purposes.

#### `secret_key`

Required.

Data type: Sensitive.

Second half of the credentials required to authenticate your Distelli Agent for build or credential storage purposes.

#### `distelli_user_home`

Optional.

Data type: String.

Home directory for the Distelli user and Distelli executables.

Default value: `undef`.

#### `endpoint`

Optional.

Data type: String.

This is the URL or IP address and port for the Distelli agent service.

Default value: `undef`.

#### `environment`

Optional.

Data type: String.

Distelli specific environments of which have access to this agent.

Default value: `undef`.

#### `install_chocolatey`

Optional.

Data type: Boolean.

This will install the [Chocolatey](https://chocolatey.org/) package management system.  [Chocolatey](https://chocolatey.org/) is needed to install the [7zip](http://www.7-zip.org/) package if it does not exist on the system prior to instantiating this module.

Default value: `false`.

#### `version`

Optional.

Data type: String.

The version of the Distelli agent to be installed.

Default value: `undef`.

## Limitations

This module has been tested on Linux-based

## Development

Puppet modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. Please follow our guidelines when contributing changes.

For more information, see our [module contribution guide.](https://docs.puppetlabs.com/forge/contributing.html)

### Contributors

To see who's already involved, see the [list of contributors.](https://github.com/puppetlabs/puppetlabs-distelli_agent/graphs/contributors)
