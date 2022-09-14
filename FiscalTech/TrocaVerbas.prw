User function TrocaVB
local nCont := 0
aVBDe   := strtokarr (GetMV("FS_VERBDE"), ",")
aVBPara := strtokarr (GetMV("FS_VERBPAR"), ",")

for nCont :=1 to len(aVBDe)
    if fBuscapd(aVBDe[nCont]) > 0
        apd[fLocaliaPD(aVBDe[nCOnt]), 1] := aVBPara[nCont]   
    EndIF
Next nCont

return
