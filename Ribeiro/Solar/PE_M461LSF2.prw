#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  ValPoten   - Autor - Tiago Santos      - Data -02.02.23   ---
--+----------+---------------------------------------------------------------
---Descri--o -  Relatório para geração dos valores vendidos e potencias    ---
--+-----------------------------------------------------------------------+--
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/

user function M461LSF2 
Local aArea :=GetArea()
Local aAreaSD2 :=SD2->(GetArea())

// SF2
Begin Transaction
    RecLock('SF2', .F.)
        F2_XINTEGR  := SC5->C5_XINTEGR            
    SF2->(MsUnlock())
End Transaction

SD2->(DbSetOrder(3)) // Filial + Doc
SD2->(DbGotop())

if SD2->( DbSeek( SF2->( F2_FILIAL + F2_DOC)))
    While SD2->(D2_FILIAL + D2_DOC) == SF2->( F2_FILIAL + F2_DOC)
        Begin Transaction
            RecLock('SD2', .F.)
                D2_XINTEGR  := SC5->C5_XINTEGR            
            SD2->(MsUnlock())
        End Transaction
        SD2->( DbSkip())
    Enddo
Endif
RestArea(aArea)
return



User Function MSD2460()
  
Begin Transaction
    RecLock('SD2', .F.)
        D2_XINTEGR  := SC5->C5_XINTEGR            
        DF2->(MsUnlock())
//Finalizando controle de transações
End Transaction
Return
