
use strict;
use warnings;
require lib::Lex;

my $file = $ARGV[0];
my @tokens = Lex::init $file;
program();


sub expr{
	my $token = $_[0];

	if(lc $token->{"VALOR"} eq  lc "true" or lc $token->{"VALOR"} eq  lc "false"){
		# true e false
		return 1;
	}
	elsif($token->{"TIPO"} eq  "STRING" or $token->{"TIPO"} eq  "INTEGER"){
		# int e string
		return 1;
	}
	elsif($token->{"VALOR"} eq "new"){
		# new TYPE
		$token = Lex::nextToken();
		if($token->{"TIPO"} eq "TYPE ID"){
			return 1;
		}
		else{
			erro($token, "TYPE_ID");
		}
	}
	else{
		erro($token, "true, false, integer ou string");
	}


	return 0;
}

sub formal{
	# ID : TYPE
	my $token = $_[0];

	if($token->{"TIPO"} eq "OBJECT ID"){
		$token = Lex::nextToken();
		if($token->{"VALOR"} eq ":"){
			$token = Lex::nextToken();
			if($token->{"TIPO"} eq "TYPE ID"){
				return 1;
			}
			else{
				erro($token, "TYPE_ID");
			}
		}
		else{
			erro($token, ":");
		}
	}
	else{
		erro($token, "OBJECT ID");
	}

	return 0;
}


sub feature{
	my $token = $_[0];

	if($token->{"TIPO"} eq "OBJECT ID"){
		$token = Lex::nextToken();
		if($token->{"VALOR"} eq "("){
			# ID( [formal, [formal]*]) : TYPE { expr };
			# formal
			$token = Lex::nextToken();
			if($token->{"TIPO"} eq "OBJECT ID"){
				my $formal = formal $token;

				while($formal){
					$token = Lex::nextToken();
					if($token->{"VALOR"} eq ","){
						$token = Lex::nextToken();
						$formal = formal $token;
					}
					else{
						last;
					}
				}
			}

			if($token->{"VALOR"} eq ")"){
				# ) : TYPE { expr };
				$token = Lex::nextToken();
				if($token->{"VALOR"} eq ":"){
					$token = Lex::nextToken();
					if($token->{"TIPO"} eq "TYPE ID"){
						$token = Lex::nextToken();
						if($token->{"VALOR"} eq "{"){
							# expr
							$token = Lex::nextToken();
							if($token->{"VALOR"} ne "}"){
								if(expr $token){
									$token = Lex::nextToken();
								}
								else{
									return 0;
								}
							}

							#$token = Lex::nextToken();
							if($token->{"VALOR"} eq "}"){
								$token = Lex::nextToken();
								if($token->{"VALOR"} eq ";"){
									return 1;
								}
								else{
									erro($token, ";");
								}
							}
							else{
								erro($token, "}");
							}
						}
						else{
							erro($token, "{");
						}
					}
					else{
						erro($token, "TYPE ID");
					}
				}
				else{
					erro($token, ":");
				}
			}
			else{
				erro($token, ")");
			}

		}
		elsif($token->{"VALOR"} eq ":"){
			# ID : TYPE [<- expr];
			$token = Lex::nextToken();
			if($token->{"TIPO"} eq "TYPE ID"){
				$token = Lex::nextToken();
				if($token->{"VALOR"} eq "<-"){
					# expr
					$token = Lex::nextToken();
					if(expr $token){
						$token = Lex::nextToken();
					}
					else{
						return 0;
					}

				}
				if($token->{"VALOR"} eq ";"){
					return 1;
				}
				else{
					erro($token, ";");
				}

			}
			else{
				erro($token, "TYPE ID");
			}

		}
		else{
			erro($token, "( or :");
		}

	}
	else{
		erro($token, "OBJECT ID");
	}

	return 0;
}


sub rClass{
	my $token = $_[0];

	if($token->{"VALOR"} eq "class"){
		$token = Lex::nextToken();
		if($token->{"TIPO"} eq "TYPE ID"){
			$token = Lex::nextToken();
			if($token->{"VALOR"} eq "inherits"){
				# inherits
				$token = Lex::nextToken();
				if($token->{"TIPO"} eq "TYPE ID"){
					$token = Lex::nextToken();
				}
				else{
					erro($token, "TYPE_ID");
					return 0;
				}
			}
			
			if($token->{"VALOR"} eq "{"){
				# feature
				$token = Lex::nextToken();
				my $result = 1;
				while($result){
					if($token->{"VALOR"} ne "}"){
						$result = feature $token;
						$token = Lex::nextToken();
					}
					else{
						last;
					}
				}

				return 0 if $result == 0;

			}
			else{
				erro($token, "inherits or {");
				return 0;
			}

			# fechamento da classe
			# $token = Lex::nextToken();
			if($token->{"VALOR"} eq "}"){
				$token = Lex::nextToken();
				if($token->{"VALOR"} eq ";"){
					return 1;
				}
				else{
					erro($token, ";");
				}

			}
			else{
				erro($token, "}");
			}
		}
		else{
			erro($token, "TYPE_ID");
		}
	}
	else{
		erro($token, "class");
	}

	return 0;
}

sub erro{
	my $token = $_[0];
	my $msg = $_[1];
	print "Erro na linha ".$token->{"LINHA"}.", token invalido: '".$token->{"VALOR"}."' (".$token->{"TIPO"}."), era esperado: ".$msg."\n";
}

sub program{
	my $token = Lex::nextToken();
	my $result = rClass $token;

	while($result){
		$token = Lex::nextToken();
		if($token){
			$result = rClass $token;
		}
		else{
			last;
		}
		
	}

	print "===========================\nCompilacao encerrada com ERROS." if $result == 0;
	print "===========================\nCompilacao encerrada com SUCESSO." if $result == 1;
}