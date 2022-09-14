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

user function APIProd
Local cUrl			:=Alltrim(GetMv("RB_URLAPIP")) + "/page="
Local cGetParams	:= ""
Local nTimeOut		:= 200
Local aHeadStr		:= {"Content-Type: application/json"}
Local cHeaderGet	:= ""
Local cRetWs		:= ""
Local oObjJson		:= Nil
Local aRet          := {}
Local cApiKey := "/json&apikey=" + Alltrim(GetMv("RB_APIKEY")) 
Local cFIlter :="&filters=situacao[A]" // Somente Produtos Ativos
Local lGetWS        := .T.
Local nPage         := 1
Default lJob        := .F.

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
        Return Nil
    else
        
        nProd := Len( oObjJson:RETORNO:PRODUTOS)
        if select("SYD") ==0 // NCM
            DbSelectArea("SYD")
        Endif
        SYD->(DbSetorder(1))
        
        if select("SB1") ==0 // Produtos
            DbSelectArea("SB1")
        Endif
        SB1->(DbSetorder(1))

        For nCont := 1 to nProd
            cCodigo :=oObjJson:retorno:Produtos[nCont]:PRODUTO:ID
            SB1->( dbgotop())
                    
            if !SB1->( Dbseek( xFilial("SB1") + cCodigo))
                cDesc := NoAcento(Upper( DecodeUTF8( oObjJson:retorno:Produtos[nCont]:PRODUTO:DESCRICAO)))
                cDesc := Left( cDesc,TamSx3("B1_DESC")[1] )
                cUM   := NoAcento(Upper( DecodeUTF8( alltrim( oObjJson:retorno:Produtos[nCont]:PRODUTO:UNIDADEMEDIDA))))

                cUM :=  u_validUM(cUM)
                cArmaz:="01"
                cTipo :="PA"
                cNcm  := oObjJson:retorno:Produtos[nCont]:PRODUTO:CLASS_FISCAL                
                cNcm := StrTran( cNcm, '.', '' )
                cNcm := iif ( Len( cNcm)<8, '99999999', cNcm) // 99999999 não informado
                nPesoBruto := Val( oObjJson:retorno:Produtos[nCont]:PRODUTO:PESOBRUTO)
                nEstMinimo := Val( oObjJson:retorno:Produtos[nCont]:PRODUTO:ESTOQUEMINIMO)
                cMarca := SubStr( oObjJson:retorno:Produtos[nCont]:PRODUTO:MARCA,1,2)
                cOrigem :=  oObjJson:retorno:Produtos[nCont]:PRODUTO:ORIGEM
                if Empty(cOrigem )
                // tratar campo Origem em branco e nCM com 4 dígitos
                    //Gerar Log
                    cOrigem := '0'
                Endif

                //--- Exemplo: Inclusao --- //
                aVetor:= { {"B1_COD" ,cCodigo ,NIL},;
                {"B1_DESC" , cDesc,NIL},;
                {"B1_TIPO" ,cTipo ,Nil},;
                {"B1_UM" ,cUM ,Nil},;
                {"B1_LOCPAD" ,cArmaz ,Nil},;
                {"B1_PICM" ,0 ,Nil},;
                {"B1_IPI" ,0 ,Nil},;
                {"B1_POSIPI" ,cNcm ,Nil},;
                {"B1_GRUPO" ,"0" ,Nil},;   // verificar como tratar esse campo
                {"B1_SGRUPO" ,"99" ,Nil},; // verificar como tratar esse campo
                {"B1_GRTRIB" ,"007" ,Nil},; // verificar como tratar esse campo
                {"B1_SMARCA" , iif ( Empty(cMarca), '02' , cMarca),Nil},;
                {"B1_CONTRAT" ,"N" ,Nil},;
                {"B1_PESBRU" ,nPesoBruto,Nil},;
                {"B1_ESTSEG" ,nEstMinimo,Nil},;
                {"B1_ORIGEM" ,cOrigem,Nil},;
                {"B1_LOCALIZ" ,"N" ,Nil}}
        
                // verificar se o NCM está cadastrado na tabela 
                lMsErroAuto := .F.
                MSExecAuto({|x,y| Mata010(x,y)},aVetor,3)
                // verifica se ocorreu erro
                if lMsErroAuto
                    // mostra erro
                    Mostraerro()
                else
                    CriaSB2(cCodigo,'01')
                endIf
            endif
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

user function validUM(cUM)
If cUM = 'CENTIMETROS'
    cUM := 'CM'
ElseIf cUM = 'UM'
    cUM := 'UN'
Endif
return cUM
