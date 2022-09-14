Function U_DIFMEDIA(cPdRot)
    cVerbaRot := cPdRot
    
    Begin Sequence
        If ( AbortProc() )
            Break
        EndIf
    
        IF ( FBUSCAPD("177")>0 )
    
            U_MEDFER()
    
        EndIF
    
    
    End Sequence
Return
