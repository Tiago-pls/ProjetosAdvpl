#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#Include "TBICONN.ch"
#include "Fileio.ch"

User Function MT410ACE()
    Local aArea        := GetArea()
    Local lContinua    := .T.  
    Local nOpc            := PARAMIXB[1]

    if FieldPos("C5_IDFLUIG") > 0
        //Se for inclusão, visualização
        if (nOpc == 3) .Or. (nOpc == 2) 
            lContinua := .T.
        elseif !EMPTY( SC5->C5_IDFLUIG) .and. FunName() == "MATA461"
            MsgAlert("*Pedido com origem do Fluig não pode ser manipulado!", "Atenção")
            lContinua := .F.
        Endif
    Endif 

    RestArea(aArea)
Return lContinua

User Function M410PVNF()
Local aArea        := GetArea()
Local lContinua := .T.        
// chamada pela rotina de pedido de venda
if FieldPos("C5_IDFLUIG") > 0
    If FunName() == "MATA461" .and. !EMPTY( SC5->C5_IDFLUIG)
        MsgAlert("Pedido com origem do Fluig não pode ser manipulado!", "Atenção")
        lContinua := .F.
    Endif
endif               
RestArea(aArea)
Return lContinua
