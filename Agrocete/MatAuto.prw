user function MatAuto()
local aArea := GetArea()
Local cRet :=""
Local cCateg := M->RA_CATFUNC

DO CASE
    CASE cCateg =='E' .or. cCateg =='G' // Estagiarios
        cParam :="MV_AGRMATE"

    CASE cCateg =='A' .or. cCateg =='P' // Autonomos ou Pro labores
        cParam :="MV_AGRMATP"

    OTHERWISE
        cParam :="MV_AGRMATM"
Endcase

cRet := GetMv(cParam)
PUTMV(cParam, Soma1(cRet))

RestArea(aArea)
Return cRet