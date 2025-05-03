*********
columnist
*********

.. current-library:: columnist

The columnist library can be used to display textual output in columnar format with text
wrapping, alignment, colorization, etc. within each cell.

.. toctree::
   :maxdepth: 2
   :hidden:


Status
======

Done
----

* Display rows of data in columns.
* Dashed external and internal borders or internal whitespace borders.
* Wrap text within cells.
* Text alignment within cells.
* Minimum and maximum cell width.
* Display headers and a separator between headers and data rows.

To do
-----

* Better handling of too-wide cell data for column that doesn't allow wrapping.
* Maximum overall table width.
* Column header wrapping.
* Get default max width of table from terminal size if possible.
* Handle cell data with Newline characters.
* Cells that span multiple columns or rows.
* Support terminal escape codes for colorizing etc.
* Ability to modify how an individual cell or header is displayed, independent of the
  column description.
* Probably lots of other things. See the `bug list
  <https://github.com/cgay/columnist/issues>`_.

Usage
=====

The main entry point is :gf:`columnize`. Just call it with some column definitions and
some row data. By default the output has no external borders and has two-space column
separators.

Example: Simple table
---------------------

.. code:: dylan

   columnize(stream,
             list(make(<column>),
                  make(<column>)),
             #(#(1, 2), #(3, 4)))

::

   1  2
   3  4

Example: Borders and headers
----------------------------

.. code:: dylan

   columnize(stream,
             list(make(<column>, header: "Letters"),
                  make(<column>, header: "Numbers")),
             #(#("a", 1), #("bb", 22)),
             borders: $dashed-borders)

::

   +---------------+
   |Letters|Numbers|
   |===============|
   |a      |1      |
   |-------+-------|
   |bb     |22     |
   +---------------+


columnist reference
===================

.. current-module:: columnist

.. generic-function:: columnize

   :signature: columnize (stream columnist rows #rest columnist-options) => ()

   Print rows of data to a stream in columnar form (i.e., as a table).

   :parameter stream: An instance of :class:`<stream>`.
   :parameter columnist: An instance of :const:`<column-spec>`.
   :parameter rows: An instance of :drm:`<sequence>`.  Each row is a sequence of cell
      data.  Each row must have the same number of elements as there are columns in the
      table.  All data is converted to strings using `print-to-string(..., escape?: #f)
      <https://opendylan.org/library-reference/io/print.html#io:print:print-to-string>`_.
   :parameter #rest columnist-options: Options to be passed to :drm:`make` when creating
      a :class:`<columnist>` instance.  See :class:`<columnist>` init options.

.. method:: columnize
   :specializer: <stream>, <sequence>, <sequence>

   A method that accepts a sequence of :class:`<column>` objects. This method is simply a
   convenience so that you don't need to explicitly create a :class:`<columnist>` object.

.. method:: columnize
   :specializer: <stream>, <columnist>, <sequence>

   A method that accepts an instance of :class:`<columnist>`.

Alignment
---------

Specify alignment within a column with ``alignment:`` keyword. For example: ``alignment:
$align-right``.  The default alignment is :const:`$align-left`.

.. constant:: $align-center

   Center align cell text.

.. constant:: $align-left

   Left align cell text.

.. constant:: $align-right

   Right align cell text.

Borders
-------

Specify the border style either when creating an instance of :class:`<columnist>` or when
calling :gf:`columnist`. Examples:

.. code:: dylan

   columnize(stream, make(<columnist>, columns, borders: $dashed-borders), rows)
   // or
   columnize(stream, columns, rows, borders: $dashed-borders)

.. constant:: $dashed-borders

   Use "dashed" borders. Using "+", "-", and "|" characters for all borders, including
   a border between each row.

.. constant:: $default-borders

   Currently the same as :const:`$internal-whitespace-borders`.

.. constant:: $internal-whitespace-borders

   No external borders, but a blank line after the column headers (if any) and two spaces
   between columns.

Columns
-------

.. class:: <column>
   :open:

   A ``<column>`` describes how each cell in a given column should be displayed.

   :superclasses: :drm:`<object>`

   :keyword alignment: An instance of :const:`<alignment>`.
   :keyword header: An instance of :const:`<string?>`.
   :keyword maximum-width: An instance of ``false-or(<integer>)``. The default is
      :drm:`#f`.
   :keyword minimum-width: An instance of :drm:`<integer>`. The default is ``0``.
   :keyword pad?: An instance of :drm:`<boolean>`. If :drm:`#f` then no whitespace
      padding is output after the cell value. This is only useful if this is the last
      cell in the row to contain any data and there are no column borders. The intended
      use case is to avoid trailing whitespace in terminal output.

Other
-----

.. class:: <columnist>
   :open:

   A description of how to display a table. Currently the only attributes are a sequence
   of :class:`<column>` instances and a border specification. 

   :superclasses: :drm:`<object>`

   :keyword borders: An instance of :class:`<border-style>`. The default is
      :const:`$default-borders`.
   :keyword required columns: A :drm:`<sequence>` of :class:`<column>` instances.


columnist-protocol reference
============================

.. current-module:: columnist-protocol

This module is provided for anyone who wants to create their own border type. For now, if
you want to extend the library Use The Sauce.

.. constant:: $border-bottom

.. constant:: $border-header

.. constant:: $border-internal

.. constant:: $border-top

.. constant:: <alignment>

.. constant:: <border-place>

.. class:: <border-style>

   :superclasses: :drm:`<object>`

   :keyword bottom-inner: An instance of :drm:`<string>`.
   :keyword bottom-left: An instance of :drm:`<string>`.
   :keyword bottom-line: An instance of :const:`<string?>`.
   :keyword bottom-right: An instance of :drm:`<string>`.
   :keyword data-row-inner: An instance of :drm:`<string>`.
   :keyword data-row-left: An instance of :drm:`<string>`.
   :keyword data-row-right: An instance of :drm:`<string>`.
   :keyword header-separator-inner: An instance of :drm:`<string>`.
   :keyword header-separator-left: An instance of :drm:`<string>`.
   :keyword header-separator-line: An instance of :const:`<string?>`.
   :keyword header-separator-right: An instance of :drm:`<string>`.
   :keyword separator-inner: An instance of :drm:`<string>`.
   :keyword separator-left: An instance of :drm:`<string>`.
   :keyword separator-line: An instance of :const:`<string?>`.
   :keyword separator-right: An instance of :drm:`<string>`.
   :keyword top-inner: An instance of :drm:`<string>`.
   :keyword top-left: An instance of :drm:`<string>`.
   :keyword top-line: An instance of :const:`<string?>`.
   :keyword top-right: An instance of :drm:`<string>`.

.. generic-function:: bottom-inner

   :signature: bottom-inner (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :drm:`<string>`.

.. generic-function:: bottom-left

   :signature: bottom-left (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :drm:`<string>`.

.. generic-function:: bottom-line

   :signature: bottom-line (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :const:`<string?>`.

.. generic-function:: bottom-right

   :signature: bottom-right (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :drm:`<string>`.

.. generic-function:: data-row-inner

   :signature: data-row-inner (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :drm:`<string>`.

.. generic-function:: data-row-left

   :signature: data-row-left (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :drm:`<string>`.

.. generic-function:: data-row-right

   :signature: data-row-right (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :drm:`<string>`.

.. generic-function:: display-border-row

   :signature: display-border-row (stream style column-widths place) => ()

   :parameter stream: An instance of ``<stream>``.
   :parameter style: An instance of :class:`<border-style>`.
   :parameter column-widths: An instance of :drm:`<sequence>`.
   :parameter place: An instance of :const:`<border-place>`.

.. generic-function:: display-data-row

   :signature: display-data-row (stream columnist b column-widths row) => ()

   :parameter stream: An instance of ``<stream>``.
   :parameter columnist: An instance of :class:`<columnist>`.
   :parameter b: An instance of :class:`<border-style>`.
   :parameter column-widths: An instance of :drm:`<sequence>`.
   :parameter row: An instance of :drm:`<sequence>`.

.. generic-function:: display-header

   :signature: display-header (stream columnist b column-widths) => ()

   :parameter stream: An instance of ``<stream>``.
   :parameter columnist: An instance of :class:`<columnist>`.
   :parameter b: An instance of :class:`<border-style>`.
   :parameter column-widths: An instance of :drm:`<sequence>`.

.. generic-function:: display-table

   :signature: display-table (stream columnist rows) => ()

   :parameter stream: An instance of ``<stream>``.
   :parameter columnist: An instance of :class:`<columnist>`.
   :parameter rows: An instance of :drm:`<sequence>`.

.. generic-function:: header-separator-inner

   :signature: header-separator-inner (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :drm:`<string>`.

.. generic-function:: header-separator-left

   :signature: header-separator-left (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :drm:`<string>`.

.. generic-function:: header-separator-line

   :signature: header-separator-line (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :const:`<string?>`.

.. generic-function:: header-separator-right

   :signature: header-separator-right (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :drm:`<string>`.

.. generic-function:: separator-inner

   :signature: separator-inner (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :drm:`<string>`.

.. generic-function:: separator-left

   :signature: separator-left (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :drm:`<string>`.

.. generic-function:: separator-line

   :signature: separator-line (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :const:`<string?>`.

.. generic-function:: separator-right

   :signature: separator-right (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :drm:`<string>`.

.. generic-function:: top-inner

   :signature: top-inner (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :drm:`<string>`.

.. generic-function:: top-left

   :signature: top-left (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :drm:`<string>`.

.. generic-function:: top-line

   :signature: top-line (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :const:`<string?>`.

.. generic-function:: top-right

   :signature: top-right (object) => (value)

   :parameter object: An instance of ``{<border-style> in columnist-protocol}``.
   :value value: An instance of :drm:`<string>`.

.. generic-function:: validate-columns

   :signature: validate-columns (columnist) => (#rest results)

   :parameter columnist: An instance of :class:`<columnist>`.
   :value #rest results: An instance of :drm:`<object>`.

.. generic-function:: validate-rows

   :signature: validate-rows (columnist rows) => (#rest results)

   :parameter columnist: An instance of :class:`<columnist>`.
   :parameter rows: An instance of :drm:`<sequence>`.
   :value #rest results: An instance of :drm:`<object>`.
