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
# POSICAO DO PARSER
my $parser = -1;

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
	my $charOpen = $_[0];
	my $charClose = $_[1];
	my $master = exists $_[2] ? $_[2] : $code;

	my $open = 0;
	my $str = "";
	my $count = 0;
	for(my $i=0; $i < (length($master)-1); $i++){
		$open = 1 if(substr($master, $i, length($charOpen)) eq $charOpen);
		$open = 0 if(substr($master, $i, length($charClose)) eq $charClose);

		if($open == 1){
			my $aux = substr($master, $i, 1);
			$str = $str . $aux;
		}
		else{
			if(length($str) > 0){
				$str = quotemeta ($str . "*)");
				$master =~ s/$str//g;
				#print $str;
				$str = "";
			}
		}

	}

	return $master;
}


# LE O CODIGO FONTE
sub lerSRC{
	my $fp = abrir $_[0];
	my $comment = 0;
	while (<$fp>){
		if (substr($_, 0, 2) ne "--"){
			$code = $code . $_;
		}
	}

	$code = removeComentario "(*", "*)";
	$code = removeComentario "(*", "*)";
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
			if ( ($letra eq "<" && (substr($code, $i+1, 1) eq "-" || substr($code, $i+1, 1) eq "=")) || ($letra eq ">" && substr($code, $i+1, 1) eq "=") ){
				$letra = $letra . substr($code, $i+1, 1);
				$i++;
			}
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

# TESTA SE UM TONKEN EH UM INTEGER
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

# TESTA SE UM TONKEN EH UMA STRING
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

# TESTA SE UM TONKEN EH UM TYPE ID
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


# TESTA SE UM TONKEN EH UM OBJECT ID
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

# TESTA SE UM TONKEN EH UM SPECIAL NOTATITION
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

# TESTA SE UM TONKEN EH UMA KEYWORD
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