#include 'protheus.ch'
//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552
@type			function
@description	Programa de inicialização do Portal THF/Portinari do TAF (ESOCIAL).
@author			Tiago Santos
@since			03/05/2021
@version		1.0
/*/

/*
SX5 - ZD - 999    IMPORTADO API - AJUSTAR          
ZE
copiar tabela SEE020 para SEE030
criar banco 422                      
deletado o gatilho A1_SUBCOD 
Tirado a aobrigação do campo Inscricao Estadual A1_INSCR
compilar o fonte roberlo_fata1002.prw

*/
//---------------------------------------------------------------------

user function ApiPedido() 
Local cUrl			:=  Alltrim(GetMv("RB_URLAPIC"))
Local cGetParams	:= ""
Local nTimeOut		:= 200
Local aHeadStr		:= {"Content-Type: application/json"}
Local cHeaderGet	:= ""
Local cRetWs		:= ""
Local cApiKey       := "&apikey=" + Alltrim(GetMv("RB_APIKEY")) 
Local cFIlter       :="" // Somente Produtos Ativos
Local lGetWS        := .T.
Local nPage         := 1
Local cArea         := "SA1"
Local oXML := TXMLManager():New()
Local aLogAuto := {}
Local cLogTxt  := ""
Local cArquivo := "C:\TOTVS\exemplo1.txt"
Local nAux     := 0

Default lJob        := .T.

cUrl += "/page="

if select(cArea) ==0 // Clienes
    DbSelectArea(cArea)
endif
SA1->(DbSetorder(1))

if select("SB1") ==0 // Produtos
    DbSelectArea("SB1")
endif
SB1->(DbSetorder(1))

if select("SC5") ==0 // Cab PV
    DbSelectArea("SC5")
endif
SC5->( DbOrderNickName("PVBLING"))

While lGetWS
    cRetWs	:= HttpGet(cUrl + cValToChar(nPage) + cApiKey +cFIlter, cGetParams, nTimeOut, aHeadStr, @cHeaderGet)

    if '<retorno><erros>'$ cRetWs
        EXIT
    Endif
    // Faz o parser
    lOk := oXml:Parse(cRetWs)

    If !lOk       
        MsgStop(oXml:Error(),'XML Parser Error')
        Return .F.
    Endif
    // Determina a quantidade de pessoas
    nPedidos := oXml:XPATHCHILDCOUNT('/retorno/pedidos')

    For nI := 1 to nPedidos
        lProcPV := .T.
        cxPath  := '/retorno/pedidos/pedido['+cValToChar(nI)+']'
        cNome   :=  StrTran(Left(  Upper(  DecodeUTF8( NoAcento(oXml:XPATHGETNODEVALUE(cxPath+'/cliente/nome')))),TamSx3("A1_NOME")[1] ),"'","")
        cCNPJ   :=  StrTran(StrTran(StrTran( oXml:XPATHGETNODEVALUE(cxPath+'/cliente/cnpj'), ".",""), "-",""), "/", "")
        if Alltrim( cNome) == "CONSUMIDOR FINAL" .or. Empty(cCNPJ) .or. Empty(cNome)
            cCod  := replicate("9",8)
            cLoja := replicate("9",4)
        else
            cNomeRed :=  Left(  Upper(  DecodeUTF8( NoAcento(oXml:XPATHGETNODEVALUE(cxPath+'/cliente/nome')))),TamSx3("A1_NREDUZ")[1] )
            cCod     :=  SubStr(cCNPJ, 1,8)
            cLoja    :=  SubStr(cCNPJ, 9,4)
            cBairro  :=  Left(  NoAcento( Upper(oXml:XPATHGETNODEVALUE(cxPath+'/cliente/bairro'))), TamSx3("A1_BAIRRO")[1])
            cIE      :=  NoAcento( Upper(oXml:XPATHGETNODEVALUE(cxPath+'/cliente/ie')))
            cEnder   :=  Left( NoAcento( Upper(oXml:XPATHGETNODEVALUE(cxPath+'/cliente/endereco'))),TamSx3("A1_END")[1] ) 
            cEnder   :=  iif(Empty(cEnder), "*", cEnder)
            cNumer   :=  NoAcento( Upper(oXml:XPATHGETNODEVALUE(cxPath+'/cliente/numero')))
            cComple  :=  Left( NoAcento( Upper(oXml:XPATHGETNODEVALUE(cxPath+'/cliente/complemento'))), TamSx3("A1_COMPENT")[1])
            cCEP     :=  StrTran(StrTran(StrTran( oXml:XPATHGETNODEVALUE(cxPath+'/cliente/cep'), ".",""), "-",""), "/", "")
            aDadosCEP:=  U_fBuscaCep(cCEP, .T.)
            if !aDadosCEP[1]
                cCodMun  :=  " "
            else
                cCodMun  :=  SubStr(aDadosCEP[3],3,5)
            Endif
            cUF      :=  Upper( oXml:XPATHGETNODEVALUE(cxPath+'/cliente/uf'))
            cUF      :=  iif(Empty(cUF), "EX", cUF)
            cMunic   :=  Left(  DecodeUTF8(  Upper( NoAcento(oXml:XPATHGETNODEVALUE(cxPath+'/cliente/cidade')))),TamSx3("A1_MUN")[1] )
            cMunic   :=  iif(Empty(cMunic), "EX", cMunic)
        Endif
        SA1->( dbgotop())
        if !SA1->( Dbseek( xFilial(cArea) + cCod + " " + cLoja ))
            if Alltrim(cCod) =="25032923"
                MsgAlert(cCod)
            Endif
                aVetor:={ {"A1_CGC"       ,cCNPJ     ,Nil},;   
                    {"A1_GRPCLI"    ,'999'     ,Nil},;  //IMPORTADO API - AJUSTAR        
                    {"A1_COD", cCod       ,Nil},; 
                    {"A1_LOJA"      ,cLoja     ,Nil},; 
                    {"A1_BAIRRO"    ,cBairro   ,Nil},; 
                    {"A1_CEP"       ,cCEP      ,Nil},; 
                    {"A1_EST"       ,cUF       ,Nil},;
                    {"A1_MUN"       ,cMunic    ,Nil},;
                    {"A1_COD_MUN"   ,cCodMun    ,Nil},;
                    {"A1_NOME"      ,cNome     ,Nil},; 
                    {"A1_NREDUZ"    ,cNomeRed  ,Nil},; 
                    {"A1_INSCR"     ,cIE       ,Nil},; 
                    {"A1_COMPENT"   ,cComple   ,Nil},;                         
                    {"A1_GRPTRIB"   ,'999'     ,Nil},;  //IMPORTADO API - AJUSTAR        
                    {"A1_EMAIL"     ,'email@email.com'     ,Nil},;  //IMPORTADO API - AJUSTAR        
                    {"A1_VEND"      ,'000001'  ,Nil},;  //IMPORTADO API - AJUSTAR        
                    {"A1_CODPAIS"   ,'01058'  ,Nil},;  //BR
                    {"A1_PAIS"      ,'105'  ,Nil},;  //BR
                    {"A1_DTINIV"    ,dDatabase  ,Nil},;  //BR
                    {"A1_TEL"       ,'999999'  ,Nil},;  //BR
                    {"A1_CONTRIB"   ,'1'    ,Nil},;  //SIM
                    {"A1_RISCO"     ,'E'    ,Nil},;  //SIM
                    {"A1_LC"        ,10000  ,Nil},;  //10000
                    {"A1_TABELA"    ,'999'  ,Nil},;  //10000                    
                    {"A1_MORADIA"   , 1     ,Nil},;  //10000                    
                    {"A1_TIPO"      , iif( Len(cCNPJ)==14, "R","F")  ,Nil},;          // tratar esse campo no log
                    {"A1_NATUREZ"   , replicate("9",10)   ,Nil},;          // tratar esse campo no log
                    {"A1_PESSOA"    , iif( Len(cCNPJ)==14, "J","F")  ,Nil},;          // tratar esse campo no log
                    {"A1_END"       ,cEnder    ,Nil}} 

                    lMsErroAuto := .F.
                  //  lMSHelpAuto     := .T.
                    //lAutoErrNoFile  := .T.
                    //MSExecAuto({|x,y| Mata030(x,y)},aVetor,3)                                                                      

                    if lMsErroAuto
                        lProcPV :=.F. 
                        Mostraerro()
                        xRet:=""
                    /*
                        cLogTxt += "CNPJ: " + cCNPJ+ " Nome: " + cNome+ CRLF
                        aLogAuto := GetAutoGRLog()
                        //Percorrendo o Log e incrementando o texto (para usar o CRLF você deve usar a include "Protheus.ch")
                        For nAux := 1 To Len(aLogAuto)
                        cLogTxt += aLogAuto[nAux] + CRLF
                        Next*/        
                    Endif
                    
        Endif
        if lProcPV
            aAreaSC5 := SC5->( GetArea())
            cRaiz := '/retorno/pedidos/pedido['+cValToChar(nI)
            cPVBling :=  oXml:XPATHGETNODEVALUE(cRaiz+']/numero')
            SC5->( dbgotop())
            if !SC5->( DbSeek(cPVBling))
                dData:= Stod(strtran(oXml:XPATHGETNODEVALUE(cRaiz+']/data'),"-",""))
                aHeader := {}
                AAdd(aHeader, {"C5_TIPO", "N", NIL})
                AAdd(aHeader, {"C5_CLIENTE", cCod, NIL})
                AAdd(aHeader, {"C5_LOJACLI", cLoja, NIL})
                AAdd(aHeader, {"C5_LOJAENT", "", NIL})
                AAdd(aHeader, {"C5_CONDPAG", "001", NIL})
                AAdd(aHeader, {"C5_NATUREZ", replicate("9",10) , NIL})
                AAdd(aHeader, {"C5_MODAL"  , replicate("9",3) , NIL})
                AAdd(aHeader, {"C5_CONDPAG", replicate("9",3) , NIL})
                AAdd(aHeader, {"C5_TPFRETE", 'S' , NIL})
                AAdd(aHeader, {"C5_ESPECI1", 'IMP BLING' , NIL})
                AAdd(aHeader, {"C5_VOLUME1", 1 , NIL})
                AAdd(aHeader, {"C5_VEND1", '000001' , NIL})
                AAdd(aHeader, {"C5_PORTADO", '422' , NIL})

                nItens := oXml:XPATHCHILDCOUNT('/retorno/pedidos/pedido['+cValToChar(nI)+']/itens')
                aItens :={}
                
                
                AAdd(aHeader, {"C5_PVBLING", cPVBling , NIL})

                for nCont :=1 to nItens
                    aLine := {}
                    cProd     := oXml:XPATHGETNODEVALUE(cRaiz+']/itens/item['+cValToChar(nCont)+']/codigo')
                    VerProd(cProd, oXml)
                    nQtd      := val(oXml:XPATHGETNODEVALUE(cRaiz+']/itens/item['+cValToChar(nCont)+']/quantidade'))
                    nPrecoUni := val(oXml:XPATHGETNODEVALUE(cRaiz+']/itens/item['+cValToChar(nCont)+']/valorunidade'))
                    nPrecoVen := nPrecoUni - Val(oXml:XPATHGETNODEVALUE(cRaiz+']/itens/item['+cValToChar(nCont)+']/descontoItem'))
                    AAdd(aLine, {"C6_PRODUTO", cProd, NIL})
                    AAdd(aLine, {"C6_QTDVEN", nQtd, NIL})
                    AAdd(aLine, {"C6_PRUNIT", nPrecoUni, NIL})
                    AAdd(aLine, {"C6_PRCVEN", nPrecoVen, NIL})
                    AAdd(aLine, {"C6_VALOR", nQtd * nPrecoVen, NIL})
                    AAdd(aLine, {"C6_TES", "999", NIL})
                    AAdd(aItens, aLine)
                Next nCont
            
                //lMSHelpAuto     := .T.
                //lAutoErrNoFile  := .T.
                lMsErroAuto     := .F.
                //MsExecAuto({|x, y, z| MATA410(x, y, z)}, aHeader, aItens, 3)

                if lMsErroAuto

                    Mostraerro()
                    xRet :=""
                /*
                    aLogAuto := GetAutoGRLog()
                    //Percorrendo o Log e incrementando o texto (para usar o CRLF você deve usar a include "Protheus.ch")
                    For nAux := 1 To Len(aLogAuto)
                    cLogTxt += aLogAuto[nAux] + CRLF
                    Next
                    MemoWrite(cArquivo, cLogTxt)*/
                Endif
            Endif
        Endif
    Next nI
    nPage := nPage +1
Enddo
MemoWrite(cArquivo, cLogTxt)
return

static function VerProd(cProd, oXml)
Local aArea := GetArea()
SB1->( dbgotop())
if !SB1->( DbSeek( xFilial("SB1") + cProd))
    cDesc   := Upper(NoAcento(oXml:XPATHGETNODEVALUE(cRaiz+']/itens/item['+cValToChar(nCont)+']/descricao')))
    cDesc   := Left( cDesc,TamSx3("B1_DESC")[1] )
    cUN     := Upper(DecodeUTF8( NoAcento(oXml:XPATHGETNODEVALUE(cRaiz+']/itens/item['+cValToChar(nCont)+']/un'))))
    cUN     :=  u_validUM(cUN)
    cNcm    := '00000000'
    cTipo   :="PA"
    cArmaz  := "01"
    cMarca  := ""
    nPesoBru:= Val(oXml:XPATHGETNODEVALUE(cRaiz+']/itens/item['+cValToChar(nCont)+']/pesoBruto'))
    cOrigem :="0"
    aVetor:= { {"B1_COD" ,cProd ,NIL},;
                {"B1_DESC" , cDesc,NIL},;
                {"B1_TIPO" ,cTipo ,Nil},;
                {"B1_UM" ,cUN ,Nil},;
                {"B1_LOCPAD" ,cArmaz ,Nil},;
                {"B1_PICM" ,0 ,Nil},;
                {"B1_IPI" ,0 ,Nil},;
                {"B1_POSIPI" ,cNcm ,Nil},;
                {"B1_GRUPO" ,"0" ,Nil},;   // verificar como tratar esse camp
                {"B1_SGRUPO" ,"99" ,Nil},;   // IMPORTADO
                {"B1_GRTRIB" ,"007" ,Nil},; // verificar como tratar esse campo
                {"B1_SMARCA" , iif ( Empty(cMarca), '02' , cMarca),Nil},;
                {"B1_CONTRAT" ,"N" ,Nil},;
                {"B1_PESBRU" ,nPesoBru,Nil},;
                {"B1_ESTSEG" ,9,Nil},;
                {"B1_ORIGEM" ,cOrigem,Nil},;
                {"B1_LOCALIZ" ,"N" ,Nil}}
        
                // verificar se o NCM está cadastrado na tabela 
                lMsErroAuto := .F.
                MSExecAuto({|x,y| Mata010(x,y)},aVetor,3)
                // verifica se ocorreu erro
                if lMsErroAuto
                    // mostra erro
                    Mostraerro()
                    xTst:=""
                else
                    CriaSB2(cProd,'01')
                endIf                
Endif

RestArea(aArea)
return
