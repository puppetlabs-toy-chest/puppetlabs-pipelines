require 'spec_helper'

describe 'pipelines::agent' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:params) { {
        'access_token' => RSpec::Puppet::RawString.new("Sensitive('token')"),
        'secret_key'   => RSpec::Puppet::RawString.new("Sensitive('key')"),
      } }
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end

  context "on Raspbian 9" do
    let(:params) { {
      'access_token' => RSpec::Puppet::RawString.new("Sensitive('token')"),
      'secret_key'   => RSpec::Puppet::RawString.new("Sensitive('key')"),
      'version'      => '1.2.3',
    } }

    let(:facts) do
      {
        'kernel' => 'Linux',
        'os'     => {
          'name'    => 'Debian',
          'family'  => 'Debian',
          'release' =>{
            'major' => '9',
            'minor' => '3',
            'full'  => '9.3',
          },
          'lsb'     => {
            'distcodename'     => 'stretch',
            'distid'           => 'Raspbian',
            'distdescription'  => 'Raspbian GNU/Linux 9.3 (stretch)',
            'distrelease'      => '9.3',
            'majdistrelease'   => '9',
            'minordistrelease' => '3',
          }
        }
      }
    end

    ['armv6l','armv7l'].each do |arch|
      context "on #{arch}" do
        let(:facts) do
          super().merge({
            'architecture'  => arch,
            'hardwaremodel' => arch,
          })
        end
        it { is_expected.to compile }
        it { is_expected.to contain_archive("/opt/distelli/distelli.Linux-#{arch}-1.2.3.gz") }
      end
    end
  end
end
