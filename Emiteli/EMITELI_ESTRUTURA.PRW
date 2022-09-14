#include "protheus.ch"
#include "tbiconn.ch"

User Function Estrutur()

	Local cPerg    := "ESTRUTURA"

	Private _cAlias	:= ""

	If !ApOleClient("MsExcel") 
		MsgStop("Microsoft Excel não Instalado") 
		Return 
	Endif 

	If Pergunte(cPerg,.T.)
		MsAguarde({|| Executa()},"Relatório Estrutura com Alternativos","Aguarde a finalização do processamento...")
	Endif

Return

Static Function Executa()

	Query()

	If (_cAlias)->(Eof())
		conout("Sem dados para envio de e-mail.")
	Endif

	Excel()

Return

Static Function Query()

	If Empty(mv_par02)

		_cAlias2 	:= GetNextAlias()

		BeginSql alias _cAlias2
		SELECT MAX(G1_REVFIM) G1_REVFIM
		
			FROM %table:SG1% SG1
			
			WHERE  G1_COD    = %exp:mv_par01%
			AND    G1_FILIAL = %xFilial:SG1%
			AND    SG1.%NotDel% 
				
		EndSql

		mv_par02 := (_cAlias2)->G1_REVFIM

	EndIf

	_cAlias 	:= GetNextAlias()

	BeginSql alias _cAlias
	   SELECT G1_ITEM, G1_COD, G1_COMP, G1_QUANT, G1_OBSERV,  B1_DESC
	
		 FROM %table:SG1% SG1, %table:SB1% SB1
		
		WHERE  G1_COD     	= %exp:mv_par01%
		  AND  G1_REVINI 	<= %exp:mv_par02%
		  AND  G1_REVFIM 	>= %exp:mv_par02%
	      AND  G1_FILIAL  	= %xFilial:SG1%
		  AND  B1_FILIAL  	= %xFilial:SB1%
		  AND  B1_COD     	= G1_COMP
		  AND  SG1.%NotDel% 
		  AND  SB1.%NotDel%     
			
		ORDER BY  G1_ITEM, G1_COD, G1_COMP, B1_DESC, G1_QUANT, G1_OBSERV 
	EndSql
	
Return _cAlias

Static Function Excel()

	Local adados	:= {}
	Local oExcel 	:= FWMsExcelEx():New()
	Local cPath		:= GetTempPath()
	Local cArquivo  := "Estrutura_" + dTos(dDatabase) + AllTrim(mv_par01) +".xls"

	cDescPA := AllTrim(Posicione("SB1",1,xFilial("SB1")+(_cAlias)->G1_COD,"B1_DESC"))

	cWorkSheet := AllTrim(mv_par01) + "_" + mv_par02
	oExcel:AddworkSheet(cWorkSheet)

	cTable := AllTrim(mv_par01) + " - " + cDescPA + " - Rev." + mv_par02
	oExcel:AddTable(cWorkSheet,cTable)

	oExcel:AddColumn(cWorkSheet,cTable,"Item",1,1)
	oExcel:AddColumn(cWorkSheet,cTable,"Código",1,1)
	oExcel:AddColumn(cWorkSheet,cTable,"Descrição Emiteli",1,1)					
	oExcel:AddColumn(cWorkSheet,cTable,"Qntd",1,1)
	oExcel:AddColumn(cWorkSheet,cTable,"Referência",1,1)

	While !(_cAlias)->(Eof())

		aDados := Array(5)
	
		aDados[1] := (_cAlias)->G1_ITEM
		aDados[2] := (_cAlias)->G1_COMP
		aDados[3] := (_cAlias)->B1_DESC
		aDados[4] := (_cAlias)->G1_QUANT
		aDados[5] := (_cAlias)->G1_OBSERV

		oExcel:AddRow(cWorkSheet,cTable,aDados)

		cZ00    := GetNextAlias()
	
    	BeginSql alias cZ00
		
			Select Z00_ORDEM, Z00_ALTER, B1_DESC
					
			From %table:Z00% Z00, %table:SB1% SB1
					
                where Z00_FILIAL    = %xFilial:Z00%
                  and Z00_COD       = %exp:mv_par01%
                  and Z00_REV       = %exp:mv_par02%
                  and Z00_COMP      = %exp:(_cAlias)->G1_COMP%
                  and B1_FILIAL     = %xFilial:SB1%
                  and B1_COD        = Z00_ALTER
                  and Z00.%NotDel%
                  and SB1.%NotDel% // chamado 27607 
            
			ORDER BY Z00_ALTER

		EndSql	

		nCount := 1

		While ! (cZ00)->(Eof())

			aDados := Array(5)

			cDesc := StrTran((cZ00)->B1_DESC, ">", "")
			cDesc := StrTran(cDesc, "<", "")
			cDesc := StrTran(cDesc, "&", "")
			cDesc := StrTran(cDesc, '"', "")
			cDesc := StrTran(cDesc, "'", "")

			aDados[1] := (_cAlias)->G1_ITEM + '.' + cValToChar(nCount)
			aDados[2] := (cZ00)->Z00_ALTER
			aDados[3] := cDesc
			aDados[4] := 0
			aDados[5] := ""

			//Define a cor da fonte do estilo da  Célula indicada no método :AddRow()
			oExcel:SetCelBgColor("#808080")

			oExcel:AddRow(cWorkSheet,cTable,aDados)

			(cZ00)->(dbSkip()) 
			nCount++

		Enddo

		(_cAlias)->(DbSkip())
	EndDo

	If !Empty(oExcel:aWorkSheet) .And. !Empty(adados)

		oExcel:Activate()
		oExcel:GetXMLFile(cArquivo)

		CpyS2T("\SYSTEM\"+cArquivo, cPath)

		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cPath+cArquivo) // Abre a planilha
		oExcelApp:SetVisible(.T.)

		fErase("\SYSTEM\"+cArquivo)
	Else
		MsgAlert("Não há dados para este produto.")
	EndIf	
Return
