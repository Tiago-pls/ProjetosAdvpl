#Include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
//#include "Directry.ch"  

User function ImpUnimed() 
	Processa({||ImpCop(),"Importação de Co-participação" })
Return

Static Function ImpCop()

cTipo := "Arquivos Texto  (*.TXT)  | *.TXT | "
cNomeTXT := cGetFile(cTipo,OemToAnsi("Selecionar Arquivo..."))

if Empty(cNomeTXT)
	Return
EndIF

FT_FUSE(cNomeTXT)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()        

nLidos := 0

// criar indice RA_UNIMED  - SRA
DbSelectArea("SRA")
cArquivo := CriaTrab(,.F.)
cChave := "RA_UNIMED"
cFor := "!Empty(RA_UNIMED)"
IndRegua("SRA",cArquivo,cChave,,cFor)

DbSelectArea("SRA")
nIndex := RetIndex("SRA")
#IFNDEF TOP   
	SRA->( DbSetIndex(cArquivo+OrdBagExt()))
#ENDIF
SRA->( DbSetOrder(nIndex+1))

// criar indice RB_UNIMED --  SRB
DbSelectArea("SRB")
cArquivo := CriaTrab(,.F.)
cChave := "RB_UNIMED"
cFor := "!Empty(RB_UNIMED)"
IndRegua("SRB",cArquivo,cChave,,cFor)

DbSelectArea("SRB")
nIndex := RetIndex("SRB")
#IFNDEF TOP   
	SRB->( DbSetIndex(cArquivo+OrdBagExt()))
#ENDIF
SRB->( DbSetOrder(nIndex+1))


DbSelectArea("RHK")
RHK->( dbSetOrder(1))

DbSelectArea("RHL")
RHL->( DbSetOrder(1))

				
While !FT_FEOF()
	IncProc("Lendo arquivo texto..." )
 
	cLinha := FT_FREADLN()
		if At("",cLinha) >0
			cLinha := STRTRAN( cLinha, "", "")

		Endif

		If SubStr(cLinha,1,14)=='BENEFICIÁRIO: '  
			cBenefic  := SubStr(cLinha,15,16)    
			nValEvent := 0.00 
			nLidos++
			FT_FSKIP()
		EndIf
		If SubStr(cLinha,1,14)=='Total Eventos:'    
			
			nValEvent := Val(STRTRAN(SubStr(cLinha,150,25),",","."))   

			if SRA->( DbSeek(cBenefic)) // Titular
				RHK->( DbGoTop())
				if RHK->( DbSeek(SRA->(RA_FILIAL + RA_MAT)+"101 "))				
					RecLock("RHO",.t.)
						RHO->RHO_FILIAL	:= SRA->RA_FILIAL
						RHO->RHO_MAT	:= SRA->RA_MAT 
						RHO->RHO_DTOCOR	:= dDataBase
						RHO->RHO_ORIGEM	:= '1'
						RHO->RHO_TPFORN	:= '1'
						RHO->RHO_CODFOR	:= '01'
						RHO->RHO_CODIGO	:= '  '
						RHO->RHO_TPLAN	:= '1' //RHK->RHK_TPPLAN
						RHO->RHO_PD		:= '457'
						RHO->RHO_VLRFUN	:= nValEvent
						RHO->RHO_VLREMP	:= 0.00
						RHO->RHO_COMPPG	:= SubStr(Dtos(dDataBase),1,6)
						RHO->RHO_OBSERV	:= ' '     
					MsUnLock()
				Endif
			Elseif SRB->( DbSeek(cBenefic)) // dependente
				RHL->( DbGoTop())
				if RHL->( DbSeek( SRB->(RB_FILIAL + RB_MAT) + "101 "+SRB->RB_COD))
					RecLock("RHO",.t.)
					RHO->RHO_FILIAL	:= SRB->RB_FILIAL
					RHO->RHO_MAT	:= SRB->RB_MAT 
					RHO->RHO_DTOCOR	:= dDataBase
					RHO->RHO_ORIGEM	:= '2'
					RHO->RHO_TPFORN	:= '1'
					RHO->RHO_CODFOR	:= '01'
					RHO->RHO_CODIGO	:= SRB->RB_COD	
					RHO->RHO_TPLAN	:= '1' //RHL->RHL_TPPLAN
					RHO->RHO_PD		:= '457'
					RHO->RHO_VLRFUN	:= nValEvent
					RHO->RHO_VLREMP	:= 0.00
					RHO->RHO_COMPPG	:= SubStr(Dtos(dDataBase),1,6)
					RHO->RHO_OBSERV	:= ' '     
					MsUnLock()   
				endif

			Endif
		endif

	nLidos++
	FT_FSKIP()

Enddo
DbSelectArea("SRA")
RetIndex("SRA")
FErase(cArquivo+OrdBagExt())

DbSelectArea("SRB")
RetIndex("SRB")
FErase(cArquivo+OrdBagExt())
Return       
