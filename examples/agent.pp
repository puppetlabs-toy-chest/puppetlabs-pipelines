class { ::distelli::agent :
  access_token => Sensitive('V5PBRGF8QI7N0DTWM8ER7YNBG'),
  #access_token => Sensitive('blah'),
  secret_key   => Sensitive('fgz1hzc9sih0sse9cz21itgaoec4ylit30j4g'),
  #secret_key   => Sensitive('blah'),
  endpoint     => 'some_endpoint',
  environments => ['production', 'staging', 'development'],
  # version      => '3.66.33',
}
