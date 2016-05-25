# vim: ft=perl

$pdf_mode = 1;
$pdflatex = 'bash -c "pdflatex < /dev/null -interaction=halt-on-error -synctex=1 \"\$@\"" %O %S';

push @generated_exts, "run.xml";
