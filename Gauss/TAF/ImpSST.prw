#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*-----------------+------------------------------------------------------------+
!Nome              ! ImportSST                                                  !
+------------------+------------------------------------------------------------+
!DescriÃ§Ã£o       ! Fonte que trata os arquivos XML para os eventos SST eSocial!              
+------------------+------------------------------------------------------------+
!Autor             ! Tiago Santos                                               !
+------------------+------------------------------------------------------------!
!Data              ! 10/03/2021                                                 !
+------------------+------------------------------------------------------------!
+------------------+------------------------------------------------------------*/
user function ImportSST

Local cTitulo   := "Selecione o Diretorio para importação arquivos SST eSocial..."
Local nMascpad  := 0                        
Local cDirini   := "\"
Local nOpcoes   := GETF_RETDIRECTORY
Local lArvore   := .F. /*.T. = apresenta o ?rvore do servidor || .F. = n?o apresenta*/   
Local lSalvar   := .F. /*.T. = Salva || .F. = Abre*/
                                                                            
cDir :=cGetFile( '*.xml|*.xml' , 'SST eSocial', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )

If Empty(cDir)
	MsgStop("Diretório não selecionado. A importacao sera abortada!","[AEST901] - ATENCAO")
	Return
EndIf       
   
MsAguarde({|| ProcArq(cDir)}, "Aguarde...", "Processando Registros...")

Return

static Function ProcArq(cDir)
local oFile 
aFiles := Directory(cDir+"\*.XML")
nCont :=1
cArq :=""

for nCont  := 1 to len(aFiles)
	cArq := cDir+aFiles[nCont,1]
	cTexto := ""
	oFile := FWFileReader():New(cArq)
    if (oFile:Open())
        while (oFile:hasLine())
            cTexto += oFile:GetLine()
        end
        oFile:Close()
        cTexto:= u_GTrataCar(Lower(cTexto))
        If FERASE(cArq) == -1
            MsgStop('Falha na deleção do Arquivo')
        else
            oFWriter := FWFileWriter():New(cArq, .T.)
            oFWriter:Create()            
            oFWriter:Write(cTexto)
            oFWriter:Close()
        Endif
    endif
Next nCont
Return 

user function GTrataCar(cTexto)

cTexto := Strtran(cTexto,"a","a")
cTexto := Strtran(cTexto,"aª","e")
cTexto := Strtran(cTexto,"ao","e")
cTexto := Strtran(cTexto,"£","")
cTexto := Strtran(cTexto,"©","")
cTexto := Strtran(cTexto,"¡","")§
cTexto := Strtran(cTexto,"­","")
cTexto := Strtran(cTexto,"§","")
cTexto := Strtran(cTexto,"º","")
cTexto := Strtran(cTexto,"µ","")
cTexto := Strtran(cTexto,"ª","")
cTexto := Strtran(cTexto," ","")
cTexto := Strtran(cTexto,"¢","")
cTexto := Strtran(cTexto,"³","")
cTexto := Strtran(cTexto,"´","")
cTexto := NoAcento(cTexto)
Return cTexto
