#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"


user function LogAnexo(cFil ,cDoc, cOrigem,cTipo, cParcela)

if select("Z40") ==0
    DbSelectArea("Z40")
Endif

Begin Transaction
    RecLock('Z40', .T.)
        Z40_FILIAL  := cFil
        Z40_DOC     :=  cDoc
        Z40_ORIGEM  := cOrigem
        Z40_PARCELA :=  cParcela
        Z40_DATA    := dDatabase
        Z40_HORA    := time()
        Z40_USUARIO := FwGetUserName(RetCodUsr())
        Z40_TIPO    := iif(cTipo =="I", "INCLUSAO","EXCLUSAO")
    Z40->(MsUnlock())     
//Finalizando controle de transações
End Transaction
return
