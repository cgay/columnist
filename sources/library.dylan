Module: dylan-user

define library columnist
  use common-dylan;
  use io, import: { format, format-out, print, standard-io, streams };
  use strings;

  export
    columnist,
    columnist-protocol,
    columnist-impl;
end library;

define module columnist
  create
    <columnist>,
    <column>,
    columnize,
    $align-left,
    $align-center,
    $align-right,
    <separator>,

    // Borders
    $default-borders,
    $internal-whitespace-borders,
    $dashed-borders;
    //$whitespace-borders, TODO
    //$dotted-borders, TODO
    //$line-borders,   TODO           // extended ASCII
end module;

// Protocol exports if you need to implement a new border style or modify columnize
// behavior.  This is untested; most likely more needs to be exported.
define module columnist-protocol
  create
    <border-style>,
      top-left,
      top-line,
      top-inner,
      top-right,
      data-row-left,
      data-row-inner,
      data-row-right,
      header-separator-left,
      header-separator-line,
      header-separator-inner,
      header-separator-right,
      separator-left,
      separator-line,
      separator-inner,
      separator-right,
      bottom-left,
      bottom-line,
      bottom-inner,
      bottom-right,
    <border-place>,
      $border-top,
      $border-internal,
      $border-header,
      $border-bottom,
    <alignment>,
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
  use columnist-protocol;

  use common-dylan;
  use format;
  use format-out;
  use print;
  use standard-io;
  use streams;
  use strings;
end module;
