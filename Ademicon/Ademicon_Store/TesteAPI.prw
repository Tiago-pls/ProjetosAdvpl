#INCLUDE "TOTVS.CH"
#INCLUDE 'TBICONN.CH'

//#INCLUDE "XMLCSVCS.CH"
//-------------------------------------------------------------------------------------------------------------------------------------------
// RbPost - realizando um post em https://api.tabletcloud.com.br/
//-------------------------------------------------------------------------------------------------------------------------------------------
//Permite emular um client HTTP - Hypertext Transfer Protocol, através de uma função AdvPL, postando um bloco de informações 
//para uma determinada URL em um servidor Web, utilizando o método POST, permitindo a passagem de parâmetros adicionais via URL e 
//aguardando por um tempo determinado (time-out) pela resposta do servidor solicitado.
//------------------------------------------------------------------------------------------------------------------------------------------
//SMS - 21/05/2021
//------------------------------------------------------------------------------------------------------------------------------------------

user function RbPost()
    Local cUrl          := "https://testapi.maxipago.net/UniversalAPI/postXML"
    Local nTimeOut      := 120
    Local aHeadOut      := {}
    Local cHeadRet      := ""
    Local sPostRet      := ""
    Local cPostData     := ""
    Local cUserName     := 'central@tabletcloud.com.br'
    Local cPassword     := 'dtat-2123-5110-5504%401707212'
    Local cClientId     := '8135'
    Local cCliSecret    := 'LJWT-5218-4485-8454'
    Local cParseJson    := ''   
    Local cAccessTk     := ''
    Local oJson         := JsonObject():New()

	
    //Trava rotina para ser executada somente por um agente
    If  .F. // !LockByName("RbPost",.T.,.F.)
        Conout("[RbPost] - Rotina está sendo executada, execução cancelada. . ")
    else

        cPostData := 'username=' + escape(cUserName)
        cPostData += '&password=' + cPassword
        cPostData += '&grant_type=password&client_id=' + cClientId
        cPostData += '&client_secret=' + cCliSecret
        cPostData :=""
        
        cData :='<?xml version="1.0" encoding="UTF-8"?>'
        cData +='<transaction-request>'    
        cData +='	<version>3.1.1.15</version>'    
        cData +='	<verification>'        
        cData +='		<merchantId>24303</merchantId>'        
        cData +='		<merchantKey>e8aos623evu59hipm00uypfs</merchantKey>'    
        cData +='	</verification>'    
        cData +='	<order>'        
        cData +='		<sale>'            
        cData +='			<processorID>1</processorID>'            
        cData +='			<referenceNum>123213</referenceNum>'            
        cData +='			<fraudCheck>N</fraudCheck>'            
        cData +='			<billing>'                
        cData +='				<name>Carlos Eduardo Augusto Araújo</name>'                
        cData +='				<address>Rua Comendador J. G. Araújo, 296</address>'                
        cData +='				<address2>11º Andar</address2>'                
        cData +='				<district>Santo Antônio</district>'                
        cData +='				<city>Manaus</city>'                
        cData +='				<state>AM</state>'                
        cData +='				<postalcode>69029-130</postalcode>'                
        cData +='				<country>BR</country>'                
        cData +='				<phone>(99) 99999-9999</phone>'                
        cData +='				<email>teste@maxipago.com</email>'                
        cData +='				<companyName>maxiPago!</companyName>'                
        cData +='				<type>Individual</type>'                
        cData +='				<gender>M</gender>'                
        cData +='				<birthDate>1959-05-25</birthDate>'                
        cData +='				<documents>'                    
        cData +='					<document>'                        
        cData +='						<documentType>CPF</documentType>'                        
        cData +='						<documentValue>920.323.047-59</documentValue>'                    
        cData +='					</document>'                
        cData +='				</documents>'            
        cData +='			</billing>'            
        cData +='			<transactionDetail>'                
        cData +='				<payType>'                    
        cData +='					<creditCard>'                        
        cData +='						<number>5111111111111100</number>'                        
        cData +='						<expMonth>12</expMonth>'                        
        cData +='						<expYear>2025</expYear>'                        
        cData +='						<cvvNumber>100</cvvNumber>'                    
        cData +='					</creditCard>'                
        cData +='				</payType>'            
        cData +='			</transactionDetail>'            
        cData +='			<payment>'                
        cData +='				<chargeTotal>10.00</chargeTotal>'                
        cData +='				<shippingTotal>10.00</shippingTotal>'                
        cData +='				<currencyCode>BRL</currencyCode>'                
        cData +='				<softDescriptor>mx5</softDescriptor>'                
        cData +='				<creditInstallment>'                    
        cData +='					<numberOfInstallments>2</numberOfInstallments>'                    
        cData +='					<chargeInterest>N</chargeInterest>'                
        cData +='				</creditInstallment>'            
        cData +='			</payment>'        
        cData +='		</sale>'    
        cData +='	</order>'
        cData +='</transaction-request>"

        aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
        aadd(aHeadOut,'Content-Type: application/xml')
        sPostRet := HttpPost(cUrl,"",cPostData,nTimeOut,aHeadOut,@cHeadRet)
        
        if !empty(sPostRet)
            conout("HttpPost Ok")
            varinfo("WebPage", sPostRet)
        else
            conout("HttpPost Failed.")
            varinfo("Header", cHeadRet)
        Endif

            
        cParseJson := oJson:FromJson(sPostRet)
        if ValType(cParseJson) == "C"
            cMsgErro := "Falha na baixa 1 da lista de ids ML - ao transformar texto em objeto json -> Erro: " + cParseJson
            conout("Falha ao transformar texto em objeto json. Erro: " + cParseJson)
        Else
            // Faz o Parser da mensagem JSon e extrai para Array (aJsonfields) e cria tambem um HashMap para os dados da mensagem (oJHM)
            cAccessTk   := oJson["access_token"]
            processa( {|| U_RbHttpGet(cAccessTk) }, "Conectando...", "Processando aguarde...", .f.)
        Endif
        //Libera rotina 
		UnLockByName("RbPost",.T.,.F.)	
    endif
   
    RPCClearEnv()
Return
