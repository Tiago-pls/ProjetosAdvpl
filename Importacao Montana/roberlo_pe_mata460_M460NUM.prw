#include "protheus.ch"
Static cSep := ""
User Function M460NUM
cSep := "  "
if isincallstack("maPvlNfs")
    cSep :="Sem Separador"
    cNumero := cNfe
elseIf SC5->C5_TIPO == "N" .and. SF2->(FieldPos("F2_SEPARA")) > 0
    cSep := SetSepara()
EndIf
Return

User Function GetSepara
Return cSep

Static Function SetSepara
Local cRet  := "  "
Local aPerg := {}
Local aSep  := PegaSep()
Local aResp := {aSep[2][1]}

aAdd(aPerg, {2, "Separador", aSep[2][1], aSep[2], 70, "", .F.})
If ParamBox(aPerg, "Informe o separador", @aResp)
    cRet := aSep[1][aScan(aSep[2], aResp[1])]
EndIf
Return cRet

User Function CadZ01
AxCadastro("Z01", "Separadores", ".T.", ".T.")
Return

Static Function PegaSep
Local aZ01 := {{}, {}}
Local cZ01 := ""
Local cBkp := If(Empty(Alias()), "SF2", Alias())

cZ01 := GetNextAlias()
BeginSQL Alias cZ01
SELECT Z01_COD, Z01_NREDUZ
FROM %table:Z01% Z01
WHERE Z01.%notdel%
AND Z01_FILIAL = %xfilial:Z01%
AND Z01_ATIVO <> '2'
ORDER BY Z01_NREDUZ
EndSQL
dbEval({|| aAdd(aZ01[1], Z01_COD), aAdd(aZ01[2], Z01_NREDUZ)})
dbCloseArea()
dbSelectArea(cBkp)
Return aZ01
