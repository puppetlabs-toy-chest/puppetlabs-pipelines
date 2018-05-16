require 'spec_helper'

describe 'pipelines::agent' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:params) do
        {
          'access_token' => RSpec::Puppet::RawString.new("Sensitive('token')"),
          'secret_key' => RSpec::Puppet::RawString.new("Sensitive('key')"),
        }
      end
      let(:facts) { os_facts }

      it do
        if os =~ %r{^windows-}
          skip 'https://github.com/danielparks/puppetlabs-pipelines/issues/9'
        else
          is_expected.to compile
        end
      end
    end
  end

  context 'on Raspbian 9' do
    let(:params) do
      {
        'access_token' => RSpec::Puppet::RawString.new("Sensitive('token')"),
        'secret_key' => RSpec::Puppet::RawString.new("Sensitive('key')"),
        'version' => '1.2.3',
      }
    end

    let(:facts) do
      {
        'kernel' => 'Linux',
        'os' => {
          'name' => 'Debian',
          'family' => 'Debian',
          'release' => {
            'major' => '9',
            'minor' => '3',
            'full' => '9.3',
          },
          'lsb' => {
            'distcodename' => 'stretch',
            'distid' => 'Raspbian',
            'distdescription' => 'Raspbian GNU/Linux 9.3 (stretch)',
            'distrelease' => '9.3',
            'majdistrelease' => '9',
            'minordistrelease' => '3',
          },
        },
      }
    end

    %w[armv6l armv7l].each do |arch|
      context "on #{arch}" do
        let(:facts) do
          super().merge(
            'architecture' => arch,
            'hardwaremodel' => arch,
          )
        end

        it { is_expected.to compile }
        it { is_expected.to contain_archive("/home/distelli/distelli.Linux-#{arch}-1.2.3.gz") }
      end
    end
  end

  context 'on macOS 10.13' do
    let(:params) do
      {
        'access_token' => RSpec::Puppet::RawString.new("Sensitive('token')"),
        'secret_key' => RSpec::Puppet::RawString.new("Sensitive('key')"),
        'version' => '1.2.3',
      }
    end

    let(:facts) do
      {
        'kernel' => 'Darwin',
        'os' => {
          'architecture' => 'x86_64',
          'family' => 'Darwin',
          'hardware' => 'x86_64',
          'macosx' => {
            'build' => '17D102',
            'product' => 'Mac OS X',
            'version' => {
              'full' => '10.13.3',
              'major' => '10.13',
              'minor' => '3',
            },
          },
          'name' => 'Darwin',
          'release' => {
            'full' => '17.4.0',
            'major' => '17',
            'minor' => '4',
          },
        },
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_archive('/Users/distelli/distelli.Darwin-x86_64-1.2.3.gz') }
  end
end
