use strict;
use warnings;
require lib::Lex;
require lib::Parser;

my $file = $ARGV[0];
my @tokens  = Lex::init $file;

Parser::init $file;
