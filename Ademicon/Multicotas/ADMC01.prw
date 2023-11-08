#include "totvs.ch"

/*/{Protheus.doc} admccom
Processo de compra de cota MC
@type function
@version 1.0
@author Pedro
@since 21/10/2023
@param aParm, array, 
        1 - cEmpresa
        2 - cFilial
        3 - nRecZ11
@return variant, fixo nulo
/*/
user function adMCcom(aParm)
	Local lEnv := .t. as Logical
    local cNaturez as Character
    local cE2_CCD  := "101001" as Character
    local cE2_ITEMD := "0001" as Character
    local cE2_CLVLDB as Character 
    local aVetSE2 as array
    local cProc as Character
    local cError as Character
    local aLog as array
    local lError := .f. as logical
	local oObjLog   := LogSMS():new()
    local oObjParm  := JsonObject():New() as Object
    local cParam as character
    local xRet

	private lAutoErrNoFile := .T.
	private lMsErroAuto := .F.

	oObjLog:setFileName("\temp\"+procname()+"_"+dtos(date())+".txt")
	oObjLog:saveMsg("================")

    if select("SX2") = 0 
        RPCSetType(3)
        lEnv := RPCSetEnv(aParm[1], aParm[2])
    endif
	If lEnv
        dbSelectArea("Z11")
        Z11->(dbGoTo(aParm[3]))
        cProc   := padl(alltrim(Z11->Z11_IDPROC), GetSx3Cache("E2_NUM","X3_TAMANHO"), "0")
        oObjLog:saveMsg("Processo: "+cProc)
        // TODO gerar conta a pagar para o cliente 
		if !empty(Z11->Z11_DOCTIT) .and. Z11->Z11_STCOMP == "00"
            if empty(cParam := trim(GetMv("AD_OBJCOM",,"")))
                lError := .t.
                cError:="Error: Parametro AD_OBJCOM ["+cParam+"] nao e um JSON valido."
                oObjLog:saveMsg(cError)
            else
                xRet := oObjParm:fromJSON(cParam)
                if ValType(xRet) <> "U"
                    lError := .t.
                    cError:="Error: Parametro AD_OBJCOM ["+cParam+"] nao e um JSON valido."
                    oObjLog:saveMsg(cError)
                else
                    DbSelectArea('SA2')
                    SA2->(dbSetOrder(3))  // A2_FILIAL+A2_CGC

                    If SA2->(DbSeek(xFilial('SA2')+trim(Z11->Z11_DOCTIT)))
                        cNaturez := oObjParm["natureza"]  // Multicota Nat Compra
                        cE2_CCD := oObjParm["ccd"]    // MultiCotas CC Compra
                        cE2_ITEMD := oObjParm["itemd"]   // MultiCotas Item de Compra
                        cE2_CLVLDB := "F"+SA2->A2_COD+SA2->A2_LOJA
                        aVetSE2 := {}
                        // aadd(aVetSE2, {"E2_FILIAL" , cFilTit                , Nil})
                        aadd(aVetSE2, {"E2_NUM"    , cProc                   , Nil})
                        aadd(aVetSE2, {"E2_PREFIXO", "MCC"                   , Nil})
                        aadd(aVetSE2, {"E2_PARCELA", "  "                    , Nil})
                        aadd(aVetSE2, {"E2_TIPO"   , "DP "                   , Nil})
                        aadd(aVetSE2, {"E2_NATUREZ", cNaturez               , Nil})
                        aadd(aVetSE2, {"E2_FORNECE", SA2->A2_COD            , Nil})
                        aadd(aVetSE2, {"E2_LOJA"   , SA2->A2_LOJA           , Nil})
                        aadd(aVetSE2, {"E2_NOMFOR" , SA2->A2_NREDUZ         , Nil})
                        aadd(aVetSE2, {"E2_EMISSAO", dDataBase               , Nil})
                        aadd(aVetSE2, {"E2_VENCTO" , (dDataBase+max(2, Z11->Z11_PRZC))                , Nil})
                        aadd(aVetSE2, {"E2_VENCREA", DataValida((dDataBase+max(2, Z11->Z11_PRZC)),.T.), Nil})
                        aadd(aVetSE2, {"E2_VALOR"  , Z11->Z11_VLICOM        , Nil})
                        aadd(aVetSE2, {"E2_HIST"   , "G:"+trim(Z11->Z11_GRUPO)+", C:"+trim(Z11->Z11_COTA)         , Nil})
                        aadd(aVetSE2, {"E2_MOEDA"  , 1                      , Nil})
                        aadd(aVetSE2, {"E2_CCD"    , cE2_CCD          , Nil})
                        aadd(aVetSE2, {"E2_ITEMD"  , cE2_ITEMD        , Nil})
                        aadd(aVetSE2, {"E2_CLVLDB" , cE2_CLVLDB       , Nil})
                        aadd(aVetSE2, {"E2_IDFLUIG" , cProc       , Nil})
                        aadd(aVetSE2, {"E2_XPROCES" , cProc      , Nil})
                        //Chama a rotina automática
                        lMsErroAuto := .F.
                        lAutoErrNoFile := .T.
                        MSExecAuto({|x,y| FINA050(x,y)}, aVetSE2, 3)

                        //Se houve erro, mostra o erro ao usuário e desarma a transação
                        If lMsErroAuto
                            cError := "Error: "
                            aLog  := GetAutoGRLog() 
                            aeval(aLog, {|x| cError += x+CRLF})
                            oObjLog:saveMsg( ;
                                    + varInfo("aVetSE2",aVetSE2, , .f., .f.) + CRLF  ;
                                    + cError )  
                            lError := .t.
                        EndIf
                    else
                        lError := .t.
                        cError:="Error: Rec "+cValToChar(Z11->(recno()))+", CPF/CNPJ "+Z11->Z11_DOCTIT+" nao localizado."
                        oObjLog:saveMsg(cError)
                    endif
                endif
			endif
		ELSE
            lError := .t.
			cError:="Error: Rec "+cValToChar(Z11->(recno()))+", CPF/CNPJ nao preenchido."
			oObjLog:saveMsg(cError)
		ENDIF

        if !lError
            RecLock("Z11", .f.)
            Z11->Z11_STCOMP := "01"
			Z11->Z11_JSONHI := Z11->Z11_JSONHI+dtos(date())+" - "+time()+" emitido cp compra."+CRLF 
            Z11->(MsUnlock())
        endif

        // TODO gerar comissao de compra 
        if !lError .and. Z11->Z11_STCOMP == "01"
            comCompra(cProc, oObjLog:getFileName(), @lError)
        endif

        if !lError .and. Z11->Z11_STCOMP == "02"
            pgtoPonCom(cProc, oObjLog:getFileName(), @lError)
        endif

    endif
return nil


/*/{Protheus.doc} comCompra
Gerar comissao de compra da Z11 (deve estar posiconado)
@type function
@version 1.0
@author Pedro
@since 21/10/2023
@param cProc, character, numero do processo
@param cArqLog, character, nome do arquivo de log
@param lError, logical, se .t. tem erro, .f. cc
@return variant, fixo nulo
/*/
static function comCompra(cProc, cArqLog, lError)
    local cNaturez as Character
    local cE2_CCD  := "101001" as Character
    local cE2_ITEMD := "0001" as Character
    local cE2_CLVLDB as Character 
    local aVetSE2 as array
    // local nInd as numeric
    // local nSomaCom as numeric
    local aTitGer := {} as array
    local nIndTit as numeric
    local nValor as numeric
    local nBase as numeric
	local oObjLog   := LogSMS():new() as Object
    // local oObjCom := JsonObject():New() as Object
    local aCamVal := {"Z11_VCCCAU", "Z11_VCCCGE", "Z11_VCCCLI", "Z11_VCCCRE"} as array
    local aCamIds := {"Z11_IDCCAU", "Z11_IDCCGE", "Z11_IDCCLI", "Z11_IDCCRE"} as array
    local nIndCam as numeric
    // local aPessoas as array
    // local nIndPess as numeric
    local cCampos as character
    // local aDivisao as array
    local cParcela as character
    local cPrefixo := "CMC" as character
    local nPrazo
    local oObjParm   := JsonObject():New() as Object
    local xRet
    local cParam as character
    private cMatCom 
	private lAutoErrNoFile := .T.
	private lMsErroAuto := .F.

    oObjLog:setFileName(cArqLog)
    oObjLog:saveMsg("Gerando comissoes")
    for nIndCam := 1 to len(aCamVal)
        if !empty(Z11->(fieldGet(fieldPos(aCamVal[nIndCam])))) ;
                    .and. !empty(Z11->(fieldGet(fieldPos(aCamIds[nIndCam]))))
            cCampos := Z11->(fieldGet(fieldPos(aCamIds[nIndCam])))
            nBase := Z11->(fieldGet(fieldPos(aCamVal[nIndCam])))
            cParcela := space(GetSX3Cache("E2_PARCELA", "X3_TAMANHO"))
            divCom(cCampos, nBase, 0, cParcela, .t., @aTitGer)
            // aPessoas := strtokarr2(cCampos, "},")
            // aDivisao := {}
            // nSomaCom := 0.00
            // for nIndPess := 1 to len(aPessoas)
            //     if ! (right(aPessoas[nIndPess], 1) == "}")
            //         cCampos := aPessoas[nIndPess]+"}"
            //     else
            //         cCampos := aPessoas[nIndPess]
            //     endif
            //     oObjCom:FromJson(cCampos)
            //     nSomaCom += val(oObjCom["per"])
            //     aadd(aDivisao, {oObjCom["doc"], val(oObjCom["per"])})
            // next
            // nBase := Z11->(fieldGet(fieldPos(aCamVal[nIndCam])))
            // for nInd := 1 to len(aDivisao)
            //     cMatCom := aDivisao[nInd][1]
            //     nValor  := nBase * (aDivisao[nInd][2] / nSomaCom)
            //     if nValor > 0
            //         if empty(nIndTit := ascan(aTitGer, {|x| x[1] == cMatCom}))
            //             aadd(aTitGer, {cMatCom, 0.00, 0, space(GetSX3Cache("E2_PARCELA", "X3_TAMANHO"))})
            //             nIndTit := len(aTitGer)
            //         endif
            //         aTitGer[nIndTit, 2] += nValor
            //     endif
            // next
        endif
    next
    // TODO comissao do adicional de prazo para o autorizado
    if !empty(Z11->Z11_VADPRZ) .and. !empty(Z11->Z11_PRZC) .and. !empty(Z11->Z11_IDCCAU)
        cCampos := strtran(strtran(trim(Z11->Z11_IDCCAU),"[",""),"]","")
        nBase := Z11->Z11_VADPRZ
        cParcela := pad("1", GetSX3Cache("E2_PARCELA", "X3_TAMANHO"))
        divCom(cCampos, nBase, Z11->Z11_PRZC, cParcela, .f., @aTitGer)
        // aPessoas := strtokarr2(cCampos, "},")
        // aDivisao := {}
        // nSomaCom := 0.00
        // for nIndPess := 1 to len(aPessoas)
        //     if ! (right(aPessoas[nIndPess], 1) == "}")
        //         cCampos := aPessoas[nIndPess]+"}"
        //     else
        //         cCampos := aPessoas[nIndPess]
        //     endif
        //     oObjCom:FromJson(cCampos)
        //     nSomaCom += val(oObjCom["per"])
        //     aadd(aDivisao, {oObjCom["doc"], val(oObjCom["per"])})
        // next
        // for nInd := 1 to len(aDivisao)
        //     cMatCom := aDivisao[nInd][1]
        //     nValor  := nBase * (aDivisao[nInd][2] / nSomaCom)
        //     if nValor > 0
        //         aadd(aTitGer, {cMatCom, nValor, Z11->Z11_PRZC, pad("1", GetSX3Cache("E2_PARCELA", "X3_TAMANHO"))})
        //     endif
        // next
    endif
    //  Gerar titulos de comissao a pagar
    if len(aTitGer) > 0
        if empty(cParam := trim(GetMv("AD_OBJCRE",,"")))
            lError := .t.
            cError:="Error: Parametro AD_OBJCRE ["+cParam+"] nao e um JSON valido."
            oObjLog:saveMsg(cError)
        else
            xRet := oObjParm:fromJSON(cParam)
            if ValType(xRet) <> "U"
                lError := .t.
                cError:="Error: Parametro AD_OBJCRE ["+cParam+"] nao e um JSON valido."
                oObjLog:saveMsg(cError)
            else
                cNaturez := oObjParm["natureza"]
                cE2_CCD  := oObjParm["ccd"] // MultiCotas CC Comissoes 
                cE2_ITEMD:= oObjParm["itemd"] // MultiCotas Item Comissoes

                for nIndTit := 1 to len(aTitGer)
                    cMatCom  := aTitGer[nIndTit, 1]
                    nValor   := aTitGer[nIndTit, 2]
                    nPrazo   := aTitGer[nIndTit, 3]
                    cParcela := aTitGer[nIndTit, 4]
                    DbSelectArea('SA2')
                    SA2->(dbSetOrder(3))  // A2_FILIAL+A2_CGC

                    If SA2->(DbSeek(xFilial('SA2')+trim(cMatCom)))
                        // TODO se ja foi gerada a comissao ignora
                        
                        SE2->(dbSetOrder(6)) // 6	E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
                        if !SE2->(dbSeek(xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefixo+cProc+cParcela+"DP "))
                            cE2_CLVLDB := "F"+SA2->A2_COD+SA2->A2_LOJA
                            aVetSE2 := {}
                            // aadd(aVetSE2, {"E2_FILIAL" , cFilTit                , Nil})
                            aadd(aVetSE2, {"E2_NUM"    , cProc                   , Nil})
                            aadd(aVetSE2, {"E2_PREFIXO", cPrefixo                , Nil})
                            aadd(aVetSE2, {"E2_PARCELA", cParcela                , Nil})
                            aadd(aVetSE2, {"E2_TIPO"   , "DP "                   , Nil})
                            aadd(aVetSE2, {"E2_NATUREZ", cNaturez               , Nil})
                            aadd(aVetSE2, {"E2_FORNECE", SA2->A2_COD            , Nil})
                            aadd(aVetSE2, {"E2_LOJA"   , SA2->A2_LOJA           , Nil})
                            aadd(aVetSE2, {"E2_NOMFOR" , SA2->A2_NREDUZ         , Nil})
                            aadd(aVetSE2, {"E2_EMISSAO", dDataBase               , Nil})
                            aadd(aVetSE2, {"E2_VENCTO" , (dDataBase+nPrazo)                , Nil})
                            aadd(aVetSE2, {"E2_VENCREA", DataValida((dDataBase+nPrazo),.T.), Nil})
                            aadd(aVetSE2, {"E2_VALOR"  , nValor          , Nil})
                            aadd(aVetSE2, {"E2_HIST"   , "Com Com. G:"+trim(Z11->Z11_GRUPO)+", C:"+trim(Z11->Z11_COTA)         , Nil})
                            aadd(aVetSE2, {"E2_MOEDA"  , 1                      , Nil})
                            aadd(aVetSE2, {"E2_CCD"    , cE2_CCD          , Nil})
                            aadd(aVetSE2, {"E2_ITEMD"  , cE2_ITEMD        , Nil})
                            aadd(aVetSE2, {"E2_CLVLDB" , cE2_CLVLDB       , Nil})
                            aadd(aVetSE2, {"E2_IDFLUIG" , cProc       , Nil})
                            aadd(aVetSE2, {"E2_XPROCES" , cProc      , Nil})
                            //Chama a rotina automática
                            lMsErroAuto := .F.
                            lAutoErrNoFile := .T.
                            MSExecAuto({|x,y| FINA050(x,y)}, aVetSE2, 3)

                            //Se houve erro, mostra o erro ao usuário e desarma a transação
                            If lMsErroAuto
                                cError := "Error: Comissao "
                                aLog  := GetAutoGRLog() 
                                aeval(aLog, {|x| cError += x+CRLF})
                                oObjLog:saveMsg( ;
                                        + varInfo("aVetSE2",aVetSE2, , .f., .f.) + CRLF  ;
                                        + cError )  
                                lError := .t.
                            EndIf
                        else
                            oObjLog:saveMsg("Comissoes: titulo ja encontrado: "+;
                                xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefixo+cProc+cParcela+"DP "+;
                                ", recno: "+cValToChar(SE2->(recno())))
                        EndIf
                    else
                        lError := .t.
                        cError:="Error: Comissao Rec "+cValToChar(Z11->(recno()))+", CPF/CNPJ "+cMatCom+" nao localizado."
                        oObjLog:saveMsg(cError)
                    endif
                next
            endif
        endif
    endif
    if !lError
        RecLock("Z11", .f.)
        Z11->Z11_STCOMP := "02"
        Z11->Z11_JSONHI := Z11->Z11_JSONHI+dtos(date())+" - "+time()+" emitido cp compra."+CRLF 
        Z11->(MsUnlock())
    endif
return nil


/*/{Protheus.doc} divCom
Divisao de comissao entre varias pessoas em varios niveis
@type function
@version 1.0
@author Pedro
@since 25/10/2023
@param cCampos, character, JSON da divisao de pessoas do nivel (Autorizado, Gestor, Licenciado, Regional)
@param nBase, numeric, valor base para dividir no nivel
@param nPrazo, numeric, prazo para pgto. do titulo
@param cParcela, character, parcela a ser gerada
@param lBusca, logical, se faz a busca no array aTitGer para acumular ou insere outra linha
@param aTitGer, array, array a ser alterado/incluido que vai conter 
    [n][1] -> CPF/CNPJ do comissionado
    [n][2] -> valor rateado para o comissionado
    [n][3] -> prazo para vcto do titulo
    [n][4] -> numero da parcela a ser gerada
@return variant, fixo nulo
/*/
static function divCom(cCampos, nBase, nPrazo, cParcela, lBusca, aTitGer)
    local aDivisao := {} as array
    local nSomaCom := 0.00 as numeric
    local nInd as numeric
    local aPessoas := {} as array
    local oObjCom := JsonObject():New() as Object
    local cMatCom as character
    local nValor as numeric
    local nIndTit as numeric

    default nPrazo   := 0
    default cParcela := space(GetSX3Cache("E2_PARCELA", "X3_TAMANHO"))
    default lBusca   := .t.

    cCampos := strtran(strtran(trim(cCampos),"[",""),"]","")
    aPessoas := strtokarr2(cCampos, "},")
    aDivisao := {}
    nSomaCom := 0.00
    for nInd := 1 to len(aPessoas)
        if ! (right(aPessoas[nInd], 1) == "}")
            cCampos := aPessoas[nInd]+"}"
        else
            cCampos := aPessoas[nInd]
        endif
        oObjCom:FromJson(cCampos)
        nSomaCom += val(oObjCom["per"])
        aadd(aDivisao, {oObjCom["doc"], val(oObjCom["per"])})
    next
    for nInd := 1 to len(aDivisao)
        cMatCom := aDivisao[nInd][1]
        nValor  := nBase * (aDivisao[nInd][2] / nSomaCom)
        if nValor > 0
            if !lBusca .or. empty(nIndTit := ascan(aTitGer, {|x| x[1] == cMatCom}))
                aadd(aTitGer, {cMatCom, 0.00, nPrazo, cParcela})
                nIndTit := len(aTitGer)
            endif
            aTitGer[nIndTit, 2] += nValor
        endif
    next
return

/*/{Protheus.doc} pgtoPonCom
Pagamento de pontos na compra da Z11 (deve estar posiconado)
@type function
@version 1.0
@author Pedro
@since 21/10/2023
@param cProc, character, numero do processo
@param cArqLog, character, nome do arquivo de log
@param lError, logical, se .t. tem erro, .f. cc
@return variant, fixo nulo
/*/
static function pgtoPonCom(cProc, cArqLog, lError)
    local cNaturez as Character
    local cE2_CCD  := "101001" as Character
    local cE2_ITEMD := "0001" as Character
    local cE2_CLVLDB as Character 
    local aVetSE2 as array
    local nValor as numeric
	local oObjLog   := LogSMS():new() as Object
    local oObjParm   := JsonObject():New() as Object
    local cParcela as character
    local cPrefixo  := "PPC" as character
    local nPrazo
    local xRet
    local cParam as character
    // local nTxPon := GetMV("AD_VLRPON",,0.04) as numeric
    private cMatCom 
	private lAutoErrNoFile := .T.
	private lMsErroAuto := .F.

    oObjLog:setFileName(cArqLog)
    oObjLog:saveMsg("Gerando pagamento de pontos")
    //  Gerar 
    if !empty(cParam := trim(GetMv("AD_OBJPON",,"")))
        xRet := oObjParm:fromJSON(cParam)
        if ValType(xRet) <> "U"
            lError := .t.
            cError:="Error: Parametro AD_OBJPON ["+cParam+"] nao e um JSON valido."
            oObjLog:saveMsg(cError)
        else
            cMatCom  := oObjParm["cnpj"]
            nValor   := (Z11->Z11_VCPCAU + Z11->Z11_VCPCGE + Z11->Z11_VCPCLI + Z11->Z11_VCPCRE)
            nPrazo   := 0
            cParcela := space(GetSX3Cache("E2_PARCELA", "X3_TAMANHO"))
            DbSelectArea('SA2')
            SA2->(dbSetOrder(3))  // A2_FILIAL+A2_CGC

            If SA2->(DbSeek(xFilial('SA2')+trim(cMatCom)))
                // TODO se ja foi gerada os pontos ignora
                
                SE2->(dbSetOrder(6)) // 6	E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
                if !SE2->(dbSeek(xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefixo+cProc+cParcela+"DP "))
                    cNaturez := oObjParm["natureza"]
                    cE2_CCD  := oObjParm["ccd"]
                    cE2_ITEMD:= oObjParm["itemd"]
                    cE2_CLVLDB := "F"+SA2->A2_COD+SA2->A2_LOJA
                    aVetSE2 := {}
                    // aadd(aVetSE2, {"E2_FILIAL" , cFilTit                , Nil})
                    aadd(aVetSE2, {"E2_NUM"    , cProc                   , Nil})
                    aadd(aVetSE2, {"E2_PREFIXO", cPrefixo                , Nil})
                    aadd(aVetSE2, {"E2_PARCELA", cParcela                , Nil})
                    aadd(aVetSE2, {"E2_TIPO"   , "DP "                   , Nil})
                    aadd(aVetSE2, {"E2_NATUREZ", cNaturez               , Nil})
                    aadd(aVetSE2, {"E2_FORNECE", SA2->A2_COD            , Nil})
                    aadd(aVetSE2, {"E2_LOJA"   , SA2->A2_LOJA           , Nil})
                    aadd(aVetSE2, {"E2_NOMFOR" , SA2->A2_NREDUZ         , Nil})
                    aadd(aVetSE2, {"E2_EMISSAO", dDataBase               , Nil})
                    aadd(aVetSE2, {"E2_VENCTO" , (dDataBase+nPrazo)                , Nil})
                    aadd(aVetSE2, {"E2_VENCREA", DataValida((dDataBase+nPrazo),.T.), Nil})
                    aadd(aVetSE2, {"E2_VALOR"  , nValor          , Nil})
                    aadd(aVetSE2, {"E2_HIST"   , "Pontos G:"+trim(Z11->Z11_GRUPO)+", C:"+trim(Z11->Z11_COTA)         , Nil})
                    aadd(aVetSE2, {"E2_MOEDA"  , 1                      , Nil})
                    aadd(aVetSE2, {"E2_CCD"    , cE2_CCD          , Nil})
                    aadd(aVetSE2, {"E2_ITEMD"  , cE2_ITEMD        , Nil})
                    aadd(aVetSE2, {"E2_CLVLDB" , cE2_CLVLDB       , Nil})
                    aadd(aVetSE2, {"E2_IDFLUIG" , cProc       , Nil})
                    aadd(aVetSE2, {"E2_XPROCES" , cProc      , Nil})
                    //Chama a rotina automática
                    lMsErroAuto := .F.
                    lAutoErrNoFile := .T.
                    MSExecAuto({|x,y| FINA050(x,y)}, aVetSE2, 3)

                    //Se houve erro, mostra o erro ao usuário e desarma a transação
                    If lMsErroAuto
                        cError := "Error: Pontos "
                        aLog  := GetAutoGRLog() 
                        aeval(aLog, {|x| cError += x+CRLF})
                        oObjLog:saveMsg( ;
                                + varInfo("aVetSE2",aVetSE2, , .f., .f.) + CRLF  ;
                                + cError )  
                        lError := .t.
                    EndIf
                else
                    oObjLog:saveMsg("Pontos: titulo ja encontrado: "+;
                        xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefixo+cProc+cParcela+"DP "+;
                        ", recno: "+cValToChar(SE2->(recno())))
                EndIf
            else
                lError := .t.
                cError:="Error: Pontos Rec "+cValToChar(Z11->(recno()))+", CPF/CNPJ "+cMatCom+" nao localizado."
                oObjLog:saveMsg(cError)
            endif
        endif
    else
        oObjLog:saveMsg("Pontos: Rec "+cValToChar(Z11->(recno()))+" sem o parametro AD_OBJPON configurado")
    endif
    if !lError
        RecLock("Z11", .f.)
        Z11->Z11_STCOMP := "99"  // Finalizado
        Z11->Z11_JSONHI := Z11->Z11_JSONHI+dtos(date())+" - "+time()+" emitido pgto. de pontos."+CRLF 
        Z11->(MsUnlock())
    endif
return nil


/*/{Protheus.doc} adMCven
Processo de venda de cota MC
@type function
@version 1.0
@author Pedro
@since 21/10/2023
@param aParm, array, 
        1 - cEmpresa
        2 - cFilial
        3 - nRecZ11
@return variant, fixo nulo
/*/
user function adMCven(aParm)
	Local lEnv := .t. as Logical
    local cNaturez as Character
    local cE1_CCC  := "" as Character
    local cE1_ITEMC := "0001" as Character
    local cE1_CLVLCR := "" as Character 
    local cE1_CLVLDB := "" as Character 
    local aVetSE1 as array
    local cProc as Character
    local cError as Character
    local aLog as array
	//local dEmissao := dDataBase as date
	local dEmissao := date()
	//local dVencto  := dDataBase+3 as date
	local dVencto  := date()+3
    local lError := .f. as logical
    local nValor := 0.00 as numeric
	local oObjLog   := LogSMS():new()

	private lAutoErrNoFile := .T.
	private lMsErroAuto := .F.

	oObjLog:setFileName("\temp\"+procname()+"_"+dtos(date())+".txt")
	oObjLog:saveMsg("================")

    if select("SX2") = 0 
        RPCSetType(3)
        lEnv := RPCSetEnv(aParm[1], aParm[2])
    endif
  
	If lEnv        
        
        dbSelectArea("Z11")
        Z11->(dbGoTo(aParm[3]))
        cProc   := padl(alltrim(Z11->Z11_IDPROV), GetSx3Cache("E1_NUM","X3_TAMANHO"), "0")
        oObjLog:saveMsg("Processo: "+cProc)
        // TODO gerar conta a receber para o fornecedor
		if !empty(Z11->Z11_DOCDES) .and. Z11->Z11_STVEND == "00"
            
			DbSelectArea('SA1')
			SA1->(dbSetOrder(3))  // A1_FILIAL+A1_CGC

			If SA1->(DbSeek(xFilial('SA1')+trim(Z11->Z11_DOCDES)))
				cNaturez := SA1->A1_NATUREZ
				if empty(cNaturez)
					cNaturez := GetMv("AD_ANTNATU",,"")
				endif
                if empty(cE1_CLVLCR)
                    //cE1_CLVLCR := GetMv("AD_ANTCLVC",,"")
                    cE1_CLVLCR := "C"+SA1->A1_COD+SA1->A1_LOJA
                endif
                if empty(cE1_CLVLDB)
                    //cE1_CLVLDB := GetMv("AD_ANTCLVD",,"")
                    cE1_CLVLDB := "C"+SA1->A1_COD+SA1->A1_LOJA
                endif
                nValor := Z11->Z11_VBRVEN
                if lower(Z11->Z11_TIPOPE) == 'vendalp'
                    // Acrescentar ao valor cobrado de leilao premium a taxa de servico lp
                    nValor += Z11->Z11_VALLPR
                elseif lower(Z11->Z11_TIPOPE) == 'vendals'
                    // Acrescentar ao valor cobrado de leilao standard a taxa de intermediacao
                    nValor += Z11->Z11_VALTXU
                endif
				//Prepara o array para o execauto
               
				aVetSE1 := {}
				aadd(aVetSE1, {"E1_NUM"    , cProc                   , Nil})
				aadd(aVetSE1, {"E1_PREFIXO", "MCV"               , Nil})
				aadd(aVetSE1, {"E1_PARCELA", " "      , Nil})
				aadd(aVetSE1, {"E1_TIPO"   , "DP "                  , Nil})
				aadd(aVetSE1, {"E1_NATUREZ", cNaturez               , Nil})
				aadd(aVetSE1, {"E1_CLIENTE", SA1->A1_COD            , Nil})
				aadd(aVetSE1, {"E1_LOJA"   , SA1->A1_LOJA           , Nil})
				aadd(aVetSE1, {"E1_NOMCLI" , SA1->A1_NREDUZ         , Nil})
				aadd(aVetSE1, {"E1_EMISSAO", dEmissao               , Nil})
				aadd(aVetSE1, {"E1_VENCTO" , dVencto                , Nil})
				aadd(aVetSE1, {"E1_VENCREA", DataValida(dVencto,.T.), Nil})
				aadd(aVetSE1, {"E1_VALOR"  , nValor         , Nil})
				aadd(aVetSE1, {"E1_MOEDA"  , 1                      , Nil})
				aadd(aVetSE1, {"E1_CCC"    , cE1_CCC          , Nil})
				aadd(aVetSE1, {"E1_ITEMC"  , cE1_ITEMC        , Nil})
				aadd(aVetSE1, {"E1_CLVLDB" , cE1_CLVLDB       , Nil})
				aadd(aVetSE1, {"E1_CLVLCR" , cE1_CLVLCR       , Nil})
				aadd(aVetSE1, {"E1_IDFLUIG" , cProc       , Nil})
				aadd(aVetSE1, {"E1_XPROCES" , cProc       , Nil})
				//Chama a rotina automática
				lMsErroAuto := .F.
				lAutoErrNoFile := .T.
                MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 3)
  
                //Se houve erro, mostra o erro ao usuário e desarma a transação
                If lMsErroAuto
                   
                    cError := "Error: "
                    aLog  := GetAutoGRLog() 
                    aeval(aLog, {|x| cError += x+CRLF})
                    oObjLog:saveMsg( ;
                            + varInfo("aVetSE1",aVetSE1, , .f., .f.) + CRLF  ;
                            + cError )  
                    lError := .t.
                else
                     
                     ConOut( ' Z11->Z11_IDPROC -> ' + Z11->Z11_IDPROC)
                    // Atualizar Status para boleto emitido
                    RecLock("Z11", .f.)
                    Z11->Z11_STVEND := "01"
        			Z11->Z11_JSONHI := Z11->Z11_JSONHI+dtos(date())+" - "+time()+" emitido boleto cliente."+CRLF 
                    Z11->(MsUnlock())
                    // TODO imprimir boleto
                EndIf
            else
                lError := .t.
				cError:="Error: Rec "+cValToChar(Z11->(recno()))+", CPF/CNPJ "+Z11->Z11_DOCDES+" nao localizado."
				oObjLog:saveMsg(cError)
			endif
		ELSE
            lError := .t.
			cError:="Error: Rec "+cValToChar(Z11->(recno()))+", CPF/CNPJ nao preenchido."
			oObjLog:saveMsg(cError)
		ENDIF
    endif
return

/*/{Protheus.doc} adMCti
Gerar comissao a partir da baixa de titulo 
@type function
@version 1,9
@author Pedro
@since 21/10/2023
@param aParm, array, 
        1 - cEmpresa
        2 - cFilial
        3 - nRecSE1
@return variant, fixo nulo
/*/
user function adMCti(aParm)
    // TODO Verifiar se gera comissao a partir da baixa de titulo 
	local oObjLog   := LogSMS():new()
    local cProc
    local lError := .f.
    local lEnv := .t. as logical

	oObjLog:setFileName("\temp\"+procname()+"_"+dtos(date())+".txt")
	oObjLog:saveMsg("================")
    if select("SX2") = 0 
        RPCSetType(3)
        lEnv := RPCSetEnv(aParm[1], aParm[2])
    endif
	If lEnv
        dbSelectArea("SE1")
        SE1->(dbGoTo(aParm[3]))
        cProc := SE1->E1_NUM
        Z11->(dbSetOrder(3)) // Z11_FILIAL+Z11_IDPROV
        Z11->(dbSeek(xFilial("Z11")+cProc))
        if Z11->Z11_STVEND == "01"
            // TODO gerar comissao de venda
            comVenda(cProc, oObjLog:getFileName(), @lError)
        endif
        if Z11->Z11_STVEND == "02"
            // TODO gerar pagamento de pontos
            pgtPonVen(cProc, oObjLog:getFileName(), @lError)
        endif
        if Z11->Z11_STVEND == "03"
            // TODO gerar pagamento de parcelas atrasadas
            pgtAtras(cProc, oObjLog:getFileName(), @lError)
        endif
        if Z11->Z11_STVEND == "04"
            // TODO gerar pagamento do leilao standard
            pgtLeilao(cProc, oObjLog:getFileName(), @lError)
        endif
    endif
return


/*/{Protheus.doc} comVenda
Gerar comissao de venda da Z11 (deve estar posiconado)
@type function
@version 1.0
@author Pedro
@since 21/10/2023
@param cProc, character, numero do processo
@param cArqLog, character, nome do arquivo de log
@param lError, logical, se .t. tem erro, .f. cc
@return variant, fixo nulo
/*/
static function comVenda(cProc, cArqLog, lError)
    local cNaturez as Character
    local cE2_CCD  := "101001" as Character
    local cE2_ITEMD := "0001" as Character
    local cE2_CLVLDB as Character 
    local aVetSE2 as array
    // local nInd as numeric
    // local nSomaCom as numeric
    local aTitGer := {} as array
    local nIndTit as numeric
    local nValor as numeric
    local nBase as numeric
	local oObjLog := LogSMS():new() as Object
    // local oObjCom := JsonObject():New() as Object
    local aCamVal := {"Z11_VCVCAU", "Z11_VCVCGE", "Z11_VCVCLI", "Z11_VCVCRE"} as array
    local aCamIds := {"Z11_IDVCAU", "Z11_IDVCGE", "Z11_IDVCLI", "Z11_IDVCRE"} as array
    local nIndCam as numeric
    // local aPessoas as array
    // local nIndPess as numeric
    local cCampos as character
    // local aDivisao as array
    local cParcela as character
    local cPrefixo := "CMC" as character
    local nPrazo
    local cError as character
    local oObjParm   := JsonObject():New() as Object
    local cParam as character
    local xRet
    private cMatCom 
	private lAutoErrNoFile := .T.
	private lMsErroAuto := .F.

    oObjLog:setFileName(cArqLog)
    oObjLog:saveMsg("Gerando comissoes")
    if lower(Z11->Z11_TIPOPE) = "vendals"
        // Venda leilao standard - paga comissao compra e venda
        aCamVal := { "Z11_VCCCAU", "Z11_VCCCGE", "Z11_VCCCLI", "Z11_VCCCRE", ;
                         "Z11_VCVCAU", "Z11_VCVCGE", "Z11_VCVCLI", "Z11_VCVCRE"}
        aCamIds := { "Z11_IDCCAU", "Z11_IDCCGE", "Z11_IDCCLI", "Z11_IDCCRE",;
                         "Z11_IDVCAU", "Z11_IDVCGE", "Z11_IDVCLI", "Z11_IDVCRE"}
    endif

    for nIndCam := 1 to len(aCamVal)
        if !empty(Z11->(fieldGet(fieldPos(aCamVal[nIndCam])))) ;
                    .and. !empty(Z11->(fieldGet(fieldPos(aCamIds[nIndCam]))))
            cCampos := Z11->(fieldGet(fieldPos(aCamIds[nIndCam])))
            nBase := Z11->(fieldGet(fieldPos(aCamVal[nIndCam])))
            cParcela := space(GetSX3Cache("E2_PARCELA", "X3_TAMANHO"))
            divCom(cCampos, nBase, 0, cParcela, .t., @aTitGer)

            // cCampos := strtran(strtran(trim(Z11->(fieldGet(fieldPos(aCamIds[nIndCam])))),"[",""),"]","")
            // aPessoas := strtokarr2(cCampos, "},")
            // aDivisao := {}
            // nSomaCom := 0.00
            // for nIndPess := 1 to len(aPessoas)
            //     if ! (right(aPessoas[nIndPess], 1) == "}")
            //         cCampos := aPessoas[nIndPess]+"}"
            //     else
            //         cCampos := aPessoas[nIndPess]
            //     endif
            //     oObjCom:FromJson(cCampos)
            //     nSomaCom += val(oObjCom["per"])
            //     aadd(aDivisao, {oObjCom["doc"], val(oObjCom["per"])})
            // next
            // nBase := Z11->(fieldGet(fieldPos(aCamVal[nIndCam])))
            // for nInd := 1 to len(aDivisao)
            //     cMatCom := aDivisao[nInd][1]
            //     nValor  := nBase * (aDivisao[nInd][2] / nSomaCom)
            //     if nValor > 0
            //         if empty(nIndTit := ascan(aTitGer, {|x| x[1] == cMatCom}))
            //             aadd(aTitGer, {cMatCom, 0.00, 0, space(GetSX3Cache("E2_PARCELA", "X3_TAMANHO"))})
            //             nIndTit := len(aTitGer)
            //         endif
            //         aTitGer[nIndTit, 2] += nValor
            //     endif
            // next
        endif
    next
    //  Gerar titulos de comissao a pagar
    if len(aTitGer) > 0
        if empty(cParam := trim(GetMv("AD_OBJCRE",,"")))
            lError := .t.
            cError:="Error: Parametro AD_OBJCRE ["+cParam+"] nao e um JSON valido."
            oObjLog:saveMsg(cError)
        else
            xRet := oObjParm:fromJSON(cParam)
            if ValType(xRet) <> "U"
                lError := .t.
                cError:="Error: Parametro AD_OBJCRE ["+cParam+"] nao e um JSON valido."
                oObjLog:saveMsg(cError)
            else
                cNaturez := oObjParm["natureza"]
                // if !empty(GetMv("AD_MCCCCC",,""))   // MultiCotas CC Comissoes 
                //     cE2_CCD := GetMv("AD_MCCCCC")
                // endif
                cE2_CCD := oObjParm["ccd"]
                // if !empty(GetMv("AD_MCITCC",,""))   // MultiCotas Item Comissoes
                //     cE2_ITEMD := GetMv("AD_MCITCC")
                // endif
                cE2_ITEMD := oObjParm["itemd"]

                for nIndTit := 1 to len(aTitGer)
                    cMatCom  := aTitGer[nIndTit, 1]
                    nValor   := aTitGer[nIndTit, 2]
                    nPrazo   := aTitGer[nIndTit, 3]
                    cParcela := aTitGer[nIndTit, 4]
                    DbSelectArea('SA2')
                    SA2->(dbSetOrder(3))  // A2_FILIAL+A2_CGC

                    If SA2->(DbSeek(xFilial('SA2')+trim(cMatCom)))
                        // TODO se ja foi gerada a comissao ignora
                        
                        SE2->(dbSetOrder(6)) // 6	E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
                        if !SE2->(dbSeek(xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefixo+cProc+cParcela+"DP "))
                            cE2_CLVLDB := "F"+SA2->A2_COD+SA2->A2_LOJA
                            aVetSE2 := {}
                            // aadd(aVetSE2, {"E2_FILIAL" , cFilTit                , Nil})
                            aadd(aVetSE2, {"E2_NUM"    , cProc                   , Nil})
                            aadd(aVetSE2, {"E2_PREFIXO", cPrefixo                , Nil})
                            aadd(aVetSE2, {"E2_PARCELA", cParcela                , Nil})
                            aadd(aVetSE2, {"E2_TIPO"   , "DP "                   , Nil})
                            aadd(aVetSE2, {"E2_NATUREZ", cNaturez               , Nil})
                            aadd(aVetSE2, {"E2_FORNECE", SA2->A2_COD            , Nil})
                            aadd(aVetSE2, {"E2_LOJA"   , SA2->A2_LOJA           , Nil})
                            aadd(aVetSE2, {"E2_NOMFOR" , SA2->A2_NREDUZ         , Nil})
                            aadd(aVetSE2, {"E2_EMISSAO", dDataBase               , Nil})
                            aadd(aVetSE2, {"E2_VENCTO" , (dDataBase+nPrazo)                , Nil})
                            aadd(aVetSE2, {"E2_VENCREA", DataValida((dDataBase+nPrazo),.T.), Nil})
                            aadd(aVetSE2, {"E2_VALOR"  , nValor          , Nil})
                            aadd(aVetSE2, {"E2_HIST"   , "Com Ven. G:"+trim(Z11->Z11_GRUPO)+", C:"+trim(Z11->Z11_COTA)         , Nil})
                            aadd(aVetSE2, {"E2_MOEDA"  , 1                      , Nil})
                            aadd(aVetSE2, {"E2_CCD"    , cE2_CCD          , Nil})
                            aadd(aVetSE2, {"E2_ITEMD"  , cE2_ITEMD        , Nil})
                            aadd(aVetSE2, {"E2_CLVLDB" , cE2_CLVLDB       , Nil})
                            aadd(aVetSE2, {"E2_IDFLUIG" , cProc       , Nil})
                            aadd(aVetSE2, {"E2_XPROCES" , cProc      , Nil})
                            //Chama a rotina automática
                            lMsErroAuto := .F.
                            lAutoErrNoFile := .T.
                            MSExecAuto({|x,y| FINA050(x,y)}, aVetSE2, 3)

                            //Se houve erro, mostra o erro ao usuário e desarma a transação
                            If lMsErroAuto
                                cError := "Error: Comissao "
                                aLog  := GetAutoGRLog() 
                                aeval(aLog, {|x| cError += x+CRLF})
                                oObjLog:saveMsg( ;
                                        + varInfo("aVetSE2",aVetSE2, , .f., .f.) + CRLF  ;
                                        + cError )  
                                lError := .t.
                            EndIf
                        else
                            oObjLog:saveMsg("Comissoes: titulo ja encontrado: "+;
                                xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefixo+cProc+cParcela+"DP "+;
                                " recno: "+cValToChar(SE2->(recno())))
                        endif
                    else
                        cError:="Error: Comissao Rec "+cValToChar(Z11->(recno()))+", CPF/CNPJ "+cMatCom+" nao localizado."
                        oObjLog:saveMsg(cError)
                    endif
                next
            endif
        endif
    endif
    if !lError
        RecLock("Z11", .f.)
        Z11->Z11_STVEND := "02"
        Z11->Z11_JSONHI := Z11->Z11_JSONHI+dtos(date())+" - "+time()+" emitido comissoes a pagar."+CRLF 
        Z11->(MsUnlock())
    endif
return nil


/*/{Protheus.doc} pgtPonVen
Pagamento de pontos na venda da Z11 (deve estar posicionado)
@type function
@version 1.0
@author Pedro
@since 21/10/2023
@param cProc, character, numero do processo
@param cArqLog, character, nome do arquivo de log
@param lError, logical, se .t. tem erro, .f. cc
@return variant, fixo nulo
/*/
static function pgtPonVen(cProc, cArqLog, lError)
    local cNaturez as Character
    local cE2_CCD  := "101001" as Character
    local cE2_ITEMD := "0001" as Character
    local cE2_CLVLDB as Character 
    local aVetSE2 as array
    local nValor as numeric
	local oObjLog   := LogSMS():new() as Object
    local oObjParm  := JsonObject():New() as Object
    local cParcela as character
    local cPrefixo  := "PPC" as character
    local nPrazo
    local xRet
    local cError as character
    local cParam
    // local nTxPon := GetMV("AD_VLRPON",,0.04) as numeric
    private cMatCom 
	private lAutoErrNoFile := .T.
	private lMsErroAuto := .F.

    oObjLog:setFileName(cArqLog)
    oObjLog:saveMsg("Gerando pagamento de pontos")
    //  Gerar 
    if !empty(cParam := trim(GetMv("AD_OBJPON",,"")))
        xRet := oObjParm:fromJSON(cParam)
        if ValType(xRet) <> "U"
            lError := .t.
            cError:="Error: Parametro AD_OBJPON ["+cParam+"] nao e um JSON valido."
            oObjLog:saveMsg(cError)
        else
            cMatCom  := oObjParm["cnpj"]
            DbSelectArea('SA2')
            SA2->(dbSetOrder(3))  // A2_FILIAL+A2_CGC

            If SA2->(DbSeek(xFilial('SA2')+trim(cMatCom)))
                // TODO se ja foi gerada os pontos ignora
                nValor   := (Z11->Z11_VCPVAU + Z11->Z11_VCPVGE + Z11->Z11_VCPVLI + Z11->Z11_VCPVRE)
                nPrazo   := 0
                cParcela := pad('1', GetSX3Cache("E2_PARCELA", "X3_TAMANHO"))
                cNaturez := oObjParm["natureza"]
                cE2_CCD  := oObjParm["ccd"]
                cE2_ITEMD:= oObjParm["itemd"]
                cE2_CLVLDB := "F"+SA2->A2_COD+SA2->A2_LOJA
                
                SE2->(dbSetOrder(6)) // 6	E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
                if !SE2->(dbSeek(xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefixo+cProc+cParcela+"DP "))
                    aVetSE2 := {}
                    // aadd(aVetSE2, {"E2_FILIAL" , cFilTit                , Nil})
                    aadd(aVetSE2, {"E2_NUM"    , cProc                   , Nil})
                    aadd(aVetSE2, {"E2_PREFIXO", cPrefixo                , Nil})
                    aadd(aVetSE2, {"E2_PARCELA", cParcela                , Nil})
                    aadd(aVetSE2, {"E2_TIPO"   , "DP "                   , Nil})
                    aadd(aVetSE2, {"E2_NATUREZ", cNaturez               , Nil})
                    aadd(aVetSE2, {"E2_FORNECE", SA2->A2_COD            , Nil})
                    aadd(aVetSE2, {"E2_LOJA"   , SA2->A2_LOJA           , Nil})
                    aadd(aVetSE2, {"E2_NOMFOR" , SA2->A2_NREDUZ         , Nil})
                    aadd(aVetSE2, {"E2_EMISSAO", dDataBase               , Nil})
                    aadd(aVetSE2, {"E2_VENCTO" , (dDataBase+nPrazo)                , Nil})
                    aadd(aVetSE2, {"E2_VENCREA", DataValida((dDataBase+nPrazo),.T.), Nil})
                    aadd(aVetSE2, {"E2_VALOR"  , nValor          , Nil})
                    aadd(aVetSE2, {"E2_HIST"   , "Pontos G:"+trim(Z11->Z11_GRUPO)+", C:"+trim(Z11->Z11_COTA)         , Nil})
                    aadd(aVetSE2, {"E2_MOEDA"  , 1                      , Nil})
                    aadd(aVetSE2, {"E2_CCD"    , cE2_CCD          , Nil})
                    aadd(aVetSE2, {"E2_ITEMD"  , cE2_ITEMD        , Nil})
                    aadd(aVetSE2, {"E2_CLVLDB" , cE2_CLVLDB       , Nil})
                    aadd(aVetSE2, {"E2_IDFLUIG" , cProc       , Nil})
                    aadd(aVetSE2, {"E2_XPROCES" , cProc      , Nil})
                    //Chama a rotina automática
                    lMsErroAuto := .F.
                    lAutoErrNoFile := .T.
                    MSExecAuto({|x,y| FINA050(x,y)}, aVetSE2, 3)

                    //Se houve erro, mostra o erro ao usuário e desarma a transação
                    If lMsErroAuto
                        cError := "Error: Pontos venda "
                        aLog  := GetAutoGRLog() 
                        aeval(aLog, {|x| cError += x+CRLF})
                        oObjLog:saveMsg( ;
                                + varInfo("aVetSE2",aVetSE2, , .f., .f.) + CRLF  ;
                                + cError )  
                        lError := .t.
                    EndIf
                else
                    oObjLog:saveMsg("Pontos venda: titulo ja encontrado: "+;
                        xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefixo+cProc+cParcela+"DP "+;
                        ", recno: "+cValToChar(SE2->(recno())))
                EndIf
                // Pontos de compra
                if lower(Z11->Z11_TIPOPE) == 'vendals'
                    nValor   := (Z11->Z11_VCPCAU + Z11->Z11_VCPCGE + Z11->Z11_VCPCLI + Z11->Z11_VCPCRE)
                    nPrazo   := 0
                    cParcela := pad('2', GetSX3Cache("E2_PARCELA", "X3_TAMANHO"))
                    SE2->(dbSetOrder(6)) // 6	E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
                    if !SE2->(dbSeek(xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefixo+cProc+cParcela+"DP "))
                        aVetSE2 := {}
                        // aadd(aVetSE2, {"E2_FILIAL" , cFilTit                , Nil})
                        aadd(aVetSE2, {"E2_NUM"    , cProc                   , Nil})
                        aadd(aVetSE2, {"E2_PREFIXO", cPrefixo                , Nil})
                        aadd(aVetSE2, {"E2_PARCELA", cParcela                , Nil})
                        aadd(aVetSE2, {"E2_TIPO"   , "DP "                   , Nil})
                        aadd(aVetSE2, {"E2_NATUREZ", cNaturez               , Nil})
                        aadd(aVetSE2, {"E2_FORNECE", SA2->A2_COD            , Nil})
                        aadd(aVetSE2, {"E2_LOJA"   , SA2->A2_LOJA           , Nil})
                        aadd(aVetSE2, {"E2_NOMFOR" , SA2->A2_NREDUZ         , Nil})
                        aadd(aVetSE2, {"E2_EMISSAO", dDataBase               , Nil})
                        aadd(aVetSE2, {"E2_VENCTO" , (dDataBase+nPrazo)                , Nil})
                        aadd(aVetSE2, {"E2_VENCREA", DataValida((dDataBase+nPrazo),.T.), Nil})
                        aadd(aVetSE2, {"E2_VALOR"  , nValor          , Nil})
                        aadd(aVetSE2, {"E2_HIST"   , "Pontos G:"+trim(Z11->Z11_GRUPO)+", C:"+trim(Z11->Z11_COTA)         , Nil})
                        aadd(aVetSE2, {"E2_MOEDA"  , 1                      , Nil})
                        aadd(aVetSE2, {"E2_CCD"    , cE2_CCD          , Nil})
                        aadd(aVetSE2, {"E2_ITEMD"  , cE2_ITEMD        , Nil})
                        aadd(aVetSE2, {"E2_CLVLDB" , cE2_CLVLDB       , Nil})
                        aadd(aVetSE2, {"E2_IDFLUIG" , cProc       , Nil})
                        aadd(aVetSE2, {"E2_XPROCES" , cProc      , Nil})
                        //Chama a rotina automática
                        lMsErroAuto := .F.
                        lAutoErrNoFile := .T.
                        MSExecAuto({|x,y| FINA050(x,y)}, aVetSE2, 3)

                        //Se houve erro, mostra o erro ao usuário e desarma a transação
                        If lMsErroAuto
                            cError := "Error: Pontos compra "
                            aLog  := GetAutoGRLog() 
                            aeval(aLog, {|x| cError += x+CRLF})
                            oObjLog:saveMsg( ;
                                    + varInfo("aVetSE2",aVetSE2, , .f., .f.) + CRLF  ;
                                    + cError )  
                            lError := .t.
                        EndIf
                    else
                        oObjLog:saveMsg("Pontos compra: titulo ja encontrado: "+;
                            xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefixo+cProc+cParcela+"DP "+;
                            ", recno: "+cValToChar(SE2->(recno())))
                    EndIf
                endif
            else
                lError := .t.
                cError:="Error: Pontos Rec "+cValToChar(Z11->(recno()))+", CPF/CNPJ "+cMatCom+" nao localizado."
                oObjLog:saveMsg(cError)
            endif
        endif
    else
        oObjLog:saveMsg("Pontos: Rec "+cValToChar(Z11->(recno()))+" sem o parametro AD_OBJPON configurado")
    endif
    if !lError
        RecLock("Z11", .f.)
        Z11->Z11_STVEND := "03"  
        Z11->Z11_JSONHI := Z11->Z11_JSONHI+dtos(date())+" - "+time()+" emitido pgto. de pontos."+CRLF 
        Z11->(MsUnlock())
    endif
return nil

/*/{Protheus.doc} pgtAtras
Pagamento de atrasados venda da Z11 (deve estar posicionado)
@type function
@version 1.0
@author Pedro
@since 21/10/2023
@param cProc, character, numero do processo
@param cArqLog, character, nome do arquivo de log
@param lError, logical, se .t. tem erro, .f. cc
@return variant, fixo nulo
/*/
static function pgtAtras(cProc, cArqLog, lError)
    local cNaturez as Character
    local cE2_CCD  := "101001" as Character
    local cE2_ITEMD := "0001" as Character
    local cE2_CLVLDB as Character 
    local aVetSE2 as array
    local nValor as numeric
	local oObjLog   := LogSMS():new() as Object
    local oObjParm   := JsonObject():New() as Object
    local cParcela as character
    local cPrefixo  := "PAT" as character
    local nPrazo
    local xRet
    local cError as character
    local cParam as character
    private cMatCom 
	private lAutoErrNoFile := .T.
	private lMsErroAuto := .F.

    oObjLog:setFileName(cArqLog)
    oObjLog:saveMsg("Gerando pagamento de atrasados")
    nValor   := Z11->Z11_ATRAS
    //  Gerar 
    if !empty(cParam := trim(GetMv("AD_OBJATR",,""))) .and. (nValor > 0.00)
        xRet := oObjParm:fromJSON(cParam)
        if ValType(xRet) <> "U"
            lError := .t.
            cError:="Error: Parametro AD_OBJATR ["+cParam+"] nao e um JSON valido."
            oObjLog:saveMsg(cError)
        else
            cMatCom  := oObjParm["cnpj"]
            nPrazo   := 0
            cParcela := space(GetSX3Cache("E2_PARCELA", "X3_TAMANHO"))
            DbSelectArea('SA2')
            SA2->(dbSetOrder(3))  // A2_FILIAL+A2_CGC

            If SA2->(DbSeek(xFilial('SA2')+trim(cMatCom)))
                // TODO se ja foi gerada o atraso
                
                SE2->(dbSetOrder(6)) // 6	E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
                if !SE2->(dbSeek(xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefixo+cProc+cParcela+"DP "))
                    cNaturez := oObjParm["natureza"]
                    cE2_CCD  := oObjParm["ccd"]
                    cE2_ITEMD:= oObjParm["itemd"]
                    cE2_CLVLDB := "F"+SA2->A2_COD+SA2->A2_LOJA
                    aVetSE2 := {}
                    // aadd(aVetSE2, {"E2_FILIAL" , cFilTit                , Nil})
                    aadd(aVetSE2, {"E2_NUM"    , cProc                   , Nil})
                    aadd(aVetSE2, {"E2_PREFIXO", cPrefixo                , Nil})
                    aadd(aVetSE2, {"E2_PARCELA", cParcela                , Nil})
                    aadd(aVetSE2, {"E2_TIPO"   , "DP "                   , Nil})
                    aadd(aVetSE2, {"E2_NATUREZ", cNaturez               , Nil})
                    aadd(aVetSE2, {"E2_FORNECE", SA2->A2_COD            , Nil})
                    aadd(aVetSE2, {"E2_LOJA"   , SA2->A2_LOJA           , Nil})
                    aadd(aVetSE2, {"E2_NOMFOR" , SA2->A2_NREDUZ         , Nil})
                    aadd(aVetSE2, {"E2_EMISSAO", dDataBase               , Nil})
                    aadd(aVetSE2, {"E2_VENCTO" , (dDataBase+nPrazo)                , Nil})
                    aadd(aVetSE2, {"E2_VENCREA", DataValida((dDataBase+nPrazo),.T.), Nil})
                    aadd(aVetSE2, {"E2_VALOR"  , nValor          , Nil})
                    aadd(aVetSE2, {"E2_HIST"   , "Atrasados G:"+trim(Z11->Z11_GRUPO)+", C:"+trim(Z11->Z11_COTA)         , Nil})
                    aadd(aVetSE2, {"E2_MOEDA"  , 1                      , Nil})
                    aadd(aVetSE2, {"E2_CCD"    , cE2_CCD          , Nil})
                    aadd(aVetSE2, {"E2_ITEMD"  , cE2_ITEMD        , Nil})
                    aadd(aVetSE2, {"E2_CLVLDB" , cE2_CLVLDB       , Nil})
                    aadd(aVetSE2, {"E2_IDFLUIG" , cProc       , Nil})
                    aadd(aVetSE2, {"E2_XPROCES" , cProc      , Nil})
                    //Chama a rotina automática
                    lMsErroAuto := .F.
                    lAutoErrNoFile := .T.
                    MSExecAuto({|x,y| FINA050(x,y)}, aVetSE2, 3)

                    //Se houve erro, mostra o erro ao usuário e desarma a transação
                    If lMsErroAuto
                        cError := "Error: Atrasos "
                        aLog  := GetAutoGRLog() 
                        aeval(aLog, {|x| cError += x+CRLF})
                        oObjLog:saveMsg( ;
                                + varInfo("aVetSE2",aVetSE2, , .f., .f.) + CRLF  ;
                                + cError )  
                        lError := .t.
                    EndIf
                else
                    oObjLog:saveMsg("Atrasos: titulo ja encontrado: "+;
                        xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefixo+cProc+cParcela+"DP "+;
                        ", recno: "+cValToChar(SE2->(recno())))
                EndIf
            else
                lError := .t.
                cError:="Error: Atrasos Rec "+cValToChar(Z11->(recno()))+", CPF/CNPJ "+cMatCom+" nao localizado."
                oObjLog:saveMsg(cError)
            endif
        endif
    else
        oObjLog:saveMsg("Atraso: Rec "+cValToChar(Z11->(recno())) ;
                +" sem o parametro AD_OBJATR configurado ou sem valor em atraso: "+cValToChar(Z11->Z11_ATRAS))
    endif
    if !lError
        RecLock("Z11", .f.)
        Z11->Z11_STVEND := "03"  
        Z11->Z11_JSONHI := Z11->Z11_JSONHI+dtos(date())+" - "+time()+" emitido pgto. de pontos."+CRLF 
        Z11->(MsUnlock())
    endif
return nil


/*/{Protheus.doc} pgtLeilao
Pagamento do Leilao Standard da Z11 (deve estar posicionado)
@type function
@version 1.0
@author Pedro
@since 21/10/2023
@param cProc, character, numero do processo
@param cArqLog, character, nome do arquivo de log
@param lError, logical, se .t. tem erro, .f. cc
@return variant, fixo nulo
/*/
static function pgtLeilao(cProc, cArqLog, lError)
    local cNaturez as Character
    local cE2_CCD  := "101001" as Character
    local cE2_ITEMD := "0001" as Character
    local cE2_CLVLDB as Character 
    local aVetSE2 as array
    local nValor as numeric
	local oObjLog   := LogSMS():new() as Object
    local oObjParm   := JsonObject():New() as Object
    local cParcela as character
    local cPrefixo  := "PVL" as character
    local nPrazo
    local xRet
    local cError as character
    local cParam as character
    private cMatCom 
	private lAutoErrNoFile := .T.
	private lMsErroAuto := .F.

    oObjLog:setFileName(cArqLog)
    oObjLog:saveMsg("Gerando pagamento do leilao standard")
    //  Gerar 
    if lower(Z11->Z11_TIPOPE) == 'vendals' .and. !empty(cParam := trim(GetMv("AD_OBJLEI",,"")))
        xRet := oObjParm:fromJSON(cParam)
        if ValType(xRet) <> "U"
            lError := .t.
            cError:="Error: Parametro AD_OBJLEI ["+cParam+"] nao e um JSON valido."
            oObjLog:saveMsg(cError)
        else
            cMatCom  := trim(Z11->Z11_DOCTIT)
            nValor   := Z11->Z11_VBRVEN - Z11->Z11_ATRAS - Z11->Z11_VALTXU

            nPrazo   := 0
            cParcela := space(GetSX3Cache("E2_PARCELA", "X3_TAMANHO"))
            DbSelectArea('SA2')
            SA2->(dbSetOrder(3))  // A2_FILIAL+A2_CGC

            If SA2->(DbSeek(xFilial('SA2')+trim(cMatCom)))
                // TODO se ja foi gerada o pgto leilao
                
                SE2->(dbSetOrder(6)) // 6	E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
                if !SE2->(dbSeek(xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefixo+cProc+cParcela+"DP "))
                    cNaturez := oObjParm["natureza"]
                    cE2_CCD  := oObjParm["ccd"]
                    cE2_ITEMD:= oObjParm["itemd"]
                    cE2_CLVLDB := "F"+SA2->A2_COD+SA2->A2_LOJA
                    aVetSE2 := {}
                    // aadd(aVetSE2, {"E2_FILIAL" , cFilTit                , Nil})
                    aadd(aVetSE2, {"E2_NUM"    , cProc                   , Nil})
                    aadd(aVetSE2, {"E2_PREFIXO", cPrefixo                , Nil})
                    aadd(aVetSE2, {"E2_PARCELA", cParcela                , Nil})
                    aadd(aVetSE2, {"E2_TIPO"   , "DP "                   , Nil})
                    aadd(aVetSE2, {"E2_NATUREZ", cNaturez               , Nil})
                    aadd(aVetSE2, {"E2_FORNECE", SA2->A2_COD            , Nil})
                    aadd(aVetSE2, {"E2_LOJA"   , SA2->A2_LOJA           , Nil})
                    aadd(aVetSE2, {"E2_NOMFOR" , SA2->A2_NREDUZ         , Nil})
                    aadd(aVetSE2, {"E2_EMISSAO", dDataBase               , Nil})
                    aadd(aVetSE2, {"E2_VENCTO" , (dDataBase+nPrazo)                , Nil})
                    aadd(aVetSE2, {"E2_VENCREA", DataValida((dDataBase+nPrazo),.T.), Nil})
                    aadd(aVetSE2, {"E2_VALOR"  , nValor          , Nil})
                    aadd(aVetSE2, {"E2_HIST"   , "Pgto LS G:"+trim(Z11->Z11_GRUPO)+", C:"+trim(Z11->Z11_COTA)         , Nil})
                    aadd(aVetSE2, {"E2_MOEDA"  , 1                      , Nil})
                    aadd(aVetSE2, {"E2_CCD"    , cE2_CCD          , Nil})
                    aadd(aVetSE2, {"E2_ITEMD"  , cE2_ITEMD        , Nil})
                    aadd(aVetSE2, {"E2_CLVLDB" , cE2_CLVLDB       , Nil})
                    aadd(aVetSE2, {"E2_IDFLUIG" , cProc       , Nil})
                    aadd(aVetSE2, {"E2_XPROCES" , cProc      , Nil})
                    //Chama a rotina automática
                    lMsErroAuto := .F.
                    lAutoErrNoFile := .T.
                    MSExecAuto({|x,y| FINA050(x,y)}, aVetSE2, 3)

                    //Se houve erro, mostra o erro ao usuário e desarma a transação
                    If lMsErroAuto
                        cError := "Error: Pgto. Leilao "
                        aLog  := GetAutoGRLog() 
                        aeval(aLog, {|x| cError += x+CRLF})
                        oObjLog:saveMsg( ;
                                + varInfo("aVetSE2",aVetSE2, , .f., .f.) + CRLF  ;
                                + cError )  
                        lError := .t.
                    EndIf
                else
                    oObjLog:saveMsg("Pgto. Leilao: titulo ja encontrado: "+;
                        xFilial("SE2")+SA2->A2_COD+SA2->A2_LOJA+cPrefixo+cProc+cParcela+"DP "+;
                        ", recno: "+cValToChar(SE2->(recno())))
                EndIf
            else
                lError := .t.
                cError:="Error: Pgto. Leilao Rec "+cValToChar(Z11->(recno()))+", CPF/CNPJ "+cMatCom+" nao localizado."
                oObjLog:saveMsg(cError)
            endif
        endif
    endif
    if !lError
        RecLock("Z11", .f.)
        Z11->Z11_STVEND := "99"  
        Z11->Z11_JSONHI := Z11->Z11_JSONHI+dtos(date())+" - "+time()+" emitido pgto. de leilao."+CRLF 
        Z11->(MsUnlock())
    endif
return nil




/*/{Protheus.doc} adMClei
Processo de colocacao de cota em leilao standard
@type function
@version 1.0
@author Pedro
@since 21/10/2023
@param aParm, array, 
        1 - cEmpresa
        2 - cFilial
        3 - nRecZ11
@return variant, fixo nulo
/*/
user function adMClei(aParm)
	Local lEnv := .t. as Logical
    // local cNaturez as Character
    // local cE1_CCC  := "" as Character
    // local cE1_ITEMC := "0001" as Character
    // local cE1_CLVLCR := "" as Character 
    // local cE1_CLVLDB := "" as Character 
    // local aVetSE1 as array
    local cProc as Character
    // local cError as Character
    // local aLog as array
	// local dEmissao := dDataBase
	// local dVencto  := dDataBase+3
    // local lError := .f. as logical
	local oObjLog   := LogSMS():new()

	private lAutoErrNoFile := .T.
	private lMsErroAuto := .F.

	oObjLog:setFileName("\temp\"+procname()+"_"+dtos(date())+".txt")
	oObjLog:saveMsg("================")

    if select("SX2") = 0 
        RPCSetType(3)
        lEnv := RPCSetEnv(aParm[1], aParm[2])
    endif
	If lEnv
        dbSelectArea("Z11")
        Z11->(dbGoTo(aParm[3]))
        cProc   := padl(alltrim(Z11->Z11_IDPROV), GetSx3Cache("E1_NUM","X3_TAMANHO"), "0")
        oObjLog:saveMsg("Processo: "+cProc)
        // TODO gerar conta a receber para o fornecedor
		// if !empty(Z11->Z11_DOCTIT) 

		// 	DbSelectArea('SA1')
		// 	SA1->(dbSetOrder(3))  // A1_FILIAL+A1_CGC

		// 	If SA1->(DbSeek(xFilial('SA1')+trim(Z11->Z11_DOCTIT)))
		// 		cNaturez := SA1->A1_NATUREZ
		// 		if empty(cNaturez)
		// 			cNaturez := GetMv("AD_ANTNATU",,"")
		// 		endif
        //         if empty(cE1_CLVLCR)
        //             //cE1_CLVLCR := GetMv("AD_ANTCLVC",,"")
        //             cE1_CLVLCR := "C"+SA1->A1_COD+SA1->A1_LOJA
        //         endif
        //         if empty(cE1_CLVLDB)
        //             //cE1_CLVLDB := GetMv("AD_ANTCLVD",,"")
        //             cE1_CLVLDB := "C"+SA1->A1_COD+SA1->A1_LOJA
        //         endif
        //         RecLock("Z11", .f.)
        //         Z11->Z11_PCTXL  := Z11->Z11_PCTXL + 1
        //         Z11->(MsUnlock())

		// 		//Prepara o array para o execauto
		// 		aVetSE1 := {}
		// 		aadd(aVetSE1, {"E1_NUM"    , cProc                   , Nil})
		// 		aadd(aVetSE1, {"E1_PREFIXO", "MCT"               , Nil})
		// 		aadd(aVetSE1, {"E1_PARCELA", cValToChar(Z11->Z11_PCTXL)      , Nil})
		// 		aadd(aVetSE1, {"E1_TIPO"   , "DP "                  , Nil})
		// 		aadd(aVetSE1, {"E1_NATUREZ", cNaturez               , Nil})
		// 		aadd(aVetSE1, {"E1_CLIENTE", SA1->A1_COD            , Nil})
		// 		aadd(aVetSE1, {"E1_LOJA"   , SA1->A1_LOJA           , Nil})
		// 		aadd(aVetSE1, {"E1_NOMCLI" , SA1->A1_NREDUZ         , Nil})
		// 		aadd(aVetSE1, {"E1_EMISSAO", dEmissao               , Nil})
		// 		aadd(aVetSE1, {"E1_VENCTO" , dVencto                , Nil})
		// 		aadd(aVetSE1, {"E1_VENCREA", DataValida(dVencto,.T.), Nil})
		// 		aadd(aVetSE1, {"E1_VALOR"  , Z11->Z11_TXLEIS        , Nil})
		// 		aadd(aVetSE1, {"E1_MOEDA"  , 1                      , Nil})
		// 		aadd(aVetSE1, {"E1_CCC"    , cE1_CCC          , Nil})
		// 		aadd(aVetSE1, {"E1_ITEMC"  , cE1_ITEMC        , Nil})
		// 		aadd(aVetSE1, {"E1_CLVLDB" , cE1_CLVLDB       , Nil})
		// 		aadd(aVetSE1, {"E1_CLVLCR" , cE1_CLVLCR       , Nil})
		// 		aadd(aVetSE1, {"E1_IDFLUIG" , cProc       , Nil})
		// 		aadd(aVetSE1, {"E1_XPROCES" , cProc       , Nil})
		// 		//Chama a rotina automática
		// 		lMsErroAuto := .F.
		// 		lAutoErrNoFile := .T.
        //         // MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 3)

        //         //Se houve erro, mostra o erro ao usuário e desarma a transação
        //         // If lMsErroAuto
        //         //     cError := "Error: "
        //         //     aLog  := GetAutoGRLog() 
        //         //     aeval(aLog, {|x| cError += x+CRLF})
        //         //     oObjLog:saveMsg( ;
        //         //             + varInfo("aVetSE1",aVetSE1, , .f., .f.) + CRLF  ;
        //         //             + cError )  
        //         //     lError := .t.
        //         // else
        //             // TODO salvar no historico a geracao do boleto 
        //             RecLock("Z11", .f.)
        //    			Z11->Z11_JSONHI := Z11->Z11_JSONHI+dtos(date())+" - "+time()+" emitido boleto autorizacao ls."+CRLF 
        //             Z11->(MsUnlock())
        //             // TODO imprimir boleto
        //         // EndIf
        //     else
		// 		cError:="Error: Rec "+cValToChar(Z11->(recno()))+", CPF/CNPJ "+Z11->Z11_DOCTIT+" nao localizado."
		// 		oObjLog:saveMsg(cError)
		// 	endif
		// ELSE
		// 	cError:="Error: Rec "+cValToChar(Z11->(recno()))+", CPF/CNPJ nao preenchido."
		// 	oObjLog:saveMsg(cError)
		// ENDIF
    endif
return

