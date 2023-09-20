#Include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
//#include "Directry.ch"  

User function ImpCoop() 
	oProcess := MsNewProcess():New({|| ImpCop()}, "Processando...", "Aguarde...", .T.)
	oProcess:Activate()

Return

Static Function ImpCop()
cTipo := "Arquivos Texto  (*.CSV)  | *.CSV | "
cArq := cGetFile(cTipo,OemToAnsi("Selecionar Arquivo..."))
If !File(cArq)
	MsgStop("O arquivo  nao foi encontrado. A importacao sera abortada!","[AEST901] - ATENCAO")
	Return
EndIf   

FT_FUSE(cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()        

aDados := {}     

lPrim := .T.
nQtd := 0
While !FT_FEOF() 	
 
	cLinha := FT_FREADLN()
    oProcess:IncRegua2("Importando CPF " +SubStr(cLinha,447,11) )
	If lPrim
		lPrim := .F.
	Else
		gravaVal( Separa( cLinha,";",.T.))
	EndIf
		
	FT_FSKIP()
EndDo

return

static function gravaVal( aDados)

if Alltrim(aDados[6]) == Alltrim(aDados[9]) 
	// Titular

Endif 

return
