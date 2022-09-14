#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/11/00
/*/{Protheus.doc} zModel2
Exemplo de Modelo 2 para cadastro de SX5
@author Tiago Santos
@since 24/05/2021
@version 1.0
	@return Nil, Função não tem retorno
	@example
	TarProj()
	AF9 -> Tarefas
    AF8 -> Projetos
/*/
User function TarProj()
	
    SetPrvt("CCOMBO,AITEMS,AROTINA,CCADASTRO,_LINCOP,_CPROTOCOLO,_COBS,_COPCAO")
    aRotina := MenuDef()
    SetColor("b/w,,,")
    cCadastro:= "Vinculação Tarefas X Projetos"
    mBrowse( 6, 1,22,75,"AF9",,,20,,,)
Return

//Função para Tratar as Opções 
User Function VERZ50(_iOpcao)
 local _iCount :=0	
local aGetsD ,bF4, cIniCpos, nMax, aCordW, lDelGetD 
	Private cAlias := "Z50", _iOpcao, _cTarefa,_cIdStakeholder, _cDescTarefa, _dDtIni, _dDtFim, _cTipoPD, _cVigencia
	nItem :=0
 			   
	if( Select("Z50") == 0)
		DbSelectArea("Z50")
	Endif				
	SX3->(DbSetOrder(1))
	SX3->( DbGotop())
	SX3->(DbSeek(cAlias))
  	nUsado := 0
	aHeader:= {}
	_aInsBr:= {}
	While SX3->( !Eof() ) .And. SX3->x3_arquivo == cAlias
		IF X3USO(SX3->x3_usado) .AND. cNivel >= SX3->x3_nivel
            If Alltrim(SX3->X3_CAMPO) $ 'Z50_ITEM|Z50_PROJET|Z50_DESCRI|Z50_REVISA|Z50_EDTPAI|Z50_NOVEDT|Z50_TAREFA|Z50_DESCPR'
                nUsado:=nUsado+1
                AADD(aHeader,{ TRIM(SX3->x3_titulo),SX3->x3_campo,; 
                SX3->x3_picture,SX3->x3_tamanho,SX3->x3_decimal,;
                "AllwaysTrue()",SX3->x3_usado,;
                SX3->x3_tipo, SX3->x3_arquivo, SX3->x3_context })
            Endif
		Endif
		SX3->( dbSkip())
	 End
	//+-----------------------------------------------+
	//¦ Montando aCols para a GetDados ¦
	//+-----------------------------------------------+
	If _iOpcao == 2
		aCols:= Array(1,nUsado+1)
			SX3->(DbSeek('Z50'))
		nUsado:=0
		While SX3->( !Eof() ) .And. SX3->x3_arquivo == 'Z50'
			IF X3USO(SX3->x3_usado) .AND. cNivel >= SX3->x3_nivel
                if Alltrim(SX3->X3_CAMPO)  $ 'Z50_ITEM|Z50_PROJET|Z50_DESCRI|Z50_REVISA|Z50_EDTPAI|Z50_NOVEDT|Z50_TAREFA|'
                    nUsado:=nUsado+1 
                    IF _iOpcao == 2// inclusao		
                        IF SX3->x3_tipo == "C" 			
                            aCOLS[1][nUsado] := SPACE(SX3->x3_tamanho) 			
                        Elseif SX3->x3_tipo == "N"
                            aCOLS[1][nUsado] := 0
                        Elseif SX3->x3_tipo == "D" 
                            aCOLS[1][nUsado] := dDataBase 				
                        Elseif SX3->x3_tipo == "M" 
                            aCOLS[1][nUsado] := "" 				
                        Else 
                            aCOLS[1][nUsado] := .F. 
                        Endif 
                    Endif 
                Endif
			Endif 
			SX3->( dbSkip())
		End
		aCOLS[1][nUsado+1] := .F.
		//_cTarefa := space(12) // verificar o sequencial desse código
		_cDescTarefa  := Space(30)
	Else
		aCols   	:= {}
		aArea := GetArea()
		cChave := Alltrim(AF9->(AF9_FILIAL + AF9_DESCRI))
		Z50->( DbSetOrder(2)) // Z50_FILIAL + Z50_DESCRI
		Z50->( DbGoTop())
		Z50->( DbSeek(cChave))
		While !Z50->(Eof()) .And. Alltrim(Z50->(Z50_FILIAL + Z50_DESCRI)) == cChave
			SX3->(DbSetOrder(2)) //Filial + Campo
			_aInsBr := {}
			For _iCount := 1 To Len(aHeader)
				SX3->(DbSeek(aHeader[_iCount, 2],.F.))				
				//_cTarefa := Z50->Z50_GRUPO
				_cDescTarefa := AF9->AF9_DESCRI
				If SX3->X3_CONTEXT="V"
					Aadd(_aInsBr, &(SX3->X3_RELACAO))
				Else
					DbSelectArea('Z50')
					Aadd(_aInsBr, &(SX3->X3_CAMPO))
				EndIf
			Next
			Aadd(_aInsBr, .F.)
			nItem +=1
			_aInsBr[1] := StrZero(nItem,3)
			Aadd(aCols, _aInsBr)
		
			Z50->(DbSkip())
		Enddo  
		RestArea(aArea)
	Endif

	//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis do Rodape do Modelo 2                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nLinGetD:= 0   
	nOpcx   := Iif(_iOpcao=2 .Or. _iOpcao=3,3,1)
	cTitulo:="Tarefas por Projeto"
 
   //?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Array com descricao dos campos do Cabecalho do Modelo 2      ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   aC:={}
   //AADD(aC,{"_cTarefa"       ,{15, 0}  , "Tarefa: "      ,"@!", , ,.T.})
   AADD(aC,{"_cDescTarefa"   ,{15,130} , "Desc Tarefa: " ,"@!", , ,.F.})   
   // inserir função para tratar fim de vigencia
   		
   //?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Array com descricao dos campos do Rodape do Modelo 2         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aR:={}
 	AADD(aR,{"nLinGetD" ,{120,10},"Linha na GetDados", "@E 999",,,.F.})
   //?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Array com coordenadas da GetDados no modelo2                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 //  aCGD:={50,5,133,315}
    aCGD:={44,5,118,315}

   //?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Validacoes na GetDados da Modelo 2                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   cLinhaOk := ".T."
	cTudoOk  := "U_GAXCADZ50(" + AllTrim(Str(_iOpcao)) +")"
         
   cIniCpos := "+Z50_ITEM"
   aCols[1,1] := "001" // Iniciar o primeiro registro com esta numeracao
   lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,aGetsD,bF4,cIniCpos,nMax,aCordW,lDelGetD, .T.)
	if !lRetMod2 // se cancelar volta a numeracao
		RollbackSx8()
	endif
Return(lRetMod2)

User Function GAXCADZ50(_iOpcao)
   Local _iPosTarefa:=  Ascan(aHeader,{|x| AllTrim(x[2]) == "Z50_TAREFA" }), ;
         _iPosProjeto :=  Ascan(aHeader,{|x| AllTrim(x[2]) == "Z50_PROJET" }), ;
         _iPosEDTPAI :=  Ascan(aHeader,{|x| AllTrim(x[2]) == "Z50_EDTPAI" }), ;
         _iPosRevisao :=  Ascan(aHeader,{|x| AllTrim(x[2]) == "Z50_REVISA" }), ;
		 _iCount, _lRetorno := .T.
	_aCC:={}
    If _iOpcao == 2 .Or. _iOpcao == 3//Incluir ou Alterar
    	For _iCount := 1 To Len(aCols) // varrer todo o acols para valida??o das linhas
			If !aCols[_iCount, Len(aCols[1])] //Se nao estiver deletado
					If Empty(aCols[_iCount, _iPosProjeto]) 
						MsgBox("Projeto não preenchido" + StrZero(_iCount,3),"Atencao","ALERT")	      	
						_lRetorno := .F.
					EndIf
					If Empty(aCols[_iCount, _iPosEDTPAI]) 
						MsgBox("EDTPAI não preenchido" + StrZero(_iCount,3),"Atencao","ALERT")	      	
						_lRetorno := .F.
					EndIf
			EndIf
   		Next
		If !_lRetorno
			Return(_lRetorno)
		EndIf
		// inicio gravacao dos registros pai e filho  
		Begin transaction 
		if _iOpcao == 3 // Alterar
			ExcluiReg( Alltrim(xFilial("Z50") + _cDescTarefa))
		Endif
			For _iCount := 1 To Len(aCols)
				If !aCols[_iCount, Len(aCols[1])] //Se nao estiver deletado
					RecLock("Z50",.T.)
						Z50->Z50_FILIAL  	:= xFilial("Z50")
						Z50->Z50_DESCRI	:= _cDescTarefa
						Z50->Z50_TAREFA   	:= aCols[_iCount, _iPosTarefa]
						Z50->Z50_PROJET  	:= aCols[_iCount, _iPosProjeto]
						Z50->Z50_EDTPAI    	:= aCols[_iCount, _iPosEDTPAI]
						Z50->Z50_REVISA    	:= aCols[_iCount, _iPosRevisao]						
					MsUnLock("Z50")
				EndIf						
			Next 			
			GravaAF9(aCols,_cDescTarefa)
		END TRANSACTION
	ElseIf _iOpcao == 4 //Excluir
		If !MsgBox("Confirma Exclusao? ","Confirmacao","YESNO")          
			Return(.F.)
		EndIf
		
		ExcluiReg(Z50->(Z50_FILIAL + Z50_GRUPO))
	EndIf
						
Return(.T.)

Static Function MenuDef()
	Local aRotina := { {"Pesquisar       " , "AxPesqui"         , 0 , 1},;
                		 {"Visualizar      " , "U_VERZ50(1)"   , 0 , 2},;   
                		 {"Incluir         " , "U_VERZ50(2)"   , 0 , 3},;   
                		 {"Alterar         " , "U_VERZ50(3)"   , 0 , 4},;                		                 		 
                		 {"Excluir         " , "U_VERZ50(4)"   , 0 , 4},;                		 
                		 {"Anexar Doc      " , "U_VERZ50(5)"   , 0 , 5}}
Return(aRotina)

Static Function ExcluiReg (cChave)
Local aArea:= GetArea()
Z50->( DbSetOrder(2)) // Z50_FILIAL + Z50_DESCRI
Z50->( dbgotop())
Z50->( DbSeek( cChave))

While !Z50->(Eof()) .And. Alltrim(Z50->(Z50_FILIAL + Z50_DESCRI)) == cChave
	
	RecLock("Z50",.F.)
		Z50->(DbDelete())
	MsUnLock("Z50")
	Z50->( Dbskip() )
End

RestArea(aArea)
Return



static Function GravaAF9(aCols,_cDescTarefa)

Local aAreaAF9 := AF9->( GetArea())
Local ntst:=0
AF9->( DbSetOrder(1)) // AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA

for nCont:=1 to len (aCols)
	AF9->( dbgotop())
	if !AF9->( DbSeek( xFilial("AF9") + aCols[nCont,2] + aCols[nCont,4]+ aCols[nCont,6]))
		ntst +=1
		aTam:= Separa(aCols[nCont,6], '.', .T.)
		cNivel := StrZero( ( len(aTam)+1),3)
		_iPosTarefa:=  Ascan(aCols,{|x| AllTrim(x[2]) == "Z50_TAREFA" })
         _iPosProjeto :=  Ascan(aCols,{|x| AllTrim(x[2]) == "Z50_PROJET" })
         _iPosEDTPAI :=  Ascan(aCols,{|x| AllTrim(x[2]) == "Z50_EDTPAI" })
         _iPosRevisao :=  Ascan(aCols,{|x| AllTrim(x[2]) == "Z50_REVISA" })
		Begin transaction 
			If !aCols[nCont, Len(aCols[1])] //Se nao estiver deletado
				RecLock("AF9",.T.)
					AF9->AF9_FILIAL  	:= xFilial("AF9")
					AF9->AF9_DESCRI	    := _cDescTarefa
					AF9->AF9_TAREFA   	:= aCols[nCont, 6]
					AF9->AF9_PROJET  	:= aCols[nCont, 2]
					AF9->AF9_EDTPAI    	:= aCols[nCont, 5]
					AF9->AF9_REVISA    	:= aCols[nCont, 4]						
					AF9->AF9_NIVEL    	:= cNivel					
					AF9->AF9_QUANT    	:= 1
					AF9->AF9_CALEND    	:= '001'
					AF9->AF9_PRIORI    	:= 500
					AF9->AF9_RESTRI    	:= '7'
					AF9->AF9_TPMEDI   	:= '4'
					AF9->AF9_TPTRF   	:= '1'
					AF9->AF9_AGCRTL   	:= '2'					
					AF9->AF9_RASTRO 	:= 1

				MsUnLock("AF9")
			EndIf
		END TRANSACTION
	Endif
Next nCont

RestArea(aAreaAF9)
Return
