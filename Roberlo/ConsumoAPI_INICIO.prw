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

user function ApiInicI(nTpAPI) 
Local cUrl			:= iif ( nTpAPI ==1, Alltrim(GetMv("RB_URLAPIC")) , Alltrim(GetMv("RB_ULRPAG")))
Local cURLNFe       :="https://bling.com.br/Api/v2/notafiscal/"
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

    cRetWs	:= HttpGet(cUrl + cValToChar(nPage) + cApiKey +cFIlter, cGetParams, nTimeOut, aHeadStr, @cHeaderGet)

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
    else
        cObj := "oObjJson:RETORNO:" + cTPObj1
        nLen := Len( &cObj)
         
        if select(cArea) ==0 // Clienes
            DbSelectArea(cArea)
        Endif
        cDbSetOrder:="->(DbSetorder(1))"
        &(cArea+cDbSetOrder)

        For nCont := 1 to nLen
            aDados :=RetArray(&(cObj+ "[" + cValtochar(nCont) +"]:" +cObjRet ) , nTpAPI)
            lGrava :=.T.
            cID 
            if(aDados[1] =="0") 
                oAntes := oObjJson
                cNumero := &(cObj+ "[" + cValtochar(nCont) +"]:PEDIDO:NOTA:NUMERO")
                cSerie := &(cObj+ "[" + cValtochar(nCont) +"]:PEDIDO:NOTA:SERIE")                
                cURLNFe += cNumero + "/" + cSerie               
                cRetCli	:= HttpGet(cURLNFe + cApiKey +cFIlter, cGetParams, nTimeOut, aHeadStr, @cHeaderGet)
                
                If FWJsonDeserialize(cRetCli, @oObjClie) // Falha
                    aDados:= RetArray( oObjClie:RETORNO:NOTASFISCAIS[1]:NOTAFISCAL:CLIENTE, nTpAPI)
                    if(aDados[1] =="0") 
                        lGrava := .F.
                    Endif
                Endif
                oObjJson:= oAntes
            Endif
            if lGrava
                cDbGotop:="->( dbgotop())"
                &(cArea+cDbGotop)
                if !&(cArea)->( Dbseek( xFilial(cArea) + aDados[1] + " " + aDados[2] ))
                    aVetor := MontaVet(nTpAPI, aDados)
                    lMsErroAuto := .F.

                    if nTpAPI = 1
                        MSExecAuto({|x,y| Mata030(x,y)},aVetor,3) // Clientes
                    elseif nTpAPI =2
                        MSExecAuto({|x,y| Mata020(x,y)},aVetor,3) // Fornecedores
                    End
                                             
                    // verifica se ocorreu erro
                    if lMsErroAuto
                        // mostra erro
                    //   MostraErro()                        
                    endIf
                endif
            Endif
            Next nI
    Endif
    nPage := nPage +1
Enddo

if len(cTexto) > 0
    nHandle := FCreate(cArq)
    FWrite(nHandle, cTexto)
    FClose(nHandle)
Endif
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

static function RetArray(oObj, nTpAPI )
Local aRet :={}
Local cMaskCGC :=""
if nTpAPI ==1 // CLientes
    If  Empty( oObj:CNPJ)
        Aadd(aRet, "0")
        Return aRet
    endif
    cMaskCGC:= "oObj:CNPJ"

else
    if (oObj:TIPOPESSOA) =="J" 
        If Empty( oObj:CNPJ)
            Aadd(aRet, "0")
            Return aRet
        endif
        cMaskCGC:= "oObj:CNPJ"
    else
        If Empty( oObj:CPF)
            Aadd(aRet, "0")
            Return aRet
        endif
        cMaskCGC:= "oObj:CPF"
    endif
Endif
cCNPJ := StrTran( StrTran( StrTran( DecodeUTF8( &cMaskCGC), ".", ""), "/", ""), "-", "")

Aadd(aRet, SubStr(cCNPJ, 1,8)) // A1_COD
Aadd(aRet, iif (valtype(&cMaskCGC)=="U","", SubStr(cCNPJ, 9,4))) // A1_LOJA
Aadd(aRet, iif (valtype(oObj:BAIRRO)=="U","", Left(  NoAcento(DecodeUTF8( oObj:NOME)) ,TamSx3("A2_BAIRRO")[1]  ) ))
Aadd(aRet, "")
Aadd(aRet, iif (valtype(oObj:CEP)=="U","", StrTran(StrTran(DecodeUTF8( oObj:CEP) , "-",""), ".","")))
Aadd(aRet, iif (valtype(oObj:CIDADE)=="U","", NoAcento(UPPER( DecodeUTF8( oObj:CIDADE)))))
Aadd(aRet, iif (valtype(oObj:COMPLEMENTO)=="U","", Left(  DecodeUTF8( oObj:COMPLEMENTO) ,TamSx3("A1_COMPENT")[1]  ) ))
Aadd(aRet, iif (valtype(oObj:EMAIL)=="U","", DecodeUTF8( oObj:EMAIL)))
Aadd(aRet, iif (valtype(oObj:ENDERECO)=="U","", Left(  NoAcento(DecodeUTF8( oObj:NOME)) ,TamSx3("A2_END")[1]  ) ))
Aadd(aRet, iif (valtype(oObj:FONE)=="U","", DecodeUTF8( oObj:FONE)))
if len(cCNPJ) ==14  // CNPJ
    Aadd(aRet, iif (valtype(oObj:IE)=="U","", DecodeUTF8( oObj:IE)))
Else
    Aadd(aRet , "")
Endif
Aadd(aRet, iif (valtype(oObj:NOME)=="U","", Left(  NoAcento(DecodeUTF8( oObj:NOME)) ,TamSx3("A2_NOME")[1]  ) ))
Aadd(aRet, iif (valtype(oObj:UF)=="U","",DecodeUTF8( oObj:UF)))
Aadd(aRet, cCNPJ)
Aadd(aRet, iif (len(cCNPJ) == 11, "F", "J"))
Aadd(aRet, iif (valtype(oObj:NOME)=="U","", Left(  DecodeUTF8( oObj:NOME) ,TamSx3("A2_NREDUZ")[1]  ) ))
Return aRet

static  function MontaVet (nTpAPI, aDados)
aRet:={{"A" + cValtochar(nTpAPI)+"_COD"                ,aDados[1]                              ,Nil},; 
         {"A" + cValtochar(nTpAPI)+"_LOJA"             ,aDados[2]                              ,Nil},; 
         {"A" + cValtochar(nTpAPI)+"_BAIRRO"           ,aDados[3]                              ,Nil},; 
         {"A" + cValtochar(nTpAPI)+"_CEP"              ,aDados[5]                              ,Nil},; 
         {"A" + cValtochar(nTpAPI)+"_EST"              ,aDados[13]                             ,Nil},;
         {"A" + cValtochar(nTpAPI)+"_MUN"              ,aDados[6]                              ,Nil},;
         {"A" + cValtochar(nTpAPI)+"_NOME"             ,aDados[12]                             ,Nil},; 
         {"A" + cValtochar(nTpAPI)+"_NREDUZ"           ,aDados[16]                             ,Nil},; 
         {"A" + cValtochar(nTpAPI)+"_INSCR"            ,iif(aDados[15]=="J",  aDados[11],"")   ,Nil},; 
         {IIf(nTpAPI ==1, "A1_COMPENT", "A2_ENDCOMP")  ,aDados[7]                              ,Nil},;         
         {"A" + cValtochar(nTpAPI)+"_CGC"              ,aDados[14]                             ,Nil},;         
         {IIf(nTpAPI ==1, "A1_TIPO", "A2_TPESSOA")     , IIf(nTpAPI ==1, "F", " ")             ,Nil},;          // tratar esse campo no log
         {"A" + cValtochar(nTpAPI)+"_NATUREZ"          , 'ISS'                                 ,Nil},;          // tratar esse campo no log
         {IIf(nTpAPI ==1, "A1_PESSOA", "A2_TIPO")      , aDados[15]                            ,Nil},;          // tratar esse campo no log
         {"A" + cValtochar(nTpAPI)+"_END"              ,aDados[9]                              ,Nil}} 
         
Return aRet                    
