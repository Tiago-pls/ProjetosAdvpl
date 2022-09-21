#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"
// Fonte destinado a funções Gnéricas da empresa Metalnox. MTXFUN.PRW
//-------------------------------------------------------------------
/*/{Protheus.doc} PesoFret
Rotina para calculo do Peso Fret
@author  Thiago.Zoppi
date: 06/02/2020
/*/
//-------------------------------------------------------------------
User Function PesoFret(cUF, cProduto,_cClie,_cLoja)
    Local nvlrFrete := 0
    Local nPerAcre  := 0
    Local cGRUPO    := ""
    Local nPeso     := 0
    Local aAreaSB1 := {}
    Local _lAltB1  := .F.

    Default _cClie := M->UA_CLIENTE
    Default _cLoja := M->UA_LOJA

    if xFilial("SB1")+ cProduto<>SB1->(B1_FILIAL+B1_COD)
        _lAltB1  := .T.
        aAreaSB1 := SB1->(GETAREA())
        DbSelectArea("SB1")
        DbSetOrder(1)
        DbSeek(xFilial("SB1")+ cProduto)
    endif
    cGRUPO    := ALLTRIM(SB1->B1_GRUPO)

    If cFilAnt == "0301" .and. cGRUPO == "3A"
        if _lAltB1
            RESTAREA(aAreaSB1)
        endif
        Return Round(nvlrFrete,2)
    EndIf

    nPerAcre  := u_MTXFREACRE(cProduto,_cClie,_cLoja)

    DbSelectArea("Z09")
    DbSetorder(1)
    IF DBSEEK( xFilial("Z09")+cUF )
        nVlrFrete	:= (Z09->Z09_FRETKG)
        nPeso		:= SB1->B1_PESBRU
        IF nPeso > 0
            nvlrFrete := nPeso * nVlrFrete
        ENDIF

    Endif

    // Calculo do Percentual de Acrescimos do Frete
    IF nvlrFrete > 0 .AND. nPerAcre > 0
        nvlrFrete := ((nPerAcre / 100) * nvlrFrete) + nvlrFrete
    ENDIF

    if _lAltB1
        RESTAREA(aAreaSB1)
    endif

Return Round(nvlrFrete,2)


//-------------------------------------------------------------------
/*/{Protheus.doc} RecalVlr
Rotina utilizada para recalcular as linhas quando usuário alterar o
@author  Thiago.Zoppi
date: 06/02/2020
/*/
//-------------------------------------------------------------------

User Function RecalVlr()
    Local nVlrUniAlt    :=  GdFieldPos("UB_ZVLRALT",aHeader)
    Local nLin
    Local cCampoVal		:= "UB_VRUNIT"
    Local aArea	:= GetArea()

    IF MSGYESNO( "Deseja Recalcular todos os itens ??" )
        For nLin := 1 to Len(aCols)
            IF aCols[n,nVlrUniAlt] == "1"
                GDFIELDPUT("UB_ZVLRALT","2",nLin)
            Endif
        Next
        U_CALCDESC(cCampoVal)
        Eval(bGDRefresh)
    ENDIF

    RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Recalfret
Rotina utilizada para recalcular as linhas quando usuário alterar o
Campo UA_TPFRETE
@author  Thiago.Zoppi
date: 15/02/2020
/*/
//-------------------------------------------------------------------
User Function Recalfret()

    Local lRet      := .T.
    Local lFrtCor   := (cFilAnt $ '0101/0201/0301')
    Local _lDes6F	:= SuperGetMV("D6FRETE",.F.,.F.)

    If lFrtCor .And. ReadVar() == "M->UA_ZFRECOR"
        If _lDes6F .and. M->UA_ZFRECOR == "S"
            M->UA_ZDESCES := 0
        Else
            M->UA_ZREDESP := CriaVar("UA_ZREDESP")
        EndIf
    EndIf

    // Valida Frete Cortesia, quando vem do UA_TPFRETE, se for diferente de "C" = CIF Frete cortesia = nao
    If ReadVar() == "M->UA_TPFRETE" .AND. M->UA_TPFRETE != "C"
        If lFrtCor
            M->UA_ZFRECOR := "N" // Frete cortesia nao
        EndIf
        M->UA_ZFRENF := "2" // Frete na Nota nao
    EndIf

    IF M->UA_TPFRETE <> "E"
		If M->UA_ZFRENF == "2"
			avalores[4] := 0
			M->UA_FRETE := 0
		EndIf
	ENDIF

    if  ReadVar() $ "M->UA_ZFRECOR/M->UA_TPFRETE/M->UA_ZFRENF"
        M->UA_ZRECALC:="1"
    endif

	If cFilAnt <> "0101"
    	U_CALCDESC("UB_VRUNIT")
		Eval(bGDRefresh)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldResdep
Valida transportadoras de Redespacho para Ferragens
@author  Gustavo Schumann - Gruppe
date: 05/2022
/*/
//-------------------------------------------------------------------
User Function VldResdep()
Local lRet := .T.
Local cExTran := AllTrim(SuperGetMV("SL_TRREDES"))

If xFilial("SUA") == "0101" .And. M->UA_TPFRETE == "E"
	//If !(M->UA_ZREDESP $ cExTran)
	If !(M->UA_ZTRANSP $ cExTran)
		MsgAlert("Somente são permitidas as transportadoras: "+cExTran, "Frete Redespacho")
		lRet := .F.
	EndIf
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} VldMktPlc
Valida transportadoras de Marketplace
@author  Gustavo Schumann - Gruppe
date: 07/2022
/*/
//-------------------------------------------------------------------
User Function VldMktPlc()
Local lRet := .T.
Local cExTran := AllTrim(SuperGetMV("SL_TRMKTPS"))

If M->UA_TPFRETE == "M"
	If !(M->UA_ZTRANSP $ cExTran)
		MsgAlert("Somente são permitidas as transportadoras: "+cExTran, "Frete de Marketplace")
		lRet := .F.
	EndIf
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} VLDSUB01
@author  Thiago.Zoppi
date: "17/02/2020"
/*/
//-------------------------------------------------------------------
User function VLDSUB01()

    lOCAL lRet 			:= .T.
    //Local lRegPesFret	:= (cFilAnt $ '0101' .OR.  cFilAnt $ '0201') .AND. M->UA_TPFRETE == "C" // Regra para Frete Peso
    Local cGrpVend		:= ""
    Local cUF			:= ""
    //Local nPosVlr 		:= GdFieldPos("UB_VRUNIT",aHeader)
    //lOCAL nProdPos 		:= GDFieldPos('UB_PRODUTO')
    //Local nPosTot 		:= GdFieldPos("UB_VLRITEM",aHeader)
    //Local nPosDesc		:= GdFieldPos("UB_DESC",aHeader)
    Local nPosTab       := GdFieldPos("UB_PRCTAB",aHeader)
    //Local nPrcDig       := GdFieldPos("UB_ZPRCDIG ",aHeader)
    //Local nQuantpos		:= GDFieldPos('UB_QUANT')
    //Local nPerDesc		:= 0
    Local nNewPos		:= GdFieldPos("UB_ZPRCTAB",aHeader)
    //Local nVlrUniAlt    := GdFieldPos("UB_ZVLRALT",aHeader)  // Campo que indica se vlr unitario foi alterado manualmente.
    Local nZPRENEG      := GdFieldPos("UB_ZPRENEG ",aHeader)

    Local PulaLinha		:= chr(13) + chr(10)
    //Local nDescon		:= 0
    //Local lrecalt		:= .T.
    Private acolsX		:= {}


    // Valida se é prospect ou cliente.
    If lProspect
        DbSelectArea("SUS")
        DbSetorder(1)
        SUS->(MsSeek(xFilial("SUS")+M->UA_CLIENTE + M->UA_LOJA))
        cGrpVend := SUS->US_GRPVEN
        cUF 	 := SUS->US_US_EST
    Else
        DbSelectArea("SA1")
        DbSetorder(1)
        SA1->(MsSeek(xFilial("SA1")+M->UA_CLIENTE + M->UA_LOJA))
        cGrpVend := SA1->A1_GRPVEN
        cUF 	 := SA1->A1_EST
    Endif

    // Regra já existe no campo de validação só veio para função.
    IF (M->UB_VRUNIT <  aCols[n,nZPRENEG]  )
        lRet := .F.
        Help(NIL, NIL, "MtxFun- Valida ", NIL, "Campo Valor Unitario", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Valor unitário nao pode ser maior que o Preco Negociado "})
    ENDIF

    //-------------------------------------------------------------------
    //   Validar Valor Alterado
    //	- Valor Unitario Digitado não poder ser maior que Prc. Tab
    //	- Valor Unitario Digitado não poder Ser menor que escalonado
    //-------------------------------------------------------------------
    IF lRet
        IF M->UB_VRUNIT  > ACOLS[N, nPosTab]
            cMensProb  := " Valor do Preço Unit. não poder ser maior que o Preço de tabela." + PulaLinha
            cMensProb  += " Valor digitado: ("+ transform(M->UB_VRUNIT , pesqpict("SUB","UB_VRUNIT")) + ")"
            lRet := .F.

            // Valida se tem Desconto Escalonado, se tiver verificar se o valor digitado não é menor que o valor com desconto.
        ELSEIF ACOLS[N, nNewPos] > 0 .AND. M->UB_VRUNIT < ACOLS[N, nNewPos]
            cMensProb  := " Valor do Preço Unit. não poder ser menor que o Preço Escalonado." + PulaLinha
            cMensProb  += " Valor digitado: ("+ transform(M->UB_VRUNIT , pesqpict("SUB","UB_VRUNIT")) + ")"
            lRet := .F.

        ENDIF

        IF ! lRet
            cMensSol := " Valor do Preço Unit. deve ser menor que Valor do Preço de tabela ( "+ transform(ACOLS[N, nPosTab], pesqpict("SUB","UB_VRUNIT")) +")"  + PulaLinha
            cMensSol += " Ou "+ PulaLinha
            cMensSol += " Valor do Preço Unit. deve ser maior que o Valor Prc. Escalonado ( "+ transform(ACOLS[N, nNewPos] , pesqpict("SUB","UB_VRUNIT")) +" )"
            Help(NIL, NIL, "MtxFun - Preço Unit.", NIL, cMensProb, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMensSol})
        ENDIF

    ENDIF

    if lRet
        M->UB_ZVLRALT := "1"
    Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} VLDSUB02
Valida o campo X3_WHEN UB_VRUNIT
@author  author
date: "17/02/2020"
/*/
//-------------------------------------------------------------------
User Function VLDSUB02()
    Local lRet 		:= .F.
    Local lEmpLib	:= (cFilAnt $ '0101' .OR.  cFilAnt $ '0201')
    Local lVld		:= (M->UA_ZNEGPRE == "2" .OR. !EMPTY(M->UA_ZNPDTRE))

    IF 	lEmpLib .OR. lVld
        lRet 	:= .T.
    ENDIF

Return  lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MTXFUN01
Transportadora Padrao.
date: "17/02/2020"
/*/
//-------------------------------------------------------------------
User Function MTXFUN01()

    Local lEmpLib	:= (cFilAnt $ '0101' .OR. cFilAnt $ '0201' .OR. cFilAnt $ '0301')
    LocaL cTransp	:= ""

    If lEmpLib
		If  M->UA_ZFRECOR == "S"
			If (cFilAnt $ '0101/0301')
				If U_MTXTRANSP()
					cTransp := M->UA_ZTRANSP
				EndIf
			Else
				cTransp	:= SuperGetMv("MV_MTXTRAN",.F.,"")
				M->UA_ZTRANSP := cTransp
			EndIf
		Else
			M->UA_ZTRANSP := ""
		EndIf
    EndIf

Return cTransp

//-------------------------------------------------------------------
/*/{Protheus.doc} MTXFUN04
Transportadora Padrao de Redespacho.
date: "05/2022"
/*/
//-------------------------------------------------------------------
/*User Function MTXFUN04()
LocaL cTransp	:= ""

If xFilial("SUA") == "0101" .And. M->UA_TPFRETE == "E"
	If U_MTXTRANSP()
		cTransp := ""
	EndIf
Else
	cTransp := M->UA_TRANSP
EndIf

Return cTransp*/

//-------------------------------------------------------------------
/*/{Protheus.doc} MTXFUN02
Calcular os descontos caso for alterado
date: "17/02/2020"

/*/
//-------------------------------------------------------------------
User Function MTXFUN02()

    Local lEmp			:= (cFilAnt $ '0101' .OR.  cFilAnt $ '0201' .OR. cFilAnt $ '0202' .OR. cFilAnt $ '0301') // Regra para empresas (teste alessandro incluido emp 0301 na lista)
    Local lRet 			:= .T.

    Local cTabPrc       := M->UA_TABELA
    Local nFaixa        := 0
    Local nLine
    Local nPerDesc		:= 0
    Local nDescSpc		:= 0
    Local cGrpVend		:= "" // Grupo de clientes
    Local lRegPesFret	:= ((cFilAnt $ "0101/0201") .And. M->UA_TPFRETE == "C" .And. M->UA_ZFRECOR =="N" .And. M->UA_ZFRENF =='2') .Or. cFilAnt == "0301" // Regra para Frete Peso
    Local cUF			:= ""

    Local nUB_ACRE      := M->UA_ZACRE
    Local nUB_VALACRE   := 0
    Local _nCorLap:=0

    Local _nPZDes       := GdFieldPos("UB_ZDESCON ",aHeader)
    Local nUB_ZDESCON   := 0
    Local nDESTAB    	:= GdFieldPos("UB_ZDESTAB ",aHeader)
    Local _nVDESTAB     := 0
    Local nPFrete	    := GdFieldPos("UB_ZVALFRE",aHeader)
    Local nVFrete       := 0
    Local nPosQtde	    := GDFieldPos('UB_QUANT')
    Local _nQuant		:= 0
    Local nPosProd		:= GDFieldPos('UB_PRODUTO')
    Local _Cprod        := ""
    local nlapid        := GdFieldPos("UB_ZLAPIDA ",aHeader)
    Local nVlapid       := 0
    local ncorte        := GdFieldPos("UB_ZCORTE ",aHeader)
    Local nVCorte       := 0
    Local nNewPos		:= GdFieldPos("UB_ZPRCTAB",aHeader)
    Local _nZPrcTab     := 0
    Local nPosTab       := GdFieldPos("UB_PRCTAB",aHeader)
    Local _nPrcTab      := 0

    Local nPosvaldesc	:= GdFieldPos("UB_VALDESC",aHeader)
    Local nPosVlr 		:= GdFieldPos("UB_VRUNIT",aHeader)
    Local nPosTot 		:= GdFieldPos("UB_VLRITEM",aHeader)
    Local nPosDesc		:= GdFieldPos("UB_DESC",aHeader)


    nLine:= n //Não retirar

    // Valida se é prospect ou cliente.
    If lProspect
        DbSelectArea("SUS")
        DbSetorder(1)
        SUS->(MsSeek(xFilial("SUS")+M->UA_CLIENTE + M->UA_LOJA))
        cGrpVend := SUS->US_GRPVEN
        cUF 	 := SUS->US_EST
    Else
        DbSelectArea("SA1")
        DbSetorder(1)
        SA1->(MsSeek(xFilial("SA1")+M->UA_CLIENTE + M->UA_LOJA))
        cGrpVend := SA1->A1_GRPVEN

        If (M->UA_ZCONORD == "1")
            DbSelectArea("SA1")
            DbSetorder(1)
            SA1->(MsSeek(xFilial("SA1")+M->UA_ZCLIORD + M->UA_ZLOJA))

            cUF := SA1->A1_EST

            DbSelectArea("SA1")
            DbSetorder(1)
            SA1->(MsSeek(xFilial("SA1")+M->UA_CLIENTE + M->UA_LOJA))
        Else
            cUF := SA1->A1_EST
        EndIf
    Endif

    // Desconto 6 + Desconto Categorizado + Desconto Distribuição + Desconto Frete.
    nDescSpc := M->UA_ZDESCES + M->UA_ZDESDIS + M->UA_ZDESCFR//M->UA_ZDESCES + M->UA_ZDESCCT + M->UA_ZDESDIS + M->UA_ZDESCFR

    If lEmp


        _Cprod      := aCols[nLine][nPosProd]
        _nQuant	    := aCols[nLine][nPosQtde]
        _nZPrcTab   := aCols[nLine][nNewPos]
        _nVDESTAB   := aCols[nLine][nDESTAB]
        nVFrete     := aCols[nLine][nPFrete]
        nVlapid     := aCols[nLine][nlapid]
        nVCorte     := aCols[nLine][nCorte]
        _nPrcTab    := aCols[nLine][nPosTab]

		// Alterado o campo de Valor total do item(nPosTot), para Valor Uniário de Tabela (nPosTab) e posteriormente calculado dentro da função QtdItEsc
        nFaixa := U_QtdItEsc(aCols, _Cprod, nPosProd, nPosQtde, cTabPrc, cGrpvend,nPosTab)

        // Coleta o percentual de desconto na tabela de escalonamento.
        if M->UA_ZPLCT != '1' .or. !cFilAnt=="0202"
            nPerDesc := U_GetPDesc(nFaixa, cTabPrc, cGrpvend, _Cprod, ,M->UA_CONDPG, M->UA_TPFRETE)[1]["Desconto"]
        else
			nPerDesc := 0
		endif

        _nVlDesc:=0
        _nPDesc:=0
        _nVlProd:=0

        If  READVAR() == "M->UB_ZDESCON" .And. nLine == n
            nUB_ZDESCON  := M->UB_ZDESCON //nPerDesc  += M->UB_ZDESCO
        Else
            nUB_ZDESCON := aCols[nLine,_nPZDes]
        EndIf

        If  xfilial('SUA')  == '0202'
            IF nVlapid > 0
                _nCorLap += nVlapid / _nQuant
            EndIF

            IF nVCorte > 0
                _nCorLap += nVCorte / _nQuant
            EndIF
        Endif

        _nVlProd:= U_ClcDesc(_nPrcTab,nPerDesc,nDescSpc,@_nVlDesc,@_nPDesc,nUB_ZDESCON,@nUB_ACRE,@nUB_VALACRE,@_nCorLap)

        aCols[nLine,nPosVlr]   := _nVlProd //VALOR UNI
        aCols[nLine,nNewPos]   := _nVlProd

        aCols[nLine,nDESTAB]   := _nVlProd//DESC DIGITADO

        //Frete
        nVlrFrete:=0
        If xfilial('SUA')  == '0202'
            IF M->UA_ZFRENF == '1'//lCampNffre .and.
                nVlrFrete  := 0
            ELSE
                nVlrFrete  := ROUND(nVFrete  / _nQuant,2) // Valor do Frete por item
            ENDIF
        else
            IF lRegPesFret // Se calcula frete
                If !(AllTrim(Posicione("SA1", 1, XFilial("SA1") + M->(UA_CLIENTE + UA_LOJA), "A1_SATIV1")) $ SuperGetMV("SL_SEGDESD", .F., ""))
                    nVlrFrete:= U_PesoFret(cUF, _Cprod)
                Else
                    nVlrFrete:= 0
                EndIf
            Elseif (cFilAnt $ '0101' .OR.  cFilAnt $ '0201') .AND. M->UA_TPFRETE == "F"
                nVlrFrete:= 0
            eNDIF
        Endif

        aCols[nLine,nPosVlr]   +=  nVlrFrete
        //Fim Frete


        aCols[nLine,nPosTot]   := ROUND(aCols[nLine,nPosVlr] * _nQuant,2)//VALOR TOTAL

        If xfilial('SUA')  != '0202' //Talves aqui esteja o problema de vidros
            aCols[nLine,nPFrete]    := ROUND(nVlrFrete * _nQuant,2)
        endif
        aCols[nLine,nPosDesc]     := _nPDesc //+ nDescSpc //PERCENTUAL DE DESCONTO
        aCols[nLine][nPosvaldesc] := ROUND( _nVlDesc * _nQuant,2) //Valor do desconto




        Tk273Calcula(,,.T.)
        Tk273Refresh(.T.)
        Eval(bGDRefresh)

    ENDIF
Return  lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MTXTRANS
Busca Transportador com menor preço, em caso de Frete Cortesia
date: "22/02/2020"
/*/
//-------------------------------------------------------------------
User Function MTXTRANSP()

    Local aArea 		:= GetArea()
    Local oModelSim  	:= FWLoadModel("GFEX010")
    Local oModelNeg  	:= oModelSim:GetModel("GFEX010_01")
    Local oModelAgr  	:= oModelSim:GetModel("DETAIL_01")  // oModel do grid "Agrupadores"
    Local oModelDC   	:= oModelSim:GetModel("DETAIL_02")  // oModel do grid "Doc Carga"
    Local oModelIt   	:= oModelSim:GetModel("DETAIL_03")  // oModel do grid "Item Carga"
    Local oModelTr   	:= oModelSim:GetModel("DETAIL_04")  // oModel do grid "Trechos"
    Local oModelInt  	:= oModelSim:GetModel("SIMULA")     // oModel do field que dispara a simulaè±«o
    Local oModelCal1 	:= oModelSim:GetModel("DETAIL_05")  // oModel do calculo do frete
    Local oModelCal2 	:= oModelSim:GetModel("DETAIL_06")  // oModel das informaå¯¤es complemetares do calculo
    Local nCont      	:= 0
    Local cCdClFr		:= "0001" //-- simulacao de frete: considerar todas a negociacoes cadastradas no GFE.
    Local cTpOp			:= "" //-- simulacao de frete: considerar todas a negociacoes cadastradas no GFE.
    Local cTpDoc		:= ''
    Local nLenAcols		:= 0
    Local nItem			:= 0
    Local nPProduto		:= aScan(aHeader,{|x| AllTrim(x[2])=="UB_PRODUTO"})
    Local nPQtdVen		:= aScan(aHeader,{|x| AllTrim(x[2])=="UB_QUANT"})
    Local nPValor		:= aScan(aHeader,{|x| AllTrim(x[2])=="UB_VLRITEM"})
    Local nX			:= 0
    Local cCGCTran		:= ''
    Local nVlrFrt		:= 0
    Local nPrevEnt		:= 0
    Local aRet			:= {}
    Local nNumCalc		:= 0
    Local nClassFret	:= 0
    Local nTipOper		:= 0
    Local cTrecho		:= ""
    Local cTabela		:= ""
    Local cNumNegoc		:= ""
    Local cRota			:= ""
    Local dDatValid		:= ""
    Local cFaixa		:= ""
    Local cTipoVei		:= ""
    Local cCgc := ''
    Local nAltura		:= 0
    Local nVolume		:= 0
    Local lRet 			:= .T.
    Local cMunRedes	 	:= SuperGetmv("MV_MTXMUN",.F.,"3550308") // Municipio Redespacho,codigo IBGE, padrao Sao Paulo. 3550308

    SA1->(dbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA))

    cTpDoc := "001"//AllTrim(Posicione("SX5",1,xFilial("SX5")+"MQ"+M->C5_TIPO,"X5_DESCRI"))	//NORMAL

    oModelSim:SetOperation(3) //Seta como inclus?
    oModelSim:Activate()

    // oModelNeg:LoadValue('CONSNEG' ,AllTrim(Str(nRadio))) // -- 1=Considera Tab.Frete em Negociacao; 2=Considera apenas Tab.Frete Aprovadas
    oModelNeg:LoadValue('CONSNEG' ,"2" )

    //Agrupadores - N? obrigatorio
    oModelAgr:LoadValue('GWN_CDCLFR',cCdClFr)  //classificaè±«o de frete
    oModelAgr:LoadValue('GWN_CDTPOP',cTpOp)    //tipo da operaè±«o
    oModelAgr:LoadValue('GWN_DOC'   ,"ROMANEIO"     )
    //Documento de Carga
    oModelDC:LoadValue('GW1_EMISDC', SM0->M0_CGC) 	//codigo do emitente - chave
    oModelDC:LoadValue('GW1_NRDC'  , M->UA_NUM  ) 	//numero da nota - chave
    oModelDC:LoadValue('GW1_CDTPDC', cTpDoc) 		// tipo do documento - chave
    oModelDC:LoadValue('GW1_CDREM' , IIF(MTA410ChkEmit(SM0->M0_CGC),SM0->M0_CGC, u_mtxRetEmit(xFilial("SUA")) ) )  	//remetente
    oModelDC:LoadValue('GW1_CDDEST', IIF(MTA410ChkEmit(SA1->A1_CGC),SA1->A1_CGC, OMSM011COD(M->UA_CLIENTE,M->UA_LOJA,1,,) ) )   //destinatario
    oModelDC:LoadValue('GW1_TPFRET', "1")
    oModelDC:LoadValue('GW1_ICMSDC', "2")
    oModelDC:LoadValue('GW1_USO'   , "1")
    oModelDC:LoadValue('GW1_QTUNI' , 1)
    //Trechos
    oModelTr:LoadValue('GWU_EMISDC' ,SM0->M0_CGC)												//codigo do emitente - chave
    oModelTr:LoadValue('GWU_NRDC'   ,M->UA_NUM  ) 												//numero da nota - chave
    oModelTr:LoadValue('GWU_CDTPDC' ,cTpDoc)													// tipo do documento - chave
    oModelTr:LoadValue('GWU_SEQ'    ,"01"   )    												//sequencia - chave

    IF !EMPTY(M->UA_ZREDESP)
        oModelTr:LoadValue('GWU_NRCIDD' , cMunRedes )   // codigo da cidade para o calculo
    ELSE
        oModelTr:LoadValue('GWU_NRCIDD' ,AllTrim(TMS120CdUf(SA1->A1_EST, "1") + SA1->A1_COD_MUN))   // codigo da cidade para o calculo
    ENDIF

    nLenAcols := Len(aCols)
    //Itens
    For nX:= 1 To nLenACols
        If !GdDeleted(nX)
            nItem += 1
            nAltura := Posicione("SB5",1,xFilial("SB5")+aCols[nX,nPProduto],"B5_ALTURA")
            nVolume := (nAltura * SB5->B5_LARG * SB5->B5_COMPR) * aCols[nX,nPQtdVen]
            SB1->(DbSetOrder(1))
            SB1->(dbSeek(xFilial("SB1")+aCols[nX,nPProduto ]))
            //--VERIFICAR QUEST? DOS PRODUTOS
            oModelIt:LoadValue('GW8_EMISDC',SM0->M0_CGC)	//codigo do emitente - chave
            oModelIt:LoadValue('GW8_NRDC'  ,M->UA_NUM  ) 	//numero da nota - chave
            oModelIt:LoadValue('GW8_CDTPDC',cTpDoc) 		// tipo do documento - chave
            oModelIt:LoadValue('GW8_ITEM'  , "ITEM"+ PADL((nItem),3,"0")  )        		//codigo do item    -
            oModelIt:LoadValue('GW8_DSITEM', "ITEM GENERICO  "	+ PADL((nItem),3,"0"))  	//descriè±«o do item -
            oModelIt:LoadValue('GW8_CDCLFR',cCdClFr)    										//classificaè±«o de frete
            oModelIt:LoadValue('GW8_VOLUME',nVolume) 											//Volume
            oModelIt:LoadValue('GW8_PESOR' ,aCols[nX,nPQtdVen] * SB1->B1_PESBRU ) 		//peso real
            oModelIt:LoadValue('GW8_VALOR' ,aCols[nX,nPValor ] )     						//valor do item
            oModelIt:LoadValue('GW8_QTDE'  ,aCols[nX,nPQtdVen ] )     						//valor do item
            oModelIt:LoadValue('GW8_TRIBP' ,"1" )
            oModelIt:AddLine(.T.)
        EndIf
    Next nX

    // Dispara a simulaè±«o
    oModelInt:SetValue("INTEGRA" ,"A")

    //Verifica se h?linhas no model do calculo, se n? h?linhas significa que a simulaè±«o falhou
    If oModelCal1:GetQtdLine() > 1 .Or. !Empty( oModelCal1:GetValue('C1_NRCALC'  ,1) )
        //Percorre o grid, cada linha corresponde a um calculo diferente
        For nCont := 1 to oModelCal1:GetQtdLine()
            oModelCal1:GoLine( nCont )

            nVlrFrt	 		:= oModelCal1:GetValue('C1_VALFRT'  ,nCont )
            nPrevEnt  		:= oModelCal1:GetValue('C1_DTPREN'  ,nCont ) - ddatabase

            nNumCalc		:= oModelCal2:GetValue	("C2_NRCALC" ,1 )  //"N?ero C?culo"
            nClassFret		:= oModelCal2:GetValue	("C2_CDCLFR" ,1 )  //"Class Frete"
            nTipOper		:= oModelCal2:GetValue	("C2_CDTPOP" ,1 )  //"Tipo Operaè±«o"
            cTrecho			:= oModelCal2:GetValue	("C2_SEQ" ,1 )     //"Trecho"
            cCGCTran		:= oModelCal2:GetValue	("C2_CDEMIT" ,1 )  //"Emit Tabela"
            cTabela			:= oModelCal2:GetValue	("C2_NRTAB" ,1 )   //"Nr tabela "
            cNumNegoc		:= oModelCal2:GetValue	("C2_NRNEG" ,1 )   //"Nr Negoc"
            cRota			:= oModelCal2:GetValue	("C2_NRROTA" ,1 )  //"Rota"
            dDatValid		:= oModelCal2:GetValue	("C2_DTVAL" ,1 )   //"Data Validade"
            cFaixa			:= oModelCal2:GetValue	("C2_CDFXTV" ,1 )  //"Faixa"
            cTipoVei		:= oModelCal2:GetValue	("C2_CDTPVC" ,1 )  //"Tipo Ve?ulo"

            If cFilant == '0101' .AND. M->UA_TPFRETE == "E" .AND. !EMPTY(UA_ZTRANSP)
				SA4->(dbSetOrder(3))
				If SA4->(dbSeek(xFilial("SA4")+cCGCTran))
					If SA4->A4_COD == M->UA_ZTRANSP
						M->UA_FRETE := nVlrFrt
						avalores[4] := nVlrFrt
						Return .T.
					EndIf
				Else
					cCGC := u_mtxRetCGC(cCGCTran)
					If SA4->(dbSeek(xFilial("SA4")+cCGC))
						If SA4->A4_COD == M->UA_ZTRANSP
							M->UA_FRETE := nVlrFrt
							avalores[4] := nVlrFrt
							Return .T.
						EndIf
					EndIf
				EndIf
			Else
				SA4->(dbSetOrder(3))
				If SA4->(dbSeek(xFilial("SA4")+cCGCTran))
						aAdd (aRet, {,SA4->A4_COD,SA4->A4_NOME,nVlrFrt,nPrevEnt,nNumCalc,nClassFret,nTipOper,cTrecho,cTabela,cNumNegoc,cRota,dDatValid,cFaixa,cTipoVei,.T.})
				Else
					cCGC := u_mtxRetCGC(cCGCTran)
					If SA4->(dbSeek(xFilial("SA4")+cCGC))
							AADD (aRet, {,SA4->A4_COD,SA4->A4_NOME,nVlrFrt,nPrevEnt,nNumCalc,nClassFret,nTipOper,cTrecho,cTabela,cNumNegoc,cRota,dDatValid,cFaixa,cTipoVei,.T.})
					EndIf
				EndIf
			EndIf
        Next nCont

    EndIf

    IF LEN(aRet) > 0
        //Ordenar pelo menor valor.
        ASORT(aRet, , , { | x,y | x[4] < y[4] } )
        //If xFilial("SUA") == "0101" .And. M->UA_TPFRETE == "E"
		//	M->UA_ZREDESP := aRet[1,2]
		//Else
			M->UA_ZTRANSP := aRet[1,2]
			M->UA_TRANSP  := aRet[1,2]
		//EndIf
    Else
        lRet 	:= .F.
    Endif

    RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function
Funçao para retornar o CGC de um determinado emitente na
simulaçao de frete. Pois, nem sempre o codigo do emitente
será o cnpj.
@Parämetro: cCodEmit - Codigo do emitente
@author  author
date: "22/02/2020"
/*/
//-------------------------------------------------------------------
User Function mtxRetCGC(cCodEmit)
    Local cCGC  := ""
    Local aArea := GetArea()

    dbSelectArea("GU3")
    dbSetOrder(1)

    If DBSeek(xFilial("GU3") + cCodEmit)
        cCGC := GU3->GU3_IDFED
    EndIf

    RestArea( aArea )

Return cCGC

//-------------------------------------------------------------------
/*/{Protheus.doc} mtxRetEmit
Função para retornar o codigo do emitente a partir da
filial.
@Parametro: cFil - Codigo da filial
date: 22/02/2020
/*/
//-------------------------------------------------------------------

User Function mtxRetEmit(cFil)

    Local aAreaGW0
    Local aArea := GetArea()
    Local cCodGFE := ""

    aAreaGW0 := GW0->( GetArea() )
    dbSelectArea("GW0")
    GW0->( dbSetOrder(1) )
    GW0->( DbSeek( Space( TamSx3("F2_FILIAL")[1] )+PadR( "FILIALEMIT",TamSx3("GW0_TABELA")[1] )+PadR( cFil,TamSx3("GW0_CHAVE")[1] ) ) )
    If !GW0->( EOF() ) .And. GW0->GW0_FILIAL == Space( TamSx3("F2_FILIAL")[1] );
            .And. GW0->GW0_TABELA == PadR( "FILIALEMIT",TamSx3("GW0_TABELA")[1] );
            .And. GW0->GW0_CHAVE == PadR( cFil,TamSx3("GW0_CHAVE")[1] )

        cCodGFE := PadR( GW0->GW0_CHAR01,TamSx3("GW1_EMISDC")[1] )
    EndIf
    RestArea( aAreaGW0 )
    RestArea( aArea )

Return cCodGFE


//-------------------------------------------------------------------
/*/{Protheus.doc} MTXBLQCP
Validação para bloquear campos do Tele atendimento
@author  author
date: "24/02/2020"
/*/
//-------------------------------------------------------------------
User Function MTXBLQCP()
    Local lRet 		:= .T.
    Local lEmpLib	:= (cFilAnt $ '0101' .OR.  cFilAnt $ '0201')
    IF lEmpLib
        DO Case
        CASE READVAR() == "M->UB_ACRE"
            lRet	:= .F.
        CASE READVAR() == "M->UB_VALACRE"
            lRet	:= .F.
        EndCase
    ENDIF

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MTXDESC6
Validacao do desconto 6 Tela Atendimento
@author  author
date: "24/02/2020"
/*/
//-------------------------------------------------------------------
User Function MTXDESC6(_lFim)

    Local cCondAV   := SuperGetMv("ZDESC6VIST", .F., "")
    Local lRet      := .T.
    Local nZDesc6   := SuperGetMv("ZDESC6MAX", .F., 0)
    Local _cSegLOJ  := SuperGetMv("ZSEGLOJ", .F., "010113/010114")
    Local _cSegIND  := SuperGetMv("ZSEGIND", .F., "010111/010112")
    Local _cSegRED  := SuperGetMv("ZSEGRED", .F., "010202/010203/010204/010205")
    Local nVMD6LOJ   := SuperGetMv("ZD6MINLOJ", .F., 8000)
    Local nVMD6IND   := SuperGetMv("ZD6MININD", .F., 8000)
    Local nVMD6RED   := SuperGetMv("ZD6MINRED", .F., 5000)
    Local nVMinD6   := 0
    Local _nVTot    := 0
    Local nLine     := 0
    Local _lPedFeC:= IIF(cFilAnt=="0201" .and. ! EMPTY(M->UA_ZFILCOM) .AND. ! EMPTY(M->UA_ZPEDCOM),.T.,.F.)
    Local _nValPeC:= 0
    Local _nDesPeC:= 0
    Local _cFretC:= ""
    Local _cSegCli := ""
    Local _lD6FobS := .F. //Desconto 6, frete fob, Cliente SC, pedido acima de 3000 permite 2.5
    //Local _cUf:=""
    Local _nVlMinDF:= 0

    Begin Sequence
        if _lPedFeC
            getpdf(M->UA_ZFILCOM, M->UA_ZPEDCOM, @_nDesPeC, @_nValPeC, @_cFretC)
            if  M->UA_ZDESCES!=_nDesPeC .and. M->UA_ZDESCES>0
                MSGSTOP("Desconto 6 do pedido complementar "+ Transform(_nDesPeC, "@E 99.99") + ",esta diferente do pedido atual. Preencher com o mesmo valor ou limpar o campo de pedido e ajustar o pedido complementar primeiro", "Desconto")
                Break
            endif

            if  M->UA_ZFRECOR!=_cFretC
                MSGSTOP("Frete cortesia do pedido complementar "+ _cFretC + ",esta diferente do pedido atual. Preencher com o mesmo valor ou limpar o campo de pedido e ajustar o pedido complementar primeiro", "Frete Cortesia")
                Break
            endif



        endif

        If  M->UA_ZDESCES!=0

            If M->UA_ZDESCES > nZDesc6
                MSGSTOP("Não é possivel desconto maior que: " + Transform(nZDesc6, "@E 99.99") + "%", "Desconto")
                Break
            EndIf

            if cFilAnt$"0101/0201" .and. M->UA_ZDESCFR>0
                MSGSTOP("Não é possivel desconto 6 pois já foi consedido desconto de 2,5% pelo coordenador", "Desconto")
                Break
            endif

            if cFilAnt$"0101/0201" .and. M->UA_TPFRETE=="F"
                //_cUf:= POSICIONE("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_EST")
                //if _cUf=="SC"
                    _lD6FobS:= .T.
                //endif
            endif

            if !(M->UA_CONDPG $ cCondAV) .and. (!_lD6FobS) //.And. Empty(M->UA_ZDTLIBS)
                //ShowHelpDlg("CondPgto", {"Só é permitido desconto específico quando a condição de pagamento for uma das seguintes: " + cCondAV}, 1, {"Verifique as informações."}, 1)
                MSGSTOP("Só é permitido desconto específico quando a condição de pagamento for uma das seguintes: " + cCondAV+chr(10)+chr(13)+"Zere o desconto para continuar...","Desconto")
                if !_lFim
                    M->UA_ZDESCES := 0
                endif
                Break
            endif

            If M->UA_ZFRECOR == "S" .and. !(cFilAnt $ "0101/0301")
                MSGSTOP("Não é permitido Desconto 6 e frete cortesia", "Desconto")
                Break
            EndIf

            if _lFim .and. cFilAnt$"0101/0201"
                For nLine := 1 To Len(aCols)
                    If !GDDeleted(nLine)
                        _nVTot += GDFieldGet("UB_VLRITEM", nLine)
                    EndIf
                Next nLine

                _nVTot+= _nValPeC

                If !(M->UA_PROSPEC)
                    dbSelectArea("SA1")
                    SA1->(dbsetorder(1))
                    SA1->(dbseek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA))
                    _cSegCli:=SA1->A1_SATIV1
                    if !Empty(_cSegCli)
                        If _cSegCli$_cSegLOJ
                            nVMinD6:= nVMD6LOJ
                        elseif _cSegCli$_cSegIND
                            nVMinD6:= nVMD6IND
                        elseif _cSegCli$_cSegRED
                            nVMinD6:= nVMD6RED
                        endif
                    endif
                endif

                If M->UA_TPFRETE <> "F"
					If _nVTot <= nVMinD6 .and. !(M->UA_CONDPG $ cCondAV) .and. (!_lD6FobS .or. (_lD6FobS .and. _nVTot<3000) .or. (M->UA_CONDPG $ cCondAV .and. _nVTot<3000))
						if (!_lD6FobS .or. (_lD6FobS .and. _nVTot<3000) .or. (M->UA_CONDPG $ cCondAV .and. _nVTot<3000))
							MSGSTOP("Não é permitido Desconto 6 para pedidos menores que "+Transform(3000, "@E 9,999,999.99"), "Desconto")
						else
							MSGSTOP("Não é permitido Desconto 6 para pedidos menores que "+Transform(nVMinD6, "@E 9,999,999.99"), "Desconto")
						endif
						Break
					endif
				EndIf
            endif

            /*
            SaveInter()
            U_MTX13P07(.T.)
            RestInter()
            */
        EndIf

        if !_lFim
            // Se acionado o desconto 6 sera limpo o campo
            // Desconto do Coordenador
            U_LIMPDESCO()

            U_CALCDESC("UB_VRUNIT")
            EVal(bGDRefresh)
        endif

        if _lFim .and. cFilAnt$"0101/0201" .and. M->UA_ZFRECOR == "S"
            if _nVTot==0
                For nLine := 1 To Len(aCols)
                    If !GDDeleted(nLine)
                        _nVTot += GDFieldGet("UB_VLRITEM", nLine)
                    EndIf
                Next nLine

                _nVTot+= _nValPeC

            endif

            If cFilAnt <> "0101"
				If !(M->UA_PROSPEC)
					dbSelectArea("SA1")
					SA1->(dbsetorder(1))
					SA1->(dbseek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA))
					_cSegCli:=SA1->A1_SATIV1
					if !Empty(_cSegCli)
						If _cSegCli$_cSegLOJ
							nVMinD6:= nVMD6LOJ
						elseif _cSegCli$_cSegIND
							nVMinD6:= nVMD6IND
						elseif _cSegCli$_cSegRED
							nVMinD6:= nVMD6RED
						endif
					endif
				endif

				If _nVTot <= nVMinD6
					MSGSTOP("Não é permitido frete cortesia para pedidos menores que "+Transform(nVMinD6, "@E 9,999,999.99"), "Desconto")
					Break
				endif
			EndIf
        endif

        //Regra de desconto de 4.5% para PZ com frete FOB e pedido acima de 5000
        if cFilAnt=="0301" .and. M->UA_ZDESCFR!=0

            _nVlMinDF:= SuperGetMV("VLMINDESFR",.F., 5000) //Valor minimo para desconto de frete em PZ 5000

            if !M->UA_TPFRETE=="F"
                MSGSTOP("Não é permitido desconto de frete para frete diferente de FOB", "Desconto")
                Break
            else
                _nVTot:= 0
                For nLine := 1 To Len(aCols)
                    If !GDDeleted(nLine)
                        _nVTot += GDFieldGet("UB_VLRITEM", nLine)
                    EndIf
                Next nLine

                if _nVTot < _nVlMinDF
                    MSGSTOP("Não é permitido desconto de frete com valor do pedido menor que R$ "+cValtoChar(_nVlMinDF), "Desconto")
                    Break
                endif
            endif
        ENDIF

    Recover
        lRet := .F.
    End Sequence

Return lRet


// Efetua a limpeza do desconto do
// coordenador
User Function LIMPDESCO()
Local nLine         := 0
Local nPosDescon	:= GDFieldPos('UB_ZDESCON')
For nLine := 1 To Len(aCols)
    If  !GDDeleted(nLine)
        aCols[nLine,nPosDescon]:= 0
    Endif
Next nLine
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MTXRecVal
Funcao chamada para recacular desconto 6 ao trocar condicao de pagto, anteriormente estava apenas zerando o campo desconto 6 mais
nao recauculava essa funcao chamada em um gatilho no campo UA_CONDPG
@author  Alessandro Cascaes
date: "04/03/2021"
/*/
//-------------------------------------------------------------------
User Function MTXRecVal()
    U_CALCDESC("UB_VRUNIT")
    EVal(bGDRefresh)
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MTXDESCUB
Validacao do desconto 8.64 Tela Atendimento (campo desconto (UB_DESC))
@author  Alessandro Cascaes
date: "03/03/2021"
UB_ZDESCON
/*/
//-------------------------------------------------------------------
User Function MTXDESCUB(cCampo)
Local lRet      := .T.
Local nDescUB   := SuperGetMv("ZDESCUB", .F., 0)
//Local cFilial   := xFilial('SUA')
Local nDesc6    := M->UA_ZDESCES
Local nDesConc  := 0


If  cCampo == 'UB_ZDESCON'  .AND.  M->UA_ZNEGPRE == '1'

    nDesConc := nDescUB - nDesc6

    If  M->UB_ZDESCON > nDesConc
        MSGSTOP('Não é permitido desconto maior que '+AllTrim(Transform(nDesConc, "@E 99.99")) +'%' , "Desconto")
        lRet := .F.
    Else
        lRet := .T.
        U_CALCDESC("UB_VRUNIT")
        EVal(bGDRefresh)
    EndIf

EndIf

Return(lRet)



/*/{Protheus.doc} ValidX3
Validação para o campos do dicionário.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 10/11/2020
@return logical, se pode alterar.
/*/
User Function ValidX3()

    Local cField    := ReadVar()
    Local lOk       := .T.
    Local nMax      := SuperGetMV("SL_PMXDESD", .F., 0)

    Begin Sequence
        If "UA_ZDESDIS" $ cField
            If &(cField) > nMax
                ShowHelpDlg("DescMax", {"O desconto máximo permitido para cliente distribuição é de: " + cValToChar(nMax)}, 1, {"Verifique as informações."}, 1)
                Break
            EndIf

            // Recalcula valores.
            U_CALCDESC("UB_VRUNIT")
            Eval(bGDRefresh)
        EndIf
    Recover
        lOk := .F.
    End Sequence

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} MTXFREACRE
Rotina copiada do FOnte MTX12P07 e adaptada para o Calculo do Frete x Peso
@author  Thiago.Zoppi
date: "29/02/2020"
/*/
//-------------------------------------------------------------------
User Function MTXFREACRE(cProduto,_cClie,_cLoja)
    Local nPorc   := 0
    Local cSQL     := ''
    Local cTmp     := GetNextAlias()
    Local cITEMCC  := ""
    Local cGRUPO   := ""
    Local aAreaSB1 := {}
    Local _lAltB1  := .F.

    if xFilial("SB1")+ cProduto<>SB1->(B1_FILIAL+B1_COD)
        _lAltB1  := .T.
        aAreaSB1 := SB1->(GETAREA())
        DbSelectArea("SB1")
        DbSetOrder(1)
        DbSeek(xFilial("SB1")+ cProduto)
    endif

    cITEMCC := Alltrim(SB1->B1_ITEMCC)//ALLTRIM(Posicione("SB1",1,xFilial("SB1")+ cProduto , "B1_ITEMCC"))
    cGRUPO  := Alltrim(SB1->B1_GRUPO)//ALLTRIM(Posicione("SB1",1,xFilial("SB1")+ cProduto , "B1_GRUPO"))

    nTotal := 0

    cSQL := " SELECT Z07_FILIAL ,Z07_COD,Z07_EST,Z07_ACRES,Z07_IEMAQ "
    cSQL += " ,Z07_PFMAQ,Z07_IEFERR,Z07_PFFERR,Z07_IEPROD,Z07_PFPROD "
    cSQL += " ,A1_PESSOA, A1_INSCR "
    cSQL += " FROM Z07010 AS Z07 "
    cSQL += " INNER JOIN SA1010 AS SA1 ON (SA1.A1_EST = Z07.Z07_EST AND SA1.D_E_L_E_T_ <> '*') "
    cSQL += " WHERE  "
    cSQL += " Z07.D_E_L_E_T_ <> '*' "
    cSQL += " AND Z07_FILIAL = '" + xFilial("Z07") + "' "
    cSQL += " AND SA1.A1_COD = '" + _cClie  + "' "
    cSQL += " AND SA1.A1_LOJA = '" + _cLoja	 + "' "

    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSQL),cTmp, .T., .T.)
    Count To nTotal
    ( cTmp )->(dbGoTop())
    IF nTotal > 0
        While ( cTmp )->( !EOF() )

            IF cITEMCC == '030102000' // MAQUINAS   teste
                IF ALLTRIM((cTmp)->A1_INSCR) != "ISENTO" .OR. ALLTRIM((cTmp)->A1_INSCR) != "ISENTA"
                    nPorc := (cTmp)->Z07_IEMAQ
                ELSEIF (ALLTRIM((cTmp)->A1_INSCR) == "ISENTO" .OR. ALLTRIM((cTmp)->A1_INSCR) == "ISENTA" ) .AND. ALLTRIM((cTmp)->A1_PESSOA) == 'F'
                    nPorc := (cTmp)->Z07_PFMAQ
                ELSE
                    nPorc := (cTmp)->Z07_ACRES
                ENDIF
            ELSEIF  cITEMCC == '030101000' .Or. (cFilAnt == "0301" .and. cGRUPO <> "3A") // FOTO PRODUTO
                IF ALLTRIM((cTmp)->A1_INSCR) != "ISENTO" .OR. ALLTRIM((cTmp)->A1_INSCR) != "ISENTA"
                    nPorc := (cTmp)->Z07_IEPROD
                ELSEIF (ALLTRIM((cTmp)->A1_INSCR) == "ISENTO" .OR. ALLTRIM((cTmp)->A1_INSCR) == "ISENTA" ) .AND. ALLTRIM((cTmp)->A1_PESSOA) == 'F'
                    nPorc := (cTmp)->Z07_PFPROD
                ELSE
                    nPorc := (cTmp)->Z07_ACRES
                ENDIF
            ELSEIF  cITEMCC == '010100000' // FERRAGENS
                IF ALLTRIM((cTmp)->A1_INSCR) != "ISENTO" .OR. ALLTRIM((cTmp)->A1_INSCR) != "ISENTA"
                    nPorc := (cTmp)->Z07_IEFERR
                ELSEIF (ALLTRIM((cTmp)->A1_INSCR) == "ISENTO" .OR. ALLTRIM((cTmp)->A1_INSCR) == "ISENTA" ) .AND. ALLTRIM((cTmp)->A1_PESSOA) == 'F'
                    nPorc := (cTmp)->Z07_PFFERR
                ELSE
                    nPorc := (cTmp)->Z07_ACRES
                ENDIF
            ELSE  // '020101' //GENERICO
                nPorc := (cTmp)->Z07_ACRES
            ENDIF
            (cTmp)->(DBSkip())
        EndDo
    ELSE
        MsgStop("NENHUM CADASTRO DE % ACRÉSCIMO SOBRE VALOR DE FRETE CALCULADO ENCONTRADO PARA O ESTADO DO CLIENTE! FAVOR VERIFICAR CADASTRO.", "Atencao")
    ENDIF
    ( cTmp )->(dbCloseArea())

    if _lAltB1
        RESTAREA(aAreaSB1)
    endif

Return nPorc

//-------------------------------------------------------------------
/*/{Protheus.doc} MTXVlDORC
Validar Validade do orçamento.
@param1 - Exibe erro em tela
@author  Thiago.Zoppi
date: "09/03/2020"
/*/
//-------------------------------------------------------------------
User Function MTXVlDORC()
    Local lRet      := .T.
    Local _dDt      := Date()
    Local aArea     := GetArea()
    Local dDtLimite := CriaVar("UA_DTLIM")

    // valida se o orçamento já existe, se esta realizando uma alteração
    // pois quando altera o cliente a data limite atualiza para a data do dia, então busca a data já gravada anteriormente
    // DbSelectArea("SUA")
    // SUA->(DbSetOrder(1))
    // SUA->(DbSeek(xFilial("SUA") + M->UA_NUM))
    // If Found()
    //     dDtLimite := SUA->UA_DTLIM
    // Else
        dDtLimite := M->UA_DTLIM
    // EndIf

    IF (TkGetTipoAte() $ "245")
        IF M->UA_EMISSAO <> NIL .AND. M->UA_OPERADO <> NIL
            _dDt := IIF( dDtLimite != NIL, dDtLimite, M->UA_EMISSAO + TkPosto(M->UA_OPERADO,"U0_VALIDAD")  )
            IF _dDt < date()//M->UA_EMISSAO + TkPosto(M->UA_OPERADO,"U0_VALIDAD") < dDataBase
                lRet   := .F.
            ENDIF
        ENDIF
    ENDIF

    RestArea(aArea)

Return lRet


/*/{Protheus.doc} MTXVLDVOL
Função que valida os volumes, calculando os produtos em pedidos no mes corrente.
@author  Thiago.Zoppi
date: "24/03/2020"
/*/
//-------------------------------------------------------------------
USER FUNCTION MTXVLDVOL(nOpc)

    Local aOrcam    := {}
    Local aPVs      := {}
    local cAlias    := GetNextAlias()
    Local cGrupo    := ""
    Local lOk       := .T.
    Local lProd     := .F.
    Local cLog      := ""
    Local nCount    := 0
    Local nPos      := 0
    Local nValUtil  := 0
    Local cNumPv    := Iif(nOpc==4,SUA->UA_NUMSC5,M->UA_NUMSC5)

    For nCount := 1 To Len(aCols)
        If !GDDeleted(nCount)
            cGrupo := Posicione("SB1", 1, XFilial("SB1") + GDFieldGet("UB_PRODUTO", nCount), "B1_GRUPO")

            //If (nPos := AScan(aOrcam, {|x| x["Grupo"] == cGrupo})) == 0
                AAdd(aOrcam, JSONObject():New())
                nPos := Len(aOrcam)

                aOrcam[nPos]["Grupo"] := cGrupo
                aOrcam[nPos]["Produtos"] := {}
                aOrcam[nPos]["Qtde"] := 0
            //EndIf

            aOrcam[nPos]["Qtde"] += GDFieldGet("UB_QUANT", nCount)
            AAdd(aOrcam[nPos]["Produtos"], JSONObject():New())
            ATail(aOrcam[nPos]["Produtos"])["Produto"] := GDFieldGet("UB_PRODUTO", nCount)
            ATail(aOrcam[nPos]["Produtos"])["Qtde"] := GDFieldGet("UB_QUANT", nCount)
        EndIf
    Next nCount

    BeginSQL Alias cAlias
        SELECT
            PRODUTO,
            GRUPO,
            LIMCLI,
            SUM(UTILCLI) UTILCLI,
            LIMTOT,
            SUM(UTILTOT) UTILTOT
        FROM
            (SELECT
                Z11_PROD PRODUTO,
                Z11_GRUPO GRUPO,
                Z11_QTDMAX LIMCLI,
                SUM(CASE
                        WHEN
                            SB1_CLI.B1_GRUPO IS NULL
                        THEN
                            0
                        ELSE
                            SC6_CLI.C6_QTDVEN
                END) UTILCLI,
                Z11_MAXTOT LIMTOT,
                0 UTILTOT
            FROM
                %Table:Z11% Z11
            LEFT JOIN
                %Table:SC5% SC5_CLI
                ON 	SC5_CLI.C5_FILIAL = %XFilial:SC5%
                AND SC5_CLI.C5_NUM != %Exp:cNumPv%
                AND SC5_CLI.C5_CLIENT = %Exp:M->UA_CLIENTE%
                AND SC5_CLI.C5_LOJACLI = %Exp:M->UA_LOJA%
                AND SUBSTRING(SC5_CLI.C5_EMISSAO, 1, 6) = %Exp:Left(DToS(Date()), 6)%
                AND SC5_CLI.%NotDel%
            LEFT JOIN
                %Table:SC6% SC6_CLI
                ON  SC6_CLI.C6_FILIAL = SC5_CLI.C5_FILIAL
                AND SC6_CLI.C6_NUM = SC5_CLI.C5_NUM
                AND SC6_CLI.C6_BLQ != 'R'
                AND SC6_CLI.%NotDel%
            LEFT JOIN
                %Table:SB1% SB1_CLI
                ON  SB1_CLI.B1_FILIAL = %XFilial:SB1%
                AND SB1_CLI.B1_COD = SC6_CLI.C6_PRODUTO
                AND SB1_CLI.B1_GRUPO = Z11_GRUPO
                AND SB1_CLI.%NotDel%
            WHERE
                    Z11_FILIAL = %XFilial:Z11%
                AND Z11.%NotDel%
            GROUP BY
                Z11_PROD,
                Z11_GRUPO,
                Z11_QTDMAX,
                Z11_MAXTOT

            UNION ALL

            SELECT
                Z11_PROD PRODUTO,
                Z11_GRUPO GRUPO,
                Z11_QTDMAX LIMCLI,
                0 UTILCLI,
                Z11_MAXTOT LIMTOT,
                SUM(CASE
                        WHEN
                            SB1_TOT.B1_GRUPO IS NULL
                        THEN
                            0
                        ELSE
                            SC6_TOT.C6_QTDVEN
                END) UTILTOT
            FROM
                %Table:Z11% Z11
            LEFT JOIN
                %Table:SC5% SC5_TOT
                ON 	SC5_TOT.C5_FILIAL = %XFilial:SC5%
                AND SC5_TOT.C5_NUM != %Exp:cNumPv%
                AND SUBSTRING(SC5_TOT.C5_EMISSAO, 1, 6) = %Exp:Left(DToS(Date()), 6)%
                AND SC5_TOT.%NotDel%
            LEFT JOIN
                %Table:SC6% SC6_TOT
                ON  SC6_TOT.C6_FILIAL = SC5_TOT.C5_FILIAL
                AND SC6_TOT.C6_NUM = SC5_TOT.C5_NUM
                AND SC6_TOT.C6_BLQ != 'R'
                AND SC6_TOT.%NotDel%
            LEFT JOIN
                %Table:SB1% SB1_TOT
                ON  SB1_TOT.B1_FILIAL = %XFilial:SB1%
                AND SB1_TOT.B1_COD = SC6_TOT.C6_PRODUTO
                AND SB1_TOT.B1_GRUPO = Z11_GRUPO
                AND SB1_TOT.%NotDel%
            WHERE
                    Z11_FILIAL = %XFilial:Z11%
                AND Z11.%NotDel%
            GROUP BY
                Z11_PROD,
                Z11_GRUPO,
                Z11_QTDMAX,
                Z11_MAXTOT) TAB
        GROUP BY
            PRODUTO,
            GRUPO,
            LIMCLI,
            LIMTOT
        ORDER BY
            PRODUTO DESC,
            GRUPO,
            LIMCLI,
            LIMTOT
    EndSQL

    While !(cAlias)->(EOF())
        AAdd(aPVs, JSONObject():New())

        ATail(aPVs)["Produto"] := (cAlias)->PRODUTO
        ATail(aPVs)["Grupo"] := (cAlias)->GRUPO
        ATail(aPVs)["LimiteCliente"] := (cAlias)->LIMCLI
        ATail(aPVs)["UtilizadoCliente"] := (cAlias)->UTILCLI
        ATail(aPVs)["LimiteTotal"] := (cAlias)->LIMTOT
        ATail(aPVs)["UtilizadoTotal"] := (cAlias)->UTILTOT

        (cAlias)->(DBSkip())
    End
    (cAlias)->(DBCloseArea())

    For nCount := 1 To Len(aOrcam)
        lProd := .F.
        If (nPos := AScan(aPVs, {|x| Alltrim(x["Produto"]) == Alltrim(aOrcam[nCount]["Produtos"][01]["Produto"])})) > 0
            // Verifica se o limite do cliente foi atingido.
            If aPVs[nPos]["LimiteCliente"] > 0 .And. (nValUtil := aPVs[nPos]["UtilizadoCliente"] + aOrcam[nCount]["Qtde"]) > aPVs[nPos]["LimiteCliente"]
                cLog += "Produto: " + AllTrim(aOrcam[nCount]["Produto"]) + " atingiu o limite no período. Limite: " + cValToChar(aPVs[nPos]["LimiteCliente"]) + " "
                cLog += "Utilizado:" + cValToChar(nValUtil) + " Qtde. solicitada: " + cValToChar(aOrcam[nCount]["Qtde"]) + CRLF
                lProd := .T.
            // Verifica se o limite da empresa foi atingido.
            ElseIf aPVs[nPos]["LimiteTotal"] > 0 .And. (nValUtil := aPVs[nPos]["UtilizadoTotal"] + aOrcam[nCount]["Qtde"]) > aPVs[nPos]["LimiteTotal"]
                cLog += "Produto: " + AllTrim(aOrcam[nCount]["Produto"]) + " atingiu o limite total de vendas para a empresa no período. Limite: " + cValToChar(aPVs[nPos]["LimiteTotal"]) + " "
                cLog += "Utilizado:" + cValToChar(nValUtil) + " Qtde. solicitada: " + cValToChar(aOrcam[nCount]["Qtde"]) + CRLF
                lProd := .T.
            EndIf
        EndIf
        If (nPos := AScan(aPVs, {|x| x["Grupo"] == aOrcam[nCount]["Grupo"]})) > 0 .and. !lProd
            // Verifica se o limite do cliente foi atingido.
            If aPVs[nPos]["LimiteCliente"] > 0 .And. (nValUtil := aPVs[nPos]["UtilizadoCliente"] + aOrcam[nCount]["Qtde"]) > aPVs[nPos]["LimiteCliente"]
                cLog += "Grupo: " + AllTrim(aOrcam[nCount]["Grupo"]) + " atingiu o limite no período. Limite: " + cValToChar(aPVs[nPos]["LimiteCliente"]) + " "
                cLog += "Utilizado:" + cValToChar(nValUtil) + " Qtde. solicitada: " + cValToChar(aOrcam[nCount]["Qtde"]) + CRLF
                cLog += "Produtos:" +  CRLF
                AEVal(aOrcam[nCount]["Produtos"], {|x| cLog += AllTrim(x["Produto"]) + " - Quantidade: " + cValToChar(x["Qtde"]) + CRLF})
            // Verifica se o limite da empresa foi atingido.
            ElseIf aPVs[nPos]["LimiteTotal"] > 0 .And. (nValUtil := aPVs[nPos]["UtilizadoTotal"] + aOrcam[nCount]["Qtde"]) > aPVs[nPos]["LimiteTotal"]
                cLog += "Grupo: " + AllTrim(aOrcam[nCount]["Grupo"]) + " atingiu o limite total de vendas para a empresa no período. Limite: " + cValToChar(aPVs[nPos]["LimiteTotal"]) + " "
                cLog += "Utilizado:" + cValToChar(nValUtil) + " Qtde. solicitada: " + cValToChar(aOrcam[nCount]["Qtde"]) + CRLF
                cLog += "Produtos:" +  CRLF
                AEVal(aOrcam[nCount]["Produtos"], {|x| cLog += AllTrim(x["Produto"]) + " - Quantidade: " + cValToChar(x["Qtde"]) + CRLF})
            EndIf
        EndIf
    Next nCount

    If !Empty(cLog)
        If !Empty(M->UA_NUMSC5)
            MsgInfo("Não é possível alterar esse atendimento, o mesmo já possui pedido gerado e irá travar no bloqueio de quantidade de venda mensal. Favor cancelar o pedido e gerar um novo atendimento!", "MTXFUN")
            lRet := .F.
        Else
            cLog := DToC(Date()) + "-" + TIME() + " - Solicitação de Analise enviada,  Usuário: " + AllTrim(UsrRetName(RetCodUsr())) + CRLF;
                + Replicate("-", 100) + CRLF;
                + cLog

            If !Empty(M->UA_ZRESTRI)
                cLog := cLog + CRLF + M->UA_ZRESTRI
            EndIf

            If (lOk := U_MTXMSG(cLog, "Altere os valores dos itens, ou solicite libereção Superior"))
                If M->UA_OPER == "1" .And. Empty(M->UA_NUMSC5)
                    M->UA_OPER := "2"
                EndIf
                M->UA_ZRESTRI := cLog
            EndIf
        EndIf
    EndIf

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} MTXMSG
Mensagem Genéricas
@author  author
date: "25/03/2020"
/*/
//-------------------------------------------------------------------
User Function MTXMSG(cMsg,cSolucao)
    Local oButton1
    Local oButton2
    Local oFont1    := TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)
    Local oMultiGe1
    Local cMultiGe1 := cMsg
    Local oMultiGe2
    Local cMultiGe2 := cSolucao
    Local oSay1
    Local oSay2
    Local lRet      := .F.
    PRIVATE oDlg

    DEFINE MSDIALOG oDlg TITLE "Validacao Volumes" FROM  000, 000  TO 400, 500 COLORS 0, 16777215 PIXEL

    @ 020, 004 GET oMultiGe1 VAR cMultiGe1 OF oDlg MULTILINE SIZE 240, 093 COLORS 0, 16777215 READONLY HSCROLL  PIXEL
    @ 129, 004 GET oMultiGe2 VAR cMultiGe2 OF oDlg MULTILINE SIZE 240, 042 COLORS 0, 16777215 READONLY HSCROLL  PIXEL
    @ 009, 004 SAY oSay1 PROMPT "Problema..:" SIZE 040, 009 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
    @ 118, 004 SAY oSay2 PROMPT "Solução..:" SIZE 040, 009 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
    @ 176, 149 BUTTON oButton1 PROMPT "&Solicitar Autorizacao" SIZE 054, 012 OF oDlg ACTION (U_MTXSOLV(@lRet), oDlg:end()) PIXEL
    @ 176, 206 BUTTON oButton2 PROMPT "&Cancelar" SIZE 037, 012 OF oDlg  ACTION oDlg:end() PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

Return lRet


USER FUNCTION MTXSOLV(lRet)
    LOCAL cHtml
    Local aUser     := StrTokArr2(SuperGetMV("MV_ZAPRVOL",.F.,""),';')
    Local aAllusers := FWSFAllUsers(aUser,{"USR_EMAIL"})
    Local cTo       := ""
    Local n         := 0

    If Len(aAllusers) > 0
        For n := 1 to Len(aAllusers)
            cTo += Lower(Alltrim(aAllusers[n][3]))
            If n < Len(aAllusers)
                cTo += ";"
            EndIf
        Next n
    EndIF

    M->UA_ZSTATUS := "2"

    cFrom         := SUPERGETMV("MV_RELFROM",.F.,"")
    cCC           := ""
    cAttach       := ""
    cSubject      := "APROVACAO - Analise volumes Periodo - Orc.: "+ALLTRIM( M->UA_NUM)


    IF EMPTY(cTo)
        RETURN .T.
    ENDIF

    cHtml := '<!DOCTYPE html>'
    cHtml += '<html lang="pt-BR">'
    cHtml += '<body>'
    cHTML +=' <p>Olá,</p>                                                                                                                                                             '
    cHTML +=' <p >O orcamento <strong>'+ALLTRIM(M->UA_NUM)+'</strong> do cliente <strong>' + M->UA_CLIENTE + '/' + M->UA_LOJA + ' - ' + ALLTRIM(Posicione("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_NOME") )+'</strong>, esta disponivel para <strong>Analise dos Volumes por período.</strong>.  </p>    '
    cHTML +=' <p ></p>    '
    cHTML +=' <p ><u>Acessar a rotina de analise no Protheus e efetuar sua aprovar/Negar!. </u></p>'
    cHtml += '</br></br>	'
    cHtml += '<p>Gerado Automaticamente via Analise de Volumes </p>'
    cHtml += '</br></br>	'
    cHtml += '<p>'+ alltrim(FWCompanyName())  + ' -  ' +  cValToChar(YEAR(DATE())) +'</p>'
    cHtml += '</body>'
    cHtml += '</html>'

    MsAguarde({|| U_MTX13P01(cFrom, cTo, cCC, cSubject, cHtml, cAttach)},"Processando","Enviando Analise")

    lRet := .T.

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MTXWHENCP
When dos campos Call Center
@author  Thiago.Zoppi
date: "02/04/2020"
/*/
//-------------------------------------------------------------------
User Function MTXWHENCP()
    Local lRet       := .T.
    Local lEmpVidros := cFilAnt $ '0202'
    Local cCampo     := READVAR()
    Local nQtdcx     := GdFieldPos("UB_ZQTDCX",aHeader)

    IF lEmpVidros
        Do Case
        CASE cCampo  == "M->UB_QUANT"
            lRet    := .F.
        CASE cCampo  == "M->UB_Z2QUANT"
            IF aCols[n,nQtdcx]  > 0
                lRet    := .F.
            ENDIF

        End Case
    ELSE  // se nao for Vidros '0202' bloqueia o campo
        IF cCampo == "M->UB_ZQTDCX"
            lRet    := .F.
        ENDIF

    ENDIF



Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MTXVLDCP
Valid dos campos Call Center
@author  Thiago.Zoppi
date: "02/04/2020"
/*/
//-------------------------------------------------------------------
User Function MTXVLDCP()
    Local lRet       := .T.
    Local lEmpVidros := cFilAnt $ '0202'
    Local cCampo     := READVAR()
    Local nQtdcx := GdFieldPos("UB_ZQTDCX",aHeader)
    Local nPosB  := GdFieldPos("UB_ZBANDA",aHeader)
    Local nArma  := GdFieldPos("UB_LOCAL",aHeader)
    //Local nQt2un := GdFieldPos("UB_Z2QUANT",aHeader)
    Local nOpera := GdFieldPos("UB_OPER",aHeader)
    local n2Uni  :=  GdFieldPos("UB_Z2UM",aHeader)
    Local cLocalCX := SUPERGETMV("MV_ZLOCCX",.F.,"") // Local para caixas

    IF lEmpVidros
        Do Case
        CASE cCampo == 'M->UB_Z2QUANT'

            IF  M->UB_Z2QUANT != INT(M->UB_Z2QUANT) .AND. aCols[n,nOpera] == '01'

                IF (M->UB_Z2QUANT % 0.5) != 0 .AND. aCols[n,n2Uni]  == 'CH' // Regra criada a pedido do cliente para liberar 0.5 chapas.
                    Help(NIL, NIL, "MTXVLDCP", NIL, "Valor inválido", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Utilizar somente Valor multiplos de 0.5."})
                    lRet    := .F.
                Else
                    U_ISBANDA()
                    aCols[n,nQtdcx]  := 0
                ENDIF

            ELSE
                U_ISBANDA()
                aCols[n,nQtdcx]  := 0
            ENDIF

        CASE cCampo  == 'M->UB_ZQTDCX'
            aCols[n,nPosB] := "2" // Marca Produto como se nao for banda
            aCols[n,nArma] :=  cLocalCX // "10" // armazem pré-definido para Caixas.
        END CASE
    ELSE

        Do Case
        CASE cCampo == 'M->UB_Z2QUANT'

            IF  M->UB_Z2QUANT != INT(M->UB_Z2QUANT) .AND. aCols[n,nOpera] == '01'
                    Help(NIL, NIL, "MTXVLDCP", NIL, "Campo só permite valor Inteiro", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Utilizar somente Valor inteiro."})
                    lRet    := .F.
            ENDIF

        END CASE


    ENDIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MTXZQTDCX
FUNCAO PARA GATILHODO CAMPO UB_ZQTDCX
@author  author
date: "03/04/2020"
/*/
//-------------------------------------------------------------------
USER FUNCTION MTXZQTDCX()
    Local nProdut := GdFieldPos("UB_PRODUTO",aHeader)
    Local nQtdcx  := GdFieldPos("UB_ZQTDCX",aHeader)
    Local nLocal  := GdFieldPos("UB_LOCAL",aHeader)
    Local nCX     := 0


    IF aCols[n,nQtdcx] = 0
        aCols[n,nLocal] := SB1->B1_LOCPAD
    ELSE
        IF aCols[n,nProdut] == SB1->B1_COD
            nCX := SB1->B1_ZQTDCX
        ELSE
            AAREASB1 := SB1->(GETAREA())
            DbSelectArea("SB1")
            DbSetorder(1)
            DBSEEK( XFILIAL("SB1")+aCols[n,nProdut] )
            nCX := SB1->B1_ZQTDCX
            RESTAREA(AAREASB1)
        ENDIF

        IF nCX > 0
            nCX := nCX * aCols[n,nQtdcx]
        ENDIF
    ENDIF

RETURN nCX



//-------------------------------------------------------------------
/*/{Protheus.doc} WHENCALL
FUNCAO WHEN DE CAMPOS
@author  author
date: "03/06/2020"
/*/
//-------------------------------------------------------------------
USER FUNCTION WHENCALL(cCampo)

    Local cSegmento := ""
    Local lWhen     := .T.
    Default cCampo  := ""

    If cCampo == "UA_ZFRECOR"
        lWhen :=  !(M->UA_ZSTAUSN $ '2/3') .AND. M->UA_TPFRETE == 'C' .AND. M->UA_ZFRENF == '2'
    ElseIf cCampo == "UA_ZFRENF"
        lWhen := M->UA_TPFRETE == 'C' .AND. M->UA_ZFRECOR == 'N'
    ElseIf cCampo == "UA_ZDESDIS"
        cSegmento := Posicione("SA1", 1, XFilial("SA1") + M->(UA_CLIENTE + UA_LOJA), "A1_SATIV1")
        If !(lWhen := cFilAnt == "0301" .And. !Empty(cSegmento) .And. AllTrim(cSegmento) $ SuperGetMV("SL_SEGDESD", .F., ""))
            M->UA_ZDESDIS := 0
        EndIf
    ElseIf cCampo == "UA_ZNEGPRE"
        lWhen := (M->UA_OPER != "1" .Or. __cUserID $ SuperGetMV("SL_USRLNEG", .F., "")) .And. M->UA_ZNEGPRE == "1"

    //Teste alessandro cascaes bloqueio campo para edicao se nao for liberado pelo gerente
    ElseIf cCampo == "UB_DESC"
        lWhen := .F.
    ElseIf cCampo == "UB_ZDESCON"

        lWhen := Iif(Empty(M->UA_ZDTLIBS),.F.,.T.)

        lWhen := Iif(__CUSERID == "000000",.T.,lWhen)

    ElseIf cCampo == "UB_ACRE"

        lWhen := Iif(Empty(M->UA_ZDTLIBS),.F.,.T.)

        lWhen := Iif(__CUSERID == "000000",.T.,lWhen)

    ElseIf cCampo == "UB_VALDESC"
        lWhen := .F.

	ElseIf cCampo == "UA_ZREDESP"
		If M->UA_TPFRETE <> "E"
			lWhen := .F.
		EndIf
    ElseIf cCampo == "UA_ZTRANSP"
		If M->UA_TPFRETE == "E" .And. xFilial("SUA") == "0101"
			lWhen := .T.
		ElseIf M->UA_TPFRETE == "M"
			lWhen := .T.
		Else
			lWhen := .F.
		EndIf
	ElseIf cCampo == "UA_TPFRETE"
		M->UA_ZREDESP := Space(6)
		M->UA_ZTRANSP := Space(6)
    EndIf

RETURN lWhen

//-------------------------------------------------------------------
/*/{Protheus.doc} LogEtapa
Grava Log ETAPAS ZZG
@author  Thiago.Zoppi
date: "28/07/2020"
Parametros
@cEtapa
@cProc
@cPedido
/*/
//-------------------------------------------------------------------
User Function LogEtapa(cEtapa,cProc,cPedido)
    Local cFilGrv   := xFilial("ZZG")
    Local cMsg      := "Etapa - "
    Local cListaEt  := ""
    Local aEtapas   := {}
    Local nPos      := 0
    Local cAliasQry := GetNextAlias()

    Default cEtapa	:= NIL
    Default cProc	:= NIL
    DEFAULT cPedido := NIL

    BeginSql Alias cAliasQry
        %NoParser%
        SELECT ISNULL(MAX(R_E_C_N_O_ ),0) AS RECNO
            From %Table:ZZG% ZZG
        WHERE ZZG_FILIAL = %xFilial:ZZG%
            AND ZZG_PEDIDO = %EXP:cPedido%
            AND ZZG.%NotDel%
    ENDSQL

    IF (cAliasQry)->RECNO > 0
        DbSelectArea("ZZG")
        ZZG->(DbgoTo((cAliasQry)->RECNO))
        IF ZZG->ZZG_ETAPA == cEtapa .and. Alltrim(ZZG->ZZG_PROC) == Alltrim(cProc + " - " + Funname())
            Return
        ENDIF
    Endif
    (cAliasQry)->(DbCloseArea())

        IF Valtype(cEtapa) == "U" .OR. Valtype(cProc) == "U" .OR. Valtype(cPedido) == "U"
            Help( ,, 'Help',, "Log de etapada não gerado!", 1, 0 )
            Return
        Endif

        cListaEt := u_retetapa() // Busca as etapas
        aEtapas  := StrTokArr2( cListaEt , ";", .T.)

        nPos :=  Ascan(aEtapas,{ |x| x = ALLTRIM(cEtapa) + "=" })
        If nPos > 0
            cMsg += aEtapas[nPos]
        Else
            cMsg +=  cEtapa + ": nao cadastrada no fonte RetFase!"
        ENDIF

        DBSelectArea("ZZG")
        ZZG->(RECLOCK("ZZG",.T.))
            Replace ZZG->ZZG_FILIAL With cFilGrv
            Replace ZZG->ZZG_DATA   With MsDate()
            Replace ZZG->ZZG_HORA   With SubStr(Time(),1,TamSx3("ZZG_HORA")[1])
            Replace ZZG->ZZG_USER   With cUserName
            Replace ZZG->ZZG_MSG    With cMsg
            Replace ZZG->ZZG_PROC   With cProc + " - " + Funname()
            Replace ZZG->ZZG_ETAPA  With cEtapa
            Replace ZZG->ZZG_PEDIDO With cPedido
        ZZG->(MSUNLOCK())


Return

/*/{Protheus.doc} GetPDesc
Coleta o percentual de descondo de acordo com os dados informados.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 31/08/2020
@param nFaixa, numeric, faixa.
@param cTabPrc, character, tabela de preço.
@param cPerfil, character, grupo do cliente.
@param cProd, character, produto.
@param cCodACO, character, código da ACO.
@return array, array com as linhas.
/*/
User Function GetPDesc(nFaixa, cTabPrc, cPerfil, cProd, cCodACO,_cCond,_cFrete)

    Local aArray    := {}
    Local _aTmp     := {}
    Local cAlias    := GetNextAlias()
    Local cCod      := ""
    Local cDesc     := ""
    Local cFamil    := ""
    Local cGrupo    := ""
    Local cTpEsc    := ""
    Local cWhereACO := ""
    Local lDesc     := .F.
    Local aAreaSB1 := {}
    Local _lAltB1  := .F.
    Local _nDias   := 0
    Local _aArea    := GetArea()
    Local _aArSE4   := SE4->(GetArea())
    Local _aParc    := {}
    Local _cFaixa
    Local _ix , _lAchou
    

    Default cPerfil := CriaVar("ACO_GRPVEN", .F.)
    Default cCodACO := CriaVar("ACO_CODREG", .F.)
    Default _cCond := CriaVar("ACO_CONDPG", .F.)
    Default _cFrete := CriaVar("ACO_ZTPFRE", .F.)
    
    if cFilAnt=="0202"
        DbSelectArea("SE4")
        DbSetOrder(1)
        if DbSeek(xFilial("SE4")+_cCond) .and. SE4->E4_TIPO=='1'
            _aParc:= StrTokArr2( SE4->E4_COND, ",")
            _nDias:= Val(_aParc[Len(_aParc)])
        else
            _nDias:= -1
        endif 

        RestArea(_aArSE4)
        RestArea(_aArea)
    endif

    cWhereACO += "%"
    If !Empty(cCodACO)
        cWhereACO += "ACO_CODREG = " + ValToSQL(cCodACO)
    Else
        cWhereACO += "(ACO_GRPVEN = " + ValToSQL(cPerfil) + " OR ACO_GRPVEN = " + ValToSQL(CriaVar("ACO_GRPVEN", .F.)) + ")"
    EndIf
    if cFilAnt=="0202"
        cWhereACO += " AND ACO_ZTPFRE= " + ValToSQL(_cFrete) +" "
        //cWhereACO += " AND (ACP_ZDIASP>= " + cValToChar(_nDias) +" OR ACP_ZDIASP=0) "
    endif
    cWhereACO += "%"

    if xFilial("SB1")+ cProd<>SB1->(B1_FILIAL+B1_COD)
        _lAltB1  := .T.
        aAreaSB1 := SB1->(GETAREA())
        DbSelectArea("SB1")
        DbSetOrder(1)
        DbSeek(xFilial("SB1")+ cProd)
    endif

    cGrupo := SB1->B1_GRUPO

    if xFilial("SBM")+ cGrupo<>SBM->(BM_FILIAL+BM_GRUPO)
        DbSelectArea("SBM")
        DbSetOrder(1)
        DbSeek(xFilial("SBM")+ cGrupo)
    endif

    cFamil := SBM->BM_TIPGRU//Posicione("SBM", 1, XFilial("SBM") + cGrupo, "BM_TIPGRU")

    DBSelectArea("DA1")
    DA1->(DBSetOrder(1))
    If DA1->(MsSeek(XFilial("DA1") + PadR(cTabPrc, TamSX3("DA1_CODTAB")[1]) + cProd))
        // Não irá aplicar o desconto se o escalonado estiver igual a não, com o perfil de cliente em branco ou sendo o informado.
        lDesc := !(DA1->DA1_ZESCAL == "N" .And. (Empty(DA1->DA1_ZGRPCL) .Or. AllTrim(cPerfil) $ DA1->DA1_ZGRPCL))
        cTpEsc := "P"//IIF(cFilAnt=="0301","P",DA1->DA1_ZTPESC)

        // Regra padrão caso não seja informado o campo.
        /*COMENTADO POIS AGORA É ESCALONADO POR VALOR EM TODOS OS SEGMENTOS
        If Empty(cTpEsc)
            cTpEsc := IIf(cFilAnt == "0202", "P", "G")
        EndIf*/

        // Escalona por item.
        If cTpEsc == "I"
            cCod := cProd
            cDesc := SB1->B1_DESC//Posicione("SB1", 1, XFilial("SB1") + cProd, "B1_DESC")
        // Escalona por grupo.
        ElseIf cTpEsc == "G"
            cCod := cGrupo
            cDesc := SBM->BM_DESC//Posicione("SBM", 1, XFilial("SBM") + cGrupo, "BM_DESC")
        // Escalona por família.
        ElseIf cTpEsc == "F"
            cCod := cFamil
            cDesc := Posicione("SX5", 1, XFILIAL("SX5") + "V0" + cFamil, "X5_DESCRI")
        // Escalona por pedido.
        Else
            cDesc := "PEDIDO"
        EndIf
    EndIf

    _cFaixa:= ""
    If cFilAnt=="0202"
        _cFaixa := "% 1=1 %" //0202
    else
        _cFaixa := "% ACP_FAIXA >= "+cValToCHar(nFaixa)+" %"
    endif

    If lDesc
        BeginSQL Alias cAlias
            SELECT
                ACP_CODREG,
                ACP_FAIXA,
                ACP_PERDES, 
                ACP_ZDIASP,
                ACP.R_E_C_N_O_ REC
            FROM
                %Table:ACO% ACO
            INNER JOIN
                %Table:ACP% ACP
                ON	ACP_FILIAL = ACO_FILIAL
                AND ACP_CODREG = ACO_CODREG
                AND (ACP_CODPRO = %Exp:cProd% OR ACP_CODPRO = %Exp:CriaVar("ACP_CODPRO", .F.)%)
                AND (ACP_GRUPO = %Exp:cGrupo% OR ACP_GRUPO = %Exp:CriaVar("ACP_GRUPO", .F.)%)
                AND (ACP_ZTPPRD = %Exp:cFamil% OR ACP_ZTPPRD = %Exp:CriaVar("ACP_ZTPPRD", .F.)%)
                AND %Exp:_cFaixa%
                AND ACP.%NotDel%
            WHERE
                    ACO_FILIAL = %XFilial:ACO%
                AND ACO_CODTAB = %Exp:cTabPrc%
                AND %Exp:cWhereACO%
                AND ACO.%NotDel%
            ORDER BY ACO_GRPVEN DESC,ACP_CODPRO DESC,ACP_GRUPO DESC,ACP_ZTPPRD DESC, ACP_FAIXA

        EndSQL

        While !(cAlias)->(EOF()) .and. (!cFilAnt=="0202" .or. (cFilAnt=="0202" .and. _nDias>=0))
            // Aborta quando mudar a tabela de desconto.
            If !Empty(aArray) .And. ATail(aArray)["Regra"] != (cAlias)->ACP_CODREG
                Exit
            EndIf
            

            AAdd(aArray, JSONObject():New())
            ATail(aArray)["Regra"] := (cAlias)->ACP_CODREG
            ATail(aArray)["Faixa"] := (cAlias)->ACP_FAIXA
            ATail(aArray)["Desconto"] := (cAlias)->ACP_PERDES
            ATail(aArray)["Tipo"] := cTpEsc
            ATail(aArray)["Codigo"] := cCod
            ATail(aArray)["Descricao"] := cDesc
            ATail(aArray)["Dias"] := (cAlias)->ACP_ZDIASP
            ATail(aArray)["Rec"] := (cAlias)->REC


            (cAlias)->(DBSkip())
        End
        (cAlias)->(DBCloseArea())
    EndIf
    
    if cFilAnt=="0202"
        _lAchou := .F.
        For _ix:= 1 to Len(aArray)
            //_nPos:= Len(aArray)+1-_ix
            if (aArray[_ix]["Faixa"]>=nFaixa)
                if aArray[_ix]["Dias"]>=_nDias
                    _aTmp:= aArray[_ix]
                    _lAchou:= .T.
                endif
               Exit
            endif
        Next _ix
        
        if !_lAchou
            For _ix:= 1 to Len(aArray)
                _nPos:= Len(aArray)+1-_ix
                if (aArray[_nPos]["Faixa"]<=nFaixa .and. aArray[_nPos]["Dias"]>=_nDias)
                    _aTmp:= aArray[_nPos]
                    _lAchou:= .T.
                    Exit
                endif
            Next _ix
        endif

        aArray:= {}
        if _lAchou
            AADD(aArray,_aTmp)
        endif

    endif

    // Informa valor default se não encontrar dados.
    If Empty(aArray)
        AAdd(aArray, JSONObject():New())
        ATail(aArray)["Regra"] := ""
        ATail(aArray)["Faixa"] := 0
        ATail(aArray)["Desconto"] := 0
        ATail(aArray)["Tipo"] := ""
        ATail(aArray)["Codigo"] := ""
        ATail(aArray)["Descricao"] := ""
    EndIf

Return aArray

Static cRetF3 := ""

/*/{Protheus.doc} F3GrpCli
Consulta customizada para multi seleção de grupo de clientes no item da tabela de preço.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 31/08/2020
/*/
User Function F3GrpCli()

    Local aOpc      := {}
    Local aValue    := Nil
    Local cOpc      := ""
    Local cTitulo   := "Grupos de Cliente"
    Local lOk       := .T.
    Local nSize     := TamSX3("ACY_GRPVEN")[1]

    cCadastro := cTitulo

    DBSelectArea("ACY")
	ACY->(DBSetOrder(1))
	// Coleta as opções.
    If ACY->(DBSeek(XFilial("ACY")))
        While !ACY->(EOF()) .And. ACY->ACY_FILIAL == XFilial("ACY")
            AAdd(aOpc, AllTrim(ACY->ACY_GRPVEN) + " - " + AllTrim(ACY->ACY_DESCRI))
            cOpc += AllTrim(ACY->ACY_GRPVEN)

            ACY->(DBSkip())
        End
    EndIf

    If (lOk := f_Opcoes(@aValue, cTitulo, aOpc, cOpc, , , , nSize, , , , , , , .T.))
        cRetF3 := ""
        AEVal(aValue, {|x| cRetF3 += IIf(!Empty(cRetF3), "|", "") + Left(x, nSize)})
    EndIf

Return lOk

/*/{Protheus.doc} F3Transp
Consulta customizada para multi seleção de transportadoras.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 26/10/2020
/*/
User Function F3Transp()

    Local aOpc      := {}
    Local aValue    := Nil
    Local cOpc      := ""
    Local cTitulo   := "Transportadoras"
    Local lOk       := .T.
    Local nSize     := TamSX3("A4_COD")[1]

    cCadastro := cTitulo

    DBSelectArea("SA4")
	SA4->(DBSetOrder(1))
	// Coleta as opções.
    If SA4->(DBSeek(XFilial("SA4")))
        While !SA4->(EOF()) .And. SA4->A4_FILIAL == XFilial("SA4")
            AAdd(aOpc, AllTrim(SA4->A4_COD) + " - " + AllTrim(SA4->A4_NOME))
            cOpc += AllTrim(SA4->A4_COD)

            SA4->(DBSkip())
        End
    EndIf

    If (lOk := f_Opcoes(@aValue, cTitulo, aOpc, cOpc, , , , nSize, , , , , , , .T.))
        cRetF3 := ""
        AEVal(aValue, {|x| cRetF3 += IIf(!Empty(cRetF3), "|", "") + Left(x, nSize)})
    EndIf

Return lOk

/*/{Protheus.doc} RetF3Grp
Retorna conteúdo da consulta customizada.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 31/08/2020
@return characters, conteúdo selecionado.
/*/
User Function RetF3Grp()

Return AllTrim(cRetF3)

/*/{Protheus.doc} QtdItEsc
Função para retornar a quantidade de escalonamento de acordo com a regra.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 04/09/2020
@param aLines, array, itens.
@param cProd, character, produto.
@param nPosProd, numeric, posição do produto.
@param nPosQtde, numeric, posição da quantidade.
@param cTab, character, tabela de preço.
@param cGrpCli, character, perfil de cliente.
@return numeric, quantidade para escalonamento.
/*/
User Function QtdItEsc(aLines, cProd, nPosProd, nPosQtde, cTab, cGrpCli,nValTab)

    Local aItOrc    := {}
    Local cFamil    := ""
    Local cFamPos   := ""
    Local cGrpPos   := ""
    Local cGrupo    := ""
    Local cTpEsc    := "P" //Agora a regra é pelo valor total do pedido para todos os segmentos//IIF(cFIlAnt$"0301","P",U_GetDA1(cProd, cTab, cGrpCli, "DA1_ZTPESC"))
    Local nCount    := 0
    Local nPos      := 0
    Local nQtdEsc   := 0
    Local _cCampo   := ""

    cGrpPos := Posicione("SB1", 1, XFilial("SB1") + cProd, "B1_GRUPO")
    cFamPos := Posicione("SBM", 1, XFilial("SBM") + cGrpPos, "BM_TIPGRU")

    For nCount := 1 To Len(aLines)
        If !ATail(aLines[nCount])
            cGrupo := Posicione("SB1", 1, XFilial("SB1") + aLines[nCount][nPosProd], "B1_GRUPO")
            cFamil := Posicione("SBM", 1, XFilial("SBM") + cGrupo, "BM_TIPGRU")

            If (nPos := AScan(aItOrc, {|x| Alltrim(x["Produto"]) == Alltrim(aLines[nCount][nPosProd])})) == 0
                AAdd(aItOrc, JSONObject():New())
                nPos := Len(aItOrc)

                aItOrc[nPos]["Produto"] := aLines[nCount][nPosProd]
                aItOrc[nPos]["Grupo"] := cGrupo
                aItOrc[nPos]["Familia"] := cFamil
                aItOrc[nPos]["Qtde"] := 0
                aItOrc[nPos]["Valor"]:= 0
            EndIf

            aItOrc[nPos]["Qtde"] += aLines[nCount][nPosQtde]
            // Alterado para calcular o valor total do item em tempo de execução conforme dados inseridos e não pelo campo já calculado,
			// desta maneira ele está pegando o valor integral de tabela de preço, e não mais considerando o valor já com desconto de outra faixa escalonada
			aItOrc[nPos]["Valor"] += ROUND((aLines[nCount][nValTab] * aLines[nCount][nPosQtde]),2)
        EndIf
    Next nCount

    nPos := 0

    // Regra padrão caso não seja informado o campo.
    /* - COMENTADO POIS AGORA É ESCALONADO POR VALOR EM TODOS OS SEGMENTOS
    If Empty(cTpEsc)
        cTpEsc := IIf(cFilAnt $ "0202", "P", "G")
    EndIf
    */

    _cCampo:= RetCampo(cTpEsc,cProd,cGrpCli,cGrpPos,cFamPos) //RetCampo(cTpEsc, cProd, _cGrpVen)

    // Escalona por item.
    If cTpEsc == "I"
        While (nPos := AScan(aItOrc, {|x| Alltrim(x["Produto"]) == Alltrim(cProd)}, nPos + 1)) > 0
            nQtdEsc += aItOrc[nPos][_cCampo]//nQtdEsc += aItOrc[nPos]["Qtde"]
        End
    // Escalona por grupo.
    ElseIf cTpEsc == "G"
        While (nPos := AScan(aItOrc, {|x| x["Grupo"] == cGrpPos}, nPos + 1)) > 0
            nQtdEsc += aItOrc[nPos][_cCampo]//nQtdEsc += aItOrc[nPos]["Qtde"]
        End
    // Escalona por família.
    ElseIf cTpEsc == "F"
        While (nPos := AScan(aItOrc, {|x| x["Familia"] == cFamPos}, nPos + 1)) > 0
            nQtdEsc += aItOrc[nPos][_cCampo]//nQtdEsc += aItOrc[nPos]["Qtde"]
        End
    // Escalona por pedido.
    Else
        AEVal(aItOrc, {|x| nQtdEsc += x[_cCampo]})//AEVal(aItOrc, {|x| nQtdEsc += x["Qtde"]})
    EndIf

Return nQtdEsc

/*/{Protheus.doc} GetDA1
Função para coletar o campo informado da tabela DA1.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 17/09/2020
@param cProd, character, produto.
@param cTab, character, tabela de preço.
@param cGrpCli, character, grupo de cliente.
@param cField, character, campo para retorno.
@return undefined, conteúdo do campo solicitado.
/*/
User Function GetDA1(cProd, cTab, cGrpCli, cField)

    Local cAlias    := GetNextAlias()
    Local cFieldQry := "%" + cField + "%"
    Local cWhereDA1	:= "%AND (DA1_ZGRPCL LIKE '%" + cGrpCli+ "%' OR DA1_ZGRPCL = " + ValToSQL(CriaVar("DA1_ZGRPCL", .F.)) + ")%"
    Local uContent  := Nil

    BeginSQL Alias cAlias
        SELECT
            %Exp:cFieldQry%
        FROM
            %Table:DA1% DA1
        WHERE
                DA1_FILIAL = %XFilial:DA1%
            AND DA1_CODTAB = %Exp:cTab%
            AND DA1_CODPRO = %Exp:cProd%
            AND DA1.%NotDel%
            %Exp:cWhereDA1%
        ORDER BY
            DA1_ZGRPCL DESC
    EndSQL

    If !(cAlias)->(EOF())
        uContent := (cAlias)->&(cField)
    EndIf

    (cAlias)->(DBCloseArea())

Return uContent

/*/{Protheus.doc} VldAltFd
Função para validar a alteração de campos no Call Center.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 19/09/2020
@return logical, se pode atualizar.
/*/
User Function VldAltFd()

    Local aDefault      := {}
    Local cField        := AllTrim(StrTran(ReadVar(), "M->", ""))
    Local cIniITCOMP    := ""
    Local cITCOMP       := ""
    Local cItem         := GDFieldGet("UB_ITEM")
    Local cProd         := GDFieldGet("UB_PRODUTO")
    Local lOk           := .T.
    Local nBkpLine      := n
    Local nFator        := 0
    Local nPos          := 0
    Local nPosItP       := GDFieldPos("UB_ZITPAI")
    Local nPosCod       := GDFieldPos("UB_PRODUTO")
    Local nPosQtd       := GDFieldPos("UB_QUANT")
    Local nQuant        := 0
    Local nSaldo:= nSldT := 0
    Local nQtdTrf:=nTmpTrf := 0
    Local _cTesTmp:= _cCfoTmp:= ""
    Local _ix :=_nSldTmp:= 0

    oGetTlv:Refresh()
    _cTesTmp:= MaTesInt(2,GDFieldGet("UB_OPER"),M->UA_CLIENTE,M->UA_LOJA,"C",GDFieldGet("UB_PRODUTO"),"UB_TES",M->UA_TIPOCLI)
    _cCfoTmp:= TK273CFO(M->UA_CLIENTE,M->UA_LOJA,_cTesTmp)
    //GDFieldPut("UB_TES", _cTesTmp, n) //COMENTADO PARA TRATAMENTO DO PROBLEMA DE TES/email  - 05/04/22 RENATOSEVER
    //GDFieldPut("UB_CF", _cCfoTmp, n)//COMENTADO PARA TRATAMENTO DO PROBLEMA DE CFOP/email  - 05/04/22 RENATOSEVER
    oGetTlv:Refresh()
     _cTesTmp:=""
     _cCfoTmp:=""

    cITCOMP := SuperGetMV("SL_ITCOMP", .F.)
    cIniITCOMP := PrefixoCpo(cITCOMP) + "_"

    AEval(aHeader, {|x| AAdd(aDefault, IIf(x[10] != "V", CriaVar(x[2], .F.), Nil))})
    AAdd(aDefault, .F.)

    DBSelectArea(cITCOMP)
    (cITCOMP)->(DBSetOrder(1))

    Begin Sequence
        // Não permite alterar item composto sendo componente.
        //If !Empty(GDFieldGet("UB_ZITPAI"))
        //    ShowHelpDlg("ItComp", {"Item não pode ser alterado pois trata-se de um componente de item composto."}, 1, {"Realize as alterações no item principal: " + GDFieldGet("UB_ZITPAI")}, 1)
        //    Break
        //EndIf

        If !Empty(cField)
            If cField == "UB_PRODUTO"
                // Não permite alterar o produto quando for item pai.
                If AScan(aCols, {|x| x[nPosItP] == GDFieldGet("UB_ITEM") .And. !ATail(x)}) > 0
                    ShowHelpDlg("ItComp", {"O código do produto não pode ser alterado pois trata-se de um item composto."}, 1, {}, 0)
                    Break
                ElseIf !Empty(&(cField)) .And. (cITCOMP)->(DBSeek(XFilial(cITCOMP) + cProd))
                    While !(cITCOMP)->(EOF()) .And. (cITCOMP)->&(cIniITCOMP + "FILIAL") + (cITCOMP)->&(cIniITCOMP + "COD") == XFilial(cITCOMP) + cProd
                        n++
                        If oGetTlv:AddLine(.T., .F.)
                            GDFieldPut("UB_PRODUTO", (cITCOMP)->&(cIniITCOMP + "COMP"), n)
                            GDFieldPut("UB_ZITPAI", cItem, n)
                            /* oGetTlv:SetArray(aCols) */
                            oGetTlv:GoTo(n)

                            M->UB_PRODUTO := (cITCOMP)->&(cIniITCOMP + "COMP")
                            Tk273Calcula("UB_PRODUTO", n)
                        EndIf

                        (cITCOMP)->(DBSkip())
                    End

                    // Restaura conteúdo do campo de memória e atualiza o grid.
                    n:= nBkpLine
                    M->UB_PRODUTO := &(cField)
                    oGetTlv:GoTo(nBkpLine)
                    oGetTlv:Refresh()
                EndIf
            Else

                If cField $ "UB_QUANT|UB_Z2QUANT|UB_ZQTDCX"
                    nQuant := &(cField)
                    nQtdTrf:=0
                    nSaldo := U_GetSldB2(cProd,GDFieldGet("UB_ZBANDA"), , ,@nQtdTrf)

                    // Quando for item composto, coleta a quantidade mínima de todos os componentes.
                    While (nPos := AScan(aCols, {|x| x[nPosItP] == GDFieldGet("UB_ITEM") .And. !ATail(x)}, nPos + 1)) > 0
                        nSldT:= U_GetSldB2(aCols[nPos][nPosCod],aCols[nPos][GDFieldPos("UB_ZBANDA")],,,@nTmpTrf)
                        if nSaldo> nSldT
                            nSaldo := nSldT
                            nQtdTrf:= nTmpTrf
                        endif
                    Enddo

                    //Verifico se existem outros itens iguais no pedido.
                    _nSldTmp:=0
                    for _ix:=1 to len(aCols)
                        if _ix!= nBkpLine .and. Empty(aCols[_ix,nPosItP]) .and. cProd==aCols[_ix,nPosCod] .and. !aCols[_ix,Len(aheader)+1]
                            _nSldTmp+= aCols[_ix,nPosQtd]
                        endif
                    next _ix
                    // Converte para a primeira UM para validar o saldo.
                    If cField == "UB_Z2QUANT
                        nQuant := ConvUm(cProd, 0, nQuant, 1)
                    ElseIf cField == "UB_ZQTDCX"
                        nQuant := Posicione("SB1", 1, XFilial("SB1") + cProd, "B1_ZQTDCX") * nQuant
                        nQuant := ConvUm(cProd, 0, nQuant, 1)
                    EndIf

                    If nQuant > (nSaldo-_nSldTmp)
                        if nQtdTrf==0
                            ShowHelpDlg("NoSld", {"Quantidade informada menor que o saldo disponível.", "Saldo: " + cValToChar(nSaldo-_nSldTmp)}, 2, {}, 0)
                        else
                            ShowHelpDlg("NoSld", {"Quantidade informada menor que o saldo disponível.", "Saldo: " + cValToChar(nSaldo-_nSldTmp)+ ". Qtd aguardando transferencia: "+ cValToChar(nQtdTrf)}, 2, {}, 0)
                        endif
                        Break
                    EndIf
                EndIf

                // Quando for item composto, atualiza os componentes.
                While (nPos := AScan(aCols, {|x| x[nPosItP] == GDFieldGet("UB_ITEM") .And. !ATail(x)}, nPos + 1)) > 0
                    nFator := Posicione(cITCOMP, 1, XFilial(cITCOMP) + GDFieldGet("UB_PRODUTO") + aCols[nPos][nPosCod], cIniITCOMP + "QUANT")
                    If cField == "UB_QUANT"
                        aCols[nPos][GDFieldPos("UB_Z2QUANT")] := ConvUm(aCols[nPos][nPosCod], nQuant, 0, 2) * nFator
                        If U_MTXVLDCP()
                            aCols[nPos][GDFieldPos("UB_ZQTDCX")] := aCols[nPos][GDFieldPos("UB_Z2QUANT")] / Max(Posicione("SB1", 1, XFilial("SB1") + aCols[nPos][nPosCod], "B1_ZQTDCX"), 1) * nFator
                        EndIf
                        aCols[nPos][GDFieldPos(cField)] := &(cField) * nFator
                    ElseIf cField == "UB_Z2QUANT"
                        aCols[nPos][nPosQtd] := nQuant * nFator
                        If U_MTXVLDCP()
                            aCols[nPos][GDFieldPos("UB_ZQTDCX")] := aCols[nPos][GDFieldPos("UB_Z2QUANT")] / Max(Posicione("SB1", 1, XFilial("SB1") + aCols[nPos][nPosCod], "B1_ZQTDCX"), 1) * nFator
                        EndIf
                        aCols[nPos][GDFieldPos(cField)] := &(cField) * nFator
                    ElseIf cField == "UB_ZQTDCX"
                        aCols[nPos][nPosQtd] := nQuant * nFator
                        aCols[nPos][GDFieldPos("UB_Z2QUANT")] := ConvUm(aCols[nPos][nPosCod], nQuant, 0, 2) * nFator
                        aCols[nPos][GDFieldPos(cField)] := &(cField) * nFator
                    /*ElseIf cField== "UB_OPER"
                        oGetTlv:Refresh()
                        oGetTlv:GoTo(nPos)
                        GDFieldPut(cField, &(cField), nPos)
                        _cTesTmp:= MaTesInt(2,&(cField),M->UA_CLIENTE,M->UA_LOJA,"C",GDFieldGet("UB_PRODUTO"),"UB_TES",M->UA_TIPOCLI)
                        _cCfoTmp:= TK273CFO(M->UA_CLIENTE,M->UA_LOJA,_cTesTmp)
                        GDFieldPut("UB_TES", _cTesTmp, nPos)
                        GDFieldPut("UB_CF", _cCfoTmp, nPos)
                        oGetTlv:Refresh()
                        oGetTlv:GoTo(nBkpLine)
                        oGetTlv:Refresh()*/ //COMENTADO PARA TRATAMENTO DO PROBLEMA DE TES/email 05/04/22 RENATOSEVER
                    ElseIf cField== "UB_ZDESCON"
                        // NAO FAZER NADA - conforme solicitacao via email 30.03.2021
                    Else
                        aCols[nPos][GDFieldPos(cField)] := &(cField)
                    EndIf
                EndDo
                if n<>nBkpLine
                    n:= nBkpLine
                    oGetTlv:GoTo(nBkpLine)
                    oGetTlv:Refresh()
                endif
            EndIf
        EndIf
    Recover
        lOk := .F.
    End Sequence

Return lOk

/*/{Protheus.doc} GetSldB2
Função para coletar o estoque do produto.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 17/09/2020
@param cProd, character, produto.
@return numeric, estoque.
/*/
User Function GetSldB2(cProd,cBanda,_cLocal,_nSldD, _nSldT)

	Local cAlias    := GetNextAlias()
    Local cWhereB2	:= "%%"
    Local cArmEst   := ""
    Local nSldEst   := 0
    Local _aLocs    := {}
    Local _ix       := 0

    Default _cLocal:= ""
    Default cBanda:= ""
    Default _nSldD:= 0
    Default _nSldT:= 0

    _nSldD:=0
    _nSldT:=0

    if Empty(_cLocal)
        cArmEst:= SuperGetMv("SL_LC15298", .F., "")
        if cFilAnt=="0202" .and. cBanda=="1" //Tratamento para saldo tambem do aramzem com banda, somente para Emp+Filial 0202
            cArmEst+="|"+SUPERGETMV("MV_ZLOCBAN",.F.,"")
        endif
    else
        cArmEst := _cLocal
    endif

	// Filtra estoque apenas em armazéns específicos quando informados no parâmetro.
	If !Empty(cArmEst)
		cWhereB2 := "%AND B2_LOCAL IN " + FormatIn(cArmEst, "|") + "%"
	EndIf

    if cFilAnt $ SuperGetMV("SL_AR15298", .F., "")
        BeginSQL Alias cAlias
            SELECT SUM(B2_QATU-B2_RESERVA-B2_QEMP) SLDDISP, SUM(QTDSA) SLDTRF from (
            SELECT B2_LOCAL, B2_QATU,B2_RESERVA,B2_QEMP, COALESCE(SUM(C6_QTDVEN-C6_QTDENT),0) QTDSA
            FROM
                %Table:SB2% SB2
                LEFT JOIN %Table:SC5% SC5 ON (C5_FILIAL=B2_FILIAL AND C5_ZETAPA='07' AND SC5.%NotDel%)
                LEFT JOIN %Table:SC6% SC6 ON (C6_FILIAL=B2_FILIAL AND C6_NUM=C5_NUM AND C6_PRODUTO=B2_COD AND C6_LOCAL=B2_LOCAL
                    AND C6_BLQ<>'R' AND C6_QTDVEN-C6_QTDENT>0 AND SC6.%NotDel%)
            WHERE
                B2_FILIAL = %XFilial:SB2%
                AND B2_COD = %Exp:cProd%
                AND SB2.%NotDel%
                %Exp:cWhereB2%
            GROUP BY B2_LOCAL, B2_QATU,B2_RESERVA,B2_QEMP
            ) TMP
        EndSQL

        If !(cAlias)->(EOF())
            _nSldD := (cAlias)->SLDDISP
            _nSldT := (cAlias)->SLDTRF
        EndIf

        (cAlias)->(DBCloseArea())
    else
        _aLocs:= StrTokArr2(cArmEst, "|")
        if Len(_aLocs)
            for _ix:=1 to len(_aLocs)
                SB2->(DBSetOrder(1))
                if SB2->(MsSeek(xFilial("SB2") + cProd + _aLocs[_ix]))  //B2_FILIAL+B2_COD+B2_LOCAL
                    _nSldD+=SaldoSb2()
                endif
            next _ix
        else
            dbSelectArea("SB2")
            DbSetOrder(1)
            SB2->(MsSeek(xFilial("SB2") + cProd))
            While !SB2->(Eof()) .and. Alltrim(SB2->(B2_FILIAL+B2_COD))==Alltrim(xFilial("SB2")+cProd)
                _nSldD+=SaldoSb2()
                dbSelectArea("SB2")
                DbSkip()
            enddo

        endif
        /*BeginSQL Alias cAlias
            SELECT
                SUM(B2_QATU - B2_RESERVA - B2_QEMP - B2_QEMPSA) AS B2_QATU
            FROM
                %Table:SB2% SB2
            WHERE
                    B2_FILIAL = %XFilial:SB2%
                AND B2_COD = %Exp:cProd%
                AND SB2.%NotDel%
                %Exp:cWhereB2%
        EndSQL*/
    endif

    nSldEst := _nSldD-_nSldT



Return nSldEst

/*/{Protheus.doc} GetSldTr
Função para coletar o estoque do produto.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 17/09/2020
@param cProd, character, produto.
@return numeric, estoque.
/*/
User Function GetSldTr(cProd,_cLocal)

	Local cAlias    := GetNextAlias()
    Local cWhereB2	:= "%%"
    Local cArmEst   := ""
    Local nSldEst   := 0
    Local _ix       := 0

    Default _cLocal:= ""
    if Empty(_cLocal)
        cArmEst:= SuperGetMv("SL_LC15298", .F., "")
    else
        cArmEst := _cLocal
    endif

	// Filtra estoque apenas em armazéns específicos quando informados no parâmetro.
	If !Empty(cArmEst)
		cWhereB2 := "%AND B2_LOCAL IN " + FormatIn(cArmEst, "|") + "%"
	EndIf

    if cFilAnt $ SuperGetMV("SL_AR15298", .F., "")
        BeginSQL Alias cAlias
            SELECT   COALESCE(SUM(C6_QTDVEN-C6_QTDENT),0) QTDSA
            FROM
                %Table:SC5% SC5
                inner join  %Table:SC6% SC6 on (C6_FILIAL=C5_FILIAL AND C6_NUM=C5_NUM AND C6_BLQ<>'R' AND C6_QTDVEN-C6_QTDENT>0 AND SC6.%NotDel%)
            WHERE
                C5_FILIAL=%XFilial:SB2% and C5_ZETAPA='07'
                AND C6_PRODUTO =  %Exp:cProd%
                AND SC5.%NotDel%
                %Exp:cWhereB2%
        EndSQL

        If !(cAlias)->(EOF())
            nSldEst := (cAlias)->QTDSA
        EndIf

        (cAlias)->(DBCloseArea())
    else
        _aLocs:= StrTokArr2(cArmEst, "|")
        for _ix:=1 to len(_aLocs)
            SB2->(DBSetOrder(1))
			if SB2->(MsSeek(xFilial("SB2") + cProd + _aLocs[_ix]))  //B2_FILIAL+B2_COD+B2_LOCAL
                nSldEst+=SB2->B2_QEMPSA
            endif
        next _ix
    endif


Return nSldEst

/*/{Protheus.doc} UpStepPV
Função responsável por atualizar a etapa do pedido.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 25/09/2020
@param cOrigem, character, origem.
/*/
User Function UpStepPV(cOrigem)

    Local aPvlNfs       := {}
    Local aBloqueio     := {}
    Local aLocsPad	    := StrTokArr(SuperGetMv("SL_LC15298",.F.,""), "|")
    Local cStep         := CriaVar("C5_ZETAPA", .F.)
    Local cAVista       := SuperGetMV("MV_AVISTA", .F., "")
	Local cAdiant       := SuperGetMV("MV_ZADIANT", .F., "")
    //Local cAdi100       := SuperGetMV("MV_ZADI100", .F., "")
    Local cStatCO       := "02/03/05"
    Local cEtaCo        := ""
    Local lPedCo        := .F.
    Local nPos          := 0
    Local nSldArm       := 0
    Local nSldTot       := 0
    Private cIDBLPV     := SuperGetMV("SL_IDBLPV", .F.)
	Private cIniIDBLPV  := PrefixoCpo(cIDBLPV) + "_"
    Private LiberOk     := .T.
    Private Inclui      := .F.
    Private lSugere     := .T.
    Private lLiber      := .F.
    Private lTransf     := .F.

    Begin Sequence
        //Em caso de pedido de entrega de Conta e Ordem, verifica a etapa do pedido de cobrança
        lPedCo:= PedCo(SC5->C5_NUM,@cEtaCo)
        if lPedCo .and. cEtaCo $ cStatCO
            cStep := cEtaCo
            Break
        endif


        // Entrega futura
        If cOrigem == "ENTREGAFUTURA"
            cStep := "08"
            Break
        EndIf

        // Exclusão de nota fiscal.
        If IsInCallStack("MATA520") .or. IsInCallStack("MATA521") .or. cOrigem == "MS520DEL"
            cStep := "99"
            Break
        EndIf


        // Eliminado resíduo.
        If SC5->C5_NOTA == Replicate("X", TamSX3("F2_DOC")[1]) .or. Alltrim(SC5->C5_NOTA) == Replicate("X", 6) .or. cOrigem == "MT500APO"
            cStep := "97"
            Break
        EndIf

        // Rejeição de crédito.
        If SC5->C5_ZREJPED == "1" //!Empty(SC5->C5_ZHISTF)
            cStep := "98"
            Break
        EndIf

        // Faturamento.
        If cOrigem == "ManConfe"  .And. IsInCallStack("GrvConf")
            cStep := "10"
            Break
        EndIf

        // Conferência.
        If cOrigem == "ManSepar" .And. IsInCallStack("FinSep")
            cStep := "16"
            Break
        EndIf

        // Separação.
        If IsInCallStack("U_MTX05R03")
            cStep := "15"
            Break
        EndIf

        // Finalização
        If cOrigem == "FIMMOV11"
            cStep := "12"
            Break
        EndIf

        // Expedição.
        If !Empty(SC5->C5_NOTA)
            cStep := "11"
            Break
        EndIf

        // Rentabilidade/Regras.
        If SC5->C5_BLQ == "1"
            cStep := "22"
            Break
        EndIf

        // Movimentação de estoque.
        If SC5->C5_ZETAPA $ "06/07/22" .And. !(cOrigem $ "MAAVCRPR/M440SC9I")
            Ma410LbNfs(2, @aPvlNfs, @aBloqueio)
        EndIf

        If !(cOrigem == "MAAVCRPR")
	        Ma410LbNfs(1, @aPvlNfs, @aBloqueio)
        EndIf

        // Quando há bloqueio de estoque, verifica se há saldo em outros armazens para movimentação.
        If AScan(aBloqueio, {|x| x[7] != "10" .and. !Empty(x[7])}) > 0 .and. AScan(aBloqueio, {|x| x[6] != "10" .and. !Empty(x[6])}) == 0
            // Valida se fará analise de estoque - 15298
			If Len(aLocsPad) > 0 .And. cFilAnt $ SuperGetMV("SL_AR15298", .F., "")
                While (nPos := AScan(aBloqueio, {|x| x[7] != "10" .and. !Empty(x[7])}, nPos + 1)) > 0
                    cArmSC6 := Posicione("SC6",1,xFilial("SC6")+aBloqueio[nPos][1]+aBloqueio[nPos][2]+aBloqueio[nPos][4],"C6_LOCAL")
                    IIF(AScan(aLocsPad, cArmSC6) == 0,aAdd(aLocsPad, cArmSC6),)
                    nSldTot := 0
                    AEVal(aLocsPad, {|x| nSldTot += IIf(SB2->(DBSeek(xFilial("SB2") + aBloqueio[nPos][4] + x)), SB2->B2_QATU - SB2->B2_RESERVA, 0)})

                    If SB2->(MsSeek(xFilial("SB2") + aBloqueio[nPos][4] + cArmSC6))
						nSldArm := SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP - SB2->B2_QEMPSA
					EndIf

                    // Movimentação de estoque.
                    nQtdLib := Val(StrTran(StrTran(StrTran(aBloqueio[nPos][5],",","#"),".",","),"#","."))
                    If nQtdLib > nSldArm .And. nQtdLib <= nSldTot
                        cStep := "07"
                        Break
                    EndIf
                End
            EndIf

            // Bloqueio de estoque.
            cStep := "06"
            Break
        EndIf

        // Análise crédito.
        If AScan(aBloqueio, {|x| x[6] != "10" .and. !Empty(x[6])}) > 0
            cStep := "05"
            Break
        EndIf

        If SE4->(FieldPos("E4_ZPIX")) > 0
            // Aguardando pagamento Pix.
            If Alltrim(Posicione("SE4", 1, xFilial("SE4") + SC5->C5_CONDPAG, "E4_ZPIX")) == "1"
                cStep := "02"
                Break
            EndIf
		EndIf

        // Aguardando adiantamento
        If AllTrim(SC5->C5_CONDPAG) $ cAdiant .And. Empty(SC5->C5_ZDTREGD) //.and. (AllTrim(SC5->C5_CONDPAG) $ cAdi100 .or. (SC5->C5_ZETAPA=="05" .and. cOrigem == "M440SC9I" ))
            cStep := "03"
            Break
        EndIf

         // Aguardando depósito/cartão.
        If AllTrim(SC5->C5_CONDPAG) $ cAVista .And. Empty(SC5->C5_ZDTDEP)
            cStep := "02"
            Break
        EndIf

        DBSelectArea("SB2")
        SB2->(DBSetOrder(1))

        // Belluno.
        If GetNewPar("SL_BELLUNO", .F.) .And. Posicione("SE4", 1, XFilial("SE4") + SC5->C5_CONDPAG, "E4_ZBELLNO") == "1" .And. !U_PaidOut("SC5", SC5->(Recno()))
            cStep := SuperGetMV("SL_STEPBNI", .F.)
            Break
        EndIf

        // Plano de corte.
        If SC5->C5_ZPLCT == "1" .And. cFilAnt == "0202"
            cStep := "20"
            Break
        EndIf

        // Listagem.
        If AScan(aBloqueio, {|x| x[6] != "10" .And. x[7] != "10"}) == 0 .And. cOrigem != "MTX13P25"   // venda futura não cai em listagem
            if SC5->C5_ZETAPA=="99"
                cStep:= SC5->C5_ZETAPA
            else
                cStep := "09"
            endif
            // ----- DATAFRETE - envia o pedido via integração -----
            // Conout("DATAFRETE - INICIO ENVIO")
            // StartJob("U_WSDAFRPE", GetEnvServer(), .T., {cEmpAnt, cFilAnt, SC5->C5_NUM})
            // U_WSDAFRPE({cEmpAnt, cFilAnt, SC5->C5_NUM})
            // Conout("DATAFRETE - FIM ENVIO")
            // -----
            Break
        EndIf

    Recover
        If cStep != SC5->C5_ZETAPA
            RecLock("SC5", .F.)
                // Altera a revisão se a etepa não for progredida.
                If (SC5->C5_ZETAPA == "15" .And. cStep != "16") .Or. (SC5->C5_ZETAPA == "16" .And. cStep != "10")
                    SC5->C5_ZREVISA := Soma1(SC5->C5_ZREVISA)
                EndIf

                // ----- DATAFRETE -----
                // listagem e pedido normal
                If SC5->C5_ZETAPA == "09" .and. Empty(SC5->C5_ZSTATDF)
                    SC5->C5_ZSTATDF := "P"	// Envio pendente
                EndIf
                // -----

                SC5->C5_ZETAPA := cStep
            SC5->(MsUnlock())

            U_LogEtapa(cStep, cOrigem, SC5->C5_NUM)

            // Atualiza a etapa do pedido no e-commerce quando necessário.
            UpdStepEc()
        EndIf
    End Sequence

Return

/*/{Protheus.doc} UpdStepEc
Função para atualizar a etapa do pedido no e-commerce.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 12/16/2020
/*/
Static Function UpdStepEc()

    Local cSTEPEC       := SuperGetMV("SL_STEPEC", .F.)
    Local cIniSTEPEC    := PrefixoCpo(cSTEPEC) + "_"
    Local nId           := 0
    Local oWSTray       := Nil
    Local oJSON         := Nil

    If !Empty(SC5->C5_ZIDTRY) .And. !Empty(nId := Posicione(cSTEPEC, 1, XFilial(cSTEPEC) + SC5->C5_ZETAPA, cIniSTEPEC + "IDTRAY"))
        oWSTray := WSTray():New()

        oJSON := JSONObject():New()
        oJSON["id"] := nId

        oWSTray:SaleOrderSituation(SC5->C5_ZIDTRY, oJSON)

        FreeObj(oJSON)
    EndIf

Return

/*/{Protheus.doc} CustoStd
Função para retornar o custo standard para formação de preço.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 28/09/2020
@param nCusCalc, numeric, custo já calculado.
@param nOP, character, número da OP.
@return numeric, custo.
/*/
User Function CustoStd(nCusCalc, nOP)

    Local nCusto    := 0
    Local aAreaSB1  := SB1->(GetArea())
    Default nOP     := 0

    // Caso haja amarração textil, deverá coletar o custo standard de todos os itens amarrados.
    If !Empty(SB1->B1_ZAMRTXT)
	    If !Empty(nOP)
            nCusto := CusOP(cValToChar(nOP), SB1->B1_ZAMRTXT)
        Else
            nCusto := CusAmrTxt(SB1->B1_ZAMRTXT)
        EndIf

        nCusto := Round(nCusto, TamSX3("B2_VATU1")[2])
    EndIf

    If nCusto <= 0
        nCusto := nCusCalc
    EndIf

    RestArea(aAreaSB1)

Return nCusto

/*/{Protheus.doc} CusAmrTxt
Coleta o custo standard dos itens da amarração textil.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 28/09/2020
@param cAmrTxt, character, item de amarração textil.
@return numeric, custo.
/*/
Static Function CusAmrTxt(cAmrTxt)

    Local cFilter   := "@B1_FILIAL = " + ValToSQL(XFilial("SB1")) + " AND B1_ZAMRTXT = " + ValToSQL(cAmrTxt) "
    Local nCusto    := 0
    Local nQuant    := 0
    Local oJSB2     := Nil

    SB1->(DBSetFilter({|| &cFilter}, cFilter))
    SB1->(DBGoTop())

    While !SB1->(EOF())
        oJSB2 := GetCM1(SB1->B1_COD)
        nQuant += oJSB2["quantidade"]
        nCusto += oJSB2["custo"]
        SB1->(DBSkip())
    End

    If nCusto > 0 .And. nQuant > 0
        nCusto /= nQuant
    EndIf

    SB1->(DBClearFilter())

Return nCusto

/*/{Protheus.doc} GetCM1
Função para coletar o custo médio do produto informado.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 16/10/2020
@param cProd, character, produto.
@return numeric, custo médio.
/*/
Static Function GetCM1(cProd)

	Local cAlias    := GetNextAlias()
    Local cWhereB2	:= "%%"
    Local cArmEst   := SuperGetMv("SL_LOCSTD", .F., "09")
    Local oSB2      := JSONObject():New()

	// Filtra estoque apenas em armazéns específicos quando informados no parâmetro.
	If !Empty(cArmEst)
		cWhereB2 := "%AND B2_LOCAL IN " + FormatIn(cArmEst, "|") + "%"
	EndIf

    BeginSQL Alias cAlias
        SELECT
            SUM(B2_CM1 * B2_QATU) AS B2_CM1,
            SUM(B2_QATU) AS B2_QATU
        FROM
            %Table:SB2% SB2
        WHERE
                B2_FILIAL = %XFilial:SB2%
			AND B2_COD = %Exp:cProd%
			AND SB2.%NotDel%
            %Exp:cWhereB2%
    EndSQL

    If !(cAlias)->(EOF())
        oSB2["quantidade"] := (cAlias)->B2_QATU
        oSB2["custo"] := (cAlias)->B2_CM1
    Else
        oSB2["quantidade"] := 0
        oSB2["custo"] := 0
    EndIf

    (cAlias)->(DBCloseArea())

Return oSB2

/*/{Protheus.doc} CusOP
Coleta o custo da OP informada.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 28/09/2020
@param cOP, character, ordem de produção.
@param cAmrTxt, character, item de amarração textil.
@return numeric, custo.
/*/
Static Function CusOP(cOP, cAmrTxt)

    Local aAreaSD3  := SD3->(GetArea())
    Local aCusto    := {}
    Local cFilter   := "@D3_FILIAL = " + ValToSQL(XFilial("SD3")) + " AND D3_OP LIKE '" + cOP + "%' AND D3_ESTORNO != 'S'"
    Local nCount    := 0
    Local nCusto    := 0
    Local nQtdTot   := 0

    SD3->(DBSetFilter({|| &cFilter}, cFilter))
    SD3->(DBGoTop())

    While !SD3->(EOF())
        If SB1->(MsSeek(XFilial("SB1") + SD3->D3_COD)) .And. SB1->B1_ZAMRTXT == cAmrTxt
            nQtdTot += SD3->D3_QUANT
            AAdd(aCusto, JSONObject():New())

            ATail(aCusto)["qtde"] := SD3->D3_QUANT
            ATail(aCusto)["custo"] := SD3->D3_CUSTO1/SD3->D3_QUANT
        EndIf
        SD3->(DBSkip())
    End

    SD3->(DBClearFilter())

    For nCount := 1 To Len(aCusto)
        nCusto += ATail(aCusto)["custo"] * aCusto[nCount]["qtde"]/nQtdTot
    Next nCount

    RestArea(aAreaSD3)

Return nCusto

/*/{Protheus.doc} WhenDesF
Função para liberar o preenchimento do campo de desconto de frete.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 30/10/2020
@return logical, se pode editar.
/*/
User Function WhenDesF()
    Local _cCoord := SuperGetMV("MV_COORDEN",.F., "") //Codigo de usuario de coordenador para permitir 2,5 % desconto mesmo sem ser avista FERRRAGENS


    Local lOk := .F.

    lOk := (cFilAnt == "0301" .And. !Empty(M->UA_ZDTLBDF)) .or. (cFilAnt$"0101/0201" .and. RetCodUsr()$_cCoord) //Em ferragens somente coordenador pode conseder 2,5% desconto neste campo

Return lOk

/*/{Protheus.doc} VldDesFR
Validação do campo de percentual de desconto quando não utilizado frete grátis.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 30/10/2020
@return return_type, return_description
/*/
User Function VldDesFR()

    Local lOk       := .T.
    Local nMaxDesc  := SuperGetMV("SL_MXDESFR", .F.)

    if cFilAnt$"0101/0201" .and. M->UA_ZDESCES>0 .and. M->UA_ZDESCFR>0
        ShowHelpDlg("MaxDesc", {"Limite de desconto excedido."}, 1, {"Já foi concedido desconto 6."}, 1)
        lOk := .F.
    ElseIf M->UA_ZDESCFR > nMaxDesc
        ShowHelpDlg("MaxDesc", {"Limite de desconto excedido."}, 1, {"O percentual máximo de desconto deve ser: " + cValToChar(nMaxDesc) + "%"}, 1)
        lOk := .F.
    EndIf

Return lOk

/*/{Protheus.doc} RetNameC
Função para retornar o nome do cliente de acordo com o tipo do pedido.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 31/10/2020
@return character, nome do cliente.
/*/
User Function RetNameC()

    Local cName := CriaVar("C5_NOMCLI", .F.)

    If SC5->C5_TIPO $ "D|B"
        cName := Posicione("SA2", 1, XFilial("SA2", SC5->C5_FILIAL) + SC5->(C5_CLIENTE + C5_LOJACLI), "A2_NOME")
    Else
        cName := Posicione("SA1", 1, XFilial("SA1", SC5->C5_FILIAL) + SC5->(C5_CLIENTE + C5_LOJACLI), "A1_NOME")
    EndIf

Return cName

/*/{Protheus.doc} RetNameF
Função para retornar o nome do fornecedor.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 31/10/2020
@return character, nome do fornecedor.
/*/
User Function RetNameF()

    Local cName := CriaVar("F1_FORNAME", .F.)

    If AllTrim(SF1->F1_TIPO) $ "D/B"
        cName := Posicione("SA1", 1, XFilial("SA1", SF1->F1_FILIAL) + SF1->(F1_FORNECE + F1_LOJA), "A1_NOME")
    Else
        cName := Posicione("SA2", 1, XFilial("SA2", SF1->F1_FILIAL) + SF1->(F1_FORNECE + F1_LOJA), "A2_NOME")
    EndIf

Return cName

/*/{Protheus.doc} GerXLS
Gera um excel a partir do grid informado.
@type function
@version 1.0
@author SLA
@since 17/09/2020
@param cAlias, character, alias.
@param cTitle, character, tí­tulo.
@param aFldTot, array, campos totalizadores.
/*/
User Function GerXLS(cAlias, cTitle, aFldTot)

	Local oExcel    := FWMsExcel():New()
	Default aFldTot	:= {}

    oExcel:AddworkSheet(cTitle)
    oExcel:AddTable(cTitle,cTitle)
    BuildHeader(@oExcel, cTitle, cTitle, cAlias, aFldTot)
    BuildRows(@oExcel, cTitle, cTitle, cAlias)

	If ApOleClient("MsExcel")
    	OpenExcel(oExcel)
		FreeObj(oExcel)
	Else
		ShowHelpDlg("NoExcel", {"Microsoft Excel não localizado na estação."}, 1, {"Entre em contato com seu suporte de TI."}, 1)
	EndIf

Return

/*/{Protheus.doc} BuildHeader
Função responsável por criar o cabeçalho da planilha em Excel.
@type function
@version 1.0
@author SLA
@since 17/09/2020
@param oExcel, objeto, Objeto FwMsExcelEx.
@param cWorkSheet, character, Nome do Worksheet.
@param cTable, character, Nome da tabela.
@param cAlias, character, alias.
@param aFldTot, array, campos que devems ser totalizados.
/*/
Static Function BuildHeader(oExcel, cWorkSheet, cTable, cAlias, aFldTot)

    Local aStruct   := (cAlias)->(DBStruct())
	Local cTitle    := ""
	Local nCount    := 0

	For nCount := 1 To Len(aStruct)
		If Empty(cTitle := GetSX3Cache(aStruct[nCount][1], "X3_TITULO"))
            cTitle := StrTran(Capitalace(aStruct[nCount][1]), "_", " ")
        EndIf

		Do Case
			Case aStruct[nCount][2] == "D"
				oExcel:AddColumn(cWorkSheet, cTable, cTitle, 1, 4)
			Case aStruct[nCount][2] == "N"
				oExcel:AddColumn(cWorkSheet, cTable, cTitle, 1, 2, AScan(aFldTot, AllTrim(aStruct[nCount][1])) > 0)
			Otherwise
				oExcel:AddColumn(cWorkSheet, cTable, cTitle, 1, 1)
		EndCase
	Next nCount

Return

/*/{Protheus.doc} BuildRows
Função responsável por criar as linhas da planilha em Excel.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 08/02/2020
@param oExcel, objeto, Objeto FwMsExcelEx.
@param cWorkSheet, character, Nome do Worksheet.
@param cTable, character, Nome da tabela.
@param cAlias, character, alias.
/*/
Static Function BuildRows(oExcel, cWorkSheet, cTable, cAlias)

	Local aRow		:= {}
	Local nCount    := 0

    While !(cAlias)->(EOF())
        aRow := {}
        For nCount := 1 To (cAlias)->(FCount())
            AAdd(aRow, (cAlias)->(FieldGet(nCount)))
        Next nCount
        oExcel:AddRow(cWorkSheet, cTable, aRow)

        (cAlias)->(DBSkip())
    End

Return

/*/{Protheus.doc} OpenExcel
Função responsável por abrir o arquivo gerado em Excel.
@type function
@author SLA
@since 17/09/2020
@version 1.0
@param oExcel, objeto, Objeto FwMsExcelEx.
/*/
Static Function OpenExcel(oExcel)

	Local cFile		:= CriaTrab(,.F.) + ".xml"
	Local cPath 	:= GetTempPath()
	Local oExcelApp	:= Nil

	oExcel:Activate()
	oExcel:GetXMLFile(cFile)
	oExcel:DeActivate()
	FreeObj(oExcel)

	// Copia arquivo do servidor para a máquina local.
	If CpyS2T(cFile, cPath)
		// Apaga arquivo no servidor.
		FErase(cFile)
	Else
		ShowHelpDlg(AllTrim(FunName());
                    ,{"Não foi possível copiar o arquivo do servidor para a máquina local."},1;
                    ,{},0)
		Return
	EndIf
	FRename(cPath + cFile, cPath + (cFile := cEmpAnt + "_" + DToS(Date()) + "-" + StrTran(Time(),":","_") + ".xml"))

	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cPath + cFile)
	oExcelApp:SetVisible(.T.)

	FreeObj(oExcelApp)

Return

/*/{Protheus.doc} PedCo
    (long_description)
    @type  Static Function
    @author user
    @since 01/12/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function PedCo(_cNumPed, _cStPai)
Local _aAreC5:= SC5->(GetArea())
Local _cStat:=""
Local _cAlias:=_cQuery:=''
Local _lRet:= .F.

if xFilial("SC5")+_cNumPed != SC5->(C5_FILIAL+C5_NUM)

    DbSelectArea("SC5")
    DbSetOrder(1)
    If !DbSeek(xFilial("SC5")+_cNumPed)
        RestArea(_aAreC5)
        Return .F.
    endif

endif

_cAlias:="TMPZP"
_cQuery:=" "
_cQuery+=" Select C5_ZETAPA, C5_NUM from "+RetSqlName("SC5")+" C5 "
_cQuery+=" Where C5_FILIAL='"+xFilial("SC5")+"' "
_cQuery+=" 		AND C5_ZPEDORD='"+AllTrim(_cNumPed)+"' "
_cQuery+=" 		and C5.D_E_L_E_T_<>'*' "

If select(_cAlias) > 0
	dbSelectArea(_cAlias)
	dbCloseArea()
EndIf

TcQuery _cQuery New Alias (_cAlias)

DbSelectArea(_cAlias)
DbGoTop()

While (!(_cAlias)->(Eof()))
	_cStat:=(_cAlias)->C5_ZETAPA
    _lRet:= .T.
	(_cAlias)->(DbSkip())
EndDo
If select(_cAlias) > 0
	dbSelectArea(_cAlias)
	dbCloseArea()
EndIf

_cStPai:= _cStat
RestArea(_aAreC5)
Return _lRet


/*/{Protheus.doc} gtnamf
    (GetNameFile, busca nome dinamico para arquivo temporario ex pdf de atendimento.)
    @type  Static Function
    @author Heitor
    @since 08/12/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function gtnamf(_cNome, _cPath, _cExt, _cMsg)
Local _aLetr:={}
Local _cNomTmp:=""
Local _nCompN:= 10 //Comprimento do nome do arquivo
Local _ix:= _nPTmp:= _nTry := 0
Local _nLimTry:= 1000 //Limite de tentativas para novos nomes na mesma solicitacao

_cPath:=Alltrim(_cPath)

if Subs(_cPath,len(_cPath),1)!="\"
    _cPath+="\"
endif

aadd(_aLetr,"A")
aadd(_aLetr,"B")
aadd(_aLetr,"C")
aadd(_aLetr,"D")
aadd(_aLetr,"E")
aadd(_aLetr,"F")
aadd(_aLetr,"G")
aadd(_aLetr,"H")
aadd(_aLetr,"I")
aadd(_aLetr,"J")
aadd(_aLetr,"K")
aadd(_aLetr,"L")
aadd(_aLetr,"M")
aadd(_aLetr,"N")
aadd(_aLetr,"O")
aadd(_aLetr,"P")
aadd(_aLetr,"Q")
aadd(_aLetr,"R")
aadd(_aLetr,"S")
aadd(_aLetr,"T")
aadd(_aLetr,"U")
aadd(_aLetr,"V")
aadd(_aLetr,"W")
aadd(_aLetr,"X")
aadd(_aLetr,"Y")
aadd(_aLetr,"Z")
aadd(_aLetr,"0")
aadd(_aLetr,"1")
aadd(_aLetr,"2")
aadd(_aLetr,"3")
aadd(_aLetr,"4")
aadd(_aLetr,"5")
aadd(_aLetr,"6")
aadd(_aLetr,"7")
aadd(_aLetr,"8")
aadd(_aLetr,"9")

_cNomTmp:= subs(_cNome,1,Len(_cNome)-Len(_cExt))

if !Empty(_cNomTmp) .and. file(_cPath+_cNomTmp+_cExt)
    FERASE(_cPath+_cNomTmp+_cExt)
endif

while _nTry<_nLimTry .and. ( Empty(_cNomTmp) .or. file(_cPath+_cNomTmp+_cExt))

    _cNomTmp:=""
    for _ix:=1 to _nCompN
        _nPTmp:= Randomize(1,len(_aLetr))
        _cNomTmp+= _aLetr[_nPTmp]
    next _ix

enddo

if file(_cPath+_cNomTmp+_cExt)
    _cMsg:="Não foi possivel encontrar um nome de arquivo que já não exista!"
    Return ""
endif

Return _cNomTmp+_cExt


/*/{Protheus.doc} VlGrvArq
    (long_description)
    @type  Static Function
    @author user
    @since 08/12/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function VlGrvArq(cArqPDF)
Local _lOk:=.F.
Local nX

For nX := 1 to 10

    If ! File(cArqPDF)
        Sleep(1000)
    Else
        Exit
    EndIf

Next nX

For nX := 1 to 10

    aFilePDF := Directory(cArqPDF)    // Retorna um array com { cNomeArq, cTamanho, dData, cHora, cAtributos }

    // Verifica se tamanho do PDF gerado está maior que zero

    If len(aFilePDF)>0 .and. len(aFilePDF[1])>0 .and. aFilePDF[1,2] > 0

        // Se maior que zero, OK! Então sai do loop
        _lOk:= .T.
        Exit

    Else

        Sleep(1000)

    EndIf

Next nX

Return _lOk


/*/{Protheus.doc} GetCont
    (Pega o primeiro contato caso só tenha um) INICIADO POREM NAO CONCLUIDO
    @type  Static Function
    @author HEITOR DOS SANTOS
    @since 06/01/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function GetCont(_cCli)

Local cAlias    := GetNextAlias()
Local nCont   := 0
Local _cContat:= ""
Default _cCli:=M->UA_CLIENTE+M->UA_LOJA


BeginSQL Alias cAlias
    SELECT AC8_CODCON
    FROM
        %Table:AC8% AC8
    WHERE
        AC8_FILIAL = %XFilial:AC8%
        AND AC8_ENTIDA = 'SA1'
        AND AC8_FILENT = %XFilial:AC8%
        AND AC8_CODENT  >= %exp:_cCli%
        AND AC8.%NotDel%
EndSQL

DbSelectArea(cAlias)
While !(cAlias)->(EOF())
    nCont++
    _cContat := (cAlias)->QTDSA
    if nCont>1
        exit
    endif
    DbSkip()
EndDo

(cAlias)->(DBCloseArea())

if nCont>1
    _cContat:=""
endif

Return _cContat


/*/{Protheus.doc} VldEst
(long_description)
@type  Static Function
@author user
@since 25/11/2020
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function MTXFUN03(_nItem) //VldEst(_nItem)

	Local _lRet := .T.
	Local _nNx  := 0
	Local _aIts := {}
	Local nPQtd	:= GDFieldPos('UB_QUANT',aHeader)
	Local nPCod := GdFieldPos("UB_PRODUTO",aHeader)
	Local nPBan := GdFieldPos("UB_ZBANDA",aHeader)
	Local _nPTmp:= 0
	Local _nNor	:= 0
	Local _nBan := 0
	Local _nSldT:= 0
	Local _nSldP:= 0
    Local _nQtdEP:=0
    Local _nQtdEPB:=0
    Local _cCodPro:= Acols[n][nPCod]
    Local z
    Local lJaPed:=.F.

    Default _nItem:= 0

    if _nItem>0 .and. aCols[_nItem,Len(aheader)+1]
        Return .T.
    endif

	DbSelectArea("SUA")
	DbSetOrder(1)
	if DbSeek(xFilial("SUA")+M->UA_NUM)
		if SUA->UA_OPER=="1"//Já estava como faturamento
			lJaPed:=.T.//Return .T.
    	endif
	endif

    for _nNx:= 1 to len(aCols)
		if aCols[_nNx,Len(aheader)+1]
			loop
		endif

        if _nItem>0 .and. _nNx<>_nItem
            Loop
        endif

		_nPTmp:=  AScan(_aIts, {|z| z[1] == aCols[_nNx,nPCod]})
		if _nPTmp>0
			if aCols[_nNx,nPBan]=="1"
				_aIts[_nPTmp,3]+=aCols[_nNx,nPQtd]
			else
				_aIts[_nPTmp,2]+=aCols[_nNx,nPQtd]
			endif
		else
			_nBan:=0
			_nNor:=0
			if aCols[_nNx,nPBan]=="1"
				_nBan:=aCols[_nNx,nPQtd]
			else
				_nNor:=aCols[_nNx,nPQtd]
			endif
			AADD(_aIts,{aCols[_nNx,nPCod],_nNor,_nBan})
		endif
	next _nNx

	for _nNx:= 1 to len(_aIts)
		_nSldT:= U_GetSldB2(_aIts[_nNx,1],"2")
        if lJaPed
            _nQtdEP:=_nQtdEPB:=0
            _cCodPro:=_aIts[_nNx,1]
            QtdPv(SUA->UA_NUMSC5, _cCodPro,@_nQtdEP,@_nQtdEPB)
        endif
		_nSldP:= _aIts[_nNx,2]
		if _nSldT+_nQtdEP<_nSldP
			MsgInfo("Saldo do Produto:"+_aIts[_nNx,1]+" é inferior ao solicitado neste atendimento! Não será possivel prosseguir!")
			Return .F.
		elseif _aIts[_nNx,3] > 0
			_nSldT:= U_GetSldB2(_aIts[_nNx,1],"1")
			_nSldP+= _aIts[_nNx,3]
			if _nSldT+_nQtdEPB<_nSldP
				MsgInfo("Saldo do Produto:"+_aIts[_nNx,1]+" é inferior ao solicitado neste atendimento! Não será possivel prosseguir!")
				Return .F.
			endif
		endif
	next _nNx

Return _lRet


/*/{Protheus.doc} QtdPv
    (long_description)
    @type  Static Function
    @author user
    @since 07/01/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function QtdPv(_cNumPv, _cCodPro,_nSldN,_nSldB)
Local _cAlias:=""
Local _cQuery:=" "
Default _nSldN:=0
DEfault _nSldB:=0

_cAlias:="TMPZP"
_cQuery:=" "
_cQuery+=" Select C6_ZBANDA, COALESCE(SUM(C9_QTDLIB),0) QTD  "
_cQuery+=" from "+RetSqlName("SC6")+" C6 "
_cQuery+="      inner join "+RetSqlName("SC9")+" C9 on (C9_FILIAL=C6_FILIAL and C9_PEDIDO=C6_NUM and C9_PRODUTO=C6_PRODUTO and C9_ITEM=C6_ITEM and C9.D_E_L_E_T_<>'*')
_cQuery+=" Where C6_FILIAL='"+xFilial("SC6")+"' "
_cQuery+=" 		AND C6_NUM='"+_cNumPv+"' "
_cQuery+=" 		AND C6_PRODUTO='"+_cCodPro+"' "
_cQuery+=" 		AND C6.D_E_L_E_T_<>'*' "
_cQuery+=" 	    and C9_NFISCAL=' ' and C9_BLOQUEI=' ' and C9_BLWMS=' ' and (C9_BLEST=' ' or C9_BLCRED<>' ') " //and C9_BLEST=' '
_cQuery+=" 	Group by C6_ZBANDA "

If select(_cAlias) > 0
	dbSelectArea(_cAlias)
	dbCloseArea()
EndIf

TcQuery _cQuery New Alias (_cAlias)

DbSelectArea(_cAlias)
DbGoTop()

While (!(_cAlias)->(Eof()))
	if (_cAlias)->C6_ZBANDA=="1"
        _nSldB:= (_cAlias)->QTD
    else
        _nSldN:= (_cAlias)->QTD
    endif

	(_cAlias)->(DbSkip())
EndDo
If select(_cAlias) > 0
	dbSelectArea(_cAlias)
	dbCloseArea()
EndIf

Return .T.


/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 07/01/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function MaLbNfs(nTipo,aPvlNfs,aBloqueio)//Ma410LbNfs

Local aArea     := GetArea()
Local aRegistros:= {}
Local lQuery    := .F.
Local cAliasSC9 := "SC9"
Local cAliasSC6 := "SC6"
Local nPrcVen   := 0
Local nQtdLib   := 0
#IFDEF TOP
	Local cQuery    := ""
#ENDIF
DEFAULT aPvlNfs    := {}
aBloqueio  := {}

Do Case
	Case nTipo == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se há itens liberados                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		#IFDEF TOP
			cAliasSC9 := "MA410PVNFS"
			lQuery := .T.
			cQuery    := "SELECT SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_ITEM,SC9.C9_SEQUEN,SC9.C9_QTDLIB,SC9.C9_QTDLIB2,SC9.C9_PRCVEN,SC9.C9_PRODUTO,SC9.C9_LOCAL,SC9.C9_BLCRED,SC9.C9_BLEST,SC9.C9_BLWMS,SC9.R_E_C_N_O_ SC9RECNO "
			cQuery    += "FROM "+RetSqlName("SC9")+" SC9 "
			cQuery    += "WHERE "
			cQuery    += "SC9.C9_FILIAL='"+xFilial("SC9")+"' AND "
			cQuery    += "SC9.C9_PEDIDO = '"+SC5->C5_NUM+"' AND "
			cQuery    += "SC9.D_E_L_E_T_=' ' "
			cQuery    += "ORDER BY " + SqlOrder(SC9->(IndexKey(1)))

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9)

		#ELSE
			dbSelectArea("SC9")
			dbSetOrder(1)
			MsSeek(xFilial("SC9")+SC5->C5_NUM)
		#ENDIF
		While !Eof() .And. xFilial("SC9") == (cAliasSC9)->C9_FILIAL .And. 	SC5->C5_NUM == (cAliasSC9)->C9_PEDIDO
			If Empty((cAliasSC9)->C9_BLCRED+(cAliasSC9)->C9_BLEST) .And. (Empty((cAliasSC9)->C9_BLWMS) .Or. (cAliasSC9)->C9_BLWMS == "05" .Or. (cAliasSC9)->C9_BLWMS == "07" )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posiciona registros                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SC6->(DbSetOrder(1))
				SC6->(MsSeek(xFilial("SC6")+(cAliasSC9)->C9_PEDIDO+(cAliasSC9)->C9_ITEM+(cAliasSC9)->C9_PRODUTO))

				SE4->(DbSetOrder(1))
				SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )

				SB1->(DbSetOrder(1))
				SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))

				SB2->(DbSetOrder(1))
				SB2->(MsSeek(xFilial("SB2")+(cAliasSC9)->C9_PRODUTO+(cAliasSC9)->C9_LOCAL))

				SF4->(DbSetOrder(1))
				SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se o produto est  sendo inventariado  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF4->F4_ESTOQUE == 'S' .And. BlqInvent((cAliasSC9)->C9_PRODUTO,(cAliasSC9)->C9_LOCAL)
					Help(" ",1,"BLQINVENT",,(cAliasSC9)->C9_PRODUTO+" Almox: "+(cAliasSC9)->C9_LOCAL,1,11)
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Calcula o preco de venda                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPrcVen := (cAliasSC9)->C9_PRCVEN
					If ( SC5->C5_MOEDA <> 1 )
						nPrcVen := a410Arred(xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase,8),"D2_PRCVEN")
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Monta array para geracao da NF                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aadd(aPvlNfs,{ (cAliasSC9)->C9_PEDIDO,;
									(cAliasSC9)->C9_ITEM,;
									(cAliasSC9)->C9_SEQUEN,;
									(cAliasSC9)->C9_QTDLIB,;
									nPrcVen,;
									(cAliasSC9)->C9_PRODUTO,;
									SF4->F4_ISS=="S",;
									If(lQuery,(cAliasSC9)->SC9RECNO,SC9->(RecNo())),;
									SC5->(RecNo()),;
									SC6->(RecNo()),;
									SE4->(RecNo()),;
									SB1->(RecNo()),;
									SB2->(RecNo()),;
									SF4->(RecNo()),;
									(cAliasSC9)->C9_LOCAL,;
									0,;
									(cAliasSC9)->C9_QTDLIB2,;
									SF4->F4_DUPLIC=="S"})
				EndIf
			ElseIf (cAliasSC9)->C9_BLCRED<>"10" .And. (cAliasSC9)->C9_BLEST <>"10"
				aadd(aBloqueio,{(cAliasSC9)->C9_PEDIDO,(cAliasSC9)->C9_ITEM,(cAliasSC9)->C9_SEQUEN,(cAliasSC9)->C9_PRODUTO,TransForm((cAliasSC9)->C9_QTDLIB,X3Picture("C9_QTDLIB")),(cAliasSC9)->C9_BLCRED,(cAliasSC9)->C9_BLEST,(cAliasSC9)->C9_BLWMS})
			EndIf
			dbSelectArea(cAliasSC9)
			dbSkip()
		EndDo
		If lQuery
			dbSelectArea(cAliasSC9)
			dbCloseArea()
			dbSelectArea("SC9")
		EndIf
	Case nTipo == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se não há itens liberados, libera!                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aPvlNfs)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega perguntas do MATA440                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Pergunte("MTA440",.F.)
		lLiber := MV_PAR02 == 1
		lTransf:= MV_PAR01 == 1
		#IFDEF TOP
			lQuery := .T.
			cAliasSC6 := "Ma410PvlNfs"

			cQuery := "SELECT SC6.R_E_C_N_O_ C6RECNO,SC5.R_E_C_N_O_ C5RECNO,"
			cQuery += "SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_ITEM,SC6.C6_QTDVEN,SC6.C6_QTDEMP,SC6.C6_QTDENT,"
			cQuery += "SC6.C6_ENTREG,SC6.C6_BLQ "
			cQuery += " FROM "+RetSqlName("SC6")+" SC6,"
			cQuery += RetSqlName("SC5")+" SC5 "
			cQuery += " WHERE SC6.C6_FILIAL = '"+xFilial('SC6')+"' AND "
			cQuery += " SC6.C6_NUM ='"+SC5->C5_NUM+"' AND "
			cQuery += " SC6.C6_BLQ NOT IN ('S ','R ') AND "
			cQuery += " (SC6.C6_QTDVEN-SC6.C6_QTDEMP-SC6.C6_QTDENT)>0 AND "
			cQuery += " SC6.D_E_L_E_T_ = ' ' AND "
			cQuery += " SC5.C5_FILIAL='"+xFilial("SC5")+"' AND "
			cQuery += " SC5.C5_NUM=SC6.C6_NUM AND "
			cQuery += " SC5.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)

			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAliasSC6)

			TcSetField(cAliasSC6,"C6_ENTREG","D",8,0)

		#ELSE
			dbSelectArea("SC6")
			dbSetOrder(1)
			MsSeek(xFilial("SC6")+SC5->C5_NUM)
		#ENDIF
		While !Eof() .And. (cAliasSC6)->C6_FILIAL == xFilial("SC6") .And.;
			(cAliasSC6)->C6_NUM == SC5->C5_NUM

			aRegistros := {}

			While !Eof() .And. (cAliasSC6)->C6_FILIAL == xFilial("SC6") .And. 	(cAliasSC6)->C6_NUM == SC5->C5_NUM
				If !AllTrim((cAliasSC6)->C6_BLQ) $ "SR"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Calcula a Quantidade Liberada                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nQtdLib := ( (cAliasSC6)->C6_QTDVEN - ( (cAliasSC6)->C6_QTDEMP + (cAliasSC6)->C6_QTDENT ) )
					If nQtdLib > 0
						If RecLock("SC5")
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Posiciona item do pedido de venda                                       ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If ( lQuery )
								SC6->(MsGoto((cAliasSC6)->C6RECNO))
							Else
								SC6->(MsGoto((cAliasSC6)->(RecNo())))
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Recalcula a Quantidade Liberada                                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							RecLock("SC6")
							nQtdLib := ( SC6->C6_QTDVEN - ( SC6->C6_QTDEMP + SC6->C6_QTDENT ) )
							If nQtdLib > 0
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica o tipo de Liberacao                                            ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If ( SC5->C5_TIPLIB == "1" )
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Libera por Item de Pedido                                               ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									Begin Transaction
										MaLibDoFat(SC6->(RecNo()),@nQtdLib,.F.,.F.,.F.,.T.,lLiber,lTransf)
									End Transaction
								Else
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Libera por Pedido                                                       ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									Begin Transaction
										RecLock("SC6")
										SC6->C6_QTDLIB := nQtdLib
										MsUnLock()
										aadd(aRegistros,SC6->(RecNo()))
									End Transaction
								EndIf
							EndIf
							SC6->(MsUnLock())
						EndIf
					EndIf
				EndIf
				dbSelectArea(cAliasSC6)
				dbSkip()
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Libera por Total de Pedido                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( Len(aRegistros) > 0 )
				Begin Transaction
					SC6->(MaAvLibPed(SC5->C5_NUM,lLiber,lTransf,.F.,aRegistros,Nil,Nil,.F.,Nil))
				End Transaction
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o Flag do Pedido de Venda                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Begin Transaction
				SC6->(MaLiberOk({SC5->C5_NUM},.F.))
			End Transaction
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle de cancelamento por solicitacao do usuario                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cAliasSC6)
		EndDo
		If lQuery
			dbSelectArea(cAliasSC6)
			dbCloseArea()
			dbSelectArea("SC6")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega perguntas do MATA410                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Pergunte("MTA410",.F.)
	EndIf
EndCase
RestArea(aArea)
Return(.T.)


/*/{Protheus.doc} ClcDesc
    (Regra de calculo de descontos do atendimento)
    @type  Static Function
    @author user
    @since 14/01/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function ClcDesc(_nPrcTab,nPerDesc,nDescSpc,_nVlDesc,_nPDesc,nUB_ZDESCON,nUB_ACRE,nUB_VALACRE,_nCorLap)
Local _nValPrc:=_nPrcTab

_nValPrc:= _nValPrc - (nPerDesc/100 * _nValPrc)//Aplica desconto escalonado primeiro
// Desconto 6 + Desconto Categorizado + Desconto Distribuição + Desconto Frete.
//nDescSpc := M->UA_ZDESCES + M->UA_ZDESCCT + M->UA_ZDESDIS + M->UA_ZDESCFR
_nValPrc:= _nValPrc - (nDescSpc/100 * _nValPrc)//Aplica descontos avista + desconto 6 + frete
_nValPrc:= Round(_nValPrc,2)//Arredonda
// Sobre o valor liquido com desconto aplicado o Desconto do Coordenador
// este desconto nao entra no percentual de desconto geral
_nValPrc:= _nValPrc - (nUB_ZDESCON/100 * _nValPrc)
_nValPrc:= Round(_nValPrc,2)//Arredonda

//Acrescimo de Corte e lapidação
_nValPrc+= _nCorLap

//nUB_ACRE - Acrescimo
nUB_VALACRE := (nUB_ACRE/100 * _nValPrc) // Obtem o liquido do acrescimo.
_nValPrc:= _nValPrc + (nUB_ACRE/100 * _nValPrc)
_nValPrc:= Round(_nValPrc,2)//Arredonda

_nVlDesc:= _nPrcTab-_nValPrc//Obtem o liquido com os descontos.
_nPDesc := _nVlDesc*100/_nPrcTab  //Percentual de desconto


Return _nValPrc


/*/{Protheus.doc} GatMtx
    (long_description)
    @type  Static Function
    @author user
    @since 27/01/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function GatMtx()
Local _cReturn:= M->UA_CONDPG

U_CALCDESC()

Return _cReturn


/*/{Protheus.doc} clccom
    (long_description)
    @type  Static Function
    @author user
    @since 02/02/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function clccom(_nBase, _nPerc, _nValCom,_nRecSe1)
//Tabela SE1CCS contem titulos antigo e seus valores e percentuais.
Local cAlias    := GetNextAlias()
Local _cFil := SE1->E1_FILIAL
Local _cPref:= SE1->E1_PREFIXO
Local _cNum := SE1->E1_NUM
Local _cParc:= SE1->E1_PARCELA
Local _cTipo:= SE1->E1_TIPO
Local _cClie:= SE1->E1_CLIENTE
Local _cLoja:= SE1->E1_LOJA
Local _cVend:= SE1->E1_VEND1
Local _cDtEm:= DTOS(SE1->E1_EMISSAO)
Local _lRet :=.F.


if Alltrim(SE1->E1_TIPO)=='CCS' .and. SE1->E1_PREFIXO=="IMP"
    BeginSQL Alias cAlias
        SELECT
            E1_COMIS1, E1_BASCOM1, E1_VALCOM1
        FROM
            SE1CCS
        WHERE
                E1_FILIAL = %Exp:_cFil%
            AND E1_PREFIXO = %Exp:_cPref%
            AND E1_NUM     = %Exp:_cNum%
            AND E1_PARCELA = %Exp:_cParc%
            AND E1_TIPO    = %Exp:_cTipo%
            AND E1_CLIENTE = %Exp:_cClie%
            AND E1_LOJA    = %Exp:_cLoja%
            AND SE1CCS.%NotDel%
    EndSQL

    If (!(cAlias)->(EOF()))
        _nPerc:= (cAlias)->E1_COMIS1
        _nBase:= (cAlias)->E1_BASCOM1
        _nValCom:= _nPerc*_nBase/100//(cAlias)->E1_VALCOM1
        _lRet:= .T.
    EndIf
    (cAlias)->(DBCloseArea())
endif


if !_lRet
    BeginSQL Alias cAlias
        select Z03_VEND, Z03_FAIXA from Z03010 Z03
        where
            Z03_FILIAL='03'
            and Z03.%NotDel%
            and Z03_VEND=%Exp:_cVend%
            and %Exp:_cDtEm% between Z03_DATINI and Z03_DATFIN
        order by Z03_VEND
    EndSQL

    If (!(cAlias)->(EOF()))
        _nPerc:= (cAlias)->Z03_FAIXA
        _lRet:= .T.
    EndIf
    (cAlias)->(DBCloseArea())

endif

Return _lRet


/*/{Protheus.doc} atuACP
description)
Local _cData:= DTOS(Date())
Local _cHora:= Time()
    @type  Static Function
    @author user
    @since 18/02/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (Usar CCTabLoj.prw, GetTabPrc (TryInt.prw))
    @see (links_or_references)
    /*/
User Function atuACP()
Local _cData:= DTOS(Date())
Local _cHora:= Time()
Local cQry  := ""

cQry := " UPDATE "+RetSqlName("ACP")+" SET ACP_MSEXP='"+_cData+"',ACP_HREXP='"+_cHora+"' WHERE ACP_FILIAL='"+xFilial("ACP")+"' and ACP_MSEXP=' ' and D_E_L_E_T_<>'*' "
nStatus:=TCSqlExec(cQry)

Return (nStatus == 0)


/*/{Protheus.doc} GetMxAcp
    (Em desenvolvimento deve retornar a Ultima Atualização da ACP para ver se integrou ou não e ver quais itens deve integrar)
    @type  Static Function
    @author user
    @since 18/02/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (Usar CCTabLoj.prw, GetTabPrc (TryInt.prw))
    @see (links_or_references)
    /*/
Static Function GetMxAcp()

	//Local aArea     := GetArea()
	//Local cQryAux   := ""
	Local cAlias 	:= GetNextAlias()
    Local _MvCAtu   := ""

	BeginSQL Alias cAlias
		SELECT
			MAX(ACP_MSEXP+ACP_HREXP) DTHR
		FROM
			%Table:ACP% ACP
		WHERE
				ACP_FILIAL = %XFilial:ACP%
			AND ACP.%NotDel%
	EndSQL

	if !(cAlias)->(EOF())
		_MvCAtu:=(cAlias)->DTHR

	Endif
	(cAlias)->(DBCloseArea())

Return _MvCAtu

/*/{Protheus.doc} SaveLog
Método para salvar o log do web service.
@type function
@version 1.0
@author comercial@codecrafters.com.br
@since 12/7/2020
/*/
User Function SvLogEC(_lJob,oJ1,oJ2,nStat,cErr,_cUrl)

	Local _cLGTRAY	 := ""
	Local _cIniLGTRAY := ""

    Local _lLock:= .F.
    Local _nCont:= 0

	Default _lJob:= .F.
	Default oJ1:= NIL
	Default oJ2:= oJResp:ToJSON()
	Default nStat:= "999"//nStatus
	Default cErr:= cError
    Default _cUrl:= "http://187.85.166.230:8082/app/wsfret/calculo-frete"

    DbSelectArea("Z32")
    while !_lLock .and. _nCont<=100
        _nCont++
        _lLock:= RecLock("Z32", .T.)
        if _lLock
            Z32->Z32_FILIAL := FWxFilial("Z32")
            Z32->Z32_URL := _cUrl
            Z32->Z32_DATE := Date()
            Z32->Z32_TIME := Time()
            If oJ1 != Nil
                Z32->Z32_JREQ := oJ1
            EndIf
            Z32->Z32_JRESP := oJ2
            Z32->Z32_HTTPCD := cValToChar(nStat)
            Z32->Z32_ERROR  := cErr
        endif
        Z32->(MsUnlock())

        if _nCont>=2
            conout("WSTRAY_SAVELOG "+ALLTRIM(_nCont))
        endif
    enddo
    Z32->(DbCloseArea())

    /*
    _cLGTRAY	 := SuperGetMV("SL_LGTRAY", .F.)
	_cIniLGTRAY := PrefixoCpo(_cLGTRAY) + "_"

    DbSelectArea(_cLGTRAY)
	RecLock(_cLGTRAY, .T.)
		(_cLGTRAY)->&(_cIniLGTRAY + "FILIAL") := XFilial(_cLGTRAY)
		(_cLGTRAY)->&(_cIniLGTRAY + "URL") := _cUrl
		(_cLGTRAY)->&(_cIniLGTRAY + "DATE") := Date()
		(_cLGTRAY)->&(_cIniLGTRAY + "TIME") := Time()
        If oJ1 != Nil
		    (_cLGTRAY)->&(_cIniLGTRAY + "JREQ") := oJ1
        endif
		(_cLGTRAY)->&(_cIniLGTRAY + "JRESP") := oJ2
		(_cLGTRAY)->&(_cIniLGTRAY + "HTTPCD") := cValToChar(nStat)
		(_cLGTRAY)->&(_cIniLGTRAY + "ERROR") := cErr
    DbSelectArea(_cLGTRAY)
	(_cLGTRAY)->(MsUnlock())
*/

Return

/*/{Protheus.doc} GTLTVEN
	(Retorna o B1_LOTVEN e atualiza o campo B1_ZHISQTD com o historico caso tenha alterado)
	@type  Static Function
	@author user
	@since 22/04/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
/*
Static Function GTLTVEN(_nRecB1)
Local _nRecBkp:= 0
Local _oJson
Local _cRet
Local _nValAnt:= 0
Local _cTmpDt:=""
Local _ix
Local _nPOld
Default _nRecB1:= 0

_nRecBkp:= IIF(_nRecB1>0, SB1->(RECNO()),0)

if _nRecB1>0
	DbSelectArea("SB1")
	DbGoto(_nRecB1)
endif

if !Empty(SB1->B1_ZHISQTD)
	_oJson := JsonObject():New()
	_cRet := _oJson:FromJson(Alltrim(SB1->B1_ZHISQTD))
   if ValType(ret) == "C"
		DbSelectAre("SB1")
		Reclock("SB1",.F.)
		SB1->B1_ZHISQTD:=""
		MsUnlock()
   elseif ValType(ret) == "A"
		for _ix:=1 to len(ret)
			if ret[_ix]['dt']>_cTmpDt
				_cTmpDt:= ret[_ix]['dt']
				_nValAnt:= ret[_ix]['qt']
			endif
		next _ix
   endif
endif

if _nValAnt>0 .and. _nValAnt!= SB1->B1_LOTVEN
	if len(ret)==3
		_cTmpDt:="99999999"
		for _ix:=1 to len(ret)
			if ret[_ix]['dt']<_cTmpDt
				_nPOld:= _ix
			endif
		next _ix
		ret[_nPOld]['dt']:= dtos(date())+subs(time(),1,5)
		ret[_nPOld]['qt']:= SB1->B1_LOTVEN
	else
		AADD(ret,JsonObject():New())
		_nPOld:= len(ret)
	endif
	ret[_nPOld]['dt']:= dtos(date())+subs(time(),1,5)
	ret[_nPOld]['qt']:= SB1->B1_LOTVEN
endif

if _nRecBkp>0
	DbSelectArea("SB1")
	DbGoto(_nRecBkp)
endif

Return Max(SB1->B1_LOTVEN,1)
*/

/*/{Protheus.doc} GetIdTab
    (long_description)
    @type  Static Function
    @author user
    @since 22/04/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function GetIdTab(_nIdParc, _cUf,_cCodTab,_cGrpVen)

Local _cQuery:= " select COALESCE(R_E_C_N_O_,0) REC from "+RetSqlName("Z37")+" where Z37_FILIAL='"+xFilial("Z37")+"' and Z37_IDPARC="+Alltrim(Str(_nIdParc))+" and D_E_L_E_T_<>'*' "
Local _nRet:= 0

_nRet:= U_SqlToVal(_cQuery)

if _nRet==0
    _cUf:= ""
    _cCodTab:= ""
else

    DbSelectArea("Z37")
    DbSetOrder(1)

    DbGoTo(_nRet)
    _cUf:= Z37->Z37_UF
    _cCodTab:= Z37->Z37_ACOCOD
    _cGrpVen:= Z37->Z37_CLIENT+Z37_LOJA
    _cGrpVen:= POSICIONE("SA1",1,xFilial("SA1")+_cGrpVen,"A1_GRPVEN")
endif
/*
Local _nIdTab:= 0
Local _ix
Local _nIdTmp:= 0

Private aHeader := {}
Private oAPI
Private aParceiro:= {}


//ConRest()
oAPI:= StaticCall(MTXFUN, ConRest,@aHeader)


GetParc()

DbSelectArea("Z37")
DBSetOrder(1)
For _ix:=1 to Len(aParceiro)
    _nIdTab:= aParceiro[_ix,2]
    _nIdTmp:= aParceiro[_ix,1]

    DbGoTop()
    While !Z37->(Eof())
        if _nIdTab==Z37->Z37_ZIDTRY
            RecLock("Z37",.F.)
            Z37->Z37_IDPARC:= _nIdTmp
            MsUnlock()
            Exit
        endif
        DbSkip()
    enddo


next _iz
*/

/*
Local _nPini:= _nPfim := 0

_cUf:=""
_cCodTab:=Subs(_cNomTb,1,6)

_nPini:= At('-', _cNomTb)
_nPini++
_nPfim:= At('-', _cNomTb,_nPini)//RAt('-', _cNomTb)
_cUf:= Subs(_cNomTb,_nPini,_nPfim-_nPini)
_cUf:=Alltrim(_cUf)
_cUf:=Alltrim(subs(_cUf,Len(_cUf)-2))
*/
Return

/*/{Protheus.doc} ConnRest
    (Connecta na API do ecommerce traycorp)
    @type  Static Function
    @author user
    @since 19/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function ConRest(aHeader,_cToken)

	Local cHost := "https://api.fbits.net"
	Local cToken
    Default _cToken:= SuperGetMV("SL_TOKTRAY", .F.)

    cToken := _cToken

	AAdd(aHeader, "Authorization: Basic " + cToken)
	AAdd(aHeader, "Content-Type: application/json")

	oAPI := FWREST():New(cHost)
Return oAPI

/*/{Protheus.doc} GetParc
    (Retornar um array com os parceiros e suas tabelas de preço)
    @type  Static Function
    @author user
    @since 19/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function GetParc()
Local lOk 	:= .T.
Local cError:= ""
Local oResult:= JSONObject():New()
Local _nIdParc:=0
Local _nIdTab:= 0
Local _cDescP:= ""
Local _cNomT := ""
Local _cJson := ""
Local _ix

	oAPI:SetPath("/parceiros")
	lOk := oAPI:Get(aHeader)

	If lOk
		oResult:FromJSON(oAPI:GetResult())

        for _ix:=1 to Len(oResult)
            _nIdParc:=oResult[_ix]["parceiroId"]
            _nIdTab:= oResult[_ix]["tabelaPrecoId"]
            _cDescP:= oResult[_ix]["nome"]
            AADD(aParceiro,{_nIdParc,_nIdTab,_cDescP,"",oResult[_ix]:toJson(),""} )
        next _iz

	Else
		cError := oAPI:GetLastError()
	EndIf

    For _ix:=1 to Len(aParceiro)
        _cNomT:= ""
        _cJson:= ""
        if GetTb(aParceiro[_ix,2], @_cNomT, @_cJson)
            aParceiro[_ix,4]:=_cNomT
            aParceiro[_ix,6]:= _cJson
        endif
    next _iz


Return

/*/{Protheus.doc} GetTb
    (Retorna a tabela de preços a partir do ID)
    @type  Static Function
    @author user
    @since 19/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GetTb(_nIdTab, _cDescT, _cJson)
Local lOk 	:= .T.
Local cError:= ""
Local oResult:= JSONObject():New()

	oAPI:SetPath("/tabelaPrecos/" + cValToChar(_nIdTab))

    lOk := oAPI:Get(aHeader)

	If lOk
		oResult:FromJSON(oAPI:GetResult())

        _cDescT:= oResult["nome"]
        _cJson := oAPI:GetResult()
	Else
		cError := oAPI:GetLastError()
	EndIf



Return lOk

/*/{Protheus.doc} PosZ38
    (Posiciona tabel Z38)
    @type  Static Function
    @author user
    @since 22/04/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function PosZ38(_cCodPro,_cDtPed,_cUf,_cCodACO)
Local cAlias := GetNextAlias()
Local _lRet:= .F.

_cDtPed:=StrTran(_cDtPed," ","")
_cDtPed:=StrTran(_cDtPed,":","")
_cDtPed:=StrTran(_cDtPed,"-","")
_cDtPed:=StrTran(_cDtPed,"T","")

    BeginSQL Alias cAlias
		SELECT
			TOP(1) Z38_CODACO, Z38_UF, Z38_PRODUT, Z38_PRDE, Z38_PRPOR,Z38_DTINT,Z38_PRCBAS,Z38_IPI,Z38_ST,Z38_LOTVEN , R_E_C_N_O_ REC
		FROM
			%Table:Z38% Z38
		WHERE
				Z38_FILIAL = %XFilial:Z38%
            AND Z38_CODACO = %Exp:_cCodACO%
            AND Z38_UF = %Exp:_cUf%
            AND Z38_PRODUT = %Exp:_cCodPro%
            AND Z38_DTINT+Z38_HRINT <= %Exp:_cDtPed%
			AND Z38.%NotDel%
            AND Z38_DTINT<>' '
            AND Z38_HRINT not like '%XX'
            Order by Z38_DTINT DESC, Z38_HRINT DESC
	EndSQL

	if !(cAlias)->(EOF())
		DbSelectArea("Z38")
		DbSetOrder(1)
        DbGoTo((cAlias)->REC)
        _lRet:= .T.
	Endif
	(cAlias)->(DBCloseArea())

Return _lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MTXVDEXP
Validacao do desconto 6 Tela Atendimento
@author  author
date: "24/02/2020"
/*/
//-------------------------------------------------------------------
Static Function MTXVDEXP()

    Local lExpres   := IIF(cFilAnt=="0202" .and. M->UA_ZEXPRES=="1",.T.,.F.)
    Local lRet      := .T.
    Local nZExpre   := SuperGetMv("ZEXPRMAX", .F.,10)
    Local _nPAcre   := M->UA_ZACRE

    Begin Sequence

        If lExpres
            if _nPAcre> nZExpre
                MSGSTOP("Não é possivel acréssimo maior que: " + Transform(nZExpre, "@E 99.99") + "%", "Desconto")
                M->UA_ZACRE := 0
                Break
            endif
        else
            if _nPAcre> 0
                MSGSTOP("Não é possivel acréssimo ", "Desconto")
                M->UA_ZACRE := 0
                Break
            endif
        EndIf

        U_CALCDESC("UB_VRUNIT")
        EVal(bGDRefresh)

    Recover
        lRet := .F.
    End Sequence

Return lRet


/*/{Protheus.doc} getpdf
    (long_description)
    @type  Static Function
    @author user
    @since 08/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function getpdf(_cFil, _cPed, _nDesc6, _nValtot, _cFretC)
Local _aArea:= GetArea()
Local _aAreUA:= SUA->(GetArea())
Local _aAreUB:= SUB->(GetArea())

_nValtot:= 0
DbSelectArea("SUA")
DbSetOrder(1)
if DbSeek(_cFil+_cPed)
    DbSelectArea("SUB")
    DbSetOrder(1)
    if DbSeek(_cFil+_cPed)
        _nDesc6:= SUA->UA_ZDESCES
        _cFretC:= SUA->UA_ZFRECOR
        While !SUB->(Eof()) .and. SUB->(UB_FILIAL+UB_NUM) == _cFil+_cPed
            _nValtot+= SUB->UB_VLRITEM
            DbSelectArea("SUB")
            DbSkip()
        enddo
    endif
endif


RestArea(_aAreUB)
RestArea(_aAreUA)
RestArea(_aArea)
Return

/*/{Protheus.doc} RetCampo
    (long_description)
    @type  Static Function
    @author user
    @since 10/08/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RetCampo(cTpEsc, cProd, _cGrpVen,cGrupo,cFamil)
//Local cGrupo := Posicione("SB1", 1, XFilial("SB1") + cProd, "B1_GRUPO")
//Local cFamil := Posicione("SBM", 1, XFilial("SBM") + cGrupo, "BM_TIPGRU")
Local cAliasACO:= GetNextAlias()
Local _cRet:="Valor"

	cQuery2 :=""
    cQuery2 := "SELECT ACP_TPDESC "
    cQuery2 += "FROM "+ RetSqlName("ACO") + " AS ACO "
    cQuery2 += "INNER JOIN "+ RetSqlName("ACP") + " AS ACP  ON  (ACO_FILIAL = ACP_FILIAL AND ACP_CODREG = ACO_CODREG AND ACP.D_E_L_E_T_ <> '*' ) "
    cQuery2 += "WHERE   "
    cQuery2 += "ACO_GRPVEN = '"+ _cGrpVen +"'"
    cQuery2 += "AND ACO_FILIAL ='"+ xFilial('ACO')+"'"
    cQuery2 += "AND ACO.D_E_L_E_T_ <> '*' "

    If cTpEsc == "I"
         cQuery2 += "AND ACP_CODPRO = '"+cProd +"'"
    // Escalona por grupo.
    ElseIf cTpEsc == "G"
        cQuery2 += "AND ACP_GRUPO = '"+cGrupo +"'"

       // Escalona por família.
    ElseIf cTpEsc == "F"
        cQuery2 += "AND ACP_ZTPPRD = '"+cFamil +"'"
    EndIf


    cQuery2    := ChangeQuery(cQuery2)

    If Select(cAliasACO) <> 0
        (cAliasACO)->(dbCloseArea())
    Endif

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery2),cAliasACO,.F.,.T.)

    if (cAliasACO)->(!EOF())
        While (cAliasACO)->(!EOF())
            _cRet:= (cAliasACO)->ACP_TPDESC
            _cRet:= IIF(_cRet=="1","Qtde","Valor")
            (cAliasACO)->(dbskip())
        enddo
    elseif cFilAnt=="0301"
        //_cRet:=RetCampo("", cProd, _cGrpVen,cGrupo,cFamil)
        Msginfo("Escalonamento não encontrado, Favor acionar o TI IMEDIATAMENTE."+"ACO_GRPVEN = '"+ _cGrpVen +"' cTpEsc="+cTpEsc+" cProd="+cProd)
        __EXCEPTION__->ERROR := "__EXCEPTION__"
        Return .F.
    endif

    If Select(cAliasACO) <> 0
        (cAliasACO)->(dbCloseArea())
    Endif

Return _cRet


// Grava LOG (Z40) - Funcao para geracao de log customizado
User Function FtGeraLog(mvFilExt, mvTabela, mvChave, mvDescri, mvLog, mvCodUser, mvRotina)
	// area inicial
	local _aAreaAtu := GetArea()
	// codigo e nome do usuario
	local _cCodUser := ""
	local _cNomUser := ""

	// usuário padrao
	Default mvCodUser := __cUserID
	Default	mvRotina  := AllTrim(FunName())

	// define codigo e nome do usuario
	_cCodUser := IIf( (Empty(mvCodUser)), "000000"  , mvCodUser )
	_cNomUser := IIf( (Empty(mvCodUser)), "WorkFlow", UsrFullName(mvCodUser) )

	// insere registro
	DBSelectArea("Z40")
	RecLock("Z40",.T.)
		Z40->Z40_FILIAL := mvFilExt
		Z40->Z40_TABELA := mvTabela
		Z40->Z40_CHAVE  := mvChave
		Z40->Z40_DATA   := Date()
		Z40->Z40_HORA   := Time()
		Z40->Z40_IDUSER := _cCodUser
		Z40->Z40_NOME   := _cNomUser
		Z40->Z40_DESCRI := mvDescri
		Z40->Z40_LOG	:= mvLog
		Z40->Z40_NMCOMP := GetComputerName()
		Z40->Z40_IPCOMP := GetClientIP()
		Z40->Z40_ROTINA := mvRotina
	MsUnLock("Z40")

	// restaura area inicial
	RestArea(_aAreaAtu)
Return(.t.)

/*/{Protheus.doc} GRPTRIB
    (long_description)
    @type  Static Function
    @author user
    @since 05/11/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function GRPTRIB(_cUf, _cIe,_cSimpl, _cPessoa, _cSimei, _cSinteg, _cCnae )
Local _cGrpTri:=""
Local _lIsent := (Empty(_cIe) .or. Alltrim(_cIe)=="ISENTO")
Local _cTpCnae:= U_tpCnae(_cCnae)

/*
Grupo de cliente - A1_GRPTRIB

Os grupos de clientes são preenchidos conforme perfil fiscal do cliente, resume a inscrição estadual, Tipo de Pessoa, CNAE, Simples Nacional e SIMEI.
Abaixo descrição de cada grupo de cliente e sua respectiva regra:


Empresa 0301 - Personalizáveis

Grupo 001 | Cliente Optante pelo Simples Nacional de Santa Catarina com Inscrição Estadual
Grupo 004 | Cliente Não Optante pelo Simples Nacional de Santa Catarina com Inscrição Estadual
Grupo 011 | Todos os clientes CPF ou Todos os clientes com inscrição estadual isenta não enquadrado no SIMEI e todos os clientes com inscrição isenta, independente do simei, só com cnae de serviço. 
Grupo 016 | Todos os clientes com inscrição estadual isenta enquadrado no SIMEI. Exceto para os estados de RS, PR, MG e RJ.
Grupo 105 | Todos os Clientes com Inscrição Estadual ativa, dos estados do RJ, MG e RS ou Cliente do PR não optante pelo Simples Nacional, optante pelo SIMEI ou não; ou isento optante pelo SIMEI dos estados RJ, MG e RS.
Grupo 020 | Todos os clientes com inscrição estadual (tem número) independente da situação do SIMEI.  Exceto os estados de SC, RJ, PR, MG e RS
Grupo 108 | Todos os clientes de fora do Brasil.
Grupo 109 | Todos os clientes do PR com inscrição estadual ativa e optante pelo simples nacional e inscrição isenta, optante pelo simei e atividade de comércio/fabricação.

Grupo 002, 007, 107, 005, 012, 013, 006, 019 e 008 não terão gatilhos pois dependem de cartas de isenções especificas, informações não disponíveis para coleta.
O cliente envia o documento digital quando possui o benefício. Não alterar clientes com estes grupos, deixar no status atual.

Empresa 0101 – FERRAGENS101

Grupo 001 | Cliente Optante pelo Simples Nacional de Santa Catarina com Inscrição Estadual
Grupo 004 | Cliente Não Optante pelo Simples Nacional de Santa Catarina com Inscrição Estadual
Grupo 011 | Todos os clientes CPF ou Todos os clientes com inscrição estadual isenta não enquadrado no SIMEI e todos os clientes com inscrição isenta, independente do simei, só com cnae de serviço.
Grupo 016 | Todos os clientes com inscrição estadual isenta enquadrado no SIMEI.
Grupo 020 | Todos os clientes com inscrição estadual (tem número) independente da situação do SIMEI.  Exceto SC.
Grupo 108 | Todos os clientes de fora do Brasil.

Empresa 0202 – VIDROS

Grupo 011 | Todos os clientes CPF, todos os clientes com inscrição isenta não enquadrado no simei e todos os clientes com inscrição isenta, independente do simei, só com cnae de serviço. 
Grupo 014 | Todos os clientes do CE, exceto os cliente com inscrição isenta independente do simei com cnae de serviço
Grupo 016 | Todos os clientes com inscrição estadual isenta enquadrado no SIMEI. Exceto para o CE
Grupo 020 | Todos os clientes com inscrição estadual (tem número) independente da situação do SIMEI.  Exceto CE.


*/

Do Case
    Case cFilAnt == "0301"
        if _cUf=="SC" .and. !_lIsent //001/004
            if _cSimpl=="1" //Optante pelo simples
                _cGrpTri := "001" //Grupo 001 | Cliente Optante pelo Simples Nacional de Santa Catarina com Inscrição Estadual
            else
                _cGrpTri := "004" //Grupo 004 | Cliente Não Optante pelo Simples Nacional de Santa Catarina com Inscrição Estadual
            endif
        //Grupo 011 | Todos os clientes CPF ou Todos os clientes com inscrição estadual isenta não enquadrado no SIMEI e todos os clientes com inscrição isenta, independente do simei, só com cnae de serviço. 
        elseif _cPessoa=="F" .or. (_lIsent .and. (!_cSimei=="S" .or. _cTpCnae=="S"))
            _cGrpTri := "011"
        elseif _lIsent .and. _cSimei=="S" .and. !_cUf$"PR/MG/RJ" //Grupo 016 | Todos os clientes com inscrição estadual isenta enquadrado no SIMEI. Exceto para os estados de RS, PR, MG e RJ.
            _cGrpTri := "016"
        //Grupo 105 | Todos os Clientes com Inscrição Estadual ativa, dos estados do RJ, MG e RS ou Cliente do PR não optante pelo Simples Nacional, optante pelo SIMEI ou não; ou isento optante pelo SIMEI dos estados RJ, MG e RS.
        elseif (_cUf$"MG/RJ" .and. (!_lIsent .and. _cSinteg=="H" .or. _lIsent .and. _cSimei=="S") ) .or. (_cUf=="PR" .and. !_cSimpl=="1")
            _cGrpTri := "105"
        elseif !_lIsent .and. !_cUf$"SC/RJ/PR/MG" //Grupo 020 | Todos os clientes com inscrição estadual (tem número) independente da situação do SIMEI.  Exceto os estados de SC, RJ, PR, MG e RS
            _cGrpTri := "020"
        elseif _cUf=="EX"//Grupo 108 | Todos os clientes de fora do Brasil.
            _cGrpTri := "108"
        elseif _cUf=="PR" .and. ((!_lIsent .and. _cSinteg=="H" .and. _cSimpl=="1") .or. (_lIsent .and. _cSimei=="S" .and. _cTpCnae$"C/F")) //Grupo 109 | Todos os clientes do PR com inscrição estadual ativa e optante pelo simples nacional e inscrição isenta, optante pelo simei e atividade de comércio/fabricação.
            _cGrpTri := "109"
        endif
    Case cFilAnt == "0101"
        if _cUf=="SC" .and. !_lIsent //001/004
            if _cSimpl=="1" //Optante pelo simples
                _cGrpTri := "001" //Grupo 001 | Cliente Optante pelo Simples Nacional de Santa Catarina com Inscrição Estadual
            else
                _cGrpTri := "004" //Grupo 004 | Cliente Não Optante pelo Simples Nacional de Santa Catarina com Inscrição Estadual
            endif
        //Grupo 011 | Todos os clientes CPF ou Todos os clientes com inscrição estadual isenta não enquadrado no SIMEI e todos os clientes com inscrição isenta, independente do simei, só com cnae de serviço.
        elseif _cPessoa=="F" .or. (_lIsent .and. (!_cSimei=="S" .or. _cTpCnae=="S"))
            _cGrpTri := "011"
        elseif _lIsent .and. _cSimei=="S" //Grupo 016 | Todos os clientes com inscrição estadual isenta enquadrado no SIMEI.
            _cGrpTri := "016"
        elseif !_lIsent .and. !_cUf$"SC" //Grupo 020 | Todos os clientes com inscrição estadual (tem número) independente da situação do SIMEI.  Exceto SC.
            _cGrpTri := "020"
        elseif _cUf=="EX"//Grupo 108 | Todos os clientes de fora do Brasil.
            _cGrpTri := "108"
        endif
    Case cFilAnt == "0202"
        //Grupo 011 – Todos os clientes CPF, todos os clientes com inscrição isenta não enquadrado no simei e todos os clientes com inscrição isenta, independente do simei, só com cnae de serviço. 
        if _cPessoa=="F" .or. (_lIsent .and. (!_cSimei=="S" .or. _cTpCnae=="S"))
            _cGrpTri := "011"
        //Grupo 014 – Todos os clientes do CE, exceto os cliente com inscrição isenta independente do simei com cnae de serviço
        elseif _cUf$"CE" .and. !_lIsent
            _cGrpTri := "014"
        elseif !_cUf$"CE" .and. _lIsent .and. _cSimei=="S" //Grupo 016 | Todos os clientes com inscrição estadual isenta enquadrado no SIMEI. Exceto para o CE
            _cGrpTri := "016"
        elseif !_lIsent .and. !_cUf$"CE" //Grupo 020 | Todos os clientes com inscrição estadual (tem número) independente da situação do SIMEI.  Exceto CE.
            _cGrpTri := "020"
        endif

ENDCASE


Return _cGrpTri

/*/{Protheus.doc} User Function nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 07/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function PosE1E3()
Local _dData := STOD("")
Local _aArea := GetArea()

DbSelectArea("SE1")
DbSetOrder(1)
if DbSeek(SE3->(E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO))
    _dData:= SE1->E1_EMISSAO
endif

RestArea(_aArea)

Return _dData

/*/{Protheus.doc} User Function GTUATPFR
    (Gatilho no campo UA_TPFRETE para atualizar o percentual de desconto de frete caso enquadrado na regra)
    @type  Function
    @author user
    @since 13/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function GTUATPFR()
Local _nDescFr:= 0
Local nLine, _nVTot
Local _nVlMinDF:= 0
Local _nVlDF:= 0

_nVTot:= 0

if cFilAnt=="0301" .and. M->UA_TPFRETE=="F"
    _nVlMinDF:= SuperGetMV("VLMINDESFR",.F., 5000) //Valor minimo para desconto de frete em PZ 5000
    _nVlDF:= SuperGetMV("VLDESFRT",.F., 4.5) //Valor de desconto de frete em PZ 4.5

    For nLine := 1 To Len(aCols)
        If !GDDeleted(nLine)
            _nVTot += GDFieldGet("UB_VLRITEM", nLine)
        EndIf
    Next nLine

    if _nVTot >= _nVlMinDF
        _nDescFr := _nVlDF
    endif
elseif cFilAnt$"0101/0201" .and. M->UA_ZDESCES==0
    _nVlDF := M->UA_ZDESCFR
endif

    M->UA_ZDESCFR:= _nDescFr
    Eval(bRefresh)
    Eval(bFolderRefresh)
    if !IsInCallStack("U_CALCDESC")
        U_MTXRecVal()
    endif
Return _nDescFr
