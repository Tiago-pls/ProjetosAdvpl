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
deletado o gatilho:
    A1_SUBCOD 
    C6_QTDVEN
Criado índice C5_BLING

compilar o fontes:
    roberlo_fata1002.prw
    fBuscaCEP.prw
    roberlo_pe_MATA460_M460NUM.prw

Tirar obrigatoriedade dos campos:
    A1_TABELA
    A1_INSCR

    tirar A410MultT()
*/
//---------------------------------------------------------------------

user function ApiNfe() 
Local cUrl			:=  Alltrim(GetMv("RB_URLNFE"))
Local cGetParams	:= ""
Local nTimeOut		:= 400
Local aHeadStr		:= {"Content-Type: application/json"}
Local cHeaderGet	:= ""
Local cRetWs		:= ""
Local cApiKey       := "&apikey=" + Alltrim(GetMv("RB_APIKEY")) 
Local cDataIniBling := SubStr(GetMv("RB_DTINIBL"),7,2)+ "/" +SubStr(GetMv("RB_DTINIBL"),5,2)+ "/" +SubStr(GetMv("RB_DTINIBL"),1,4)
Local cDataAtual    := SubStr( Dtos( dDatabase),7,2)+ "/" +SubStr( Dtos( dDatabase),5,2)+ "/" +SubStr( Dtos( dDatabase),1,4)
Local cFIlter       := "&filters=dataEmissao["+ cDataIniBling + " TO "+ cDataAtual+"]"
Local lGetWS        := .T.
Local nPage         := 1
Local cArea         := "SA1"
Local oXML          := TXMLManager():New()

Local oXMLProd      := TXMLManager():New()
Local cLogTxt       := ""
Local cArquivo      := "C:\TOTVS\"

Default lJob        := .T.
private cError      :=""
Private cWarning    :=""
private oXMLNfe     := TXMLManager():New()
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
    nNfe := oXml:XPATHCHILDCOUNT('/retorno/notasfiscais')

    For nI := 1 to nNfe
        lProcPV := .T.
        cxPath  := '/retorno/notasfiscais/notafiscal['+cValToChar(nI)+']'
        cURLXML   :=  alltrim(oXml:XPATHGETNODEVALUE(cxPath+'/xml'))

        if !Empty( cURLXML)
            cRetNfe:= HttpGet(cURLXML, cGetParams, nTimeOut, aHeadStr, @cHeaderGet)
            // Faz o parser
            oXMLNfe := XmlParser( cRetNfe, "_", @cError, @cWarning )

            If oXMLNfe == Nil       
                MsgStop("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
                Return .F.
            Endif
            // recuperar os dados
            cSerie:= Strzero(val(oXMLNfe:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT),3)
            cNfe  := Strzero(val(oXMLNfe:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT),9)
            cNfeBling := cSerie + cNfe
            SC5->( DbOrderNickName("PVBLING"))
            SC5->( dbgotop())
            If !SC5->( DbSeek(cNfeBling))
                if type("oXMLNfe:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ") =="O"
                    cvar := "_CNPJ"
                else
                    cVar :="_CPF"
                end
                cCGC := &("oXMLNfe:_NFEPROC:_NFE:_INFNFE:_DEST:"+cVar+":TEXT")
                cCod  :=  SubStr(cCGC, 1,8)
                cLoja :=  SubStr(cCGC, 9,4)
                dEmissao := Stod(StrTran(SubStr(oXMLNfe:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT,1,10), "-",""))
                SA1->( dbgotop())
                if !SA1->( Dbseek( xFilial(cArea) + cCod + " " + cLoja ))
                    aVetor    := RetCliente(oXMLNfe)                    
                    lMsErroAuto := .F.
                    MSExecAuto({|x,y| Mata030(x,y)},aVetor,3) 
                    if lMsErroAuto
                        Mostraerro()
                        lProcPV :=.F. 
                    Endif    
                Endif
                if lProcPV
                    nInic:=  At( '<det ',cRetNfe )
                    nFim := RAt( '</det>',cRetNfe ) 
                    if nInic > 0
                        cTextoProd := "<ini>" + SubStr( cRetNfe, nInic , nFim - nInic +6)+"</ini>"
                        lOk := oXMLProd:Parse(cTextoProd)
                        If !lOk       
                            MsgStop(oXMLProd:Error(),'XML Parser Error')
                            Return .F.
                        Endif

                            // Determina a quantidade de itens
                        nItens := oXMLProd:XPATHCHILDCOUNT('/ini')
                        nQtdErros :=0
                        aItens :={}
                        cItem := "00"
                        For nContItens := 1 to nItens
                            aLine := {}
                            cProd:= alltrim(oXmlProd:XPATHGETNODEVALUE('/ini/det['+ cValtoChar(nContItens) + ']/prod/cProd'))
                            cCFOP:= alltrim(oXmlProd:XPATHGETNODEVALUE('/ini/det['+ cValtoChar(nContItens) + ']/prod/CFOP'))
                            cDesc := val(oXmlProd:XPATHGETNODEVALUE('/ini/det['+ cValtoChar(nContItens) + ']/prod/vDesc'))
                            // ICMS
                            cICMS00:= alltrim(oXmlProd:XPATHGETNODEVALUE('/ini/det['+ cValtoChar(nContItens) + ']/imposto/ICMS/ICMS00/CST'))
                            cICMS10:= alltrim(oXmlProd:XPATHGETNODEVALUE('/ini/det['+ cValtoChar(nContItens) + ']/imposto/ICMS/ICMS10/CST'))
                            cICMS60:= alltrim(oXmlProd:XPATHGETNODEVALUE('/ini/det['+ cValtoChar(nContItens) + ']/imposto/ICMS/ICMS60/CST'))
                            DO CASE
                                CASE !Empty(cICMS00)
                                    cICMS :=cICMS00
                                CASE !empty(cICMS10)
                                    cICMS :=cICMS10
                                CASE !empty(cICMS60)
                                    cICMS :=cICMS60
                                OTHERWISE 
                            ENDCASE
                            cPISCOF:= alltrim(oXmlProd:XPATHGETNODEVALUE('/ini/det['+ cValtoChar(nContItens) + ']/imposto/PIS/PISAliq/CST'))
                            
                           
                            cTES:= RestTES(cCFOP, cICMS, cPISCOF)

                            cItem := Soma1(cItem)
                            cProd:= Upper(Left(Strtran(StrTran(cProd," ",""),"-",""),TamSx3("B1_COD")[1]))
                            nQtdErros += iif( VerProd(cProd, oXmlProd),0,1)
                            nQtd      := Val(alltrim(oXmlProd:XPATHGETNODEVALUE('/ini/det['+ cValtoChar(nContItens) + ']/prod/qCom')))
                            nPrecoUni := Val(alltrim(oXmlProd:XPATHGETNODEVALUE('/ini/det['+ cValtoChar(nContItens) + ']/prod/vUnCom')))
                            nPrecoVen :=  ((nPrecoUni * nQtd) - cDesc) / nQtd
                            AAdd(aLine, {"C6_PRODUTO", cProd, NIL})
                            AAdd(aLine, {"C6_QTDVEN", nQtd, NIL})
                            AAdd(aLine, {"C6_PRUNIT", nPrecoUni, NIL})
                            AAdd(aLine, {"C6_PRCVEN", nPrecoVen , NIL})
                            AAdd(aLine, {"C6_VALOR", nQtd * nPrecoVen, NIL})
                            AAdd(aLine, {"C6_TES", cTES, NIL})
                            AAdd(aLine, {"C6_ITEM", cItem, NIL})
                            AAdd(aLine, {"C6_VALDESC", cDesc, NIL})
                            AAdd(aItens, aLine)
                        Next nContItens
                     
                    Endif
                    If nQtdErros == 0
                        aHeader := {}
                        //há desconto?
                        nDesc :=val(oXMLNfe:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:TEXT)
                        
                        //há Frete
                        cTpFrete:=oXMLNfe:_NFEPROC:_NFE:_INFNFE:_TRANSP:_MODFRETE:TEXT
                                                
                        DO CASE
                            CASE cTpFrete =='0'
                                cTpFrete :='C'
                            CASE cTpFrete =='1'
                                cTpFrete :='F'     
                            CASE cTpFrete =='2'
                                cTpFrete :='T'
                            CASE cTpFrete =='3'
                                cTpFrete :='R'   
                            CASE cTpFrete =='4'
                                cTpFrete :='D'
                            CASE cTpFrete =='9'
                                cTpFrete :='S'                                                                                        
                        ENDCASE

                        nFrete :=val(oXMLNfe:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VFRETE:TEXT)

                        AAdd(aHeader, {"C5_TIPO", "N", NIL})
                        AAdd(aHeader, {"C5_CLIENTE", cCod, NIL})
                        AAdd(aHeader, {"C5_LOJACLI", cLoja, NIL})
                        AAdd(aHeader, {"C5_CLIENTE", cCod, NIL})
                        AAdd(aHeader, {"C5_LOJAENT", cLoja, NIL})
                        AAdd(aHeader, {"C5_CONDPAG", "001", NIL})
                        AAdd(aHeader, {"C5_MODAL"  , replicate("9",3) , NIL})
                        AAdd(aHeader, {"C5_CONDPAG", replicate("9",3) , NIL})
                        AAdd(aHeader, {"C5_TPFRETE", cTpFrete , NIL})
                        AAdd(aHeader, {"C5_FRETE"  , nFrete , NIL})
                        AAdd(aHeader, {"C5_ESPECI1", 'IMP BLING' , NIL})
                        AAdd(aHeader, {"C5_VOLUME1", 1 , NIL})
                        AAdd(aHeader, {"C5_VEND1", '000001' , NIL})
                        AAdd(aHeader, {"C5_PORTADO", '422' , NIL})
                        AAdd(aHeader, {"C5_PVBLING", cNfeBling , NIL})
                        AAdd(aHeader, {"C5_EMISSAO", dEmissao , NIL})
                        lMsErroAuto     := .F.
                        dDatabase := dEmissao
                        MsExecAuto({|x, y, z| MATA410(x, y, z)}, aHeader, aItens, 3)

                        if lMsErroAuto
                            Mostraerro()
                            MemoWrite(cArquivo + Dtos(Date())+Time()+".txt", cLogTxt)

                        else                        
                            cSerieNF := cvaltochar(val(SubStr( cNfeBling, 1,3)))
                            cPedido := SC5->C5_NUM
                            nLibPedCli := LibPedCli(xFilial("SC5"), cPedido)
                            If nLibPedCli > 0
                                pedToNf(xFilial("SC5"), cPedido, cSerieNF)
                                //gravação chave Nfe
                                Begin Transaction
                                    RecLock('SF2', .F.)
                                        F2_CHVNFE   := SubStr( cURLXML , Rat( '=',cURLXML) + 1, len (cUrlXML))
                                    SF2->(MsUnlock())                                    
                                    RecLock('SF3', .F.)
                                        F3_CHVNFE   := SubStr( cURLXML , Rat( '=',cURLXML) + 1, len (cUrlXML))
                                    SF3->(MsUnlock())
                                    
                                //Finalizando controle de transações
                                End Transaction
                            Endif                            
                        Endif
                    Endif                    
                Endif
            Endif
        Endif        
    Next nI
    nPage := nPage +1
Enddo
MemoWrite(cArquivo, cLogTxt)
return

Static function RetCliente(oXMLNfe)

cBairro    := Left(NoAcento(Upper(oXMLNfe:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_XBAIRRO:TEXT)), TamSx3("A1_BAIRRO")[1])
cCEP       := oXMLNfe:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_CEP:TEXT
cUF        := oXMLNfe:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:TEXT
cMunic     := Left(NoAcento(Upper(oXMLNfe:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_XMUN:TEXT)), TamSx3("A1_MUN")[1] )
aDadosCEP  :=  U_fBuscaCep(cCEP, .T.)
cNome      := oXMLNfe:_NFEPROC:_NFE:_INFNFE:_DEST:_xNome:TEXT
cNomeFant  := oXMLNfe:_NFEPROC:_NFE:_INFNFE:_DEST:_xNome:TEXT 
cEnder     := Left(NoAcento(Upper(oXMLNfe:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_xLgr:TEXT)),TamSx3("A1_END")[1] ) 
cNome      := oXMLNfe:_NFEPROC:_NFE:_INFNFE:_DEST:_xNome:TEXT
cNomeFant  := oXMLNfe:_NFEPROC:_NFE:_INFNFE:_DEST:_xNome:TEXT  

if !aDadosCEP[1]
    cCodMun  :=  " "
else
    cCodMun  :=  SubStr(aDadosCEP[3],3,5)
Endif

aCliente:={ {"A1_CGC"     ,cCGC     ,Nil},;   
		  {"A1_GRPCLI"    ,'999'     ,Nil},;  //IMPORTADO API - AJUSTAR        
		  {"A1_COD"       ,cCod       ,Nil},; 
		  {"A1_LOJA"      ,cLoja     ,Nil},; 
		  {"A1_BAIRRO"    ,cBairro   ,Nil},; 
		  {"A1_CEP"       ,cCEP      ,Nil},; 
		  {"A1_EST"       ,cUF       ,Nil},;
		  {"A1_MUN"       ,cMunic    ,Nil},;
		  {"A1_COD_MUN"   ,cCodMun    ,Nil},;
		  {"A1_NOME"      ,cNome     ,Nil},; 
		  {"A1_NREDUZ"    ,cNomeFant  ,Nil},; 
		  {"A1_COMPENT"   ,' '   ,Nil},;                         
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
		  {"A1_TABELA"    ,' '  ,Nil},;  //10000                    
		  {"A1_MORADIA"   , 1     ,Nil},;  //10000                    
		  {"A1_TIPO"      , iif( Len(cCGC)==14, "R","F")  ,Nil},;          // tratar esse campo no log
		  {"A1_NATUREZ"   , replicate("9",10)   ,Nil},;          // tratar esse campo no log
		  {"A1_PESSOA"    , iif( Len(cCGC)==14, "J","F")  ,Nil},;          // tratar esse campo no log
		  {"A1_END"       ,cEnder    ,Nil}}

Return aCliente

static function VerProd(cProd, oXml)
Local aArea := GetArea()
Local lRet := .T.
SB1->( dbgotop())

if !SB1->( DbSeek( xFilial("SB1") + cProd))
    cDesc   := Upper(NoAcento(oXml:XPATHGETNODEVALUE('/ini/det['+ cValtoChar(nContItens) + ']/prod/xProd')))
    cDesc   := Left( cDesc,TamSx3("B1_DESC")[1] )
    cUN     := Upper(DecodeUTF8( NoAcento(oXml:XPATHGETNODEVALUE('/ini/det['+ cValtoChar(nContItens) + ']/prod/uTrib'))))
    cUN     :=  u_validUM(cUN)
    cNcm    := '00000000'
    cTipo   :="PA"
    cArmaz  := "01"
    cMarca  := ""
    nPesoBru:= 0
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
                    lRet := .F.
                else
                    //CriaSB2(cProd,'01')
                endIf                
Endif
RestArea(aArea)
return lRet


/*/{Protheus.doc} LibPedCli
@type			function
@description	Liberar pedido de venda
@author			Tiago Santos
@since			11/06/2021
@version		1.0
/*/
Static Function LibPedCli(cFilPed, cNumPed)
	Local aArea := GetArea()
	Local nValTot := 0
	Local nQtd	:= 0

	SF4->(dBSetOrder(1))
	// Posiciona no Cabeçalho do Pedido
	SC5->(DBSetOrder(1))
	SC5->(DbSeek(cFilPed+cNumPed))
	// Posiciona nos Itens do Pedido
	SC6->(DBSetOrder(1))
	If SC6->(DbSeek(cFilPed+cNumPed))

		While !SC6->(Eof()) .And. SC6->C6_FILIAL == cFilPed .And. SC6->C6_NUM == cNumPed
			nValTot += SC6->C6_VALOR
     		
     		// Posiciona no TES de acordo com o item
			SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES))
     
			nQtdLib := SC6->C6_QTDVEN
			
			RecLock("SC6", .F.) //Forca a atualizacao do Buffer no Top
			
				Begin Transaction
					/*
					±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
					±±³Funcao    ³MaLibDoFat³ Autor ³Eduardo Riera          ³ Data ³09.03.99 ³±±
					±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
					±±³Descri+.o ³Liberacao dos Itens de Pedido de Venda                      ³±±
					±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
					±±³Retorno   ³ExpN1: Quantidade Liberada                                  ³±±
					±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
					±±³Transacao ³Nao possui controle de Transacao a rotina chamadora deve    ³±±
					±±³          ³controlar a Transacao e os Locks                            ³±±
					±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
					±±³Parametros³ExpN1: Registro do SC6                                      ³±±
					±±³          ³ExpN2: Quantidade a Liberar                                 ³±±
					±±³          ³ExpL3: Bloqueio de Credito                                  ³±±
					±±³          ³ExpL4: Bloqueio de Estoque                                  ³±±
					±±³          ³ExpL5: Avaliacao de Credito                                 ³±±
					±±³          ³ExpL6: Avaliacao de Estoque                                 ³±±
					±±³          ³ExpL7: Permite Liberacao Parcial                            ³±±
					±±³          ³ExpL8: Tranfere Locais automaticamente                      ³±±
					±±³          ³ExpA9: Empenhos ( Caso seja informado nao efetua a gravacao ³±±
					±±³          ³       apenas avalia ).                                     ³±±
					±±³          ³ExpbA: CodBlock a ser avaliado na gravacao do SC9           ³±±
					±±³          ³ExpAB: Array com Empenhos previamente escolhidos            ³±±
					±±³          ³       (impede selecao dos empenhos pelas rotinas)          ³±±
					±±³          ³ExpLC: Indica se apenas esta trocando lotes do SC9          ³±±
					±±³          ³ExpND: Valor a ser adicionado ao limite de credito          ³±±
					±±³          ³ExpNE: Quantidade a Liberar - segunda UM                    ³±±
					*/
					nQtd := MaLibDoFat(SC6->(RecNo()),@nQtdLib,.T.,.T.,.F.,.T.,.F.,.F.)
	          		
				End Transaction
			SC6->(MsUnLock())
			SC6->(dbSkip())
		EndDo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o Flag do Pedido de Venda                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Begin Transaction
			SC5->(MaLiberOk({cNumPed},.F.))
		End Transaction
	EndIf

	RestArea(aArea)

Return nQtd



/*/{Protheus.doc} LibPedCli
@type			function
@description	Liberar pedido de venda
@author			Pedro Souza
@since			11/06/2021
@version		1.0
/*/
Static Function pedToNf(cFilPed, cNumPed, cSerie)

Local aArea		:= GetArea()
	Local aPvlNfs   := {}
	// Local nI        := 0
	Local cNota
//	IncProc("Faturando o Pedido: "+cFilPed+"/"+cNumPed)
	
	SC9->(DbSetOrder(1))
	SC9->(DbSeek(cFilPed+cNumPed) )		// FILIAL+NUMERO+ITEM
	While !SC9->(Eof()) .and. SC9->C9_FILIAL+SC9->C9_PEDIDO == cFilPed+cNumPed
		SC5->(DbSetOrder(1))
		SC5->(DbSeek(xFilial("SC5")+cNumPed ) ) // FILIAL+NUMERO
		SC6->(DbSetOrder(1))
		SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM+SC9->C9_ITEM) )	// FILIAL+NUMERO+ITEM
		SE4->(DbSetOrder(1))
		SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG) )			// FILIAL+CONDPAG
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO) )			// FILIAL+PRODUTO
		SB2->(DbSetOrder(1))
		SB2->(DbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL) ) // FILIAL+PRODUTO+LOCAL
		SF4->(DbSetOrder(1))
		SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES ))                                   //FILIAL+CODIGO
          
		aAdd( aPvlNfs , {	SC5->C5_NUM, ;		// NUMERO PEDIDO
							SC9->C9_ITEM,;		// ITEM PEDIDO
							SC9->C9_SEQUEN,;	// SEQUENCIA
							SC9->C9_QTDLIB,;	// QUANTIDADE
							SC9->C9_PRCVEN,;	// PRECO VENDA
							SC9->C9_PRODUTO,;	// PRODUTO
							.F.,;
							SC9->(RecNo()),;
							SC5->(RecNo()),;
							SC6->(RecNo()),;
							SE4->(RecNo()),;
							SB1->(RecNo()),;
							SB2->(RecNo()),;
							SF4->(RecNo())})          
		SC9->(dbSkip())
	EndDo
     
	cNota	:= maPvlNfs(aPvlNfs,cSerie,.F.,.F.,.F.,.F.,.F.,0,0,.F.,.F.)
	aPvlNfs := {}	
	RestArea(aArea)
Return cNota + cSerie


 // criar tabela com os valores
static function RestTES(cCFOP, cICMS, cPISCOF)
cRet :="999"
if select("ZRA") == 0
    DbSelectArea("ZRA")
Endif

ZRA->(dbSetorder(1))
ZRA->(dbGotop())

if ZRA->( Dbseek( cCFOP+ cICMS + cPISCOF))
    cRet := ZRA->ZRA_TES
endif
Return cRet
