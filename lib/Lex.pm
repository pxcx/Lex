####################
##				  ##
##	 ANALIZADOR	  ##
##	   LEXICO	  ##
##				  ##
####################
use strict;
use warnings;

###################
##				 ##
##	DECLARACOES  ##
##				 ##
###################
package Lex;

# LISTA DOS DELIMITADORES
my @delimitadores = ();
# LISTA DOS KEYWORDS
my @keywords = ();
# STR DO CODIGO FONTE
#my $code = "";
# ARRAY DE PALAVRAS SEPARADAS
my @palavras = ();
# ARRAY DE PALAVRAS SEPARADAS
my @linhas = ();
# ARRAY DE TOKENS
my @tokens = ();
# POSICAO DO PARSER
my $parser = 0;

####################
##				  ##
##	FUNCOES AUX	  ##
##				  ##
####################

# ABRE UM ARQUIVO E DEVOLVE O HANDLER
sub abrir{
	open(my $fp, "<", $_[0]) || die "NAO FOI POSSIVEL ABRIR <".$_[0]."! ERRO INFORMADO: ".$!;
	return $fp;
}

# REMOVE ESPACOS EM BRANCO NO FINAL E NO INICIO DE UMA STRING
sub  trim{
	my $s = shift;
	$s =~ s/^\s+|\s+$//g;
	return $s;
}

# REMOVE OS COMENTARIOS DE UMA STRING !!! BUGADA !!!
sub removeComentario{
	my $open = 0;
	my $count = 0;

	foreach(@linhas){
		my $auxOpen = index $_->{"LINHA"}, "(*";
		my $auxClose = index $_->{"LINHA"}, "*)";

		if($auxOpen != -1 && $auxClose != -1){
			$_->{"LINHA"} = substr $_->{"LINHA"}, 0, $auxOpen;
		}
		else{
			if($auxOpen != -1){
				$open = 1;
				$_->{"LINHA"} = substr $_->{"LINHA"}, $auxOpen, (length($_->{"LINHA"})-$auxOpen), "";
			}

			if($auxClose != -1){
				$open = 0;
				delete $linhas[$count];
			}

			delete $linhas[$count] if($open == 1);
		}

		$count++;
	}
}


# LE O CODIGO FONTE
sub lerSRC{
	my $fp = abrir $_[0];
	my $comment = 0;
	my $linha = 1;
	while (<$fp>){
		if (substr($_, 0, 2) ne "--"){
			$_ =~ s/\s/ /g;

			my %aux = (
				"LINHA" => $_,
				"NRO" => $linha,
			);

			my $linhaRef = \%aux;
			push @linhas, $linhaRef;
		}
		$linha++;
	}

	removeComentario;

	return 1;
}

# LE A TABELA DE DELIMITADORES
sub lerDelimitadores{
	my $fp = abrir $_[0];
	while (<$fp>) {
		push @delimitadores, trim $_;
	}

	$delimitadores[0] = " ";
}

# LE A TABELA DE KEYWORDS
sub lerKeywords{
	my $fp = abrir $_[0];
	while (<$fp>) {
		push @keywords, trim $_;
	}
}



####################
##				  ##
##	FUNCOES PIK	  ##
##				  ##
####################

# VERFIFICA SE UM CHAR ESTA NA LISTA DE DELIMITADORES
sub ehDelimitador{
	my $char = $_[0];
	foreach(@delimitadores){
		if($char eq $_){
			return 1;
		}
	}

	return 0;
}

# VERFIFICA SE UM CHAR ESTA NA LISTA DE KEYWORDS
sub ehKeyword{
	my $char = $_[0];
	foreach(@keywords){
		if($char eq $_){
			return 1;
		}
	}

	return 0;
}

# SEPARA CADA BLOCO DO $code BASEADO NOS DELIMITADORES
sub separa{
	my $token = "";
	my $strOpen = 0;

	foreach(@linhas){
		if($_){
			my $code = $_->{"LINHA"};
		
			for(my $i=0; $i< length $code; $i++){
				my $letra = substr($code, $i, 1);

				if($letra eq "\""){
					$strOpen = $strOpen == 0 ? 1 : 0;
				}


				if(ehDelimitador($letra) && $strOpen == 0){
					if ( ($letra eq "<" && (substr($code, $i+1, 1) eq "-" || substr($code, $i+1, 1) eq "=")) || ($letra eq ">" && substr($code, $i+1, 1) eq "=") ){
						$letra = $letra . substr($code, $i+1, 1);
						$i++;
					}

					if(length $token > 0){
						my %auxHash = (
							"PALAVRA" => $token,
							"LINHA" => $_->{"NRO"}
						);
						my $auxRef = \%auxHash;
						push @palavras, $auxRef;
						$token = "";
					}
					if($letra ne " " && $letra ne "\n" && $letra ne "\t"){
						my %auxHash = (
							"PALAVRA" => $letra,
							"LINHA" => $_->{"NRO"}
						);
						my $auxRef = \%auxHash;
						push @palavras, $auxRef;
					}
				}
				else{
					$token = $token . $letra;
				}
			} # fim do for interno
		}
	}
	return @palavras;
}

# TESTA SE UM TONKEN EH UM INTEGER
sub testaInteger{
	my $token = $_[0]->{"PALAVRA"};
	my $linha = $_[0]->{"LINHA"};
	
	if($token =~ m/^[A-Za-z0-9]*\d+[A-Za-z0-9]*$/){

		my %t = (
				"VALOR" => $token,
				"TIPO" => "INTEGER",
				"LINHA" => $linha,
			);
		my $tokenRef = \%t;
		push @tokens, $tokenRef;
	}
	else{
		return 0;
	}
}

# TESTA SE UM TONKEN EH UMA STRING
sub testaString{
	my $token = $_[0]->{"PALAVRA"};
	my $linha = $_[0]->{"LINHA"};
	
	if($token =~ m/^".*$/){

		my %t = (
				"VALOR" => $token,
				"TIPO" => "STRING",
				"LINHA" => $linha,
			);
		my $tokenRef = \%t;
		push @tokens, $tokenRef;
	}
	else{
		return 0;
	}
}

# TESTA SE UM TONKEN EH UM TYPE ID
sub testaType{
	my $token = $_[0]->{"PALAVRA"};
	my $linha = $_[0]->{"LINHA"};
	
	if($token =~ m/^[A-Z].*$/){

		my %t = (
				"VALOR" => $token,
				"TIPO" => "TYPE ID",
				"LINHA" => $linha,
			);
		my $tokenRef = \%t;
		push @tokens, $tokenRef;
	}
	else{
		return 0;
	}
}


# TESTA SE UM TONKEN EH UM OBJECT ID
sub testaObject{
	my $token = $_[0]->{"PALAVRA"};
	my $linha = $_[0]->{"LINHA"};
	
	if($token =~ m/^[a-z].*$/ && !ehKeyword $token){

		my %t = (
				"VALOR" => $token,
				"TIPO" => "OBJECT ID",
				"LINHA" => $linha,
			);
		my $tokenRef = \%t;
		push @tokens, $tokenRef;
	}
	else{
		return 0;
	}
}

# TESTA SE UM TONKEN EH UM SPECIAL NOTATITION
sub testaNotacao{
	my $token = $_[0]->{"PALAVRA"};
	my $linha = $_[0]->{"LINHA"};
	
	if(ehDelimitador $token){

		my %t = (
				"VALOR" => $token,
				"TIPO" => "SPECIAL NOTATION",
				"LINHA" => $linha,
			);
		my $tokenRef = \%t;
		push @tokens, $tokenRef;
	}
	else{
		return 0;
	}
}

# TESTA SE UM TONKEN EH UMA KEYWORD
sub testaKeyword{
	my $token = $_[0]->{"PALAVRA"};
	my $linha = $_[0]->{"LINHA"};
	
	if(ehKeyword $token){

		my %t = (
				"VALOR" => $token,
				"TIPO" => "KEYWORD",
				"LINHA" => $linha,
			);
		my $tokenRef = \%t;
		push @tokens, $tokenRef;
	}
	else{
		return 0;
	}
}

# RETORNA O PROXIMO TOKEN DA LISTA
sub nextToken{
	if($parser < scalar @tokens){
		my $aux = $tokens[$parser];
		$parser++;
		return $aux;
	}

	return 0;
}


# CONSULTA O FOLLOW DO TOKEN ATUAL
sub follow{
	if($parser < scalar @tokens){
		return $tokens[$parser];
	}

	return 0;
}

sub current{
	if($parser < scalar @tokens){
		return $tokens[$parser - 1];
	}

	return 0;
}

###################
##				 ##
##	INICIALIZAR  ##
##				 ##
###################

sub init{
	my $src = $_[0];
	my $delFile = "lang/delimitadores.cool";
	my $keyFile = "lang/keywords.cool";

	lerDelimitadores $delFile;
	lerKeywords $keyFile;
	lerSRC $src;
	separa();
	foreach my $k (keys @palavras){
		my $i = testaInteger $palavras[$k];
		my $n = testaNotacao $palavras[$k];
		my $kw = testaKeyword $palavras[$k];
		my $s = testaString $palavras[$k];
		my $t = testaType $palavras[$k];
		my $o = testaObject $palavras[$k];

		if(!$i && !$n && !$kw && !$s && !$t && !$o){
			return @tokens;
		}
	}
	return @tokens;
}



# FIM
return 1;