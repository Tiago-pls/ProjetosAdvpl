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

    RpcSetType(3)//Nao consome licencas
	PREPARE ENVIRONMENT EMPRESA '03' FILIAL '010101' TABLES 'SA1','SE1','SE5','SED'
	
    //Trava rotina para ser executada somente por um agente
    If  .F. // !LockByName("RbPost",.T.,.F.)
        Conout("[RbPost] - Rotina está sendo executada, execução cancelada. . ")
    else

        cPostData := 'username=' + escape(cUserName)
        cPostData += '&password=' + cPassword
        cPostData += '&grant_type=password&client_id=' + cClientId
        cPostData += '&client_secret=' + cCliSecret
        
        aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
        aadd(aHeadOut,'Content-Type: application/x-www-form-urlencoded')
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
