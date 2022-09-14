#INCLUDE 'PROTHEUS.CH'

User Function GP210SAL()
If SRA->RA_CATFUNC == "E"	.or. SRA->RA_CATFUNC =='G'
    nPercentual := 0.00
    EndIf
Return
