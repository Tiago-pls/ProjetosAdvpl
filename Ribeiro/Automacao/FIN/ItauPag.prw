#include "rwmake.ch" 
/*
__________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Função    ¦ AGCTA    ¦ Autor ¦ Lucilene Mendes            ¦ Data ¦ 03/07/17 ¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Descrição ¦ Retorna a agencia e conta do favorecido.  Posição 024-043       ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦ Uso      ¦ Sispag Itaú.  Segmento A                                        ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function AGCTA() 

If SUBSTR(SA2->A2_BANCO,1,3)  $ '341/409'  //Itaú ou Unibanco

	_cAGENC  := '0'+StrZero(Val(Substr(SA2->A2_AGENCIA,1,4)),4)
	If AT("-",SA2->A2_NUMCON) > 0
		_cCONTA  := " "+StrZero(Val(Substring(SA2->A2_NUMCON,1,AT("-",SA2->A2_NUMCON)-1)),12)+" "
		_cDIGIT  := Substring(SA2->A2_NUMCON,AT("-",SA2->A2_NUMCON)+1,1)	
	Else
		_cCONTA  := " "+StrZero(Val(Substring(SA2->A2_NUMCON,1,Len(Alltrim(SA2->A2_NUMCON))-1)),12)+" "
		_cDIGIT  := Right(Alltrim(SA2->A2_NUMCON),1)
	Endif

Elseif SUBSTR(SA2->A2_BANCO,1,3)  $ '399'  // HSBC
	_cAGENC  := '0'+StrZero(Val(Substr(SA2->A2_AGENCIA,1,4)),4)
	If AT("-",SA2->A2_NUMCON) > 0
		_cCONTA  := " "+StrZero(Val(Substring(SA2->A2_NUMCON,1,AT("-",SA2->A2_NUMCON)-1)),12)
		_cDIGIT := Substring(SA2->A2_NUMCON,AT("-",SA2->A2_NUMCON)+1,2)
	Else
		_cCONTA  := " "+StrZero(Val(Substring(SA2->A2_NUMCON,1,Len(Alltrim(SA2->A2_NUMCON))-1)),12)
		_cDIGIT := Right(Alltrim(SA2->A2_NUMCON),2)
	Endif


Else
	_cAGENC  := "0"+StrZero(Val(Substr(SA2->A2_AGENCIA,1,4)),4) 
	If AT("-",SA2->A2_NUMCON) > 0
   		_cCONTA  := " "+StrZero(Val(Substring(SA2->A2_NUMCON,1,AT("-",SA2->A2_NUMCON)-1)),12)+" "
   		_cDIGIT  := Substring(SA2->A2_NUMCON,AT("-",SA2->A2_NUMCON)+1,1)
	Else
		_cCONTA  := " "+StrZero(Val(Substring(SA2->A2_NUMCON,1,Len(Alltrim(SA2->A2_NUMCON))-1)),12)+" "
		_cDIGIT  := Right(Alltrim(SA2->A2_NUMCON),1)
	Endif	
	
Endif
//03837 0000010830069
_Retorno := _cAGENC + _cCONTA + _cDIGIT

Return(_Retorno)

/*
__________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Função    ¦ BCOFAV   ¦ Autor ¦ Lucilene Mendes            ¦ Data ¦ 03/07/17 ¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Descrição ¦ Retorna o banco do favorecido.  Posição 018-020                 ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦ Uso      ¦ Sispag Itaú.  Segmento J                                        ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function BCOFAV() 


If !EMPTY(SE2->E2_LINDIG)
	_Retorno := SubStr(SE2->E2_LINDIG,1,3)

Else
	_Retorno := SubStr(SE2->E2_CODBAR,1,3)

Endif

Return(_Retorno) 

/*
__________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Função    ¦ MOEFAV   ¦ Autor ¦ Lucilene Mendes            ¦ Data ¦ 04/07/17 ¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Descrição ¦ Retorna a moeda do favorecido.  Posição 021-021                 ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦ Uso      ¦ Sispag Itaú.  Segmento J                                        ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function MOEFAV() 


If !EMPTY(SE2->E2_LINDIG)
	_Retorno := SubStr(SE2->E2_LINDIG,4,1)

Else
	_Retorno := SubStr(SE2->E2_CODBAR,4,1)

Endif

Return(_Retorno)    

/*
__________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Função    ¦ DigVrf   ¦ Autor ¦ Lucilene Mendes            ¦ Data ¦ 04/07/17 ¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Descrição ¦ Retorna o dígito verificador do cód. de barras.  Posição 022-022¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦ Uso      ¦ Sispag Itaú.  Segmento J                                        ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function DigVrf()        

Local cCampo:= ""

If !Empty(SE2->E2_LINDIG)    
	cCampo := Substr(SE2->E2_LINDIG,33,1)   //linha digitável
Else
	cCampo := Substr(SE2->E2_CODBAR,5,1)//cód. barras
EndIf	

Return(cCampo)  

/*
__________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Função    ¦ FtVcVlr   ¦ Autor ¦ Lucilene Mendes           ¦ Data ¦ 04/07/17 ¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Descrição ¦ Retorna o  fator de vencto e valor do cód. de barra             ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦ Uso      ¦ Sispag Itaú.  Segmento J                                        ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function FtVctVlr()

SetPrvt("CCAMPO,")

If !Empty(SE2->E2_LINDIG)
	cCampo := Substr(SE2->E2_LINDIG,34,14)
Else
	cCampo := Substr(SE2->E2_CODBAR,06,14)
Endif
cCampo := Strzero(Val(cCampo),14) 

Return(cCampo) 

/*
__________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Função    ¦ CampLiv  ¦ Autor ¦ Lucilene Mendes            ¦ Data ¦ 05/07/17 ¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Descrição ¦ Retorna o campo livre do cód. de barras.  Posição 037-061       ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦ Uso      ¦ Sispag Itaú.  Segmento J                                        ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function CampLiv() 

If !Empty(SE2->E2_LINDIG)
	cCampo := 	Substr(SE2->E2_LINDIG,5,5)+Substr(SE2->E2_LINDIG,11,10)+Substr(SE2->E2_LINDIG,22,10)
Else
	cCampo := Substr(SE2->E2_CODBAR,20,25)
EndIf	

Return(cCampo)
                

/*
__________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Função    ¦ ConvLD   ¦ Autor ¦ Lucilene Mendes            ¦ Data ¦ 05/07/17 ¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Descrição ¦ Converte a linha digitável em código de barras                  ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦ Uso      ¦ Sispag Itaú.  Segmento J                                        ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function ConvLD()

SETPRVT("cStr")

If !Empty(SE2->E2_LINDIG)
	cStr := AllTRIM(SE2->E2_LINDIG)
Elseif !Empty(SE2->E2_CODBAR)
	cStr := ALLTRIM(SE2->E2_CODBAR)
Else	
     // Se o Campo está em Branco não Converte nada.
     cStr := ""
Endif   

// Se o Tamanho do String for menor que 44, completa com zeros até 47 dígitos. Isso é
// necessário para Bloquetos que NÂO têm o vencimento e/ou o valor informados na LD.
cStr := IF(LEN(cStr)<44,cStr+REPL("0",47-LEN(cStr)),cStr)


DO CASE
	CASE LEN(cStr) == 47
	    cStr := SUBSTR(cStr,1,4)+SUBSTR(cStr,33,15)+SUBSTR(cStr,5,5)+SUBSTR(cStr,11,10)+SUBSTR(cStr,22,10)
	CASE LEN(cStr) == 48
	   	cStr := SUBSTR(cStr,1,11)+SUBSTR(cStr,13,11)+SUBSTR(cStr,25,11)+SUBSTR(cStr,37,11)
	OTHERWISE
     	cStr := cStr+SPACE(48-LEN(cStr))
ENDCASE

RETURN(cStr)


// Gera a linha com as instruções de pagamento para GPS ou DARF
User Function Fin011TR()

	Local cRet:= ""

	If SEA->EA_MODELO=="17"
		
		cRet+= "01" 															//TRIBUTO
		cRet+= Substr(SE2->E2_IDDARF,1,4)										//CÓDIGO PAGAMENTO
		cRet+= Substr(SE2->E2_IDDARF,5,6)										//COMPETÊNCIA
		cRet+= Substr(SE2->E2_IDDARF,11,14)										//IDENTIFICADOR
		cRet+= STRZERO(SE2->E2_VALOR *100,14)									//VALOR DO TRIBUTO
		cRet+= STRZERO(SE2->E2_VALJUR*100,14)									//VALOR OUTR
		cRet+= STRZERO(SE2->E2_ACRESC*100,14)									//ATUALIZ. MONETÁRIA
		cRet+= STRZERO((SE2->E2_VALOR+SE2->E2_VALJUR+SE2->E2_ACRESC)*100,14)	//VALOR ARRECADADO
		cRet+= GRAVADATA(SE2->E2_VENCREA,.F.,5)									//DATA ARRECADAÇÃO
		cRet+= Space(8)															//BRANCOS
		cRet+= Space(50)														//USO EMPRESA				
		cRet+= PadL(SUBSTR(SM0->M0_NOMECOM,1,30),30)							//CONTRIBUINTE
	
	Elseif SEA->EA_MODELO=="16"
		
		cRet+= "02"								                    //NDARF/GPS        0180190
		cRet+= SE2->E2_CODRET                                        //NRECEITA (DARF) 0200230
		cRet+= "2"                                                   //NEMPRESA-INSCR. 0240240
		cRet+= SUBSTR(SM0->M0_CGC,1,14)                              //NCNPJ           0250380
		cRet+= GRAVADATA(SE2->E2_EMISSAO,.F.,5)                      //NPERIODO        0390460
		cRet+= STRZERO(SE2->E2_NUMREF,17)                            //NREFERENCIA     0470630
		cRet+= STRZERO(SE2->E2_VALOR*100,14)                         //NPRINCIPAL      0640772
		cRet+= STRZERO(SE2->E2_VALJUR*100,14)                        //NMULTA          0780912
		cRet+= STRZERO(SE2->E2_ACRESC*100,14)                        //NJUROS          0921052
		cRet+= STRZERO(SE2->(E2_VALOR+E2_ACRESC+E2_VALJUR)*100,14)   //NVALOR TOTAL    1061192
		cRet+= GRAVADATA(SE2->E2_VENCREA,.F.,5)                      //NVENCIMENTO     1201270
		cRet+= GRAVADATA(SE2->E2_VENCREA,.F.,5)                      //NPAGAMENTO      1281350
		cRet+= SPACE(30)                                             //NBRANCOS        1361650
		cRet+= SUBSTR(SM0->M0_NOMECOM,1,30)                          //NCONTRIBUINTE   1661950 
		
	Elseif SEA->EA_MODELO=="35"	 //FGTS - GFIP
	
		cRet+= "11"													//TRIBUTO  	018 019 
		cRet+= SE2->E2_CODRET										//RECEITA 	020 023 
		cRet+= "1"													//TIPO IDENT.	024  
		cRet+= SUBSTR(SM0->M0_CGC,1,14)								//INSCRIÇÃO	025 038 
		cRet+= SE2->E2_LINDIG										//COD.BARRAS	039 
		cRet+= SE2->E2_IDDARF										//IDENTIF 	087 102 9(16)
		cRet+= space(9)												//LACRE		103 111 9(09)
		cRet+= space(2)												//DIGITO LACRE112 113 9(02)
		cRet+= SUBSTR(SM0->M0_NOMECOM,1,30)							//NOME CONTR	114 143 X(30)
		cRet+= GRAVADATA(SE2->E2_VENCTO,.F.,5) 						//DATA PGTO 	144 151 9(08) DDMMAAAA
		cRet+= STRZERO(SE2->(E2_SALDO+E2_ACRESC+E2_VALJUR)*100,14)	//VALOR 		152 165 9(12)V9(02)
		cRet+= SPACE(30)											//BRANCOS 	166 195 X(30)
	Endif
Return cRet


User Function IBFIN011()
	Local cQuery 	:= ''
	Local _cAlias	:= ''
	Local nValcamp  := 0
	Local cRet  := ""

	_cAlias	:= GetNextAlias()
	BEGINSQL Alias _cAlias
	SELECT
	SUM(E2_VALJUR) E2_VALJUR,SUM(E2_ACRESC) E2_ACRESC,SUM(E2_VALOR) E2_VALOR
	FROM %Table:SE2%
	WHERE
	E2_NUMBOR = %exp:SE2->E2_NUMBOR% AND D_E_L_E_T_ = ' '
	ENDSQL
	
	IF (_cAlias)->(!EOF())
		nValcamp :=	((_cAlias)->E2_VALJUR + (_cAlias)->E2_ACRESC)//Soma valor do juros mais multa
	EndIf
	dbSelectArea(_cAlias)
	cRet += STRZERO(nValCamp*100,14)
Return(cRet)                                         


User Function IBFIN012(cSeg)
	Local cQuery 	:= ''
	Local _cAlias	:= ''
	Local nValsAcr  := 0
	Local cRet		:= ""
	Local nTotal	:= SOMAVALOR()
	_cAlias	:= GetNextAlias()

	BEGINSQL Alias _cAlias
	SELECT
	SUM(E2_VALJUR) E2_VALJUR,SUM(E2_ACRESC) E2_ACRESC,SUM(E2_VALOR) E2_VALOR
	FROM %Table:SE2%
	WHERE
	E2_NUMBOR = %exp:SE2->E2_NUMBOR% AND D_E_L_E_T_ = ' '
	ENDSQL

	//Trouxe registro?
	IF (_cAlias)->(!EOF())
		nValsAcr :=	((_cAlias)->E2_VALJUR + (_cAlias)->E2_ACRESC)
		If cSeg == 'N'
			nTotal := (_cAlias)->E2_VALOR * 100
		ElseIF cSeg == 'T'
			nTotal := (_cAlias)->E2_VALOR * 100
			//Retorna valor total sem juros
			Return (nTotal)
		EndIF
	EndIf

	dbSelectArea(_cAlias)

	nTotal := (nTotal/100)+nValsAcr

	cRet += STRZERO(nTotal*100,14)
Return(cRet)
