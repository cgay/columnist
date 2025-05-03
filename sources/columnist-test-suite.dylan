Module: columnist-test-suite


define function %columnize (columns, rows, #rest options)
  let columnist = apply(make, <columnist>, columns: columns, options);
  with-output-to-string (stream)
    columnize(stream, columnist, rows);
  end
end function;

define constant $abcd1234-rows = #(#("a", 1),
                                   #("bb", 22),
                                   #("ccc", 333),
                                   #("dddd", 4444));

// Default is no external borders and 2 spaces for internal borders.
define test test-columnize/defaults ()
  let text = %columnize(list(make(<column>),
                             make(<column>)),
                        $abcd1234-rows);
  assert-equal("""
a     1   
bb    22  
ccc   333 
dddd  4444
""",
               text);
end test;

// Rightmost column has no padding so no trailing whitespace.
define test test-columnize/no-padding ()
  let text = %columnize(list(make(<column>),
                             make(<column>, pad?: #f)),
                        $abcd1234-rows);
  assert-equal("""
a     1
bb    22
ccc   333
dddd  4444
""",
               text);
end test;

define constant $quick-brown-rows
  = #(#("the quick frown box jumps over the dazy log", "column 2", "column 3"),
      #("supercalifragilistic",                        "expy",     "alidoshus"),
      #("-",                                           "",         "my dog has fleas"));

define test test-columnize/wrapping ()
  let columns = list(make(<column>, maximum-width: 12),
                     make(<column>, maximum-width: 7),
                     make(<column>, maximum-width: 10));
  let text = %columnize(columns, $quick-brown-rows);
  assert-equal("""
               the quick     column  column 3 
               frown box     2                
               jumps over                     
               the dazy                       
               log                            
               supercalifra  expy    alidoshus
               gilistic                       
               -                     my dog   
                                     has fleas
               """,
               text);
end test;

define constant $abc123-rows = #(#("a", 1),
                                 #("bb", 22),
                                 #("ccc", 333));

define test test-columnize/dashed-borders ()
  let text = %columnize(list(make(<column>),
                             make(<column>)),
                        $abc123-rows,
                        borders: $dashed-borders);
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

define test test-columnize/headers-dashed-borders ()
  let text = %columnize(list(make(<column>, header: "Letters"),
                             make(<column>, header: "Numbers")),
                        $abc123-rows,
                        borders: $dashed-borders);
  assert-equal("""
+---------------+
|Letters|Numbers|
|===============|
|a      |1      |
|-------+-------|
|bb     |22     |
|-------+-------|
|ccc    |333    |
+---------------+
""",
               text);
end test;

define test test-columnize/headers-internal-whitespace-borders ()
  let text = %columnize(list(make(<column>, header: "ABC"),
                             make(<column>, header: "123")),
                        $abc123-rows,
                        borders: $internal-whitespace-borders);
  assert-equal("""
ABC  123
        
a    1  
bb   22 
ccc  333
""",
               text);
end test;

define test test-columnize/some-headers ()
  let text = %columnize(list(make(<column>, header: "ABC"),
                             make(<column>)), // header is #f
                        $abc123-rows);
  assert-equal("""
ABC     
        
a    1  
bb   22 
ccc  333
""",
               text);
end test;

define test test-columnize/alignment ()
  let text = %columnize(list(make(<column>,
                                  minimum-width: 5,
                                  alignment: $align-left),
                             make(<column>,
                                  minimum-width: 6,
                                  alignment: $align-center),
                             make(<column>,
                                  minimum-width: 7,
                                  alignment: $align-right)),
                        #(#("a", 1, "Zork"),
                          #("bb", 22, "Q*bert")),
                        borders: $dashed-borders);
  assert-equal("""
+--------------------+
|a    |  1   |   Zork|
|-----+------+-------|
|bb   |  22  | Q*bert|
+--------------------+
""",
               text);
end test;
