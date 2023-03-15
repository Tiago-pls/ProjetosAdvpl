#include "rwmake.ch"
#include "protheus.ch"


user function SX5Nota()
Local aArea     := GetArea()
Local cSerieSX5 := alltrim(Paramixb[3])
local lRet      := .F.
local cFilserie := SUPERGETMV( 'NF_FILSER', , '100109',  ) // Filiais SC que ir�o tratar a s�rie espec�fica
local cSerie    := SUPERGETMV( 'NF_SERIESC', , 'F',  ) // Serie espec�fica para gera��o da Nota fiscal de servi�o SC

if cEmpAnt =='10'  .and. FwCodFil() == cFilserie .and. SB1->B1_TIPO ='SV'
    if cSerieSX5 == cSerie
        lRet := .T.
    endif    
Endif
RestArea(aArea)
return lRet
