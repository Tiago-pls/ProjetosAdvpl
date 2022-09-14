#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/11/00
/*/{Protheus.doc} zModel2
Exemplo de Modelo 2 para cadastro de SX5
@author Tiago Santos
@since 13/05/2021
@version 1.0
	@return Nil, Função não tem retorno
	@example
	GrupoSH()
	
/*/
User function GrupoSH()
	
	SetPrvt("CCOMBO,AITEMS,AROTINA,CCADASTRO,_LINCOP,_CPROTOCOLO,_COBS,_COPCAO")
   aRotina := MenuDef()
   SetColor("b/w,,,")
   cCadastro:= "Cadastro de Grupos StakeHolders"
   mBrowse( 6, 1,22,75,"Z49",,,20,,,)

Return

//Função para Tratar as Opções 
User Function VERCTA(_iOpcao)
 local _iCount :=0	
local aGetsD ,bF4, cIniCpos, nMax, aCordW, lDelGetD 
	Private cAlias := "Z49", _iOpcao, _cGrupo,_cIdStakeholder, _cNome, _dDtIni, _dDtFim, _cTipoPD, _cVigencia, _nSalario
 			   
	SX3->(DbSetOrder(1))
	SX3->(DbSeek(cAlias))
  	nUsado := 0
	aHeader:= {}
	_aInsBr:= {}

	While SX3->( !Eof() ) .And. SX3->x3_arquivo == cAlias

		IF X3USO(SX3->x3_usado) .AND. cNivel >= SX3->x3_nivel
			nUsado:=nUsado+1			
			AADD(aHeader,{ TRIM(SX3->x3_titulo),SX3->x3_campo,;
			SX3->x3_picture,SX3->x3_tamanho,SX3->x3_decimal,;
			"AllwaysTrue()",SX3->x3_usado,;
			SX3->x3_tipo, SX3->x3_arquivo, SX3->x3_context } )			
		Endif
		SX3->( dbSkip())
	 End
	//+-----------------------------------------------+
	//¦ Montando aCols para a GetDados ¦
	//+-----------------------------------------------+
	If _iOpcao == 2
		aCols:= Array(1,nUsado+1)
			SX3->(DbSeek(cAlias))
		nUsado:=0
		While SX3->( !Eof() ) .And. SX3->x3_arquivo == cAlias

			IF X3USO(SX3->x3_usado) .AND. cNivel >= SX3->x3_nivel
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
			SX3->( dbSkip())
		End
		aCOLS[1][nUsado+1] := .F.
		_cGrupo := GetSXENum("Z49","Z49_GRUPO")
		_cNome  := Space(30)
	Else
		aCols   	:= {}
		aArea := GetArea()
		cChave := Z49->(Z49_FILIAL + Z49_GRUPO)
		Z49->( DbGoTop())
		Z49->( DbSeek(cChave))
		While !Z49->(Eof()) .And. Z49->(Z49_FILIAL + Z49_GRUPO) == cChave
			SX3->(DbSetOrder(2)) //Filial + Campo
			_aInsBr := {}
			For _iCount := 1 To Len(aHeader)
				SX3->(DbSeek(aHeader[_iCount, 2],.F.))
				
				_cGrupo := Z49->Z49_GRUPO
				_cNome := Z49->Z49_DESCGP

				If SX3->X3_CONTEXT="V"
					Aadd(_aInsBr, &(SX3->X3_RELACAO))
				Else
					DbSelectArea(cAlias)
					Aadd(_aInsBr, &(SX3->X3_CAMPO))
				EndIf
			Next
			Aadd(_aInsBr, .F.)
			Aadd(aCols, _aInsBr)
			Z49->(DbSkip())
		Enddo  
		RestArea(aArea)
	Endif

	//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis do Rodape do Modelo 2                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nLinGetD:= 0   
	nOpcx   := Iif(_iOpcao=2 .Or. _iOpcao=3,3,1)
	cTitulo:="Manuteno Grupo StakeHolders"
 
   //?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Array com descricao dos campos do Cabecalho do Modelo 2      ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   aC:={}
   AADD(aC,{"_cGrupo"  ,{15, 0}  , "Grupo: "      ,"@!", , ,.F.})
   AADD(aC,{"_cNome"   ,{15,130} , "Desc Grupo: " ,"@!", , ,.T.})   
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

   cLinhaOk := "ExecBlock('Md2LinOk',.f.,.f.)"
	cTudoOk  := "U_GAXCADZ49(" + AllTrim(Str(_iOpcao)) +")"
         
   //lMaximazed := .T.
   lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,aGetsD,bF4,cIniCpos,nMax,aCordW,lDelGetD, .T.)

	if !lRetMod2 // se cancelar volta a numeracao
		RollbackSx8()
	endif

Return(lRetMod2)

User Function GAXCADZ49(_iOpcao)
   Local _iPosIDSH   :=  Ascan(aHeader,{|x| AllTrim(x[2]) == "Z49_IDSTKH"     }), ;
         _iPosNome   :=  Ascan(aHeader,{|x| AllTrim(x[2]) == "Z49_NOMSTH"     }), ;
         _iPosEmail  :=  Ascan(aHeader,{|x| AllTrim(x[2]) == "Z49_EMAIL"}), ;
		 _iPosAtivo  :=  Ascan(aHeader,{|x| AllTrim(x[2]) == "Z49_ATIVO" }), ;
		 _iCount, _lRetorno := .T.
	_aCC:={}
    If _iOpcao == 2 .Or. _iOpcao == 3//Incluir ou Alterar
    	For _iCount := 1 To Len(aCols) // varrer todo o acols para valida??o das linhas
			If !aCols[_iCount, Len(aCols[1])] //Se nao estiver deletado
					If Empty(aCols[_iCount, _iPosNome]) 
						MsgBox("Nome não preenchido" + StrZero(_iCount,3),"Atencao","ALERT")	      	
						_lRetorno := .F.
					EndIf
					If Empty(aCols[_iCount, _iPosEmail]) 
						MsgBox("Email não preenchido" + StrZero(_iCount,3),"Atencao","ALERT")	      	
						_lRetorno := .F.
					EndIf
					If EMPTY( alltrim(aCols[_iCount, _iPosAtivo]))
						MsgBox("Situacao não preenchida" + StrZero(_iCount,3),"Atencao","ALERT")	      	
						_lRetorno := .F.
					EndIf
					If EMPTY( alltrim(aCols[_iCount, _iPosIDSH]))
						MsgBox("Recurso não preenchido" + StrZero(_iCount,3),"Atencao","ALERT")	      	
						_lRetorno := .F.
					EndIf
				
					nPos := ASCAN(_aCC, aCols[_iCount, _iPosIDSH])
					if _lRetorno
						if nPos = 0
							aadd(_aCC, aCols[_iCount, _iPosIDSH])							
						elseif nPos <> 0 
							MsgBox("ID Duplicado " +  aCols[_iCount, _iPosIDSH] +" Linhas: "  + StrZero(nPos,2) + " e " + StrZero(_iCount,2) ,"Atencao","ALERT")	      	
							_lRetorno := .F.																			
						endif
					endif
			EndIf
   		Next
		If !_lRetorno
			Return(_lRetorno)
		EndIf

		// inicio gravacao dos registros pai e filho  
		Begin transaction 
		if _iOpcao == 3 // Alterar
			ExcluiReg(Z49->(Z49_FILIAL + Z49_GRUPO))
		Endif
			
			For _iCount := 1 To Len(aCols)
				If !aCols[_iCount, Len(aCols[1])] //Se nao estiver deletado
					RecLock("Z49",.T.)
						Z49->Z49_FILIAL  	:= xFilial("Z49")
						Z49->Z49_GRUPO 		:= _cGrupo
						Z49->Z49_DESCGP		:= _cNome
						Z49->Z49_IDSTKH   	:= aCols[_iCount, _iPosIDSH]
						Z49->Z49_NOMSTH   	:= aCols[_iCount, _iPosNome]
						Z49->Z49_EMAIL    	:= aCols[_iCount, _iPosEmail]
						Z49->Z49_ATIVO    	:= aCols[_iCount, _iPosAtivo]
					MsUnLock("Z49")
				EndIf						
			Next 
			
		END TRANSACTION

	ElseIf _iOpcao == 4 //Excluir
		If !MsgBox("Confirma Exclusao? ","Confirmacao","YESNO")          
			Return(.F.)
		EndIf

		// Exclui registros antigos 
		ExcluiReg(Z49->(Z49_FILIAL + Z49_GRUPO))
	EndIf
						
Return(.T.)

Static Function MenuDef()
	Local aRotina := { {"Pesquisar       " , "AxPesqui"         , 0 , 1},;
                		 {"Visualizar      " , "U_VERCTA(1)"   , 0 , 2},;   
                		 {"Incluir         " , "U_VERCTA(2)"   , 0 , 3},;   
                		 {"Alterar         " , "U_VERCTA(3)"   , 0 , 4},;                		                 		 
                		 {"Excluir         " , "U_VERCTA(4)"   , 0 , 4},;                		 
                		 {"Anexar Doc      " , "U_VERCTA(5)"   , 0 , 5}}
Return(aRotina)


User function Md2LinOk()
Return .t.


Static Function ExcluiReg (cChave)
Z49->( dbgotop())
Z49->( DbSeek( cChave))

While !Z49->(Eof()) .And. Z49->( Z49_FILIAL + Z49_GRUPO) == cChave
	
	RecLock("Z49",.F.)
		Z49->(DbDelete())
	MsUnLock("Z49")
	Z49->( Dbskip() )
End
Return
