#INCLUDE "RWMAKE.CH"
#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! AltSal                                                  !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o         ! Rotina para cadastro de Tipos de Alteções Salariais   !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                      !
+------------------+---------------------------------------------------------!
!Data              ! 03/12/2010                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/
user function MFisc003

Local nOpca := 0
Local oDlg
Local aSays	   := { }
Local aButtons := { }
Local oDlg

Private cPict6  := "999.99"
Private cPict18 := "999999999999999.99"
Private _cPerg := ''
Private cVerbaIss:= GetNewPar("AD_VRBISS","'125','221'")
dbSelectArea("SX1")  
dbSetOrder(1)
_cPerg := "MFIS003" +Replicate(" ",Len(X1_GRUPO)- Len("MFIS003"))
GeraPerg(_cPerg)
Pergunte(_cPerg,.F.)

DEFINE FONT oFont2 NAME "Arial' SIZE 000,-012

DEFINE MSDIALOG oDlg1 FROM 0,0 TO 270,505 TITLE 'Geracao de arquivo de ISS' PIXEL
@ 0.5, 0.7 TO 7.8, 31

@  23,14 SAY oSay prompt 'Este programa gera arquivo texto de ISS da Prefeitura de Curitiba,' SIZE 275, 007 OF oDlg1 PIXEL FONT oFont2
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
Local cMesAno :=0
Local Ni := 0
Local cNomeArq := "PMC_"

Private nDet   := 0

//verifica se existe diretorio para gravar arquivos no servidor
If !Pergunte(_cPerg,.T.)
   Return
Endif 

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
cNomeArq := "PMC_" + strZero(month(MV_PAR01),2) + "_"+cValtoChar(Year(MV_PAR01))+".txt"
nHandle := FCreate(Alltrim(MV_PAR04)+ cNomeArq)
If nHandle < 0
    ConOut("Erro durante criação do arquivo.")
    Return
Endif
If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif

cQry := "Select * from "+ RetSqlName("SE2") + " SE2"
cQry +=  " Inner join " + RetSqlName("SA2") + " SA2 on 	SA2.A2_COD = SE2.E2_FORNECE AND SA2.A2_LOJA = SE2.E2_LOJA"
cQry += " where SE2.D_E_L_E_T_ =' ' and SUBSTRING(SE2.E2_EMISSAO,1,6) = '"+SUBSTR(DTOS(MV_PAR01),1,6)+"'"
cQry += " And E2_TIPO ='NF' and E2_FILIAL ='"+ xFilial("SE2")+"' "
cQry += " AND (SE2.E2_PREFIXO LIKE 'CJ%' OR SE2.E2_PREFIXO LIKE 'CF%' )"
cQry += " Order by A2_CGC"

TcQuery cQry New Alias "QRY"  
cHeader := RetHeader()

FWrite(nHandle, cHeader)
nCont := 0
nValor := 0

While QRY->(! EOF())
	nCOnt += 1
	nValor += QRY->E2_VALOR
	FWrite(nHandle, LoteR())
	QRY->(DbSkip())
enddo
If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif
cQry := LanFOL()

TcQuery cQry New Alias "QRY"  

While QRY->(! EOF())
	nCOnt += 1
	nValor += QRY->RD_VALOR
	FWrite(nHandle, LoteRFun())
	QRY->(DbSkip())
enddo

FWrite(nHandle, Trailler(nCont, nValor))
FClose(nHandle)

return


static function RetHeader()
cHeader :="H"
cHeader += SubStr(MV_PAR02,1,10) // Inscrição Municipal
cHeader += SM0->M0_CGC // CNPJ
cHeader += Space(11) // espaço
cHeader += Alltrim(SM0->M0_NOMECOM)+Space(100 - len(alltrim(SM0->M0_NOMECOM))) // Razao Social
cHeader += MV_PAR03 // Tipo N- Normal T - TESTE
cHeader += strZero(month(MV_PAR01),2) // Mes
cHeader +=  cValtoChar(Year(MV_PAR01))  // Ano
cHeader +=  Space(252)  // Espaço
cHeader +=  '.' + chr(13) + chr(10) // ponto
Return cHeader

Static Function GeraPerg(cPerg) 
Local aRegs:= {}
aAdd(aRegs,{cPerg,"01","Data referencia"     ,"Data referencia"        ,"Data referencia"  ,"mv_ch1", 'D', 08, 0, 0, 'G', ''            , '', '', '', 'MV_PAR01'})
aAdd(aRegs,{cPerg,"02","Insc. Municipal"     ,"Insc. Municipal"        ,"Insc. Municipal"  ,"mv_ch2","C",10,0,0,"G","naovazio()","mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Tipo Arquivo"        ,"Tipo Arquivo"           ,"Tipo Arquivo"     ,"mv_ch3","C",01,0,0,"G"," ","mv_par03","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Caminho Arquivo"     ,"Caminho Arquivo"        ,"Caminho Arquivo"  ,"mv_ch4","C",60,0,0,"G"," ","mv_par04","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})

U_BuscaPerg(aRegs)

Return

Static function LoteR()
Local cLoteR :="R"//1
cLoteR += SubStr(QRY->E2_EMISSAO,7,2) + SubStr(QRY->E2_EMISSAO,5,2) + SubStr(QRY->E2_EMISSAO,1,4)//2
cLoteR += SubStr(QRY->E2_NUM,1,8) // 10
cLoteR += Replicate ("0", 8)//18
cLoteR += '1' // 26
cLoteR += Replicate ("0", 3) //27
cLoteR += Iif(QRY->A2_RECISS $"1S","S","N")//30
cLoteR += Iif("CURITIBA"$QRY->A2_MUN,"D","F")//31
cLoteR += Space(2)//32
cLoteR += Space(2)//34
cLoteR += StrZero(Val(StrTran(cValtoChar(QRY->E2_VALOR * 100),'.','')),15)//36
cLoteR += Replicate("0",15)//51
cLoteR += strzero(Iif("CURITIBA"$QRY->A2_MUN,VAL(QRY->A2_INSCRM),0),10) //66 tam 10
cLoteR += Iif(QRY->A2_TIPO$"J",Iif(Empty(QRY->A2_CGC),Replicate("0",14),QRY->A2_CGC),Replicate("0",14))//76
cLoteR += Iif(QRY->A2_TIPO$"F",Iif(Empty(QRY->A2_CGC),Replicate("0",11),QRY->A2_CGC),Replicate("0",11))//90
cLoteR += QRY->A2_NOME +Space(60) //101
cLoteR += 'RUA  ' //201
cLoteR += iif(Alltrim(Substr(QRY->A2_END, 1, At(" ", QRY->A2_END))) == 'RUA',Substr(QRY->A2_END, At(" ", QRY->A2_END), len(QRY->A2_END) )+Space(3), QRY->A2_END)+ space(10)//206
cLoteR += QRY->A2_NR_END //256
cLoteR += Space(20)//262
cLoteR += QRY->A2_BAIRRO + Space(30)//282
cLoteR += QRY->A2_MUN + Space(14) //332
cLoteR += QRY->A2_EST //349
cLoteR += Iif (Empty(QRY->A2_CEP),Replicate("0",8),QRY->A2_CEP)//378
cLoteR += Replicate("0",6)//386
cLoteR += Replicate("0",4)//392
cLoteR += "." + chr(13) + chr(10)
Return  cLoteR

Static function LoteRFun()

Local cLoteR :="R"//1
cLoteR += SubStr(QRY->RD_DATPGT,7,2) + SubStr(QRY->RD_DATPGT,5,2) + SubStr(QRY->RD_DATPGT,1,4)//2
cLoteR += PADL(QRY->RA_MAT,8,'0')//10
cLoteR += Replicate ("0", 8)//18
cLoteR += '1' //26
cLoteR += Replicate ("0", 3) //27
cLoteR += "N"//30
cLoteR += Iif("CURITIBA"$QRY->RA_MUNICIP,"D","F")//31
cLoteR += Space(2)//32
cLoteR += Space(2)//34
cLoteR += StrZero(Val(StrTran(cValtoChar(QRY->RD_VALOR * 100),'.','')),15)//36
cLoteR += Replicate("0",15)//51
cLoteR += PADL(QRY->RA_NUMINSC,10,'0') //66 tam 10
cLoteR += Replicate("0",14)//76
cLoteR += QRY->RA_CIC //90
cLoteR += QRY->RA_NOME +Space(70) //101
cLoteR += 'RUA  ' //201
cLoteR += iif(Alltrim(Substr(QRY->RA_ENDEREC, 1, At(" ", QRY->RA_ENDEREC))) == 'RUA',Substr(QRY->RA_ENDEREC, At(" ", QRY->RA_ENDEREC), len(QRY->RA_ENDEREC) )+Space(3), QRY->RA_ENDEREC)//206
cLoteR += SubStr(QRY->RA_LOGRNUM,1,6) //256
cLoteR += Space(20)//262
cLoteR += QRY->RA_BAIRRO + Space(35)//282
cLoteR += QRY->RA_MUNICIP + Space(14) //332
cLoteR += QRY->RA_ESTADO //349
cLoteR += Iif (Empty(QRY->RA_CEP),Replicate("0",8),QRY->RA_CEP)//378
cLoteR += Replicate("0",6)//386
cLoteR += Replicate("0",4)//392
cLoteR += "." + chr(13) + chr(10)
Return  cLoteR


static function Trailler(nCont,nValor)

cRet :="T"//1
cRet += StrZero(nCont,8)//2
cRet +=  Replicate("0",15)//10
cRet +=  Replicate("0",15)//25
cRet += StrZero(nValor * 100,15)//40
cRet +=  Replicate("0",15)//55
cRet += Space(326)
cRet += "." + chr(13) + chr(10)
Return cRet

/*
+--------------------------------------------------------------------------+
! Função    ! AtuTRBFol  ! Autor !Marcio A.Sugahara   ! Data ! 22/10/2015  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Seleciona os registros que serao processados.                !
!           ! Origem Folha.                                                !
+-----------+--------------------------------------------------------------+
*/
Static Function LanFOL()
Local cSql :=  ''
Local cRet := ''
Local nPos
Local nValCont := 0

// lancamentos da folha
cSql +=  " SELECT RA_MAT, RA_ALIQISS, RA_BAIRRO, RA_CEP, RA_CIC, RA_CODISS, RA_LOGRNUM, "
cSql +=  "        RA_COMPLEM, RA_CSTISS, RA_DDDFONE, RA_TELEFON, RA_ENDEREC, "
cSql +=  "        RA_LOGRNUM, RA_ESTADO, RA_MUNICIP, RA_NOME, RA_NUMINSC, RA_SERVICO, "
cSql +=  "        RA_SIAF, RD_DATPGT, RD_VALOR, RD_PD"
cSql +=  " FROM " + RetSqlName("SRA")+" SRA INNER JOIN "
cSql +=             RetSqlName("SRD")+" SRD ON "
cSql +=  "       SRD.RD_FILIAL = '"+xFilial("SRD")+"' AND "
cSql +=  "       SRD.RD_MAT = SRA.RA_MAT AND "
//cSql +=  "       (SRD.RD_PD = '489' OR "
cSql +=  "       SRD.RD_PD IN ("+cVerbaIss+")  AND "
cSql +=  "       SUBSTRING(SRD.RD_DATPGT,1,6) = '"+SUBSTR(DTOS(MV_PAR01),1,6)+"' AND"
cSql +=  "       SRD.D_E_L_E_T_ = ' ' "
cSql +=  " WHERE SRA.RA_FILIAL = '"+xFilial("SRA")+"' "
cSql += "      AND SRA.D_E_L_E_T_ = ' ' "
cSql += "      Order by RA_CIC "
return cSql
