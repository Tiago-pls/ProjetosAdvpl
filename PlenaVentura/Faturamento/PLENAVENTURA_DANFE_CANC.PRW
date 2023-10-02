
/**---------------------------------------------------------------------------------------------------------------**/
/** PROPRIETÁRIO: 		       																  	 		          **/
/** MODULO		: Faturamento 																					  **/
/** NOME 		: RFAT010.RPW																					  **/
/** FINALIDADE	: Geração de DANFE DE CANCELAMENTO E INUTILIZAÇAO												  **/
/** SOLICITANTE	: Fernando Nonato					                                                           	  **/
/** DATA 		: 																								  **/
/** RESPONSÁVEL	: TOTVS CURITIBA																				  **/
/**---------------------------------------------------------------------------------------------------------------**/
/**                                          DECLARAÇÃO DAS BIBLIOTECAS                                           **/
/**---------------------------------------------------------------------------------------------------------------**/
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include "colors.ch"
#INCLUDE "Tbiconn.ch"
#INCLUDE "rptDef.ch"
#INCLUDE "FWPrintSetup.ch"



#DEFINE IMP_SPOOL 2

#DEFINE VBOX       080
#DEFINE VSPACE     008
#DEFINE HSPACE     010
#DEFINE SAYVSPACE  008
#DEFINE SAYHSPACE  008
#DEFINE HMARGEM    030
#DEFINE VMARGEM    030


User Function DFECANC()
	Local aArea := GetArea()		//Grava a area
	Local cNomeRel  := ""		  	//Nome do relatório
	Local lAtoL		:= .F.		  	//Ajusta o relatório nas proporções
	Local lDs		:= .F.		  	//Disable setup
	Local cLocal    := "\spool"   	//Local de impressao
	Local lRodou 	:= .F.
	Local cPerg		:= "DFECANC"

	Local nHErp := AdvConnection()
	Local cDBTSS:= "ORACLE/TSS_Prod"	//Comunicação com TSS
	Local cSrv  := "10.5.1.228"	//IP do servidor a ser acessado
	Local nConTSS
	Local cQryS := ""

	Private nI		:= 0			//Contador
	Private oDFE 	:= Nil			//Objeto de impressão
	Private aDados 	:= {}			//Dados dos títulos
//////////////////////////////////////////////////////////////
	Private _cTopAlias := "TSS_Prod"         //DEFINIÇAO DO SHEMA DE AMBIENTE ALIAS
	Private _cTopDB    := "ORACLE"       //BANCO DE DADOS UTILIZADO
	Private _cTopSrv   := "10.5.1.228" //= IP DO SERVIDOR
	Private _cTopSrvN  := "10.5.1.228"
	Private cTopServer
	Private cTopAlias

	If "DESENV" $ Upper(GetEnvServer())
		_cTopSrv   := "10.5.1.32" //= IP DO SERVIDOR
		_cTopSrvN  := "10.5.1.32"
		Private _cTopAlias := "desenv_tss"         //DEFINIÇAO DO SHEMA DE AMBIENTE ALIAS
	Endif
	If Pergunte (cPerg,.T.)
		cTop         := GetPvProfString("SPED","TOPALIAS",_cTopAlias,GetAdv97())
		cTopData     := GetPvProfString("SPED","TOPDATABASE",_cTopDB,GetAdv97())
		cTopAlias    := cTopData + "/" + cTop
		cTopServer   := GetPvProfString("SPED","TOPSERVER",_cTopSrv,GetAdv97())

		LjMsgRun("Conectando em " + cTopAlias + " " + cTopServer,,,)
		TCConType("TCPIP")
		nCon := TCLINK(AllTrim(cTopAlias),AllTrim(cTopServer),7892)

		If nCon < 0
			MsgStop("Erro conectando SPED 7892: " + alltrim(Str(nCon)) + " - " + AllTrim(cTopAlias) + "-" + AllTrim(cTopServer))
			Return .f.
		endif
//////////////////////////////////////////////////////////////

/**/

		//Define o nome do relatório
		cNomeRel := "DANFE-" + Dtos(Date()) + StrTran(Time(), ":", "")

		//Relatório
		oDFE := FWMSPrinter():New(cNomeRel, IMP_PDF, lAtoL, cLocal, lDS, , , , , , .F., )

	//validPerg()
	


		//Conexoes BDs
	//	nConTSS := TcLink(cDbTSS,cSrv,7890)

		//Inicio Conexao SPED050
		//TCSETCONN(nConTSS)

		/*
		Tabela SF3
		F3_CHVNFE
		F3_CODSREF – 101 = Cancelada | 102 = Inutilizada
		F3_DTCANC – tem que estar em branco
		F3_NFISCAL
		F3_SERIE
		F3_PROTOC – Protocolo de cancelamento
		
		Tabela SPED050
		STATUSCANC – 2 = cancelada / inutilizada
		NFE_PROT – Protocolo
		TIPO_CANC – 1 = Cancelamento | 2 = Inutilização
		DOC_CHV
		NFE_ID – Serie + Nota
		
		SPED054
		NFE_CHV
		NFE_ID
		CSTAT_SEFR – 101 = Cancelada | 102 = Inutilizada
		DTREC_SEFR – Data cancelamento / inutilização
		HRREC_SEFR – Hora cancelamento / inutilização
		NFE_PROT – Protocolo
		
		*/
		cQryS := " SELECT SPED054.CSTAT_SEFR STATUS, SPED054.DTREC_SEFR DATA_P, SPED054.HRREC_SEFR HORA_P, "
		cQryS += " SPED054.NFE_CHV CHAVE, SPED054.NFE_PROT PROTOCOLO, DOC_ID, DOC_SERIE, "
		cQryS += " substr(Trim( UTL_RAW.CAST_TO_VARCHAR2( DBMS_LOB.SUBSTR( SPED050.xml_erp,2000 ) ) ) , "
		cQryS += " INSTR(Trim( UTL_RAW.CAST_TO_VARCHAR2( DBMS_LOB.SUBSTR( SPED050.xml_erp,2000 ) ) ),'<tpNF>')+6 ,1) TPNF"
		cQryS += " FROM SPED050 "
		cQryS += " RIGHT JOIN SPED001 ON SPED001.ID_ENT = SPED050.ID_ENT AND SPED001.D_E_L_E_T_ = ' ' "
		cQryS += " LEFT JOIN SPED054 ON SPED054.NFE_ID = SPED050.NFE_ID and SPED054.ID_ENT =SPED050.ID_ENT "
		cQryS += "		AND SPED054.D_E_L_E_T_ = ' ' "
		cQryS += " WHERE STATUS = '7' AND STATUSCANC = '2' AND SPED050.D_E_L_E_T_ = ' ' "
		cQryS += " AND SPED050.NFE_ID BETWEEN '" + MV_PAR03+MV_PAR01 + "' "
		cQryS += " 						  AND '" + MV_PAR03+MV_PAR02 + "' "
		cQryS += " AND SPED001.CNPJ = '" + SM0->M0_CGC + "' AND SPED001.IE = '" + SM0->M0_INSC + "' "
		cQryS += " AND SPED054.R_E_C_N_O_ = (SELECT MAX(SP54.R_E_C_N_O_) FROM SPED054  SP54 "
		cQryS += " WHERE SP54.NFE_ID = SPED050.NFE_ID AND SP54.ID_ENT = SPED050.ID_ENT "
		cQryS += "		AND SP54.D_E_L_E_T_ = ' ') "
		cQryS := ChangeQuery(cQryS)

		TCQuery cQryS NEW ALIAS "SPED"

		DbSelectArea("SPED")
		SPED->(DbGoTop())
		While !SPED->(Eof())

			DFECANCA(oDFE) //Chama a rotina de impressão da nota
			lRodou := .T.
			SPED->(Dbskip())

		EndDo
		SPED->(DbCloseArea())


		TcUnlink(nConTSS)
	endif
	If !lRodou // Se não gerou nenhum boleto sai da rotina
		Return nil
	Endif

	//Verifica se houve impressao
	If (oDFE:nModalResult == PD_OK)
		//Verifica se foi cancelado
		If !(oDFE:Canceled())
			//Visualiza
			oDFE:Preview()
		EndIf
	EndIf

	//Descarrega spool
	Ms_Flush()

//Restaura a área
	RestArea(aArea)

Return


Static Function DFECANCA()
	Local nx
	Local   xBitMap := FisxLogo("1")     ///Logotipo da empresa

	PRIVATE oFont06    := TFontEx():New(odfe,"Times New Roman",06,06,.F.,.T.,.F.)
	PRIVATE oFont10N   := TFontEx():New(odfe,"Times New Roman",08,08,.T.,.T.,.F.)// 1
	PRIVATE oFont07N   := TFontEx():New(odfe,"Times New Roman",06,06,.T.,.T.,.F.)// 2
	PRIVATE oFont07    := TFontEx():New(odfe,"Times New Roman",06,06,.F.,.T.,.F.)// 3
	PRIVATE oFont08    := TFontEx():New(odfe,"Times New Roman",07,07,.F.,.T.,.F.)// 4
	PRIVATE oFont08N   := TFontEx():New(odfe,"Times New Roman",06,06,.T.,.T.,.F.)// 5
	PRIVATE oFont09N   := TFontEx():New(odfe,"Times New Roman",08,08,.T.,.T.,.F.)// 6
	PRIVATE oFont09    := TFontEx():New(odfe,"Times New Roman",08,08,.F.,.T.,.F.)// 7
	PRIVATE oFont10    := TFontEx():New(odfe,"Times New Roman",09,09,.F.,.T.,.F.)// 8
	PRIVATE oFont11    := TFontEx():New(odfe,"Times New Roman",10,10,.F.,.T.,.F.)// 9
	PRIVATE oFont12    := TFontEx():New(odfe,"Times New Roman",11,11,.F.,.T.,.F.)// 10
	PRIVATE oFont11N   := TFontEx():New(odfe,"Times New Roman",10,10,.T.,.T.,.F.)// 11
	PRIVATE oFont18N   := TFontEx():New(odfe,"Times New Roman",17,17,.T.,.T.,.F.)// 12
	PRIVATE OFONT12N   := TFontEx():New(odfe,"Times New Roman",11,11,.T.,.T.,.F.)// 12

	Private PixelX := oDFE:nLogPixelX()
	Private PixelY := oDFE:nLogPixelY()


	oDFE:StartPage()
	nHPage := oDFE:nHorzRes()
	nHPage *= (300/PixelX)
	nHPage -= HMARGEM
	nVPage := oDFE:nVertRes()
	nVPage *= (300/PixelY)
	nVPage -= VBOX



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 1 IDENTIFICACAO DO EMITENTE                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDFE:Box(042,000,137,250)
	oDFE:Say(052,098, "Identificação do emitente",oFont12N:oFont)
	nLinCalc	:=	065
	cStrAux		:=	Alltrim(SM0->M0_NOME)
	nForTo		:=	Len(cStrAux)/25
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDFE:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
		nLinCalc+=10
	Next nX

	cStrAux		:=	Alltrim(SM0->M0_ENDCOB)
	nForTo		:=	Len(cStrAux)/40
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDFE:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
		nLinCalc+=10
	Next nX

	cStrAux		:=	Alltrim(SM0->M0_COMPCOB)
	nForTo		:=	Len(cStrAux)/40
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDFE:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
		nLinCalc+=10
	Next nX

	oDFE:Say(nLinCalc,098, Alltrim(SM0->M0_BAIRCOB) + " Cep: " + Alltrim(SM0->M0_CEPCOB),oFont08N:oFont)
	nLinCalc+=10
	oDFE:Say(nLinCalc,098, Alltrim(SM0->M0_CIDCOB) + "/" + SM0->M0_ESTCOB,oFont08N:oFont)
	nLinCalc+=10
	oDFE:Say(nLinCalc,098, "Fone: " + SM0->M0_TEL,oFont08N:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 2                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oDFE:Box(042,248,137,351)
	oDFE:Say(055,275, "DANFE",oFont18N:oFont)
	oDFE:Say(065,258, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
	oDFE:Say(075,258, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
	oDFE:Say(085,266, "0-ENTRADA",oFont08:oFont)
	oDFE:Say(095,266, "1-SAÍDA"  ,oFont08:oFont)
	oDFE:Box(078,315,095,325)
	oDFE:Say(089,318, SPED->TPNF,oFont08N:oFont)

	oDFE:Say(110,255,"N. "+StrZero(Val(SPED->DOC_ID),9),oFont10N:oFont)
	oDFE:Say(120,255,"SÉRIE "+ SPED->DOC_SERIE,oFont10N:oFont)
	oDFE:Say(130,255,"FOLHA 1/1",oFont10N:oFont)

//oDFE:SayBitmap(045,005,"\System\lgrl09.BMP",090,090)
	oDFE:SayBitmap(045,005,xBitMap,090,090)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 3         		                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oDFE:Box(042,350,137,603)
	IF SPED->STATUS = "101" // CANCELADA
		oDFE:Say(085,355,"NF-E CANCELADA",oFont18N:oFont)
	ELSEIF SPED->STATUS = "102" // INUTILIZADA
		oDFE:Say(085,355,"NF-E INUTILIZADA",oFont18N:oFont)
	ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Corpo de Mensagem                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	oDFE:Say(300,003, "CHAVE DE ACESSO DA NFE: " + SPED->CHAVE,oFont18N:oFont)

	IF SPED->STATUS = "101" // CANCELADA
		oDFE:Say(325,003, "PROTOCOLO CANCELAMENTO: " + SPED->PROTOCOLO,oFont18N:oFont)
	ELSEIF SPED->STATUS = "102" // INUTILIZADA
		oDFE:Say(325,003, "PROTOCOLO INUTILIZAÇÃO: " + SPED->PROTOCOLO,oFont18N:oFont)
	ENDIF

	oDFE:Say(350,003, "DATA ENVIO/HOMOLOGAÇÃO: " + dtoc(stod(SPED->DATA_P)) + " " + SPED->HORA_P,oFont18N:oFont)

Return


/*
Tabela SF3
F3_CHVNFE
F3_CODSREF – 101 = Cancelada | 102 = Inutilizada
F3_DTCANC – tem que estar em branco
F3_NFISCAL
F3_SERIE
F3_PROTOC – Protocolo de cancelamento

Tabela SPED050
STATUSCANC – 2 = cancelada / inutilizada
NFE_PROT – Protocolo
TIPO_CANC – 1 = Cancelamento | 2 = Inutilização
DOC_CHV
NFE_ID – Serie + Nota

SPED054
NFE_CHV
NFE_ID
CSTAT_SEFR – 101 = Cancelada | 102 = Inutilizada
DTREC_SEFR – Data cancelamento / inutilização
HRREC_SEFR – Hora cancelamento / inutilização
NFE_PROT – Protocolo

*/

/*
Static Function ValidPerg

	_cAlias := Alias()
	cPerg := "DFECANC"
	PutSX1(cPerg, "01", "Da Nota Fiscal?"        , "", "", "mv_ch1" , "C", 09,  0, 0, "G", "", "", "", "", "mv_par01", "","","","","","","","","","","","","","","","")
	PutSX1(cPerg, "02", "Ate Nota Fiscal?"       , "", "", "mv_ch2" , "C", 09,  0, 0, "G", "", "", "", "", "mv_par02", "","","","","","","","","","","","","","","","")
	PutSX1(cPerg, "03", "Da Serie?"              , "", "", "mv_ch3" , "C", 03,  0, 0, "G", "", "", "", "", "mv_par03", "","","","","","","","","","","","","","","","")

	dbSelectArea(_cAlias)
Return

*/
