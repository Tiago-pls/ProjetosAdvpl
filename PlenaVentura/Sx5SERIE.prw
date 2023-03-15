#include "rwmake.ch"
#include "protheus.ch"


user function SX5Nota()
Local aArea     := GetArea()
Local cSerieSX5 := alltrim(Paramixb[3])
local lRet      := .F.
local cFilserie := SUPERGETMV( 'NF_FILSER', , '100109',  ) // Filiais SC que irão tratar a série específica
local cSerie    := SUPERGETMV( 'NF_SERIESC', , 'F',  ) // Serie específica para geração da Nota fiscal de serviço SC

if cEmpAnt =='10'  .and. FwCodFil() == cFilserie .and. SB1->B1_TIPO ='SV'
    if cSerieSX5 == cSerie
        lRet := .T.
    endif    
Endif
RestArea(aArea)
return lRet
