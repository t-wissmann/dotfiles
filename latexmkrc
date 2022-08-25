# vim: ft=perl
#
#
use Cwd qw(getcwd);
use Digest::MD5 qw(md5 md5_hex md5_base64);


$pdf_mode = 1;
$pdflatex = 'bash -c "pdflatex < /dev/null -file-line-error -interaction=halt-on-error -synctex=1 \"\$@\"" -- %O %S';


# always use an out-of-source aux dir
$git_root = "";
#$git_root = `git rev-parse --show-toplevel 2> /dev/null`;
if ($git_root eq "") {
    # if we are not in a git directory, then save 
    my $dir = getcwd;
    $aux_dir = $ENV{"HOME"} . "/.cache/latexmk-auxdir/" . md5_hex($dir);
    print "Using aux_dir: " . $aux_dir . "\n";
    $emulate_aux = 1;
}

# remove the following with 'latexmk -c'
push @generated_exts, "run.xml";
push @generated_exts, "bbl";
push @generated_exts, "vtc";
push @generated_exts, "synctex.gz";

