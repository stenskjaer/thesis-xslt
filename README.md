# XSLT Conversion script

The setup of the directory structure should make the script available to the
(lpb-print)[https://github.com/lombardpress/lbp-print] script that makes the
processing of XML files easier. I have not really tested how it works with the
script yet though, so good luck!

This is the script I use for creating textual editions for my PhD dissertation.
This means that it will not be possible to compile the output `tex`-file on its
own as the output is pulled into my dissertation `tex` with an `\input`. The
dissertation `tex` defines the whole preamble including the setup of `reledmac`.
