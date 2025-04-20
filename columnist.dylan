Module: columnist-impl

// TODO:
//   * better handling of too-wide cell data for column that doesn't allow wrapping.
//   * justify cell data left, right, center
//   * support a maximum overall table width
//   * get default max width of table from terminal size if possible.
//   * handle multi-line strings (just split instead of wrap?)
//   * ability to nest tables would be cool.
//   * cells that span multiple columns or rows
//   * support terminal escape codes for colorizing etc.

define constant <int?>    = false-or(<integer>);

// Minimum column width, not counting column separator characters or borders.
define constant $minimum-column-width = 1;

// define constant $align-left   = #"_left";
// define constant $align-center = #"_center";
// define constant $align-right  = #"_right";
//define constant <alignment> = one-of($align-left, $align-center, $align-right);

// Display rows on stream as described by a <columnist>.
define generic columnize (stream :: <stream>, c :: <columnist>, rows :: <sequence>);
define generic validate-rows (c :: <columnist>, rows :: <sequence>);
define generic validate-columns (c :: <columnist>);
define generic cell-data-as-string (cell-data) => (s :: <string>);
define generic left-border         (c :: <columnist>) => (s :: <string>);
define generic inter-column-border (c :: <columnist>) => (s :: <string>);
define generic right-border        (c :: <columnist>) => (s :: <string>);
define generic display-separator
    (stream :: <stream>, c :: <columnist>, sep :: <separator>,
     column-widths :: <sequence>, row-count :: <integer>, row-num :: <integer>)
 => ();

define class <separator> (<object>)
  constant slot %border :: <string> = "-", init-keyword: border:;
end class;

define method separator-border (sep :: <separator>) => (s :: <string>)
  if (sep.%border.size > 1)
    error("separator borders of length > 1 are not yet implemented");
  end;
  sep.%border
end method;

// A description of how to display rows.  By default there are no visible borders.
define open class <columnist> (<object>)
  constant slot %columns       :: <sequence>, required-init-keyword: columns:;

  // Borders: There is no inter-row-border; use separators instead. The corner border
  // applies to all corners, whether edge or inner. If the left/right border is non-empty
  // you probably also want to supply a non-empty corner. Border strings with length > 1
  // aren't supported yet.

  constant slot %left-border         :: <string> = "",  init-keyword: left-border:;
  constant slot %right-border        :: <string> = "",  init-keyword: right-border:;
  constant slot %inter-column-border :: <string> = " ", init-keyword: inter-column-border:;
  // TODO: should this belong to the <separator> class since it is only used when writing
  // separators?
  constant slot %corner-border       :: <string> = "",  init-keyword: corner-border:;
end class;

define inline method left-border (c :: <columnist>) => (border :: <string>)
  c.%left-border
end method;

define inline method right-border (c :: <columnist>) => (border :: <string>)
  c.%right-border
end method;

define inline method inter-column-border (c :: <columnist>) => (border :: <string>)
  c.%inter-column-border
end method;

define inline method corner-border (c :: <columnist>) => (border :: <string>)
  c.%corner-border
end method;

// As a convenience, border?: #t creates a standard ASCII art border.
define method make
    (class :: subclass(<columnist>), #rest args, #key border? :: <boolean>)
 => (c :: <columnist>)
  if (border?)
    apply(next-method,
          row-edge-border: "-",
          row-inner-border: ".",
          column-edge-border: "|",
          column-inner-border: ".",
          corner-border: '+',
          args)
  else
    next-method()
  end
end method;

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
  constant slot %max-width :: <int?> = #f,
    init-keyword: maximum-width:;
  // constant slot %allow-wrap? :: <boolean> = #t,
  //   init-keyword: allow-wrap?:;
  // constant slot %margin :: <string> = " ",
  //   init-keyword: margin:;
  // constant slot %alignment :: <alignment> = $align-left,
  //   init-keyword: alignment:;
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
  let column-widths = make(<vector>, size: columns.size, fill: $minimum-column-width);
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
             i from 0)
          column-widths[i] := max(datum.size, column-widths[i]);
        end;
      end;
    end;
  end for;

  // Output the data.
  for (row in new-rows,
       ri from 0)
    if (instance?(row, <separator>))
      display-separator(stream, columnist, row, column-widths, new-rows.size, ri);
    else
      for (cell-datum in row,
           ci from 0)
        (ci == 0)
          & write(stream, columnist.left-border);
        write(stream, pad-right(cell-datum, column-widths[ci]));
        (ci < row.size - 1)
          & write(stream, columnist.inter-column-border);
      end for;
      write(stream, columnist.right-border);
    end;
    unless (ri == new-rows.size - 1)
      write-element(stream, '\n');
    end;
  end for;
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

define method display-separator
    (stream :: <stream>, columnist :: <columnist>, sep :: <separator>,
     column-widths :: <sequence>, row-count :: <integer>, row-num :: <integer>)
 => ()
  let inner-table-width
    = reduce1(\+, column-widths)
        + columnist.inter-column-border.size * (column-widths.size - 1);
  let wleft = columnist.left-border.size;
  let wright = columnist.right-border.size;
  let table-width = inner-table-width + wleft + wright;
  let sep-char = sep.separator-border[0];  // TODO: separator.size > 1
  if (row-num == 0 | row-num == row-count - 1)
    // top or bottom separator line
    write(stream, columnist.corner-border);
    write(stream, make(<string>, size: inner-table-width, fill: sep-char));
    write(stream, columnist.corner-border);
  else
    // middle separator line
    write(stream, columnist.left-border);
    let line = make(<string>, size: inner-table-width, fill: sep-char);
    let pos = 0;
    for (width in column-widths,
         col from 0,
         while: col < column-widths.size - 1)
      pos := pos + width;
      for (ch in columnist.corner-border,
           i from pos)
        line[i] := ch;
      end;
    end;
    write(stream, line);
    write(stream, columnist.right-border);
  end;
end method;
