#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE2.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"


user Function GeraDados()
	Private _cPerg := ''
	_cPerg := "GERADADOS"
	GeraPerg(_cPerg)
	If !Pergunte(_cPerg,.T.)
		Return
	Endif
	oProcess := MsNewProcess():New({|| u_ExpDados()}, "Processando...", "Aguarde...", .T.)
	oProcess:Activate()
return
 
user function ExpDados()
	cQuery := Query(MV_PAR07)
	cArq := alltrim(MV_PAR08)
	nHandle := fCreate(cArq,0)
	if nHandle = -1
        MSGALERT("Erro ao criar arquivo - ferror " + Str(Ferror()))
    else
		nCont := 0
		nValor := 0
		If Select("QRY")>0         
			QRY->(dbCloseArea())
		Endif
		TcQuery cQuery New Alias "QRY" 
		if MV_PAR07 ==1 // T�tulos
			if Select("SD1") ==0
				DBSELECTAREA( "SD1" )
			Endif
			SD1->(DBSETORDER( 1 ))
			cCCusto :=""
		    nTotal := 0
			Count To nTotal
			QRY->(DbGoTop())
	  		oprocess:SetRegua2(nTotal)	
			cLinha :="CNPJ;Especie;Num_Docto;Valor Doc;Emissao;Vencto;Tipo;Etapa;Observa��es;Filler"	+CHR(13)+CHR(10) 
			FWrite(nHandle, cLinha)
			While QRY->(! EOF())
				oProcess:IncRegua2("Fornecedor:  " + alltrim(QRY->A2_NOME) )
				nCont += 1
				cLinha :=""
				if  (QRY->A2_TIPO== 'J')
					cCGC := Alltrim(Transform(QRY->CGC, "@R 99.999.999/9999-99")) 
				else
					cCGC := Alltrim(Transform(QRY->CGC, "@R 999.999.999-99")) + Space(4)
				endif
				SD1->(dbGotop())
					//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
				if SD1->(DbSeek( QRY->(E2_FILIAL + E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA)))
					cCusto := SubStr(SD1->D1_CC,1,4)
				Endif
				/*cCusto := Padr(cCusto,4)
				cLinha += cCGC
				cLinha += PadR(QRY->E2_TIPO,5)
				cLinha += StrZero(Val(QRY->E2_NUM),15)
				cLinha += StrZero(QRY->E2_VALOR,15)
				cLinha += SubStr(QRY->E2_EMISSAO,7,2) + SubStr(QRY->E2_EMISSAO,5,2) +SubStr(QRY->E2_EMISSAO,1,4)
				cLinha += SubStr(QRY->E2_VENCREA,7,2) + SubStr(QRY->E2_VENCREA,5,2) +SubStr(QRY->E2_VENCREA,1,4)
				cLinha += iif( Empty(QRY->E2_CODSERV), 'M', 'S')
				cLinha += cCusto
				cLinha += Space(126)
				cLinha += CHR(13)+CHR(10) */
				cCusto := Padr(cCusto,4) +";"
				cLinha += cCGC+";"
				cLinha += alltrim(QRY->E2_TIPO)+";"
				cLinha += AllTrim(QRY->E2_NUM)+";"
				cLinha += cValToChar(QRY->E2_VALOR *100)+";"
				cLinha += SubStr(QRY->E2_EMISSAO,7,2) + '/' + SubStr(QRY->E2_EMISSAO,5,2) +'/' +SubStr(QRY->E2_EMISSAO,1,4)+";"
				cLinha += SubStr(QRY->E2_VENCREA,7,2) + '/' + SubStr(QRY->E2_VENCREA,5,2) +'/' +SubStr(QRY->E2_VENCREA,1,4)+";"
				cLinha += iif( Empty(QRY->E2_CODSERV), 'M', 'S')+";"
				cLinha += cCusto
				cLinha += CHR(13)+CHR(10) 

				FWrite(nHandle, cLinha)
				QRY->(DbSkip())
			enddo
		else
		    nTotal := 0
			Count To nTotal
			QRY->(DbGoTop())
	  		oprocess:SetRegua2(nTotal)
			cLinha :="CNPJ;Nome;Endere�o;Num;Complemento;CEP;Bairro;Cidade;UF;Cmun;Inscr.Est;Fone;Email;Contato" +CHR(13)+CHR(10)
			FWrite(nHandle, cLinha)
			While QRY->(! EOF())
				oProcess:IncRegua2("Fornecedor:  " + alltrim(QRY->A2_NOME) )
				nCont += 1
				cLinha :=""
				if  (QRY->A2_TIPO== 'J')
					cCGC := Alltrim(Transform(QRY->CGC, "@R 99.999.999/9999-99")) 
				else
					cCGC := Alltrim(Transform(QRY->CGC, "@R 999.999.999-99")) + Space(4)
				endif
				cLinha += Alltrim(cCGC)+";"
				cLinha += Alltrim(QRY->A2_NOME)+";"
				
				if At(',',QRY->A2_END,1) > 0
					cLinha += SUBSTR( QRY->A2_END, 1,  At(',',QRY->A2_END,1) - 1) +";"
				else
					cLinha += Alltrim(QRY->A2_END)+";"
				Endif
				cLinha += Alltrim(QRY->A2_NR_END)    +";"
				cLinha += Alltrim(QRY->A2_COMPLEM)   +";"
				cLinha += Alltrim(QRY->A2_CEP)       +";"
				cLinha += Alltrim(QRY->A2_BAIRRO)    +";"
				cLinha += Alltrim(QRY->A2_MUN)       +";"
				cLinha += Alltrim(QRY->A2_EST)       +";"
				cLinha += Alltrim(QRY->A2_COD_MUN)   +";"
				cLinha += Alltrim(QRY->A2_INSCR)     +";"
				cLinha += Alltrim(QRY->A2_TEL)       +";"
				cLinha += Alltrim(QRY->A2_EMAIL)     +";"
				cLinha += Alltrim(QRY->A2_CONTATO)
				cLinha += CHR(13)+CHR(10)
				FWrite(nHandle, cLinha)
				QRY->(DbSkip())
			enddo
		Endif
		FCLOSE( nHandle )    
    endif
Return

Static Function GeraPerg(_cPerg)
	Local aRegs:= {}
	aAdd(aRegs,{_cPerg,"01","Filial de"        ,"Filial de"        ,"Filial de"        ,"mv_ch1",'C',06,0,0,'G',''          , '', '', '', 'MV_PAR01'})
	aAdd(aRegs,{_cPerg,"02","Filial Ate"       ,"Filial Ate"       ,"Filial Ate"       ,"mv_ch2","C",06,0,0,"G","naovazio()","mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{_cPerg,"03","Fornecedor de"    ,"Fornecedor de"    ,"Fornecedor de"    ,"mv_ch3","C",06,0,0,"G"," "         ,"mv_par03","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{_cPerg,"04","Fornecedor Ate"   ,"Fornecedor Ate"   ,"Fornecedor Ate"   ,"mv_ch4","C",06,0,0,"G","naovazio()","mv_par04","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{_cPerg,"05","Data de"          ,"Data Ate"         ,"Data Ate"         ,"mv_ch5","D",08,0,0,"G","          ","mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{_cPerg,"06","Data Ate"         ,"Data Ate"         ,"Data Ate"         ,"mv_ch6","D",08,0,0,"G","naovazio()","mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{_cPerg,"07","Tipo arquivo"     ,"Tipo arquivo"     ,"Tipo arquivo"     ,"mv_ch7","C",01,0,0,"G","naovazio()","mv_par07","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{_cPerg,"08","Diret�rio Arquivo","Diret�rio Arquivo","Diret�rio Arquivo","mv_ch8","C",99,0,0,"G","naovazio()","mv_par08","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
	U_BuscaPerg(aRegs)

Return

static function Query(nTipo)
	cQuery :=""
	cLenSA2 :=cValtoChar(len(alltrim(xFilial("SA2"))) )
	if nTipo ==1
		
		cQuery := " Select  A2_CGC as  CGC , A2_TIPO, E2_FORNECE, E2_LOJA, E2_TIPO, E2_NUM, E2_PREFIXO, E2_VALOR , E2_EMISSAO, E2_VENCREA, A2_NOME, E2_CODSERV , E2_FILIAL "
		cQuery += " from " + RetSqlName("SE2") + " SE2"
		cQuery += " Inner join "+ RetSqlName("SA2") +" SA2 on E2_FORNECE = A2_COD and E2_LOJA = A2_LOJA"		
		cQuery += " Where E2_FILIAL >= '" + MV_PAR01+"' and E2_FILIAL <='" + MV_PAR02+"' and SE2.D_E_L_E_T_ =' '"
		cQuery += " AND E2_FORNECE >='"+MV_PAR03+"' and E2_FORNECE <= '"+MV_PAR04+"' "
		cQuery += " AND E2_VENCTO >= '"+ DTos(MV_PAR05)+"' and E2_VENCTO <= '"+ Dtos(MV_PAR06)+"' and SA2.D_E_L_E_T_ =' '"
		cQuery += " AND SubString(E2_FILIAL ,1,"+cLenSA2+")   =  SubString(A2_FILIAL ,1,"+cLenSA2+") "
		cQuery += " AND E2_TIPO  ='NF' "
		cQuery += " Order by 1, 5" 
	else
		cQuery :=" Select A2_CGC as  CGC, A2_TIPO, A2_NOME,A2_END,A2_NR_END,A2_COMPLEM,A2_CEP,A2_BAIRRO,  "
		cQuery += " A2_MUN,A2_EST,A2_COD_MUN,A2_INSCR,A2_TEL,A2_EMAIL,A2_CONTATO  from " + RetSqlName("SA2") +" SA2"
		cQuery += " Where A2_FILIAL >= '" + MV_PAR01+"' and A2_FILIAL <='" + MV_PAR02+"' and SA2.D_E_L_E_T_ =' '"
		cQuery += " AND A2_COD >='"+MV_PAR03+"' and A2_COD <= '"+MV_PAR04+"' and A2_CGC <> ' '"
		cQuery += " AND A2_COD in (select F1_FORNECE From "+RetSqlName("SF1")+ " SF1 where F1_EMISSAO >= '"+DTos(MV_PAR05)+"' group by F1_FORNECE"
	Endif
return ChangeQuery(cQuery)
