#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  FA070TIT   - Autor - Tiago Santos      - Data -02.02.23   ---
--+----------+---------------------------------------------------------------
---Descri--o -   PE    para atualizar o limite de crédito do Integrador   ---
--+-----------------------------------------------------------------------+--
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/
/*
aDados[1] -> Integrador
aDados[2] -> Loja
aDados[3] -> Tipo 
    I Inclusão|
    A Alteração|
    E Exclusão|
    V Venda|
    B Baixa|
    C cancelamento Baixa|
    N Canc Nota )
aDados[4] -> Valor

*/
user function AtuLimCr(adados) 

Begin transaction 
    RecLock("ZSD", .T.)
        ZSD->ZSD_FILIAL  := xFilial("ZSD")
        ZSD->ZSD_INTEGR  := aDados[1]
        ZSD->ZSD_LOJA    :=  aDados[2]
        ZSD->ZSD_TIPO    :=  aDados[3]
        ZSD->ZSD_VALOR   :=  aDados[4]
        ZSD->ZSD_DATA    :=   dDataBase
        ZSD->ZSD_HORA    :=   Time()  
        ZSD->ZSD_USUARIO :=   UsrRetName(RetCodUsr())
    MsUnlock()
End Transaction
if select("ZSA")==0
    DbSelectArea("ZSA")
Endif
ZSA->( DbSetorder(1))
ZSA->( dbGotop())

// se for venda, diminuir o limite do integrador
if aDados[3] $ ('V|B|C|N')
    if (ZSA->( DbSeek( xFilial("ZSA") + aDados[1] + aDados[2])))
        Do Case
            Case aDados[3] $ ('V|C')
                nValor := ZSA->ZSA_LIMITE - aDados[4]            
            Case aDados[3] $ ('B|N')
                nValor := ZSA->ZSA_LIMITE + aDados[4]            
        Endcase
        Begin transaction 
            RecLock("ZSA", .F.)
                ZSA->ZSA_LIMITE := nValor
            ZSA->( MSUNLOCK())
        end transaction
    Endif
Endif
return 
