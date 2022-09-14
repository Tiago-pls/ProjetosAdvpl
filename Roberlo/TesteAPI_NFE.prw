#include 'protheus.ch'
//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552
@type			function
@description	Programa de inicialização do Portal THF/Portinari do TAF (ESOCIAL).
@author			Tiago Santos
@since			03/05/2021
@version		1.0
/*/
//---------------------------------------------------------------------

user function TesteNfe() 
Local cUrl			:= iif ( nTpAPI ==1, Alltrim(GetMv("RB_URLAPIC")) , Alltrim(GetMv("RB_ULRPAG")))
Local cURLNFe       :="https://www.bling.com.br/relatorios/nfe.xml.php?s&chaveAcesso=42200222841412000430550010000000201484396287"
Local cGetParams	:= ""
Local nTimeOut		:= 200
Local aHeadStr		:= {"Content-Type: application/json"}
Local cHeaderGet	:= ""
Local cRetWs		:= ""
Local oObjJson		:= Nil
Local oObjClie		:= Nil
Local aRet          := {}
Local cApiKey       := "/json&apikey=" + Alltrim(GetMv("RB_APIKEY")) 
Local cFIlter       :="" // Somente Produtos Ativos
Local lGetWS        := .T.
Local nPage         := 1
local  cPath        :="C:\temp\"
Local cFileLog      := NomeAutoLog()
Local cArea         := iif ( nTpAPI ==1, "SA1" , "SA2")
local cTPObj1       := iif ( nTpAPI ==1, "PEDIDOS" , "ContasPagar")
local cTPObj2       := iif ( nTpAPI ==1, "PEDIDO" , "ContaPagar:FORNECEDOR")
local cObjRet       := iif ( nTpAPI ==1, "PEDIDO:CLIENTE" , "CONTAPAGAR:FORNECEDOR")
local cID           := iif ( nTpAPI ==1, "PEDIDO:CLIENTE" , ":IDCONTATO")
Local cArq          :="C:\Temp\"+Dtos(dDatabase) + StrTran(TIME(),":","_") + ".TXT"
Local cTexto        :=""
Default lJob        := .F.


cUrl += "/page="

While lGetWS

    cRetWs	:= HttpGet(cURLNFe  +cFIlter, cGetParams, nTimeOut, aHeadStr, @cHeaderGet)

    If !FWJsonDeserialize(cRetWs, @oObjJson) // Falha
        if lJob
            aAdd(aRet,.F.)
            aAdd(aRet,"Falha na consulta API!")
            Return aRet
        Else
            MsgStop("Ocorreu erro no processamento do Json.")
            Return Nil
        Endif

    ElseIf  At('{"retorno":{"erros":',cRetWs) > 0 //AttIsMemberOf(oObjJson,"ERRO")
        // não encontrou
        EXIT
    Endif
Enddo
