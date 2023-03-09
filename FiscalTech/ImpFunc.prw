#include "PROTHEUS.CH"
#include "tbiconn.ch"
#INCLUDE "TOPCONN.CH"
//=================================================================================


//=================================================================================


User Function ImpFunc()

Local cUrl := "https://backend-dot-hrestart-thinkz.appspot.com/integracao/0.2.0"
Local cToken :="Ikcpl4nZOyFsdj1bXZTGjfpTWymvHYeUMyLmY4oyIIw1nTreTPojUeZyYWPtFB2TyyRohikQlWXcOSVr875WurJ5AUN3SZQiIJiMqhyhQL71igLBWPByiOWa5Gnp7sPj4IuVhyxvYeuwIj3Lf6pHPsPZbrIrzQXCST57hVkPa6RBmpkM3TDClJbXIAk2X9qMkuojENJvDcXLb5B42G9LR6uXpoRCnktCLN4kv5jL3n5RSNlaws6MPptVLaNqlH0R"
Local oRestClient := FWRest():New(cUrl)
Local aHeader := {}
Local cCPF     := M->RA_CIC //'02337071901'// SRA->RA_CIC
Local oJsObj
local cConta :=""
local cBanco :=""
// inclui o campo Authorization no formato : na base64
Aadd(aHeader, "Authorization: Bearer " + cToken)

/*GET */
oRestClient:SetPath("/admissao/"+cCPF)

If oRestClient:Get(aHeader)
   
    cJson := oRestClient:GetResult()
    FWJsonDeserialize(oRestClient:CRESULT,@oJsObj)
    cteste := oJsObj:CPF
    M->RA_PROCES     := '00001'
    M->RA_CODFUNC    := oJsObj:CARGOCOD
    RunTrigger(1,nil,nil,,'RA_CODFUNC')
    M->RA_CARGO      := posicione('SRJ',1, xFilial("SRJ")+M->RA_CODFUNC ,'RJ_CARGO') 
    M->RA_DCARGO     := left(posicione('SQ3',1, xFilial("SQ3")+M->RA_CARGO,'Q3_DESCSUM') ,TamSx3("RA_DCARGO") [1])
    M->RA_SEXO       := Upper( oJsObj:SEXO)
    M->RA_NOME       := Left(Upper( NoAcento(decodeUTF8(oJsObj:NOMECOMPLETO))),30)
    M->RA_NOMECMP    := Upper( NoAcento(decodeUTF8(oJsObj:NOMECOMPLETO)))
    M->RA_MAE        := Upper( NoAcento(decodeUTF8(oJsObj:NOMEMAE)))+Space( TamSx3("RA_MAE")[1] - len(Upper( NoAcento(decodeUTF8(oJsObj:NOMEMAE)))))
    M->RA_PAI        := Upper( NoAcento(decodeUTF8(oJsObj:NOMEPAI)))+Space( TamSx3("RA_PAI")[1] - len(Upper( NoAcento(decodeUTF8(oJsObj:NOMEPAI)))))
    M->RA_TIPOPGT    := 'M'
    M->RA_ADMISSA    := StoD(strtran(oJsObj:DATAADMISSAO,'-'))
    RunTrigger(1,nil,nil,,'RA_ADMISSA')
    M->RA_NASC       := StoD(strtran(oJsObj:DATANASCIMENTO,'-'))
    M->RA_EMAIL      := Alltrim(oJsObj:EMAIL)
    M->RA_NACIONC    := '01058'
    M->RA_NACIONA    := '10'
    M->RA_SEXO       := Upper(oJsObj:SEXO)
    M->RA_DDDCELU    := Left(oJsObj:TELEFONE,2)
    M->RA_NUMCELU    := right(oJsObj:TELEFONE,9)
    if ! oJsObj:PIS == nil
        M->RA_PIS := Alltrim(oJsObj:PIS:NUMERO)
    Endif
    if ! oJsObj:ENDERECO == nil
        M->RA_TIPENDE := '2'
        M->RA_LOGRTP  := oJsObj:ENDERECO:ABREVIACAOTIPOLOGRADOURO
        M->RA_LOGRDSC := oJsObj:ENDERECO:LOGRADOURO
        M->RA_LOGRNUM := oJsObj:ENDERECO:NUMERO
        M->RA_ENDEREC := oJsObj:ENDERECO:LOGRADOURO + space(TamSx3("RA_ENDEREC")[1] - len(oJsObj:ENDERECO:LOGRADOURO))
        M->RA_NUMENDE := oJsObj:ENDERECO:NUMERO
        M->RA_BAIRRO  := oJsObj:ENDERECO:BAIRRO+ space(TamSx3("RA_BAIRRO")[1] - len(oJsObj:ENDERECO:BAIRRO))
        M->RA_CEP     := oJsObj:ENDERECO:CEP
        M->RA_MUNICIP := oJsObj:ENDERECO:CIDADE
        M->RA_ESTADO:= oJsObj:ENDERECO:ESTADO
        M->RA_CODMUN := SubStr(oJsObj:ENDERECO:CODIGOCIDADE,3,5)
    Endif
    if ! oJsObj:CARTEIRAHABILITACAO == nil
        M->RA_DTEMCNH    := StoD(strtran(oJsObj:CARTEIRAHABILITACAO:DATAEMISSAO,'-'))
        M->RA_DTVCCNH    := StoD(strtran(oJsObj:CARTEIRAHABILITACAO:DATAVALIDADE,'-'))
        M->RA_HABILIT    := strtran(oJsObj:CARTEIRAHABILITACAO:NUMEROREGISTRO,'-')
        M->RA_CNHORG     := 'DETRAN ' +  oJsObj:CARTEIRAHABILITACAO:UFEXPEDIDOR
        M->RA_UFCNH      := oJsObj:CARTEIRAHABILITACAO:UFEXPEDIDOR
        cCat := oJsObj:CARTEIRAHABILITACAO:CATEGORIA
        DO CASE
            CASE cCat == 'A'
                cCat :="1"
            CASE cCat == 'B'
                cCat :="2"
            CASE cCat == 'C'
                cCat :="3"
            CASE cCat == 'D'
                cCat :="4"
            CASE cCat == 'E'
                cCat :="5"
            CASE cCat == 'AB'
                cCat :="6"
            CASE cCat == 'AC'
                cCat :="7"
            CASE cCat == 'AD'
                cCat :="8"
            CASE cCat == 'AE'
                cCat :="9"
        ENDCASE
        M->RA_CATCNH := cCat
    Endif
    if ! oJsObj:RGRNE == nil
        M->RA_RG        := Alltrim(oJsObj:RGRNE:NUMERODOCUMENTO)
        M->RA_DTRGEXP   := StoD(strtran(oJsObj:RGRNE:DATAEMISSAO,'-'))
        M->RA_RGUF      := oJsObj:RGRNE:UFEXPEDIDOR
        M->RA_RGORG     := oJsObj:RGRNE:ORGAOEMISSOR
        M->RA_RGEXP     := oJsObj:RGRNE:ORGAOEMISSOR
        M->RA_ORGEMRG   := oJsObj:RGRNE:ORGAOEMISSOR + oJsObj:RGRNE:UFEXPEDIDOR
        M->RA_NATURAL   := oJsObj:RGRNE:UFNASCIMENTO
        if !Empty(oJsObj:RGRNE:MUNICIPIONATURALIDADE)
            M->RA_CODMUNN   := posicione('CC2',2,xFilial('CC2')+ upper(oJsObj:RGRNE:MUNICIPIONATURALIDADE),'CC2_CODMUN') 
            M->RA_MUNNASC   := posicione('CC2',1,xFilial('CC2') +M->RA_NATURAL+M->RA_CODMUNN ,'CC2_MUN') 
            M->RA_CODMUNE   := posicione('CC2',1, XFILIAL('CC2')+M->RA_ESTADO+M->RA_CODMUN ,'CC2_MUN') 
        Endif        
        M->RA_NACIONN   := posicione('CCH',1, XFILIAL('CCH')+M->RA_NACIONC ,'CCH_PAIS') 
        M->RA_DESCFUN   := posicione('SRJ',1, xFilial("SRJ")+M->RA_CODFUNC ,'RJ_DESC')         
    Endif
    if !oJsObj:CARTEIRATRABALHO == nil
        M->RA_DTCTEXP    := StoD(strtran(oJsObj:CARTEIRATRABALHO:DATAEMISSAO,'-'))
        M->RA_NUMCP      := oJsObj:CARTEIRATRABALHO:NUMEROREGISTRO
        M->RA_SERCP      := oJsObj:CARTEIRATRABALHO:SERIE
        M->RA_UFCP       := oJsObj:CARTEIRATRABALHO:UF
    Endif
    cBanco := oJsObj:DADOSBANCARIOS:CODIGOBANCO + oJsObj:DADOSBANCARIOS:AGENCIA 
    if oJsObj:DADOSBANCARIOS:CODIGOBANCO ='001'
        cConta :=  Strzero(Val(oJsObj:DADOSBANCARIOS:AGENCIA),8)
    elseif oJsObj:DADOSBANCARIOS:CODIGOBANCO ='341'
        cConta := oJsObj:DADOSBANCARIOS:AGENCIA
    else
        cConta :=''
        cBanco :=''
    End
    M->RA_BCDEPSA  := cBanco
    M->RA_CTDEPSA  := cConta
    //
Else
    Alert("GET - " + oRestClient:GetLastError())
EndIf

RETURN
