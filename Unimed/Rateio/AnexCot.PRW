#include "rwmake.ch"
#include "protheus.ch"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ AnexCot ¦ Autor ¦  Lucilene Mendes       ¦ Data ¦15.07.15  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Anexos do Atualiza Cotação.                                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function  AnexRat(cNum)
local cNum := Z39->Z39_NUM
Private oAnx, oAnx1     
Private aListC   := {}
Private nLista   := nLista2 := 1
Private cOrigem  := "C:\TEMP\"
Private cDestino := "\"
Private oList1,oList2
Private cDirAtu  := Upper("Rateios" )  
Private cNumCot  := StrZero(val(cNum),6)
Private cFornLj	 := ""
Private oOk      := LoadBitmap( GetResources(), "LBOK" ) 
Private oNo      := LoadBitmap( GetResources(), "LBNO" ) 

If Right(cDirAtu,1) $ "\/"
	cDirAtu := SubStr(cDirAtu,1, Len(cDirAtu) -1 )
	If Right(cDirAtu,1) $ "\/"
		cDirAtu := SubStr(cDirAtu,1, Len(cDirAtu) -1 )
	EndIf	
EndIf

cDestino += cDirAtu
If !ExistDir(cDestino)
	nRet := makeDir(cDestino)
	If nRet != 0
		Alert("Nao foi possivel criar o diretorio "+cDestino )
		Return .T.
	EndIf
EndIf

cDestino += "\Cotacao\"

If !ExistDir(cDestino)
	nRet := makeDir(cDestino)
	If nRet != 0
		Alert("Nao foi possivel criar o diretorio "+cDestino )
		Return .T.
	EndIf
EndIf

cDestino += Lower(AllTrim(cNumCot)) + '\'

If !ExistDir(cDestino)
	nRet := makeDir(cDestino)
	If nRet != 0
		Alert("Nao foi possivel criar o diretorio "+cDestino )
		Return .T.
	EndIf
EndIf  

If !ExistDir(cDestino)
	nRet := makeDir(cDestino)
	If nRet != 0
		Alert("Nao foi possivel criar o diretorio "+cDestino )
		Return .T.
	EndIf
EndIf
	
aListD:= {}
aAnex1 := DIRECTORY(cDestino+"*.*","",,.T.) 
cTipoAnx := ""
  	     
if Len(aAnex1) > 0 
	For i:= 1 to Len(aAnex1) 
	 	aAdd( aListD , { .f. , aAnex1[i,1], aAnex1[i,2], aAnex1[i,3], aAnex1[i,4],'','', } ) 
	Next
lAnexo:=.t.
endif
  	
AtuList( 3 )
     
DEFINE MSDIALOG oAnx TITLE "Anexos do Rateio" FROM 130, 000 TO 700, 900 PIXEL 

oBtView := tButton():New(015,005,'Salvar',		oAnx,{|| SalvarDoc() },35,13,,,,.T.)
oBtAll	:= tButton():New(030,005,'Todos',		oAnx,{|| Selec(2)	},35,13,,,,.T.)	
oBtDel 	:= tButton():New(045,005,'Excluir',		oAnx,{|| Excluir()  },35,13,,,,.T.)	
oBtDel 	:= tButton():New(060,005,'Abrir Arq',	oAnx,{|| AbrirArq()  },35,13,,,,.T.)	
oBtDir	:= tButton():New(110,005,'Diretorio',oAnx,{|| AtuOrig(1) }   ,35,13,,,,.T.)	
@112,045 Say oAnx1 PROMPT cOrigem Size 135, 007  PIXEL 
oBtInc	:= tButton():New(140,005,'Anexar',		oAnx,{|| AtuCopia(1)}   ,35,13,,,,.T.)	
oBtAll	:= tButton():New(155,005,'Todos',		oAnx,{|| Selec(1)	}   ,35,13,,,,.T.)	
oBtRef 	:= tButton():New(170,005,'Refresh',		oAnx,{|| AtuTela() }    ,35,13,,,,.T.)	
@140,045 ListBox oList1 Fields HEADERS '  ','Arquivo','Tamanho','Data','Hora' Size 390,080 Pixel Of oAnx;
On dblClick(aListC := SDTroca2(oList1:nAt,aListC) , oList1:Refresh() )	 
@015,045 ListBox oList2 Fields HEADERS '  ','Arquivo','Tamanho','Data','Hora' Size 390,080 Pixel Of oAnx ;  //&!
On dblClick(aListD := SDTroca2(oList2:nAt,aListD) , oList2:Refresh() )	 	
oList1:SetArray(aListC)
oList1:bLine:={||{If(aListC[oList1:nAt,01],oOk,oNo),aListC[oList1:nAt,2],Transform(aListC[oList1:nAt,3],"999,999,999,999"),DtoC(aListC[oList1:nAt,4]), aListC[oList1:nAt,5] } } 
oList1:Refresh()                             
                      
If Len(aListD) > 0
	oList2:SetArray(aListD)
	oList2:bLine:={||{If(aListD[oList2:nAt,01],oOk,oNo),aListD[oList2:nAt,2],Transform(aListD[oList2:nAt,3],"999,999,999,999"),DtoC(aListD[oList2:nAt,4]), aListD[oList2:nAt,5] } } 
	oList2:Refresh()
Else
	oList2:SetArray(aListD)
	oList2:bLine:={||{If(.T.,oOk,oNo),"","","","","","" } } 
EndIf                                                                                  

ACTIVATE MSDIALOG oAnx ON INIT EnchoiceBar(oAnx, {|| if(valida(), (lOk := .T., oAnx:End()), ) }, {|| oAnx:End() } )  CENTERED
	
Return

static function valida

return .T.
//------------------------------------------------------------+
//                        FUNÇÃO ATULIST                      !
//------------------------------------------------------------+ 
//    NOME: LAYZE RIBAS                  DATA: 25/09/2013     !
//------------------------------------------------------------+    
  
Static Function AtuList( nTipo  ) 
    
Local nI := 0
Local cDesttp     := cDirAtu +"\Cotacao\"+cNumCot+"\"
Local nCont := 1
	
If nTipo == 1 .Or. nTipo == 3
	aListC := {}
	aListM := Directory(cOrigem + "*.*") 
	For nI := 1 To Len(aListM)
		aAdd( aListC , { .f. , aListM[nI,1], aListM[nI,2], aListM[nI,3], aListM[nI,4] } ) 
	Next
   	aSort(aListC,,,{|X,Y| X[2] < Y[2] })            
EndIf

If nTipo == 2 .Or. nTipo == 3
	aListD:= {}
	aListN := Directory( cDestino + "\*.*")
	For nI := 1 To Len(aListN)
		aAdd( aListD , { .f. , aListN[nI,1], aListN[nI,2], aListN[nI,3], aListN[nI,4] } ) 
	Next
   	aSort(aListD,,,{|X,Y| X[2] < Y[2] }) 
EndIf  

Return

//------------------------------------------------------------+
//                        FUNÇÃO ATUORIG                      !
//------------------------------------------------------------+ 
//    NOME: LAYZE RIBAS                  DATA: 25/09/2013     !
//------------------------------------------------------------+   

Static Function AtuOrig(nTipo)

Local lOk 	   := .t.   
Local cOrgBkp  := cOrigem
Local cDestBkp := cDestino
Local nCont    := 0

While lOk          
	nCont += 1
	If nTipo == 1
		cOrigem  := cGetFile("","Selecione o Destino ...",0,"",.F.,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_MULTISELECT+GETF_OVERWRITEPROMPT)
		If SubStr(cOrigem,1,1) == '\' 
			MsgAlert("Nao foi selecionado o diretorio local!")
		Else
			lOk := .f.
		EndIf
	Else
		cDestino := cGetFile("","Selecione o Destino ...",0,"",.F.,GETF_RETDIRECTORY+GETF_OVERWRITEPROMPT)
		If SubStr(cDestino,1,1) <>  '\'
			MsgAlert("Nao foi selecionado o diretorio do Servidor!")
		Else
			lOk := .f.
		EndIf
	EndIf   
	If nCont > 5
	    cDestino := cDestBkp
	    cOrigem  := cOrgBkp                                                                         
		Exit                                                                             
	EndIf	
EndDo
	
If nTipo == 1
	AtuList(1) //Origem 

	oList1:SetArray(aListC)
	oList1:bLine:={||{If(aListC[oList1:nAt,01],oOk,oNo),aListC[oList1:nAt,2],Transform(aListC[oList1:nAt,3],"999,999,999,999"),DtoC(aListC[oList1:nAt,4]), aListC[oList1:nAt,5] } } 
	oList1:Refresh()
Else          
    AtuList(2) //Destino 

	oList2:SetArray(aListD)
	oList2:bLine:={||{If(aListD[oList2:nAt,01],oOk,oNo),aListD[oList2:nAt,2],Transform(aListD[oList2:nAt,3],"999,999,999,999"),DtoC(aListD[oList2:nAt,4]), aListD[oList2:nAt,5] } } 
	oList2:Refresh()
EndIf

oAnx1:Refresh()
		
Return(.t.)

//------------------------------------------------------------+
//                      FUNÇÃO SALVARDOC                      !
//------------------------------------------------------------+ 
//    NOME: LAYZE RIBAS                  DATA: 25/09/2013     !
//------------------------------------------------------------+   

Static Function SalvarDoc()

Local lOk		:= .T.
Local cDirTemp	:= ""
Local lView		:= .T.
Local nCont		:= 0
Local cExtensao := ".tmp"  
Local cDest     := "" //aListD[oList2:nAt,7]  
Local _lTela    := .T.
Local lMark     := .F.

For i:=1 to Len(aListD)
	If aListD[i,1] 
		lMark:= .T.
	Endif	
Next
If !lMark
	MsgInfo("Não existem itens selecionados!","Atenção!")
	Return .F.
Endif

While lOk          
	nCont++
	cDirTemp:= cGetFile("","Selecione o Destino ...",0,"",.F.,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_OVERWRITEPROMPT)
	If SubStr(cOrigem,1,1) == '\' 
		MsgAlert("Não foi selecionado o diretorio local!")
	Else
		lOk := .F.
		_lTela := .F.
	EndIf
	If nCont > 5
	    lView := .F.
		Exit                                                                             
	EndIf	
EndDo

//For nI:= 1 To Len(aListD)
//	If lView == .T. // .And. _lTela == .T.
//		If aListD[nI,1]

	If !Empty(cDirTemp)
		Processa({|| ServToCli(aListD, cDest, cDirTemp) }, 'Salvando Arquivos','Aguarde...')
	Else
		_lTela:= .F.
	Endif   		
//        EndIf
//	EndIF
//Next



Return (_lTela)


//------------------------------------------------------------+
//                        FUNÇÃO SERVTOCLI                    !
//------------------------------------------------------------+ 
//    NOME: LAYZE RIBAS                  DATA: 25/09/2013     !
//------------------------------------------------------------+   

Static Function ServToCli(aCopia, cVar, cDirTemp)    

Local cCont 	:= 0
Local cVar2 	:= ""
Local cArqOrig	:= ""
Local lSucesso	:= .T.

For nn := 1 to len(aCopia)
	If aCopia[nn,1]
		cCont++
	EndIf
Next

ProcRegua(cCont)

For nn := 1 to len(aCopia)
	If aCopia[nn,1] 
		cVar := cDirAtu +"\Cotacao\"+cNumCot+"\" 
	
		cVar2 := aCopia[nn,2]
		IncProc("Copiando Arquivo: " + cVar2 )
		cArqOrig := cVar+"\" + cVar2 
		lSucesso := CpyS2T(cArqOrig, cDirTemp, .F.)  
		cVar:= ""
	EndIf   
Next nn
	
If lSucesso 
	MsgInfo("Arquivo(s) salvo(s)")
Else
	Alert("Falha ao salvar Arquivo(s)")
EndIf

Return

//------------------------------------------------------------+
//                        FUNÇÃO Excluir                      !
//------------------------------------------------------------+ 
//    NOME: LAYZE RIBAS                  DATA: 25/09/2013     !
//------------------------------------------------------------+   

Static Function Excluir()

Local _lREX := .T.
Local nn := 0 
Local pp := 0 
Local cDir := cDirAtu +"\Cotacao\"+cNumCot+"\"                                                 

If !MsgYesNo("Excluir todos os arquivos selecionados?")
	oAnx1:Refresh()
	_lREX := .F.
EndIf

If _lREX
	If Len(aListD) > 0
		For nEx := 1 To Len(aListD)
		    If aListD[nEx,1] == .T.
		    	cDir := cDirAtu +"\Cotacao\"+cNumCot+"\"
		    	cNomeAqv:= aListD[nEx,2]
				If FERASE(cDir+cNomeAqv) == -1
					MsgStop('Falha ao apagar o Arquivo  ( FError'+str(ferror(),4)+ ')')
				Else
					aListD[nEx,1]:= .F.
				Endif  
				DirRemove(cDir)	
				cDir:= "" 
				pp++
   			EndIf  
 
		Next 
 //  	DirRemove(cDirAtu +"\Cotacao\"+cNumCot+"\"+cTpAnx)
 //	DirRemove(cDirAtu +"\Cotacao\"+cNumCot)
		    
	Endif

	AtuList(1) //Origem
	
	oList1:SetArray(aListC)
	oList1:bLine:={||{If(aListC[oList1:nAt,01],oOk,oNo),aListC[oList1:nAt,2],Transform(aListC[oList1:nAt,3],"999,999,999,999"),DtoC(aListC[oList1:nAt,4]), aListC[oList1:nAt,5] } } 
	oList1:Refresh()
	
	aListN := Directory( cDestino + "\*.*")
	aListD:= {}
    
	If ExistDir(cDirAtu +"\Cotacao\"+cNumCot+"\")   
		aListN := Directory( cDirAtu +"\Cotacao\"+cNumCot+"\*.*")
		For nI := 1 To Len(aListN)        
			aAdd( aListD , { .f. , aListN[nI,1], aListN[nI,2], aListN[nI,3], aListN[nI,4], "CRONOGRAMA", "INCLUSÃO", } ) 
        Next nI
  	EndIf
    
    oList2:SetArray(aListD)
	oList2:bLine:={||{If(aListD[oList2:nAt,01],oOk,oNo),aListD[oList2:nAt,2],Transform(aListD[oList2:nAt,3],"999,999,999,999"),DtoC(aListD[oList2:nAt,4]), aListD[oList2:nAt,5] } } 
	oList2:Refresh()
		
	oAnx1:Refresh()
MsgAlert("Excluidos " + cValToChar(pp) + " arquivos.")

EndIf




Return     

//------------------------------------------------------------+
//                        FUNÇÃO ATUCOPIA                     !
//------------------------------------------------------------+ 
//    NOME: LAYZE RIBAS                  DATA: 25/09/2013     !
//------------------------------------------------------------+   


Static Function AtuCopia(nTipo)

Local oTpDoc  
Local oTpAnx      
Local lMark := .F.
Private oDlA

For i:=1 to Len(aListC)
	If aListC[i,1] 
		lMark:= .T.
	Endif	
Next
	If !lMark
		MsgInfo("Não existem itens selecionados!","Atenção!")
		Return .F.
	Endif
		
ANXArq(nTipo) 

Return (.T.)


//------------------------------------------------------------+
//                        FUNÇÃO ANXArq                       !
//------------------------------------------------------------+ 
//    NOME: LAYZE RIBAS                  DATA: 25/09/2013     !
//------------------------------------------------------------+   


Static Function ANXArq(nTipo) 
   
  
Local cVar      := ""
Local cVar3     := ""
Local aCopia    := {} 
Local cDestiBKP :=cDirAtu +"\Cotacao\"+cNumCot+"\"
Private _lAnex  := .T. 

If !ExistDir(cDestiBKP)
	nRet := makeDir(cDestiBKP)
	If nRet != 0
		Alert("Não foi possível criar o diretório "+cDestiBKP )
		Return .T.
	EndIf
EndIf 
    
If !ExistDir(cDestiBKP)
	nRet := makeDir(cDestiBKP)
	If nRet != 0
		Alert("Não foi possível criar o diretório "+cDestiBKP )
		Return .T.
	EndIf
EndIf      

cDestino :=  cDestiBKP   
If nTipo == 1    //Terminal para o Servidor   
	aCopia := aClone(aListC)
	cVar   := Lower(cOrigem) 
	cVar3  := Lower(cDestiBKP)
Else
    //Servidor para o Terminal
   	aCopia := aClone(aListD)
	cVar  := Lower(cDestiBKP)
	cVar3 := Lower(cOrigem)
EndIf       
    


Processa({|| ContCopia( aCopia, cVar, cVar3, nTipo ) }, 'Copiando... Aguarde...','Aguarde...')
	 	 	  	
 	 	  	                                                   
If nTipo == 2          
	AtuList(1) //Origem

	oList1:SetArray(aListC)
	oList1:bLine:={||{If(aListC[oList1:nAt,01],oOk,oNo),aListC[oList1:nAt,2],Transform(aListC[oList1:nAt,3],"999,999,999,999"),DtoC(aListC[oList1:nAt,4]), aListC[oList1:nAt,5] } } 
	oList1:Refresh()
Else
	AtuList(2)// Destino
		
	oList2:SetArray(aListD)
	oList2:bLine:={||{If(aListD[oList2:nAt,01],oOk,oNo),aListD[oList2:nAt,2],Transform(aListD[oList2:nAt,3],"999,999,999,999"),DtoC(aListD[oList2:nAt,4]), aListD[oList2:nAt,5] } } 
	oList2:Refresh()
 EndIf
	oList2:Refresh()
	oList1:Refresh()
    
	oAnx1:Refresh()
		
Return(.t.)

//------------------------------------------------------------+
//                        FUNÇÃO CONTCOPIA                    !
//------------------------------------------------------------+ 
//    NOME: LAYZE RIBAS                  DATA: 25/09/2013     !
//------------------------------------------------------------+   

Static Function ContCopia(aCopia,cVar,cVar3,nTipo)

Local nI
local cMsg1				:= ""
local lSucess			:= .F.
local nAcopia			:= Len(aCopia)
local aFiles			:= {}
local nJ				:= 0
local nK				:= 0
local cRemoteip			:= Getclientip()
local cRemoteComputer	:= GetComputerName()
local cThread			:= alltrim(str(ThreadId(),16,0))
local nN				:= 0
local cMsg2				:= " "

For nI:=1 to nAcopia
	If aCopia[nI,1]
		aadd(aFiles,{ ni , alltrim(upper(aCopia[nI,2])), " "} )
		nJ++
	EndIf   
Next

nN		:= LEN(aFiles)
cMsg1	:= (" ")
cMsg1	+= chr(13)+chr(10)
cMsg1	+= cMsg2
cMsg1	+= chr(13)+chr(10)
cMsg1	+= (" Usuario=[" + cUsername + "] Computador=[" + cRemoteComputer + "]")
cMsg1	+= (" IP=[" + cRemoteip + "]")
cMsg1	+= (" Thread=[" + cThread + "]")
cMsg1	+= chr(13)+chr(10)
cMsg1	+= (" Origem =[" + alltrim(cVar) + "]")
cMsg1	+= chr(13)+chr(10)
cMsg1	+= (" Destino=[" + alltrim(cVar3) + "]")
cMsg1	+= chr(13)+chr(10)
cMsg1	+= (" Inicio da Copia em [" + dtoc(date()) + " " + time() + "].")
If nJ >= 1
	cMsg1	+= ( " Copiar " + alltrim(str(nj,10,0)) + iif(nJ <= 1, " arquivo selecionado"," arquivos selecionados") +".")
Else
	cMsg1	+= (" ? ")
EndIf
cMsg1	+= chr(13)+chr(10)
cMsg1	+= (" Arquivos:")
For nI:=1 to nN
   cMsg1	+= IIF(nI==1," "," ; ") + ALLTRIM(aFiles[nI,2])
Next
cMsg1	+= chr(13)+chr(10)
cMsg1	+= ("******************************************************************************")
Conout(cMsg1)

ProcRegua( naCopia )    

For nI := 1 To naCopia       
cVar2 := Lower(aCopia[nI,2])   //Nome do Arquivo a ser copiado.       
cIncProc := If( aCopia[nI,1] , 'Copiando arquivo: ' + Trim(cVar2) , "" )	    
IncProc( cIncProc )      	    	
	If aCopia[nI,1] //Esta marcado, entao copia
		If nTipo == 2  //  Servidor para Remote
			lSucess := CpyS2T( cVar + cVar2 , cVar3 , .T. )
		Else   //  Remote para Sevidor
			lSucess := CpyT2S( cVar + cVar2 , cVar3 , .T. )
			
			//Renomeia o arquivo para retirar acentos e espaços para visualização no portal.
			cVarN := Lower(StrTran(NoAcento((cVar2))," ","_"))
			If(FRenameEx(cVar3+"\"+cVar2,cVar3+"\"+cVarN)==-1)
				conout(FError())
			EndIf
		EndIf
     	If lSucess
			nN	:= ascan(aFiles,{|aVal| aVal[1] == nI})
			aFiles[nN,3] := "*"
			nK++
		Endif
	EndIf                                      
Next

cMsg1	:= (" ")
cMsg1	+= chr(13)+chr(10)
cMsg1	+= cMsg2	
cMsg1	+= chr(13)+chr(10)
cMsg1	+= (" Usuario=[" + cUsername + "] Computador=[" + cRemoteComputer + "]")
cMsg1	+= (" IP=[" + cRemoteip + "]")
cMsg1	+= (" Thread=[" + cThread + "]")
cMsg1	+= chr(13)+chr(10)
cMsg1	+= (" Origem=[" + alltrim(cVar) + "]")
cMsg1	+= chr(13)+chr(10)
cMsg1	+= (" Destino=[" + alltrim(cVar3) + "]")
cMsg1	+= chr(13)+chr(10)
cMsg1	+= (" Termino da Copia em [" + dtoc(date()) + " " + time() + " Hr].")
cMsg1	+= chr(13)+chr(10)
If nK == 1
	cMsg1	+= (" Foi copiado 1 arquivo")
Elseif nK > 1	
	cMsg1	+= (" Foram copiados " + alltrim(str(nK,10,0) ) + " arquivos " )
Else	
	cMsg1	+= (" Nenhum arquivo foi copiado")
Endif

If nJ == 1
	cMsg1	+= (" de 1 arquivo selecionado." )
Elseif nJ > 1
	cMsg1	+= (" de " + alltrim( str(nj,10,0) )  + " arquivos selecionados")
Else	
	cMsg1	+= (".")
Endif

cMsg1	+= chr(13)+chr(10)

If nK == 1
	cMsg1	+= (" Arquivo copiado:")
ElseIf nK > 1
	cMsg1	+= (" Arquivos copiados:")
Else
	cMsg1	+= ("?")
	cMsg1	+= chr(13)+chr(10)
Endif

If nK >= 1
	For nI:=1 to nJ
	   If aFiles[nI,3] <> " "
		   cMsg1	+= ( iif(nI=1," "," ; ") + upper(alltrim(aFiles[nI,2])) )
		EndIf   
	Next
	cMsg1	+= chr(13)+chr(10)
EndIf	

If nJ >= 1 .and. nJ <> nK
   	If (nJ - nk) == 1
		cMsg1	+= (" 1 Arquivo nao copiado:")
 	Else
		cMsg1	+= (" " + alltrim(str((nJ - nk),10,0)) + " Arquivos nao copiados:")
   	EndIf
	For nI:=1 to nJ
	   If aFiles[nI,3] == " "
		   cMsg1	+= ( iif(nI=1," "," ; ") + upper(alltrim(aFiles[nI,2])) )
		EndIf   
	Next
cMsg1	+= chr(13)+chr(10)
Endif

cMsg1	+= ("******************************************************************************")
cMsg1	+= chr(13)+chr(10)
cMsg1	+= (" ")
cMsg1	+= chr(13)+chr(10)

Return

//------------------------------------------------------------+
//                        FUNÇÃO ATUTELA                      !
//------------------------------------------------------------+ 
//    NOME: LAYZE RIBAS                  DATA: 25/09/2013     !
//------------------------------------------------------------+   

Static Function AtuTela()

	AtuList(1) //Origem 
	
	oList1:SetArray(aListC)
	oList1:bLine:={||{If(aListC[oList1:nAt,01],oOk,oNo),aListC[oList1:nAt,2],Transform(aListC[oList1:nAt,3],"999,999,999,999"),DtoC(aListC[oList1:nAt,4]), aListC[oList1:nAt,5] } } 
	oList1:Refresh()
        
    AtuList(2) //Destino 
	oList2:SetArray(aListD)
	oList2:bLine:={||{If(aListD[oList2:nAt,01],oOk,oNo),aListD[oList2:nAt,2],Transform(aListD[oList2:nAt,3],"999,999,999,999"),DtoC(aListD[oList2:nAt,4]), aListD[oList2:nAt,5] } } 
	oList2:Refresh()
    
	oAnx1:Refresh()
		
Return()

//------------------------------------------------------------+
//                        FUNÇÃO SELECT                       !
//------------------------------------------------------------+ 
//    NOME: LAYZE RIBAS                  DATA: 25/09/2013     !
//------------------------------------------------------------+   

Static Function Selec(nTipo)

If nTipo == 1
	aListC := SDTroca(aListC)
    oList1:Refresh()
Else
	aListD := SDTroca(aListD)
    oList2:Refresh()
EndIf
oAnx1:Refresh()	
Return

//------------------------------------------------------------+
//                      FUNÇÃO INVERTE                        !
//------------------------------------------------------------+ 
//    NOME: LAYZE RIBAS                  DATA: 25/09/2013     !
//------------------------------------------------------------+   

Static Function SDTroca(aVetor)
Local nI                

For nI := 1 To Len(aVetor)
   	aVetor[nI,1] := !aVetor[nI,1]	 	
Next                 	        
Return(aVetor)

//------------------------------------------------------------+
//                       FUNÇÃO INVERTE2                      !
//------------------------------------------------------------+ 
//    NOME: LAYZE RIBAS                  DATA: 25/09/2013     !
//------------------------------------------------------------+   

Static Function SDTroca2(nIt,aVetor)                    
	aVetor[nIt,1] := !aVetor[nIt,1]	 	
Return(aVetor)

Static Function AbrirArq()

Local _lREX := .T.
Local nn := 0 
Local pp := 0 
Local cDir := cDirAtu +"\Cotacao\"+cNumCot+"\"                                                 

If _lREX
	If Len(aListD) > 0
		For nEx := 1 To Len(aListD)
		    If aListD[nEx,1] == .T.
		    	cDir := cDirAtu +"\Cotacao\"+cNumCot+"\"
		    	cNomeAqv:= aListD[nEx,2]
				cNome := "T"+cNomeAqv
				fRename(cDir + cNomeAqv, cDir + cNome )
				CpyS2T(cDir+ cNome, "C:\TEMP")
				ShellExecute( "Open","c:\temp\" + cnome,"","c:\temp\", 1 )
				fRename(cDir + cNome, cDir + cNomeAqv )
   			EndIf  
		Next 
	Endif
EndIf

Return   
