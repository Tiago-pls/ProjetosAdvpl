#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"

/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Miscelânea                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! FIS - FISCAL                                            !
+------------------+---------------------------------------------------------+
!Nome              ! MFIS001.PRW                                             !
+------------------+---------------------------------------------------------+
!Descricao         ! Geração de arquivo para ISS.                            !
+------------------+---------------------------------------------------------+
!Autor             ! Marcio Akira Sugahara                                   !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 16/03/2015                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

User Function MFIS001()

Local oDlg

Local _nTamEmp := Len(cEmpAnt)  //tamanho do campo empresa
Local _nTamFil := Len(cFilAnt)  //tamanho do campo filial

Private _cPerg := "MFIS001"

//cria perguntas (Sx1)
AjustaSX1(_cPerg)
Pergunte(_cPerg,.F.)

DEFINE FONT oFont2 NAME "Arial" SIZE 000,-012

DEFINE MSDIALOG oDlg1 FROM 0,0 TO 270,505 TITLE "Geracao de arquivo do ISS" PIXEL
@ 0.5, 0.7 TO 7.8, 31

@  23,14 SAY oSay prompt "Este programa gera arquivo texto para ISS de PINHAIS de acordo com os parâmetros" SIZE 275, 007 OF oDlg1 PIXEL FONT oFont2
@  33,14 SAY oSay prompt "informados." SIZE 275, 007 OF oDlg1 PIXEL FONT oFont2
@  43,14 SAY oSay prompt "Será gerado um arquivo com a seguinte estrutura:" SIZE 275, 007 OF oDlg1 PIXEL FONT oFont2
@  53,14 SAY oSay prompt "ISS_PINHAIS_ + [COD.EMPRESA] + [COD.FILIAL] + [MMAAAA].TXT" SIZE 275, 007 OF oDlg1 PIXEL FONT oFont2
@  63,14 SAY oSay prompt "Por exemplo: " SIZE 275, 007 OF oDlg1 PIXEL FONT oFont2
@  73,14 SAY oSay prompt "         ISS_PINHAIS_0101_20150316.TXT" SIZE 275, 007 OF oDlg1 PIXEL FONT oFont2

@ 115,130 BMPBUTTON TYPE 5 ACTION Pergunte(_cPerg)
@ 115,160 BMPBUTTON TYPE 1 ACTION Processa( {|| M001Proc(), Close(oDlg1) } )
@ 115,190 BMPBUTTON TYPE 2 ACTION Close(oDlg1)

ACTIVATE DIALOG oDlg1 centered


Return()

Static Function M001Proc()

Local aAlias10 := {}

Private cCNPJ := ALLTRIM(SM0->M0_CGC)

If cCNPJ == "81742223000126"
	MSAguarde( {|| GetQuery(1, @aAlias10)}, 'Aguarde' ,'Buscando dados para a geração!',.F. )
	
	If aAlias10[1]
		MSAguarde( {|| GeraIss(aAlias10)}, 'Gerando arquivo do ISS! Aguarde...' ,'',.F. )
	Else
		Alert('Nenhum título ou nota encontrada para processamento.')
	Endif
Endif

Return

//------------------------------
/*/{Protheus.doc} GeraIss
Rotina para geração do arquivo do ISS

@author Lucas
@since 18/11/2014
@version 1.0

@param aAlias, array, Array com a definição do alias para a linha 10 do registro

@protected
/*/
//------------------------------
Static Function GeraIss( aAlias )

Local aLinha    := {}
Local aEndNum   := {}
Local cEnd      := ''
Local cNum      := ''
Local cTel      := ''
Local cFax      := ''
Local cArq      := ''
Local cLinha    := ''
Local cPessoa   := ''
Local cCompet   := ''
Local cObs      := ''
Local cTipoDoc  := ''
Local cMensagem := ''
Local cMesAno   := ''
local cXPDISS   := GetMv("MV_XPDISS")
Local cAliqISS  := ''
Local cIss      := ''
Local cDedIss   := ''
Local cBaseIss  := ''
Local nBaseIss  := 0
Local nArquivo  := 0
Local nI        := 1
Local nX		:= 0
conout('//---------------------------------')
conout('Iniciando geraçao de arquivo de ISS')

cMesAno := substr(DTOC(mv_par01), 4, 2)+substr(DTOC(mv_par01), 7, 4)
cArq := ALLTRIM(mv_par03)+"\ISS_PINHAIS_"+ALLTRIM(cMesAno)+"_"+SUBSTR(TIME(), 7,2)+".TXT"

nArquivo := fCreate(cArq,0)
if ferror() # 0
	msgalert ("ERRO AO CRIAR O ARQUIVO, ERRO: " + str(ferror()))
else
	while !(aAlias[2])->(EOF())
		
		cMensagem := 'Documento: ' + allTrim((aAlias[2])->DOC) + ' - ' + cValTochar(nI) + ' de ' + cValTochar(aAlias[3])
		conout(cMensagem)
		MSPROCTXT(cMensagem)
		processMessage()
		
		IF '000003352' == allTrim((aAlias[2])->DOC)
			PROCESSMESSAGE()
		ENDIF
		
		// calcula o valor do ISS
		do case
			case (alltrim((aAlias[2])->FORN) == '000183' .and. alltrim((aAlias[2])->LOJA) == '20')
				nBaseIss := Round(iif((aAlias[2])->XVRBUT > 0, (aAlias[2])->XVRBUT - (aAlias[2])->INSS, (aAlias[2])->VLCRUZ + (aAlias[2])->IRRF),2)
				
			case (alltrim((aAlias[2])->FORN) == '000180' .and. alltrim((aAlias[2])->LOJA) == '51')
				nBaseIss := Round(iif((aAlias[2])->XVRBUT > 0, (aAlias[2])->XVRBUT - (aAlias[2])->INSS, (aAlias[2])->VLCRUZ + (aAlias[2])->IRRF),2)
				
			otherwise
				nBaseIss := Round((aAlias[2])->XVRBUT,2)
				//nBaseIss := Round(iif((aAlias[2])->XVRBUT > 0, (aAlias[2])->XVRBUT, (aAlias[2])->VLCRUZ + (aAlias[2])->ISS),2)
		endcase
		
		if nBaseIss > 0
			do case
				/*Tipo do Documento (
				01 – Nota Fiscal de Serviços (Bloco);
				02 – Cupom Fiscal;
				03 – Contrato;
				04 – Recibo;
				05 – Nota Fiscal Conjugada;
				07 – Nota Fiscal Eletrônic@;
				08 – 6  2  7  I  Cupom Fiscal Conjugado;
				10 – Nota Fiscal de Serviços (Formulário);
				11 – Documento Fiscal Estrangeiro;
				12 – Nota Fiscal Conjugada (Formulário) )*/
				
				case ALLtRIM((aAlias[2])->TIPO2) == 'NF' .AND. allTrim((aAlias[2])->ESPECIE) == 'NF' // NOTA FISCAL DE SERVIÇOS (BLOCO)
					cTipDoc := '01'
					
				case ALLtRIM((aAlias[2])->TIPO2) == 'NF' .AND. allTrim((aAlias[2])->ESPECIE) == 'NFS' // Nota Fiscal Eletrônic@
					cTipDoc := '07'
					
				case SUBSTRING((aAlias[2])->PREFIXO, 1, 2) == 'CF' // Recibo
					cTipDoc := '04'
					
				otherwise
					cTipDoc := '01'
			endcase
			
			// calculando a base do iss
			cBaseIss := StrTran(transform(nBaseIss,"@E 999999999.99"),",",".")
			cBaseIss := StrZero(0, 18-len(ALLTRIM(cBaseIss)))+ ALLTRIM(cBaseIss)
			
			cObs := allTrim((aAlias[2])->OBS)
			IF SUBSTRING((aAlias[2])->PREFIXO, 1, 2) == "CF" .OR. SUBSTRING((aAlias[2])->PREFIXO, 1, 2) == "CJ"
				cOBS := "COMISSAO SOBRE VENDA DE COTAS DE CONSORCIO"
			ENDIF
			
			cCompet := SUBSTRING((aAlias[2])->EMISSAO, 5, 2)+'/'+SUBSTRING((aAlias[2])->EMISSAO, 1, 4)
			
			//ALTERADO EM 18/12/14
			//cPessoa := iif(len((aAlias[2])->CGC) < 14, 'F', 'J')
			cPessoa := (aAlias[2])->A2_TIPO
			
			IF (aAlias[2])->ISS > 0
				cAliqISS := StrTran(transform(ROUND(((aAlias[2])->ISS/nBaseISS)*100,0),"@E 999.99"),",",".")
			ELSE
				cAliqISS := StrTran(transform(0,"@E 999.99"),",",".")
			ENDIF
			cAliqISS := StrZero(0, 6-len(ALLTRIM(cAliqISS)))+ ALLTRIM(cAliqISS)
			
			cDedIss := StrTran(transform(0,"@E 999.99"),",",".")
			cDedIss := StrZero(0, 18-len(ALLTRIM(cDedIss)))+ ALLTRIM(cDedIss)
			
			cISS := StrTran(transform((aAlias[2])->ISS,"@E 999999999.99"),",",".")
			cISS := StrZero(0, 18-len(ALLTRIM(cISS)))+ ALLTRIM(cISS)
			
			cEnd := ''
			cNum := '0'
			aEndNum := StrToKarr( ALLTRIM((aAlias[2])->A2_END) , ",")
			For nX := 1 To Len( aEndNum )
				IF nX == 1
					cEnd := ALLtRIM(aEndNum[nX])
				Else
					cNum := ALLtRIM(aEndNum[nX])
				endif
			Next nX
			cNum := strzero( val(cNum), 6 )
			
			if EMPTY((aAlias[2])->A2_TEL)
				cTel := "00 0000-0000"
			else
				cTel := (aAlias[2])->A2_TEL
			endif
			
			if EMPTY((aAlias[2])->A2_FAX)
				cFax := "00 0000-0000"
			else
				cFax := (aAlias[2])->A2_FAX
			endif
			
			// gerou a linha 10 do registro.
			clinha := (aAlias[2])->REG + ';'
			cLinha += (aAlias[2])->TIPO + ';'
			cLinha += cTipDoc + ';'
			cLinha += PADL((aAlias[2])->DOC,15) + ';'
			cLinha += cCompet + ';'
			cLinha += cPessoa + ';'
			cLinha += PADL(STRZERO(VAL((aAlias[2])->CGC), 14), 14) + ';'
			cLinha += 'J;'
			cLinha += PADL(cCNPJ, 14) + ';'
			cLinha += DTOC(STOD((aAlias[2])->EMISSAO)) + ';'
			cLinha += PADL(cBaseIss,18) + ';'
			cLinha += 'E;'
			cLinha += PADR(ALLTRIM(cOBS), 100) + ';'
			cLinha += iif((aAlias[2])->SIMPLES == '1', 'S', 'N')+ ';'
			
			fwrite(nArquivo, cLinha + chr(13) + chr(10))
			if ferror() # 0
				msgalert ("ERRO GRAVANDO ARQUIVO, ERRO: " + str(ferror()))
			endif
			
			// gerou a linha 20 do registro.
			clinha := '20' + ';'
			cLinha += (aAlias[2])->TIPO + ';'
			cLinha += cTipDoc + ';'
			cLinha += PADL((aAlias[2])->DOC,15) + ';'
			cLinha += cCompet + ';'
			cLinha += cPessoa + ';'
			cLinha += PADL(STRZERO(VAL((aAlias[2])->CGC), 14), 14) + ';'
			cLinha += 'J;'
			cLinha += PADL(cCNPJ, 14) + ';'
			cLinha += PADL(cXPDISS, 7) + ';'
			cLinha += PADL(cAliqISS, 6) + ';'
			cLinha += PADL(cBaseIss,18) + ';'
			cLinha += PADL(cDedIss,18) + ';'
			cLinha += PADL(cISS,18) + ';'
			cLinha += PADL(STRZERO(VAL("5453"),7), 7) + ';'
			
			//ALTERADO EM 16/12/14
			//cLinha += iif(LEN((aAlias[2])->CGC) < 14, '01', '14') + ';'
			//cLinha += iif(LEN((aAlias[2])->CGC) < 14, 'S', 'N') + ';'
			
			//ALTERADO EM 18/12/14
			//alterado para considerar o campo A2_TIPO (ao inves de usar o tamanho do campo CGC)
			
			//codigo do municipio  "19152" -->  PINHAIS
			cCSTISS := ""
			//SE PJ,	FORA DE PINHAIS e A2_RECISS= S -->	13
			If (aAlias[2])->A2_TIPO = "J" .and. (aAlias[2])->A2_COD_MUN <> "19152" .and. (aAlias[2])->RECISS = "S"
				cCSTISS := "13"
				
				//Se PJ, FORA DE PINHAIS e A2_RECISS= N --> 01
			ElseIf(aAlias[2])->A2_TIPO = "J" .and. (aAlias[2])->A2_COD_MUN <> "19152" .and. (aAlias[2])->RECISS = "N"
				cCSTISS := "01"
				
				//SE PJ, DENTRO DE PINHAIS e A2_RECISS = S  --> 12
			ElseIf (aAlias[2])->A2_TIPO = "J" .and. (aAlias[2])->A2_COD_MUN = "19152" .and. (aAlias[2])->RECISS = "S"
				cCSTISS := "12"
				
				//Se PJ, DENTRO DE PINHAIS e A2_RECISS =  N ---> 01
			ElseIf (aAlias[2])->A2_TIPO = "J" .and. (aAlias[2])->A2_COD_MUN = "19152" .and. (aAlias[2])->RECISS = "N"
				cCSTISS := "01"
				
				//SE PF e A2_RECISS = S  --> 08
			ElseIf (aAlias[2])->A2_TIPO = "F" .and. (aAlias[2])->RECISS = "S"
				cCSTISS := "08"
				
				//SE PF e A2_RECISS = N  --> 01
			ElseIf (aAlias[2])->A2_TIPO = "F" .and. (aAlias[2])->RECISS = "N"
				cCSTISS := "01"
			EndIf
			
			cLinha += cCSTISS + ';'
			cLinha +=  (aAlias[2])->RECISS+ ';'
			//Ate aqui 16/12/14
			
			fwrite(nArquivo, cLinha + chr(13) + chr(10))
			if ferror() # 0
				msgalert ("ERRO GRAVANDO ARQUIVO, ERRO: " + str(ferror()))
			endif
			
			// gerou a linha 30 do registro.
			clinha := '30' + ';'
			cLinha += cPessoa + ';'
			cLinha += PADL(STRZERO(VAL((aAlias[2])->CGC), 14), 14) + ';'
			cLinha += PADR(ALLTRIM((aAlias[2])->A2_NOME),40) + ';'
			cLinha += PADR(ALLTRIM(cEnd), 40) + ';'
			cLinha += PADR(ALLTRIM(cNum), 6) + ';'
			cLinha += PADR((aAlias[2])->A2_COMPLEM,20) + ';'
			cLinha += PADR((aAlias[2])->A2_BAIRRO,20) + ';'
			cLinha += PADR((aAlias[2])->A2_MUN,30) + ';'
			cLinha += PADR((aAlias[2])->A2_EST,2) + ';'
			cLinha += PADR((aAlias[2])->A2_CEP,8) + ';'
			cLinha += PADR(cTel,12) + ';'
			cLinha += PADR(cFax,12) + ';'
			
			fwrite(nArquivo, cLinha + chr(13) + chr(10))
			if ferror() # 0
				msgalert ("ERRO GRAVANDO ARQUIVO, ERRO: " + str(ferror()))
			endif
		endif
		
		(aAlias[2])->(dbSkip())
		nI++
	enddo
	(aAlias[2])->(dbCloseArea())
endif
fclose(nArquivo)
conout('//---------------------------------')

If MsgYesNo("Arquivo gerado no diretorio: " + alltrim(cArq) + "." + (chr(13) + chr(10)) + (chr(13) + chr(10)) + "Deseja imprimir o Relatório para conferência?")
	RELISS( cArq )
endif

Return

//------------------------------
/*/{Protheus.doc} RELISS
Gera relatório do ISS

@version 1.0

@param cDiretorio, character, Arquivo a ser utilizado na geração
/*/
//------------------------------
Static Function RELISS(cDiretorio)

Local cArq    := cDiretorio
Local cLinha  := ""
//Local lPrim   := .T.
Local aCampos := {}
Local aDados := {}
Local aArea := GetArea()
Loca nX		:= 0
Private	oFonte08  := TFont():New('Arial',08,08,,.F.,,,,.T.,.F.,.F.)
Private	oFonte08N := TFont():New('Arial',08,08,,.T.,,,,.T.,.F.,.F.)
Private	oFonte09  := TFont():New('Arial',08,08,,.F.,,,,.T.,.F.,.F.)
Private	oFonte09N := TFont():New('Arial',08,08,,.T.,,,,.T.,.F.,.F.)
Private	oFonte10  := TFont():New('Arial',10,10,,.F.,,,,.T.,.F.,.F.)
Private	oFonte10N := TFont():New('Arial',10,10,,.T.,,,,.T.,.F.,.F.)
Private	oFonte11N := TFont():New('Arial',11,11,,.T.,,,,.T.,.F.,.F.)
Private	oFonte12N := TFont():New('Arial',12,12,,.T.,,,,.T.,.F.,.F.)
Private	oFonte14N := TFont():New('Arial',14,14,,.T.,,,,.T.,.F.,.F.)
Private	oFonte16N := TFont():New('Arial',16,16,,.T.,,,,.T.,.F.,.F.)
Private	oFonte20N := TFont():New('Arial',20,20,,.T.,,,,.T.,.F.,.F.)
Private	oFonte28  := TFont():New('Arial',28,28,,.F.,,,,.T.,.F.,.F.)

Private	oBrWhite  := TBrush():New2( , fRGB(255,255,255) )
Private	oBrGray   := TBrush():New2( , fRGB(240,240,240) )
Private	oBrBlack  := TBrush():New2( , fRGB(0,0,0) )
Private lPrim     := .T.
Private nLin      := 5000
Private nLinAux   := 0
Private nPag      := 0
Private cObs2     := ""
Private cObs3     := ""
Private cObs4     := ""
Private aErro     := {}

If !File(cArq)
	MsgStop("O arquivo " +cDir+cArq + " não foi encontrado. A importação será abortada!","[RELISS] - ATENCAO")
	Return
EndIf

FT_FUSE(cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()
While !FT_FEOF()
	IncProc("Lendo arquivo texto...")
	
	cLinha := FT_FREADLN()
	lPrim := .F.
	If lPrim
		aCampos := Separa(cLinha,";",.T.)
		lPrim := .F.
	Else
		AADD(aDados,Separa(cLinha,";",.T.))
	EndIf
	
	FT_FSKIP()
Enddo

_cArqDBF  := CriaTrab(NIL,.f.)
_aFields := {}
AADD(_aFields,{"TR_COMPET"  ,"C",07,00,"@!"                }) // Numero do Pedido
AADD(_aFields,{"TR_CNPJ"    ,"C",14,00,"@!"                }) //
AADD(_aFields,{"TR_NOME"    ,"C",40,00,"@!"                }) //
AADD(_aFields,{"TR_DOC"     ,"C",15,00,"@!"                }) //
AADD(_aFields,{"TR_EMISSAO" ,"D",08,00,"@!"                }) //
AADD(_aFields,{"TR_VALOR"   ,"N",14,02,"@E999,999,999.99" }) //
AADD(_aFields,{"TR_ISS"     ,"N",14,02,"@E999,999,999.99" }) //

DbCreate(_cArqDbf,_aFields)
DbUseArea(.T.,,_cArqDbf,"TRC")
_cIndex := Criatrab(Nil,.F.)
_cChave := "TR_CNPJ+TR_DOC"
Indregua("TRC",_cIndex,_cChave,,,"Selecionando Registros...")

If Len( aDados ) > 0
	dbGoTop()
	// Gravar a chave nos registros em branco
	For nX := 1 To Len( aDados )
		if aDados[nX,1] == "10"
			RecLock("TRC",.T.)
			TRC->TR_COMPET := aDados[nX,5]
			TRC->TR_DOC  := aDados[nX,4]
			TRC->TR_EMISSAO := CTOD(aDados[nX,10])
			TRC->TR_VALOR :=  VAL(aDados[nX,11])
		end
		if aDados[nX,1] == "20"
			TRC->TR_ISS :=  VAL(aDados[nX,14])
		endif
		if aDados[nX,1] == "30"
			TRC->TR_CNPJ := aDados[nX,3]
			TRC->TR_NOME := aDados[nX,4]
			MsUnLock("TRC")
		endif
	next
endif

oPrint := ReportDef()
oPrint:PrintDialog()

RestArea(aArea)

Return

//------------------------------
/*/{Protheus.doc} ReportDef
Define estrutura do relatório

@version 1.0
@return oPrint Objeto TReport

@protected
/*/
//------------------------------
Static Function ReportDef()

oPrint := TReport():New("RELISS","ISS TOMADOS",,{|oPrint| PrintReport()},"Impress? do tomados")
oPrint:HideHeader()
oPrint:HideFooter()
oPrint:SetPortrait()

Return oPrint

//------------------------------
/*/{Protheus.doc} PrintReport
Rotina para impressão do relatório

@version 1.0

@protected
/*/
//------------------------------
Static Function PrintReport()

Local cValorTotal := 0
Local cValorISS   := 0
Local cQtd   := 0
Private lPrim     := .T.

If nLin >= 2500
	fQuebra()
EndIf

TRC->(dbGoTop())
If TRC->(!Eof())
	nLinN := 0100
	DO While TRC->(!Eof())
		oPrint:Say(nLin,0075, TRC->TR_COMPET , ofonte09)
		oPrint:Say(nLin,0455, TRC->TR_CNPJ, ofonte09,,,,1)
		oPrint:Say(nLin,0485, TRC->TR_NOME, ofonte09)
		oPrint:Say(nLin,1130, TRC->TR_DOC, ofonte09)
		oPrint:Say(nLin,1325, DTOC(TRC->TR_EMISSAO), ofonte09)
		oPrint:Say(nLin,1690, TRANSFORM(TRC->TR_VALOR,"@E 999,999,999.99"), ofonte09,,,,1)
		oPrint:Say(nLin,2000, TRANSFORM(TRC->TR_ISS,"@E 999,999.99"), ofonte09,,,,1)
		cValorTotal += TRC->TR_VALOR
		cValorISS	+= TRC->TR_ISS
		cQtd++
		nLin+=50
		TRC->(DbSkip())
		If nLin >= 2500
			fQuebra()
		endif
	EndDo
	
	nLin += 65
	oPrint:Line(nLin,0050,nLin,2320)
	nLin += 50
	oPrint:Say(nLin,0250, "VALOR TOTAL: "+ TRANSFORM(cValorTotal,"@E 999,999,999.99"), oFonte09)
	oPrint:Say(nLin,0600, "ISS TOTAL: "+ TRANSFORM(cValorISS,"@E 999,999,999.99"), oFonte09)
	oPrint:Say(nLin,1200, "Quantidade: "+ TRANSFORM(cQtd,"@E 999999"), oFonte09)
	oPrint:EndPage(.T.)
	
	TRC->(DbCloseArea())
Endif

Return

//------------------------------
/*/{Protheus.doc} fQuebra
Quebra a linha do relatório

@version 1.0

@protected
/*/
//------------------------------
Static Function fQuebra()

nPag++

If !lPrim
	nLin += 65
	oPrint:Line(nLin,0050,nLin,2320)
	nLin += 100
	oPrint:Say(nLin,0050, "C O N T I N U A >>> P?. "+ALLTRIM(strzero(nPag,2))+" . . .", oFonte12N)
	oPrint:EndPage(.T.)
	lPrim := .F.
	oPrint:StartPage()
	oPrint:SayBitmap(050,050,"CONSEG.BMP",400,130)
	cEmpresa  := Alltrim(Posicione("SM0",1,cEmpAnt+xFilial("SM0"),"M0_NOMECOM"))
	cCnpj     := TRANSFORM(SM0->M0_CGC, "@R 99.999.999/9999-99")
	oPrint:Say(080,1200, cEmpresa , oFonte14N,,,,2)
	oPrint:Say(150,1200, "CNPJ: " + cCnpj , oFonte10N,,,,2)
	
	nLin := 400
	nLinAux := nLin
	nLin += 20
	
	oPrint:Say(nLin,0075, "Competencia"          , ofonte09N)
	oPrint:Say(nLin,0375, "CNPJ/CPF"        , ofonte09N,,,,1)
	oPrint:Say(nLin,0485, "NOME"	, ofonte09N)
	oPrint:Say(nLin,1150, "NUMERO"	, ofonte09N)
	oPrint:Say(nLin,1315, "EMISSAO"   , ofonte09N)
	oPrint:Say(nLin,1600, "VALOR CONTABIL"  , ofonte09N,,,,2)
	oPrint:Say(nLin,2000, "VALOR ISS" , oFonte09N,,,,1)
	nLin += 65
	oPrint:Line(nLin,0050,nLin,2320)
else
	lPrim := .F.
	
	oPrint:StartPage()
	
	oPrint:SayBitmap(050,050,"CONSEG.BMP",400,130)
	
	cEmpresa  := Alltrim(Posicione("SM0",1,cEmpAnt+xFilial("SM0"),"M0_NOMECOM"))
	cCnpj     := TRANSFORM(SM0->M0_CGC, "@R 99.999.999/9999-99")
	
	oPrint:Say(080,1200, cEmpresa , oFonte14N,,,,2)
	oPrint:Say(150,1200, "CNPJ: " + cCnpj , oFonte10N,,,,2)
	nLin := 400
	
	nLinAux := nLin
	nLin += 20
	
	oPrint:Say(nLin,0075, "Competencia"          , ofonte09N)
	oPrint:Say(nLin,0375, "CNPJ/CPF"        , ofonte09N,,,,1)
	oPrint:Say(nLin,0485, "NOME"	, ofonte09N)
	oPrint:Say(nLin,1150, "NUMERO"	, ofonte09N)
	oPrint:Say(nLin,1315, "EMISSAO"   , ofonte09N)
	oPrint:Say(nLin,1600, "VALOR CONTABIL"  , ofonte09N,,,,2)
	oPrint:Say(nLin,2000, "VALOR ISS" , oFonte09N,,,,1)
	nLin += 65
	oPrint:Line(nLin,0050,nLin,2320)
endif

Return

//------------------------------
/*/{Protheus.doc} fRGB
Transforma RGB em Long Decimal

@version 1.0

@param R, numérico, Red
@param G, numérico, Green
@param B, numérico, Blue

@return Numérico Retorna valor convertido em long decimal

@protected
/*/
//------------------------------
Static Function fRGB(R,G,B)

Return B * 65536 + G * 256 + R



Static Function GetQuery( nOpc, aAlias )

local aMatTipo  := StrToKarr( StrTran(GetMv("MV_XTPISS"), "'", '') , '|')
local aMatEspec := StrToKarr( StrTran(GetMv("MV_XESPECI"), "'", '') , '|')
Local cAlias    := getNextAlias()
local cXFilial  := StrTran(GetMv("MV_XFILISS") , "'", '')
local cXPDISS   := StrTran(GetMv("MV_XPDISS") , "'", '')
Local cEspecie  := ''
Local cTipo     := ''
Local nCount    := 0
Local nX        := 0

cTipo := ''
For nX := 1 To Len( aMatTipo )
	IF Empty(cTipo)
		cTipo += "'"+aMatTipo[nX]
	else
		cTipo += "', '"+aMatTipo[nX]
	endif
Next nX
cTipo := "%" + allTrim(cTipo) + "'%"

cEspecie := ''
For nX := 1 To Len( aMatEspec )
	IF Empty(cEspecie)
		cEspecie += "'"+aMatEspec[nX]
	else
		cEspecie += "', '"+aMatEspec[nX]
	endif
Next nX
cEspecie := "%" + allTrim(cEspecie) + "'%"

do case
	case nOpc == 1
		BeginSql Alias cAlias
			SELECT
			'10' AS REG, '2' AS TIPO, SE2.E2_NUM AS DOC, SE2.E2_PREFIXO AS PREFIXO,
			SE2.E2_FORNECE AS FORN, SE2.E2_LOJA AS LOJA, SE2.E2_EMISSAO AS EMISSAO,
			SA2.A2_CGC AS CGC, ISNULL(SE2.E2_XVRBUT, 0.00) AS XVRBUT, SE2.E2_INSS AS INSS,
			SE2.E2_VLCRUZ AS VLCRUZ, SE2.E2_IRRF AS IRRF, 'E' AS SIT, '' AS OBS,
			SA2.A2_SIMPNAC AS SIMPLES, 'TIT' AS TIPO2, '' AS ESPECIE, '' AS CHAVENFE,
			SA2.A2_CODSIAF AS CODSIAF, SE2.E2_ISS AS ISS, SA2.A2_RECISS AS RECISS,
			SA2.A2_END, SA2.A2_TEL, SA2.A2_FAX, SA2.A2_NOME, SA2.A2_COMPLEM,
			SA2.A2_BAIRRO, SA2.A2_MUN, SA2.A2_EST, SA2.A2_CEP, SA2.A2_COD_MUN, A2_TIPO
			FROM
			%TABLE:SE2% SE2
			INNER JOIN %TABLE:SA2% SA2 ON
			SA2.A2_FILIAL = %XFILIAL:SA2%
			AND SA2.A2_COD = SE2.E2_FORNECE
			AND SA2.A2_LOJA = SE2.E2_LOJA
			AND SA2.A2_COD > '000010'
			AND SA2.%NOTDEL%
			WHERE
			SE2.E2_FILIAL = %EXP:cXfilial%
			AND (SE2.E2_EMISSAO BETWEEN %EXP:DTOS(mv_par01)% AND %EXP:DTOS(mv_par02)%)
			AND SE2.E2_TIPO NOT IN (%EXP:cTipo%)
			AND (SE2.E2_PREFIXO LIKE 'CJ%' OR SE2.E2_PREFIXO LIKE 'CF%' OR SE2.E2_PREFIXO = 'RPA')
			AND SE2.%NOTDEL%
			
			UNION ALL
			
			SELECT
			'10' AS REG, '2' AS TIPO, SF1.F1_DOC AS DOC, SF1.F1_PREFIXO AS PREFIXO,
			SF1.F1_FORNECE AS FORN, SF1.F1_LOJA AS LOJA, SF1.F1_EMISSAO AS EMISSAO,
			SA2.A2_CGC AS CGC, ISNULL(SE2.E2_XVRBUT, 0) AS XVRBUT, SE2.E2_INSS AS INSS,
			SE2.E2_VLCRUZ AS VLCRUZ, SE2.E2_IRRF AS IRRF, 'E' AS SIT, '' AS OBS,
			SA2.A2_SIMPNAC AS SIMPLES, 'NF' AS TIPO2, SF1.F1_ESPECIE AS ESPECIE,
			SF1.F1_CHVNFE AS CHAVENFE, SA2.A2_CODSIAF AS CODSIAF, SE2.E2_ISS AS ISS,
			SA2.A2_RECISS AS RECISS, SA2.A2_END, SA2.A2_TEL, SA2.A2_FAX, SA2.A2_NOME,
			SA2.A2_COMPLEM, SA2.A2_BAIRRO, SA2.A2_MUN, SA2.A2_EST, SA2.A2_CEP,SA2.A2_COD_MUN, A2_TIPO
			FROM
			%TABLE:SE2% SE2
			INNER JOIN %TABLE:SA2% SA2 ON
			SA2.A2_FILIAL = %XFILIAL:SA2%
			AND SA2.A2_COD = SE2.E2_FORNECE
			AND SA2.A2_LOJA = SE2.E2_LOJA
			AND SA2.A2_COD > '000010'
			AND SA2.%NOTDEL%
			INNER JOIN %TABLE:SF1% SF1 ON
			SF1.F1_FILIAL = %XFILIAL:SF1%
			AND SF1.F1_DOC = SE2.E2_NUM
			AND SF1.F1_SERIE = SE2.E2_PREFIXO
			AND (SF1.F1_EMISSAO BETWEEN %EXP:DTOS(mv_par01)% AND %EXP:DTOS(mv_par02)%)
			AND SF1.%NOTDEL%
			WHERE
			SE2.E2_FILIAL = %EXP:cXfilial%
			AND (SE2.E2_EMISSAO BETWEEN %EXP:DTOS(mv_par01)% AND %EXP:DTOS(mv_par02)%)
			AND SE2.E2_TIPO NOT IN ( %EXP:cTipo% )
			AND (SE2.E2_PREFIXO LIKE 'CJ%' OR SE2.E2_PREFIXO LIKE 'CF%' OR SE2.E2_PREFIXO = 'RPA' OR SF1.F1_ESPECIE in (%EXP:cEspecie%))
			AND SE2.%NOTDEL%
			AND NOT EXISTS(
			SELECT
			SD1.R_E_C_N_O_
			FROM
			%TABLE:SD1% SD1
			INNER JOIN %TABLE:SF4% SF4 ON
			SF4.F4_FILIAL = %XFILIAL:SF4%
			AND SF4.F4_CODIGO = SD1.D1_TES
			AND SF4.%NOTDEL%
			WHERE
			SD1.D1_FILIAL = %XFILIAL:SF1%
			AND SD1.D1_DOC = SF1.F1_DOC
			AND SD1.D1_SERIE = SF1.F1_SERIE
			AND SD1.D1_FORNECE = SF1.F1_FORNECE
			AND SD1.D1_LOJA = SF1.F1_LOJA
			AND SD1.D1_TES = '002'
			AND SD1.%NOTDEL% )
			ORDER BY
			TIPO2, DOC, FORN, LOJA
		EndSql
		
	     cDebug := GetLastQuery()[2]          //Para debugar a query
		
		(cAlias)->(dbEval({|| nCount++ }))
		(cAlias)->(dbGoTop())
		// fim case
endcase

aAlias := { nCount > 0, cAlias, nCount }

Return





/*
+-------------------------------------------------------------------------+
! Função    ! AjustaSX1 ! Autor ! Marcio A.Sugahara  ! Data !  16/03/2015 !
+-----------+-----------+-------+--------------------+------+-------------+
! Descricao ! Ajusta as perguntas do SX1.                                 !
+-----------+-------------------------------------------------------------+
*/
Static Function AjustaSX1(_nTamEmp,_nTamFil)
PutSx1(_cPerg,"01","Emissao de?"   ,"Emissao de?"   ,"Emissao de?"   ,"mv_ch1","D",08,0,0,"G",""          ,""   ,""   ,"","mv_par01","","","",""                              ,"","","","","","","","","","","","",,,,"")
PutSx1(_cPerg,"02","Emissao ate?"   ,"Emissao ate?"   ,"Emissao ate?"   ,"mv_ch2","D",08,0,0,"G",""          ,""   ,""   ,"","mv_par02","","","",""                              ,"","","","","","","","","","","","",,,,"")
PutSx1(_cPerg,"03","Dir.Destino:","Dir.Destino:","Dir.Destino:","mv_ch3","C",99,0,0,"G","U_MFIS001B()"          ,"","","","mv_par03","","","",""                     ,"","","","","","","","","","","","",,,,"")
Return()

/*
+-------------------------------------------------------------------------+
! Função    ! MFIS001B  ! Autor ! Marcio A.Sugahara  ! Data !  16/03/2015 !
+-----------+-----------+-------+--------------------+------+-------------+
! Descricao ! define pasta de destino do arquivo texto.                   !
+-----------+-------------------------------------------------------------+
*/
User function MFIS001B()
Local carq := cGetFile(" Arquivo texto ( *.TXT ) |*.TXT|  " ,"Escolha diretorio destino.",1,"c:\",.F.,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_OVERWRITEPROMPT)
mvRet      := Alltrim(ReadVar())		// Iguala Nome da Variavel ao Nome variavel de Retorno
&MvRet     := alltrim(cArq)	// Devolve Resultado
Return()