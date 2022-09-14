#include 'protheus.ch'
#include 'topconn.CH'
#INCLUDE "RWMAKE.CH"
#include 'ap5mail.ch'
#include 'RPTDEF.CH'
#include 'FWPrintSetup.ch'
#INCLUDE "tbiconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PFINR03  บAutor ณ Microsiga Sofware   บ Data ณ  11/10/04   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ BOLETO BANCARIO ( Imprime o boleto bancario )              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PROJETO : P00016                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

aParametros[1]  //Do Prefixo        
aParametros[2]  //At o Prefixo
aParametros[3]  //Do Tกtulo
aParametros[4]  //At o Tกtulo
aParametros[5]  //Do Banco
aParametros[6]  //At o Banco
aParametros[7]  //Do Cliente
aParametros[8]  //At o Cliente
aParametros[9]  //Da Loja
aParametros[10] //At a Loja
aParametros[11] //Do Vencimento
aParametros[12] //At o Vencimento
aParametros[13] //Da Emisso
aParametros[14] //At a Emisso
aParametros[15] //Selecionar Tกtulos
aParametros[16] //Do Bordero
aParametros[17] //Ate o Bordero
aParametros[18]	//tipo de impressใo
aParametros[19]	//Do tipo de titulo
aParametros[20]	//ao tipo de titulo
aParametros[21]	//Tipo de Cobranca
aParametros[22] //Inibe Tela
aParametros[23]	// Banco para Transferencia do Titulo
aParametros[24] // Agencia para Transferencia do Titulo
aParametros[25]	// Conta para Transferencia do Titulo
*/

User Function BOLETOBB(_aTitulos1)
	Local cQuery	:= ''
	Local aArea 	:= GetArea()
	Local aAreaSE1	:= SE1->(GetArea())
	Local aAreaSX5	:= SX5->(GetArea())
	Local aAreaSM0	:= SM0->(GetArea())   //Adicionado Lucilene SMSTI - 06/04/2018
	Local oBcoOrig
	Local oCboBox
	Local aSituacoes:= {}
	Local cCapital  := Space(55)
	Local cMvBcoBol	:= Space(20)
	Local nI		:= 0
	Local nP		:= 0                            
	Local aSize     := MsAdvSize()
	Local aObjects  := {{30,30,.T.,.F.},{100,100,.T.,.t.}}     //,{100,015,.t.,.f.}
	Local aInfo     := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aPosObj   := MsObjSize(aInfo,aObjects)
	Local nSuperior := 20
	Local nEsquerda := aPosObj[2,2]
	Local nInferior := aPosObj[2,3] -15
	Local nDireita  := aPosObj[2,4]
	Local _oPnPesq
	Local _cHr		:=Chr(13)
	Private oMark
	//Variaveis de campos de Tela para manipulacao
	Private cBcoOrig := Space(3)
	Private cAgenOrig:= Space(TamSX3('A6_AGENCIA')[1]) //Space(5) A6_AGENCIA, A6_DVAGE, A6_NUMCON, A6_DVCTA
	Private cDVAgenOr:= Space(TamSX3('A6_DVAGE')[1])
	Private cCtaOrig := Space(TamSX3('A6_NUMCON')[1]) //Space(10)
	Private cDvCtaOr := Space(TamSX3('A6_DVCTA')[1]) //Space(10)
	Private cSituaca := Space(25)

	//Variaveis de controle do Cliente
	Private _cBcoCli := ''
	Private _cAgeCli := ''
	Private _cCtaCli := ''
	Private _cSitCli := ''
	Private _cTipSita:= Space(1)
	//Variaveis para armazenar a selecao do usuario
	Private _cBcoScr := ''
	Private _cAgeScr := ''
	Private _cCtaScr := ''
	Private _cSitScr := ''
	Private cNomeBco := Space(40)
	Private lExec    := .F.
	Private nQtdReg	 := 0
	Private cPerg    := PadR('ZZZ',10,Space(1))
	Private cArqTemp := Criatrab(Nil,.F.)
	Private aCpoBro  := {}
	Private lInverte := .T.
	Private cMarca   := GetMark()
	Private lEnd	 := .f.
	Private lPortador:= .f.
	Private lSituacao:= .f.
	Private lTpCaract:= .f.
	Private _Quebra  := Char(13) + Char(10)
	Private PrefFat  := 'FAT/F'
	Private _cChr13  := Chr(13)
	Private lInibeTela := .f.
	Private aParametros:= {}
	Private oCkMarca
	Private _lCkMarca		:=.F.
	Private lAdjustToLegacy := .T.
	// chamado Private lAdjustToLegacy:= .F.
	Private lDisableSetup  	:= .T.
	//Private cCaminho 		:= "\boleto\"
	Private cCaminho 		:= "c:\temp\"

	// Verificando se caminho existe
	if !existDir(cCaminho)
		if makeDir(cCaminho) <> 0
			msgStop("Caminho " + cCaminho + " nใo existe. Crie a pasta e tente novamente.")
			return nil
		endif
	endif
	/*
	//Verifica se o campo E1_NUMBCO esta com o tamanho correto.
	If TamSX3('E1_NUMBCO')[1] < 17
		Aviso('Aten็ใo','Altere o tamanho do campo E1_NUMBCO para 17 !',{'OK'},,'Tamanho Incorreto !')
		Return( Nil )
	EndIF
*/
	IF !Empty(_aTitulos1)
		aParametros:=_aTitulos1
	EndIf

	AjustaSx1(cPerg)

	If Len(aParametros) = 0
		If	( !Pergunte(cPerg,.T.) )

			Return( Nil )

		EndIf
	Else
		Pergunte(cPerg,.F.)
		//Carrega os parametros pelo array passado.
		mv_par01 	:= aParametros[1]               //Do Prefixo
		mv_par02 	:= aParametros[2]               //At o Prefixo
		mv_par03 	:= aParametros[3]               //Do Tกtulo
		mv_par04 	:= aParametros[4]               //At o Tกtulo
		mv_par05 	:= aParametros[5]               //Do Banco
		mv_par06 	:= aParametros[6]               //At o Banco
		mv_par07 	:= aParametros[7]               //Do Cliente
		mv_par08 	:= aParametros[8]               //At o Cliente
		mv_par09 	:= aParametros[9]               //Da Loja
		mv_par10 	:= aParametros[10]               //At a Loja
		mv_par11 	:= aParametros[11]               //Do Vencimento
		mv_par12 	:= aParametros[12]               //At o Vencimento
		mv_par13 	:= aParametros[13]               //Da Emisso
		mv_par14 	:= aParametros[14]               //At a Emisso
		mv_par15 	:= aParametros[15]               //Selecionar Tกtulos
		mv_par16 	:= aParametros[16]               //Do Bordero
		mv_par17 	:= aParametros[17]               //At o Bordero
		mv_par18 	:= aParametros[18]				 //tipo de impressใo
		mv_par19 	:= aParametros[19]				 //Do tipo de titulo
		mv_par20	:= aParametros[20]				 //ao tipo de titulo

		// aParametros[21]					//Tipo de Cobranca
		// aParametros[22]  					//Inibe Tela
		// aParametros[23]					// Banco para Transferencia do Titulo
		// aParametros[24]  					// Agencia para Transferencia do Titulo
		// aParametros[25]					// Conta para Transferencia do Titulo

		If Empty(aParametros[23]) //se o parametro banco estiver vazio, Seleciona o banco padrใo para emissใo.

			cMvBcoBol := GetNewPar('MV_BCOBOL','001')

			If Empty(cMvBcoBol)
				IW_MSGBOX('Banco padrใo para transfer๊ncia nใo informado! Verifique o Parโmetro MV_BCOBOL','Aten็ใo', "STOP")
				Return
			Else
				nP := 0
				For nI := 1 to Len(AllTrim(cMvBcoBol))
					if !(Substr(cMvBcoBol,nI,1) $ '/|#!')
						Do Case
							Case nP == 0
							cBcoOrig := AllTrim(cBcoOrig) + Substr(cMvBcoBol,nI,1)
							Case nP == 1
							cAgenOrig:= AllTrim(cAGenOrig) + Substr(cMvBcoBol,nI,1)
							Case nP == 2
							cCtaOrig := AllTrim(cCtaOrig) + Substr(cMvBcoBol,nI,1)
						EndCase
					Else
						nP++
					EndIf
				Next
			EndIf

			cQuery := "SELECT * "
			cQuery += "FROM "+ RetSQLName("SA6") + "  "
			cQuery += "WHERE  D_E_L_E_T_ != '*'   AND "
			cQuery += "A6_FILIAL='"+xFilial('SA6')+"'   AND "
			cQuery += "A6_COD = '" + AllTrim(cBcoOrig) + "' AND "
			cQuery += "A6_AGENCIA = '" + AllTrim(cAgenOrig) + "' AND "
			cQuery += "A6_NUMCON = '" + AllTrim(cCtaOrig) + "' "

			If Select("BCO") > 0
				DBSelectArea("BCO")
				BCO->(DbCloseArea())
			EndIf
			TCQUERY cQuery NEW ALIAS "BCO"

			DBSelectArea("BCO")
			DBGoTop()

			if Empty("BCO")
				IW_MSGBOX('Banco padrใo para transfer๊ncia nใo Localizado! Verifique o Parโmetro MV_BCOBOL','Aten็ใo', "STOP")
				Return
			EndIf

			BCO->(DbCloseArea())

			DbSelectArea("SX5")
			If (dbSeek(xFilial("SX5")+"07"+aParametros[21]))
				cSituaca:= aParametros[21]+' '+SX5->X5_DESCRI //Tipo de Cobran็a ( 1 ou 4 )
			Else
				IW_MSGBOX('Situacao para transferencia nao localizado, verifique o parametro MV_SITBOL','Aten็ใo', "STOP")
				Return
			EndIf

		Else
			cBcoOrig := aParametros[23]               //Banco de Transferencia
			cAGenOrig:= aParametros[24]               //AGencia de Transferencia
			cCtaOrig := aParametros[25]               //Conta de Transferencia

			DbSelectArea("SX5")
			If (dbSeek(xFilial("SX5")+"07"+aParametros[21]))
				cSituaca:= aParametros[21]+' '+SX5->X5_DESCRI //Tipo de Cobran็a ( 1 ou 4 )
			Else
				IW_MSGBOX('Situacao para transferencia nao localizado, verifique o parametro MV_SITBOL','Aten็ใo', "STOP")
				Return
			EndIf
		EndIf

		//Se nใo houver nenhum banco informado, nใo pode inibir a tela.
		If !Empty(cBcoOrig)
			lInibeTela := aParametros[22]
		Else
			lInibeTela := .F.
		EndIf

	EndIf

	//Verifico variaveis de Bco/AGe/Cta/Sit - caso seja o mesmo cliente.
	BcoClie(2)

	//Seta se vai trazer os titulos selecinados ou nao.
	lInverte := ( mv_par15 = 1 ) //Para Desabilitar o Parametro.

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta a tabela de situa็๖es de Tํtulos                                                                                                                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SX5")
	dbSeek(xFilial('SX5')+"07")
	While SX5->X5_FILIAL+SX5->X5_tabela == xFilial('SX5')+"07"

		If AllTrim(SX5->X5_CHAVE) $ GetNewPar('MV_CRTBOLE','1|4') + If(!Empty(cSituaca),'|'+cSituaca,'')   //Cobranca Simples e Cobranca Registrada
			cCapital := Capital(X5Descri())
			AADD( aSituacoes , SubStr(SX5->X5_CHAVE,1,2)+OemToAnsi(SubStr(cCapital,1,20)))
		EndIf

		dbSkip()
	EndDo

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCampos que serao mostrados no browse.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aCpoBro :=	{	{'E1_OK',,OemToAnsi(' '),' '},;
	{'E1_FILIAL',,OemToAnsi('Filial'),'@!'},;
	{'E1_PREFIXO',,OemToAnsi('Prefixo'),'@!'},;
	{'E1_NUM',,OemToAnsi('Numero'),'@!'},;
	{'E1_NUMBOR',,OemToAnsi('Num. Bordero'),'@!'},;
	{'E1_PARCELA',,OemToAnsi('Parcela'),'@!'},;
	{'E1_TIPO',,OemToAnsi('Tipo'),'@!'},;
	{'A1_COD',,OemToAnsi('Cliente'),'@!'},;
	{'A1_LOJA',,OemToAnsi('Loja'),'@!'},;
	{'A1_NOME',,OemToAnsi('Nome'),'@!'},;
	{'E1_NUMBCO',,OemToAnsi('Num. Banco'),'@!'},;
	{'E1_PORTADO',,OemToAnsi('Portador'),'@!'},;
	{'E1_AGEDEP',,OemToAnsi('Ag. Dep.'),'@!'},;
	{'E1_CONTA',,OemToAnsi('Conta'),'@!'},;
	{'E1_FATURA',,OemToAnsi('Fatura'),'@!'}	}
	//{'E1_DOCFECH',,OemToAnsi('Doc.Fech'),'@!'}	}
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMonta a query com os registros a serem marcados.!ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery	:= "SELECT SE1.E1_OK, "+_cHr
	cQuery	+= "SE1.E1_FILIAL, "+_cHr
	cQuery	+= "SE1.E1_PREFIXO, "+_cHr
	cQuery	+= "SE1.E1_NUM, "+_cHr
	cQuery	+= "SE1.E1_NUMBOR, "+_cHr
	cQuery	+= "SE1.E1_PARCELA, "+_cHr
	cQuery	+= "SE1.E1_TIPO, "+_cHr
	cQuery	+= "SA1.A1_COD, "+_cHr
	cQuery	+= "SA1.A1_LOJA, "+_cHr
	cQuery	+= "SA1.A1_NOME, "+_cHr
	cQuery	+= "SE1.E1_NUMBCO, "+_cHr
	cQuery	+= "SE1.E1_PORTADO, "+_cHr
	cQuery	+= "SE1.E1_AGEDEP, "+_cHr
	cQuery	+= "SE1.E1_CONTA, "+_cHr
	cQuery	+= "SA1.A1_INSCR, "+_cHr
	cQuery	+= "SA1.A1_CGC, "+_cHr
	cQuery	+= "E1_FATURA "+_cHr
	cQuery	+= "FROM " + RetSqlName('SE1') + ' SE1, ' + RetSqlName('SA1') + ' SA1 '+_cHr
	cQuery	+= "WHERE SA1.A1_COD =  SE1.E1_CLIENTE "+_cHr
	cQuery	+= "AND SA1.A1_LOJA = SE1.E1_LOJA "+_cHr
	//cQuery	+= "AND SE1.E1_FILIAL = '" + xFilial('SE1') + "' "+_cHr
	cQuery	+= "AND SE1.E1_EMISSAO >= '" + Dtos(mv_par13) + "' "+_cHr
	cQuery	+= "AND SE1.E1_EMISSAO <= '" + Dtos(mv_par14) + "' "+_cHr
	cQuery	+= "AND SE1.E1_PREFIXO >= '" + mv_par01 + "' "+_cHr
	cQuery	+= "AND SE1.E1_PREFIXO <= '" + mv_par02 + "' "+_cHr
	cQuery	+= "AND SE1.E1_NUM >= '" + mv_par03 + "' "+_cHr
	cQuery	+= "AND SE1.E1_NUM <= '" + mv_par04 + "' "+_cHr
	cQuery	+= "AND SE1.E1_NUMBOR >= '" + mv_par16 + "' "+_cHr
	cQuery	+= "AND SE1.E1_NUMBOR <= '" + mv_par17 + "' "+_cHr
	cQuery	+= "AND SE1.E1_PORTADO >= '" + mv_par05 + "' "+_cHr
	cQuery	+= "AND SE1.E1_PORTADO <= '" + mv_par06 + "' "+_cHr
	cQuery	+= "AND SE1.E1_CLIENTE >= '" + mv_par07 + "' "+_cHr
	cQuery	+= "AND SE1.E1_CLIENTE <= '" + mv_par08 + "' "+_cHr
	cQuery	+= "AND SE1.E1_LOJA >= '" + mv_par09 + "' "+_cHr
	cQuery	+= "AND SE1.E1_LOJA <= '" + mv_par10 + "' "+_cHr
	cQuery	+= "AND SE1.E1_VENCTO >= '" + Dtos(mv_par11) + "' "+_cHr
	cQuery	+= "AND SE1.E1_VENCTO <= '" + Dtos(mv_par12) + "' "+_cHr
	//cQuery	+= "AND SE1.E1_TIPO >= '" + mv_par19 + "' "
	//cQuery	+= "AND SE1.E1_TIPO <= '" + mv_par20 + "' "
	cQuery	+= "AND SE1.E1_TIPO NOT IN ('NCC','RA ') "+_cHr
	cQuery	+= "AND SE1.E1_SALDO > 0 "+_cHr
	cQuery	+= "AND SE1.D_E_L_E_T_ <> '*' "+_cHr
	cQuery	+= "AND SA1.A1_FILIAL = '" + xFilial('SA1') + "' "+_cHr
	cQuery	+= "AND SA1.D_E_L_E_T_ <> '*' "+_cHr
	cQuery  += "AND SE1.E1_SITUACA NOT IN ('2','7') "+_cHr
	cQuery	+= "ORDER BY SA1.A1_FILIAL, SA1.A1_NOME, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO "+_cHr
	If (__cUserId $ "000203")
		MemoWrit('C:\TEMP\Boleto.txt',cQuery)
	EndIf
	cQuery	:= ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TRA',.F.,.T.)

	DbSelectArea('TRA')
	Count to nQtdReg
	TRA->(DbGoTop())

	Copy to &cArqTemp

	TRA->(DbCloseArea())

	DbUseArea(.t.,,cArqTemp,'TRA',Nil,.f.)
	TRA->(DbGoTop())

	If ! lInibeTela
		Define Dialog oDlg TITLE OemToAnsi('Sele็ใo dos Tํtulos para impressใo dos Boletos.') From aSize[7],0 to aSize[6],aSize[5] style nOR(WS_VISIBLE, WS_POPUP) Pixel
		_oPnPesq := TPanel():New(aPosObj[1,2],aPosObj[1,2],'',oDlg,, .T., .T.,, ,aPosObj[1,4],aPosObj[1,3],.T.,.T. )
		oMark:=MsSelect():New('TRA','E1_OK',,aCpoBro,@lInverte,@cMarca,{aPosObj[2,1]+5,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]})
		oMark:bAval:={|x| x:= GetFocus(), SelecTit() , SetFocus(x) }
		oMark:oBrowse:Refresh()

		@ 005, 010 SAY 'Banco/Ag๊ncia/Conta para transfer๊ncia' OF _oPnPesq PIXEL
		@ 005, 185 SAY 'Situa็ใo' OF _oPnPesq    PIXEL
		@ 005, 280 SAY 'Caracterํstica' OF _oPnPesq PIXEL
		@ 020, 010 MSGET oBcoOrig VAR cBcoOrig   Picture "@S3"  F3 "SA6" WHEN !(!Empty(cBcoOrig) .And. (MV_PAR07 == MV_PAR08)) Valid {|| CarregaSa6(@cBcoOrig,@cAgenOrig,@cCtaOrig,.F.,,.F.), cNomeBco := If( AllTrim(cBcoOrig) <> '', Posicione('SA6',1,xFilial('SA6')+cBcoOrig+cAgenOrig+cCtaOrig,'A6_NOME') , '' ) }  SIZE 25, 08 OF _oPnPesq PIXEL
		@ 020, 039 MSGET cAgenOrig               Picture "@S5"           WHEN .F. Valid {|| CarregaSa6(@cBcoOrig,@cAgenOrig,@cCtaOrig,.F.,,.T.),.F.}                          SIZE 20, 08 OF _oPnPesq PIXEL
		@ 020, 068 MSGET cCtaOrig                Picture "@S10"          WHEN .F. Valid {|| If(CarregaSa6(@cBcoOrig,@cAgenOrig,@cCtaOrig,.F.,,.T.),.T.,oBcoOrig:SetFocus()),.F.} SIZE 45, 08 OF _oPnPesq PIXEL
		@ 020, 113 MSGET cNomeBco                WHEN {|| cNomeBco := If( AllTrim(cBcoOrig) <> '', Posicione('SA6',1,xFilial('SA6')+cBcoOrig+cAgenOrig+cCtaOrig,'A6_NOME') , cNomeBco ), .F. } SIZE 70,08 OF _oPnPesq PIXEL
		@ 020, 185 COMBOBOX oCboBox VAR cSituaca ITEMS aSituacoes WHEN IF( Len(aParametros) >= 18 , AllTrim(aParametros[18])=='' , !(!Empty(cSituaca) .And. (MV_PAR07 == MV_PAR08)) ) Size 82,46 OF _oPnPesq PIXEL
		//@ 020, 280 MSGET _cTipSita                 SIZE 25, 08 OF _oPnPesq PIXEL
		@ 020, 280 MSGET _cTipSita               WHEN {|| _cTipSita := If( AllTrim(cBcoOrig) <> '', Posicione('SA6',1,xFilial('SA6')+cBcoOrig+cAgenOrig+cCtaOrig,'A6_CARACT') , _cTipSita ), .F. }  SIZE 25, 08 OF _oPnPesq PIXEL
		//@ 035, 010 CheckBox oCkMarca Var _lCkMarca Prompt "Marca Todos os Titilos Vinculado ao Banco Selecioando ?" Size 150, 10 PIXEL OF _oPnPesq ON CHANGE SelecTod()
		oCboBox:nAt := 1

		DEFINE SBUTTON FROM 023, 320 TYPE 01 ACTION (IIf(TudoOK(oDlg),(lExec:=.T.,oDlg:End()),lExec:=.F.)) ENABLE Of oDlg
		DEFINE SBUTTON FROM 023, 350 TYPE 02 ACTION (FERASE(cArqTemp  + GetDBExtension()),oDlg:End()) ENABLE Of oDlg

		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		lExec := .T.
	EndIf

	TRA->(DbGoTop())

	If	lExec
		Processa({ |lEnd| MontaRelx()})
	EndIf

	TRA->(DbCloseArea())

	RetIndex("SE1")
	Ferase(cArqTemp+GetDbExtension())

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRetoma a area anterior ao processamento. !ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RestArea(aAreaSM0) //Adicionado Lucilene SMSTI - 06/04/2018
	RestArea(aAreaSX5)
	RestArea(aAreaSE1)
	RestArea(aArea)

Return( Nil )


Static Function SelecTit()
	Local _lRet	:= .T.
	Local _aArea	:= GetArea()

	IF TRA->(Marked('E1_OK'))
		RecLock("TRA",.F.)
		Replace TRA->E1_OK With "  "
		TRA->(MsUnlock())
		RestArea(_aArea)
		Return(_lRet)
	EndIf

	//Validacao para Nใo permitir a emissao de Boleto do Bradesco na conta antiga.

	If Empty(TRA->E1_NUMBCO)
		If (cBcoOrig='237') .AND. (cCtaOrig<>'1500-8')
			MsgInfo(cUserName+Chr(13)+" A Conta "+cCtaOrig+" Esta desativada."+chr(13)+chr(13)+"Favor informar o Departamento Financeiro" )
			_lRet:=.F.
		EndIf
	EndIf



	If _lRet
		RecLock("TRA",.F.)
		Replace TRA->E1_OK With cMarca
		TRA->(MsUnlock())
	Endif

	RestArea(_aArea)
Return(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MONTARELx บAutor ณ JULIO STORINO       บ Data ณ  15/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MontaRelx()

	Local	oPrint
	Local	nX			:= 0
	Local	cNroDoc 	:= ''
	Local	cConvenio	:= ''
	Local	cSeqCart	:= ''
	Local	cCarteira	:= ''
	Local	cCompCart   := ''
	Local	cDigCta     := ''
	Local	nI          := 1
	Local	aCB_RN_NN   := {}
	Local	nVlrAbat	:= 0
	Local	cQuery      := ''
	Local	cSituant    := ''
	Local cMemoTit    	:= ''

	Private	aDadosFat	:= {}	// Dados da Fatura
	Private	aDadosEmp	:= {}
	Private	aDadosTit	:= {}
	Private	aDadosBanco := {}
	Private	aDatSacado  := {}
	Private	aDadosBol   := {}
	Private	aBolText    := {}
    

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicia o processo de impressao dos boletos. !ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (Len(aParametros) = 0) .OR. (Len(aParametros) <> 0 .AND. (GetNewPar('MV_IMPBOL',1) <> 3))
		//	oPrint := TMSPrinter():New('Impressใo de Boleto Bancแrio')
		//	oPrint:SetPortrait() // ou SetLandscape()
		//			oPrint:Setup()
		//	oPrint:StartPage()   // Inicia uma nova pแgina
	EndIF

	TRA->(DbGoTop())
	ProcRegua(nQtdReg)

	While	TRA->( ! Eof() )

		If	( lEnd )
			If	MsgYesNo(OemToAnsi('Deseja abortar impressใo ?'))
				Exit
				Return
			EndIf
		EndIf

		If	TRA->(Marked('E1_OK')) 
		
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPosiciona no titulo que sera processado.!ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DbSelectArea('SE1')
			SE1->(DbSetOrder(1))
			If	! SE1->(DbSeek(TRA->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
//			If	! SE1->(DbSeek(xFilial('SE1') + TRA->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
				TRA->(DbSkip())
				Loop
			EndIf
             
			//Adicionado Lucilene SMSTI - 06/04/2018
			//Posiciona na filial do tํtulo
			SM0->(dbSeek(cEmpAnt+SE1->E1_FILIAL))
			
			aDadosEmp:= {SM0->M0_NOMECOM,; //[1]Nome da Empresa    
				SM0->M0_ENDCOB,; //[2]Endere็o
				AllTrim(SM0->M0_BAIRCOB)+', '+AllTrim(SM0->M0_CIDCOB)+', '+SM0->M0_ESTCOB ,; //[3]Complemento
				'CEP: '+Subs(SM0->M0_CEPCOB,1,5)+'-'+Subs(SM0->M0_CEPCOB,6,3),; //[4]CEP
				'PABX/FAX: '+SM0->M0_TEL,; //[5]Telefones
				'CNPJ: '+Subs(SM0->M0_CGC,1,2)+'.'+Subs(SM0->M0_CGC,3,3)+'.'+; //[6]
				Subs(SM0->M0_CGC,6,3)+'/'+Subs(SM0->M0_CGC,9,4)+'-'+; //[6]
				Subs(SM0->M0_CGC,13,2),; //[6]CGC
				'I.E.: '+Subs(SM0->M0_INSC,1,3)+'.'+Subs(SM0->M0_INSC,4,3)+'.'+; //[7]
				Subs(SM0->M0_INSC,7,3)+'.'+Subs(SM0->M0_INSC,10,3)}  //[7]I.E

			If SE1->E1_PORTADOR = '001'
				RecLock('SE1',.f.)
				Replace SE1->E1_NUMBCO With ''
				SE1->(MsUnlock())
			Endif

			//Se o cliente for internacional, ou existe a nota de fechamento ou adicione qq coisa para nใo imprimir
			//as notas originais da fatura. Se cliente nacional nใo fa็o nada.
			/*		If Posicione('SA1',1,xFilial('SA1')+SE1->E1_CLIENTE+E1_LOJA,'A1_SOFT') == '2'
			cMemoTit := If(Empty(SE1->E1_DOCFECH),'--',SE1->E1_DOCFECH)
			EndIF */

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica se o cliente possui banco/agencia/Conta definido no Cadastro, prevalece sobre a selecao ณ
			//ณSolicito em 18/03/2010 - Valquiria - Desenvolvido por Julio Storino							          ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			// O Parametro MV_FORCBOL e do tipo booleanto (.t. ou .f.) e define se, independente do banco/age/cta/situacao
			// selecionado na tela de impressao do boleto, verifica se o cliente possui um bco/age/cta/situacao definido em
			// seu cadastso, pegando de la as informacoes para geracao do boleto. Este parametro so fara sentido se os clientes
			// De / Ate forem diferentes, pois se forem iguais e existir informacoes no cliente, a tela ja vira preenchida
			// com os dados deste cliente, sem opcao de mudar.
			// .t. - sempre verifica independente do que esteja setado na tela (quando cliente De/Ate forem diferentes)
			// .f. - nao verifica e prevalece o que esta definido na tela. (quando cliente De/Ate forem diferentes)
			If GetNewPar('MV_FORCBOL',.F.)
				BcoClie(1,SE1->E1_CLIENTE,SE1->E1_LOJA)
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica a carteira do titulo !ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If	'001' == IIF( Empty(SE1->E1_PORTADOR) .or. ( (SE1->E1_PORTADOR <> cBcoOrig) .and. !Empty(cBcoOrig) ), cBcoOrig, SE1->E1_PORTADOR )
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณBANCO DO BRASILณ
				//ณ 17- REGISTRADOณ
				//ณ 18- SIMPLES   ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cCarteira	:= '101'

			ElseIf	'033' == IIF( Empty(SE1->E1_PORTADOR) .or. ( (SE1->E1_PORTADOR <> cBcoOrig) .and. !Empty(cBcoOrig) ), cBcoOrig, SE1->E1_PORTADOR )

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณBANCO DO SANTANDERณ
				//ณ ??- REGISTRADOณ
				//ณ ??- SIMPLES   ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cCarteira	:= '101' //IIF( (IIF( Empty(SE1->E1_SITUAC2) .or. ( (SE1->E1_SITUAC2 <> Substr(cSituaca,1,1)) .and. !Empty(cSituaca) ), Substr(cSituaca,1,1), SE1->E1_SITUAC2 )) == '1','18','101')

			ElseIf	'237' == IIF( Empty(SE1->E1_PORTADOR) .or. ( (SE1->E1_PORTADOR <> cBcoOrig) .and. !Empty(cBcoOrig) ), cBcoOrig, SE1->E1_PORTADOR )
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณBANCO BRADESCO   ณ
				//ณ 06 - SIMPLES    ณ
				//ณ 09 - REGISTRADO ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cCarteira	:= '101'
			ElseIf	'341' == IIF( Empty(SE1->E1_PORTADOR) .or. ( (SE1->E1_PORTADOR <> cBcoOrig) .and. !Empty(cBcoOrig) ), cBcoOrig, SE1->E1_PORTADOR )
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณBANCO ITAU       ณ
				//ณ175 - SIMPLES    ณ
				//ณ109 - REGISTRADO ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cCarteira	:= '109'//Iif( (IIF( Empty(SE1->E1_SITUAC2) .or. ( (SE1->E1_SITUAC2 <> Substr(cSituaca,1,1)) .and. !Empty(cSituaca) ), Substr(cSituaca,1,1), SE1->E1_SITUAC2 )) == '1','175','109')
			ElseIf	'356' == IIF( Empty(SE1->E1_PORTADOR) .or. ( (SE1->E1_PORTADOR <> cBcoOrig) .and. !Empty(cBcoOrig) ), cBcoOrig, SE1->E1_PORTADOR )
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณBANCO REAL       ณ
				//ณ 20 - SIMPLES    ณ
				//ณ    - REGISTRADO ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cCarteira	:= '101'
			ElseIf	'399' == IIF( Empty(SE1->E1_PORTADOR) .or. ( (SE1->E1_PORTADOR <> cBcoOrig) .and. !Empty(cBcoOrig) ), cBcoOrig, SE1->E1_PORTADOR )
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณBANCO HSBC        ณ
				//ณ CNR- CNR NORMAL  ณ
				//ณ CNR- CNR SIMPLES ณ
				//ณ    - REGISTRADO  ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cCarteira	:= '101'
			ElseIf '748' == IIF( Empty(SE1->E1_PORTADOR) .or. ( (SE1->E1_PORTADOR <> cBcoOrig) .and. !Empty(cBcoOrig) ), cBcoOrig, SE1->E1_PORTADOR )
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณBANCO SICREDI    ณ
				//ณ 1  - SIMPLES    ณ
				//ณ 1  - REGISTRADO ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณPARAMETROS BANCARIOS                                               ณ
				//ณ 1  - SIMPLES    ณ No Banco            999      (EE_CODIGO)        |
				//ณ                 ณ Agencia             9999     (EE_AGENCIA)       |
				//ณ                 ณ Conta               99999-9  (EE_CONTA          |
				//ณ                 ณ Sub Cta             9        (EE_SUBCTA)        |
				//ณ                 ณ Cod Cedente         99999    (EE_CODEMP)        |
				//ณ                 ณ Cod Cob Eletronica  99       (EE_CODCOBE)       |
				//ณ 1 - REGISTRADA  ณ ** IDEM ITENS ACIMA **                          |
				//ณ                 ณ    o que muda da simples para registrada e      |
				//ณ                 ณ    o fato de enviar o arquivo de remessa.       |
				//ณ                 ณ                                                 |
				//ณ                 ณ                                                 |
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

				cCarteira	:= '101'
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPosiciona na Arq de Parametros CNAB para ver se hแ informacoes      ณ
			// Verifica se o Tํtulo jแ tem portador, senใo pega o da transferencia.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DbSelectArea('SEE')
			SEE->(DbSetOrder(1))

			If Empty(SE1->E1_PORTADOR) .or. ( (SE1->E1_PORTADOR <> cBcoOrig) .and. !Empty(cBcoOrig) )
				IF !SEE->(DbSeek(xFilial('SEE')+SE1->(cBcoOrig+cAgenOrig+Padr(cCtaOrig,10,space(1))+padr(cCarteira,3,space(1))),.T.))
					IW_MSGBOX('Aten็ใo, Bco/Ag/Cta [' + cBcoOrig + '/' + cAgenOrig +'/' + AllTrim(cCtaOrig) + '], da carteira ['+ cCarteira + '] Nใo possui parโmetros cadastrados !, Favor Veriricar!','Aten็ใo', "STOP")
					Return( Nil )
				EndIf
			Else
				IF !SEE->(DbSeek(xFilial('SEE')+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA+padr(cCarteira,3,space(1))),.T.))
					IW_MSGBOX('Aten็ใo, Bco/Ag/Cta [' + SE1->E1_PORTADOR + '/' + SE1->E1_AGEDEP +'/' + AllTrim(SE1->E1_CONTA) + '], da carteira ['+ cCarteira + '] Nใo possui parโmetros cadastrados !, Favor Veriricar!','Aten็ใo', "STOP")
					Return( Nil )
				EndIf
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica Faixa Inicial e Final de Impressใo           ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If (VAL(SEE->EE_FAXATU) < VAL(SEE->EE_FAXINI)) .OR. (VAL(SEE->EE_FAXATU) > VAL(SEE->EE_FAXFIM))
				IW_MSGBOX('Aten็ใo, Bco/Ag/Cta [' + SE1->E1_PORTADOR + '/' + SE1->E1_AGEDEP +'/' + AllTrim(SE1->E1_CONTA) + '], da carteira ['+ cCarteira + '] esgotou a faixa de impressใo!, Favor Veriricar!','Aten็ใo', "STOP")
				Exit
				Return
			EndIf


			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณTransfere o titulo para o portador informado caso sejaณ
			//ณnecessแrio.                                           ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If Empty(SE1->E1_PORTADOR) //.or. ( (SE1->E1_PORTADOR <> cBcoOrig) .and. !Empty(cBcoOrig) )
				cSituant := '101'
				RecLock('SE1',.f.)

				Replace SE1->E1_PORTADO With cBcoOrig
				Replace SE1->E1_AGEDEP  With cAgenOrig
				Replace SE1->E1_CONTA   With cCtaOrig

				//Limpa o Campo E1_NUMBCO pois tem que pegar nova numera็ใo
				Replace SE1->E1_NUMBCO With ''

				
				

				//Criar um parโmetro para definir esta regra, jแ transfere a situacao do titulo para simples quanto for
				//este tipo de cobranca, ou deixa no 0-carteira e usa-se o bordero tamb้m para titulos simpes.
				If (GetNewPar('MV_TRFCART',.F.)) .And. (SE1->E1_SITUACA <> Substr(cSituaca,1,1)) .AND. (Substr(cSituaca,1,1) == '1')
					Replace SE1->E1_SITUACA With '1'
				EndIf


				SE1->(MsUnlock())

				//Retirado pro Maia em 27/12/2014/  O Sistema esta gerando no momento do Inclusใo do Bordero
				/*

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณGrava a transferencia do titulo na tabela de titulos  ณ
				//ณenviados ao banco (                                   ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If RecLock('SEA',.T.)
				//Replace SEA->EA_NUMBOR  With STRTRAN( TIME() , ':', '' )
				Replace SEA->EA_FILIAL  With xFilial('SEA')
				Replace SEA->EA_FILORIG With cFilAnt
				Replace SEA->EA_PREFIXO With SE1->E1_PREFIXO
				Replace SEA->EA_NUM     With SE1->E1_NUM
				Replace SEA->EA_PARCELA With SE1->E1_PARCELA
				Replace SEA->EA_PORTADO With SE1->E1_PORTADO
				Replace SEA->EA_AGEDEP  With SE1->E1_AGEDEP
				Replace SEA->EA_TIPO    With SE1->E1_TIPO
				Replace SEA->EA_CART    With 'R'
				Replace SEA->EA_NUMCON  With SE1->E1_CONTA
				Replace SEA->EA_SITUACA With SE1->E1_SITUACA
				Replace SEA->EA_SITUANT With cSituant
				Replace SEA->EA_FORNECE With SE1->E1_CLIENTE
				Replace SEA->EA_LOJA 	With SE1->E1_LOJA

				SEA->(MsUnlock())
				Else
				If (Len(aParametros) = 0)
				Alert(OemToAnsi('Nใo foi possํvel gravar a transfer๊ncia do tํtulo, mas o processo continuarแ !'))
				Else
				ConOut(OemToAnsi('Nใo foi possํvel gravar a transfer๊ncia do tํtulo, mas o processo continuarแ !'))
				EndIf
				EndIf
				*/
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica se o sistema esta preparado ou nao para imprimirณ
			//ณdependendo do portador...                                ณ
			//ณEste RdMake Imprime boletos dos seguintes banco...       ณ
			//ณ Brasil, Bradesco, Itau, Real, HSBC, Sicredi             ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If	( ! SE1->E1_PORTADO $ '001/033/237/341/356/399/748' ) //.or. ( ! SE1->E1_SITUAC2 $ '14' )
				If (Len(aParametros) = 0)
					Alert(OemToAnsi('O Titulo: '+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+', nใo estแ preparado para impressใo. Verifique o Portador do titulo.'))
				Else
					ConOut(OemToAnsi('O Titulo: '+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+', nใo estแ preparado para impressใo. Verifique o Portador do titulo.'))
				EndIf
				TRA->(DbSkip())
				Loop
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPosiciona o SA6 (Bancos)ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DbSelectArea('SA6')
			SA6->(DbSetOrder(1))
			SA6->(DbSeek(xFilial('SA6') + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA,.T.))

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPosiciona na Arq de Parametros CNABณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DbSelectArea('SEE')
			SEE->(DbSetOrder(1))
			SEE->(DbSeek(xFilial('SEE')+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA+cCarteira),.T.))

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
			//Se a Faixa Inicial for Zero ou vazia, entao passo para 1.
			//ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
			If !Empty(SEE->EE_FAXATU)
				If Val(SEE->EE_FAXATU) = 0
					RecLock('SEE',.F.)
					SEE->EE_FAXATU := StrZero(1,12)
					MsUnlock()
				EndIf
			ElseIf SEE->EE_CODIGO = '341'
				RecLock('SEE',.F.)
				SEE->EE_FAXATU := StrZero(1,8)
				MsUnlock()
			Else
				RecLock('SEE',.F.)
				SEE->EE_FAXATU := StrZero(1,12)
				MsUnlock()
			EndIF


			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAqui defino parte do nosso numero.                                          ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If	( Empty(SE1->E1_NUMBCO) )

				Do Case
					Case SEE->EE_CODIGO = '001'
						cConvenio := AllTrim(SEE->EE_CODEMP)
						cSeqCart	 := StrZero(Val(SEE->EE_FAXATU),10)
					Case SEE->EE_CODIGO = '033'
						cConvenio := AllTrim(SEE->EE_CODEMP)
						cSeqCart	 := StrZero(Val(SEE->EE_FAXATU),12)
					Case SEE->EE_CODIGO = '237'
						cSeqCart	 := StrZero(Val(SEE->EE_FAXATU),11)
					Case SEE->EE_CODIGO = '341'
						cConvenio := AllTrim(SEE->EE_SUBCTA)
						cSeqCart	 := Substr(SEE->EE_FAXATU,5)// StrZero(Val(SEE->EE_FAXATU),8)
						
					Case SEE->EE_CODIGO = '356'
						cSeqCart	 := StrZero(Val(SEE->EE_FAXATU),12)
					Case SEE->EE_CODIGO = '399'
						cSeqCart	 := StrZero(Val(SEE->EE_FAXATU),12)
					Case SEE->EE_CODIGO = '748'
						cSeqCart	 := StrZero(Val(SEE->EE_FAXATU),5)
				EndCase

				//Se Tiver que usar alguma informa็ใo a mais para compor o NossoNumero
				//pode ser feito neste momento, antes de passar para a composicao do c๓digo de barras
				//que ira calcular nosso numero final, barras e linha digitแvel
				Do Case
					Case SEE->EE_CODIGO $ '001'  //BRASIL BRADESCO ITAU
					Do Case
						Case Len(cConvenio) = 6
						cNroDoc		:= alltrim(cConvenio + StrZero(Val(cSeqCart),5))
						Case Len(cConvenio) = 7
						cNroDoc		:= cConvenio + StrZero(Val(cSeqCart),10)
					EndCase
					Case SEE->EE_CODIGO = '341'  //ITAU
				//	cNroDoc		:= cConvenio + StrZero(Val(Substr(cSeqCart,8,6)),11-Len(cConvenio))
				//	cNroDoc		:= cConvenio + StrZero(Val(cSeqCart),11-Len(cConvenio))
					cNroDoc		:= StrZero(Val(cSeqCart),8)
					Case SEE->EE_CODIGO = '356'   //REAL
					cNroDoc		:= StrZero(Val(Substr(cSeqCart,8,6)),7)
					OtherWise   //'237/399/748' HSBC - SICREDI
					cNroDoc		:= cSeqCart
				EndCase

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAtualiza a tabela com o numero do proximo boleto. !ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If RecLock('SEE',.F.)
					Replace SEE->EE_FAXATU With Soma1( SEE->EE_FAXATU )
					MsUnLock()
				Else
					Help('',1,'REGNOIS')
				EndIf

			Else
				cNroDoc		:= SE1->E1_NUMBCO
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe for banco do brasil, apos a carteira vai um complementoณ
			//ณex: 17-019.                                               ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If SA6->A6_COD = '001'
				cCompCart := '-019'
			Else
				cCompCart := ''
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe for banco Real o digito da conta e um calculo usando   ณ
			//ณmodulo 10 composto de agencia+conta+nosso_numero          ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If SA6->A6_COD = '356'
				cDigCta := U_DIGIT001( cNroDoc + SubStr(SA6->A6_AGENCIA,1,4) + StrZero(Val( SubStr(SA6->A6_NUMCON,1,If(At('-',SA6->A6_NUMCON) # 0,At('-',SA6->A6_NUMCON)-1,Len(AllTrim(SA6->A6_NUMCON))-1)) ),7) )
			Else
				cDigCta := SubStr(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1)
			EndIf

			// [1] Numero do Banco
			// [2] Nome do Banco
			// [3] Agencia
			// [4] Conta Corrente
			// [5] Digito da conta corrente
			// [6] Codigo da Carteira
			// [7] Logotipo do banco
			// [8] C๓digo da Empresa dos Parโmetros Bancแrios
			// [9] C๓digo da Cobran็a Eletr๔nica dos Parโmetros Bancแrios

			If SA6->A6_COD = '341'
				aDadosBanco  := {	SA6->A6_COD,;
				SA6->A6_NREDUZ,;
				SubStr(SA6->A6_AGENCIA,1,4),;
				SubStr(SA6->A6_NUMCON,1,5),;
				SA6->A6_DVCTA,;
				cCarteira+cCompCart,;
				AllTrim(SA6->A6_NREDUZ)+'.BMP',;
				AllTrim(SEE->EE_CODEMP),;
				AllTrim(SEE->EE_CODCOBE)}
			
			Else
				aDadosBanco  := {	SA6->A6_COD,;
				SA6->A6_NREDUZ,;
				SubStr(SA6->A6_AGENCIA,1,4),;
				SubStr(SA6->A6_NUMCON,1,If(At('-',SA6->A6_NUMCON) # 0,At('-',SA6->A6_NUMCON)-1,Len(AllTrim(SA6->A6_NUMCON))-1)),;
				cDigCta,;
				cCarteira+cCompCart,;
				AllTrim(SA6->A6_NREDUZ)+'.BMP',;
				AllTrim(SEE->EE_CODEMP),;
				AllTrim(SEE->EE_CODCOBE)}
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPosiciona o SA1 (Cliente)ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DbSelectArea('SA1')
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial('SA1')+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.))


			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณColeta dos dados a serem impressos no boleto -linhasณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aAdd( aDadosBol ,GetNewPar('MV_MULTBOL',10) )//If(Empty(SEE->EE_MULTBOL),GetNewPar('MV_MULTBOL',10),SEE->EE_MULTBOL) )
			aAdd( aDadosBol ,SE1->E1_PORCJUR)//If(Empty(SEE->EE_TXPER)  ,SE1->E1_PORCJUR,SEE->EE_TXPER  ) )
			GetNewPar('MV_TXPER',0.1)
			/*
			Do Case
			Case SEE->EE_PROTEST = '1'		//Cadastro de Cliente
			Do Case
			Case SA1->A1_PROTEST $ '3456'
			aAdd( aDadosBol, 'Protesto com ' +SA1->A1_PROTEST+ ' dia util ap๓s o vencimento.' )
			OtherWise
			aAdd( aDadosBol, '' )
			EndCase
			Case SEE->EE_PROTEST = '2'		//Parametros do Banco
			aAdd( aDadosBol, SEE->EE_MSGPROT )
			OtherWise							//Nใo Protestar
			aAdd( aDadosBol, '' )
			EndCase  */
			aAdd( aDadosBol , '' )
			aAdd( aDadosBol , '' )
			aAdd( aDadosBol , '' )
			aAdd( aDadosBol , '' )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณDados do SA1 (Cliente)ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			// [1] Razao Social
			// [2] Codigo
			// [3] Endere็o
			// [4] Cidade
			// [5] Estado
			// [6] CEP
			// [7] CGC
			// [8] PESSOA
			// [9] REGIAO

			If	Empty(SA1->A1_ENDCOB)
				aDatSacado   := {AllTrim(SUBSTR(SA1->A1_NOME,1,45)),;
				AllTrim(SA1->A1_COD)+'-'+SA1->A1_LOJA,;
				AllTrim(SA1->A1_END)+'-'+AllTrim(SA1->A1_BAIRRO),;
				AllTrim(SA1->A1_MUN),;
				SA1->A1_EST,;
				SA1->A1_CEP,;
				SA1->A1_CGC,;
				SA1->A1_PESSOA,;
				SA1->A1_REGIAO,;
				SA1->A1_EMAIL}
			Else
				aDatSacado   := {AllTrim(SUBSTR(SA1->A1_NOME,1,45)),;
				AllTrim(SA1->A1_COD)+'-'+SA1->A1_LOJA,;
				AllTrim(SA1->A1_ENDCOB)+'-'+AllTrim(SA1->A1_BAIRROC),;
				AllTrim(SA1->A1_MUNC),;
				SA1->A1_ESTC,;
				SA1->A1_CEPC,;
				SA1->A1_CGC,;
				SA1->A1_PESSOA,;
				SA1->A1_REGIAO,;
				SA1->A1_EMAIL}
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPosiciona o SE1 (Contas a receber)ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DbSelectArea('SE1')
			nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,'R',1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
			DbSelectArea('SE1')


			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณMonta codigo de barrasณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If	( AllTrim(SE1->E1_PORTADOR) == '001' )   		//BANCO DO BRASIL
				If Len(cConvenio) = 6
					aCB_RN_NN := xBBVerfBar(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,;
					Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5]	,;
					cNroDoc,(SE1->E1_SALDO - nVlrAbat),cCarteira,'9')
				Else
					aCB_RN_NN := xBBVerfBa7(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,;
					Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5]	,;
					cNroDoc,(SE1->E1_SALDO - nVlrAbat),cCarteira,'9',cConvenio)
				EndIF
			ElseIf	( AllTrim(SE1->E1_PORTADOR) == '033' )		//SANTANDER
				aCB_RN_NN := xSanVerfBar(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,;
					Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5]	,;
					cNroDoc,(SE1->E1_SALDO - nVlrAbat),cCarteira,'9',SE1->E1_VENCTO,aDadosBanco[8])
			ElseIf	( AllTrim(SE1->E1_PORTADOR) == '237' )		//BRADESCO
				aCB_RN_NN := xBraVerfBar(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,;
				Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5]	,;
				cNroDoc,(SE1->E1_SALDO - nVlrAbat),cCarteira,'9')
			ElseIf	( AllTrim(SE1->E1_PORTADO) == '341' )		//ITAU
			//	aCB_RN_NN := xItaVerfBar(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,;
			//	Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5]	,;
			//	cNroDoc,(SE1->E1_SALDO - nVlrAbat),cCarteira,'9')
				aCB_RN_NN := fLinhaDig (SE1->E1_PORTADO, ; // Codigo do Banco (341)				    	[1]
										'9', ; // Codigo da Moeda (9) 				                	   	[2]
										cCarteira, ; // Codigo da Carteira                                  [3]
										aDadosBanco[3] , ; // Codigo da Agencia                             [4]
										aDadosBanco[4]   , ; // Codigo da Conta                             [5]
										aDadosBanco[5] , ; // Digito verificador da Conta                   [6]
										(SE1->E1_SALDO - nVlrAbat)   , ; // Valor do Titulo                 [7]
										SE1->E1_VENCREA , ; // Data de vencimento do titulo                 [8]
										cNroDoc   )  // Numero do Documento Ref ao Contas a Receber           [9]



			ElseIf	( AllTrim(SE1->E1_PORTADOR) == '356' )		//
				aCB_RN_NN := xReaVerfBar(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,;
				Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5]	,;
				cNroDoc,(SE1->E1_SALDO - nVlrAbat),cCarteira,'9')
			ElseIf	( AllTrim(SE1->E1_PORTADOR) == '399' )		//HSBC
				aCB_RN_NN := xHsbVerfBar(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,;
				Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5]	,;
				cNroDoc,(SE1->E1_SALDO - nVlrAbat),cCarteira,'9',SE1->E1_VENCTO,aDadosBanco[8])
			ElseIf	( AllTrim(SE1->E1_PORTADOR) == '748' )		//SICREDI
				aCB_RN_NN := xSicVerfBar(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,;
				Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],;
				cNroDoc,(SE1->E1_SALDO - nVlrAbat),cCarteira,'9',SE1->E1_VENCTO,aDadosBanco[8],aDadosBanco[9])
			EndIf

			// [01] Numero do titulo
			// [02] Data da emissใo do titulo
			// [03] Data da emissใo do boleto
			// [04] Data do vencimento
			// [05] Valor do titulo
			// [06] Nosso numero (Ver formula para calculo)
			// [07] Prefixo da NF
			// [08] Tipo do Titulo
			// [09] Acrescimo
			// [10] Decrescimo
			aDadosTit := {SE1->E1_NUM+SE1->E1_PARCELA,;      // 01
			SE1->E1_EMISSAO,;                                       // 02
			dDataBase,;                                             // 03
			SE1->E1_VENCTO,;                                        // 04
			(SE1->E1_SALDO - nVlrAbat),;                            // 05
			aCB_RN_NN[3],;                                          // 06
			SE1->E1_PREFIXO,;                                       // 07
			SE1->E1_TIPO,;                                          // 08
			SE1->E1_SDACRESC,;                                      // 09
			SE1->E1_SDDECRESC}                                      // 10

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCARREGA AS INSTRUCOES A SEREM IMPRESSAS NO CORPO DO BOLETO!ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aBolText	:= {}  //Preencher as 7 posi็oes.

			//** MULTA **
			/*
			If aDadosBol[1] > 0
			//aAdd( aBolText, 'Ap๓s o vencimento cobrar multa de R$ ' + AllTrim(Transform((aDadosTit[5] * (aDadosBol[1]/100)),'@E 999,999,999.99')) )
			Else
			aAdd( aBolText, '' )
			EndIf

			//** TAXA PERMANENCIA **
			If aDadosBol[2] > 0
			aAdd( aBolText, 'Juros de R$ ' + AllTrim(Transform((aDadosTit[5] * (aDadosBol[2]/100)),'@E 999,999,999.99')) + ' ao dia' )
			Else
			aAdd( aBolText, '' )
			EndIf
			*/

			_cTxMora:=""
			aAdd( aBolText, '' )
			If (aDadosBol[1] > 0)
				If SE1->E1_PORTADO == '341'
					_cTxMora:='Ap๓s o vencimento cobrar multa de '+ CValToChar(aDadosBol[1]) +'%: R$ '+ AllTrim(Transform((aDadosTit[5] * (aDadosBol[1]/100)),'@E 999,999,999.99')) +' e '
					aAdd( aBolText, _cTxMora+'Juros diแrio de 0,033%: R$ ' + AllTrim(Transform((aDadosTit[5] * 0.00033),'@E 999,999,999.99')) ) 
				Else
					//_cTxMora:='Ap๓s o vencimento cobrar multa de R$ '+AllTrim(Transform(aDadosBol[1],'@E 999.99') )+' e '
					_cTxMora:='Ap๓s o vencimento cobrar multa de R$ '+ AllTrim(Transform((aDadosTit[5] * (aDadosBol[1]/100)),'@E 999,999,999.99')) +' e '
					aAdd( aBolText, _cTxMora+'Juros diแrio de: R$ ' + AllTrim(Transform((aDadosTit[5] * (aDadosBol[2]/100)),'@E 999,999,999.99')) )
				EndIF
			EndIf
			/*
			If aDadosBol[2] > 0 //Ap๓s o vencimento cobra multa de R$ 3,00 e Mora diแria de R$ 1,30
			If Empty(_cTxMora)
			aAdd( aBolText, 'Juros de R$ ' + AllTrim(Transform((aDadosTit[5] * (aDadosBol[2]/100)),'@E 999,999,999.99')) + ' ao dia' )
			Else
			aAdd( aBolText, _cTxMora+'Mora diแria: R$ ' + AllTrim(Transform((aDadosTit[5] * (aDadosBol[2]/100)),'@E 999,999,999.99')) )
			EndIf
			Else
			aAdd( aBolText, '' )
			EndIf
			*/
            
            //Chamado 2643 - Alfred Andersen/SMS em 29/03/2018
			//** SANTANDER **
			If AllTrim(SE1->E1_PORTADOR) == '033'  
				_cTextSant := "Prezado cliente, para sua comodidade a partir deste m๊s seus boletos podem ser atualizados atrav้s do site:"+chr(13)+chr(10)  
		   		aAdd( aBolText, _cTextSant )
		   		_cTextSant := "www.santander.com.br/br/resolva-on-line/reemissao-de-boleto-vencido"+chr(13)+chr(10)
		   		aAdd( aBolText, _cTextSant )
            EndIf    
            
			//** PROTESTO **
			aAdd( aBolText, aDadosBol[3] )

			//** LINHA 1 A LINHA 4 **
			aAdd( aBolText, aDadosBol[4] )
			aAdd( aBolText, aDadosBol[5] )
			aAdd( aBolText, aDadosBol[6] )
			//aAdd( aBolText, aDadosBol[7] )
			//	EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe for fatura, verifica os dados dos titulos integrantes. !ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If	( AllTrim(SE1->E1_PREFIXO) $ PrefFat )
				aDadosFat := xVerFatura(SE1->E1_NUM,SE1->E1_PREFIXO, SE1->E1_CLIENTE, SE1->E1_LOJA)
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGrava Nosso Numero no Titulo                               ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			IF alltrim(SE1->E1_PORTADOR) != '033' 
				DbSelectArea('SE1')
				If	RecLock('SE1',.f.)
					Replace SE1->E1_NUMBCO 	With Right(aCB_RN_NN[3],TamSX3("E1_NUMBCO")[1])   // Nosso numero (Ver formula para calculo)
					MsUnlock()
				Else
					Help('',1,'REGNOIS')
				EndIf
			EndIF

			If (Len(aParametros) = 0) .OR. (Len(aParametros) <> 0 .AND. (GetNewPar('MV_IMPBOL',1) <> 3))

				//			oPrint := TMSPrinter():New('Impressใo de Boleto Bancแrio')
				//			oPrint:SetPortrait() // ou SetLandscape()
				//			oPrint:Setup()
				//			oPrint:StartPage()   // Inicia uma nova pแgina
				// original
				//oPrint := FWMSPrinter():New(alltrim(aDadosTit[1]), IMP_PDF, lAdjustToLegacy, cCaminho , lDisableSetup, , , , , , ,.F., )
				lServer :=.T.
				lViewPDF     := .F.
				oPrint:= FWMSPrinter():New(alltrim(aDadosTit[1]), IMP_SPOOL, lAdjustToLegacy, cCaminho,lDisableSetup,NIL, NIL, "PDF", lServer, NIL, NIL, lViewPDF)

				// Ordem obrigแtoria de configura็ใo do relat๓rio
				oPrint:SetResolution(72)
				oPrint:SetPortrait()
				oPrint:SetPaperSize(DMPAPER_A4)
				oPrint:SetMargin(5,5,5,5)

				Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,cMemoTit)

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณGera E-mailณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				/*
				aCaminho          := {"\Boleto\*.jpg"}
				filepath          := "\Boleto\"+StrImp(aDadosBanco[1],'NroDoc')
				nwidthpage      := 1300
				nheightpage     := 1700

				aFiles := Directory(aCaminho[1])
				//		For i:=1 to Len(aFiles)
				//		     fErase("\Boleto\"+aFiles[i,1])
				//		Next i

				oPrint:SaveAllAsJpeg(filepath,nwidthpage,nheightpage,200)

				aFiles := {}
				aFiles := Directory(aCaminho[1])
				*/
				FErase( cCaminho+AllTrim(aDadosTit[1])+".pdf" )
				//oPrint:cPathPDF := cCaminho
				oPrint:Preview()
				oPrint:EndPage()     // Finaliza a pแgina
				cArq := AllTrim(aDadosTit[1])+".pdf" 				
				// Tiago Santos
				cNovo := cCaminho + AllTrim(aDadosTit[1]) +".rel"

				cGeraSenha := cCaminho+ AllTrim(aDadosTit[1]) +".pdf output "+cCaminho + AllTrim(aDadosTit[1]) +"_.pdf owner_pw foo user_pw "
				cGeraSenha += Alltrim(TRA->A1_PWBOL1) + " allow printing "
				WaitRunSrv( "F:\TOTVS\pdftk " + cGeraSenha, .T., cCaminho)
                //ShellExecute("Open","F:\TOTVS\pdftk.exe", cGeraSenha,	cCaminho, 1 )
				//ShellExecute("Open","F:\TOTVS\printer.exe", cGeraSenha,	cCaminho, 1 )
			    //remo็ใo para fins de testes no ambiente de homologa็ใo. Alfred/SMS em 25.04.2018
				sleep(8500)
			    //CpyT2S(cCaminho+AllTrim(aDadosTit[1]) +"_.pdf","\boleto\" , .T.)
				//CpyT2S(cCaminho+AllTrim(aDadosTit[1]) +".pdf","\boleto\" , .T.)
				lret := __CopyFile(cCaminho +AllTrim(aDadosTit[1])+"_.pdf" , "\boleto\"+AllTrim(aDadosTit[1]) +"_.pdf")

				FErase( "c:\temp\"+AllTrim(aDadosTit[1])+".rel" )
				FErase( "c:\temp\"+AllTrim(aDadosTit[1])+".pdf" )
				FErase( "c:\temp\"+AllTrim(aDadosTit[1])+"_.pdf" )
				ENVEMAIL(SE1->E1_FILIAL,SE1->E1_NUM,SE1->E1_PREFIXO, SE1->E1_CLIENTE, SE1->E1_LOJA)
			EndIF

			nX++

		EndIf

		IncProc()
		TRA->(DbSkip())
		nI++

		//Retorno as variaveis de Tela (so faz quando cliente De/Ate forem diferentes)
		BcoClie(0)

	EndDo

	If (Len(aParametros) = 0) .OR. (Len(aParametros) <> 0 .AND. (GetNewPar('MV_IMPBOL',1) <> 3))
		oPrint:EndPage()     // Finaliza a pแgina
		//oPrint:Preview()     // Visualiza antes de imprimir //Michael Andrade
	EndIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Impress  บAutor ณ Microsiga Software  บ Data ณ  11/10/04   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IMPRESSAO DO BOLETO LASER CONFORME O BANCO..               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,cMemoTit)

	Local nx
	Local _nLinAux		:= 0
	Local	oBrush		:= TBrush():New(,4),;
	nLin		:= 0,;
	oFont7  	:= TFont():New('Arial',9,7,.T.,.F.,5,.T.,5,.T.,.F.),;
	oFont8  	:= TFont():New('Arial',10,8,.T.,.F.,5,.T.,5,.T.,.F.),;
	oFont9  	:= TFont():New('Arial',11,11,.T.,.F.,5,.T.,5,.T.,.F.),;
	oFont11c	:= TFont():New('Courier New',12,12,.T.,.T.,5,.T.,5,.T.,.F.),;
	oFont11 	:= TFont():New('Arial',9,11,.T.,.T.,5,.T.,5,.T.,.F.),;
	oFont10 	:= TFont():New('Arial',12,12,.T.,.T.,5,.T.,5,.T.,.F.),;
	oFont14 	:= TFont():New('Arial',9,14,.T.,.T.,5,.T.,5,.T.,.F.),;
	oFont18 	:= TFont():New('Arial',22,22,.T.,.T.,5,.T.,5,.T.,.F.),;
	oFont20 	:= TFont():New('Arial',9,20,.T.,.T.,5,.T.,5,.T.,.F.),;
	oFont21 	:= TFont():New('Arial',9,21,.T.,.T.,5,.T.,5,.T.,.F.),;
	oFont16n	:= TFont():New('Arial',9,16,.T.,.F.,5,.T.,5,.T.,.F.),;
	oFont15 	:= TFont():New('Arial',9,15,.T.,.T.,5,.T.,5,.T.,.F.),;
	oFont15n	:= TFont():New('Arial',18,18,.T.,.F.,5,.T.,5,.T.,.F.),;
	oFont14n	:= TFont():New('Arial',9,14,.T.,.F.,5,.T.,5,.T.,.F.),;
	oFont24 	:= TFont():New('Arial',9,24,.T.,.T.,5,.T.,5,.T.,.F.),;
	nI 			:= 0,;
	nQtdPrint	:= 0,;
	nLinhPrin	:= 1
	cDigBco     := ""
	_cCR   := Chr(13)+Chr(10) //Incluido por Henrique para impressao do Log em 08/01



	Default cMemoTit := ''

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicia uma nova paginaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oPrint:StartPage()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณC O M P R O V A N T E   D E   E N T R E G Aณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nRow1 := 0

	oPrint:Line(nRow1+0150,0500,nRow1+0070,0500) //- linha pra baixo
	oPrint:Line(nRow1+0150,0710,nRow1+0070,0710)

	cString := StrImp(aDadosBanco[1],'PosLogo')

	IF AllTrim(Upper(aDadosBanco[2])) == 'SICREDI' .OR. aDadosBanco[1] == '033'
		oPrint:SayBitmap(0070,0100,aDadosBanco[7],280,080)
	ELSE
		oPrint:SayBitmap(0070,0100,aDadosBanco[7],cString[1],cString[2])
		oPrint:Say(nRow1+0125,cString[3],aDadosBanco[2],oFont10)	// [2] Nome do Banco
	ENDIF

	cDigBco := StrImp(aDadosBanco[1],'DigBco')
	oPrint:Say(nRow1+0125,0513,aDadosBanco[1]+cDigBco,oFont18) // [1] Numero do Banco

	oPrint:Say(nRow1+0125,1900,'Comprovante de Entrega',oFont10)



	oPrint:Line(nRow1+0150,0100,nRow1+0150,2300)

	oPrint:Say(nRow1+0150+titulo(),0100,'Cedente',oFont8)
	oPrint:Say(nRow1+0150+valor(),0100,aDadosEmp[1],oFont10) // Nome + CNPJ

	IF  aDadosBanco[1] == '341'
		oPrint:Say(nRow1+0150+titulo(),1060,'Ag๊ncia/C๓digo Cedente',oFont8)
		oPrint:Say(nRow1+0150+valor(),1060, aDadosBanco[3]+'/'+aDadosBanco[4]+'-'+ aDadosBanco[5]   ,oFont10)
	Else
		cString := StrImp(aDadosBanco[1],'AgCedente')
		oPrint:Say(nRow1+0150+titulo(),1060,'Ag๊ncia/C๓digo Cedente',oFont8)
		oPrint:Say(nRow1+0150+valor(),1060,cString[1],oFont10)
	EndIf
	cString := StrImp(aDadosBanco[1],'NroDoc')
	oPrint:Say(nRow1+0150+titulo(),1510,'Nro.Documento',oFont8)
	oPrint:Say(nRow1+0150+valor(),1550,cString,oFont10) // Prefixo +Numero+Parcela




	oPrint:Line (nRow1+0240,0100,nRow1+0240,1900)

	oPrint:Say(nRow1+0240+titulo(),100 ,'Sacado',oFont8)
	oPrint:Say(nRow1+0240+valor(),100 ,aDatSacado[1],oFont10) // Nome

	oPrint:Say(nRow1+0240+titulo(),1060,'Vencimento',oFont8)
	oPrint:Say(nRow1+0240+valor(),1060,StrZero(Day(aDadosTit[4]),2) +'/'+ StrZero(Month(aDadosTit[4]),2) +'/'+ Right(Str(Year(aDadosTit[4])),4),oFont10)

	oPrint:Say(nRow1+0240+titulo(),1510,'Valor do Documento',oFont8)
	oPrint:Say(nRow1+0240+valor(),1550,AllTrim(TransForm(aDadosTit[5],'@E 999,999,999.99')),oFont10)




	oPrint:Line (nRow1+0330,0100,nRow1+0330,1900)

	oPrint:Say(nRow1+0400,0100,'Recebi(emos) o bloqueto/tํtulo',oFont10)
	oPrint:Say(nRow1+0450,0100,'com as caracterํsticas acima.',oFont10)

	oPrint:Say(nRow1+0330+titulo(),1060,'Carteira',oFont8)
	oPrint:Say(nRow1+0330+valor(),1060,aDadosBanco[6],oFont10)

	If aDadosBanco[1] == '341'
		oPrint:Say(nRow1+0330+titulo(),1410,'Nosso Numero',oFont8)
		oPrint:Say(nRow1+0330+valor(),1410,'109/'+ Substr(aCB_RN_NN[3],1,8) +'-' + Substr(aCB_RN_NN[3],9,1),oFont10)
	Else
		cString := StrImp(aDadosBanco[1],'NossoNumero')
		oPrint:Say(nRow1+0330+titulo(),1410,'Nosso Numero',oFont8)
		oPrint:Say(nRow1+0330+valor(),1410,cString,oFont10)
	EndIF


	oPrint:Line (nRow1+0420,1050,nRow1+0420,1900)

	oPrint:Say(nRow1+0440,1060,'Data',oFont8)
	oPrint:Say(nRow1+0440,1410,'Entregador',oFont8)

	oPrint:Line (nRow1+0510,0100,nRow1+0510,2300)

	oPrint:Line (nRow1+0510,1050,nRow1+0150,1050)
	oPrint:Line (nRow1+0510,1400,nRow1+0330,1400)
	oPrint:Line (nRow1+0330,1500,nRow1+0150,1500)
	oPrint:Line (nRow1+0510,1900,nRow1+0150,1900)

	oPrint:Say(nRow1+0170,1910,'(   ) Mudou-se',oFont8)
	oPrint:Say(nRow1+0205,1910,'(   ) Ausente',oFont8)
	oPrint:Say(nRow1+0240,1910,'(   ) Nใo existe nบ indicado',oFont8)
	oPrint:Say(nRow1+0275,1910,'(   ) Recusado',oFont8)
	oPrint:Say(nRow1+0310,1910,'(   ) Nใo procurado',oFont8)
	oPrint:Say(nRow1+0345,1910,'(   ) Endere็o insuficiente',oFont8)
	oPrint:Say(nRow1+0380,1910,'(   ) Desconhecido',oFont8)
	oPrint:Say(nRow1+0415,1910,'(   ) Falecido',oFont8)
	oPrint:Say(nRow1+0450,1910,'(   ) Outros(anotar no verso)',oFont8)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณR E C I B O    D O     S A C A D Oณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nRow2 := -30

	For nI := 100 to 2300 step 50
		oPrint:Line(nRow2+0550, nI,nRow2+0550, nI+30)
	Next nI

	oPrint:Line(nRow2+0660,0100,nRow2+0660,2300)
	oPrint:Line(nRow2+0660,0500,nRow2+0580,0500)
	oPrint:Line(nRow2+0660,0710,nRow2+0580,0710)

	cString := StrImp(aDadosBanco[1],'PosLogo')

	IF AllTrim(Upper(aDadosBanco[2])) == 'SICREDI' .Or. aDadosBanco[1] == '033'
		oPrint:SayBitmap(nRow2+0580,0100,aDadosBanco[7],280,080)
	ELSE
		oPrint:SayBitmap(nRow2+0580,0100,aDadosBanco[7],cString[1],cString[2])
		oPrint:Say(nRow2+0635,cString[3],aDadosBanco[2],oFont10)	// [2] Nome do Banco
	ENDIF

	oPrint:Say(nRow2+0635,0513,aDadosBanco[1]+cDigBco,oFont18)	// [1] Numero do Banco

	oPrint:Say(nRow2+0635,1800,'Recibo do Sacado',oFont10)

	oPrint:Line(nRow2+0750,0100,nRow2+0750,2300)
	oPrint:Line(nRow2+0840,0100,nRow2+0840,2300)
	oPrint:Line(nRow2+0910,0100,nRow2+0910,2300)
	oPrint:Line(nRow2+0980,0100,nRow2+0980,2300)

	oPrint:Line(nRow2+0840,0500,nRow2+0980,0500) //nro doc
	oPrint:Line(nRow2+0980,0750,nRow2+0910,0750) //especie
	oPrint:Line(nRow2+0840,1000,nRow2+0980,1000) //quantidade
	oPrint:Line(nRow2+0840,1300,nRow2+0910,1300) //aceite
	oPrint:Line(nRow2+0840,1480,nRow2+0980,1480) //valor

	cString := StrImp(aDadosBanco[1],'LOCALPAGTO')
	oPrint:Say(nRow2+660+titulo(),0100,'Local de Pagamento',oFont8)
	If (aDadosBanco[1]=='001')
		oPrint:Say(nRow2+0660+titulo()+10,0380,cString[1],oFont10)
		oPrint:Say(nRow2+0660+valor()-10,0380,cString[2],oFont10)
	ElseIf (aDadosBanco[1]=='237')
		oPrint:Say(nRow2+0660+titulo()+10,0200,cString[1],oFont10)
		oPrint:Say(nRow2+0660+valor()-10,0200,cString[2],oFont10)
	ElseIf (aDadosBanco[1]=='341')
		oPrint:Say(nRow2+0660+titulo()+30,0230,cString[1],oFont10)
		oPrint:Say(nRow2+0660+valor(),0230,cString[2],oFont10)
	Else
		oPrint:Say(nRow2+0660+titulo()+10,0400,cString[1],oFont10)
		oPrint:Say(nRow2+0660+valor()-10,0400,cString[2],oFont10)
	EndIf
	cString	:= StrZero(Day(aDadosTit[4]),2) +'/'+ StrZero(Month(aDadosTit[4]),2) +'/'+ Right(Str(Year(aDadosTit[4])),4)
	oPrint:Say(nRow2+0660+titulo(),1810,'Vencimento',oFont8)
	oPrint:Say(nRow2+0660+valor(),1880,cString,oFont11c)

	oPrint:Say(nRow2+0750+titulo(),100 ,'Cedente',oFont8)
	oPrint:Say(nRow2+0750+valor(),100 ,aDadosEmp[1]+'          - '+aDadosEmp[6],oFont10) // Nome + CNPJ

	IF  aDadosBanco[1] == '341'
		oPrint:Say(nRow2+0750+titulo(),1810,'Ag๊ncia/C๓digo Cedente',oFont8)
		oPrint:Say(nRow2+0750+valor(),1880,aDadosBanco[3]+'/'+aDadosBanco[4]+'-'+aDadosBanco[5],oFont11c)
	Else
		cString := StrImp(aDadosBanco[1],'AgCedente')
		oPrint:Say(nRow2+0750+titulo(),1810,'Ag๊ncia/C๓digo Cedente',oFont8)
		oPrint:Say(nRow2+0750+valor(),1880,cString[1],oFont11c)
	Endif
	



	oPrint:Say(nRow2+0840+titulo(),100 ,'Data do Documento',oFont8)
	oPrint:Say(nRow2+0840+valor2(),100, StrZero(Day(aDadosTit[2]),2) +'/'+ StrZero(Month(aDadosTit[2]),2) +'/'+ Right(Str(Year(aDadosTit[2])),4),oFont10)

	cString := StrImp(aDadosBanco[1],'NroDoc')
	oPrint:Say(nRow2+0840+titulo(),505 ,'Nro.Documento',oFont8)
	oPrint:Say(nRow2+0840+valor2(),605 ,cString,oFont10)

	cString := StrImp(aDadosBanco[1],'Especie')
	oPrint:Say(nRow2+0840+titulo(),1005,'Esp้cie Doc.',oFont8)

	IF AllTrim(Upper(aDadosBanco[2])) == 'BRADESCO'
		oPrint:Say(nRow2+0840+valor2(),1050,'DM',oFont10) //'NF'
	ELSE
		oPrint:Say(nRow2+0840+valor2(),1050,cString,oFont10)
	ENDIF

	cString := StrImp(aDadosBanco[1],'Aceite')
	oPrint:Say(nRow2+0840+titulo(),1305,'Aceite',oFont8)
	oPrint:Say(nRow2+0840+valor2(),1400,cString,oFont10)


	cString := StrImp(aDadosBanco[1],'DTPROC')
	oPrint:Say(nRow2+0840+titulo(),1485,'Data do Processamento',oFont8)
	oPrint:Say(nRow2+0840+valor2(),1550,cString,oFont10) // Data impressao

	If aDadosBanco[1] == '341'
		oPrint:Say(nRow2+0840+titulo(),1810,'Nosso N๚mero',oFont8)
		oPrint:Say(nRow2+0840+valor2(),1880,'109/'+ Substr(aCB_RN_NN[3],1,8)+'-' + Substr(aCB_RN_NN[3],9,1),oFont11c)
	Else
		cString := StrImp(aDadosBanco[1],'NossoNumero')
		oPrint:Say(nRow2+0840+titulo(),1810,'Nosso N๚mero',oFont8)
		oPrint:Say(nRow2+0840+valor2(),1880,cString,oFont11c)
	EndIf





	oPrint:Say(nRow2+0910+titulo(),0100,'Uso do Banco',oFont8)

	oPrint:Say(nRow2+0910+titulo(),0505,'Carteira',oFont8)
	oPrint:Say(nRow2+0910+valor2(),0555,aDadosBanco[6],oFont10)

	cString := StrImp(aDadosBanco[1],'Especie')
	oPrint:Say(nRow2+0910+titulo(),0755,'Esp้cie',oFont8)

	IF AllTrim(Upper(aDadosBanco[2])) == 'BRADESCO'
		oPrint:Say(nRow2+0910+valor2(),0805,'R$',oFont10)
	ELSE
		oPrint:Say(nRow2+0910+valor2(),0805,'R$',oFont10)
	ENDIF

	oPrint:Say(nRow2+0910+titulo(),1005,'Quantidade',oFont8)
	oPrint:Say(nRow2+0910+titulo(),1485,'Valor',oFont8)

	oPrint:Say(nRow2+0910+titulo(),1810,'Valor do Documento',oFont8)
	cString := AllTrim(TransForm(aDadosTit[5],'@E 99,999,999.99'))
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say(nRow2+0910+valor2(),nCol,cString ,oFont11c)

	//Criado rotina para imprimir as observa็๕es uniformemente.
	oPrint:Say(nRow2+980+titulo(),0100,'Instru็๕es (Todas informa็๕es deste bloqueto sใo de exclusiva responsabilidade do cedente)',oFont8)



	nObsLin := nRow2+1010
	nObsSal := 25

	oPrint:Say(nObsLin,0100,aBolText[1],oFont10)
	nObsLin += nObsSal
	oPrint:Say(nObsLin,0100,aBolText[2],oFont10)
	nObsLin += nObsSal
	oPrint:Say(nObsLin,0100,aBolText[3],oFont10)
	nObsLin += nObsSal
	oPrint:Say(nObsLin,0100,aBolText[4],oFont10)
	nObsLin += nObsSal
	oPrint:Say(nObsLin,0100,aBolText[5],oFont10)
	nObsLin += nObsSal
	oPrint:Say(nObsLin,0100,aBolText[6],oFont10)
	nObsLin += nObsSal
	//oPrint:Say(nObsLin,0100,aBolText[7],oFont10)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณImprime os titulos que se refere a tal cobran็a !ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	oPrint:Say(nRow2+nObsLin,0100,'Referente aos documentos: ',oFont11)   //1246
	_nLinAux:=38
	/*
	If AllTrim(Upper(aDadosBanco[2])) == 'BRADESCO'
	oPrint:Say(nRow2+1246,0100,'Referente aos documentos: ',oFont11)
	_nLinAux:=41
	Else
	oPrint:Say(nRow2+1206,0100,'Referente aos documentos:',oFont11)
	Endif
	*/
	nLin := nObsLin+_nLinAux
	oPrint:Say(nRow2+nLin,0100,'Numero do RPS: ' + SE1->E1_NUM ,oFont11)


	If	( Len(aDadosFat) > 0 ) .And. Empty(cMemoTit)

		nLin := nObsLin+_nLinAux // Posicao da Linha     //1242
		nCol := 0100 // Posicao da Coluna
		For nx:=1 to Len(aDadosFat)
			nQtdPrint++
			oPrint:Say(nRow2+nLin,nCol,Alltrim(aDadosFat[nx][2])+'-'+aDadosFat[nx][3]+Iif(!Empty(aDadosFat[nx][4]),'/'+Alltrim(aDadosFat[nx][4]),'')+', ',oFont9)
			nCol += 156
			If	( nQtdPrint == 11 )
				nLin += 025
				nCol := 100
				nQtdPrint := 0
				nLinhPrin++
			EndIf
			If	( nLinhPrin > 7 )
				Exit
			EndIf
		Next nx

	Else	// Outros

		nLin := nObsLin+100 // Posicao da Linha
		nCol := 0100 // Posicao da Coluna
		// [01] Numero do titulo
		// [02] Data da emissใo do titulo
		// [03] Data da emissใo do boleto
		// [04] Data do vencimento
		// [05] Valor do titulo
		// [06] Nosso numero (Ver formula para calculo)
		// [07] Prefixo da NF
		// [08] Tipo do Titulo
		If Empty(cMemoTit)
			oPrint:Say(nRow2+nLin,nCol,aDadosTit[7] +' - '+ aDadosTit[1],oFont9)
		Else
			oPrint:Say(nRow2+nLin,nCol,cMemoTit,oFont9)
		EndIf

	EndIf

	oPrint:Say(nRow2+980+titulo(),1810,'(-) Desconto/Abatimento',oFont8)
	oPrint:Say(nRow2+1050+titulo(),1810,'(-) Outras Dedu็๕es',oFont8)
	If	( aDadosTit[10] > 0 )
		cString := AllTrim(TransForm(aDadosTit[10],'@E 99,999,999.99'))
		nCol := 1810+(374-(Len(cString)*22))
		oPrint:Say(nRow2+1050+valor2(),nCol,cString ,oFont11c)
	EndIf
	oPrint:Say(nRow2+1120+titulo(),1810,'(+) Mora/Multa',oFont8)
	oPrint:Say(nRow2+1190+titulo(),1810,'(+) Outros Acr้scimos',oFont8)
	If	( aDadosTit[9] > 0 )
		cString := AllTrim(TransForm(aDadosTit[9],'@E 99,999,999.99'))
		nCol := 1810+(374-(len(cString)*22))
		oPrint:Say(nRow2+1190+titulo(),nCol,cString ,oFont11c)
	EndIf
	oPrint:Say(nRow2+1260+titulo(),1810,'(=) Valor Cobrado',oFont8)





	oPrint:Say(nRow2+1450+titulo(),0100,'Sacado',oFont8)
	oPrint:Say(nRow2+1450+titulo(),1850,'Imp.: '+AllTrim(cUserName)+'-'+Time() ,oFont8)		//User Impressao

	oPrint:Say(nRow2+1470+titulo(0),0400,aDatSacado[1]+' ('+aDatSacado[2]+')',oFont10)
	//oPrint:Say(nRow2+1630,1850,'R:[' + AllTrim(aDatSacado[9]) + ']',oFont10)		//REGIAO
	oPrint:Say(nRow2+1470+titulo(1),0400,aDatSacado[3],oFont10)
	oPrint:Say(nRow2+1470+titulo(2),0400,aDatSacado[6]+'    '+aDatSacado[4]+' - '+aDatSacado[5],oFont10) // CEP+Cidade+Estado

	If	( aDatSacado[8] = 'J' )
		oPrint:Say(nRow2+1470+titulo(3),400 ,'CNPJ: '+TransForm(aDatSacado[7],'@R 99.999.999/9999-99'),oFont10) // CGC
	Else
		oPrint:Say(nRow2+1470+titulo(3),400 ,'CPF: '+TransForm(aDatSacado[7],'@R 999.999.999-99'),oFont10) 	// CPF
	EndIf

	oPrint:Say(nRow2+1470+titulo(3),1850,SubStr(aDadosTit[6],1,3)+SubStr(aDadosTit[6],4),oFont10)

	oPrint:Say(nRow2+1630-10,0100,'Sacador/Avalista',oFont8)
	oPrint:Say(nRow2+1630+titulo(),1500,'Autentica็ใo Mecโnica',oFont8)

	oPrint:Line(nRow2+0660,1800,nRow2+1330,1800) //linha vertical
	oPrint:Line(nRow2+1050,1800,nRow2+1050,2300) //deducoes
	oPrint:Line(nRow2+1120,1800,nRow2+1120,2300) //mora
	oPrint:Line(nRow2+1190,1800,nRow2+1190,2300) //acrecimentos
	oPrint:Line(nRow2+1260,1800,nRow2+1260,2300) //cobrado
	oPrint:Line(nRow2+1330,1800,nRow2+1330,2300) //fim

	oPrint:Line(nRow2+1450,0100,nRow2+1450,2300)
	oPrint:Line(nRow2+1630,0100,nRow2+1630,2300)











	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณF I C H A     D E    C O M P E N S A C A O ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nRow3 := 0

	For nI := 100 to 2300 step 50
		oPrint:Line(nRow3+1810, nI, nRow3+1810, nI+30)
	Next nI

	oPrint:Line(nRow3+1920,0100,nRow3+1920,2300)
	oPrint:Line(nRow3+1920,0500,nRow3+1840,0500)
	oPrint:Line(nRow3+1920,0710,nRow3+1840,0710)


	cString := StrImp(aDadosBanco[1],'PosLogo')

	IF AllTrim(Upper(aDadosBanco[2])) == 'SICREDI' .or. aDadosBanco[1] == '033'
		oPrint:SayBitmap(1840,0100,aDadosBanco[7],280,080)
	ELSE
		oPrint:SayBitmap(1840,0100,aDadosBanco[7],cString[1],cString[2])
		oPrint:Say(nRow1+1895,cString[3],aDadosBanco[2],oFont10)	// [2] Nome do Banco
	ENDIF

	oPrint:Say(nRow3+1895,0513,aDadosBanco[1]+cDigBco,oFont18) // [1]Numero do Banco

	oPrint:Say(nRow3+1895,0755,aCB_RN_NN[2],oFont15n) // Linha Digitavel do Codigo de Barras



	oPrint:Line(nRow3+2010,0100,nRow3+2010,2300)
	oPrint:Line(nRow3+2100,0100,nRow3+2100,2300)
	oPrint:Line(nRow3+2170,0100,nRow3+2170,2300)
	oPrint:Line(nRow3+2240,0100,nRow3+2240,2300)

	oPrint:Line(nRow3+2100,0500,nRow3+2240,0500)
	oPrint:Line(nRow3+2170,0750,nRow3+2240,0750)
	oPrint:Line(nRow3+2100,1000,nRow3+2240,1000)
	oPrint:Line(nRow3+2100,1300,nRow3+2170,1300)
	oPrint:Line(nRow3+2100,1480,nRow3+2240,1480)

	cString := StrImp(aDadosBanco[1],'LOCALPAGTO')
	oPrint:Say(nRow3+1920+titulo(),0100,'Local de Pagamento',oFont8)

	If (aDadosBanco[1]=='001')
		oPrint:Say(nRow3+1920+titulo()+10,0380,cString[1],oFont10)
		oPrint:Say(nRow3+1920+valor()-10,0380,cString[2],oFont10)
	ElseIf (aDadosBanco[1]=='237')
		oPrint:Say(nRow3+1920+titulo()+10,0200,cString[1],oFont10)
		oPrint:Say(nRow3+1920+valor()-10,0200,cString[2],oFont10)
	ElseIf (aDadosBanco[1]=='341')
		oPrint:Say(nRow3+1920+titulo()+30,0230,cString[1],oFont10)
		oPrint:Say(nRow3+1920+valor(),0230,cString[2],oFont10)
	Else
		oPrint:Say(nRow3+1920+titulo()+10,0400,cString[1],oFont10)
		oPrint:Say(nRow3+1920+valor()-10,0400,cString[2],oFont10)
	EndIf

	oPrint:Say(nRow3+1920+titulo(),1810,'Vencimento',oFont8)
	cString := StrZero(Day(aDadosTit[4]),2) +'/'+ StrZero(Month(aDadosTit[4]),2) +'/'+ Right(Str(Year(aDadosTit[4])),4)
	//nCol    := 1810+(374-(len(cString)*22))
	oPrint:Say(nRow3+1920+valor(),1880,cString,oFont11c)

	oPrint:Say(nRow3+2010+titulo(),0100,'Cedente',oFont8)
	oPrint:Say(nRow3+2010+valor(),0100,aDadosEmp[1]+'       - '+aDadosEmp[6],oFont10) // Nome + CNPJ

	IF  aDadosBanco[1] == '341'
		oPrint:Say(nRow3+2010+titulo(),1810,'Ag๊ncia/C๓digo Cedente',oFont8)
		oPrint:Say(nRow3+2010+valor(),1880,aDadosBanco[3]+'/'+aDadosBanco[4]+'-'+aDadosBanco[5],oFont11c)
	Else
		cString := StrImp(aDadosBanco[1],'AgCedente')
		oPrint:Say(nRow3+2010+titulo(),1810,'Ag๊ncia/C๓digo Cedente',oFont8)
		oPrint:Say(nRow3+2010+valor(),1880,cString[1],oFont11c)
	EndIF

	oPrint:Say(nRow3+2100+titulo(),0100 ,'Data do Documento',oFont8)
	oPrint:Say (nRow3+2100+valor2(),0100, StrZero(Day(aDadosTit[2]),2) +'/'+ StrZero(Month(aDadosTit[2]),2) +'/'+ Right(Str(Year(aDadosTit[2])),4), oFont10)

	cString := StrImp(aDadosBanco[1],'NroDoc')
	oPrint:Say(nRow3+2100+titulo(),505 ,'Nro.Documento',oFont8)
	oPrint:Say(nRow3+2100+valor2(),605 ,cString,oFont10) // Prefixo +Numero+Parcela

	cString := StrImp(aDadosBanco[1],'Especie')
	oPrint:Say(nRow3+2100+titulo(),1005,'Esp้cie Doc..',oFont8)

	IF AllTrim(Upper(aDadosBanco[2])) == 'BRADESCO'
		oPrint:Say(nRow3+2100+valor2(),1050,'DM',oFont10)  //'NF'
	ELSE
		oPrint:Say(nRow3+2100+valor2(),1050,cString,oFont10)
	ENDIF

	cString := StrImp(aDadosBanco[1],'Aceite')
	oPrint:Say(nRow3+2100+titulo(),1305,'Aceite',oFont8)
	oPrint:Say(nRow3+2100+valor2(),1400,cString,oFont10)

	oPrint:Say(nRow3+2100+titulo(),1485,'Data do Processamento',oFont8)
	oPrint:Say(nRow3+2100+valor2(),1550,StrZero(Day(aDadosTit[3]),2) +'/'+ StrZero(Month(aDadosTit[3]),2) +'/'+ Right(Str(Year(aDadosTit[3])),4),oFont10) // Data impressao
	
	If aDadosBanco[1] == '341'
		oPrint:Say(nRow3+2100+titulo(),1810,'Nosso N๚mero',oFont8)
		oPrint:Say(nRow3+2100+valor2(),1880,'109/'+Substr(aCB_RN_NN[3],1,8) +'-'+ Substr(aCB_RN_NN[3],9,1),oFont11c)
	Else
		cString := StrImp(aDadosBanco[1],'NossoNumero')
		oPrint:Say(nRow3+2100+titulo(),1810,'Nosso N๚mero',oFont8)
		oPrint:Say(nRow3+2100+valor2(),1880,cString,oFont11c)
	EndIf




	oPrint:Say(nRow3+2170+titulo(),0100,'Uso do Banco',oFont8)

	oPrint:Say(nRow3+2170+titulo(),0505,'Carteira',oFont8)
	oPrint:Say(nRow3+2170+valor2(),0555,aDadosBanco[6],oFont10)

	cString := StrImp(aDadosBanco[1],'Especie')
	oPrint:Say(nRow3+2170+titulo(),0755,'Esp้cie',oFont8)

	IF AllTrim(Upper(aDadosBanco[2])) == 'BRADESCO'
		oPrint:Say(nRow3+2170+valor2(),0805,'R$',oFont10)
	ELSE
		oPrint:Say(nRow3+2170+valor2(),0805,'R$',oFont10)
	ENDIF

	oPrint:Say(nRow3+2170+titulo(),1005,'Quantidade',oFont8)
	oPrint:Say(nRow3+2170+titulo(),1485,'Valor',oFont8)

	oPrint:Say(nRow3+2170+titulo(),1810,'Valor do Documento',oFont8)
	cString := AllTrim(TransForm(aDadosTit[5],'@E 99,999,999.99'))
	nCol 	:= 1810+(374-(len(cString)*22))
	oPrint:Say(nRow3+2170+valor2(),nCol,cString,oFont11c)




	oPrint:Say(nRow3+2240+titulo(),0100,'Instru็๕es (Todas informa็๕es deste bloqueto sใo de exclusiva responsabilidade do cedente)',oFont8)

	nObsLin := nRow3+2270
	nObsSal := 25

	oPrint:Say(nObsLin,0100,aBolText[1],oFont10)
	nObsLin += nObsSal
	oPrint:Say(nObsLin,0100,aBolText[2],oFont10)
	nObsLin += nObsSal
	oPrint:Say(nObsLin,0100,aBolText[3],oFont10)
	nObsLin += nObsSal
	oPrint:Say(nObsLin,0100,aBolText[4],oFont10)
	nObsLin += nObsSal
	oPrint:Say(nObsLin,0100,aBolText[5],oFont10)
	nObsLin += nObsSal
	oPrint:Say(nObsLin,0100,aBolText[6],oFont10)
	nObsLin += nObsSal
	//oPrint:Say(nObsLin,0100,aBolText[7],oFont10)

	FOR nI = 1 TO MlCount(cMemoTit,100)
		if nI > 2
			exit
		endif
		nObsLin += nObsSal
		oPrint:Say(nObsLin,0100,MemoLine(cMemoTit,100,nI),oFont10)
	NEXT

	oPrint:Say(nRow3+2240+titulo(),1810,'(-) Desconto/Abatimento',oFont8)
	oPrint:Say(nRow3+2310+titulo(),1810,'(-) Outras Dedu็๕es',oFont8)
	If	( aDadosTit[10] > 0 )
		cString := AllTrim(TransForm(aDadosTit[10],'@E 99,999,999.99'))
		nCol 	:= 1810+(374-(len(cString)*22))
		oPrint:Say(nRow3+23100+titulo(),nCol,cString,oFont11c)
	EndIf
	oPrint:Say(nRow3+2380+titulo(),1810,'(+) Mora/Multa',oFont8)
	oPrint:Say(nRow3+2450+titulo(),1810,'(+) Outros Acr้scimos',oFont8)
	If	( aDadosTit[9] > 0 )
		cString := AllTrim(TransForm(aDadosTit[9],'@E 99,999,999.99'))
		nCol 	:= 1810+(374-(len(cString)*22))
		oPrint:Say(nRow3+2450+titulo(),nCol,cString,oFont11c)
	EndIf
	oPrint:Say(nRow3+2520+titulo(),1810,'(=) Valor Cobrado',oFont8)

	oPrint:Say(nRow3+2590+titulo(),0100,'Sacado',oFont8)



	oPrint:Say(nRow3+2610+titulo(0),0400,aDatSacado[1]+' ('+aDatSacado[2]+')',oFont10)

	If	( aDatSacado[8] = 'J' )
		oPrint:Say(nRow3+2610+titulo(0),1680,'CNPJ: '+TransForm(aDatSacado[7],'@R 99.999.999/9999-99'),oFont10) // CGC
		//	oPrint:Say(nRow3+2900,2170,'R:[' + AllTrim(aDatSacado[9]) + ']',oFont10)		//REGIAO
	Else
		oPrint:Say(nRow3+2610+titulo(0),1680,'CPF: '+TransForm(aDatSacado[7],'@R 999.999.999-99'),oFont10) 	// CPF
		//	oPrint:Say(nRow3+2900,2170,'R:[' + AllTrim(aDatSacado[9]) + ']',oFont10)		//REGIAO
	EndIf

	oPrint:Say(nRow3+2610+titulo(1),0400,aDatSacado[3],oFont10)
	oPrint:Say(nRow3+2610+titulo(2),0400,aDatSacado[6]+'    '+aDatSacado[4]+' - '+aDatSacado[5],oFont10) // CEP+Cidade+Estado
	oPrint:Say(nRow3+2610+titulo(2),1750,SubStr(aDadosTit[6],1,3)+SubStr(aDadosTit[6],4),oFont10)

	oPrint:Say(nRow3+2730-10,0100,'Sacador/Avalista',oFont8)
	oPrint:Say(nRow3+2730+titulo(),1800,'Autentica็ใo Mecโnica - Ficha de Compensa็ใo',oFont8)

	oPrint:Line(nRow3+1920,1800,nRow3+2590,1800)
	oPrint:Line(nRow3+2310,1800,nRow3+2310,2300)
	oPrint:Line(nRow3+2380,1800,nRow3+2380,2300)
	oPrint:Line(nRow3+2450,1800,nRow3+2450,2300)
	oPrint:Line(nRow3+2520,1800,nRow3+2520,2300)
	oPrint:Line(nRow3+2590,0100,nRow3+2590,2300)

	oPrint:Line(nRow3+2730,0100,nRow3+2730,2300)

	//If mv_par18 = 2 //Impressใo Deskjet
	//	MsBar('INT25',13.3,0.6,aCB_RN_NN[1],oPrint,.f.,,,0.0134,0.61,,,'A',.f.)
	//Else
	//	MsBar('INT25',26.5,1.4,aCB_RN_NN[1],oPrint,.f.,,,0.0294,1.19,,,'A',.F.)
	//EndIf
	//MSBAR3("INT25"  , 26, .9, aCB_RN_NN[1]  ,oPrint,.F.,/*Color*/,/*lHorz*/,.02960,1  ,/*lBanner*/,/*cFont*/,"C",.F.)
	oPrint:FWMSBAR("INT25" ,62.5,2.4, aCB_RN_NN[1] ,oPrint,.F.,,.T.,0.02,1,.F.,"Arial",NIL,.F.,2,2,.F.)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFinaliza a paginaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oPrint:EndPage()
	//Incluido por Henrique em 08/01
	//Grava um Logo sempre que esta rotina for utilizada.
	_cLog := 'Em '+DtoC(dDataBase)+' '+Time()+' o usuแrio '+cUserName+' imprimiu o Boleto ' + SE1->E1_NUMBCO + _cCR
	_cLog += 'do cliente: ' + SE1->E1_CLIENTE + ' do Titulo: ' + SE1->E1_NUM //+ _cCR
	//_cLog += 'O pedido estava em separa็ใo !'

	//U_MFAT031J(_cLog,'BOL')
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFinaliza a paginaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ xBBVerfBar บAutorณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica/Gera o Codigo de Barra ( Banco do Brasil )        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ MOTIVO                                          บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xBBVerfBar(	cPrefixo,cNumero,cParcela,cTipo,;
	cBanco,cAgencia,cConta,cDacCC,;
	cNroDoc,nVlrTit,cCart,cMoeda)
	Local	cNosso		:= '',;
	nNum		:= '',;
	cCampoL		:= '',;
	cFatorValor	:= '',;
	cLivre		:= '',;
	cDigBarra	:= '',;
	cBarra		:= '',;
	cParte1		:= '',;
	cDig1		:= '',;
	cParte2		:= '',;
	cDig2		:= '',;
	cParte3		:= '',;
	cDig3		:= '',;
	cParte4		:= '',;
	cParte5		:= '',;
	cDigital	:= '',;
	aRet		:= {}

	cAgencia	:= StrZero(Val(cAgencia),4)
	cNosso 		:= ''

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFormulacao do nosso numeroณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If	( Len(AllTrim(cNroDoc)) == 12 ) // Ja esta pronto nao precisa verificar digito
		nNum	:= SubStr(cNroDoc,1,11)
		cNosso	:= cNroDoc
	ElseIf	( Len(AllTrim(cNroDoc)) == 17 ) // Ja esta pronto nao precisa verificar digito
		nNum	:= SubStr(cNroDoc,1,17)
		cNosso	:= nNum + xBBCalcDigN(nNum)
	Else
		nNum	:= StrZero(Val(cNroDoc),11)
		cNosso	:= nNum + xBBCalcDigN(nNum)
	EndIf

	// Campo livre -  verificar a conta e carteira
	cCampoL := nNum + cAgencia + StrZero(Val(cConta),8) + cCart

	// Campo livre do codigo de barra - verificar a conta
	cFatorValor  := xFator()+StrZero(nVlrTit*100,10)

	cLivre := cBanco + cMoeda + cFatorValor + cCampoL

	// Campo do codigo de barra
	cDigBarra := U_CalCpBB(cLivre)
	cBarra    := SubStr(cLivre,1,4)+cDigBarra+SubStr(cLivre,5,40)

	// Composicao da linha digitavel
	cParte1  := cBanco+cMoeda
	cParte1  += SubStr(cCampoL,1,5)
	cDig1    := U_DIGIT001( cParte1 )
	cParte2  := SubStr(cCampoL,6,10)
	cDig2    := U_DIGIT001( cParte2 )
	cParte3  := SubStr(cCampoL,16,10)
	cDig3    := U_DIGIT001( cParte3 )
	cParte4  := ' '+cDigBarra+' '
	cParte5  := cFatorValor

	cDigital := SubStr(cParte1,1,5)+'.'+SubStr(cparte1,6,4)+cDig1+' '+;
	SubStr(cParte2,1,5)+'.'+SubStr(cparte2,6,5)+cDig2+' '+;
	SubStr(cParte3,1,5)+'.'+SubStr(cparte3,6,5)+cDig3+' '+;
	cParte4+;
	cParte5

	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ xBBVerfBar บAutorณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica/Gera o Codigo de Barra ( Banco do Brasil )        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS CONVENIO COM 7 POSICOES                            บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ MOTIVO                                          บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xBBVerfBa7(cPrefixo,cNumero,cParcela,cTipo,;
	cBanco,cAgencia,cConta,cDacCC,;
	cNroDoc,nVlrTit,cCart,cMoeda,cConvenio)
	Local	cNosso		:= '',;
	nNum		:= '',;
	cCampoL		:= '',;
	cFatorValor	:= '',;
	cLivre		:= '',;
	cDigBarra	:= '',;
	cBarra		:= '',;
	cParte1		:= '',;
	cDig1		:= '',;
	cParte2		:= '',;
	cDig2		:= '',;
	cParte3		:= '',;
	cDig3		:= '',;
	cParte4		:= '',;
	cParte5		:= '',;
	cDigital	:= '',;
	aRet		:= {}

	cAgencia	:= StrZero(Val(cAgencia),4)
	cNosso 		:= cNroDoc

	// Campo livre -  verificar a conta e carteira
	cFatorValor := xFator() + StrZero(nVlrTit*100,10)
	cCampoL 		:= cBanco + cMoeda + cFatorValor + Replicate('0',6) + cNosso + cCart

	// Campo do codigo de barra
	cDigBarra := U_CalCpBB(cCampoL)
	cBarra    := SubStr(cCampoL,1,4)+cDigBarra+SubStr(cCampoL,5,40)

	// Composicao da linha digitavel
	cParte1  := cBanco+cMoeda
	cParte1  += SubStr(cBarra,20,5)
	cDig1    := U_DIGIT001( cParte1 )
	cParte2  := SubStr(cBarra,25,10)
	cDig2    := U_DIGIT001( cParte2 )
	cParte3  := SubStr(cBarra,35,10)
	cDig3    := U_DIGIT001( cParte3 )
	cParte4  := ' '+cDigBarra+' '
	cParte5  := cFatorValor

	cDigital := SubStr(cParte1,1,5)+'.'+SubStr(cparte1,6,4)+cDig1+' '+;
	SubStr(cParte2,1,5)+'.'+SubStr(cparte2,6,5)+cDig2+' '+;
	SubStr(cParte3,1,5)+'.'+SubStr(cparte3,6,5)+cDig3+' '+;
	cParte4+;
	cParte5

	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)

Return( aRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ xBraVerfBarบAutorณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica/Gera o Codigo de Barra ( Bradesco )               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ MOTIVO                                          บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xBraVerfBar(cPrefixo,cNumero,cParcela,cTipo,;
	cBanco,cAgencia,cConta,cDacCC,;
	cNroDoc,nVlrTit,cCart,cMoeda)
	Local	cNosso		:= '',;
	nNum		:= '',;
	cCampoL		:= '',;
	cFatorValor	:= '',;
	cLivre		:= '',;
	cDigBarra	:= '',;
	cBarra		:= '',;
	cParte1		:= '',;
	cDig1		:= '',;
	cParte2		:= '',;
	cDig2		:= '',;
	cParte3		:= '',;
	cDig3		:= '',;
	cParte4		:= '',;
	cParte5		:= '',;
	cDigital	:= '',;
	aRet		:= {}

	cAgencia	:= StrZero(Val(cAgencia),4)
	cNosso 		:= ''

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFormulacao do nosso numeroณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If	( Len(AllTrim(cNroDoc)) == 12 ) // Ja esta pronto nao precisa verificar digito
		nNum	:= SubStr(cNroDoc,1,11)
		cNosso	:= cNroDoc
	Else
		nNum	:= StrZero(Val(cNroDoc),11)
		cNosso	:= nNum + xBraCalcDigN(StrZero(Val(cCart),2)+nNum)
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCampo Livre -  Verificar a conta e carteiraณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	// 01 a 04 - 04 - Agencia Cedente
	// 05 a 06 - 02 - Carteira
	// 07 a 17 - 11 - Nosso Numero sem o digito
	// 18 a 24 - 07 - Conta Corrente sem o digito
	// 25 a 25 - 01 - Zero
	cCampoL := cAgencia + StrZero(Val(cCart),2) + nNum + StrZero(Val(cConta),7) + '0'

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCampo livre do codigo de barra - verificar a contaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cFatorValor  := xFator()+StrZero(nVlrTit*100,10)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMonta o campo Livre:ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	// 000000000111111111122222222223333333333444444444455555555556
	// 123456789012345678901234567890123456789012345678901234567890
	// 2379?XXXX$$$$$$$$$$LLLLLLLLLLLLLLLLLLLLLLLLL
	// x  xx         x          x           x
	cLivre := cBanco + cMoeda + cFatorValor + cCampoL

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCampo do codigo de barraณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cDigBarra := U_CalcpBr(cLivre)
	cBarra    := SubStr(cLivre,1,4)+cDigBarra+SubStr(cLivre,5,43)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณComposicao da linha digitavelณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cParte1  := cBanco + cMoeda + SubStr(cCampoL,1,5)
	cDig1    := U_DIGIT001( cParte1 )
	cParte2  := SubStr(cCampoL,6,10)
	cDig2    := U_DIGIT001( cParte2 )
	cParte3  := SubStr(cCampoL,16,10)
	cDig3    := U_DIGIT001( cParte3 )
	cParte4  := ' '+cDigBarra+' '
	cParte5  :=  cFatorValor

	cDigital := SubStr(cParte1,1,5)+'.'+SubStr(cParte1,6,4)+cDig1+' '+;
	SubStr(cParte2,1,5)+'.'+SubStr(cParte2,6,5)+cDig2+' '+;
	SubStr(cParte3,1,5)+'.'+SubStr(cParte3,6,6)+cDig3+;
	cParte4+;
	cParte5

	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ xItaVerfBarบAutorณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica/Gera o Codigo de Barra ( Bradesco )               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ MOTIVO                                          บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xItaVerfBar(cPrefixo,cNumero,cParcela,cTipo,;
	cBanco,cAgencia,cConta,cDacCC,;
	cNroDoc,nVlrTit,cCart,cMoeda)
	Local	cNosso		:= '',;
	nNum		:= '',;
	cCampoL		:= '',;
	cFatorValor	:= '',;
	cLivre		:= '',;
	cDigBarra	:= '',;
	cBarra		:= '',;
	cParte1		:= '',;
	cDig1		:= '',;
	cParte2		:= '',;
	cDig2		:= '',;
	cParte3		:= '',;
	cDig3		:= '',;
	cParte4		:= '',;
	cParte5		:= '',;
	cDigital	:= '',;
	aRet		:= {}

	cAgencia	:= StrZero(Val(cAgencia),4)
	cNosso 		:= ''

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFormulacao do nosso numeroณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//If	( Len(AllTrim(cNroDoc)) == 12 ) // Ja esta pronto nao precisa verificar digito
	//	nNum	:= SubStr(cNroDoc,1,11)
	//	cNosso	:= cNroDoc
	//Else
		nNum	:= StrZero(Val(cNroDoc),7)
		cNosso	:= nNum + U_DIGIT001(cAgencia+cConta+nNum)
//	EndIf

	//ConOut('Nosso Numero s/ digito..:' + nNum)
	//ConOut('Nosso Numero c/ digito..:' + cNosso)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCampo Livre -  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cCampoL := AllTrim(cNosso) + StrZer(Val(cAgencia),4) + StrZero(Val(cConta),5) + U_DIGIT001(cAgencia+cConta) + '000'

	//ConOut('Agencia..:' + cAgencia )
	//ConOut('Carteira.:' + StrZero(val(cCart),2) )
	//ConOut('Nosso Num s/digito.:' + nNum )
	//ConOut('Conta Cedente..:' + StrZero(Val(cConta),7) )
	ConOut('Formado campo-livre..:' + cCampoL )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCampo livre do codigo de barra - verificar a contaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cFatorValor  := xFator()+StrZero(nVlrTit*100,10)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMonta o campo Livre:ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	// 000000000111111111122222222223333333333444444444455555555556
	// 123456789012345678901234567890123456789012345678901234567890
	// 2379?XXXX$$$$$$$$$$LLLLLLLLLLLLLLLLLLLLLLLLL
	// x  xx         x          x           x
	cLivre := cBanco + cMoeda + cFatorValor + cCampoL

	//ConOut('Banco..:' + cBanco )
	//ConOut('Moeda..:' + cMoeda )
	ConOut('Fator+Valor..:' + cFatorValor )
	ConOut('Campo Livre..:' + cCampoL )

	//ConOut('Codigo para gerar o codigo de barras..:' + cLivre )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCampo do codigo de barraณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cDigBarra := U_Calc_5pIt(cLivre)
	cBarra    := SubStr(cLivre,1,4)+cDigBarra+SubStr(cLivre,5,43)

	ConOut('Digito Calculado..:' + cDigBarra )
	ConOut('Codigo Completo...:' + cBarra )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณComposicao da linha digitavelณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cParte1  := cBanco + cMoeda + SubStr(cCampoL,1,5)
	cDig1    := U_DIGIT001( cParte1 )
	cParte2  := SubStr(cCampoL,6,10)
	cDig2    := U_DIGIT001( cParte2 )
	cParte3  := SubStr(cCampoL,16,10)
	cDig3    := U_DIGIT001( cParte3 )
	cParte4  := ' '+cDigBarra+' '
	cParte5  :=  cFatorValor

	cDigital := SubStr(cParte1,1,5)+'.'+SubStr(cParte1,6,4)+cDig1+' '+;
	SubStr(cParte2,1,5)+'.'+SubStr(cParte2,6,5)+cDig2+' '+;
	SubStr(cParte3,1,5)+'.'+SubStr(cParte3,6,6)+cDig3+;
	cParte4+;
	cParte5

	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)

Return aRet



/*
+-----------+----------+-------+--------------------+------+-------------+
| Programa  |BOLITAU   |Autor  |Microsiga           | Data |  11/21/05   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |Obten็ใo da linha digitavel/codigo de barras                |
|           |                                                            |
+-----------+------------------------------------------------------------+
| Uso       | AP                                                         |
+-----------+------------------------------------------------------------+
*/

Static Function fLinhaDig (cCodBanco, ; // Codigo do Banco (341)      [1]
cCodMoeda, ; // Codigo da Moeda (9)                                   [2]
cCarteira, ; // Codigo da Carteira                                    [3]
cAgencia , ; // Codigo da Agencia                                     [4]
cConta   , ; // Codigo da Conta                                       [5]
cDvConta , ; // Digito verificador da Conta                           [6]
nValor   , ; // Valor do Titulo                                       [7]
dVencto  , ; // Data de vencimento do titulo                          [8]
cNroDoc   )  // Numero do Documento Ref ao Contas a Receber           [9]

//Local cValorFinal   := StrZero(int(nValor*100),10)
Local cValorFinal   := StrZero((nValor*100),10)
Local cFator        := StrZero(dVencto - CtoD("07/10/97"),4)
Local cCodBar   	:= Replicate("0",43)
Local cCampo1   	:= Replicate("0",05)+"."+Replicate("0",05)
Local cCampo2   	:= Replicate("0",05)+"."+Replicate("0",06)
Local cCampo3   	:= Replicate("0",05)+"."+Replicate("0",06)
Local cCampo4   	:= Replicate("0",01)
Local cCampo5   	:= Replicate("0",14)
Local cTemp     	:= ""
Local cNossoNum 	:= substr(cNroDoc,1,8) // Nosso numero
Local cDV			:= "" // Digito verificador dos campos
Local cLinDig		:= ""
Local cDvNN			:= ''
/*
-------------------------
Definicao do NOSSO NUMERO
-------------------------
*/
If At("-",cConta) > 0
//	cDig   := Right(AllTrim(cConta),1)
	cConta := AllTrim(Str(Val(Left(cConta,At('-',cConta)-1) + cDvConta))) //cDig)))
Else
	cConta := AllTrim(cConta)//AllTrim(Str(Val(cConta)))
Endif

cDvNN 		:= substr(cNroDoc,9,1)
cNossoNum   := cNossoNum + cDvNN

//cNossoNum   := cCarteira + cNroDoc + '-' + cDvNN
/*
-----------------------------
Definicao do CODIGO DE BARRAS
-----------------------------
*/
//Alltrim(cNroDoc)            + ; // 23 a 30
cTemp := Alltrim(cCodBanco)   + ; // 01 a 03
Alltrim(cCodMoeda)            + ; // 04 a 04
Alltrim(cFator)               + ; // 06 a 09
Alltrim(cValorFinal)          + ; // 10 a 19
Alltrim(cCarteira)            + ; // 20 a 22
Alltrim(substr(cNroDoc,1,8))  +;  // 23 A 30
Alltrim(cDvNN)  			  + ; // 31 a 31
Alltrim(cAgencia)             + ; // 32 a 35
Alltrim(cConta)               + ; // 36 a 40
Alltrim(cDvConta)             + ; // 41 a 41
"000"                             // 42 a 44
cDvCB  := Alltrim(Str(modulo11(cTemp)))	// Digito Verificador CodBarras
cCodBar:= SubStr(cTemp,1,4) + cDvCB + SubStr(cTemp,5)// + cDvNN + SubStr(cTemp,31)

/*/
-----------------------------------------------------
Definicao da LINHA DIGITAVEL (Representacao Numerica)
-----------------------------------------------------
Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
AAABC.CCDDX		DDDDD.DDFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV

CAMPO 1:
AAA = Codigo do banco na Camara de Compensacao
B = Codigo da moeda, sempre 9
CCC = Codigo da Carteira de Cobranca
DD = Dois primeiros digitos no nosso numero
X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
/*/
cTemp   := cCodBanco + cCodMoeda + cCarteira + Substr(cNroDoc,1,2)
cDV		:= Alltrim(Str(u_Modulo10(cTemp)))
cCampo1 := SubStr(cTemp,1,5) + '.' + Alltrim(SubStr(cTemp,6)) + cDV + Space(2)
/*/
CAMPO 2:
DDDDDD = Restante do Nosso Numero
E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
FFF = Tres primeiros numeros que identificam a agencia
Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
/*/
cTemp	:= Substr(cNroDoc,3,6) + cDvNN + Substr(cAgencia,1,3)
cDV		:= Alltrim(Str(u_Modulo10(cTemp)))
cCampo2 := Substr(cTemp,1,5) + '.' + Substr(cTemp,6) + cDV + Space(3)
/*/
CAMPO 3:
F = Restante do numero que identifica a agencia
GGGGGG = Numero da Conta + DAC da mesma
HHH = Zeros (Nao utilizado)
Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
/*/
cTemp   := Substr(cAgencia,4,1) + Alltrim(cConta) + Alltrim(cDvConta) + "000"
cDV		:= Alltrim(Str(u_Modulo10(cTemp)))
cCampo3 := Substr(cTemp,1,5) + '.' + Substr(cTemp,6) + cDV + Space(2)
/*/
CAMPO 4:
K = DAC do Codigo de Barras
/*/
cCampo4 := cDvCB + Space(2)
/*/            
CAMPO 5:
UUUU = Fator de Vencimento
VVVVVVVVVV = Valor do Titulo
/*/
cCampo5 := cFator + StrZero((nValor * 100),14 - Len(cFator))
cLinDig := cCampo1 + cCampo2 + cCampo3 + cCampo4 + cCampo5
Return {cCodBar, cLinDig, cNossoNum}

/*
+-----------+----------+-------+--------------------+------+-------------+
| Programa  |MODULO10  |Autor  |Microsiga           | Data |  21/11/05   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |Cแlculo do Modulo 10 para obten็ใo do DV dos campos do      |
|           |Codigo de Barras                                            |
+-----------+------------------------------------------------------------+
| Uso       | Financeiro Transilva LOG                                   |
+-----------+------------------------------------------------------------+
*/
User Function Modulo10(cData)
Local  L,D,P := 0
Local B     := .F.
L := Len(cData)
B := .T.
D := 0
While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		End
	End
	D := D + P
	L := L - 1
	B := !B
End
D := 10 - (Mod(D,10))
If D = 10
	D := 0
End
Return D

/*
+-----------+----------+-------+--------------------+------+-------------+
| Programa  |MODULO11  |Autor  |Microsiga           | Data |  21/11/05   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |Calculo do Modulo 11 para obtencao do DV do Codigo de Barras|
|           |                                                            |
+-----------+------------------------------------------------------------+
| Uso       | Financeiro Transilva LOG                                   |
+-----------+------------------------------------------------------------+
*/
Static Function Modulo11(cData)
Local L, D, P := 0
L := Len(cdata)
D := 0
P := 1
// Some o resultado de cada produto efetuado e determine o total como (D);
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End
// DAC = 11 - Mod 11(D)
D := 11 - (mod(D,11))
// OBS: Se o resultado desta for igual a 0, 1, 10 ou 11, considere DAC = 1.
If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
	D := 1

End

Return D


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ xReaVerfBarบAutorณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica/Gera o Codigo de Barra ( Real )                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ MOTIVO                                          บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xReaVerfBar(cPrefixo,cNumero,cParcela,cTipo,;
	cBanco,cAgencia,cConta,cDacCC,;
	cNroDoc,nVlrTit,cCart,cMoeda)
	Local	cNosso		:= '',;
	nNum		:= '',;
	cCampoL		:= '',;
	cFatorValor	:= '',;
	cLivre		:= '',;
	cDigBarra	:= '',;
	cBarra		:= '',;
	cParte1		:= '',;
	cDig1		:= '',;
	cParte2		:= '',;
	cDig2		:= '',;
	cParte3		:= '',;
	cDig3		:= '',;
	cParte4		:= '',;
	cParte5		:= '',;
	cDigital	:= '',;
	aRet		:= {}

	cAgencia	:= StrZero(Val(cAgencia),4)
	cNosso 		:= ''

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFormulacao do nosso numeroณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nNum	:= StrZero(Val(cNroDoc),7)
	cNosso	:= nNum

	//ConOut('Nosso Numero s/ digito..:' + nNum)
	//ConOut('Nosso Numero c/ digito..:' + cNosso)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCampo Livre -  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cCampoL := StrZero(Val(cAgencia),4) + StrZero(Val(cConta),7) + U_DIGIT001( cNosso + cAgencia + StrZero(Val(cConta),7) ) + StrZero(Val(cNosso),13)

	//ConOut('Agencia..:' + cAgencia )
	//ConOut('Carteira.:' + StrZero(val(cCart),2) )
	//ConOut('Nosso Num s/digito.:' + nNum )
	//ConOut('Conta Cedente..:' + StrZero(Val(cConta),7) )
	ConOut('Formado campo-livre..:' + cCampoL )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCampo livre do codigo de barra - verificar a contaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cFatorValor  := xFator()+StrZero(nVlrTit*100,10)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMonta o campo Livre:ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	// 000000000111111111122222222223333333333444444444455555555556
	// 123456789012345678901234567890123456789012345678901234567890
	// 2379?XXXX$$$$$$$$$$LLLLLLLLLLLLLLLLLLLLLLLLL
	// x  xx         x          x           x
	cLivre := cBanco + cMoeda + cFatorValor + cCampoL

	//ConOut('Banco..:' + cBanco )
	//ConOut('Moeda..:' + cMoeda )
	ConOut('Fator+Valor..:' + cFatorValor )
	ConOut('Campo Livre..:' + cCampoL )

	//ConOut('Codigo para gerar o codigo de barras..:' + cLivre )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCampo do codigo de barraณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cDigBarra := U_Calc_5pRe(cLivre)
	cBarra    := SubStr(cLivre,1,4)+cDigBarra+SubStr(cLivre,5,43)

	ConOut('Digito Calculado..:' + cDigBarra )
	ConOut('Codigo Completo...:' + cBarra )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณComposicao da linha digitavelณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cParte1  := cBanco + cMoeda + SubStr(cCampoL,1,5)
	cDig1    := U_DIGIT001( cParte1 )
	cParte2  := SubStr(cCampoL,6,10)
	cDig2    := U_DIGIT001( cParte2 )
	cParte3  := SubStr(cCampoL,16,10)
	cDig3    := U_DIGIT001( cParte3 )
	cParte4  := ' '+cDigBarra+' '
	cParte5  :=  cFatorValor

	cDigital := SubStr(cParte1,1,5)+'.'+SubStr(cParte1,6,4)+cDig1+' '+;
	SubStr(cParte2,1,5)+'.'+SubStr(cParte2,6,5)+cDig2+' '+;
	SubStr(cParte3,1,5)+'.'+SubStr(cParte3,6,6)+cDig3+;
	cParte4+;
	cParte5

	Aadd(aRet,cBarra)
	Aadd(aRet,cDigital)
	Aadd(aRet,cNosso)

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ xHsbVerfBarบAutorณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica/Gera o Codigo de Barra ( Real )                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ MOTIVO                                          บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xHsbVerfBar(cPrefixo,cNumero,cParcela,cTipo,;
	cBanco,cAgencia,cConta,cDacCC,;
	cNroDoc,nVlrTit,cCart,cMoeda,dVencto,cCedente)

	Local nNroDoc     := 0
	Local nCedente    := 0
	Local nFatVct     := 0
	Local	cNosso		:= ''
	Local nParDig     := 0

	Local	cBarra		:= ''
	Local	cDigBarra	:= ''

	Local	cParte1		:= ''
	Local	cDig1		   := ''
	Local	cParte2		:= ''
	Local	cDig2		   := ''
	Local	cParte3		:= ''
	Local	cDig3		   := ''
	Local	cParte4		:= ''
	Local	cParte5		:= ''
	Local	cDigital	   := ''

	Local	aRet		   := {}

	//Zera e ajusta algumas variแvels
	cAgencia	   := StrZero(Val(cAgencia),4)
	cNosso 		:= ''
	cCedente    := StrZero(Val(cCedente),7)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFormulacao do nosso numero (N๚mero Bancแrio) ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(cNroDoc) < 15  //Quando jแ existe o Nosso N๚mero do banco ele vem com tamanho 15, entใo s๓ gero novamente
		//se for menor que este tamanho.

		//Calculo do dํgito verificar primeira parte
		nNroDoc   := Val(xCalMod11(cNroDoc,9,2,'D'))
		nNroDoc   := If(nNroDoc=0 .Or. nNroDoc=10,'0',cValToChar(nNroDoc))
		nNroDoc   := PadL(AllTrim(cNroDoc),13,'0') + nNroDoc

		nNroDoc   += '4'   //A pen๚ltima posi็ใo ้ sempre o “tipo identificador”, sendo que:
		//“4” - Vincula: “vencimento”, “c๓digo do cedente” e “c๓digo do documento”;
		cNosso   := nNroDoc
		nNroDoc	:= Val(nNroDoc)
		nCedente	:= Val(cCedente)
		nFatVct  := Val( Substr(DTOS(dVencto),7,2) + Substr(DTOS(dVencto),5,2) + Substr(DTOS(dVencto),3,2) )
		nNroDoc  := nNroDoc + nCedente + nFatVct

		nParDig	:= Val(xCalMod11(StrZero(nNroDoc,15),9,2,'D'))
		nparDig  := If(nParDig=0 .Or. nParDig=10,'0',cValToChar(nParDig))

		cNosso   := cNosso + nParDig
	Else
		cNosso := StrZero(Val(cNroDoc),16)
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cแlculo do C๓digo de Barras ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	//Primeiro calculo o dํgito verificador

	cBarra := cBanco + cMoeda + xFator() + StrZero(nVlrTit*100,10) + StrZero(Val(cCedente),7) + Substr(cNosso,1,13)

	//Adiciona Data no Formato Juliano HSBC - Parametro MV_HSBCJUL
	cBarra += If( GetNewPar('MV_HSBCJUL',.T.), xJuliano(dVencto), '0000' )

	cBarra += '2'   //C๓digo do aplicativo CNR = 2

	//se            0-10-1
	cDigBarra := 11 - Val(xCalMod11(cBarra,9,2,'C'))
	cDigBarra := If(cDigBarra=0 .Or. cDigBarra=10,'1',cValToChar(cDigBarra))

	cBarra := Substr(cBarra,1,4) + cDigBarra + Substr(cBarra,5,999)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณComposicao da linha digitavelณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	cParte1  := cBanco + cMoeda + SubStr(cCedente,1,5)
	cDig1    := U_DIGIT001( cParte1 )

	cParte2  := SubStr(cCedente,6,2) + Substr(cNosso,1,8)
	cDig2    := U_DIGIT001( cParte2 )

	cParte3  := SubStr(cNosso,9,5) + If( GetNewPar('MV_HSBCJUL',.T.),xJuliano(dVencto),'0000') + '2'
	cDig3    := U_DIGIT001( cParte3 )

	cParte4  := ' '+cDigBarra+' '

	cParte5  :=  xFator() + StrZero(nVlrTit*100,10)

	cDigital := SubStr(cParte1,1,5)+'.'+SubStr(cParte1,6,4)+cDig1+' '+;
	SubStr(cParte2,1,5)+'.'+SubStr(cParte2,6,5)+cDig2+' '+;
	SubStr(cParte3,1,5)+'.'+SubStr(cParte3,6,6)+cDig3+;
	cParte4+;
	cParte5

	Aadd(aRet,cBarra)   //C๓digo de Barras
	Aadd(aRet,cDigital) //Linha Digitแvel
	Aadd(aRet,cNosso)   //Nosso N๚mero

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ xSicVerfBarบAutorณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica/Gera o Codigo de Barra ( Sicred )                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ MOTIVO                                          บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xSicVerfBar(cPrefixo,cNumero,cParcela,cTipo,cBanco,cAgencia,cConta,cDacCC,cNroDoc,nVlrTit,cCart,cMoeda,dVencto,cCedente,cConvenio)

	Local   nNroDoc     := 0
	Local   nCedente    := 0
	Local   nFatVct     := 0
	Local	cNosso		:= ''

	Local	cBarra		:= ''
	Local	cDigBarra	:= ''
	Local   cCpoLivre   := ''

	Local	cParte1		:= ''
	Local	cDig1		   := ''
	Local	cParte2		:= ''
	Local	cDig2		   := ''
	Local	cParte3		:= ''
	Local	cDig3		   := ''
	Local	cParte4		:= ''
	Local	cParte5		:= ''
	Local	cDigital	   := ''

	Local	aRet		   := {}

	//Zera e ajusta algumas variแvels
	cAgencia	   := StrZero(Val(cAgencia),4)
	cNosso 		:= ''

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFormulacao do nosso numero (N๚mero Bancแrio) ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(AllTrim(cNroDoc)) < 9               //EE_CODCOBE
		//Calculo do dํgito verificador     748       20        04               99                          2   99999
		nNroDoc    := 11 - Val(xCalMod11(cAgencia+cConvenio+cCedente+Right(cValToChar(Year(dDataBase)),2)+'2'+cNroDoc,9,2,'C'))
		nNroDoc    := If( nNroDoc > 9,'0',cValToChar(nNroDoc))

		//Montagem do nosso n๚mero
		cNosso    := Right(cValToChar(Year(dDataBase)),2)			// ANO (DOIS DIGITOS)
		cNosso    += '2'        //FIXO
		cNosso    += cNroDoc    //SEQUENCIAO EE_FAIXATU
		cNosso    += nNroDoc    //DIGITO
	Else
		cNosso := AllTrim(cNroDoc)
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cแlculo do C๓digo de Barras ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	cCpoLivre := '3'   //C๓digo da cobran็a no Sicredi
	cCpoLivre += cCart
	cCpoLivre += cNosso
	cCpoLivre += cAgencia
	cCpoLivre += cConvenio
	cCpoLivre += PadL(cCedente,5,'0')
	cCpoLivre += '1'    //Se hแ valor do documento, preencher com 1.
	cCpoLivre += '0'    //Filler Zeros

	cDigBarra := 11 - Val(xCalMod11(cCpoLivre,9,2,'C'))
	cDigBarra := If(cDigBarra>9,'0',cValToChar(cDigBarra))

	cCpoLivre := cCpoLivre + cDigBarra

	cBarra    := cBanco
	cBarra    += cMoeda
	cBarra    += xFator()
	cBarra    += StrZero(nVlrTit*100,10)
	cBarra    += cCpoLivre

	cDigBarra := 11 - Val(xCalMod11(cBarra,9,2,'C'))
	cDigBarra := If(cDigBarra > 9 .Or. cDigBarra = 0 .Or. cDigBarra = 1,'1',cValToChar(cDigBarra))

	cBarra    := Substr(cBarra,1,4) + cDigBarra + Substr(cBarra,5,999)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณComposicao da linha digitavelณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	cParte1  := cBanco + cMoeda + SubStr(cCpoLivre,1,5)
	cDig1    := U_DIGIT001( cParte1 )

	cParte2  := SubStr(cCpoLivre,6,10)
	cDig2    := U_DIGIT001( cParte2 )

	cParte3  := SubStr(cCpoLivre,16,10)
	cDig3    := U_DIGIT001( cParte3 )

	cParte4  := ' '+cDigBarra+' '

	cParte5  :=  xFator() + StrZero(nVlrTit*100,10)

	cDigital := SubStr(cParte1,1,5)+'.'+SubStr(cParte1,6,4)+cDig1+' '+;
	SubStr(cParte2,1,5)+'.'+SubStr(cParte2,6,5)+cDig2+' '+;
	SubStr(cParte3,1,5)+'.'+SubStr(cParte3,6,6)+cDig3+;
	cParte4+;
	cParte5

	Aadd(aRet,cBarra)   //C๓digo de Barras
	Aadd(aRet,cDigital) //Linha Digitแvel
	Aadd(aRet,cNosso)   //Nosso N๚mero

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ xCalMod11 NบAutorณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Para calculo do nosso numero do banco do brasil            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

// Exemplo:    xCalMod11( '2292838' , 9 , 2 )   nBas1 = Base Maior    nBas2 = Base Menor

Static Function xCalMod11(cVariavel,nBas1,nBas2,cOrdem,nSeZer,nSeDez,nSeUm)

	Local	Auxi	   := 0
	Local	SumDig	:= 0
	Local	nbase  	:= Len(cVariavel)
	Local	iDig   	:= nBase
	Local	base   	:= 0

	Default nBas1  := 9
	Default nBas2  := 2
	Default nSeZer := 0
	Default nSeDez := 0
	Default nSeUm  := 1
	Default cOrdem := 'D'

	If Upper(cOrdem) == 'D'
		base := nBas1
		While	iDig >= 1
			If	( base == (nBas2-1) )
				base := nBas1
			EndIf

			auxi   := Val(SubStr(cVariavel, idig, 1)) * base
			sumdig += auxi
			base--
			iDig--
		EndDo
	Else
		base := nBas2
		While	iDig >= 1
			If	( base == (nBas1+1) )
				base := nBas2
			EndIf

			auxi   := Val(SubStr(cVariavel, idig, 1)) * base
			sumdig += auxi
			base++
			iDig--
		EndDo
	EndIF

	auxi := mod(Sumdig,11)

Return( Str(auxi,2,0) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ xBBCalcDigNบAutorณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Para calculo do nosso numero do banco do brasil            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BOLETOS                                                    บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xBBCalcDigN(cVariavel)
	Local	Auxi	:= 0,;
	SumDig	:= 0

	cbase	:= cVariavel
	lbase  	:= Len(cBase)
	base   	:= 9
	sumdig 	:= 0
	Auxi   	:= 0
	iDig   	:= lBase

	While	iDig >= 1

		If	( base == 1 )
			base := 9
		EndIf

		auxi   := Val(SubStr(cBase, idig, 1)) * base
		sumdig += auxi
		base--
		iDig--

	EndDo

	auxi := mod(Sumdig,11)

	If	( auxi == 10 )
		auxi := 'X'
	Else
		auxi := str(auxi,1,0)
	EndIf

Return(auxi)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณxBraCalcDigNบAutorณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Para calculo do nosso numero do Bradesco....               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xBraCalcDigN(cVariavel)
	Local	Auxi	:= 0,;
	SumDig	:= 0

	cbase	:= cVariavel
	lbase  	:= Len(cBase)
	base   	:= 2
	sumdig 	:= 0
	Auxi   	:= 0
	iDig   	:= lBase

	//ConOut('Vou Calcular o Digito de..:' + cBase )

	While	iDig >= 1

		If	( base == 8 )   //Base de 2 a 7 ok !
			base := 2
		EndIf

		auxi   := Val(SubStr(cBase, idig, 1)) * base
		sumdig += auxi
		base++
		iDig--
	EndDo

	//ConOut('Somado..:' + Str(sumdig) )

	auxi := 11 - mod(Sumdig,11)

	//ConOut('Digito inicial..:' + Str(auxi) )

	If	( auxi == 10 )
		auxi := 'P'
	ElseIf ( auxi == 11 )
		auxi := '0'
	Else
		auxi := str(auxi,1,0)
	EndIf

Return(auxi)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ DIGIT001 บAutor  ณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Para calculo usando modulo 10                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ MOTIVO                                          บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DIGIT001(cVariavel)
	Local	Auxi 	:= 0,;
	sumdig 	:= 0

	cbase  := cVariavel
	lbase  := LEN(cBase)
	umdois := 2
	sumdig := 0
	Auxi   := 0
	iDig   := lBase

	While	 ( iDig >= 1 )

		auxi   := Val(SubStr(cBase, idig, 1)) * umdois
		sumdig := SumDig + If (auxi < 10, auxi, (auxi-9))
		umdois := 3 - umdois
		iDig := iDig-1

	EndDo

	cValor	:= AllTrim(padl(Alltrim(str(sumdig)),12,'0'))
	nDezena	:= Val(AllTrim(Str(Val(SubStr(cvalor,11,1))+1))+'0')
	auxi 	:= nDezena - sumdig

	If	( auxi >= 10 )
		auxi := 0
	EndIf

Return(str(auxi,1,0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FATOR	บAutor  ณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo do FATOR de vencimento para linha digitavel.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ MOTIVO                                          บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xFator()

	If	Len(AllTrim(SubStr(DTOC(SE1->E1_VENCTO),7,4))) = 4
		cData := SubStr(DTOC(SE1->E1_VENCTO),7,4)+SubStr(DTOC(SE1->E1_VENCTO),4,2)+SubStr(DTOC(SE1->E1_VENCTO),1,2)
	Else
		cData := '20'+SubStr(DTOC(SE1->E1_VENCTO),7,2)+SubStr(DTOC(SE1->E1_VENCTO),4,2)+SubStr(DTOC(SE1->E1_VENCTO),1,2)
	EndIf

	cFator := STR(1000+(STOD(cData)-STOD('20000703')),4)

Return(cFator)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ CALCpBB  บAutor  ณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo do digito do nosso numero                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CALCpBB(cVariavel)
	Local	Auxi	:= 0,;
	sumdig	:= 0

	cbase	:= cVariavel
	lbase	:= LEN(cBase)
	base 	:= 2
	sumdig	:= 0
	Auxi 	:= 0
	iDig  	:= lBase

	While	( iDig >= 1 )
		If	( base >= 10 )
			base := 2
		EndIf
		auxi   := Val(SubStr(cBase, idig, 1)) * base
		sumdig := SumDig+auxi
		base++
		iDig--
	EndDo

	auxi := mod(sumdig,11)
	If	( auxi == 0 ) .or. ( auxi == 1 ) .or. ( auxi >= 10 )
		auxi := 1
	Else
		auxi := 11 - auxi
	EndIf

Return(Str(auxi,1,0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ CALCpBr  บAutor  ณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo do digito do nosso numero do Bradesco              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CALCpBr(cVariavel)
	Local	Auxi	:= 0,;
	sumdig	:= 0

	cbase	:= cVariavel
	lbase	:= LEN(cBase)
	base 	:= 2
	sumdig	:= 0
	Auxi 	:= 0
	iDig  	:= lBase

	While	( iDig >= 1 )
		If	( base >= 10 )
			base := 2
		EndIf
		auxi   := Val(SubStr(cBase, idig, 1)) * base
		sumdig := SumDig+auxi
		base++
		iDig--
	EndDo

	auxi := mod(sumdig,11)

	If	( auxi == 0 ) .or. ( auxi == 1 ) .or. ( auxi > 9 )
		auxi := 1
	Else
		auxi := 11 - auxi
	EndIf

Return(Str(auxi,1,0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ CALC_5pItบ Autor ณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo do digito do nosso numero do Itau                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CALC_5pIt(cVariavel)
	Local	Auxi	:= 0,;
	sumdig	:= 0

	cbase	:= cVariavel
	lbase	:= LEN(cBase)
	base 	:= 2
	sumdig	:= 0
	Auxi 	:= 0
	iDig  	:= lBase

	While	( iDig >= 1 )
		If	( base >= 10 )
			base := 2
		EndIf
		auxi   := Val(SubStr(cBase, idig, 1)) * base
		sumdig := SumDig+auxi
		base++
		iDig--
	EndDo

	auxi := mod(sumdig,11)

	If	( auxi == 0 ) .or. ( auxi == 1 ) .or. ( auxi > 9 )
		auxi := 1
	Else
		auxi := 11 - auxi
	EndIf

Return(Str(auxi,1,0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ CALC_5pReบ Autor ณMicrosiga           บ Data ณ  02/13/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo do digito do nosso numero do Real                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CALC_5pRe(cVariavel)
	Local	Auxi	:= 0,;
	sumdig	:= 0

	cbase	:= cVariavel
	lbase	:= LEN(cBase)
	base 	:= 2
	sumdig	:= 0
	Auxi 	:= 0
	iDig  	:= lBase

	While	( iDig >= 1 )
		If	( base >= 10 )
			base := 2
		EndIf
		auxi   := Val(SubStr(cBase, idig, 1)) * base
		sumdig := SumDig+auxi
		base++
		iDig--
	EndDo

	auxi := mod(sumdig,11)

	If	( auxi == 0 ) .or. ( auxi == 1 ) .or. ( auxi > 9 )
		auxi := 1
	Else
		auxi := 11 - auxi
	EndIf

Return(Str(auxi,1,0))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AjustaSX1บAutor ณ Julio Storino       บ Data ณ  15/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta o SX1 - Arquivo de Perguntas..                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ MOTIVO                                          บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AjustaSX1(cPerg)
	Local	aRegs   := {},;
	_sAlias := Alias(),;
	nX

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCampos a serem grav. no SX1ณ
	//ณaRegs[nx][01] - X1_GRUPO   ณ
	//ณaRegs[nx][02] - X1_ORDEM   ณ
	//ณaRegs[nx][03] - X1_PERGUNTEณ
	//ณaRegs[nx][04] - X1_PERSPA  ณ
	//ณaRegs[nx][05] - X1_PERENG  ณ
	//ณaRegs[nx][06] - X1_VARIAVL ณ
	//ณaRegs[nx][07] - X1_TIPO    ณ
	//ณaRegs[nx][08] - X1_TAMANHO ณ
	//ณaRegs[nx][09] - X1_DECIMAL ณ
	//ณaRegs[nx][10] - X1_PRESEL  ณ
	//ณaRegs[nx][11] - X1_GSC     ณ
	//ณaRegs[nx][12] - X1_VALID   ณ
	//ณaRegs[nx][13] - X1_VAR01   ณ
	//ณaRegs[nx][14] - X1_DEF01   ณ
	//ณaRegs[nx][15] - X1_DEF02   ณ
	//ณaRegs[nx][16] - X1_DEF03   ณ
	//ณaRegs[nx][17] - X1_F3      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria uma array, contendo todos os valores...ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAdd(aRegs,{cPerg,'01','Do Prefixo         ?','Do Prefixo         ?','Do Prefixo         ?','mv_ch1','C', 3,0,0,'G','','mv_par01','','','',''})
	aAdd(aRegs,{cPerg,'02','At o Prefixo      ?','At o Prefixo      ?','At o Prefixo      ?','mv_ch2','C', 3,0,0,'G','','mv_par02','','','',''})
	aAdd(aRegs,{cPerg,'03','Do Tกtulo          ?','Do Tกtulo          ?','Do Tกtulo          ?','mv_ch3','C', 6,0,0,'G','','mv_par03','','','',''})
	aAdd(aRegs,{cPerg,'04','At o Tกtulo       ?','At o Tกtulo       ?','At o Tกtulo       ?','mv_ch4','C', 6,0,0,'G','','mv_par04','','','',''})
	aAdd(aRegs,{cPerg,'05','Do Banco           ?','Do Banco           ?','Do Banco           ?','mv_ch5','C', 3,0,0,'G','','mv_par05','','','','SA6'})
	aAdd(aRegs,{cPerg,'06','At o Banco        ?','At o Banco        ?','At o Banco        ?','mv_ch6','C', 3,0,0,'G','','mv_par06','','','','SA6'})
	aAdd(aRegs,{cPerg,'07','Do Cliente         ?','Do Cliente         ?','Do Cliente         ?','mv_ch7','C', 6,0,0,'G','','mv_par07','','','','CLI'})
	aAdd(aRegs,{cPerg,'08','At o Cliente      ?','At o Cliente      ?','At o Cliente      ?','mv_ch8','C', 6,0,0,'G','','mv_par08','','','','CLI'})
	aAdd(aRegs,{cPerg,'09','Da Loja            ?','Da Loja            ?','Da Loja            ?','mv_ch9','C', 2,0,0,'G','','mv_par09','','','',''})
	aAdd(aRegs,{cPerg,'10','At a Loja         ?','At a Loja         ?','At a Loja         ?','mv_cha','C', 2,0,0,'G','','mv_par10','','','',''})
	aAdd(aRegs,{cPerg,'11','Do Vencimento      ?','Do Vencimento      ?','Do Vencimento      ?','mv_chb','D', 8,0,0,'G','','mv_par11','','','',''})
	aAdd(aRegs,{cPerg,'12','At o Vencimento   ?','At o Vencimento   ?','At o Vencimento   ?','mv_chc','D', 8,0,0,'G','','mv_par12','','','',''})
	aAdd(aRegs,{cPerg,'13','Da Emisso         ?','Da Emisso         ?','Da Emisso         ?','mv_chd','D', 8,0,0,'G','','mv_par13','','','',''})
	aAdd(aRegs,{cPerg,'14','At a Emisso      ?','At a Emisso      ?','At a Emisso      ?','mv_che','D', 8,0,0,'G','','mv_par14','','','',''})
	aAdd(aRegs,{cPerg,'15','Selecionar Tกtulos ?','Selecionar Tกtulos ?','Selecionar Tกtulos ?','mv_chf','N', 1,0,1,'C','','mv_par15','Sim','No','',''})
	aAdd(aRegs,{cPerg,'16','Do Bordero         ?','Do Bordero         ?','Do Bordero         ?','mv_chg','C', 6,0,0,'G','','mv_par16','','','',''})
	aAdd(aRegs,{cPerg,'17','At o Bordero      ?','At o Bordero      ?','At o Bordero      ?','mv_chh','C', 6,0,0,'G','','mv_par17','','','',''})
	aAdd(aRegs,{cPerg,'18','Tipo de Impressใo  ?','Tipo de Impressใo  ?','Tipo de Impressใo  ?','mv_chi','N', 1,0,1,'C','','mv_par18','Laser','DeskJet','',''})
	aAdd(aRegs,{cPerg,'19','Do Tipo de Tํtulo  ?','Do Tipo de Tํtulo  ?','Do Tipo de Tํtulo  ?','mv_chj','C', 3,0,0,'G','','mv_par19','','','','05'})
	aAdd(aRegs,{cPerg,'20','At้ Tipo de Tํtulo ?','At้ Tipo de Tํtulo ?','At้ Tipo de Tํtulo ?','mv_chk','C', 3,0,0,'G','','mv_par20','','','','05'})

	DbSelectArea('SX1')
	SX1->(DbSetOrder(1))

	For nX:=1 to Len(aRegs)
		If	( !SX1->(DbSeek(aRegs[nx][01]+aRegs[nx][02])) )
			If	RecLock('SX1',.T.)
				Replace X1_GRUPO	With aRegs[nx][01]
				Replace X1_ORDEM   	With aRegs[nx][02]
				Replace X1_PERGUNTE	With aRegs[nx][03]
				Replace X1_PERSPA	With aRegs[nx][04]
				Replace X1_PERENG	With aRegs[nx][05]
				Replace X1_VARIAVL	With aRegs[nx][06]
				Replace X1_TIPO		With aRegs[nx][07]
				Replace X1_TAMANHO	With aRegs[nx][08]
				Replace X1_DECIMAL	With aRegs[nx][09]
				Replace X1_PRESEL	With aRegs[nx][10]
				Replace X1_GSC		With aRegs[nx][11]
				Replace X1_VALID	With aRegs[nx][12]
				Replace X1_VAR01	With aRegs[nx][13]
				Replace X1_DEF01	With aRegs[nx][14]
				Replace X1_DEF02	With aRegs[nx][15]
				Replace X1_DEF03	With aRegs[nx][16]
				Replace X1_F3   	With aRegs[nx][17]
				MsUnlock('SX1')
			Else
				Help('',1,'')
			EndIf
		Endif
	Next nX
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณxVerFaturaบAutor ณ Julio Storino       บ Data ณ  15/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica os titulos integrantes das faturas. !!!           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao Principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDATA      ณ ANALISTA ณ  MOTIVO                                         บฑฑ
ฑฑฬออออออออออุออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ          ณ                                                 บฑฑ
ฑฑศออออออออออฯออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function xVerFatura(cNumFat,cPrefixo,_cCodCli,_cLojaCli)
	Local	cQuery	:= '',;
	cAnoFut	:= AllTrim(Str(Year(dDataBase)+10))+'1231',;
	aReturn	:= {}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica, os Titulos Originais, da FATURA Impressa Acima...ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If	( AllTrim(cPrefixo) $ PrefFat )
		cQuery	:= "SELECT SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, SE5.E5_VALOR, "
		cQuery	+= "SE5.E5_VLDESCO, SE5.E5_VLJUROS, SE5.E5_VLMULTA "
		cQuery	+= "FROM " + RetSqlName('SE5') + ' SE5 '
		cQuery	+= "WHERE SE5.E5_FILIAL = '" + xFilial('SE5') + "' "
		cQuery	+= "AND SE5.E5_TIPODOC = 'BA' "
		cQuery	+= "AND SE5.E5_DATA >= '19950101' "
		cQuery	+= "AND SE5.E5_DATA <= '" + cAnoFut + "' "
		cQuery	+= "AND SE5.E5_RECPAG = 'R' "
		cQuery	+= "AND SE5.E5_SITUACA <> 'C' "
		cQuery	+= "AND SE5.E5_MOTBX = 'FAT' "
		cQuery	+= "AND SE5.E5_HISTOR = 'Bx.Emis.Fat." + cNumFat + "' "
		cQuery	+= "AND SE5.E5_CLIFOR = '"+_cCodCli+" ' AND SE5.E5_LOJA = '"+_cLojaCli+" '   "
		cQuery	+= "AND SE5.D_E_L_E_T_ <> '*' "
		cQuery	+= " ORDER BY SE5.E5_FILIAL, SE5.E5_DATA, SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA "
	Else
		cQuery	+= "SELECT SD2.D2_PEDIDO NUMERO "
		cQuery	+= "FROM " + RetSqlName("SD2") + " AS SD2 "
		cQuery	+= "WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' "
		cQuery	+= "AND SD2.D2_DOC = '" + cNumFat + "' "
		cQuery	+= "AND SD2.D2_SERIE = '" + cPrefixo + "' "
		cQuery	+= "AND SD2.D2_CLIENTE = '" + _cCodCli + "' "
		cQuery	+= "AND SD2.D2_LOJA = '" + _cLojaCli + "' "
		cQuery	+= "AND SD2.D_E_L_E_T_ = '' "
		cQuery	+= "GROUP BY SD2.D2_PEDIDO "
	EndIf
	cQuery	:= ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TR5',.F.,.T.)

	DbSelectArea('TR5')
	TR5->(DbGoTop())

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณElementos da Arrayณ
	//ณ1o - Emissao      ณ
	//ณ2o - Prefixo      ณ
	//ณ3o - Numero       ณ
	//ณ4o - Parcela      ณ
	//ณ5o - Valor        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	While	TR5->( ! Eof() )
		If	( AllTrim(cPrefixo) $ PrefFat	)
			aAdd(aReturn,{'',TR5->E5_PREFIXO,TR5->E5_NUMERO,TR5->E5_PARCELA,TR5->E5_VALOR+TR5->E5_VLDESCO-(TR5->E5_VLJUROS+TR5->E5_VLMULTA)})
		Else
			aAdd(aReturn,{	'','',TR5->NUMERO,'',0})
		EndIf
		TR5->(DbSkip())
	EndDo

	TR5->(DbCloseArea())

Return aReturn




//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFuncao para validar os dados digitados na tela de sele็ใo com rela็ใoณ
//ณao banco e agencia de transferencia e ao tipo de cobran็a.           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
STATIC FUNCTION TudoOk(oDlg)

	Local _lRet   := .T.
	Local _Msg    := ''

	lPortador := .f.
	lSituacao := .f.
	lTpCaract := .f.

	TRA->(DbGoTop())

	//Define se vai precisar da obrigatoriedade de banco e Tipo de Cobran็a
	While TRA->(!EOF())
		IF TRA->(Marked('E1_OK')) .and. Empty(TRA->E1_PORTADOR)
			lPortador := .t.
		EndIf
		If TRA->(Marked('E1_OK')) 
			lSituacao := .t.
		EndIf
		if lPortador .and. lSituacao
			Exit
		EndIf

		//Valida se Todos os Titulo Selecionados estao igual a cadaracteristica do Banco
		IF TRA->(Marked('E1_OK')) 
			lTpCaract:=.T.
		EndIf

		TRA->(DbSkip())
	EndDo

	If lTpCaract
		_lRet := .F.
		_Msg  += _Quebra + 'O Campo Caracteristica esta Diferente do Banco Selecionado!'
		TRA->(DbGoTop())
	EndIf

	If  lPortador .and. Empty(cBcoOrig)
		_lRet := .F.
		_Msg  += _Quebra + 'Obrigat๓rio informar o banco de transfer๊ncia !'
	EndIf

	If lSituacao .and. Empty(cSituaca)
		_lRet := .F.
		_Msg  += _Quebra + 'Obrigat๓rio informar a situa็ใo de Transfer๊ncia !'
	EndIf

	If lSituacao .and. !Empty(cSituaca) .and. !Substr(cSituaca,1,1)$'1/4'
		_lRet := .F.
		_Msg  += _Quebra + 'Somente situa็๕es 1 ou 4 sใo permitidas !'
	EndIf

	If !Empty(cBcoOrig) .and. !Substr(cSituaca,1,1)$'1/4'
		_lRet := .F.
		_Msg  += _Quebra + 'Somente situa็๕es 1 ou 4 sใo permitidas !'
	EndIf

	If !Empty(_Msg)
		IW_MSGBOX(_Msg, 'Aten็ใo', "STOP")
	EndIf

Return _lRet



Static Function xJuliano(dData)

	Local cRet    := ''
	Local dDtIni  := SToD( StrZero(Year(dData),4) + '0101' )
	Local nDias   := (dData - dDtIni) + 1

	cRet := StrZero(nDias,3) + Right( Str(Year(dData)),1)

Return cRet




Static Function StrImp(cBco,cTipo)

	Local Ret

	Do Case
		Case Upper(cTipo) == 'DIGBCO'
		Do Case
			Case cBco = '001'
			Ret := '-9'
			Case cBco = '033'
			Ret := '-7'
			Case cBco = '237'
			Ret := '-2'
			Case cBco = '341'
			Ret := '-7'
			Case cBco = '356'
			Ret := '-5'
			Case cBco = '399'
			Ret := '-9'
			Case cBco = '748'
			Ret := '-X'
		EndCase

		Case Upper(cTipo) == 'NOSSONUMERO'
		Do Case
			Case cBco == '001'
			Do Case
				Case Len(aDadosTit[6]) = 12
				Ret := AllTrim(SubStr(aDadosTit[6],1,6)+SubStr(aDadosTit[6],7,5)+' - '+SubStr(aDadosTit[6],12,1))
				Case Len(aDadosTit[6]) = 17
				Ret := AllTrim(SubStr(aDadosTit[6],1,7)+' '+SubStr(aDadosTit[6],8,10))
			EndCase
			Case cBco == '033'
			Ret := AllTrim(aDadosTit[6])
			Case cBco == '237'
			Ret := AllTrim(StrZero(Val(aDadosBanco[6]),2)) + '/' + AllTrim(SubStr(aDadosTit[6],1,11)) + '-' + SubStr(aDadosTit[6],12,1)
			Case cBco == '341'
			Ret := AllTrim(SubStr(aDadosTit[6],1,3)) + '/' + AllTrim(SubStr(aDadosTit[6],4,8)) + '-' + SubStr(aDadosTit[6],12,1)
			Case cBco == '356'
			Ret := AllTrim(aDadosTit[6])
			Case cBco == '399'
			Ret := AllTrim(aDadosTit[6])
			Case cBco == '748'
			Ret := Left(AllTrim(aDadosTit[6]),2) + '/' + Substr(AllTrim(aDadosTit[6]),3,6) + '-' + Right(AllTrim(aDadosTit[6]),1)
		EndCase

		Case Upper(cTipo) == 'LOCALPAGTO'
		Do Case
			Case cBco == '033'
			Ret := {}
			aAdd( Ret, 'ATษ O VENCIMENTO, PREFERENCIALMENTE NO SANTANDER' )
			aAdd( Ret, 'APำS O VENCIMENTO, SOMENTE NO SANTANDER' )
			Case cBco == '399'
			Ret := {}
			aAdd( Ret, 'PAGAR PREFERENCIALMENTE EM AGสNCIAS DO HSBC' )
			aAdd( Ret, 'APำS O VENCIMENTO, SOMENTE NO '+aDadosBanco[2] )
			Case cBco == '748'
			Ret := {}
			aAdd( Ret, 'PAGAVEL PREFERENCIALMENTE NAS COOPERATIVAS DE CREDITO DO SICREDI' )
			aAdd( Ret, ' ' )
			Case cBco == '237'
			Ret := {}
			aAdd( Ret, 'PAGAVEL PREFERENCIALMENTE NA REDE BRADESCO OU BRADESCO EXPRESSO' )
			aAdd( Ret, ' ' )
			Case cBco == '341'
			Ret := {}
			aAdd( Ret, 'ATษ O VENCIMENTO, PAGUE EM QUALQUER BANCO OU CORRESPONDENTE NรO BANCมRIO.' )
			aAdd( Ret, 'APำS O VENCIMENTO, ACESSE itau.com.br/boletos E PAGUE EM QUALQUER BANCO OU CORRESPONDENTE.' )
			OtherWise
			Ret := {}
			aAdd( Ret, 'QUALQUER BANCO ATE O VENCIMENTO' )
			aAdd( Ret, 'APำS O VENCIMENTO, SOMENTE NO '+aDadosBanco[2] )
		EndCase

		Case Upper(cTipo) == 'NRODOC'
		Do Case
			Case cBco == '399'
			Ret := aDadosTit[6]
			OtherWise
			Ret := aDadosTit[7]+aDadosTit[1]
			//Ret := aDadosTit[7]+'-' + Substr(aDadosTit[1],1,TamSX3('E1_NUM')[1]) + '/' + RIGHT(aDadosTit[1],TamSX3('E1_PARCELA')[1])
		EndCase

		Case Upper(cTipo) == 'ESPECIE'
		Do Case
			Case cBco == '001'
			Ret := 'DM'
			Case cBco == '033'
			Ret := 'DM'
			Case cBco == '237'
			Ret := 'DM'
			Case cBco == '399'
			Ret := ''
			OtherWise
			Ret := aDadosTit[8]
		EndCase

		Case Upper(cTipo) == 'ACEITE'
		Do Case
			Case cBco == '399'
			Ret := ''
			OtherWise
			Ret := 'N'
		EndCase

		Case Upper(cTipo) == 'DTPROC'
		Do Case
			Case cBco == '399'
			Ret := ''
			OtherWise
			Ret := StrZero(Day(aDadosTit[3]),2) +'/'+ StrZero(Month(aDadosTit[3]),2) +'/'+ Right(Str(Year(aDadosTit[3])),4)
		EndCase

		Case Upper(cTipo) == 'POSLOGO'
		Do Case
			Case cBco == '399'
			Ret := {}
			aAdd( Ret, 110 )
			aAdd( Ret, 75 )
			aAdd( Ret, 220 )
			OtherWise
			Ret := {}
			aAdd( Ret, 75 )
			aAdd( Ret, 75 )
			aAdd( Ret, 185 )
		EndCase

		Case Upper(cTipo) == 'AGCEDENTE'
		Do Case
			Case cBco == '748'
			Ret := {}
			aAdd( Ret, aDadosBanco[3]+'.'+aDadosBanco[9]+'.'+AllTrim(aDadosBanco[8]))
			aAdd( Ret, 1810+(490-(len(Ret[1])*22)) )
			Case cBco == '399'
			Ret := {}
			aAdd( Ret, aDadosBanco[8] )
			aAdd( Ret, 1810+(374-(len(Ret[1])*22)) )
			OtherWise
			Ret := {}
			aAdd( Ret, aDadosBanco[3]+'-3/'+aDadosBanco[4]+'-'+aDadosBanco[5] )
			aAdd( Ret, 1810+(374-(len(Ret[1])*22)) )
		EndCase

		OtherWise
		Ret := '?'
	EndCase

Return( Ret )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBCOCLIE   บAutor  ณ- JULIO STORINO -   บ Data ณ  03/31/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFAZ O TRATAMENTO PARA BCO/AGE/CTA/SIT INFORMADO NO CADASTRO บฑฑ
ฑฑบ          ณDE CLIENTES.                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BcoClie(_nOpc,_cCliente,_cLoja)

	Local _lAchouCli	:= .F.
	//_nOpc = 0 | Retornar variaveis de Tela (reset)
	//_nOpc = 1 | Verifica Dados para Titulo Corrente
	//_nOpc = 2 | Verifica Dados para Parametros informados.

	Do Case

		Case _nOpc = 0

		//Se os parametros forem identicos nao preciso setar nada, pois ja foi feito na montagem da tela
		If MV_PAR07 == MV_PAR08

			Return( Nil )

		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRetorno os valores selecionados em Tela para Proximo registroณ
		//ณSolicitado por Valquiria 18/03/2010 - Desenv. Julio Storino  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		//Verifico se hแ informacao nas variaveis de Screen, pois se nao houver foi porque eu nao
		//busquei os possiveis dados do cliente em momento algum entao prevalece o que esta nas variaveis originais.
		If !Empty(_cBcoScr) .And. !Empty(_cAgeScr) .And. !Empty(_cCtaScr) .And. !Empty(_cSitScr)
			cBcoOrig		:= _cBcoScr
			cAGenOrig	:= _cAgeScr
			cCtaOrig		:= _cCtaScr
			cSituaca		:= _cSitScr + ' ' + Posicione('SX5',1,xFilial('SX5')+'07'+_cSitScr,'X5_DESCRI')
		EndIf

		Case _nOpc = 1

		If (SA1->(FieldPos('A1_BCOCOB'))<>0) .And. (SA1->(FieldPos('A1_AGECOB'))<>0) .And. (SA1->(FieldPos('A1_CTACOB'))<>0) .And. (SA1->(FieldPos('A1_SITCOB'))<>0)

			//Se os parametros forem identicos nao preciso setar nada, pois ja foi feito na montagem da tela
			If (MV_PAR07 == MV_PAR08) .And. ;
			(!Empty(_cBcoCli) .And. !Empty(_cAgeCli) .And. !Empty(_cCtaCli) .And. !Empty(_cSitCli))

				Return( Nil )

			EndIf

			SA1->(DbSetOrder(1))
			SA1->(DbGoTop())

			If Empty(_cLoja)
				_lAchouCli := SA1->(DbSeek(xFilial('SA1') + _cCliente ))
			Else
				_lAchouCli := SA1->(DbSeek(xFilial('SA1') + _cCliente + _cLoja ))
			EndIf

			If _lAchouCli
				_cBcoCli := SA1->A1_BCOCOB
				_cAgeCli	:= SA1->A1_AGECOB
				_cCtaCli	:= SA1->A1_CTACOB
				_cSitCli	:= SA1->A1_SITCOB
			EndIf

			If !Empty(_cBcoCli) .And. !Empty(_cAgeCli) .And. !Empty(_cCtaCli) .And. !Empty(_cSitCli)

				_cBcoScr	:= cBcoOrig
				_cAgeScr	:= cAGenOrig
				_cCtaScr	:= cCtaOrig
				_cSitScr	:= cSituaca

				cBcoOrig	:= _cBcoCli
				cAGenOrig	:= _cAgeCli
				cCtaOrig	:= _cCtaCli
				cSituaca	:= _cSitCli

			EndIf

		EndIf

		Case _nOpc = 2

		If MV_PAR07 == MV_PAR08

			BcoClie(1,MV_PAR07,MV_PAR09)

		EndIf

	EndCase

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณENVEMAIL  บAutor  ณValtenio M.         บ Data ณ  15/01/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static function ENVEMAIL(CODFIL,NUM,PREFIXO,CLIENTE, LOJA)

	Local cCodgHtml := ""
	Local lResultad := .F.
	Local cDestinad := Alltrim(aDatSacado[10]) //"valtenio.oliveira@totvs.com.br" //aDatSacado[10]
	Local cTitulHtm := "Boleto On-Line ESCRIBA"
	Local cNFEletronica := alltrim( Posicione('SF2',1,CODFIL+NUM+PREFIXO+CLIENTE+LOJA,'F2_NFELETR') )
	Local cProtocolo    := SF2->F2_CODNFE
    
	Local nVezes := 0

	cCodgHtml := '<html>'+CRLF
	cCodgHtml += '<head>'+CRLF
	cCodgHtml += '<title>BOLETO ON-LINE</title>'+CRLF
	cCodgHtml += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'+CRLF
	cCodgHtml += '</head>                '+CRLF
	cCodgHtml += '<body>'+CRLF
	cCodgHtml += '<p>Prezado(a):<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF
	cCodgHtml += '<p>Em anexo boleto bancแrio, e link para impressใo da NFSE da Prefeitura, referente a contrato de servi็o da Escriba Informแtica Ltda.<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF
	//If cFilAnt = "010101"
	If SF2->F2_FILIAL = "010101"
		//	    cCodgHtml += '<p>http://isscuritiba.curitiba.pr.gov.br/portalnfse/autenticidade.aspx<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF
		cCodgHtml += '<p>https://isscuritiba.curitiba.pr.gov.br/portalnfse/Default.aspx?doc=82234568000131&num='+ALLTRIM(cNFEletronica)+'&cod='+ALLTRIM(cProtocolo)+'<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF
	Else
		//	    cCodgHtml += '<p>http://sjp.ginfes.com.br<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF
		if val( substr( cNFEletronica, 1, 4 ) ) >= 2017   //Verificacao para nao comprometer o link de consulta da NFS-e de SJP
			cNFEletronica := substr( cNFEletronica, 5, len( cNFEletronica ) - 4 )
		endif
		cCodgHtml += '<p>https://nfe.sjp.pr.gov.br/servicos/validarnfse/validar.php?CCM=60453&verificador='+ALLTRIM(cProtocolo)+'&nrnfs='+ALLTRIM(cNFEletronica)+'<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF
	Endif
	cCodgHtml += '<p>****** Dados para impressao da NFSE ******<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF
	cCodgHtml += '<p>Num RPS : Indicado no boleto<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF
	cCodgHtml += '<p>Serie: E<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF
	//If cFilAnt = "010101"
	If SF2->F2_FILIAL = "010101"
		cCodgHtml += '<p>CNPJ do Prestador: 82.234.568/0001-31<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF
		cCodgHtml += '<p>Inscr. Municipal do Prestador: 01070370945-1<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF
	Else
		cCodgHtml += '<p>CNPJ do Prestador: 82.234.568/0002-12<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF
		cCodgHtml += '<p>Inscr. Municipal do Prestador: 60453<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF
	Endif
	cCodgHtml += '</body>'+CRLF
	cCodgHtml += '</html>'+CRLF
	cCodgHtml += '<p>Qualquer d๚vida, entrar em contato pelo fone: (041) 2106-1212. <em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF
	cCodgHtml += '<p>Atenciosamente, <em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF
	cCodgHtml += '<p>Dpto. Financeiro - Escriba Informแtica Ltda.<em><font size="2" face="Arial, Helvetica, sans-serif"></font></em></p>'+CRLF

	//tira os ENTER, pois a fun็ใo de envio substitui por <BR> <BR>
	cCodgHtml := StrTran(cCodgHtml,CRLF,'')

	 
	cMailServer:= GetNewPar("ES_MAILSRV","smtp.office365.com") //smtp.escriba.com.br
	nMailPorta:= GetNewPar("ES_MAILPRT",587)
	cMailSenha:= GetNewPar("ES_MAILSPSW","Taq80052")    //nfescriba$1
	cMailConta:= GetNewPar("ES_MAILCNT","nfeclientes@escriba.com.br")  

	//Cria a conexใo com o server STMP ( Envio de e-mail )
	oServer := TMailManager():New()
	
	//Protocolos
	If GetMV("MV_RELTLS ")
		oServer:SetUseTLS(.T.)
	Endif
	If GetMV("MV_RELSSL ")	 
		oServer:SetUseSSL(.T.)
	Endif
	
	oServer:Init( "", cMailServer, cMailConta, cMailSenha, 0, nMailPorta )
	   
	//seta um tempo de time out com servidor de 1min
	If oServer:SetSmtpTimeOut( 120 ) != 0
		Alert( "Falha ao setar o time out do e-mail" )
	EndIf
	   
	//realiza a conexใo SMTP
	nErro:= oServer:SmtpConnect(cMailConta, cMailSenha)
	If nErro != 0
		Alert( "Falha ao conectar no servidor. Erro: "+oServer:Geterrorstring(nErro) )
	 	Return .F.
	EndIf	 
	 
	//Autentica็ใo
	If GetMV("MV_RELAUTH") 
	  	oServer:smtpAuth(cMailConta, cMailSenha)
	Endif
	  
	//Apos a conexใo, cria o objeto da mensagem
	oMessage := TMailMessage():New()
	   
	//Limpa o objeto
	oMessage:Clear()
	   
	//Popula com os dados de envio
	oMessage:cFrom              := cMailConta
	oMessage:cTo                := cDestinad
	//oMessage:cCc                := cCopia
	//oMessage:cBcc               := "microsiga@microsiga.com.br"
	oMessage:cSubject           := cTitulhtm
	oMessage:cBody              := cCodgHtml
    
	If oMessage:AttachFile("\boleto\"+AllTrim(aDadosTit[1])+"_.pdf") < 0
		Alert( "Erro ao anexar o arquivo: \boleto\"+AllTrim(aDadosTit[1])+".pdf" )
		Return .F.
    Endif
      
    
    //Envia o e-mail
	nRet:= oMessage:Send(oServer)
	If nRet <> 0
		cErro:= oServer:GetErrorString(nRet) 
	    Alert("Erro ao enviar o e-mail: "+cErro )
	    Return .F.
	EndIf
	   
	//Desconecta do servidor
	If oServer:SmtpDisconnect() != 0
	    Alert( "Erro ao disconectar do servidor SMTP" )
	    Return .F.
	EndIf
    
	/*
	cMailConta:= "valtenio.moura@gmail.com.br" //"vmo@ibest.com.br"
	cMailServer:= "smtp.gmail.com:587" //"smtp.ibest.com.br"
	cMailSenha:= "senha"
	

	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lResult

	If(!lResult)
		Get MAIL ERROR cErro
		MsgAlert(cErro, "Erro durante o envio")
	Else
     
		_cAtach := "\boleto\"+AllTrim(aDadosTit[1])+".pdf"

		While ! File(_cAtach) .And. nVezes <= 15
			Sleep(1000)
			nVezes++
		EndDO

		SEND MAIL FROM cMailConta;
		TO          cDestinad;
		SUBJECT     cTitulHtm;
		BODY        cCodgHtml;
		ATTACHMENT _cAtach   ;
		RESULT      _lResultad

		If !_lResultad
			//Erro no Envio do e-mail
			GET MAIL ERROR cError
			Msgbox("Erro no envio de e-Mail"+chr(13)+cError)
		Endif

		DISCONNECT SMTP SERVER

	EndIf 
	*/
Return


static function titulo(nLinhas)
	default nLinhas := 0
return 20 + (nLinhas * 35)

static function valor()
return 80

static function valor2()
return 60















/*
xSanVerfBar(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,;
					Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5]	,;
					cNroDoc,(SE1->E1_SALDO - nVlrAbat),cCarteira,'9',SE1->E1_VENCTO,aDadosBanco[8],cConvenio)
*/
Static Function xSanVerfBar(cPrefixo,cNumero,cParcela,cTipo,cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,cCart,cMoeda,dVencto,cConvenio)

	LOCAL cValorFinal   := strzero(nValor*100,10)
	LOCAL nDvnn			:= 0
	LOCAL nDvcb			:= 0
	LOCAL nDv			:= 0
	LOCAL cNN			:= ''
	LOCAL cRN			:= ''
	LOCAL cCB			:= ''
	LOCAL cS				:= ''
	LOCAL cFator      := strzero(dVencto - ctod("07/10/97"),4)
	LOCAL cCart			:= "109"

		cCart := "9"
		//-----------------------------
		// Definicao do NOSSO NUMERO
		// ----------------------------
		//alterado jonatas
		//cS    := Alltrim(Str(Val(cNroDoc))) //Bruno 08/07/2011 problemas com o digito verificador do nosso numero
		//nDvnn := modulo11(cS,.T.) // digito verificador Nosso Num
		//cNN   := PADL(cS + AllTrim(Str(nDvnn)),8,"0")
		//fim alteracao
		//cNN   := PADL(cS + AllTrim(Str(nDvnn)),11,"0") //Bruno Gomes da Silva 19/04/2011 - Erro no codigo de barra do boleto.
		cNN   := u_NNSANT() //Funcao para o Nosso Numero Santander


		//----------------------------------
		//	 Definicao do CODIGO DE BARRAS
		//----------------------------------
		cS    := cBanco + cMoeda + cFator +  cValorFinal + cCart + SUBSTR(Trim(cConvenio),1,LEN(TRIM(cConvenio)))  + cNN + "0" + "101"
		nDvcb := SanMod11(cS,.F.)
		cCB   := SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5,43)

		//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
		//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
		//	AAABC.DDDDE		FFFFF.FFFNNY	NNNNN.NNNNNZ	UUUUVVVVVVVVVV

		// 	CAMPO 1:
		//  AAA = Codigo do banco na Camara de Compensacao
		//    B = Codigo da moeda, sempre 9 Nacional 8 Outras Moedas
		//    C = Fixo 9
		// DDDD = Codigo Cedente (4 primeiros digitos)
		//    E = calculado pelo Modulo 10

		//cS    := cBanco + "9" + cCart + SubStr(cConvenio,2,4) alterado jonatas
		cS    := cBanco + "9" + cCart + SubStr(cConvenio,1,4)
		nDv   := SanMod10(cS)
		cRN   := cS + "." + AllTrim(Str(nDv)) + " "

		// 	CAMPO 2:
		//    FFFF = Codigo do Dedente (3 ultimos digitos)
		// NNNNNNN = 2 primeiros digitos do nosso numero
		//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

		//cS    := SUBSTR(cConvenio,6,3) + "00000" + LEFT(cNN,2)Alterado JONATAS
		cS	  := SUBSTR(cConvenio,5,3) + Substr(cNN,1,7)
		nDv   := SanMod10(cS)
		cRN   := cRN + cS + "." + Alltrim(Str(nDv)) + " "

		// 	CAMPO 3:
		//	  N = Restante do Nosso Numero
		//	  N = FIXO '0'
		//	NNN = TIPO DE MODALIDADE CARTEIRA
		//	  Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
		//cS    := SUBSTR(cNN,3,6) + "0" + "101" alterado jonatas
		cS    := SUBSTR(cNN,8,6) + "0" + "101"
		nDv   := SanMod10(cS)
		cRN   := cRN + cS + "." + Alltrim(Str(nDv)) + " "

		//	CAMPO 4:
		//	     K = DAC do Codigo de Barras
		cRN   := cRN + AllTrim(Str(nDvcb)) + " "

		// 	CAMPO 5:
		//	      UUUU = Fator de Vencimento
		//	VVVVVVVVVV = Valor do Titulo
		cRN   := cRN + cFator + StrZero((nValor*100),10)

		cRN := TransForm(RetNum(cRN),'@R 99999.99999 99999.999999 99999.999999 9 99999999999999')

Return({cCB,cRN,cNN})


Static Function SanMod11(cData,lNossoNum_DV)
	Local L := Len(cdata)
	Local D := 0
	Local P := 1
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		End
		L := L - 1
	End
	If lNossoNum_DV
		D := mod(D,11)
		If D == 10
			D := 1
		ElseIf D == 0 .OR. D == 1
			D := 0
		Else
			D := 11 - D
		EndIf
	Else
		D := D * 10
		D := mod(D,11)
		If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
			D := 1
		EndIf
	EndIf
Return(D)

Static Function SanMod10(cData)
	LOCAL L,D,P := 0
	LOCAL B     := .F.
	L := Len(cData)
	B := .T.
	D := 0
	While L > 0
		P := Val(SubStr(cData, L, 1))
		If (B)
			P := P * 2
			If P > 9
				P := P - 9
			End
		End
		D := D + P
		L := L - 1
		B := !B
	End
	D := 10 - (Mod(D,10))
	If D = 10
		D := 0
	End
Return(D)
