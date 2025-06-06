# Columnist

[![tests](https://github.com/cgay/columnist/actions/workflows/test.yml/badge.svg)](https://github.com/cgay/columnist/.github/workflows/test.yml)


Columnist helps create columnar text output from sequences (rows) of data.  For a good
example of what I'm trying to create here, see [this Python
project](https://github.com/acksmaggart/columnar).

The initial version of Columnist is, however, far more humble. The goal is simply to help
making prettier output for the `--help` output generated by the command-line-parser
library.

Examples of current output with and without borders:

```
ABC  123        +---------------+
                |Letters|Numbers|
a    1          |===============|
bb   22         |a      |1      |
ccc  333        |-------+-------|
                |bb     |22     |
                |-------+-------|
                |ccc    |333    |
                +---------------+
```

Full documentation is [here](https://package.opendylan.org/columnist/index.html).
