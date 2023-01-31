#include 'protheus.ch'
#include "fwbrowse.ch"



User Function ACnt120DescItem()

	Local oModal
	Local oDescontoItem

	//backup do readvar
	Local cOldReadVar := ReadVar()

	Local oColumn
	Local aColumns := {}

	Local aCampos := {"CNE_ITEM","CNE_PRODUT","CNE_VLTOT","CNE_PDESC","CNE_VLDESC","CNE_MTDESC"}

	Local n1

	oModal := FWDialogModal():New()
	oModal:SetEscClose(.T.)
	oModal:setTitle("Desconto por item")
	oModal:setSize(250, 400)
	oModal:createDialog()


	oDescontoItem := FWBROWSE():New()
	oDescontoItem:SetOwner(oModal:getPanelMain())
	oDescontoItem:SetDataArray()
	oDescontoItem:SetArray(oGetDados:aCols)
	oDescontoItem:DisableConfig()
	oDescontoItem:DisableReport()
	oDescontoItem:SetEditCell(.T.,{|lCancel,oBrowse,cField| ValidaDesconto(lCancel,oBrowse) })
	oDescontoItem:SetLineOk({|oBrowse,lDown| ValidaLinha(oBrowse,lDown)  })

	For n1 := 1 to len(aCampos)
		//posiciona pelo campo na SX3
		//SX3->( dbSetOrder(2) )
		//SX3->( dbSeek( aCampos[n1] ) )

		//cria a columa
		oColumn := FWBrwColumn():New()
		oColumn:SetData( &("{|| oGetDados:aCols[oDescontoItem:At()][ aScan(oGetDados:aHeader,{|x| alltrim(x[2]) == '"+aCampos[n1]+"' }) ] }") )
		oColumn:SetTitle(GetSx3Cache(aCampos[n1],'X3_TITULO'))
		oColumn:SetType(GetSx3Cache(aCampos[n1],'X3_TIPO'))
		oColumn:SetSize(GetSx3Cache(aCampos[n1],'X3_TAMANHO'))
		oColumn:SetDecimal(GetSx3Cache(aCampos[n1],'X3_DECIMAL'))
		oColumn:SetPicture(GetSx3Cache(aCampos[n1],'X3_PICTURE'))
		oColumn:SetAlign( IIF(GetSx3Cache(aCampos[n1],'X3_TIPO') == "N",COLUMN_ALIGN_RIGHT,IIF(GetSx3Cache(aCampos[n1],'X3_TIPO') == "D",COLUMN_ALIGN_CENTER,COLUMN_ALIGN_LEFT)) )
		oColumn:SetHeaderClick({||})
		IF aCampos[n1] $ "CNE_PDESC#CNE_MTDESC#CNE_VLDESC"
			oColumn:SetEdit(.T.)
			oColumn:SetReadVar("M->"+aCampos[n1])
		EndIF

		aAdd(aColumns, oColumn)

	Next n1

	//adiciona as colunas
	oDescontoItem:SetColumns(aColumns)
	oModal:addButtons({{"","Sair"     ,{|| oModal:Deactivate() }, "Clique aqui para Sair",,.T.,.T.}})
	IF ! INCLUI
		oModal:addButtons({{"","Historico",{|| u_ACnt120Historico() }, "Clique aqui para Ver o Histórico",,.T.,.T.}})
	EndIF

	//ativa o markbrowser
	oDescontoItem:Activate()


	oModal:Activate()


	//retorna o backup da readvar
	__ReadVar := cOldReadVar

Return


Static Function ValidaDesconto(lCancel,oBrowse)

	Local lValido := lCancel

	Local posPDesc := aScan(oGetDados:aHeader,{|x| alltrim(x[2]) == 'CNE_PDESC' })
	Local posVlDesc := aScan(oGetDados:aHeader,{|x| alltrim(x[2]) == 'CNE_VLDESC' })
	Local posVlTot := aScan(oGetDados:aHeader,{|x| alltrim(x[2]) == 'CNE_VLTOT' })
	Local posMtDesc := aScan(oGetDados:aHeader,{|x| alltrim(x[2]) == 'CNE_MTDESC' })

	IF ! lCancel

		//atualiza posição do getdados
		oGetDados:nAt := oBrowse:nAt

		IF ReadVar() == "M->CNE_PDESC"
			IF M->CNE_PDESC <= 100 .AND. CN130TotMed(4)
				oGetDados:aCols[oGetDados:nAt][posPDesc] := M->CNE_PDESC
				oGetDados:aCols[oGetDados:nAt][posVlDesc] := NoRound(aCols[oGetDados:nAt][posVlTot] * M->CNE_PDESC / 100,TamSx3('CNE_VLDESC')[2])
				IF M->CNE_PDESC == 0
					oGetDados:aCols[oGetDados:nAt][posMtDesc] := CriaVar("CNE_MTDESC")
				EndIF
				lValido := .T.
			EndIF
		ElseIF ReadVar() == "M->CNE_MTDESC"
			IF oGetDados:aCols[oGetDados:nAt][posPDesc] != 0
				oGetDados:aCols[oGetDados:nAt][posMtDesc] := M->CNE_MTDESC
				lValido := .T.
			EndIF		
		ElseIF ReadVar() == "M->CNE_VLDESC"
			//IF oGetDados:aCols[oGetDados:nAt][posVlDesc] != 0
				oGetDados:aCols[oGetDados:nAt][posVlDesc] := M->CNE_VLDESC
				oGetDados:aCols[oGetDados:nAt][posPDesc] :=  (M->CNE_VLDESC / aCols[oGetDados:nAt][posVlTot] )*100
				lValido := .T.
			//EndIF
		EndIF
	EndIF

Return lValido


Static Function ValidaLinha(oBrowse,lDown)

	Local lValid := .T.
	Local posPDesc := aScan(oGetDados:aHeader,{|x| alltrim(x[2]) == 'CNE_PDESC' })
	Local posMtDesc := aScan(oGetDados:aHeader,{|x| alltrim(x[2]) == 'CNE_MTDESC' })

	IF oGetDados:aCols[oBrowse:nAt][posPDesc] != 0
		IF Empty(oGetDados:aCols[oBrowse:nAt][posMtDesc])
			lValid := .F.
			Aviso("Motivo","Informe o motivo para o desconto.",{"Voltar"},1)
		EndIF
	ElseIF ! Empty(oGetDados:aCols[oBrowse:nAt][posMtDesc])
		oGetDados:aCols[oBrowse:nAt][posMtDesc] := CriaVar("CNE_MTDESC")
	EndIF

Return lValid



User Function ACNT120Historico()

	Local oBrowse
	Local oModal := FWDialogModal():New()

	Local aNoFields := {"ZCN_FILIAL", "ZCN_NUMMED", "ZCN_HIST"}

	oModal:SetEscClose(.T.)
	oModal:setTitle("Historico de desconto por item")
	oModal:setSize(250, 450)
	oModal:createDialog()

	oBrowse := FWBROWSE():New()
	oBrowse:SetOwner( oModal:getPanelMain() )
	oBrowse:SetDataQuery(.F.)
	oBrowse:SetDataTable(.T.)
	oBrowse:SetAlias( "ZCN" )
	oBrowse:SetDescription( "Historico de desconto por item" )
	oBrowse:SetFilterDefault( "ZCN_NUMMED == '"+M->CND_NUMMED+"'" )
	oBrowse:DisableReport()
	oBrowse:AddLegend("ZCN_HIST=='I'","bpmsdoci"," Incluido")
	oBrowse:AddLegend("ZCN_HIST=='A'","bpmsdoca"," Alterado")
	oBrowse:AddLegend("ZCN_HIST=='E'","bpmsdoce"," Excluido")
	oBrowse:SetColumns(GetColumns("ZCN",aNoFields))
	oBrowse:Activate()

	oModal:addButtons({{"","Sair"     ,{|| oModal:Deactivate() }, "Clique aqui para Sair",,.T.,.T.}})

	oModal:Activate()

Return

Static Function GetColumns(cAlias,aNoFields)
	Local aSX3
	Local aColumns := {}
	Local oColumn
	Local nI

	//SX3->( dbSetOrder(1) )
	//SX3->( dbSeek( cAlias ) )
	aSX3 := FWSX3Util():GetAllFields( cAlias, .T. )

	//While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == cAlias
	for nI:=1 to Len(aSX3)

		IF aScan(aNoFields, {|x| alltrim(x) == alltrim(aSX3[nI]) }) == 0

			oColumn := FWBrwColumn():New()

			oColumn:SetType(GetSx3Cache(aSX3[nI],'X3_TIPO'))
			oColumn:SetTitle(GetSx3Cache(aSX3[nI],'X3_TITULO'))
			oColumn:SetSize(GetSx3Cache(aSX3[nI],'X3_TAMANHO'))
			oColumn:SetDecimal(GetSx3Cache(aSX3[nI],'X3_DECIMAL'))
			oColumn:SetData(&("{||" + aSX3[nI] + "}"))
			oColumn:SetPicture(GetSx3Cache(aSX3[nI],'X3_PICTURE'))
			oColumn:SetAlign( IIF(GetSx3Cache(aSX3[nI],'X3_TIPO') == "N",COLUMN_ALIGN_RIGHT,IIF(GetSx3Cache(aSX3[nI],'X3_TIPO') == "D",COLUMN_ALIGN_CENTER,COLUMN_ALIGN_LEFT)) )

			aAdd(aColumns, oColumn)
		EndIF
		//SX3->( dbSkip() )
	//EndDO
	Next

Return aColumns
