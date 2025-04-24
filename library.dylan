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
    $internal-whitespace-borders, // The default
    //$whitespace-borders, TODO
    $dashed-borders,
    //$dotted-borders, TODO
    //$line-borders,   TODO           // extended ASCII

    // for subclassers
    <columnist>,
    <column>,
    <separator>,
    <border-style>,
    display-header,
    display-data-row,
    display-border-row,
    // display-cell, ?
    // display-row, ?
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
