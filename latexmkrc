# vim: ft=perl
#

$pdf_mode = 1;
$pdflatex = 'bash -c "pdflatex < /dev/null -file-line-error -interaction=halt-on-error -synctex=1 \"\$@\"" -- %O %S';

# remove the following with 'latexmk -c'
push @generated_exts, "run.xml";
push @generated_exts, "synctex.gz";

