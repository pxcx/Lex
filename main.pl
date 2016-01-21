use strict;
use warnings;
require lib::Lex;
require lib::Parser;

my $file = $ARGV[0];
my @tokens  = Lex::init $file;

while(my $token = Lex::nextToken()){	
	print "\n\t", $token->{"VALOR"}, " -> ", $token->{"TIPO"}, "\n";
}