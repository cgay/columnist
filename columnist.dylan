Module: columnist-impl

// TODO:
//   * better handling of too-wide cell data for column that doesn't allow wrapping.
//   * support a maximum overall table width
//   * support wrapped column headers
//   * get default max width of table from terminal size if possible.
//   * handle multi-line strings (just split instead of wrap?)
//   * ability to nest tables would be cool.
//   * cells that span multiple columns or rows
//   * support terminal escape codes for colorizing etc.

define constant <string?> = false-or(<string>);

// Minimum column width, not counting column separator characters or borders.
define constant $minimum-column-width = 1;

define constant $align-left   = #"_left";
define constant $align-center = #"_center";
define constant $align-right  = #"_right";
define constant <alignment> = one-of($align-left, $align-center, $align-right);

// Display rows on stream as described by a <columnist>.
define generic columnize (stream :: <stream>, c :: <columnist>, rows :: <sequence>);
define generic validate-rows (c :: <columnist>, rows :: <sequence>);
define generic validate-columns (c :: <columnist>);
define generic cell-data-as-string (cell-data) => (s :: <string>);

define class <border-style> (<object>)
  // Note that the *-line slots are used to determine whether or not a row separator of
  // the given type should be displayed. For example, if top-line is #f no top border is
  // displayed.  Column borders may be omitted by use of the empty string.

  // Top line, the line above the headers (or above the top row if no headers).
  constant slot top-left               :: <string>  = "",   init-keyword: top-left:;
  constant slot top-line               :: <string?> = #f,   init-keyword: top-line:;
  constant slot top-inner              :: <string>  = "",   init-keyword: top-inner:;
  constant slot top-right              :: <string>  = "",   init-keyword: top-right:;
  // Data rows
  constant slot data-row-left          :: <string>  = "",   init-keyword: data-row-left:;
  constant slot data-row-inner         :: <string>  = "  ", init-keyword: data-row-inner:;
  constant slot data-row-right         :: <string>  = "",   init-keyword: data-row-right:;
  // Separator between header and first data row.
  constant slot header-separator-left  :: <string>  = "",   init-keyword: header-separator-left:;
  constant slot header-separator-line  :: <string?> = #f,   init-keyword: header-separator-line:;
  constant slot header-separator-inner :: <string>  = "",   init-keyword: header-separator-inner:;
  constant slot header-separator-right :: <string>  = "",   init-keyword: header-separator-right:;
  // Any other separator line.
  constant slot separator-left         :: <string>  = "",   init-keyword: separator-left:;
  constant slot separator-line         :: <string?> = #f,   init-keyword: separator-line:;
  constant slot separator-inner        :: <string>  = "",   init-keyword: separator-inner:;
  constant slot separator-right        :: <string>  = "",   init-keyword: separator-right:;
  // Bottom border
  constant slot bottom-left            :: <string>  = "",   init-keyword: bottom-left:;
  constant slot bottom-line            :: <string?> = #f,   init-keyword: bottom-line:;
  constant slot bottom-inner           :: <string>  = "",   init-keyword: bottom-inner:;
  constant slot bottom-right           :: <string>  = "",   init-keyword: bottom-right:;
end class;

define constant $border-top      = #"_top";
define constant $border-internal = #"_internal";
define constant $border-header   = #"_header";
define constant $border-bottom   = #"_bottom";

define constant <border-place>
  = one-of($border-top, $border-internal, $border-header, $border-bottom);

// TODO: validate that each string is either 0 or 1 in size?

// No edge borders, just whitespace between columns and after header row.
define constant $internal-whitespace-borders
  = make(<border-style>,
         data-row-inner: "  ",
         header-separator-left: "",
         header-separator-line: " ",
         header-separator-inner: "  ",
         header-separator-right: "");

define constant $default-borders = $internal-whitespace-borders;

// Boxes, but with dashed lines, so chic, n'est pas?
define constant $dashed-borders
  = make(<border-style>,
         top-left: "+",
         top-inner: "-",
         top-right: "+",
         top-line: "-",
         data-row-left:  "|",
         data-row-inner: "|",
         data-row-right: "|",
         header-separator-left: "|",
         header-separator-inner: "=",
         header-separator-line:  "=",
         header-separator-right: "|",
         separator-left: "|",
         separator-line: "-",
         separator-inner: "+",
         separator-right: "|",
         bottom-left: "+",
         bottom-inner: "-",
         bottom-right: "+",
         bottom-line: "-");

define class <separator> (<object>)
end class;

// A description of how to display rows.  By default there are no visible borders.
define open class <columnist> (<object>)
  constant slot %columns :: <sequence>,
    required-init-keyword: columns:;
  constant slot %borders :: <border-style> = $default-borders,
    init-keyword: borders:;
end class;

define method initialize (c :: <columnist>, #key) => ()
  validate-columns(c);
end;

define method validate-columns (columnist :: <columnist>)
  for (c in columnist.%columns)
    let min = c.%min-width;
    let max = c.%max-width;
    min
      & (min < $minimum-column-width)
      & error("column min width (%d) must be at least %d",
              min, $minimum-column-width);
    max
      & (max < $minimum-column-width)
      & error("column max width (%d) must be at least %d",
              max, $minimum-column-width);
    min & max
      & (min > max)
      & error("column min width (%d) must not be greater than column max width (%d)",
              min, max);
  end;
end method;

define open class <column> (<object>)
  // Widths in characters. Assumes fixed-width fonts....hmm.
  constant slot %min-width :: <integer> = $minimum-column-width,
    init-keyword: minimum-width:;
  constant slot %max-width :: false-or(<integer>) = #f,
    init-keyword: maximum-width:;
  constant slot %header :: <string?> = #f,
    init-keyword: header:;
  // constant slot %allow-wrap? :: <boolean> = #t,
  //   init-keyword: allow-wrap?:;
  constant slot %alignment :: <alignment> = $align-left,
    init-keyword: alignment:;
end class;

define method cell-data-as-string (cell-data :: <object>) => (s :: <string>)
  print-to-string(cell-data, escape?: #f)
end;

define method cell-data-as-string (cell-data :: <string>) => (s :: <string>)
  cell-data
end;


// Print a table described by `columnist` using data in `rows`. Each row is either a
// <separator> or a sequence of objects to be displayed.  All non-separator rows must be
// the same length.  Any cell data that is not a string is converted to a string via
// print-to-string:print:io with `escape?: #f`. There are no column headers; instead use
// the first row as header data and add a <separator> as the second row.
//
// Sigh. I feel like all this code is way too complex and there is probably some more
// elegant way to do it, but I can't see it.
define method columnize
    (stream :: <stream>, columnist :: <columnist>, rows :: <sequence>)
  validate-rows(columnist, rows);
  let columns = columnist.%columns;

  // Wrap cells if needed and compute column widths.
  let column-widths = make(<vector>, size: columns.size, fill: 0);
  for (column in columns,
       ci from 0)
    // TODO: support wrapped column headers
    column-widths[ci] := max(column.%min-width, size(column.%header | ""));
  end;
  let new-rows = make(<stretchy-vector>);
  for (row in rows)
    if (instance?(row, <separator>))
      // Separators always take exactly one row for now. They can't be converted to row
      // data until column widths have been determined.
      add!(new-rows, row);
    else
      for (_row in wrap-row-cells(columns, map-as(<vector>, cell-data-as-string, row)))
        add!(new-rows, _row);
        for (datum in _row,
             column in columns,
             ci from 0)
          column-widths[ci] := max(column.%min-width, datum.size, column-widths[ci]);
        end;
      end;
    end;
  end for;

  // Output the table.  Border style is passed explicitly so subclassers can dispatch on it.
  let b = columnist.%borders;
  if (b.top-line)
    display-border-row(stream, b, column-widths, $border-top);
    new-line(stream);
  end;
  if (any?(%header, columns))
    display-header(stream, columnist, b, column-widths);
    new-line(stream);
    if (b.header-separator-line)
      display-border-row(stream, b, column-widths, $border-header);
      new-line(stream);
    end;
  end;
  for (row in new-rows,
       ri from 0)
    display-data-row(stream, columnist, b, column-widths, row);
    // Don't output a \n after the last line. That's up to our caller to decide.
    let last-row? = ri == new-rows.size - 1;
    if (last-row?)
      if (b.bottom-line)
        new-line(stream);
        display-border-row(stream, b, column-widths, $border-bottom);
      end;
    else
      new-line(stream);
      if (b.separator-line)
        display-border-row(stream, b, column-widths, $border-internal);
        new-line(stream);
      end;
    end;
  end for;
end method;

define method display-header
    (stream :: <stream>, columnist :: <columnist>, b :: <border-style>,
     column-widths :: <sequence>)
 => ()
  display-data-row(stream, columnist, b, column-widths, map(%header, columnist.%columns));
end method;

define method display-data-row
    (stream :: <stream>, columnist :: <columnist>, b :: <border-style>,
     column-widths :: <sequence>, row :: <sequence>)
 => ()
  let ncols = column-widths.size;
  for (text in row,
       column in columnist.%columns,
       ci from 0)
    (ci == 0)
      & write(stream, b.data-row-left);
    let padder = select (column.%alignment)
                   $align-left => pad-right;
                   $align-center => pad;
                   $align-right => pad-left;
                 end;
    write(stream, padder(text, column-widths[ci]));
    (ci < ncols - 1)
      & write(stream, b.data-row-inner);
  end for;
  write(stream, b.data-row-right);
end method;

define method display-border-row
    (stream :: <stream>, style :: <border-style>, column-widths :: <sequence>,
     place :: <border-place>)
 => ()
    let (left, line, inner, right)
      = select (place)
          $border-top =>
            values(style.top-left, style.top-line, style.top-inner, style.top-right);
          $border-header =>
            values(style.header-separator-left, style.header-separator-line,
                   style.header-separator-inner, style.header-separator-right);
          $border-internal =>
            values(style.separator-left, style.separator-line,
                   style.separator-inner, style.separator-right);
          $border-bottom =>
            values(style.bottom-left, style.bottom-line,
                   style.bottom-inner, style.bottom-right);
        end;
    write(stream, left);
    for (width in column-widths,
         ci from 0)
      write(stream, pad(line, width, fill: line[0]));
      (ci < column-widths.size - 1)
        & write(stream, inner);
    end;
    write(stream, right);
end method;

define method validate-rows (columnist :: <columnist>, rows :: <sequence>)
  if (empty?(rows))
    error("no rows provided");
  else
    let n-columns = columnist.%columns.size;
    for (row in rows,
         i from 0)
      unless (instance?(row, <separator>)
                | (instance?(row, <sequence>)
                     & row.size == n-columns))
        error("row must be either a separator or a sequence with the same length"
                " as other rows (row %d)", i);
      end
    end
  end
end method;

// Wrap the cell data in `row` based on the <column>s in `columns`, potentially splitting
// the row into multiple rows.
define function wrap-row-cells
    (columns :: <sequence>, row :: <sequence>) => (new-rows :: <sequence>)
  let wrapped-lines = make(<vector>, size: columns.size, fill: #());
  let num-rows = 0;
  for (cell-datum in row,
       column in columns,
       i from 0)
    let max-width = column.%max-width;
    let lines = if (max-width & cell-datum.size > max-width)
                  split-cell-datum(cell-datum, max-width)
                else
                  list(cell-datum)
                end;
    wrapped-lines[i] := lines;
    num-rows := max(num-rows, lines.size);
  end;
  let new-rows = make(<vector>, size: num-rows);
  let ri = 0;
  until (every?(empty?, wrapped-lines))
    let new-row = make(<vector>, size: columns.size, fill: "");
    for (lines in wrapped-lines,
         ci from 0)
      new-row[ci] := if (empty?(lines)) "" else head(lines) end;
      wrapped-lines[ci] := tail(lines);
    end;
    new-rows[ri] := new-row;
    ri := ri + 1;
  end;
  new-rows
end function;

define function split-cell-datum
    (cell-datum :: <string>, cell-width :: <integer>)
 => (lines :: <list>)
  let length = cell-datum.size;
  local method skip (i, test)
          while (i < length & test(cell-datum[i]))
            i := i + 1
          end;
          i
        end;
  let lines = #();
  let line-start = 0;
  let line-end = 0;
  block (exit-block)
    while (#t)
      let wstart = skip(line-end, whitespace?);
      let wend = skip(wstart, compose(\~, whitespace?));
      let width = wend - line-start;
      if (width >= cell-width)
        if (line-end == 0)      // initial word size > cell-width
          line-end := cell-width;
        end;
        lines := pair(copy-sequence(cell-datum, start: line-start, end: line-end),
                      lines);
        line-start := skip(line-end, whitespace?);
        if (line-start == length)
          exit-block()
        end;
      elseif (wend == length)
        lines := pair(copy-sequence(cell-datum, start: line-start), lines);
        exit-block();
      end;
      line-end := min(wend, line-start + cell-width);
    end while;
  end block;
  reverse!(lines)
end function;
