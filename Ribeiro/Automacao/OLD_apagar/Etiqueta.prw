#Include "Protheus.ch"
#DEFINE CRLF ( chr(13)+chr(10) )
/*
+----------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Ponto de Entrada                                        !
+------------------+---------------------------------------------------------+
!Módulo            ! SIGAACD                                                 !
+------------------+---------------------------------------------------------+
!Nome              ! RACD001                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Rotina de Impressão de etiqueta de identificaçao de     !
!                  ! volumes.                                                !
+------------------+---------------------------------------------------------+
!Autor             ! A.Effting                                               !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 10/02/2017                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

User Function RACD001(_cAlias,_nReg,_nOpc)
Local lOk := .F.
Local cPerg := "RACD001   "

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Declaração de cVariable dos componentes                                 ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Private nCopias    := 1
Private cDetEtiq   := ""
Private cTextEtiq1 := ""
Private cTextEtiq2 := ""
Private nVolumes   := 0
Private nTamanho  := 1
Private cDir := "c:\temp\"


/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Declaração de Variaveis Private dos Objetos                             ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Private oDlg1     := Nil
Private oSay1     := Nil
Private oSay2     := Nil
Private oSay3     := Nil
Private oSay4     := Nil
Private oSay5     := Nil
Private oRMenu1   := Nil
Private oDetEtiq  := Nil
Private oGet1     := Nil
Private oTextEtiq := Nil
Private oVolumes  := Nil
Private oBtn2     := Nil
Private oBtn3     := Nil
Private oMeter    := Nil
Private _cBarra   := ""
Private lHasButton := .T.

If !ExistDir(cDir)
	MakeDir(cDir)
Endif

cTextEtiq1 := Alltrim(MemoRead("c:\temp\etiq_1_"+Alltrim(CB7->CB7_ORDSEP)+".txt"))
cTextEtiq2 := Alltrim(MemoRead("c:\temp\etiq_2_"+Alltrim(CB7->CB7_ORDSEP)+".txt"))

//Posiciona Pedido de Vendas
DbSelectArea("SC5")
SC5->(DbSetOrder(1))
SC5->(DbSeek(CB7->CB7_FILIAL+CB7->CB7_PEDIDO))

DbSelectArea("SA1")
SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

DbSelectArea("SA4")
SA4->(DbSetOrder(1))
SA4->(DbSeek(xFilial("SA4")+SC5->C5_TRANSP))

nVolumes := SC5->C5_VOLUME1

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
oDlg1      := MSDialog():New( 092,232,661,862,"Emissão de Etiquetas de Volumes",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,120,{||"Detalhes"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay2      := TSay():New( 068,012,{||"Cópias"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
oSay3      := TSay():New( 120,008,{||"Texto da Etiqueta"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
oSay4      := TSay():New( 185,017,{||"Volumes"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)

cDetEtiq := ""
cDetEtiq += "Ordem de Separação: "+Alltrim(CB7->CB7_ORDSEP)+CRLF
cDetEtiq += "Pedido de vendas  : "+Alltrim(CB7->CB7_PEDIDO)+CRLF
cDetEtiq += "Volumes: "+Alltrim(SC5->C5_ESPECI1)           +CRLF
cDetEtiq += "Qtde Volumes: "+cValToChar(nVolumes)   +CRLF

If Empty(cTextEtiq1) .OR. cTextEtiq1 == CRLF
	cTextEtiq1 := cValToChar(nVolumes)+" VOLUMES"+CRLF
	cTextEtiq1 += Alltrim(SA1->A1_NREDUZ)+CRLF	
	cTextEtiq1 += Alltrim(SA1->A1_MUN)+"-"+Alltrim(SA1->A1_EST)+CRLF
	cTextEtiq1 += Alltrim(SA4->A4_NREDUZ)+CRLF
EndIf

If Empty(cTextEtiq2) .OR. cTextEtiq1 == CRLF
	cTextEtiq2 := Alltrim(cValToChar(nVolumes))+" VOLUMES"+CRLF
	cTextEtiq2 += Alltrim(SA1->A1_NREDUZ)+CRLF
	cTextEtiq2 += Alltrim(SA1->A1_MUN)+"-"+Alltrim(SA1->A1_EST)+CRLF
	cTextEtiq2 += Alltrim(SA4->A4_NREDUZ)+CRLF
EndIf

cTextEtiq := cTextEtiq1

//If Empty(cTextEtiq2)
//	cTextEtiq := cTextEtiq2
//EndIf

//--- progress bar ---
nMeter := 0          
nTotal := 0
oMeter := TMeter():New(218,012,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oDlg1,200,100,,.T.,,,.F.)		

oSay5      := TSay():New( 224,012,{||_cBarra},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)

GoRMenu1   := TGroup():New( 009,008,056,100,"Opções",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oRMenu1    := TRadMenu():New( 020,021,{"Pequena (Volumes)","Grande (Pallet)"},{|u| If(PCount()>0,nTamanho:=u,nTamanho)},oDlg1,,{|| U_RACD01T(nTamanho) },CLR_BLACK,CLR_WHITE,"",,,072,23,,.F.,.F.,.T. )

oDetEtiq   := TMultiGet():New( 012,120,{|u| If(PCount()>0,cDetEtiq:=u,cDetEtiq)},oDlg1,176,096,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.T.,,,.F.,,  )
oDetEtiq:lWordWrap = .T.

oGet1 := TGet():New( 066,032,{|u| If( PCount() == 0, nCopias, nCopias := u ) },oDlg1,020,008,"@E 999",,CLR_BLACK, CLR_WHITE,,.F.,,.T.,  ,.F.,,.F.,.F.,,.F.,.F.,  ,"nCopias",,,,lHasButton  )
//oGet1 := TGet():New( 066,032,{|u| If(PCount()>0,nCopias:=u,nCopias)}       ,oDlg1,020,008,''      ,,CLR_BLACK, CLR_WHITE,,   ,,.T.,"",   ,,.F.,.F.,,.F.,.F.,"","nCopias",,)

oTextEtiq   := TMultiGet():New( 132,008,{|u| If(PCount()>0, cTextEtiq := u, cTextEtiq)},oDlg1,288,044,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
oTextEtiq:lWordWrap = .T.

//#######
//oTMultiget1 := TMultiget():New(  83, 63,{|u| If(Pcount()>0, cJustIfi  := u,  cJustIfi)},oPnlA,300, 45,,,         ,         ,,.T.,  ,,,,,.F.,{|u| If(len(cJustIfi) > 254, GFEMsgErro("O tamanho máximo de caracteres para a descrição do motivo é de 254."+CRLF+CRLF+"- A descrição informada possui "+Alltrim(Str(Len(cJustIfi)))+ " caracteres."),.T. )})
//oTMultiget1:EnableVScroll( .T. )
//oTMultiget1:GoEnd()
//oTMultiget1:Refresh()
//#######

oVolumes := TGet():New( 183,045,{|u| If( PCount() == 0, nVolumes, nVolumes := u ) },oDlg1,020, 008, "@E 999",, CLR_BLACK, CLR_WHITE,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nVolumes",,,,lHasButton  )
//oVolumes := TGet():New( 183,045,{|u| If(PCount()>0,nVolumes:=u,nVolumes)},oDlg1,020,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nVolumes",,)

oBtn1      := TButton():New( 184,256,"Gravar",oDlg1,{|| U_RACD01G(nTamanho) },037,012,,,,.T.,,"",,,,.F. )

oBtn2      := TButton():New( 252,212,"Confirmar",oDlg1,{||_lOk := u_RACD01I(oMeter),IIF(_lOk,oDlg1:End(),.F.)},037,012,,,,.T.,,"",,,,.F. )
oBtn3      := TButton():New( 252,256,"Fechar",oDlg1,{||oDlg1:End()},037,012,,,,.T.,,"",,,,.F. )

oDlg1:Activate(,,,.T.)

Return Nil

/*
+------------------+---------------------------------------------------------+
!Autor             ! Alexandre Effting/SMSTI                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 13/02/2017                                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para Impressão de etiquetas padrão Zebra         !
+------------------+---------------------------------------------------------+
*/

User Function RACD01I(oMeter)
	Local _lRet := .T.
	Local _nCount := 0

	//--- Etiquetas para Caixas ---
	If nTamanho == 1

		//Inicia a regua de progressao
	  oMeter:NTOTAL := nVolumes
	  oMeter:Set(0)
			
		For _nX := 1 to nVolumes
		
			//Atualiza regua de progressao
			_nCount++
			oMeter:Set(_nCount)
		
			oSay5:SetText("Imprimindo "+cValToChar(_nX)+" de "+cValToChar(nVolumes)+" ")
			oSay5:CtrlRefresh()
		
			If !ImpTam1()
				oMeter:Set(0)
				oSay5:SetText(" ")
				Return .F.
			EndIf	
		
		Next _nX

	EndIf

	//--- Etiquetas para Pallets ---
	If nTamanho == 2

		//Inicia a regua de progressao
	  oMeter:NTOTAL := nCopias
	  oMeter:Set(0)
			
		For _nX := 1 to nCopias
		
			//Atualiza regua de progressao
			_nCount++
			oMeter:Set(_nCount)
		
			oSay5:SetText("Imprimindo "+cValToChar(_nX)+" de "+cValToChar(nCopias)+" ")
			oSay5:CtrlRefresh()
		
			If !ImpTam2()
				oMeter:Set(0)
				oSay5:SetText(" ")
				Return .F.
			EndIf	
		
		Next _nX

	EndIf

	_lRet := (MsgYesNo("As etiquetas foram emitidas corretamente?","Emissão Etiquetas"))  

	If !_lRet
		oMeter:Set(0)
		oSay5:SetText(" ")
	EndIf

Return _lRet

/*
+------------------+---------------------------------------------------------+
!Autor             ! Alexandre Effting/SMSTI                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 14/02/2017                                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para Impressão de Etiquetas para Caixas          !
+------------------+---------------------------------------------------------+
*/
Static Function ImpTam1()
	Local _lRet := .T.
	Local cPrinter := "Z01"
  Local cPorta    := "LPT" + Alltrim(Posicione('CB5',1,xFilial('CB5')+cPrinter,'CB5_LPT'))
  Local cModelo   := Alltrim(Posicione('CB5',1,xFilial('CB5')+cPrinter,'CB5_MODELO'))
  Local nColIni := 3
  Local nLinIni := 3
	Local nLin    	:= 3
	Local nCol1    	:= 0
  Local nCol2    	:= 0
  Local nCol3    	:= 0
  Local nLargMax  := 88
  Local nAltMax   := 78
  Local nMargEsq  := 3
  Local nMargDir  := 3 
  Local _nInc := 65
	Local lPrim := .T.
	Local nCount := 4
	
	Local _aAux := STRTOKARR(cTextEtiq,CRLF)
	
	If Len(_aAux) <> 4
		MSGSTOP( "Informe um texto padronizado de no máximo 4 linhas para a etiqueta.", "Validação" )
		Return .F.
	EndIf

	//--- Efetua a impressão ---
  MSCBPRINTER(cModelo,CPorta, , 40   ,.f.)      

  MSCBCHKSTATUS(.F.)

  MSCBBEGIN(1,1) 

	//--Inicializa Colunas
	nCol1 := 72           //--- Contador de Volumes ---
	nCol2 := 74           //--- Municipio e Estado ---
	nCol3 := 72+10        //--- Total de Volumes ---
	                   
	For _nX := 1 to nVolumes
	
		nCount++
		
		If nCount > 4
			If !lPrim
				MSCBEND()
			EndIf
			nCount := 1
			nCol1 := 72     //--- Contador de Volumes ---
			nCol2 := 74     //--- Municipio e Estado --- 
			nCol3 := 84     //--- Total de Volumes ---   
			nLin   := 4
			MSCBBEGIN(1,6)
			
			lPrim := .F.
		EndIf
		
		//#### 1
		If nCount == 1
			MSCBSAY(nCol1, nLin      , StrZero(_nX,3),"R","0","160,060",.T.)     //--- Contador de Volumes ---
			MSCBBOX(nCol2-1, nLin + 011, nCol2+018,nLin + 005,3,"B")  
			MSCBSAY(nCol2, nLin + 011, _aAux[3]      ,"I","0","030,015",.T.) //--- Municipio e Estado ---
			MSCBBOX(nCol3-1, nLin + 020, nCol3+008,nLin + 020 + 030,3,"B")  
			MSCBSAY(nCol3, nLin + 020, _aAux[1]                    ,"R","0","055,045",.T.) //--- Total de Volumes ---
			MSCBSAY(nCol1, nLin + 020, SubStr(_aAux[2],1,10)       ,"R","0","055,045",.T.) //--- Cliente
			MSCBSAY(nCol2, nLin + 020 + 033, SubStr(_aAux[4],1,16) ,"I","0","030,015",.T.) //--- Transportadora ---
		EndIf

		//#### 2
		If nCount == 2
			
			nCol1 -= 23 
			nCol2 -= 23 
			nCol3 -= 23 
			
			MSCBSAY(nCol1, nLin      , StrZero(_nX,3),"R","0","160,060",.T.)     //--- Contador de Volumes ---
			MSCBBOX(nCol2-1, nLin + 011, nCol2+018,nLin + 005,3,"B")  
			MSCBSAY(nCol2, nLin + 011, _aAux[3]      ,"I","0","030,015",.T.) //--- Municipio e Estado ---
			MSCBBOX(nCol3-1, nLin + 020, nCol3+008,nLin + 020 + 030,3,"B")  
			MSCBSAY(nCol3, nLin + 020, _aAux[1]                    ,"R","0","055,045",.T.) //--- Total de Volumes ---
			MSCBSAY(nCol1, nLin + 020, SubStr(_aAux[2],1,10)       ,"R","0","055,045",.T.) //--- Cliente
			MSCBSAY(nCol2, nLin + 020 + 033, SubStr(_aAux[4],1,16) ,"I","0","030,015",.T.) //--- Transportadora ---
		EndIf

		//#### 3
		If nCount == 3

			nCol1 -= 22
			nCol2 -= 22
			nCol3 -= 22

			MSCBSAY(nCol1, nLin      , StrZero(_nX,3),"R","0","160,060",.T.)     //--- Contador de Volumes ---
			MSCBBOX(nCol2-1, nLin + 011, nCol2+018,nLin + 005,3,"B")  
			MSCBSAY(nCol2, nLin + 011, _aAux[3]      ,"I","0","030,015",.T.) //--- Municipio e Estado ---
			MSCBBOX(nCol3-1, nLin + 020, nCol3+008,nLin + 020 + 030,3,"B")  
			MSCBSAY(nCol3, nLin + 020, _aAux[1]                    ,"R","0","055,045",.T.) //--- Total de Volumes ---
			MSCBSAY(nCol1, nLin + 020, SubStr(_aAux[2],1,10)       ,"R","0","055,045",.T.) //--- Cliente
			MSCBSAY(nCol2, nLin + 020 + 033, SubStr(_aAux[4],1,16) ,"I","0","030,015",.T.) //--- Transportadora ---
		EndIf

		//#### 4
		If nCount == 4

			nCol1 -= 25
			nCol2 -= 25
			nCol3 -= 25

			MSCBSAY(nCol1, nLin      , StrZero(_nX,3),"R","0","160,060",.T.)     //--- Contador de Volumes ---
			MSCBBOX(nCol2-1, nLin + 011, nCol2+018,nLin + 005,3,"B")  
			MSCBSAY(nCol2, nLin + 011, _aAux[3]      ,"I","0","030,015",.T.) //--- Municipio e Estado ---
			MSCBBOX(nCol3-1, nLin + 020, nCol3+008,nLin + 020 + 030,3,"B")  
			MSCBSAY(nCol3, nLin + 020, _aAux[1]                    ,"R","0","055,045",.T.) //--- Total de Volumes ---
			MSCBSAY(nCol1, nLin + 020, SubStr(_aAux[2],1,10)       ,"R","0","055,045",.T.) //--- Cliente
			MSCBSAY(nCol2, nLin + 020 + 033, SubStr(_aAux[4],1,16) ,"I","0","030,015",.T.) //--- Transportadora ---				
		EndIf
		
		//nCol1 -= 25 
		//nCol2 -= 25 
		//nCol3 -= 25 
		
	Next _nx

  MSCBEND()                                  
  
  MSCBCLOSEPRINTER()  
Return _lRet

/*
+------------------+---------------------------------------------------------+
!Autor             ! Alexandre Effting/SMSTI                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 14/02/2017                                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para Impressão de Etiquetas para Pallet          !
+------------------+---------------------------------------------------------+
*/
Static Function ImpTam2()
	Local _lRet := .T.
	Local cPrinter := "Z01"
  Local cPorta    := "LPT" + Alltrim(Posicione('CB5',1,xFilial('CB5')+cPrinter,'CB5_LPT'))
  Local cModelo   := Alltrim(Posicione('CB5',1,xFilial('CB5')+cPrinter,'CB5_MODELO'))
  Local nColIni := 3
  Local nLinIni := 3
  Local nLargMax  := 98
  Local nAltMax   := 78
  Local nMargEsq  := 3
  Local nMargDir  := 3 
  Local _nInc := 20
	
	Local _aAux := STRTOKARR(cTextEtiq,CRLF)
	
	If Len(_aAux) <> 4
		MSGSTOP( "Informe um texto padronizado de no máximo 4 linhas para a etiqueta.", "Validação" )
		Return .F.
	EndIf

	//--- Efetua a impressão ---
  MSCBPRINTER(cModelo,CPorta, , 40   ,.f.)      

  MSCBCHKSTATUS(.F.)

  MSCBBEGIN(1,1) 

 	MSCBSAY(nColIni, nLinIni          , _aAux[1], "N", "0", "100,100",,,,,.T.) 
 	MSCBSAY(nColIni, nLinIni+(_nInc*1), _aAux[2], "N", "0", "100,100",,,,,.T.) 
 	MSCBSAY(nColIni, nLinIni+(_nInc*2), _aAux[3], "N", "0", "100,100",,,,,.T.) 
 	MSCBSAY(nColIni, nLinIni+(_nInc*3), _aAux[4], "N", "0", "100,100",,,,,.T.)  	
		  
  MSCBEND()                                  
  
  MSCBCLOSEPRINTER()  
	
Return _lRet


/*
+------------------+---------------------------------------------------------+
!Autor             ! Alexandre Effting/SMSTI                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 13/02/2017                                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para gravação dos detalhes da etiqueta por Ordem !
+------------------+---------------------------------------------------------+
*/

User Function RACD01G(_nTamanho)
	Local _lRet := .T.
	Local _nCount := 0

	If _nTamanho == 1
		memowrite(cDir+"etiq_1_"+Alltrim(CB7->CB7_ORDSEP)+".txt",cTextEtiq)
	Else
		memowrite(cDir+"etiq_2_"+Alltrim(CB7->CB7_ORDSEP)+".txt",cTextEtiq)
	EndIf
	
	MsgInfo("Detalhe da etiqueta gravada para esta ordem de separação.","RACD01G - Gravação de Detalhe")

Return _lRet

/*
+------------------+---------------------------------------------------------+
!Autor             ! Alexandre Effting/SMSTI                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 13/02/2017                                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para ajuste de parametros com base no tamanho da !
!                  ! etiqueta.                                               !
+------------------+---------------------------------------------------------+
*/

User Function RACD01T(_nTamanho)
	Local _lRet := .T.
	Local _nCount := 0

	If _nTamanho == 2
		
		nCopias := nCopias * 4
	
		cTextEtiq := cTextEtiq2
	
	ElseIf _nTamanho == 1
		
		nCopias := nCopias / 4
	
		cTextEtiq := cTextEtiq1
		
	EndIf

	nCopias := IIF(nCopias <= 0,1,nCopias)
	
	oGet1:CtrlRefresh()
	
//	oTextEtiq:GoTop()
//	oTextEtiq:AppendText(cTextEtiq)

	oTextEtiq:Refresh()
	
		
Return _lRet
