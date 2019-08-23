user { 'apache':
  ensure   => 'present',
  uid      => '5501',
  password => 'apache',
  shell    => '/bin/bash',
}
