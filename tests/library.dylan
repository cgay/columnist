Module: dylan-user


define library columnist-test-suite
  use columnist;

  use common-dylan;
  use io;
  use testworks;
end library;

define module columnist-test-suite
  use columnist;
  use columnist-impl;

  use common-dylan;
  use streams;
  use testworks;
end module;
