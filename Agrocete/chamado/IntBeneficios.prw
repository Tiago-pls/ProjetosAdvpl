#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! AltMat                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Numeração de Matricula de acordo com a categoria        !              
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------!
!Data              ! 10/03/2021                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/

User Function GPM19RGB()

Local aAreaSRA := SRA->( GetArea() )

Local cRotInt  := PARAMIXB[1]//Roteiro
Local cFilSRA  := PARAMIXB[2]//Filial do funcionáriop
Local cMatSRA  := PARAMIXB[3]//Matrícula do funcionário

Local cCodPla   := GetMV("AG_CODPLA")
Local cVBForPS  := GetMV("AG_VBFORPS")
Local cVBForOD  := GetMV("AG_VBFOROD")
RHK->( dbGoTop())
RHK->( dbSeek(cFilSRA + cMatSRA +'1'))
If cRotInt =='PLA' .and. RHK->RHK_PLANO $ cCodPla .and. RGB->RGB_PD == cVBForPS
    RGB->RGB_PD := '785'
EndIf

If cRotInt =='PLA' .and. RHK->RHK_PLANO $ cCodPla .and. RGB->RGB_PD == cVBForOD
    RGB->RGB_PD := '787'
EndIf

RestArea(aAreaSRA)

Return
