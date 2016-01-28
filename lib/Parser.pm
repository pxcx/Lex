use strict;
use warnings;
use Switch;

require lib::Lex;
package Parser;


my $valor = "";
my $tipo = "";
my $follow = "";



sub regraN {
	$valor = $_[0]->{"VALOR"};
	if ($valor eq ",") {
		my $token = Lex::nextToken();
		if ($token->{"TIPO"} eq "OBJECT ID") {
			$token = Lex::nextToken();
			if ($token->{"VALOR"} eq ":") {
				$token = Lex::nextToken();
				if ($token->{"TIPO"} eq "TYPE ID") {
					if (regraM(Lex::nextToken())) {
						return regraFechamento();
					}
				}
			}
		}
	} else {
		$follow = Lex::follow();
		if ($follow->{"VALOR"} eq ",") {
			return regraFechamento();
		} 
	}
	erro(Lex::current());
}

sub regraM {
	$valor = $_[0]->{"VALOR"};
	if ($valor eq "<-") {
		if (regraF(Lex::nextToken())) {
			if (regraN(Lex::nextToken())) {
				return regraFechamento();
			}
		} else {
			$follow = Lex::follow();
			if ($follow->{"VALOR"} ne ",") {
				return regraFechamento();
			}
		}
	}
		erro(Lex::current());
		return 0;
}

sub regraL {
	if (regraF(Lex::nextToken())) {
		my $follow = Lex::follow();
		if ($follow->{"VALOR"} eq ";") {
			regraK($_[0]);
		}
		return regraFechamento();
	}
	erro(Lex::current());
	return 0;
}

sub regraK {
	$tipo = $_[0]->{"TIPO"};
	if ($tipo eq "OBJECT ID") {
		my $token = Lex::nextToken();
		if ($token->{"VALOR"} eq ":") {
			$token = Lex::nextToken();
			if ($token->{"TIPO"} eq "TYPE ID") {
				if (regraL(Lex::nextToken())) {
					return regraFechamento();
				}
			}
		}
	}
	erro(Lex::current());
	return 0;
}

sub regraJ {
	if (regraF($_[0])) {
		$follow = Lex::follow();
		if ($follow->{"VALOR"} eq ",") {
			Lex::nextToken();
			regraJ(Lex::nextToken());
		} elsif ($follow->{"VALOR"} eq ")") {
			return 1;
		} else {
			erro(Lex::current());
			return 0;
		}
	} 
	erro(Lex::current());
	return 0;
}

sub regraI {
	if (regraF($_[0],1)) {
		return regraFechamento();
	}
	erro(Lex::current());
	return 0;
}

sub regraH {
	$valor = $_[0]->{"VALOR"};
	if ($valor eq ",") {
		if (regraG(Lex::nextToken())) {
			return regraFechamento();
		}
	} else {
		return regraFechamento();
	}
	erro(Lex::current());
	return 0;
}

sub regraG {
	$tipo = $_[0]->{"TIPO"};
	if ($tipo eq "OBJECT ID") {
		my $token = Lex::nextToken();
		if ($token->{"VALOR"} eq ":") {
			print "CAIU AQUI\n";
			$token = Lex::nextToken();
			if ($token->{"TIPO"} eq "TYPE ID") {
				$token = Lex::nextToken();
				if (regraH(Lex::nextToken())) {
					return regraFechamento();
				}
			}
		}
	}
	erro(Lex::current());
	return 0;
}

sub regraF {
	$valor = $_[0]->{"VALOR"};
	$tipo = $_[0]->{"TIPO"};

	switch ($valor) {
		case {lc $valor eq "false"} { 
			if (Lex::follow()->{"VALOR"} eq ")") {
				return 1;
			}
			return regraFechamento(); 
		}
		case {lc $valor eq "true"} { 
			if (Lex::follow()->{"VALOR"} eq ")") {
				return 1;
			}
			return regraFechamento(); 
		}
		case {lc $tipo eq "string"} { 
			if (Lex::follow()->{"VALOR"} eq ")") {
				return 1;
			}
			return regraFechamento(); 
		}
		case {lc $tipo eq "integer"} { 
			if (Lex::follow()->{"VALOR"} eq ")") {
				return 1;
			}
			return regraFechamento(); 
		}
		case {$tipo eq "OBJECT ID"} {
			$follow = Lex::follow();
			if($follow->{"VALOR"} eq "("){
				Lex::nextToken();
				$follow = Lex::follow();
				if ($follow->{"VALOR"} ne ")") {
					if(regraJ(Lex::nextToken())){
						my $token = Lex::nextToken();			
						if($token->{"VALOR"} eq ")"){
							return regraFechamento();
						}
					}
					erro(Lex::current());
					return 0;
					} else {
						return regraFechamento();
					}
			}
			elsif($follow->{"VALOR"} eq "<-"){
				Lex::nextToken();
				my $token = Lex::nextToken();
				if(regraI($token)) {
						return regraFechamento();
				}
				erro(Lex::current());
				return 0;
			}
			else {
				return regraFechamento();
			}
		}
		case {$valor eq "("} {
			my $token = Lex::nextToken();
			if(regraI($token)) {
				my $token = Lex::nextToken();
				if($token->{"VALOR"} eq ")") {
					return regraFechamento();
				} else {
					erro(Lex::current());
					return 0;
				}
			} else {
				erro(Lex::current());
				return 0;
			}
		}
		case {lc $valor eq "not"} {
			my $token = Lex::nextToken();
			if(regraI($token)) {
		    	return regraFechamento();
		    } else {
				erro(Lex::current());
				return 0;
			}
		}
		case {lc $valor eq "isvoid"} {
			my $token = Lex::nextToken();
			if(regraI($token)) {
				return regraFechamento();
			} else {
				erro(Lex::current());
				return 0;
			}
		}
		case {lc $valor eq "new"} {
			my $token = Lex::nextToken();
			if($token->{"TIPO"} eq "TYPE ID") {
				return regraFechamento();
			} else {
				erro(Lex::current());
				return 0;
			}
		}
		case {$valor eq "{"} {
				if(regraJ(Lex::nextToken())) {
					my $token = Lex::nextToken();
					if($token->{"VALOR"} eq "}") {
						return regraFechamento();
					} else {
						erro(Lex::current());
						return 0;
					}
				}
		}
		case {lc $valor eq "~"} {
			my $token = Lex::nextToken();
			if(regraI($token)) {
				return regraFechamento();
			} else {
				erro(Lex::current());
				return 0;
			}
		}
		case {lc $valor eq "while"} {
				my $token = Lex::nextToken();
				if(regraI($token)) {
					my $token = Lex::nextToken();
					if(lc $token->{"VALOR"} eq "loop") {
						if(regraI(Lex::nextToken())) {
							my $token = Lex::nextToken();
							if(lc $token->{"VALOR"} eq "pool") {
								return regraFechamento();
							} else {
								erro(Lex::current());
								return 0;
							}
						} else {
							erro(Lex::current());
							return 0;
						}
					} else {
						erro(Lex::current());
						return 0;
					}
				} else {
					erro(Lex::current());
					return 0;
				}
		}
		case {lc $valor eq "if"} {
				my $token = Lex::nextToken();
				if(regraI($token)) {
					$token = Lex::nextToken();
					if(lc $token->{"VALOR"} eq "then") {
						$token = Lex::nextToken();
						if(regraI($token)) {
							$token = Lex::nextToken();
							if(lc $token->{"VALOR"} eq "fi") {
								return regraFechamento();
							}
							elsif(lc $token->{"VALOR"} eq "else") {
								$token = Lex::nextToken();
								if(regraI($token)) {
									my $token = Lex::nextToken();
									if(lc $token->{"VALOR"} eq "fi"){
										return regraFechamento();
									} else {
										erro(Lex::current());
										return 0;
									}
								} else {
									erro(Lex::current());
									return 0;
								}
							}
						} else {
							erro(Lex::current());
							return 0;
						}
					} else {
						erro(Lex::current());
						return 0;
					} 
				} else {
					erro(Lex::current());
					return 0;
				} 
		}
		case {lc $valor eq "if"} {
				if(regraI(Lex::nextToken())) {
					my $token = Lex::nextToken();
					if(lc $token->{"VALOR"} eq "then"){
						if(regraI(Lex::nextToken())) {
							my $token = Lex::nextToken();
							if(lc $token->{"VALOR"} eq "fi"){
								return regraFechamento();
							}
							elsif(lc $token->{"VALOR"} eq "else"){
								if(regraI(Lex::nextToken())) {
									my $token = Lex::nextToken();
									if(lc $token->{"VALOR"} eq "fi"){
										return regraFechamento();
									}
								}
							}
						}
					}
				}
				print "ERRO AQUI F11"; return 0;
		}
		case {lc $valor eq "case"} {
				my $token = Lex::nextToken();
				if(regraI($token)) {
					$token = Lex::nextToken();
					if(lc $token->{"VALOR"} eq "of") {
						$token = Lex::nextToken();
						if(regraK($token)) {
							$token = Lex::nextToken();
							if(lc $token->{"VALOR"} eq "esac") {
								return regraFechamento();
							} else {
								erro(Lex::current());
								return 0;
							}
						} else {
							erro(Lex::current());
							return 0;
						} 
					}
				} else {
					erro(Lex::current());
					return 0;
				}
		}
		case {lc $valor eq "let"} {
				my $token = Lex::nextToken();
				if(lc $token->{"TIPO"} eq "OBJECT ID"){
					$token = Lex::nextToken();
					if(lc $token->{"VALOR"} eq ":"){
						$token = Lex::nextToken();
						if(lc $token->{"TIPO"} eq "TYPE ID"){
							$token = Lex::nextToken();
							if(regraL($token)){
								$token = Lex::nextToken();
								if(lc $token->{"VALOR"} eq "in"){
									$token = Lex::nextToken();
									if(regraI($token)){
										return regraFechamento();
									} else {
										erro(Lex::current());
										return 0;
									}
								} else {
									erro(Lex::current());
									return 0;
								}
							} else {
								erro(Lex::current());
								return 0;
							}
						}
					} else {
						erro(Lex::current());
						return 0;	
					}
				}
				erro(Lex::current());
		}
		else {
			if(defined $_[1]) {
				erro(Lex::current());
				return 0;
			}
			else {
				if(regraI($_[0])){
					my $token = Lex::nextToken();
					if($token->{"VALOR"} eq "="
						|| $token->{"VALOR"} eq "<="
						|| $token->{"VALOR"} eq "<"
						|| $token->{"VALOR"} eq "/"
						|| $token->{"VALOR"} eq "*"
						|| $token->{"VALOR"} eq "-"
						|| $token->{"VALOR"} eq "+"
					) {
						$token = Lex::nextToken();
						if(regraI($token)){
							return regraFechamento();
						} else {
							erro(Lex::current());
							return 0;
						}
					} else {
						erro(Lex::current());
						return 0;
					}
				} else {
					erro(Lex::current());
					return 0;
				}
			}
			erro(Lex::current());
			return 0;
		}
	} # FIM DO SWITCH
}

sub regraE {
	$valor = $_[0]->{"VALOR"};
	if ($valor eq "{") {
		if (regraF(Lex::nextToken())) {
			my $token = Lex::nextToken();
			if ($token->{"VALOR"} eq "}") {
				return regraFechamento();
			}
		}
	} else {
		if (my $token->{"VALOR"} eq "<-") {
			if (regraF(Lex::nextToken())) {
				return regraFechamento();
			}
		}
	}
	erro(Lex::current());
	return 0;
}

sub regraD {
	$valor = $_[0]->{"VALOR"};
	if ($valor eq "(") {
		$follow = Lex::follow();
		if($follow->{"VALOR"} ne ")") { 
			if (regraH(Lex::nextToken())) {
				my $token = Lex::nextToken();
				if($token->{"VALOR"} eq ")") {
					return regraFechamento();
				} else {
					erro(Lex::current());
				}
			} else {
				erro(Lex::current());
			}
		} else {
			Lex::nextToken();
			return 1;
		}
	} else {
		erro(Lex::current());
	}
	erro(Lex::current());
	return 0;
}

sub regraC {
	$tipo = $_[0]->{"TIPO"};
	if ($tipo eq "OBJECT ID") {
		if (regraD(Lex::nextToken())) {
			my $token = Lex::nextToken();
			if ($token->{"VALOR"} eq ":") {
				$token = Lex::nextToken();
				if ($token->{"TIPO"} eq "TYPE ID") {
					if (regraE(Lex::nextToken())) {
						return 1;
					} else {
						erro(Lex::current());
					}
				} else {
					erro(Lex::current());
				}
			} else {
				erro(Lex::current());
			}
		} else {
			erro(Lex::current());
		}
	} else {
		erro(Lex::current());
	}
	erro(Lex::current());
	return 0;
}

sub regraB {
	$valor = $_[0]->{"VALOR"};
	if ($valor eq "inherits") {
		my $token = Lex::nextToken();
		if ($token->{"TIPO"} eq "TYPE ID") {
			return 1;
		}
	} elsif ($valor eq "{") {
		return 1;
	} else {
		erro(Lex::current());
		return 0;
	}
}

sub regraA {
	$valor = $_[0]->{"VALOR"};

	if ($valor eq "class") {
		my $token = Lex::nextToken();
		if ($token->{"TIPO"} eq "TYPE ID") {
			if (regraB(Lex::nextToken())) {
				$token = Lex::nextToken();
				if ($token->{"VALOR"} eq "{") {
					if (regraC(Lex::nextToken())) {
						$token = Lex::nextToken();
						if ($token->{"VALOR"} eq "}") {
							return 1;
						} 
					}
				}
			}
		} 
	}
	erro(Lex::current());
	return 0;
}

sub erro {
	my $token = $_[0]->{"VALOR"};
	my $linha = $_[0]->{"LINHA"};
	print "O SEGUINTE TOKEN: ".$token." NAO EH ESPERADO NA LINHA ".$linha."\n";
}

sub regraFechamento {
	$follow = Lex::follow();
	if ($follow->{"VALOR"} eq ";" || $follow->{"VALOR"} eq "}") {
		Lex::nextToken();
		return 1;
	} else {
		erro($follow);
		return 0;
	}
}

sub init {
	my @tokens = Lex::init $_[0];
	my $token = Lex::nextToken();

	if (regraA $token) {
		print "\n\nSUCESSO!!!";
	} else {
		print "\n\nERROS FORAM ENCONTRADOS";
	}


#	while($token){
#		print $token->{"VALOR"}."\n";
#		$token = Lex::nextToken();
#	}

}

return 1;



















