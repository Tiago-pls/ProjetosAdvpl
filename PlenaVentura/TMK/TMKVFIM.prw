#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'
/*-----------------+---------------------------------------------------------+
!Nome              ! TMKVFIM                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Gravação campo C5_XMSGNOT                               !
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------!
!Data              ! 05/05/2023                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/
user function TMKVFIM
Local aArea := GetArea()
if SC5->( FIELDPOS( 'C5_XMSGNOT' )) <> 0
    RECLOCK( 'SC5', .F. )
        SC5->C5_XMSGNOT = M->UA_OBS
    SC5->( MSUNLOCK())
endif
RestArea(aArea)
return
