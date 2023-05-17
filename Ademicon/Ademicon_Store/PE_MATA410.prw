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
    Local lResiduo := IsInCallStack('MA410RESID')
     
    //Se for inclusão, visualização ou resíduo, permite continuar
    If (nOpc == 3) .Or. (nOpc == 2) .Or. (lResiduo)
        lContinua := .T.
         
    //Senão, mostra mensagem ao usuário
    Elseif !EMPTY( SC5->C5_IDFLUIG)
        MsgAlert("Pedido com origem do Fluig não pode ser manipulado!", "Atenção")
        lContinua := .F.
    Endif
                     
    RestArea(aArea)
Return lContinua


