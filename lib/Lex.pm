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
my $code = "";
# ARRAY DE PALAVRAS SEPARADAS
my @palavras = ();
# ARRAY DE TOKENS
my @tokens = ();

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

# LE O CODIGO FONTE
sub lerSRC{
	my $fp = abrir $_[0];
	my $comment = 0;
	while (<$fp>){
		if (substr($_, 0, 2) ne "--"){
			if(substr($_, 0, 2) eq "(*" || substr($_, 0, 2) eq "*)" || substr($_, length($_)-3, 2) eq "*)"){
				$comment = $comment == 0 ? 1 : 0;
			}

			if ($comment == 0 && substr($_, 0, 2) ne "*)" && substr($_, length($_)-3, 2) ne "*)"){
				$code = $code . $_;
			}
		}
	}
	$code =~ s/\s/ /g;

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

	for(my $i=0; $i< length $code; $i++){
		my $letra = substr($code, $i, 1);

		if($letra eq "\""){
			$strOpen = $strOpen == 0 ? 1 : 0;
		}


		if(ehDelimitador($letra) && $strOpen == 0){
			push @palavras, $token if length $token > 0;
			push @palavras, $letra if ($letra ne " " && $letra ne "\n" && $letra ne "\t");
			$token = "";
		}
		else{
			$token = $token . $letra;
		}
	}
	return @palavras;
}


sub testaInteger{
	my $token = $_[0];
	
	if($token =~ m/^[A-Za-z0-9]*\d+[A-Za-z0-9]*$/){

		my %t = (
				"VALOR" => $token,
				"TIPO" => "INTEGER",
			);
		my $tokenRef = \%t;
		push @tokens, $tokenRef;
	}
	else{
		return 0;
	}
}

sub testaString{
	my $token = $_[0];
	
	if($token =~ m/^".*$/){

		my %t = (
				"VALOR" => $token,
				"TIPO" => "STRING",
			);
		my $tokenRef = \%t;
		push @tokens, $tokenRef;
	}
	else{
		return 0;
	}
}

sub testaType{
	my $token = $_[0];
	
	if($token =~ m/^[A-Z].*$/){

		my %t = (
				"VALOR" => $token,
				"TIPO" => "TYPE ID",
			);
		my $tokenRef = \%t;
		push @tokens, $tokenRef;
	}
	else{
		return 0;
	}
}


sub testaObject{
	my $token = $_[0];
	
	if($token =~ m/^[a-z].*$/ && !ehKeyword $token){

		my %t = (
				"VALOR" => $token,
				"TIPO" => "OBJECT ID",
			);
		my $tokenRef = \%t;
		push @tokens, $tokenRef;
	}
	else{
		return 0;
	}
}





sub testaNotacao{
	my $token = $_[0];
	
	if(ehDelimitador $token){

		my %t = (
				"VALOR" => $token,
				"TIPO" => "SPECIAL NOTATION",
			);
		my $tokenRef = \%t;
		push @tokens, $tokenRef;
	}
	else{
		return 0;
	}
}


sub testaKeyword{
	my $token = $_[0];
	
	if(ehKeyword $token){

		my %t = (
				"VALOR" => $token,
				"TIPO" => "KEYWORD",
			);
		my $tokenRef = \%t;
		push @tokens, $tokenRef;
	}
	else{
		return 0;
	}
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
		testaInteger $palavras[$k];
		testaNotacao $palavras[$k];
		testaKeyword $palavras[$k];
		testaString $palavras[$k];
		testaType $palavras[$k];
		testaObject $palavras[$k];
	}
	return @tokens;
}




return 1;