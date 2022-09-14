Function U_TESTARES(cPdRot)
    cVerbaRot := cPdRot
    
    Begin Sequence
        If ( AbortProc() )
            Break
        EndIf
    
        IF ( FBUSCAPD("001")==0 )
    
            FDELPD("001")
            aVBDe   := strtokarr (GetMV("FS_VERBDE"), ",")
            aVBPara := strtokarr (GetMV("AA_VERBPAR"), ",")
            for nCont :=1 to len(aVBDe)
                if fBuscapd(aVBDe[nCOnt]) > 0
                    nHrs := apd[fLocaliaPD(aHE[nCOnt]),4]
                    nSalHora := SRA->RA_SALARIO / SRA->RA_HRSMES
                    nPercHE := GetAdvFVal("SRV","RV_PERC", SRA->RA_FILIAL + aVBDe[nCOnt] ,1,"")  / 100
                    apd[fLocaliaPD(aVBDe[nCOnt]),5] := Round(nHrs * nSalHora * nPercHE,2)
                    
                EndIF
            Next nCont

    
    
    End Sequence
Return
