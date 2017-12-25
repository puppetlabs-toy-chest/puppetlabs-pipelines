require 'spec_helper'

describe 'pipelines::agent' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:params) { {
        'access_token' => RSpec::Puppet::RawString.new("Sensitive('token')"),
        'secret_key' => RSpec::Puppet::RawString.new("Sensitive('key')"),
      } }
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
