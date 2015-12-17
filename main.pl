use strict;
use warnings;
require Lib::Lex;

my $file = $ARGV[0];
my @tokens  = Lex::init $file;

foreach(@tokens){
	print "\t" . $$_{"VALOR"} . " => " . $$_{"TIPO"} . "\n\n";
}