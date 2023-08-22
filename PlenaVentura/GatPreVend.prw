#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! GatPreVend                                              !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o       ! Gatilho pmara formação do preço de venda                !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------!
!Data              ! 19/08/2022                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/
user function GatPreVend
Local aArea := GetArea()
Local nRet  := 0
Local nMarkup  := 0
Local cClientBloq := SuperGetMV("BL_CLIENTE", .T., "000004")

// criar campo ValorDig 
/*
if GDFIELDGET("UB_CUSTDES",N) =='1' .or. GDFIELDGET("UB_RUPEST",N)   =='1'
    Return GDFIELDGET("UB_VRUNIT",N)
Endif
*/
if  SA1->A1_COD  $ cClientBloq
    RETURN GDFIELDGET("UB_VRUNIT",N)
endif

if select("Z25") == 0 
    DbSelectArea("Z25")
Endif
if select("SB2")==0 
    DbSelectArea("SB2")
Endif
if select("Z24")==0 
    DbSelectArea("Z24")
Endif

nMarkup := 100 - u_RetMarkup() // recalculado o MKP 
nCustoProd := posicione("SB2",1,xFilial("SB2") + GDFIELDGET("UB_PRODUTO",N),"B2_CM1")
nTot  := u_RetTotAliq()
/*
nRet := nCustoProd + (nCustoProd * nMarkup /100)
nTot  := u_RetTotAliq()
nValor := Round(nRet  / (1- (nTot / 100)),2)

281002055371


*/
//C1/(1-(0,45+0,1325))
nValor := nCustoProd / (1 - (nMarkup + nTot) / 100)

GdFieldPut("UB_VRUNIT"	  ,nValor 	 ,N,aHeader,aCols)

u_Tk273Calc("UB_VRUNIT")
GdFieldPut("UB_PRCTAB",round(nValor,2) 	 ,N,aHeader,aCols)
if nValor <> 0 .and. SUB->(FieldPos( "UB_XCALC" )) > 0
    GdFieldPut("UB_XCALC", 'S' 	 ,N,aHeader,aCols)
Endif

GdFieldPut("UB_VLRITEM"	  ,nValor * GDFIELDGET("UB_QUANT",N) 	 ,N,aHeader,aCols)

RestArea(aArea)

Return nValor   


/*-----------------+---------------------------------------------------------+
!Nome              ! GatCustDes                                              !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o       ! Gatilho Controle ultima compra produto                  !
+------------------+---------------------------------------------------------*/
user function GatCustDes()
Local nMesesUlCo :=Getmv("BL_MESESUC")
Local cRet := '0'
Local aArea := GetArea()
Local cData := ''
dDataMov := Stod( u_RetDtMovPr(GDFIELDGET("UB_PRODUTO",N))) 

if  DateDiffDay(dDataMov , Date() ) > nMesesUlCo
    
    cData += SubStr(Dtos(dDataMov), 7, 2)+ '/'
    cData += SubStr(Dtos(dDataMov), 5, 2)+ '/'
    cData += SubStr(Dtos(dDataMov), 1, 4)
    MsgAlert("Ultima compra anterior ao limite configurado no parâmetro BL_MESESUC, ultima compra registrada: "+cData)
    cRet := '1'
Endif
RestArea(aArea)
Return cRet

/*-----------------+---------------------------------------------------------+
!Nome              ! RetDtMovPr                                              !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o       ! Controle ultima compra produto                          !
+------------------+---------------------------------------------------------*/

user  Function RetDtMovPr(cProd)
cQuery :=""

cQuery := "Select NVL2( Max(D1_EMISSAO) , Max(D1_EMISSAO), '' ) EMISSAO "
cQuery += " FROM "+RetSqlName("SD1")+" SD1 "
cQuery += "WHERE SD1.D_E_L_E_T_ = ' ' AND D1_FILIAL = '"+xFilial("SD1")+"' AND D1_COD = '" + Alltrim(cProd) + "' "

If Select("TMPSD1") > 0
	Dbselectarea("TMPSD1")
	TMPSD1->(DbClosearea())
EndIf
TcQuery cQuery New Alias "TMPSD1"
cEmissao := TMPSD1->EMISSAO
TMPSD1->(DbClosearea())
Return cEmissao

/*-----------------+---------------------------------------------------------+
!Nome              ! GatRupEst                                               !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o       ! Gatilho Custo Médio desatualizado                       !
+------------------+---------------------------------------------------------*/

user function GatRupEst()
local cRet := '0'
Local cClientBloq := SuperGetMV("BL_CLIENTE", .T., "000004")
if  SA1->A1_COD  $ cClientBloq
    return cRet
endif

SB2->(dbSetOrder(1))
SB2->( dbGotop())
if SB2->( dbSeek(xFilial("SB2") + GDFIELDGET("UB_PRODUTO",N)))
    nCustoProd := SB2->B2_CM1
else
    MsgAlert("Produto sem Custo Médio atualizado")
    cRet :='1'
Endif
if round(nCustoProd,2)  ==0 
    MsgAlert("Produto com Custo Médio zerado")
    cRet :='1'
Endif
Return cRet

/*-----------------+---------------------------------------------------------+
!Nome              ! RetMarkup                                               !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o       ! GRetorno do Markup segundo Regra de prioridade          !
+------------------+---------------------------------------------------------*/
user function RetMarkup 
nMarkup :=0
nMkProd := posicione("SB1",1,xFilial("SB1")+GDFIELDGET("UB_PRODUTO",N),"B1_MARKUP")
nMKGrupProd := posicione("Z25",1,xFilial("Z25") + SB1->B1_GRTRIB,"Z25_MARKUP")
nMKEst := posicione("Z24",1,xFilial("Z24") + SA1->A1_EST,"Z24_MARKUP")

SB2->(dbSetOrder(1))
SB2->( dbGotop())
if SB2->( dbSeek(xFilial("SB2") + GDFIELDGET("UB_PRODUTO",N)))
    nCustoProd := SB2->B2_CM1
else
    MsgAlert("Produto sem Custo Médio atualizado")
Endif

if SA1->A1_MARKUP <> 0
    nMarkup := SA1->A1_MARKUP
elseif nMkProd <> 0
    nMarkup :=  nMkProd
Elseif nMKGrupProd <> 0
    nMarkup:=  nMKGrupProd
Elseif nMKEst <> 0
    nMarkup:=  nMKEst
Endif

Return  nMarkup

/*-----------------+---------------------------------------------------------+
!Nome              ! RetTotAliq                                              !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o       ! Retorno somatorio aliquitas                             !
+------------------+---------------------------------------------------------*/
User function RetTotAliq
local nRet :=0 
nAliqICMS   := MaFisRet(N,"IT_ALIQICM")
if SA1->A1_GRPTRIB ='200'
    nAliqICMS  := MaFisRet(N,"IT_ALIQSOL") 
Endif
nAliqCofins := IIF(MaFisRet(N,"IT_BASECF2") <> 0, MaFisRet(N,"IT_ALIQCF2"),0)
nAliqPIS    := IIF(MaFisRet(N,"IT_BASEPS2") <> 0, MaFisRet(N,"IT_ALIQPS2"),0)
nRet        := nAliqICMS + nAliqCofins + nAliqPIS
return  nRet

//GDFIELDGET("UB_RUPEST",N)
User Function PrcCalc(cCalculado)
Local lRet := .T.

if cCalculado =='S'
    lRet := .F.
Endif
//
Return lRet
 
