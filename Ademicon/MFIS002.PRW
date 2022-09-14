#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
+------------------+---------------------------------------------------------+
!Nome              ! MFIS002                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Geração de arquivo de ISS - prefeitura de Pinhais.      !
+------------------+---------------------------------------------------------+
!Autor             ! Marcio A.Sugahara                                       !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 22/10/2015                                              !
+------------------+---------------------------------------------------------+
*/

User Function MFIS002()

Local nOpca := 0
Local oDlg
Local aSays	   := { }
Local aButtons := { }
Local oDlg

Private cPict6  := "999.99"
Private cPict18 := "999999999999999.99"
Private _cPerg := 'MFIS002'
Private cVerbaIss:= GetNewPar("AD_VRBISS","'125','221'")
AjustaSX1()
Pergunte(_cPerg,.F.)

DEFINE FONT oFont2 NAME "Arial' SIZE 000,-012

DEFINE MSDIALOG oDlg1 FROM 0,0 TO 270,505 TITLE 'Geracao de arquivo de ISS' PIXEL
@ 0.5, 0.7 TO 7.8, 31

@  23,14 SAY oSay prompt 'Este programa gera arquivo texto de ISS da Prefeitura de Pinhais,' SIZE 275, 007 OF oDlg1 PIXEL FONT oFont2
@  33,14 SAY oSay prompt 'de acordo com os parâmetros informados.' SIZE 275, 007 OF oDlg1 PIXEL FONT oFont2

@ 115,130 BMPBUTTON TYPE 5 ACTION Pergunte(_cPerg)
@ 115,160 BMPBUTTON TYPE 1 ACTION Processa( {|| M001Proc(), Close(oDlg1) } )
@ 115,190 BMPBUTTON TYPE 2 ACTION Close(oDlg1)

ACTIVATE DIALOG oDlg1 centered

Return()

/*
+--------------------------------------------------------------------------+
! Função    ! M001Proc   ! Autor !Marcio A.Sugahara   ! Data ! 22/10/2015  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Função de geração do arquivo.                                !
+-----------+--------------------------------------------------------------+
*/
Static Function M001Proc()
Local cArq     := ''
Local cNomeArq := ''
Local cDirISS  := '\_ISS' //diretorio (servidor) onde os arquivos serão gerados
Local lGerou   := .f.
Local cDirDest
Local nProc    := 0
Local cMesAno


Private nDet   := 0

//verifica se existe diretorio para gravar arquivos no servidor
if !ExistDir(cDiriss)
	//cria diretorio
	MakeDir(cDiriss)
endif

//certifica se nao existe arquivos antigos
aFiles := directory( cDiriss+'\ISS*.txt' )
For nI := 1 to len(aFiles)
	cArq := cDiriss+'\'+alltrim(aFiles[nI,1])
	FERASE(cArq)
Next

cMesAno := substr(DTOC(mv_par01), 4, 2)+substr(DTOC(mv_par01), 7, 4)
cDirDest := mv_par02

ProcRegua(0)
IncProc("Criando arquivo temporario... ")
CriaTRB()
IncProc("Processando... Dados da Folha. ")
AtuTRBFol()
IncProc("Processando... Dados do Financeiro. ")
AtuTRBFin()
IncProc("Processando... Dados do Fiscal. ")
AtuTRBFis()

cNomeArq := 'ISS_PINHAIS_' + alltrim(cMesAno)+'_' + SUBSTR(TIME(), 7,2)+".TXT"
cArq     := cDiriss + '\' + cNomeArq
//cria arquivo no servidor
_nArq := FCreate(cArq,0)
ProcRegua(TRB->(RecCount()))
TRB->(DbSetOrder(1))
TRB->(DbGotop())
While !TRB->(EOF())
	IncProc("Geradno arqivo texto...")
	Reg10(_nArq)
	Reg20(_nArq)
	Reg30(_nArq)
	TRB->(DbSkip())
End

Fclose(_nArq)

//copia arquivo do servidor para o computador do usuário.
FT_FUse(cArq)  //abre o arquivo
//copia apenas arquivos com conteudo

If FT_FLastRec() > 0
	lGerou := .T.
	CPYs2t(cArq,cDirDest,.T.)
EndIf

If lGerou
	//	MsgInfo('Arquivo gerado com sucesso!' + CHR(13)+CHR(10) + ALLTRIM(cDirDest)+'\'+cNomeArq )
	If MsgYesNo("Arquivo gerado no diretorio: " + ALLTRIM(cDirDest)+'\'+cNomeArq + "." + ;
		(chr(13) + chr(10)) + ;
		(chr(13) + chr(10)) + ;
		"Deseja imprimir o Relatório para conferência?")
		ImpRel( cArq )
		
	EndIf
EndIf

//fecha e apaga arquivo do servidor
FT_FUse()
FERASE(cArq)

Return()


/*
+--------------------------------------------------------------------------+
! Função    ! CriaTRB    ! Autor !Marcio A.Sugahara   ! Data ! 22/10/2015  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Cria arquivo temporario.                                     !
+-----------+--------------------------------------------------------------+
*/

static Function CriaTRB()
Local aEstru := {}

If Select("TRB")<>0
	DbSelectArea("TRB")
	DbCloseArea()
Endif
aAdd( aEstru, { 'TR_TPSERV'  , 'C',  1, 0 } )
aAdd( aEstru, { 'TR_TPDOC'   , 'C',  2, 0 } )
aAdd( aEstru, { 'TR_DOC'     , 'C', 15, 0 } )
aAdd( aEstru, { 'TR_COMPET'  , 'C',  7, 0 } )
aAdd( aEstru, { 'TR_TPPREST' , 'C',  1, 0 } )
aAdd( aEstru, { 'TR_CNPJPRE' , 'C', 14, 0 } )
aAdd( aEstru, { 'TR_TPTOMAD' , 'C',  1, 0 } )
aAdd( aEstru, { 'TR_CNPJTOM' , 'C', 14, 0 } )
aAdd( aEstru, { 'TR_EMISSAO' , 'D',  8, 0 } )
aAdd( aEstru, { 'TR_VALOR'   , 'N', 18, 2 } )
aAdd( aEstru, { 'TR_SITDOC'  , 'C',  1, 0 } )
aAdd( aEstru, { 'TR_OBS'     , 'C',100, 0 } )
aAdd( aEstru, { 'TR_SIMPLES' , 'C',  1, 0 } )

aAdd( aEstru, { 'TR_CODISS'  , 'C',  7, 0 } )
aAdd( aEstru, { 'TR_ALIQISS' , 'N',  6, 2 } )
aAdd( aEstru, { 'TR_BASEISS' , 'N', 18, 2 } )
aAdd( aEstru, { 'TR_DEDUCAO' , 'N', 18, 2 } )
aAdd( aEstru, { 'TR_RETIDO'  , 'N', 18, 2 } )
aAdd( aEstru, { 'TR_LOCAL'   , 'C',  7, 0 } )
aAdd( aEstru, { 'TR_CSTISS'  , 'C',  2, 0 } )
aAdd( aEstru, { 'TR_TRIBUTA' , 'C',  1, 0 } )
aAdd( aEstru, { 'TR_REDISS'  , 'C',  1, 0 } )

aAdd( aEstru, { 'TR_RAZAO'   , 'C',  40, 0 } )
aAdd( aEstru, { 'TR_END'     , 'C',  40, 0 } )
aAdd( aEstru, { 'TR_NUM'     , 'C',   6, 0 } )
aAdd( aEstru, { 'TR_COMPEND' , 'C',  20, 0 } )
aAdd( aEstru, { 'TR_BAIRRO'  , 'C',  20, 0 } )
aAdd( aEstru, { 'TR_MUN'     , 'C',  30, 0 } )
aAdd( aEstru, { 'TR_EST'     , 'C',   2, 0 } )
aAdd( aEstru, { 'TR_CEP'     , 'C',   8, 0 } )
aAdd( aEstru, { 'TR_FONE'    , 'C',  12, 0 } )
aAdd( aEstru, { 'TR_FAX'     , 'C',  12, 0 } )

// cria o arquivo
cArqTRB := CriaTrab( aEstru, .T. )

// abre arquivo de trabalho
DbUseArea( .T.,__LocalDriver , cArqTRB, 'TRB', .F. )

_cIndex := Criatrab(Nil,.F.)
_cChave := "TR_CNPJPRE+TR_DOC"
Indregua("TRB",_cIndex,_cChave,,,"Selecionando Registros...")


Return()


/*
+--------------------------------------------------------------------------+
! Função    ! AtuTRBFol  ! Autor !Marcio A.Sugahara   ! Data ! 22/10/2015  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Seleciona os registros que serao processados.                !
!           ! Origem Folha.                                                !
+-----------+--------------------------------------------------------------+
*/
Static Function AtuTRBFol()
Local cSql :=  ''
Local cRet := ''
Local nPos
Local nValCont := 0

// lancamentos da folha
cSql +=  " SELECT RA_MAT, RA_ALIQISS, RA_BAIRRO, RA_CEP, RA_CIC, RA_CODISS, "
cSql +=  "        RA_COMPLEM, RA_CSTISS, RA_DDDFONE, RA_TELEFON, RA_ENDEREC, "
cSql +=  "        RA_LOGRNUM, RA_ESTADO, RA_MUNICIP, RA_NOME, RA_NUMINSC, RA_SERVICO, "
cSql +=  "        RA_SIAF, RD_DATPGT, RD_VALOR, RD_PD"
cSql +=  " FROM " + RetSqlName("SRA")+" SRA INNER JOIN "
cSql +=             RetSqlName("SRD")+" SRD ON "
cSql +=  "       SRD.RD_FILIAL = '"+xFilial("SRD")+"' AND "
cSql +=  "       SRD.RD_MAT = SRA.RA_MAT AND "
cSql +=  "       (SRD.RD_PD = '489' OR "
cSql +=  "       (SRD.RD_PD IN ("+cVerbaIss+") AND SRA.RA_NUMINSC <> '' )) AND "
cSql +=  "       SUBSTRING(SRD.RD_DATPGT,1,6) = '"+SUBSTR(DTOS(MV_PAR01),1,6)+"' AND"
cSql +=  "       SRD.D_E_L_E_T_ = ' ' "
cSql +=  " WHERE SRA.RA_FILIAL = '"+xFilial("SRA")+"' "
//cSql +=  "     AND SRA.RA_ALIQISS > 0 "
cSql += "      AND SRA.D_E_L_E_T_ = ' ' "

cSql := changequery(cSql)

If Select("TRBSRD")<>0
	DbSelectArea("TRBSRD")
	DbCloseArea()
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), "TRBSRD", .F., .T.)

While !TRBSRD->(EOF())
	nValCont := BuscaVal(TRBSRD->RA_MAT)  //Buca RD_VALOR da verba 125
	RecLock("TRB",.t.)
	TRB->TR_TPSERV  := '2'
	TRB->TR_TPDOC   := '04'
	TRB->TR_DOC     := PADL(TRBSRD->RD_DATPGT,15,'0')
	TRB->TR_COMPET  := SUBSTR(TRBSRD->RD_DATPGT,5,2) + '/' + SUBSTR(TRBSRD->RD_DATPGT,1,4)
	TRB->TR_TPPREST := 'F'
	TRB->TR_CNPJPRE := PADL(TRBSRD->RA_CIC,14,'0')
	TRB->TR_TPTOMAD := 'J'
	TRB->TR_CNPJTOM := SM0->M0_CGC
	TRB->TR_EMISSAO := STOD(TRBSRD->RD_DATPGT)
	TRB->TR_VALOR   := nValCont
	TRB->TR_SITDOC  := 'E'
	TRB->TR_OBS     := TRBSRD->RA_SERVICO
	TRB->TR_SIMPLES := 'N'
	
	//
	TRB->TR_CODISS  := PADL(ALLTRIM(TRBSRD->RA_CODISS),7,'0')
	TRB->TR_ALIQISS := TRBSRD->RA_ALIQISS
	TRB->TR_BASEISS := nValCont
	TRB->TR_DEDUCAO := 0
	If TRBSRD->RD_PD $ cVerbaIss //autonomo com inscricao (RA_NUMINSC)
		TRB->TR_RETIDO  := 0
	Else
		TRB->TR_RETIDO  := TRBSRD->RD_VALOR  //valor da versa 489
	Endif
	TRB->TR_LOCAL   := PADL(ALLTRIM(TRBSRD->RA_SIAF),7,'0')
	TRB->TR_CSTISS  := TRBSRD->RA_CSTISS
	
	If Empty(TRBSRD->RA_NUMINSC)
		TRB->TR_TRIBUTA := 'N'
	Else
		TRB->TR_TRIBUTA := 'S'
	EndIf
	//TRB->TR_TRIBUTA := If(Empty(TRBSRD->RA_NUMINSC),'N',TRBSRD->RA_NUMINSC)
	
	TRB->TR_REDISS  := ' '
	
	//
	TRB->TR_RAZAO   := TRBSRD->RA_NOME
	
	//Modificado em 23/09/2019 - Cristiano Vieira
	/*
	//separa endereço do numero
	npos := At(',', TRBSRD->RA_ENDEREC)
	If nPos > 0
		cRet := Substr(TRBSRD->RA_ENDEREC,1,nPos-1)
	Else
		cRet := TRBSRD->RA_ENDEREC
	EndIf
	TRB->TR_END     := cRet
	
	If nPos > 0
		cRet := Alltrim(Substr(TRBSRD->RA_ENDEREC,npos+1))
	Else
		cRet := space(6)
	EndIf
	*/
	TRB->TR_END 	:= TRBSRD->RA_ENDEREC	
	TRB->TR_NUM     := TRBSRD->RA_LOGRNUM	
	TRB->TR_COMPEND := TRBSRD->RA_COMPLEM
	TRB->TR_BAIRRO  := TRBSRD->RA_BAIRRO
	TRB->TR_MUN     := TRBSRD->RA_MUNICIP
	TRB->TR_EST     := TRBSRD->RA_ESTADO
	TRB->TR_CEP     := TRBSRD->RA_CEP
	TRB->TR_FONE    := TRBSRD->RA_DDDFONE+TRBSRD->RA_TELEFON
	TRB->TR_FAX     := '00 0000-0000'
	MsUnLock()
	TRBSRD->(DbSkip())
End
Return()



//EM 16/02/2016
//SUBSTITUICAO PARA A TABELA SRD.
/*Static Function AtuTRBFol()
Local cSql :=  ''
Local cRet := ''
Local nPos
Local nValCont := 0

// lancamentos da folha
cSql +=  " SELECT RA_MAT, RA_ALIQISS, RA_BAIRRO, RA_CEP, RA_CIC, RA_CODISS, "
cSql +=  "        RA_COMPLEM, RA_CSTISS, RA_DDDFONE, RA_TELEFON, RA_ENDEREC, "
cSql +=  "        RA_ESTADO, RA_MUNICIP, RA_NOME, RA_NUMINSC, RA_SERVICO, RA_SIAF, "
cSql +=  "        RC_DATA, RC_VALOR"
cSql +=  " FROM " + RetSqlName("SRA")+" SRA INNER JOIN "
cSql +=             RetSqlName("SRC")+" SRC ON "
cSql +=  "       SRC.RC_FILIAL = '"+xFilial("SRC")+"' AND "
cSql +=  "       SRC.RC_MAT = SRA.RA_MAT AND "
cSql +=  "       SRC.RC_PD = '489' AND "
cSql +=  "       SUBSTRING(SRC.RC_DATA,1,6) = '"+SUBSTR(DTOS(MV_PAR01),1,6)+"' AND"
cSql +=  "       SRC.D_E_L_E_T_ = ' '"
cSql +=  " WHERE SRA.RA_FILIAL = '"+xFilial("SRA")+"' "
cSql +=  "     AND SRA.RA_ALIQISS > 0 "
cSql += "      AND SRA.D_E_L_E_T_ = ' ' "

cSql := changequery(cSql)

If Select("TRBSRC")<>0
DbSelectArea("TRBSRC")
DbCloseArea()
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), "TRBSRC", .F., .T.)

While !TRBSRC->(EOF())
nValCont := BuscaVal(TRBSRC->RA_MAT)  //Buca RC_VALOR da verba 125
RecLock("TRB",.t.)
TRB->TR_TPSERV  := '2'
TRB->TR_TPDOC   := '04'
TRB->TR_DOC     := PADL(TRBSRC->RC_DATA,15,'0')
TRB->TR_COMPET  := SUBSTR(TRBSRC->RC_DATA,5,2) + '/' + SUBSTR(TRBSRC->RC_DATA,1,4)
TRB->TR_TPPREST := 'F'
TRB->TR_CNPJPRE := PADL(TRBSRC->RA_CIC,14,'0')
TRB->TR_TPTOMAD := 'J'
TRB->TR_CNPJTOM := SM0->M0_CGC
TRB->TR_EMISSAO := STOD(TRBSRC->RC_DATA)
TRB->TR_VALOR   := nValCont
TRB->TR_SITDOC  := 'E'
TRB->TR_OBS     := TRBSRC->RA_SERVICO
TRB->TR_SIMPLES := 'N'

//
TRB->TR_CODISS  := PADL(ALLTRIM(TRBSRC->RA_CODISS),7,'0')
TRB->TR_ALIQISS := TRBSRC->RA_ALIQISS
TRB->TR_BASEISS := nValCont
TRB->TR_DEDUCAO := 0
TRB->TR_RETIDO  := TRBSRC->RC_VALOR  //valor da versa 489
TRB->TR_LOCAL   := PADL(ALLTRIM(TRBSRC->RA_SIAF),7,'0')
TRB->TR_CSTISS  := TRBSRC->RA_CSTISS
TRB->TR_TRIBUTA := If(Empty(TRBSRC->RA_NUMINSC),'N','S')
TRB->TR_REDISS  := ' '

//
TRB->TR_RAZAO   := TRBSRC->RA_NOME

npos := At(',', TRBSRC->RA_ENDEREC)
cRet := Substr(TRBSRC->RA_ENDEREC,1,nPos-1)
TRB->TR_END     := cRet

cRet := Alltrim(Substr(TRBSRC->RA_ENDEREC,npos+1))
TRB->TR_NUM     := cRet
TRB->TR_COMPEND := TRBSRC->RA_COMPLEM
TRB->TR_BAIRRO  := TRBSRC->RA_BAIRRO
TRB->TR_MUN     := TRBSRC->RA_MUNICIP
TRB->TR_EST     := TRBSRC->RA_ESTADO
TRB->TR_CEP     := TRBSRC->RA_CEP
TRB->TR_FONE    := TRBSRC->RA_DDDFONE+TRBSRC->RA_TELEFON
TRB->TR_FAX     := '00 0000-0000'

TRBSRC->(DbSkip())
End
Return()*/




/*
+--------------------------------------------------------------------------+
! Função    ! AtuTRBFin  ! Autor !Marcio A.Sugahara   ! Data ! 22/10/2015  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Seleciona os registros que serao processados.                !
!           ! Origem Financeiro.                                           !
+-----------+--------------------------------------------------------------+
*/
Static Function AtuTRBFin()
Local cSql :=  ''
Local cRet := ''
Local nPos

//lancamentos do financeiro
cSql := ""
cSql +=  " SELECT A2_BAIRRO, A2_CEP, A2_CGC, A2_CODSIAF, A2_COMPLEM, A2_DDD, "
cSql +=  "        A2_END, A2_NR_END, A2_EST, A2_FAX, A2_MUN, A2_NOME, A2_RECISS, A2_SIMPNAC, "
cSql +=  "        A2_TEL, A2_TIPO, E2_EMISSAO, E2_FORNECE, E2_NUM, E2_VALOR, E2_IRRF "
cSql +=  " FROM " + RetSqlName("SA2")+" SA2 INNER JOIN "
cSql +=             RetSqlName("SE2")+" SE2 ON "
cSql +=  "       SE2.E2_FILIAL = '"+xFilial("SE2")+"' AND "
cSql +=  "       SE2.E2_FORNECE = SA2.A2_COD AND "
cSql +=  "       SE2.E2_LOJA    = SA2.A2_LOJA AND "
cSql +=  "       SE2.E2_PREFIXO IN ('CJ1','CJ2') AND "
cSql +=  "       SE2.E2_TIPO = 'NF ' AND "
cSql +=  "       SUBSTRING(SE2.E2_EMISSAO,1,6) = '"+SUBSTR(DTOS(MV_PAR01),1,6)+"' AND "
cSql +=  "       SE2.D_E_L_E_T_ = ' '"
cSql +=  " WHERE SA2.A2_FILIAL = '"+xFilial("SA2")+"' "
cSql += "      AND SA2.D_E_L_E_T_ = ' ' "
cSql := changequery(cSql)

If Select("TRBSE2")<>0
	DbSelectArea("TRBSE2")
	DbCloseArea()
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), "TRBSE2", .F., .T.)

While !TRBSE2->(EOF())
	RecLock("TRB",.t.)
	TRB->TR_TPSERV  := '2'
	TRB->TR_TPDOC   := '07'
	TRB->TR_DOC     := PADL(TRBSE2->E2_NUM,15,'0')
	TRB->TR_COMPET  := SUBSTR(TRBSE2->E2_EMISSAO,5,2) + '/' + SUBSTR(TRBSE2->E2_EMISSAO,1,4)
	TRB->TR_TPPREST := TRBSE2->A2_TIPO
	TRB->TR_CNPJPRE := PADL(TRBSE2->A2_CGC,14,'0')
	TRB->TR_TPTOMAD := 'J'
	TRB->TR_CNPJTOM := SM0->M0_CGC
	TRB->TR_EMISSAO := STOD(TRBSE2->E2_EMISSAO)
	TRB->TR_VALOR   := TRBSE2->E2_VALOR + TRBSE2->E2_IRRF
	TRB->TR_SITDOC  := 'E'
	TRB->TR_OBS     := 'COMISSAO SOBRE VENDA DE COTAS DE CONSORCIO'
	
	If TRBSE2->A2_SIMPNAC <> '1'
		TRB->TR_SIMPLES := 'N'
	Else
		TRB->TR_SIMPLES := 'S
	EndIf

	
	//TRB->TR_SIMPLES := If(Empty(TRBSE2->A2_SIMPNAC),'N',TRBSE2->A2_SIMPNAC)
	
	//
	TRB->TR_CODISS  := '0001009'

	If TRBSE2->A2_RECISS = 'S' .and.  TRBSE2->A2_SIMPNAC = '1'
		TRB->TR_ALIQISS := GetMV("MV_ALIQISS")
	Else
		TRB->TR_ALIQISS := 0
 	EndIf
	
	
	TRB->TR_BASEISS := TRBSE2->E2_VALOR + TRBSE2->E2_IRRF
	TRB->TR_DEDUCAO := 0
	TRB->TR_RETIDO  := 0
	TRB->TR_LOCAL   := PADL(ALLTRIM(TRBSE2->A2_CODSIAF),7,'0')
	TRB->TR_CSTISS  := '13'
	TRB->TR_TRIBUTA := TRBSE2->A2_RECISS
	TRB->TR_REDISS  := ' '
	
	//
	TRB->TR_RAZAO   := TRBSE2->A2_NOME
	
	//Modificado em 23/09/2019 - Cristiano Vieira
	/*
	//separa endereço do numero
	npos := At(',', TRBSE2->A2_END)
	If nPos > 0
		cRet := Substr(TRBSE2->A2_END,1,nPos-1)
	Else
		cRet := TRBSE2->A2_END
	EndIf
	TRB->TR_END     := cRet
	
	If nPos > 0
		cRet := Alltrim(Substr(TRBSE2->A2_END,npos+1))
	Else
		cRet := space(6)
	EndIf
	*/
	
	TRB->TR_END		:= TRBSE2->A2_END
	TRB->TR_NUM     := TRBSE2->A2_NR_END
	TRB->TR_COMPEND := TRBSE2->A2_COMPLEM
	TRB->TR_BAIRRO  := TRBSE2->A2_BAIRRO
	TRB->TR_MUN     := TRBSE2->A2_MUN
	TRB->TR_EST     := TRBSE2->A2_EST
	TRB->TR_CEP     := TRBSE2->A2_CEP
	TRB->TR_FONE    := TRBSE2->A2_DDD+TRBSE2->A2_TEL
	TRB->TR_FAX     := TRBSE2->A2_DDD+TRBSE2->A2_FAX
	MsUnLock()
	TRBSE2->(DbSkip())
End
Return()

/*
+--------------------------------------------------------------------------+
! Função    ! AtuTRBFis  ! Autor !Marcio A.Sugahara   ! Data ! 22/10/2015  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Seleciona os registros que serao processados.                !
!           ! Origem Fiscal.                                               !
+-----------+--------------------------------------------------------------+
*/
Static Function AtuTRBFis()
Local cSql :=  ''
Local cRet := ''
Local nPos
Local cChvTRB   := ''

//lancamentos do fiscal
cSql := ""
cSql += " SELECT A2_BAIRRO, A2_CEP, A2_CGC, A2_CODSIAF, A2_COMPLEM, A2_DDD, "
cSql += "        A2_END, A2_NR_END, A2_EST, A2_FAX, A2_MUN, A2_NOME, A2_RECISS, A2_SIMPNAC, "
cSql += "        A2_TEL, A2_TIPO, B1_ALIQISS, B1_CODISS, B1_DESC, D1_BASEISS, D1_VALISS, D1_ALIQISS, "
cSql += "        F3_EMISSAO, F3_ESPECIE, F3_NFISCAL, F3_VALCONT, F3_RECISS, A2_CSTISS, FT_PRODUTO "
cSql +=  " FROM " + RetSqlName("SA2")+" SA2 INNER JOIN "
cSql +=             RetSqlName("SF3")+" SF3 ON "
cSql +=  "       SF3.F3_FILIAL  = '"+xFilial("SF3")+"' AND "
cSql +=  "       SF3.F3_CLIEFOR = SA2.A2_COD AND "
cSql +=  "       SF3.F3_LOJA    = SA2.A2_LOJA AND "
cSql +=  "       SUBSTRING(SF3.F3_CFO,1,1) < '5' AND "
cSql +=  "       SF3.F3_TIPO    = 'S' AND "
//cSql +=  "       SF3.F3_NFISCAL    = '000040023' AND "
cSql +=  "       SUBSTRING(SF3.F3_EMISSAO,1,6) = '"+SUBSTR(DTOS(MV_PAR01),1,6)+"' AND "
cSql +=  "       SF3.D_E_L_E_T_ = ' ' INNER JOIN "
cSql +=             RetSqlName("SFT")+" SFT ON "
cSql +=  "       SFT.FT_FILIAL  = '"+xFilial("SFT")+"' AND "
cSql +=  "       SFT.FT_NFISCAL = SF3.F3_NFISCAL  AND "
cSql +=  "       SFT.FT_SERIE   = SF3.F3_SERIE AND "
cSql +=  "       SFT.FT_CLIEFOR = SF3.F3_CLIEFOR AND "
cSql +=  "       SFT.FT_LOJA    = SF3.F3_LOJA AND "
cSql +=  "       SUBSTRING(SFT.FT_CFOP,1,1) < '5' AND "
cSql +=  "       SFT.FT_TIPO    = 'S' AND "
cSql +=  "       SFT.D_E_L_E_T_ = ' ' INNER JOIN "
cSql +=             RetSqlName("SD1")+" SD1 ON "
cSql +=  "       SD1.D1_FILIAL  = '"+xFilial("SD1")+"' AND "
cSql +=  "       SD1.D1_DOC     = SFT.FT_NFISCAL  AND "
cSql +=  "       SD1.D1_SERIE   = SFT.FT_SERIE AND "
cSql +=  "       SD1.D1_FORNECE = SFT.FT_CLIEFOR AND "
cSql +=  "       SD1.D1_LOJA    = SFT.FT_LOJA AND "
cSql +=  "       SD1.D1_COD     = SFT.FT_PRODUTO AND "
cSql +=  "       SD1.D1_ITEM    = SFT.FT_ITEM AND "
cSql +=  "       SUBSTRING(SD1.D1_CF,1,1) < '5' AND "
cSql +=  "       SD1.D_E_L_E_T_ = ' ' INNER JOIN "
cSql +=             RetSqlName("SB1")+" SB1 ON "
cSql +=  "       SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
cSql +=  "       SB1.B1_COD = SFT.FT_PRODUTO  AND "
cSql +=  "       SB1.D_E_L_E_T_ = ' ' INNER JOIN "
cSql +=             RetSqlName("SF4")+" SF4 ON "
cSql +=  "       SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND "
cSql +=  "       SF4.F4_CODIGO = SD1.D1_TES  AND "
cSql +=  "       SF4.D_E_L_E_T_ = ' '  "
cSql +=  " WHERE SA2.A2_FILIAL = '"+xFilial("SA2")+"' "
cSql += "      AND SA2.D_E_L_E_T_ = ' ' "
cSql := changequery(cSql)

If Select("TRBSF3")<>0
	DbSelectArea("TRBSF3")
	DbCloseArea()
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), "TRBSF3", .F., .T.)

While !TRBSF3->(EOF())
	If !TRB->(DbSeek(PADL(TRBSF3->A2_CGC,14,'0')+PADL(TRBSF3->F3_NFISCAL,15,'0')))
		RecLock("TRB",.t.)
		TRB->TR_TPSERV  := '2'
		TRB->TR_TPDOC   := '07'
		TRB->TR_DOC     := PADL(TRBSF3->F3_NFISCAL,15,'0')
		TRB->TR_COMPET  := SUBSTR(TRBSF3->F3_EMISSAO,5,2) + '/' + SUBSTR(TRBSF3->F3_EMISSAO,1,4)
		TRB->TR_TPPREST := TRBSF3->A2_TIPO
		TRB->TR_CNPJPRE := PADL(TRBSF3->A2_CGC,14,'0')
		TRB->TR_TPTOMAD := 'J'
		TRB->TR_CNPJTOM := SM0->M0_CGC
		TRB->TR_EMISSAO := STOD(TRBSF3->F3_EMISSAO)
		TRB->TR_VALOR   := TRBSF3->F3_VALCONT
		TRB->TR_SITDOC  := 'E'
		TRB->TR_OBS     := TRBSF3->B1_DESC
		
		If TRBSF3->A2_SIMPNAC <> '1'
			TRB->TR_SIMPLES := 'N'
		Else
			TRB->TR_SIMPLES := 'S
		EndIf

		//Modificado em 21/03/2022 - Cristiano Vieira
		//*** INÍCIO ***		
		/*
		If TRBSF3->F3_RECISS = '1'
			If TRBSF3->A2_SIMPNAC = '1'
				TRB->TR_ALIQISS := GetMV("MV_ALIQISS")
			Else
				TRB->TR_ALIQISS := 0
			EndIf
			TRB->TR_BASEISS := TRBSF3->F3_VALCONT
			TRB->TR_RETIDO  := 0
		Else
			TRB->TR_ALIQISS := TRBSF3->D1_ALIQISS
			TRB->TR_BASEISS := TRBSF3->D1_BASEISS
			TRB->TR_RETIDO  := TRBSF3->D1_VALISS
		EndIf
		*/
		If TRBSF3->F3_RECISS = '1'
			If TRBSF3->A2_SIMPNAC = '1'
				TRB->TR_ALIQISS := GetMV("MV_ALIQISS")
			Else
				TRB->TR_ALIQISS := 0
			EndIf
			TRB->TR_BASEISS := TRBSF3->F3_VALCONT
			TRB->TR_RETIDO  := 0
		Else 
			If TRBSE2->A2_CODSIAF = '7535'
				TRB->TR_ALIQISS := 0
				TRB->TR_BASEISS := 0
				TRB->TR_RETIDO  := 0
			EndIf
		EndIf
		//*** FIM ***

		
		TRB->TR_CODISS  := PADL(ALLTRIM(TRBSF3->B1_CODISS),7,'0')
		TRB->TR_DEDUCAO := 0
		TRB->TR_LOCAL   := If(TRBSF3->A2_RECISS = 'S',PADL(ALLTRIM(TRBSF3->A2_CODSIAF),7,'0'),'0005453')
		TRB->TR_CSTISS  := TRBSF3->A2_CSTISS
		TRB->TR_TRIBUTA := TRBSF3->A2_RECISS
		TRB->TR_REDISS  := ' '
		
		
		TRB->TR_RAZAO   := TRBSF3->A2_NOME
		
		//Modificado em 23/09/2019 - Cristiano Vieira
		/*
		//separa endereço do numero
		npos := At(',', TRBSF3->A2_END)
		If nPos > 0
			cRet := Substr(TRBSF3->A2_END,1,nPos-1)
		Else
			cRet := TRBSF3->A2_END
		EndIf
		TRB->TR_END     := cRet
		
		If nPos > 0
			cRet := Alltrim(Substr(TRBSF3->A2_END,npos+1))
		Else
			cRet := space(6)
		EndIf
		*/
		
		TRB->TR_END		:= TRBSF3->A2_END
		TRB->TR_NUM     := TRBSF3->A2_NR_END		
		TRB->TR_COMPEND := TRBSF3->A2_COMPLEM
		TRB->TR_BAIRRO  := TRBSF3->A2_BAIRRO
		TRB->TR_MUN     := TRBSF3->A2_MUN
		TRB->TR_EST     := TRBSF3->A2_EST
		TRB->TR_CEP     := TRBSF3->A2_CEP
		TRB->TR_FONE    := TRBSF3->A2_DDD+TRBSF3->A2_TEL
		TRB->TR_FAX     := TRBSF3->A2_DDD+TRBSF3->A2_FAX
		MsUnLock()
	Else
		RecLock("TRB",.f.)
		If TRBSF3->F3_RECISS = '1'
			TRB->TR_BASEISS := TRBSF3->F3_VALCONT
			TRB->TR_RETIDO  := 0
		Else
			TRB->TR_BASEISS += TRBSF3->D1_BASEISS
			TRB->TR_RETIDO  += TRBSF3->D1_VALISS		
		EndIf
		MsUnLock()
	EndIf
	
	TRBSF3->(DbSkip())
End

Return()


Static Function BuscaVal(cMatr)
Local cSql := ''

cSql +=  " SELECT SUM(RD_VALOR)  RD_VALOR "
cSql +=  " FROM " + RetSqlName("SRD")+" SRD "
cSql +=  " WHERE SRD.RD_FILIAL = '"+xFilial("SRD")+"' AND "
cSql +=  "       SRD.RD_MAT = '"+cMatr+"' AND "
cSql +=  "       SRD.RD_PD IN ("+cVerbaIss+") AND "
//cSql +=  "       SRD.RD_PD = '978' AND "
cSql +=  "       SUBSTRING(SRD.RD_DATPGT,1,6) = '"+SUBSTR(DTOS(MV_PAR01),1,6)+"' AND"
cSql +=  "       SRD.D_E_L_E_T_ = ' '"
If Select("TRBVAL")<>0
	DbSelectArea("TRBVAL")
	DbCloseArea()
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), "TRBVAL", .F., .T.)

Return(TRBVAL->RD_VALOR)


/*
+--------------------------------------------------------------------------+
! Função    ! Reg10      ! Autor !Marcio A.Sugahara   ! Data ! 26/10/2015  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Registro 10                                                  !
+-----------+--------------------------------------------------------------+
*/
Static Function Reg10(_nArq)

_cAux := '10'   // registro
_cAux += ';'
_cAux += TRB->TR_TPSERV  //tipo servico
_cAux += ';'
_cAux += TRB->TR_TPDOC
_cAux += ';'
_cAux += TRB->TR_DOC
_cAux += ';'
_cAux += TRB->TR_COMPET
_cAux += ';'
_cAux += TRB->TR_TPPREST
_cAux += ';'
_cAux += TRB->TR_CNPJPRE
_cAux += ';'
_cAux += TRB->TR_TPTOMAD
_cAux += ';'
_cAux += TRB->TR_CNPJTOM
_cAux += ';'
_cAux += DTOC(TRB->TR_EMISSAO)
_cAux += ';'
_cAux += PADL(ALLTRIM(TRANSFORM(TRB->TR_VALOR,cPict18)),18,'0')
_cAux += ';'
_cAux += TRB->TR_SITDOC
_cAux += ';'
_cAux += TRB->TR_OBS
_cAux += ';'
_cAux += TRB->TR_SIMPLES
_cAux += ';'
_cAux += CHR(13)+CHR(10)
FWrite(_nArq,_cAux)
Return()


/*
+--------------------------------------------------------------------------+
! Função    ! Reg20      ! Autor !Marcio A.Sugahara   ! Data ! 26/10/2015  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Registro 20                                                  !
+-----------+--------------------------------------------------------------+
*/
Static Function Reg20(_nArq)

_cAux := '20'   // registro
_cAux += ';'
_cAux += TRB->TR_TPSERV  //tipo servico
_cAux += ';'
_cAux += TRB->TR_TPDOC
_cAux += ';'
_cAux += TRB->TR_DOC
_cAux += ';'
_cAux += TRB->TR_COMPET
_cAux += ';'
_cAux += TRB->TR_TPPREST
_cAux += ';'
_cAux += TRB->TR_CNPJPRE
_cAux += ';'
_cAux += TRB->TR_TPTOMAD
_cAux += ';'
_cAux += TRB->TR_CNPJTOM
_cAux += ';'
_cAux += TRB->TR_CODISS
_cAux += ';'
_cAux += PADL(ALLTRIM(TRANSFORM(TRB->TR_ALIQISS,cPict6)),6,'0')
_cAux += ';'
_cAux += PADL(ALLTRIM(TRANSFORM(TRB->TR_BASEISS,cPict18)),18,'0')
_cAux += ';'
_cAux += PADL(ALLTRIM(TRANSFORM(TRB->TR_DEDUCAO,cPict18)),18,'0')
_cAux += ';'
_cAux += PADL(ALLTRIM(TRANSFORM(TRB->TR_RETIDO,cPict18)),18,'0')
_cAux += ';'
_cAux += TRB->TR_LOCAL
_cAux += ';'
_cAux += TRB->TR_CSTISS
_cAux += ';'
_cAux += TRB->TR_TRIBUTA
_cAux += ';'
_cAux += TRB->TR_REDISS
_cAux += ';'
_cAux += CHR(13)+CHR(10)
FWrite(_nArq,_cAux)
Return()



/*
+--------------------------------------------------------------------------+
! Função    ! Reg30      ! Autor !Marcio A.Sugahara   ! Data ! 26/10/2015  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Registro 30                                                  !
+-----------+--------------------------------------------------------------+
*/
Static Function Reg30(_nArq)

_cAux := '30'   // registro
_cAux += ';'
_cAux += TRB->TR_TPPREST
_cAux += ';'
_cAux += TRB->TR_CNPJPRE
_cAux += ';'
_cAux += TRB->TR_RAZAO
_cAux += ';'
_cAux += TRB->TR_END
_cAux += ';'
_cAux += TRB->TR_NUM
_cAux += ';'
_cAux += TRB->TR_COMPEND
_cAux += ';'
_cAux += TRB->TR_BAIRRO
_cAux += ';'
_cAux += TRB->TR_MUN
_cAux += ';'
_cAux += TRB->TR_EST
_cAux += ';'
_cAux += TRB->TR_CEP
_cAux += ';'
_cAux += TRB->TR_FONE
_cAux += ';'
_cAux += TRB->TR_FAX
_cAux += ';'
_cAux += CHR(13)+CHR(10)
FWrite(_nArq,_cAux)
Return()










/*
+-------------------------------------------------------------------------+
! Função    ! AjustaSX1 ! Autor ! Marcio A.Sugahara  ! Data !  22/10/2015 !
+-----------+-----------+-------+--------------------+------+-------------+
! Descricao ! Ajusta as perguntas do SX1.                                 !
+-----------+-------------------------------------------------------------+
*/
Static Function AjustaSX1()

putSx1(_cPerg, '01', 'Data referencia?' , 'Data referencia?', 'Data referencia?', 'mv_ch1', 'D', 08, 0, 0, 'G', ''            , '', '', '', 'MV_PAR01')
PutSx1(_cPerg, '02', 'Diretorio Dest.?' , 'Diretorio Dest.?', 'Diretorio Dest.?', 'mv_ch2', 'C', 60, 0, 0, 'G', 'U_MFIS002A' , '', '', '', 'MV_PAR02')
Return()

//validacao usada no SX1
User Function MFIS002A()
Local cArqDest := cGetFile("*.txt","Selecione o Destino...",1,"C:\",.F.,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_OVERWRITEPROMPT+GETF_NETWORKDRIVE)
mvRet      := Alltrim(ReadVar())		// Iguala Nome da Variavel ao Nome variavel de Retorno
&MvRet     := alltrim(cArqDest)	// Devolve Resultado
Return()


/*
+-------------------------------------------------------------------------+
! Função    ! AjustaSX1 ! Autor ! Marcio A.Sugahara  ! Data !  22/10/2015 !
+-----------+-----------+-------+--------------------+------+-------------+
! Descricao ! Ajusta as perguntas do SX1.                                 !
+-----------+-------------------------------------------------------------+
*/
Static Function ImpRel(cDiretorio)

Local cArq    := cDiretorio
Local cLinha  := ""
//Local lPrim   := .T.
Local aCampos := {}
Local aDados := {}
Local aArea := GetArea()

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
	MsgStop("O arquivo " +cArq + " não foi encontrado. A importação será abortada!","[RELISS] - ATENCAO")
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
AADD(_aFields,{"TR_TPDOC"   ,"C",02,00,"@!"                }) //

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
			TRC->TR_TPDOC  := aDados[nX,3]
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
If Select("TRC")<>0
	DbSelectArea("TRC")
	DbCloseArea()
Endif
Return


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

Local nValorTotal := 0
Local nValorISS   := 0
Local nQtd   := 0
Private lPrim     := .T.

If nLin >= 3000
	fQuebra()
EndIf
oPrint:SetMeter( TRC->(LastRec() ))
TRC->(dbGoTop())
If TRC->(!Eof())
	nLinN := 0100
	DO While TRC->(!Eof())
		IF oPrint:Cancel()
			Exit
		EndIF
		
		oPrint:IncMeter(,,nQtd)
		
		oPrint:Say(nLin,0075, TRC->TR_COMPET , ofonte09)
		oPrint:Say(nLin,0455, TRC->TR_CNPJ, ofonte09,,,,1)
		oPrint:Say(nLin,0485, TRC->TR_NOME, ofonte09)
		oPrint:Say(nLin,1130, TRC->TR_DOC, ofonte09)
		oPrint:Say(nLin,1375, DTOC(TRC->TR_EMISSAO), ofonte09)
		oPrint:Say(nLin,1740, TRANSFORM(TRC->TR_VALOR,"@E 999,999,999.99"), ofonte09,,,,1)
		oPrint:Say(nLin,2050, TRANSFORM(TRC->TR_ISS,"@E 999,999.99"), ofonte09,,,,1)
		oPrint:Say(nLin,2100, TRC->TR_TPDOC, ofonte09)		
		nValorTotal += TRC->TR_VALOR
		nValorISS	+= TRC->TR_ISS
		nQtd++
		nLin+=50
		TRC->(DbSkip())
		If nLin >= 3000
			fQuebra()
		endif
	EndDo
	
	nLin += 65
	oPrint:Line(nLin,0050,nLin,2320)
	nLin += 50
	oPrint:Say(nLin,0250, "VALOR TOTAL: "+ TRANSFORM(nValorTotal,"@E 999,999,999.99"), oFonte09)
	oPrint:Say(nLin,0600, "ISS TOTAL: "+ TRANSFORM(nValorISS,"@E 999,999,999.99"), oFonte09)
	oPrint:Say(nLin,1200, "Quantidade: "+ TRANSFORM(nQtd,"@E 999999"), oFonte09)
	oPrint:EndPage(.T.)
	
	TRC->(DbCloseArea())
Endif

Return


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
	oPrint:SayBitmap(050,050,"lgrl01.bmp",400,130)
	cEmpresa  := SM0->M0_NOMECOM
	cCnpj     := TRANSFORM(SM0->M0_CGC, "@R 99.999.999/9999-99")
	oPrint:Say(080,1200, cEmpresa , oFonte14N,,,,2)
	oPrint:Say(150,1200, "CNPJ: " + cCnpj , oFonte10N,,,,2)
	
	nLin := 200
	nLinAux := nLin
	nLin += 20
	
	oPrint:Say(nLin,0075, "Competencia"          , ofonte09N)
	oPrint:Say(nLin,0375, "CNPJ/CPF"        , ofonte09N,,,,1)
	oPrint:Say(nLin,0485, "NOME"	, ofonte09N)
	oPrint:Say(nLin,1150, "NUMERO"	, ofonte09N)
	oPrint:Say(nLin,1365, "EMISSAO"   , ofonte09N)
	oPrint:Say(nLin,1650, "VALOR CONTABIL"  , ofonte09N,,,,2)
	oPrint:Say(nLin,2050, "VALOR ISS" , oFonte09N,,,,1)
	oPrint:Say(nLin,2100, "TP.DOC."   , ofonte09N)
	nLin += 65
	oPrint:Line(nLin,0050,nLin,2320)
else
	lPrim := .F.
	
	oPrint:StartPage()
	
	oPrint:SayBitmap(050,050,"lgrl01.bmp",400,130)
	
	cEmpresa  := SM0->M0_NOMECOM
	cCnpj     := TRANSFORM(SM0->M0_CGC, "@R 99.999.999/9999-99")
	
	oPrint:Say(080,1200, cEmpresa , oFonte14N,,,,2)
	oPrint:Say(150,1200, "CNPJ: " + cCnpj , oFonte10N,,,,2)
	nLin := 200
	
	nLinAux := nLin
	nLin += 20
	
	oPrint:Say(nLin,0075, "Competencia"          , ofonte09N)
	oPrint:Say(nLin,0375, "CNPJ/CPF"        , ofonte09N,,,,1)
	oPrint:Say(nLin,0485, "NOME"	, ofonte09N)
	oPrint:Say(nLin,1150, "NUMERO"	, ofonte09N)
	oPrint:Say(nLin,1365, "EMISSAO"   , ofonte09N)
	oPrint:Say(nLin,1650, "VALOR CONTABIL"  , ofonte09N,,,,2)
	oPrint:Say(nLin,2050, "VALOR ISS" , oFonte09N,,,,1)
	oPrint:Say(nLin,2100, "TP.DOC."   , ofonte09N)
	nLin += 65
	oPrint:Line(nLin,0050,nLin,2320)
endif

Return


Static Function fRGB(R,G,B)

Return B * 65536 + G * 256 + R
