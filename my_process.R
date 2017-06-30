#!/usr/bin/env Rscript
'usage: my_process.R [-i <input>]

options:
 -i <input>  Message' -> doc

library(docopt)
opts <- docopt(doc)
str(opts) 