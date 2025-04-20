Module: dylan-user

define library columnist
  use common-dylan;
  use io, import: { format, format-out, print, standard-io, streams };
  use strings;

  export
    columnist,
    columnist-impl;
end library;

define module columnist
  create
    <columnist>,
    <column>,
    <separator>,
    columnize,

    // for subclassers
    validate-rows,
    validate-columns;
end module;

define module columnist-impl
  use columnist;

  use common-dylan;
  use format;
  use format-out;
  use print;
  use standard-io;
  use streams;
  use strings;
end module;
