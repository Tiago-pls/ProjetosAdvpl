#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  MSD2460   - Autor - Tiago Santos      - Data -02.02.23   ---
--+----------+---------------------------------------------------------------
---Descri--o -  atualização dos campos do integrador na nota fiscal       ---
--+-----------------------------------------------------------------------+--
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/
User Function MSD2460()
  
Begin Transaction
    RecLock('SF2', .F.)
        F2_XINTEGR  := SC5->C5_XINTEGR            
        SF2->(MsUnlock())
End Transaction

Begin Transaction
    RecLock('SD2', .F.)
        D2_XINTEGR  := SC5->C5_XINTEGR            
        DF2->(MsUnlock())
End Transaction
//Atualizar limite de crédito
Return
