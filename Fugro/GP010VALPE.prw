/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦  GP010AGRV  ¦ Autor ¦ Tiago Santos        ¦ Data ¦25.06.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Ponto de Entrada para gravacao do historico de alteracoes ¦¦¦
¦¦¦          ¦  Superiores                                                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

user function GP010VALPE
Local aArea  := GetArea()
Local lRet := .T.
if SRA->RA_SUPERIO <> M->RA_SUPERIO
	if RecLock("Z03",.T.)
		Z03->Z03_FILIAL  	:= xFilial("SRA")
		Z03->Z03_MAT		:= M->RA_MAT
		Z03->Z03_DATA		:= Date()
		Z03->Z03_SUPERI		:= M->RA_SUPERIO
		Z03->Z03_USUARI     := UsrFullName( ) 
		Z03->Z03_HORA   	:= alltrim(Time()) 
	endif
Endif
RestArea(aArea)
return lRet

