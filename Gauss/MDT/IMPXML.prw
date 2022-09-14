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
user function ImpSST

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
aFiles := Directory(cDir+"\*.XML")
nCont :=1
cArq :=""
if select('SRA')==0
	DbselectArea('SRA')
Endif
SRA->( DbSetOrder(5)) // FIlial + CIC
for nCont  := 1 to len(aFiles)
	if (FWCodEmp()+fwcodfil() <> SubStr(aFiles[nCont,1],1,4))
		cName := FWCodEmp()+fwcodfil()+"_S-"+substr(aFiles[nCont,1],3,4) +substr(aFiles[nCont,1],9,len(aFiles[nCont,1]) -8)
		//frename(cDir+aFiles[nCont,1], Upper(cDir+cName ))
		FT_FUSE(cDir+aFiles[nCont,1])
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()        
		While !FT_FEOF()
			cArq += alltrim(FT_FREADLN())
			FT_FSKIP()
		EndDo

		cCPF := Substr(cArq, At('<cpfTrab>',cArq)+ 9,11)
		cAntes:=left(cArq ,At('<matricula>',cArq) +10)
		cDepois := Right(cArq, len(cArq) - At('</matricula>',cArq)  +1)
		cCodUnic:=""
		SRA->( DbGotop())
		if SRA->( DbSeek(xFilial('SRA') + cCPF))
			cCodUnic := SRA->RA_CODUNIC
		Endif
		cArq:= cAntes + Alltrim(cCodUnic) + cDepois

		nHandle := FCREATE(cDir+Upper(cName))
		 if nHandle = -1
			conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
		else
			FWrite(nHandle, cArq)
			FClose(nHandle)
		endif
	Endif
Next nCont
Return 
