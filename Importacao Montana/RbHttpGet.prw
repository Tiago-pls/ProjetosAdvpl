#INCLUDE "TOTVS.CH"
//https://api.tabletcloud.com.br/Help/Api/GET-cupom-get-dataInicial-datafinal-filiais
User Function RbHttpGet(_cToken)
    Local _cPerg         := 'RbHttpGet '
    Local _cUrl          := ''
    Local _cDtInicial    := ''
    Local _cDtFinal      := ''
    Local _cFiliais      := '9415' 
    Local _cHtmlPage     := ''
    Local _aAccToken     := {}  
    Local _cVendedor     := "000001" //Codigo do Vendedor

    Local oXML          
    Local oXMLCli      
    Local oXMLIten      

    local cxPath  := '/retorno/notasfiscais/notafiscal['+cValToChar(1)+']'

    Local ni:= 0
    Local nj:= 0

    Local _aCab         := {}
    Local _aItem        := {} 
    Local _aParcelas    := {} 

    //Retorna o tamanho dos campos
    Local nTamProd      := TamSX3("LR_PRODUTO")[1]
    Local nTamUM        := TamSX3("LR_UM")[1]
    Local nTamTabela    := TamSX3("LR_TABELA")[1]

    Local cCliPad   := SuperGetMV( "MV_CLIPAD",,"000001" )	// Cliente Padrao
    Local cLojPad   := SuperGetMV( "MV_LOJAPAD",,"01" )	// Loja do Cliente Padrao
    Local cTipoCl   := "F"
    Local cSerieCP  := Getmv("MV_SERIE")

    Private cError	:= ""
	Private cWarning	:= ""

    Private lMsHelpAuto := .T. //Variavel de controle interno do ExecAuto
    Private lMsErroAuto := .F. //Variavel que informa a ocorrência de erros no ExecAuto
    public cCupom :=""

    If !Pergunte(_cPerg,.t.)
		Return
	endif
    mv_par01    := Stod( Getmv("RB_DTINICP"))
    mv_par02    := Stod( Getmv("RB_DTFIMCP"))

    _cDtInicial := Substr(Dtos(mv_par01),1,4) + '-' + Substr(Dtos(mv_par01),5,2) + '-' + Substr(Dtos(mv_par01),7,2) 
    _cDtFinal   := Substr(Dtos(mv_par02),1,4) + '-' + Substr(Dtos(mv_par02),5,2) + '-' + Substr(Dtos(mv_par02),7,2)
    
    _cUrl  := 'https://api.tabletcloud.com.br/cupom/get/'
    _cUrl  += _cDtInicial +'/'
    _cUrl  += _cDtFinal   +'/'
    _cUrl  += _cFiliais
    
    Aadd(_aAccToken,'Authorization: Bearer ' +_cToken ) 

    _cHtmlPage := Httpget(_cUrl, , , _aAccToken)

    FWJsonDeserialize(_cHtmlPage,@oXml)

    SA1->(DbSetOrder(3)) 
    SB1->(DbSetOrder(1)) 

    if select("SL1") == 0
        DbSelectArea("SL1")
    Endif
    SL1->( DbSetorder(2)) // L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV

    For ni:= 1 To Len(oXML)
        cCupom:= oXML[nI]:CODCUPOM
        SL1->( DbGotop())
        if SL1->( DbSeek( xFilial("SL1") + cSerieCP + cValtochar(cCupom )))
            conout("Cupom "+cValtochar(cCupom )+" ja importado")
            loop
        endif
        if len(oXML[nI]:CLIENTES)= 0
            //Posiciona no cliente padrão 
            cCNPJ := 'NAO INFORMADO'
        Else
            oXMLCli     := oXML[nI]:CLIENTES[1]
            cCNPJ := oXMLCli:CPF_CNPJ
        Endif
        oXMLIten    := oXML[nI]:itens
        _aCab       := {}
        _aItem      := {} 
        _aParcelas  := {}
        dDatabase   := stod(SubStr(STRTRAN(oXML[nI]:dtmovimento,'-'),1,10))
        SA1->(DbSetOrder(3)) 
            //Se encontrou o cliente grava os dados 
        IF SA1->(DbSeek(xFilial("SA1") + cCNPJ))
            cCliPad :=  SA1->A1_COD
            cLojPad :=  SA1->A1_LOJA
            cTipoCl :=  SA1->A1_TIPO
        else
            
            //Posiciona no cliente padrão 
            SA1->(DbSetOrder(1))  
            if !SA1->(DbSeek(xFilial("SA1")+PADR(cCliPad,TAMSX3("A1_COD")[1])+cLojPad))
                conout("Cliente padrão não encontrado")
                loop
            EndIf
            
        EndIf
        // Monta cabeçalho do orçamento (SLQ)
        //***********************************

        aAdd( _aCab, {"LQ_COMIS"        , 0 , NIL} )
        aAdd( _aCab, {"LQ_CLIENTE"      , SA1->A1_COD, NIL} )
        aAdd( _aCab, {"LQ_LOJA"         , SA1->A1_LOJA , NIL} )
        aAdd( _aCab, {"LQ_VEND"         , _cVendedor , NIL} )
        aAdd( _aCab, {"LQ_TIPOCLI"      , cTipoCl , NIL} )
        aAdd( _aCab, {"LQ_DESCONT"      , 0 , NIL} )
        aAdd( _aCab, {"LQ_DTLIM"        , dDatabase , NIL} )
        aAdd( _aCab, {"LQ_EMISSAO"      , dDatabase , NIL} )
        aAdd( _aCab, {"LQ_CONDPG"       , "001" , NIL} )
        aAdd( _aCab, {"LQ_NUMMOV"       , "1 " , NIL} )
        aAdd( _aCab, {"LQ_DOC"          , oXML[nI]:CODCUPOM  , NIL} )
        cCupom:= oXML[nI]:CODCUPOM   
            //************************************************
            // Monta o Pagamento do orçamento (aPagtos) (SL4)
            //************************************************
        aAdd( _aParcelas, {} )
        aAdd( _aParcelas[Len(_aParcelas)], {"L4_DATA"       , dDatabase , NIL} )
        aAdd( _aParcelas[Len(_aParcelas)], {"L4_VALOR"      , oXML[nI]:valortotal   , NIL} )
        aAdd( _aParcelas[Len(_aParcelas)], {"L4_FORMA"      , "R$ "     , NIL} )
        aAdd( _aParcelas[Len(_aParcelas)], {"L4_ADMINIS"    , " "       , NIL} )
        aAdd( _aParcelas[Len(_aParcelas)], {"L4_NUMCART"    , " "       , NIL} )
        aAdd( _aParcelas[Len(_aParcelas)], {"L4_FORMAID"    , " "       , NIL} )
        aAdd( _aParcelas[Len(_aParcelas)], {"L4_MOEDA"      , 1        , NIL} )

        For nj:=1 to len(oXMLIten)
                //***********************************
                // Monta Itens do orçamento (SLR)
                //***********************************
            cProd := Padr(oXMLIten[nj]:CODIGOVENDA,TamSx3("B1_COD")[1])
            // verificar se há código PDV cadastrado na SB1
           // cPDV  := POSICIONE( "SB1",1,XFILIAL("SB1") + cProd,"B1_PDVLEG")
            cPDV := GetAdvFVal("SB1","B1_PDVLEG",XFILIAL("SB1") + cProd,1,"") 
            cProd := iif(empty(cPDV), cProd, cPDV)
            if !SB1->(DbSeek(xfilial("SB1") + cProd))                    
                if !VerProd(cProd,_cToken)
                    loop
                EndIf
         //   Else
           //     cPdv:= SB1->B1_PDVLEG
            EndIf

            aAdd( _aItem, {} )
            //aAdd( _aItem[Len(_aItem)], {"LR_PRODUTO"    , SB1->B1_COD   , NIL} )
            aAdd( _aItem[Len(_aItem)], {"LR_PRODUTO"    , cProd  , NIL} )
            aAdd( _aItem[Len(_aItem)], {"LR_DESCRI"     , Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC" )  , NIL} )
            aAdd( _aItem[Len(_aItem)], {"LR_QUANT"      , oXMLIten[nj]:quantidade, NIL} )
            aAdd( _aItem[Len(_aItem)], {"LR_PRCTAB"     , oXMLIten[nj]:VALORTOTAL/oXMLIten[nj]:quantidade , NIL} )
            aAdd( _aItem[Len(_aItem)], {"LR_UM"         , SB1->B1_UM                 , NIL} )
            aAdd( _aItem[Len(_aItem)], {"LR_DESC"       , 0                          , NIL} )
            aAdd( _aItem[Len(_aItem)], {"LR_VALDESC"    , 0                          , NIL} )
            aAdd( _aItem[Len(_aItem)], {"LR_TABELA"     , PadR("1",nTamTabela)       , NIL} )
            aAdd( _aItem[Len(_aItem)], {"LR_DESCPRO"    , 0                          , NIL} )
            aAdd( _aItem[Len(_aItem)], {"LR_VEND"       , _cVendedor                 , NIL} )
                
        next 

        SetFunName("LOJA701")
        MSExecAuto({|a,b,c,d,e,f,g,h| Loja701(a,b,c,d,e,f,g,h)},.F.,3,"","",{},_aCab,_aItem ,_aParcelas)

        If lMsErroAuto
            Alert("Erro no ExecAuto")
            cMsgErro := MostraErro()
            DisarmTransaction()
            Alert(cMsgErro)
        Else
            MsgAlert("Registro incluido com sucesso!")
        EndIf
    Next nI 
dtFim := Stod( Getmv("RB_DTFIMCP")) +1

PUTMV("RB_DTINICP", Dtos( Stod( Getmv("RB_DTFIMCP")) +1))
PUTMV("RB_DTFIMCP", Dtos( Stod( Getmv("RB_DTFIMCP")) +1))

Return

static function VerProd(cCodProd,_cToken)
    Local aArea         := GetArea()
    Local lRet          := .T.
    Local _cUrlGet      := "https://api.tabletcloud.com.br/produtos/get/"+cCodProd
    Local aTokenPr      := {}
    Local cHtmlPro      := ""
    Local oXmlProd   
    Local cTipo         := "PA"
    Local cArmaz        := "01"
    Local cMarca        := ""              

    Private lMsErroAuto := .F.

    Aadd(aTokenPr,'Authorization: Bearer ' +_cToken ) 

    cHtmlPro := Httpget(_cUrlGet, , , aTokenPr)

    FWJsonDeserialize(cHtmlPro,@oXmlProd)
    
    aVetor:= { {"B1_COD" ,     AllTrim(cCodProd) ,NIL},;
            {"B1_DESC" ,    UPPER(AllTrim(oXmlProd:DESCRICAOCUPOM)),NIL},;
            {"B1_TIPO" ,    cTipo ,Nil},;
            {"B1_UM" ,      UPPER(AllTrim(oXmlProd:unidade)) ,Nil},;
            {"B1_LOCPAD" ,  cArmaz ,Nil},;
            {"B1_POSIPI" ,  AllTrim(oXmlProd:codigoncm) ,Nil},;
            {"B1_GRUPO" ,   "0" ,Nil},;   // verificar como tratar esse camp
            {"B1_SGRUPO" ,  "99" ,Nil},;   // IMPORTADO
            {"B1_GRTRIB" ,  "007" ,Nil},; // verificar como tratar esse campo
            {"B1_SMARCA" ,  iif ( Empty(cMarca), '02' , cMarca),Nil},;
            {"B1_ORIGEM" ,  "0",Nil},;
            {"B1_LOCALIZ" , "N" ,Nil}}        

    // verificar se o NCM está cadastrado na tabela 
    lMsErroAuto := .F.
    MSExecAuto({|x,y| Mata010(x,y)},aVetor,3)
    // verifica se ocorreu erro
    if lMsErroAuto
        // mostra erro
        Mostraerro()
        lRet := .F.
    else
        CriaSB2(SB1->B1_COD,'01')
    endIf                
    RestArea(aArea)
return lRet




