Module: columnist-test-suite


define function %columnize (columns, rows, #rest options)
  let columnist = apply(make, <columnist>, columns: columns, options);
  with-output-to-string (stream)
    columnize(stream, columnist, rows);
  end
end function;

define test test-columnize/defaults ()
  let rows = #(#("a", 1),
               #("bb", 22),
               #("ccc", 333),
               #("dddd", 4444));
  let text = %columnize(list(make(<column>),
                             make(<column>)),
                        rows);
  assert-equal("""
a    1   
bb   22  
ccc  333 
dddd 4444
""",
               text);
end test;

define test test-columnize/wrapping ()
  let rows
    = #(#("the quick frown box jumps over the dazy log", "column 2", "column 3"),
        #("supercalifragilistic",                        "expy",     "alidoshus"),
        #("-",                                           "",         "my dog has fleas"));
  let columns = list(make(<column>, maximum-width: 12),
                     make(<column>, maximum-width: 7),
                     make(<column>, maximum-width: 10));
  let text = %columnize(columns, rows);
  assert-equal("""
the quick    column column 3 
frown box    2               
jumps over                   
the dazy                     
log                          
supercalifra expy   alidoshus
gilistic                     
-                   my dog   
                    has fleas
""",
               text);
end test;

define test test-columnize/borders ()
  let rows = #(#("a", 1),
               #("bb", 22),
               #("ccc", 333));
  let text = %columnize(list(make(<column>),
                             make(<column>)),
                        rows,
                        left-border: "<",
                        inter-column-border: "|",
                        right-border: ">");
  assert-equal("""
<a  |1  >
<bb |22 >
<ccc|333>
""",
               text);
end test;

define test test-columnize/separators ()
  let rows = list(make(<separator>),
                  #("a", 1),
                  make(<separator>),
                  #("bb", 22),
                  make(<separator>),
                  #("ccc", 333),
                  make(<separator>));
  let text = %columnize(list(make(<column>),
                             make(<column>)),
                        rows,
                        left-border: "| ",
                        inter-column-border: " | ",
                        right-border: " |",
                        corner-border: "+");
  assert-equal("""
+-------+
|a  |1  |
|---+---|
|bb |22 |
|---+---|
|ccc|333|
+-------+
""",
               text);
end test;
