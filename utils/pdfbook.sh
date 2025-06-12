#!/usr/bin/env bash

# A wrapper around pdfbook2 with sane defaults:
#   Just keep the margin of the original PDF.
#
exec pdfbook2 --paper=a4paper -i 0 -o 0 -t 0 -b 0 -n "$@"

