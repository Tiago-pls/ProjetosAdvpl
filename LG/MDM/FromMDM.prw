#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#include 'tbiconn.ch'
#include "RWMAKE.CH"
#include 'parmtype.ch'
#Define ENTER  ''
User function FROMMDM()
local cPath := GetMv("LG_MDMFILE")+"FROM\" 
//PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01'
aFiles := Directory(cpath + "*.*")

If len(aFiles) ==0
	conout("O arquivo  nao foi encontrado. A importacao sera abortada!","[AEST901] - ATENCAO")
	Return
EndIf       
for nCont :=1 to len (aFiles)
    MsAguarde({|| ProcArq(cpath + aFiles[nCont,1])}, "Aguarde...", "Processando Registros...")
    Next nCont

Return

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  ProcArq    ¦ Autor ¦ Tiago Santos        ¦ Data ¦16.10.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Processa o arquivo selecionado                 		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

static function ProcArq(cArq)  

FT_FUSE(cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()        

aDados := {}     

lPrim := .T.
nQtd := 0
While !FT_FEOF()
 
	Conout("Lendo arquivo texto..." + cValToChar(nQtd))
 
	cLinha := FT_FREADLN()
	If lPrim
		lPrim := .F.
	Else  		  
		GravaMDM( Separa( Strtran(clinha,'"',''),";",.T.))                                                  
	EndIf
		
	FT_FSKIP()
EndDo

conout( "Foram importados " + cValtoChar(nQtd) + " registros", "Importacao" ) 
Return                    


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  gravaBH     ¦ Autor ¦ Tiago Santos      ¦ Data ¦16.10.21  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Gravacao Banco de Horas                		              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

static function GravaMDM( aDados)

if select("SRA") ==0
    DbSelectArea("SRA")
Endif 

SRA->( DbSetorder(13))
SRA->( DbGoTop())
cMat := Strzero(val(Alltrim(aDados[2])),6)
If SRA->( DbSeek(cMat))
    Begin transaction 
        if RecLock("SRA",.F.)
            SRA->RA_MDMCOD := aDados[3]
            MsUnLock("SRA")
        endif      
    END TRANSACTION
endif


return
