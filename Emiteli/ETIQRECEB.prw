#Include "Protheus.ch"  
#include 'rwmake.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SMSA008
Ponto de entrada: Realiza a impressão da etiqueta via Documento de Entrada

@author    Alfred Andersen
@version   1.00
@since     07/12/2018

/*/
User Function ETIQRECE()

Local cQuery    := ""
Local cPorta    := SUPERGETMV("MV_ZIMPORT", .F., "LPT1") 
Local cModelo   := SUPERGETMV("MV_ZMODEL" , .F., "ZEBRA") 
local cFont1 	:= "022,013" //Fonte maior - títulos dos campos obrigatórios do DANFE ("altura da fonte, largura da fonte")
local cFont2 	:= "020,008" //Fonte menor - campos variáveis do DANFE ("altura da fonte, largura da fonte")
local cFont3 	:= "018,008" //Fonte menor - campos variáveis do DANFE ("altura da fonte, largura da fonte")
local cFont3C 	:= "029,001" //Fonte menor - campos variáveis do DANFE ("altura da fonte, largura da fonte")

local cFont4 	:= "014,008" //Fonte menor - campos variáveis do DANFE ("altura da fonte, largura da fonte")
local cFont5 	:= "012,008" //Fonte menor - campos variáveis do DANFE ("altura da fonte, largura da fonte")
local cFont6 	:= "010,008" //Fonte menor - campos variáveis do DANFE ("altura da fonte, largura da fonte")
local cFont7 	:= "008,009" //Fonte menor - campos variáveis do DANFE ("altura da fonte, largura da fonte")
local cFont8 	:= "005,006" //Fonte menor - campos variáveis do DANFE ("altura da fonte, largura da fonte")
//Cria a pergunta de acordo com o tamanho da SX1
Static oDlg

    cQuery := "SELECT D1_COD, D1_LOTECTL, D1_QUANT, D1_DTDIGIT, D1_DTVALID, D1_DOC " 
    cQuery += " FROM "+RetSQLName("SD1")+" SD1 "
	cQuery += " WHERE D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_ = ' '"
    cQuery += " AND D1_DOC = '"+SF1->F1_DOC+"' AND D1_SERIE = '"+SF1->F1_SERIE+"' "
    cQuery += "  AND D1_FORNECE = '"+SF1->F1_FORNECE +"'"
    cQuery += " AND D1_LOJA = '"+SF1->F1_LOJA+"' "
    
    TCQUERY cQuery New Alias NSD1
    DbSelectArea("NSD1")
    NSD1->(DbGoTop())
	nCont :=0
    DO WHILE NSD1->(!EOF())
		nCont +=1
		cCaixa := "00001"
		cTitulo:= ""		
		cMensagem := 'Qtd Etiquetas Item ' + cValToChar(nCont)
	//	_nEtq 	:= iif(NSD1->B1_QE <= 0,1,NSD1->B1_QE) * MV_PAR02
	    DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 100,300 PIXEL   //monta janela

		//posicionamento dos objetos
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 100,300 PIXEL   //monta janela 
			@005,005 TO 045,145 OF oDlg PIXEL                          //borda interna
			@015,020 SAY cMensagem SIZE 060,007 OF oDlg PIXEL             //label
			@015,085 MSGET cCaixa SIZE 055,011 OF oDlg PIXEL			
			DEFINE SBUTTON FROM 030,025 TYPE 1 ACTION (oDlg:End()) ENABLE OF oDlg   		
		ACTIVATE MSDIALOG oDlg CENTERED 

		_nEtx	:= 0

		_nEtiq :=  val(cCaixa)//NSD1->D1_QUANT / MV_PAR02
		
		//Calcula o resto da divisao    
		_nRest := NSD1->D1_QUANT %  _nEtiq //MV_PAR02

		if _nRest > 0 
			_nEtiq := Round(val(STR(INT(_nEtiq)) + ".9"),0)
		ENDIF
		
		DO WHILE _nEtx < _nEtiq //Descomentado Senne 20220808

			_nEtx := _nEtx + 1
			
			MSCBPRINTER(cModelo, cPorta,,10,.F.,,,,,,.F.,)
			MSCBCHKSTATUS(.F.)
			MSCBBEGIN(1,6)   
			MSCBBox(00,00,70,40)
			MSCBLineH(00,00,70,70,"B")

			//cTx := ALLTRIM(NSD1->B1_DESC)
			cTx := Alltrim(GetadvFval("SB1","B1_DESC",xFilial("SB1")+NSD1->D1_COD,1))
			IND := 70
			if len(alltrim(cTx)) > IND
				DO WHILE SUBSTR(cTx,IND,1) != " " 
					If IND < 61 
						EXIT
					ENDIF
					If SUBSTR(cTx,IND,1) == ""
						EXIT
					ENDIF
					IND := IND - 1
				END DO
			endif
			cTx := SUBSTR(cTx,1,IND - 1)

			MSCBSay(01, 03, cTx, "N", "B", cFont3C,.T.)	

			MSCBSay(01, 11, "Cod:", "N", "A", cFont5,.F.)		
			MSCBSay(08, 10, NSD1->D1_COD, "N", "A", cFont2,.F.)	
			//			 1    2          3               4	   5	  6    7    8    9  10  11  12  13   14   15   16
			//MSCBSayBar(03, 13, ALLTRIM(NSD1->D1_COD), "N", "MB07", 5.5, .F., .F., .F., , 2.5, 1, .F., .F., "1", .F.)
			MSCBSayBar(03, 13, ALLTRIM(NSD1->D1_COD), "N", "MB07", 5.5, .F., .F., .F., , 1.5, 1, .F., .F., "1", .F.)

			MSCBSay(48, 11, "NF:", "N", "A", cFont5,.F.)		

			MSCBSay(53, 10, NSD1->D1_DOC, "N", "A", cFont2,.F.)		

			MSCBSay(01, 21, "Lote:", "N", "A", cFont5,.F.)		
			MSCBSay(11, 20, NSD1->D1_LOTECTL + " - " + alltrim(str(_nEtx)) + "/" + alltrim(str(_nEtiq)) , "N", "A", cFont2,.F.)		
			MSCBSayBar(03, 23, ALLTRIM(NSD1->D1_LOTECTL), "N", "MB07", 5.5, .F., .F., .F., , 1.5, 1, .F., .F., "1", .F.)

			MSCBSay(01, 32, "   Quant:", "N", "A", cFont6,.F.)		

			if _nEtx == _nEtiq .AND. _nRest > 0 
				MSCBSay(20, 31, ALLTRIM(Transform(Val(STR(_nRest)),"@e 9,999,999.99")), "N", "A", cFont3,.F.)		
			else
				//MSCBSay(20, 31, ALLTRIM(Transform(Val(STR(MV_PAR02)),"@e 9,999,999.99")), "N", "A", cFont3,.F.)		
				MSCBSay(20, 31, ALLTRIM(Transform(_nEtiq,"@e 9,999,999.99")), "N", "A", cFont3,.F.)		
			ENDIF

			MSCBSay(01, 35, " Entrada:", "N", "A", cFont6,.F.)		
			MSCBSay(20, 34, DTOC(STOD(NSD1->D1_DTDIGIT)), "N", "A", cFont3,.F.)		

			MSCBSay(01, 38, "Validade:", "N", "A", cFont6,.F.)		
			MSCBSay(20, 37, DTOC(STOD(NSD1->D1_DTVALID)), "N", "A", cFont3,.F.)		

			MSCBSay(54, 17, "Recontagem", "N", "A", cFont7,.F.)		

			MSCBLineH(56,19,69,1)
			MSCBLineH(56,23,69,1)
			MSCBLineH(56,27,69,1)
			MSCBLineH(56,31,69,1)
			MSCBLineH(50,35,69,1)

			MSCBLineV(56,19,35,1)
			MSCBLineV(69,19,39,1)

			MSCBSay(44, 36, "End:", "N", "A", cFont7,.F.)		


			MSCBLineH(50,39,69,1)
			//MSCBLineH(56,43,91,1)

			MSCBLineV(50,35,39,1)
			//MSCBLineV(91,45,52,1)

			cTx :=  GetadvFval("SB1","B1_DESC",xFilial("SB1")+NSD1->D1_COD,1)
			IND := 25
				DO WHILE SUBSTR(cTx,IND,1) != " " 
					IF IND > 10
						EXIT
					ENDIF
					IND := IND - 1
				END DO
			cTx := SUBSTR(cTx,1,IND - 1)
			MSCBSay(38, 30, cTx, "N", "A", cFont8,.F.)		

			MSCBEND()

			MSCBCLOSEPRINTER()	
		ENDDO //descomentado Senne - 20220808

    NSD1->(dbSkip())
    ENDDO
    NSD1->(DBCLOSEAREA("NSD1"))	 

//PutMV("MV_PAR02",0)
//SCHGETNF()

RETURN


Static Function GeraPerg(cPerg)
Local aRegs:= {}

aAdd(aRegs,{cPerg,"01","Qtd Caixas do Item"         ,"Qtd Caixas do Item"        ,"Qtd Caixas do Item"       ,"mv_ch1","N",10,0,0,"G"," ","mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})

U_BuscaPerg(aRegs)

Return

/*Static Function SCHGETNF()
	Local aArea	:= GetArea()
	Local aPROFALIASArea	:= PROFALIAS->(GetArea())
	Local _CR     := chr(13)
	Local _LF     := chr(10)
	Local cLinha     := ""
	Local cPerg     := padr(alltrim("QIE210"),10," ")


	Pergunte("QIE210",.F.)

		PutMV("MV_PAR02",0.00)
		MV_PAR02 := 0.00


	If Select("PROFALIAS") <= 0 
		dbUseArea(.T., "CTREECDX", "\profile\profile.usr", "PROFALIAS", .T., .F.)
	EndIf	
	
	cLinha     := "N#C#1" +_CR+_LF + "N#G# 1200.00" +_CR+_LF + "C#G#351      " +_CR+_LF + "C#G#VIZ"

	DbSelectArea("PROFALIAS")    
	DbsetOrder(1)
	// "000026              " + "QIE210    " + "PERGUNTE  " + "MV_PAR    " + "01"
	If DbSeek(RetCodUsr( ) + SPACE(20-LEN(RetCodUsr( ))) + cPerg + "PERGUNTE  " + "MV_PAR    " + SM0->M0_CODIGO)
		RecLock("PROFALIAS",.F.)
			PROFALIAS->P_DEFS:=cLinha
		PROFALIAS->(Msunlock())
	EndIf 

	DbSelectArea("SX1")    
	DbsetOrder(1)
	If DbSeek(cPerg + "02")
		RecLock("SX1",.F.)
			SX1->X1_CNT01 := "0.00"
		SX1->(Msunlock())
	EndIf 

RestArea(aPROFALIASArea)
RestArea(aArea) 

Return */
