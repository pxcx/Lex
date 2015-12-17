use strict;
use warnings;
require lib::Lex;

my $file = $ARGV[0];
my @tokens  = Lex::init $file;

foreach(@tokens){
	print "\n\t", $$_{"VALOR"}, " -> ", $$_{"TIPO"}, "\n";
}