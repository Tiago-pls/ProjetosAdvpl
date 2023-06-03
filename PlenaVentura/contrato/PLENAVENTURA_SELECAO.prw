
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE2.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"  

user Function fSelecao(l1Elem,lTipoRet)
	Local MvPar
	Local cTitulo	 := "Item - Equipamento - Decricao"
	Local MvParDef	 := ""	
	Local nElemRet   := If ( ValType(&( ReadVar() )) <> 'U' , Len( &( ReadVar() ) ) , 1 )
	Private aCat	 := {}
	Default lTipoRet := .T.
	
	l1Elem := If (l1Elem = Nil , .F. , .T.)
	cAlias := Alias() 					 // Salva Alias Anterior

	IF lTipoRet
		MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
		mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
	EndIf
	if Select("CN9")==0
        DBSELECTAREA( "CN9" )
    Endif


    cQuery := "   SELECT CNB_ITEM, CNB_PRODUT, B1_DESC FROM " +RetSqlName("CNB")+" CNB"
    cQuery += "    INNER JOIN "+RetSqlName("SB1")+" SB1 ON  B1_COD = CNB_PRODUT "
    cQuery += "     WHERE  CNB_CONTRA = '"+MV_PAR04+"'  AND CNB_REVISA  ='"+MV_PAR05+"' AND"
    cQuery += "     CNB.D_E_L_E_T_ = ' ' and"
    cQuery += "     CNB_SUBST <>'S' and       "
    cQuery += "      SB1.D_E_L_E_T_ = ' ' and "
    cFilSB1:=  cValtoChar(Len(alltrim(xFilial("SB1"))))
    cQuery += "       substr(B1_FILIAL,1,"+cFilSB1+")   = substr(CNB_FILIAL,1,"+cFilSB1+")"
    cQuery += " ORDER BY 1"
    If Select("QRY")>0         
        QRY->(dbCloseArea())
    Endif
	TcQuery cQuery New Alias "QRY" 
	If QRY->(!EOF())
		CursorWait()
			While QRY->(!EOF()) 				
				Aadd(aCat,QRY->CNB_ITEM+ " - " +alltrim(QRY->CNB_PRODUT) + " - " +QRY->B1_DESC)
				MvParDef+=QRY->CNB_ITEM			
				dbSkip()
			Enddo
		CursorArrow()
	Else
        MsgAlert("Contrato + Revisão sem equipamento selecionados")
        
	EndIf
	
	IF lTipoRet
           
		IF f_Opcoes(@MvPar,cTitulo,aCat,MvParDef,12,49,l1Elem,3,nElemRet)  	// Chama funcao f_Opcoes
			mvpar  := strtran(mvpar,"*","")									// Retirar astericos que retorna na esquerda
			//mvpar  := padr(mvpar,nElemRet,'*')								// Complementa com asteriscos na direita para manter o tamanho padrao da variavel
			&MvRet := mvpar										 			// Devolve Resultado
		EndIf
	EndIf
	
	dbSelectArea(cAlias) 								 // Retorna Alias	
Return( IF( lTipoRet , .T. , MvParDef ) )
