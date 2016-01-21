use strict;
use warnings;
require lib::Lex;

package Parse;

sub regraA ($token) {
	if ($token->{"VALOR"} eq "class") {
		$token = Lex::nextToken();
		if ($token->{"TIPO"} eq "TYPE ID") {
			if (regraB(Lex::nextToken())) {
				$token = Lex::nextToken();
				if ($token->{"VALOR"} eq "{") {
					if (regraC(Lex::nextToken())) {
						$token = Lex::nextToken();
						if ($token->{"VALOR"} eq "}") {
							return true;
						}
						print("Erro no token ".$token->{"VALOR"});
					}
				}
			}
		}
	}
	return false;
}

sub regraB ($token) {
	if ($token->{"VALOR"} eq "inherits") {
		$token = Lex::nextToken();
		if ($token->{"TIPO"} eq "TYPE ID") {
			return true;
		}
	} else {
		return true;
	}
	return false;
}

sub regraC ($token) {
	if ($token->{"TIPO"} eq "OBJECT ID") {
		if (regraD(Lex::nextToken())) {
			$token = Lex::nextToken();
			if ($token->{"VALOR"} eq ":") {
				$token = Lex::nextToken();
				if ($token->{"TIPO"} eq "TYPE ID") {
					if (regraE(Lex::nextToken()) {
						return true;
					}
				}
			}
		}
	}
	return false;
}

sub regraD ($token) {
	if ($token->{"VALOR"} eq "(") {
		if(regraH(Lex::nextToken())) {
			$token = Lex::nextToken();
			if($token->{"VALOR"} eq ")") {
				return true;
			}
		}
	}
	return false;
}

sub regraE ($token) {
	if ($token->{"VALOR"} eq "{") {
		if (regraF(Lex::nextToken())) {
			$token = Lex::nextToken();
			if ($token->{"VALOR"} eq "}") {
				return true;
			}
		}
	} else {
		if ($token->{"VALOR"} eq "<-") {
			if (regraF(Lex::nextToken())) {
				return true;
			}
		}
	}
	return false;
}

sub regraF{
	my $valor = $_[0]->{"VALOR"};
	my $tipo = $_[0]->{"TIPO"};

	switch($valor){
		case {lc $valor eq "false"} { return true; }
		case {lc $valor eq "true"} { return true; }
		case {lc $valor eq "string"} { return true; }
		case {lc $valor eq "integer"} { return true; }
		case {$tipo eq "OBJECT ID"} {
			my $follow = Lex::follow();
			if($follow->{"VALOR"} eq "("){
				Lex::nextToken();
				if(regraJ(Lex::nextToken())){
					my $token = Lex::nextToken();
					if($token->{"VALOR"} eq ")"){
						return true;
					}
				}
				return false;
			}
			else if($follow->{"VALOR"} eq "<-"){
				Lex::nextToken();
				if(regraI(Lex::nextToken())){
						return true;
				}
				return false;
			}
			else{
				return true;
			}
		}
		case {$valor eq "("} {
			if(regraI(Lex::nextToken()){
				my $token = Lex::nextToken();
				if($token->{"VALOR"} eq ")") return true;
			}
			return false;
		}
		case {lc $valor eq "not"} {
			if(regraI(Lex::nextToken()) return true;
			return false;
		}
		case {lc $valor eq "isvoid"} {
			if(regraI(Lex::nextToken()) return true;
			return false;
		}
		case {lc $valor eq "new"} {
			my $token = Lex::nextToken();
			if($token->{"TIPO"} eq "TYPE ID") return true;
			return false;
		}
		case {$valor eq "{"} {
				if(regraJ(Lex::nextToken()){
					my $token = Lex::nextToken();
					if($token->{"VALOR"} eq "}") return true;
				}
				return false;
		}
		case {lc $valor eq "~"} {
			if(regraI(Lex::nextToken()) return true;
			return false;
		}
		case {lc $valor eq "while"} {
				if(regraI(Lex::nextToken()){
					my $token = Lex::nextToken();
					if(lc $token->{"VALOR"} eq "loop"){
						if(regraI(Lex::nextToken()){
							my $token = Lex::nextToken();
							if(lc $token->{"VALOR"} eq "pool"){
								return true;
							}
						}
					}
				}
				return false;
		}
		case {lc $valor eq "if"} {
				if(regraI(Lex::nextToken()){
					my $token = Lex::nextToken();
					if(lc $token->{"VALOR"} eq "then"){
						if(regraI(Lex::nextToken()){
							my $token = Lex::nextToken();
							if(lc $token->{"VALOR"} eq "fi"){
								return true;
							}
							else if(lc $token->{"VALOR"} eq "else"){
								if(regraI(Lex::nextToken()){
									my $token = Lex::nextToken();
									if(lc $token->{"VALOR"} eq "fi"){
										return true;
									}
								}
							}
						}
					}
				}
				return false;
		}
		case {lc $valor eq "if"} {
				if(regraI(Lex::nextToken()){
					my $token = Lex::nextToken();
					if(lc $token->{"VALOR"} eq "then"){
						if(regraI(Lex::nextToken()){
							my $token = Lex::nextToken();
							if(lc $token->{"VALOR"} eq "fi"){
								return true;
							}
							else if(lc $token->{"VALOR"} eq "else"){
								if(regraI(Lex::nextToken()){
									my $token = Lex::nextToken();
									if(lc $token->{"VALOR"} eq "fi"){
										return true;
									}
								}
							}
						}
					}
				}
				return false;
		}
		case {lc $valor eq "case"} {
				if(regraI(Lex::nextToken()){
					my $token = Lex::nextToken();
					if(lc $token->{"VALOR"} eq "of"){
						if(regraK(Lex::nextToken()){
							my $token = Lex::nextToken();
							if(lc $token->{"VALOR"} eq "esac"){
								return true;
							}
						}
					}
				}
				return false;
		}
		case {lc $valor eq "let"} {
				my $token = Lex::nextToken();
				if(lc $token->{"TIPO"} eq "OBJECT ID"){
					my $token = Lex::nextToken();
					if(lc $token->{"VALOR"} eq ":"){
						my $token = Lex::nextToken();
						if(lc $token->{"TIPO"} eq "TYPE ID"){
							if(regraL(Lex::nextToken())){
								my $token = Lex::nextToken();
								if(lc $token->{"VALOR"} eq "in"){
									if(regraI(Lex::nextToken())){
										return true;
									}
								}
							}
						}
					}
				}
				return false;
		}
	} # FIM DO SWITCH
	else{
		if(defined $_[1]){
			return false;
		}
		else{
			if(regraI($_[0])){
				my $token = Lex::nextToken();
				if($token->{"VALOR"} eq "="
					|| $token->{"VALOR"} eq "<="
					|| $token->{"VALOR"} eq "<"
					|| $token->{"VALOR"} eq "/"
					|| $token->{"VALOR"} eq "*"
					|| $token->{"VALOR"} eq "-"
					|| $token->{"VALOR"} eq "+"
				){
					if(regraI(Lex::nextToken())){
						return true;
					}
				}
			}
		}
		return false;
	}
}

sub regraG ($token) {
	if ($token->{"TIPO"} eq "OBJECT ID") {
		$token = Lex::nextToken();
		if ($token->{"VALOR"} eq ":") {
			$token = Lex::nextToken();
			if ($token->{"TIPO"} eq "TYPE ID") {
				$token = Lex::nextToken();
				if (regraH(Lex::nextToken())) {
					return true;
				}
			}
		}
	}
	return false;
}

sub regraH ($token) {
	if ($token->{"VALOR"} eq ",") {
		if (regraG(Lex::nextToken())) {
			return true;
		}
	} else {
		return true;
	}
	return false;
}

sub regraI ($token) {
	regraF($token)
}

sub regraJ ($token) {
	if (regraF(Lex::nextToken())) {
		$token = Lex::nextToken();
		if ($token->{"VALOR"} eq ",") {
			return true;
		}
	} else {
		regraF();
	}
	return false;
}

sub regraK ($token) {
	if ($token->{"TIPO"} eq "OBJECT ID") {
		$token = Lex::nextToken();
		if ($token->{"VALOR"} eq ":") {
			$token = Lex::nextToken();
			if ($token-> {"TIPO"} eq "TYPE ID") {
				if (regraL(Lex::nextToken())) {
					return true;
				}
			}
		}
	}
	return false;
}

sub regraL ($token) {
	if (regraF(Lex::nextToken())) {
		my $follow = Lex::follow();
		if ($follow() eq ";") {
			regraK($token);
		}
		return true;
	}
}

sub regraM ($token) {
	if ($token->{"VALOR"} eq "<-") {
		if (regraF(Lex::nextToken())) {
			if (regraN(Lex::nextToken)) {
				return true;
			}
		} else {
			$follow = Lex::follow();
			if ($follow->{"VALOR"} ne ",") {
				return true;
			}
		}
	}
		return false;
}

sub regraN ($token) {
	if ($token->{"VALOR"} eq = ",") {
		$token = Lex::nextToken();
		if ($token->{"TIPO"} eq "OBJECT ID"} {
			$token = Lex::nextToken();
			if ($token->{"VALOR"} eq ":") {
				$token = Lex::nextToken();
				if ($token->{"TIPO"} eq "TYPE ID") {
					if (regraM(Lex::nextToken())) {
						return true;
					}
				}
			}
		}
	} else {
		$follow = Lex:follow();
		if ($follow->{"VALOR"} eq ",") {
			return true;
		} 
	}
	return false;
}