#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! AltMat                                                  !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o       ! Numeração de Matricula de acordo com a categoria        !              
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                      !
+------------------+---------------------------------------------------------!
!Data              ! 10/03/2021                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/
user function AltMat(cCateg)
Local cMat :=""

if Empty(SRA->RA_MAT)
         
    if cCateg =="A"
        cMat:= GETMV("MV_MTAUT")
    else
         cMat:= GETMV("MV_MATMEN")
    endif
Endif

Return cMat


// Ponto de entrada na inclusão de funcionários
user function GP010VALPE
Local aArea  := GetArea()
Local lRet := .T.

if inclui
    if M->RA_CATFUNC =="A"
        PUTMV("MV_MTAUT",  Soma1( M->RA_MAT))
    else
        PUTMV("MV_MATMEN",  Soma1(M->RA_MAT))
    endif
Endif
RestArea(aArea)
return lRet
