#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! AltMat                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Numeracao de Matricula de acordo com a categoria        !              
+------------------+---------------------------------------------------------+
!Autor             ! Tiago Santos                                            !
+------------------+---------------------------------------------------------!
!Data              ! 10/03/2021                                              !
+------------------+---------------------------------------------------------!
+------------------+--------------------------------------------------------*/
user function AltMat(cCateg)

Local cMat := M->RA_MAT

if Empty(M->RA_MAT)
    DO CASE
    CASE cCateg =="M"
        cMat:= GETMV("MV_MATMEN")
        
    CASE cCateg =="E"
        cMat:= GETMV("MV_MATEST")
        
    CASE cCateg =="A"
        cMat:= GETMV("MV_MATAUT")
    EndCase
    
Endif

Return cMat




user function GP010VALPE
Local aArea  := GetArea()
Local lRet := .T.

if inclui
    DO CASE
    CASE M->RA_CATFUNC =="M"
        PUTMV("MV_MATMEN",  Soma1(M->RA_MAT))
        
    CASE M->RA_CATFUNC =="E"
        PUTMV("MV_MATEST",  Soma1( M->RA_MAT))
        
    CASE M->RA_CATFUNC =="A"
        PUTMV("MV_MATAUT",  Soma1( M->RA_MAT))
    EndCase
Endif
RestArea(aArea)
return lRet



