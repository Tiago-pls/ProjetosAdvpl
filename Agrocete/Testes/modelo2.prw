#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/11/00
/*
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯?¯¯
¯¯¯Programa  ¯VERBACTA  ¯Autor  ¯Fabiano Filla       ¯ Data ¯  12/08/10   ¯¯¯
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯?¯¯
¯¯¯Desc.     ¯Rotina para Cadastro da tabela Z01 - Verba X Grupo CC       ¯¯¯
¯¯¯          ¯                                                            ¯¯¯
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯?¯¯
¯¯¯Uso       ¯ AP                                                        ¯¯¯
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯?¯¯
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

User function RateioFOL()
	
	SetPrvt("CCOMBO,AITEMS,AROTINA,CCADASTRO,_LINCOP,_CPROTOCOLO,_COBS,_COPCAO")
	
   aRotina := MenuDef()

   SetColor("b/w,,,")
   cCadastro:= "Rateio Folha de Pagamento"

   mBrowse( 6, 1,22,75,"Z39",,,20,,,)

Return

//Funēćo para Tratar as Opēões 
User Function VERCTA(_iOpcao)
 local _iCount :=0	
local aGetsD ,bF4, cIniCpos, nMax, aCordW, lDelGetD 
	Private cAlias := "Z40", _iOpcao, _cNum,_cFuncional, _cNome, _dDtIni, _dDtFim, _cTipoPD, _cVigencia, _nSalario
 			   
	SX3->(DbSetOrder(1))
	SX3->(DbSeek(cAlias))
  	nUsado := 0
	aHeader:= {}
	_aInsBr:= {}

  	Do While SX3->( !Eof() ) .And. SX3->x3_arquivo == cAlias
		If X3USO(SX3->x3_usado) .AND. cNivel >= SX3->x3_nivel
	   		nUsado:=nUsado+1
			AADD(aHeader,{ TRIM(SX3->x3_titulo), SX3->x3_campo, SX3->x3_picture, SX3->x3_tamanho, SX3->x3_decimal,"AllwaysTrue()", SX3->x3_usado, SX3->x3_tipo, SX3->x3_arquivo, SX3->x3_usado } )
			If SX3->X3_TIPO = "C"
				Aadd(_aInsBr, Space(SX3->X3_TAMANHO))
	  		ElseIf SX3->X3_TIPO = "D"
	  		   Aadd(_aInsBr, Ctod(""))
	  		ElseIf SX3->X3_TIPO = "N"
	  		   Aadd(_aInsBr, 0.00)
	  		EndIf
  		 EndIf
  		SX3->( DbSkip() )
	Enddo
	Aadd(_aInsBr, .F.)
	
	aCols   	:= {}
	If _iOpcao == 2
		_cNum := GetSXENum("Z39","Z39_NUM")
   		_cFuncional := Space(6)
		_cNome	  := Space(35)
		_dDtIni := Stod('  /  /  ')
		_dDtFim := Stod('  /  /  ')
		_cVigencia :="S"
		_nSalario:= 99999.99
		   
		Aadd(aCols, _aInsBr)
  	Else
		// Carregar as variaveis do cabecalho
		_cNum       := Z39->Z39_NUM
   		_cFuncional := Z39->Z39_FUNCIO
		_cNome	    := POSICIONE("SRA", 1, Z39->Z39_FILIAL + _cFuncional , "RA_NOME")
		_dDtIni     := Z39->Z39_DTINIC
		_dDtFim     := Z39->Z39_DATAFI 
		_cVigencia  := Z39->Z39_VIGENC 
		_nSalario   := POSICIONE("SRA", 1, Z39->Z39_FILIAL + _cFuncional , "RA_SALARIO")

			   
		Z40->(DbSetOrder(1)) //Z40_FILIAL+Z40_NUM+Z40_FUNCIO
     	//Z40->(DbSeek(xFilial("Z40")+_cFuncional,.T.))
     	Z40->(DbSeek( Z39->Z39_FILIAL + _cNum + _cFuncional,.T.))

		While !Z40->(Eof()) .And. Z39->Z39_FILIAL + _cNum + _cFuncional == Z40->(Z40_FILIAL + Z40_NUM + Z40_FUNCIO)
			SX3->(DbSetOrder(2)) //Filial + Campo
			_aInsBr := {}
			For _iCount := 1 To Len(aHeader)
				SX3->(DbSeek(aHeader[_iCount, 2],.F.))
				If SX3->X3_CONTEXT="V"
					Aadd(_aInsBr, &(SX3->X3_RELACAO))
				Else
					DbSelectArea(cAlias)
					Aadd(_aInsBr, &(SX3->X3_CAMPO))
				EndIf
			Next
			Aadd(_aInsBr, .F.)
			Aadd(aCols, _aInsBr)
			Z40->(DbSkip())
		Enddo         
	EndIf

	If Len(aCols) == 0
		Return 
	EndIf   
   
	//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄæ
	//³ Variaveis do Rodape do Modelo 2                              ³
	//ĄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŁ

	nLinGetD:= 0   
	nOpcx   := Iif(_iOpcao=2 .Or. _iOpcao=3,3,1)
	//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄæ
	//³ Titulo da Janela                                             ³
	//ĄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŁ

	cTitulo:="Manuteno Rateio Folha de Pagamento"
 
   //?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄæ
   //³ Array com descricao dos campos do Cabecalho do Modelo 2      ³
   //ĄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŁ

   aC:={}
   AADD(aC,{"_cNum"       ,{15, 0} , "Rateio: "      ,"@!",                           ,     ,.F.})
   AADD(aC,{"_cFuncional" ,{15,60}  , "Funcional: ","@!","U_ExistFunc(_cFuncional)" ,"SRA",_iOpcao=2})
   AADD(aC,{"_cNome"      ,{15,130} , "Nome   : "    ,"@!",                           ,     ,.F.})   
   AADD(aC,{"_nSalario"   ,{15,365}, "Salario:"     ,"@E 999,999,999.99",            ,     ,.F.})
   AADD(aC,{"_cVigencia"  ,{15,455}, "Vigente:"   ,"@!",                            ,      ,.F.})
   AADD(aC,{"_dDtIni"     ,{15,495}, "Dta Inicio:"   ,"@!","U_IniVigencia(_dDtIni)"    ,     ,_iOpcao=2})
   AADD(aC,{"_dDtFim"     ,{15,560}, "Dta Fim:"      ,"@!","U_FimVigencia(_dDtIni,_dDtFim)"    ,     ,_iOpcao=2})
   // inserir funēćo para tratar fim de vigencia
   		
   //?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄæ
   //³ Array com descricao dos campos do Rodape do Modelo 2         ³
   //ĄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŁ
   aR:={}

   //?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄæ
   //³ Array com coordenadas da GetDados no modelo2                 ³
   //ĄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŁ

 //  aCGD:={50,5,133,315}
 aCGD:={44,5,118,315}

   //?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄæ
   //³ Validacoes na GetDados da Modelo 2                           ³
   //ĄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŁ

   cLinhaOk := "AllwaysTrue()"
	cTudoOk  := "U_GAXCADZ40(" + AllTrim(Str(_iOpcao)) +")"

   //?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄæ
   //³ Chamada da Modelo2                                           ³
   //ĄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄŁ
   // lRetMod2 = .t. se confirmou
   // lRetMod2 = .f. se cancelou

   //lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)
         
   //lMaximazed := .T.
   lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,aGetsD,bF4,cIniCpos,nMax,aCordW,lDelGetD, .T.)

	if !lRetMod2 // se cancelar volta a numeracao
		RollbackSx8()
	endif

Return(lRetMod2)

User Function GAXCADZ40(_iOpcao)
   Local _iPosAtiva  :=  Ascan(aHeader,{|x| AllTrim(x[2]) == "Z40_ATIVAC"     }), ;
         _iPosCC     :=  Ascan(aHeader,{|x| AllTrim(x[2]) == "Z40_CC"     }), ;
         _iPosPercRa :=  Ascan(aHeader,{|x| AllTrim(x[2]) == "Z40_PERCRA"}), ;
		 _iPosDirec  :=  Ascan(aHeader,{|x| AllTrim(x[2]) == "Z40_DIRECI" }), ;
		 _iCount, _lRetorno := .T.

	_aCC:={}
	_nPerc:=0

   If _iOpcao == 2 .Or. _iOpcao == 3//Incluir ou Alterar
    	For _iCount := 1 To Len(aCols) // varrer todo o acols para valida??o das linhas
			If !aCols[_iCount, Len(aCols[1])] //Se nao estiver deletado

					If Empty(aCols[_iCount, _iPosCC]) 
						MsgBox("Informe o Centro de Custo na Linha " + StrZero(_iCount,3),"Atencao","ALERT")	      	
						_lRetorno := .F.
					EndIf
					If (aCols[_iCount, _iPosPercRa] = 0 )
						MsgBox("Informe Percentual de Rateio na Linha " + StrZero(_iCount,3),"Atencao","ALERT")	      	
						_lRetorno := .F.
					EndIf
					If EMPTY( alltrim(aCols[_iCount, _iPosDirec]))
						MsgBox("Informe Direcionador do Rateio na Linha " + StrZero(_iCount,3),"Atencao","ALERT")	      	
						_lRetorno := .F.
					EndIf
					If EMPTY( alltrim(aCols[_iCount, _iPosAtiva]))
						MsgBox("Informe se rateio esta ativo na Linha " + StrZero(_iCount,3),"Atencao","ALERT")	      	
						_lRetorno := .F.
					EndIf	

					// validar CC e Percentual de rateio
					if aCols[_iCount, _iPosAtiva] == "S" // se rateio ativo
						nPos := ASCAN(_aCC, aCols[_iCount, _iPosCC])
						_nPerc += aCols[_iCount, _iPosPercRa]
						if _lRetorno
							if len(_aCC) = 0
								Aadd(_aCC, aCols[_iCount, _iPosCC])							
							elseif nPos <> 0 
								MsgBox("Centro de Custo duplicado! " +  aCols[_iCount, _iPosCC] +" Linhas: "  + StrZero(nPos,2) + " e " + StrZero(_iCount,2) ,"Atencao","ALERT")	      	
								_lRetorno := .F.	
							elseif _nPerc > 100
								MsgBox("Total do Percentual de rateio invalido " +  StrZero(_nPerc,3)      ,"Atencao","ALERT")	      	
								_lRetorno := .F.												
							endif
						endif
					Endif				
			EndIf
   		Next
		If !_lRetorno
			Return(_lRetorno)
		EndIf

		// inicio gravacao dos registros pai e filho  

		Begin transaction 
			Z40->(DbSetOrder(1)) //Filial + Cod. Verba + Grupo CC
			if(_iOpcao == 2) // Incluir
			elseif(_iOpcao == 3) //
				Z40->(DbSeek( Z39->Z39_FILIAL + _cNum ,.T.))
			
				While !Z40->(Eof()) .And. Z40->( Z40_FILIAL + Z40_NUM) == Z39->( Z39_FILIAL + Z39_NUM)
					RecLock("Z40",.F.)
						Z40->(DbDelete())
					MsUnLock("Z40")
					Z40->( Dbskip() )
				End

			Endif

			// gravacao cabecalho
			if RecLock("Z39",.T.)
				Z39->Z39_FILIAL  	:= xFilial("Z39")
				Z39->Z39_NUM		:= _cNum
				Z39->Z39_VIGENC		:= _cVigencia
				Z39->Z39_FUNCIO		:= _cFuncional
				Z39->Z39_DTINIC		:= _dDtIni
				Z39->Z39_DATAFI   	:= _dDtFim
			
				MsUnLock("Z39")
			
				// gravacao itens
				For _iCount := 1 To Len(aCols)
					If !aCols[_iCount, Len(aCols[1])] //Se nao estiver deletado
						RecLock("Z40",.T.)
							Z40->Z40_FILIAL  	:= xFilial("Z40")
							Z40->Z40_NUM		:= _cNum
							Z40->Z40_FUNCIO		:= _cFuncional
							Z40->Z40_CC   	    := aCols[_iCount, _iPosCC]
							Z40->Z40_PERCRA   	:= aCols[_iCount, _iPosPercRa]
							Z40->Z40_DIRECI   	:= aCols[_iCount, _iPosDirec]
							Z40->Z40_ATIVAC   	:= aCols[_iCount, _iPosAtiva]
						MsUnLock("Z40")
					EndIf
				Next  
				ConfirmSX8()
			else
				RollbackSx8()
			endif
		END TRANSACTION
	ElseIf _iOpcao == 4 //Excluir

		If !MsgBox("Confirma Exclusao? ","Confirmacao","YESNO")          
			Return(.F.)
		EndIf
   
		Z40->(DbSetOrder(1)) //Filial + Cod. Verba + Grupo CC
		Z40->(DbSeek(xFilial("Z40")+_cFuncional,.T.))
		While !Z40->(Eof()) .And. xFilial("Z40")+_cFuncional == Z40->Z40_FILIAL+Z40->Z40_FUNCIO
			RecLock("Z40",.F.)
				Z40->(DbDelete())
			MsUnLock("Z40")
			
			Z40->(DbSkip())
		Enddo
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

// Funcao validar funcionario informado
User Function ExistFunc(_cFuncional)
	Local _lRetorno := .T.
	SRA->(DbSetOrder(1)) //Filial + Cod. Verba
	If SRA->(DbSeek(xFilial("SRA")+_cFuncional,.F.))

		If SRA->RA_SITFOLH $ ("D/T/A")
			MsgBox("Funcionario Inativo!","Atencao","ALERT")	      	
			_lRetorno := .F.
		else

			// verificar se ha rateio ativo para este funcionario
			aZ39Area := Z39->( GetArea())
				Z39->( DbSetORder(2)) // Filial + Matricula + Vigencia
				if Z39->( dbSeek(xFilial("Z39") + _cFuncional + "S" ))
					MsgBox("Funcionario Possui Rateio Vigente!","Atencao","ALERT")	      	
					_lRetorno := .F.
				else
					_cNome  := SRA->RA_NOME		
					_nSalario := SRA->RA_SALARIO
					_lRetorno := .T.
				Endif
			RestArea(aZ39Area)


		Endif
	Else  
		MsgBox("Funcionario Inexistente!","Atencao","ALERT")	      	
		_lRetorno := .F.
	EndIf
Return(_lRetorno)


// Funcao para tratar o fim da vigencia do Rateio do funcionario
user function FimVigencia(_dDtIni,_dDtFim)
local lRet := .T.
if ! empty(_dDtFim)
	if _dDtFim < _dDtIni
		MSGALERT( "Data Fim de Vigencia Menor que a data inicio", "Atencao" )
		Return(.F.)
	endif
	If !MsgBox("Confirma Fim de Vigencia? ","Confirmacao","YESNO")          
		Return(.F.)
	EndIf
	_cVigencia := "N"
Endif
Return lRet

// Funcao para tratar o fim da vigencia do Rateio do funcionario
user function IniVigencia(_dDtIni)
local lRet := .T.
if empty(_dDtIni)
		MSGALERT( "Inicio de Vigencia nao Informado", "Atencao" )
		Return(.F.)
	endif
Return lRet
