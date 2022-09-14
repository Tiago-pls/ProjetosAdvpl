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

user function ApiInic(nTpAPI)
Local cUrl			:= Alltrim(GetMv("RB_URLAPIC")) 
Local cGetParams	:= ""
Local nTimeOut		:= 200
Local aHeadStr		:= {"Content-Type: application/json"}
Local cHeaderGet	:= ""
Local cRetWs		:= ""
Local oObjJson		:= Nil
Local aRet          := {}
Local cApiKey       := "/json&apikey=" + Alltrim(GetMv("RB_APIKEY")) 
Local cFIlter       :="" // Somente Produtos Ativos
Local lGetWS        := .T.
Local nPage         := 3
local  cPath        :="C:\temp\"
Local cFileLog := NomeAutoLog()
Default lJob        := .F.

While lGetWS
//cUrl :="https://bling.com.br/Api/v2/pedido/221/jason&apikey=bd6bc6c9a31346969d63970dabe0bf71f0073def5af51133a78d9c44fafc32b719e49093"    

    cRetWs	:= HttpGet(cUrl + cValToChar(nPage) + cApiKey +cFIlter, cGetParams, nTimeOut, aHeadStr, @cHeaderGet)
   // cRetWs	:= HttpGet(cUrl, cGetParams, nTimeOut, aHeadStr, @cHeaderGet)

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
        Return Nil
    else
        
        nPedidos := Len( oObjJson:RETORNO:PEDIDOS)
         
        if select("SA1") ==0 // Clienes
            DbSelectArea("SA1")
        Endif
        SA1->(DbSetorder(1))

        For nCont := 1 to nPedidos
            aCliente :=u_RetArray(oObjJson:retorno:PEDIDOS[nCont]:PEDIDO:CLIENTE)
            lGrava :=.T.
            if(aCliente[1] =="0")        
                lGrava := .F.
            Endif
            if lGrava
                SA1->( dbgotop())
                if !SA1->( Dbseek( xFilial("SA1") + aCliente[1] + " " + aCliente[2] ))

                    aVetor:={{"A1_COD",aCliente[1] ,Nil},; 
                    {"A1_LOJA"      ,aCliente[2]   ,Nil},; 
                    {"A1_BAIRRO"    ,aCliente[3]   ,Nil},; 
                    {"A1_CEP"       ,aCliente[5]   ,Nil},; 
                    {"A1_EST"       ,aCliente[13]  ,Nil},;
                    {"A1_MUN"       ,aCliente[6]   ,Nil},;
                    {"A1_NOME"      ,aCliente[12]  ,Nil},; 
                    {"A1_NREDUZ"     ,aCliente[12]  ,Nil},; 
                    {"A1_INSCR"     ,aCliente[11]  ,Nil},; 
                    {"A1_COMPENT"   ,aCliente[7]   ,Nil},;         
                    {"A1_CGC"       ,aCliente[14]   ,Nil},;         
                    {"A1_TIPO"      , 'F'           ,Nil},;          // tratar esse campo no log
                    {"A1_NATUREZ"   , 'ISS'         ,Nil},;          // tratar esse campo no log
                    {"A1_PESSOA"   , aCliente[15]   ,Nil},;          // tratar esse campo no log
                    {"A1_END"       ,aCliente[9]   ,Nil}} 

                    lMsErroAuto := .F.

                    if !empty(aCliente[14] ) // CNPJ
                        MSExecAuto({|x,y| Mata030(x,y)},aVetor,3)
                    Endif
                    
                    // verifica se ocorreu erro
                    if lMsErroAuto
                        // mostra erro
                      // GravaErro()
                        
                    endIf
                endif
            Endif
            Next nI
    Endif
    nPage := nPage +1
Enddo
return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552
@type			function
@description	Função para validar Unidades de Medidas divergentes
@author			Tiago Santos
@since			03/05/2021
@version		1.0
/*/
//---------------------------------------------------------------------

user function RetArray(oObj)
Local aRet :={}

if (Empty(oObj:CNPJ))
    Aadd(aRet, "0")
    Return aRet
endif
cCNPJ := StrTran( StrTran( StrTran( DecodeUTF8( oObj:CNPJ), ".", ""), "/", ""), "-", "")

Aadd(aRet, SubStr(cCNPJ, 1,8)) // A1_COD
Aadd(aRet, iif (valtype(oObj:CNPJ)=="U","", SubStr(cCNPJ, 9,4))) // A1_LOJA
Aadd(aRet, iif (valtype(oObj:BAIRRO)=="U","", NoAcento( Upper( DecodeUTF8( oObj:BAIRRO)))))
Aadd(aRet, iif (valtype(oObj:CELULAR)=="U","", DecodeUTF8( oObj:CELULAR)))
Aadd(aRet, iif (valtype(oObj:CEP)=="U","", StrTran(StrTran(DecodeUTF8( oObj:CEP) , "-",""), ".","")))
Aadd(aRet, iif (valtype(oObj:CIDADE)=="U","", NoAcento(UPPER( DecodeUTF8( oObj:CIDADE)))))
Aadd(aRet, iif (valtype(oObj:COMPLEMENTO)=="U","", Left(  DecodeUTF8( oObj:COMPLEMENTO) ,TamSx3("A1_COMPENT")[1]  ) ))
Aadd(aRet, iif (valtype(oObj:EMAIL)=="U","", DecodeUTF8( oObj:EMAIL)))
Aadd(aRet, iif (valtype(oObj:ENDERECO)=="U","", UPPER( DecodeUTF8( oObj:ENDERECO))))
Aadd(aRet, iif (valtype(oObj:FONE)=="U","", DecodeUTF8( oObj:FONE)))
Aadd(aRet, iif (valtype(oObj:IE)=="U","", DecodeUTF8( oObj:IE)))
Aadd(aRet, iif (valtype(oObj:NOME)=="U","", NoAcento( UPPER( DecodeUTF8( oObj:NOME)))))
Aadd(aRet, iif (valtype(oObj:UF)=="U","",DecodeUTF8( oObj:UF)))
Aadd(aRet, cCNPJ)
Aadd(aRet, iif (len(cCNPJ) == 11, "F", "J"))
Return aRet
