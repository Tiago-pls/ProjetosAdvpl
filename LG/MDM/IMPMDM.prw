#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  IMPMdm       ¦ Autor ¦ Tiago Santos      ¦ Data ¦22.07.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Importa~ção campos novos MDM  - SRA - ZRA     		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

user function ImpMDM()
                     
Local cTitulo   := "Selecione o Diretorio para Importar o arquivo..."
Local nMascpad  := 0                        
Local cDirini   := "\"
Local nOpcoes   := GETF_LOCALHARD
Local lArvore   := .F. /*.T. = apresenta o ?rvore do servidor || .F. = n?o apresenta*/   
Local lSalvar   := .F. /*.T. = Salva || .F. = Abre*/

cArq := cGetFile( '*.csv|*.csv' , cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)

If !File(cArq)
	MsgStop("O arquivo  nao foi encontrado. A importacao sera abortada!","[AEST901] - ATENCAO")
	Return
EndIf       
   
MsAguarde({|| ProcArq(cArq)}, "Aguarde...", "Processando Registros...")


Return

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  ProcArq    ¦ Autor ¦ Tiago Santos        ¦ Data ¦26.07.21 ¦¦¦
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
 
	IncProc("Lendo arquivo texto..." + cValToChar(nQtd))
	cLinha := FT_FREADLN()
    
	If lPrim
		lPrim := .F.
	Else 
        cLinha := Tratatex(cLinha) 		  
		nQtd += gravaMDM( Separa( cLinha,";",.T.))                                                  
	EndIf
		
	FT_FSKIP()
EndDo

MSGALERT( "Foram importados " + cValtoChar(nQtd) + " registros", "Importacao" ) 
Return                    


/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  gravaBH     ¦ Autor ¦ Tiago Santos      ¦ Data ¦22.09.20  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Gravacao Banco de Horas                     		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

static function gravaMDM( aDados)

Local nImp    := 0
Local cChave  := StrZero(val(aDados[1]),2)+  StrZero(val(aDados[2]),6)
Local cFil    := StrZero( val( aDados[1]),2)
Local cMat    := StrZero(val(aDados[2]),6)

if select("ZRA") == 0 
    DbSelectArea("ZRA")
Endif

if select("SRA") == 0 
    DbSelectArea("SRA")
Endif
SRA->( DbSetOrder(1))
SRA->( DbGotop())
if SRA->( DbSeek(cChave))

    cMotConTem  := Upper( NoAcento(Alltrim(adados[5]))) //RA_XMOTCTE
    cMotCont    := Upper(adados[8]) //RA_XMOTCON
    cExpat      := Upper(Alltrim(adados[9])) //RA_XEXPATR
    cTransOrg   := Upper(Alltrim(adados[10])) //ZRA_TRVORG
    cTransOrgDt := adados[11] //ZRA_TRANSD

    // Atualizar SRA
    cBHRMAN     := adados[16]  //ZRA_HIERMA
    cHRDate     := adados[17] //ZRA_XHRDTI
    cBHIERM     := adados[18]  //ZRA_BHRMAN
    cEmpDirLi   := adados[19] //ZRA_DLMGID
    cCurso      := Alltrim(Upper(adados[21]))
    dDtConCurso := adados[22] //RA_COURDT
    cJobRep     := Upper(Alltrim(adados[23])) //ZRA_JOBREP
    dJobRepIni  := Upper(Alltrim(adados[24])) //ZRA_JOBREP
    cLGStatus   := Upper(Alltrim(adados[25])) //RA_XLGSTAT
    dDtStatus   := adados[26] 
     Begin transaction 
          if RecLock("SRA",.F.)
                SRA->RA_XMOTCTE  :=  cMotConTem 
                SRA->RA_XCHAVE   :=  SRA->(RA_FILIAL + RA_MAT)
                SRA->RA_XCOURDT  :=  Stod(subStr(dDtConCurso, 7,4) + subStr(dDtConCurso, 4,2) + subStr(dDtConCurso, 1,2))      
                SRA->RA_XMOTCON  :=  cMotCont   
                SRA->RA_XEXPATR  :=  cExpat
                SRA->RA_XCOURSE  :=  cCurso
                SRA->RA_XLGSTAT  :=  cLGStatus    
                SRA->RA_XLGSTAR  :=  Stod(subStr(dDtStatus, 7,4) + subStr(dDtStatus, 4,2) + subStr(dDtStatus, 1,2))  
             MsUnLock("SRA")
          endif      
      END TRANSACTION
    // Atualizar ZRA
    ZRA->( DbSetOrder(1)) 
    ZRA->( Dbgotop())

    if  ZRA->( DbSeek( cChave))
        Begin transaction 
            if RecLock("ZRA",.F.)
                ZRA->ZRA_TRVORG   := cTransOrg  
                ZRA->ZRA_TRANSD   := Stod(subStr(cTransOrgDt, 7,4) + subStr(cTransOrgDt, 4,2) + subStr(cTransOrgDt, 1,2))
                ZRA->ZRA_XHRDTI   := Stod(subStr(cHRDate, 7,4) + subStr(cHRDate, 4,2) + subStr(cHRDate, 1,2))                     
                ZRA->ZRA_DLMGID   := Stod(subStr(cEmpDirLi, 7,4) + subStr(cEmpDirLi, 4,2) + subStr(cEmpDirLi, 1,2))
                ZRA->ZRA_JOBREP   := cJobRep
                ZRA->ZRA_XJOBRE   := Stod(subStr(dJobRepIni , 7,4) + subStr(dJobRepIni , 4,2) + subStr(dJobRepIni , 1,2))
                ZRA->ZRA_BHIERM   := cBHIERM
                ZRA->ZRA_BHRMAN   := cBHRMAN//cHierMan   
                MsUnLock("ZRA")   
            endif      
        END TRANSACTION   
    else
         Begin transaction 
            if RecLock("ZRA",.T.)           
                ZRA->ZRA_FILIAL   :=cFil
                ZRA->ZRA_MAT      := cMat
                ZRA->ZRA_TRVORG   := cTransOrg 
                ZRA->ZRA_TRANSD   := Stod(subStr(cTransOrgDt, 7,4) + subStr(cTransOrgDt, 4,2) + subStr(cTransOrgDt, 1,2))
                ZRA->ZRA_XHRDTI   := Stod(subStr(cHRDate, 7,4) + subStr(cHRDate, 4,2) + subStr(cHRDate, 1,2))
                ZRA->ZRA_BHIERM   := cBHIERM
                ZRA->ZRA_BHRMAN   := cBHRMAN//cHierMan   
                ZRA->ZRA_DLMGID   := Stod(subStr(cEmpDirLi, 7,4) + subStr(cEmpDirLi, 4,2) + subStr(cEmpDirLi, 1,2))
                ZRA->ZRA_JOBREP   := cJobRep
                ZRA->ZRA_XJOBRE   := Stod(subStr(dJobRepIni , 7,4) + subStr(dJobRepIni , 4,2) + subStr(dJobRepIni , 1,2))
                MsUnLock("ZRA")
            endif      
        END TRANSACTION
    endif
    nImp ++
Endif
return nImp

static function Tratatex(cTexto)
cTexto := Strtran(cTexto,'‡','c')
cTexto := Strtran(cTexto,'Ö','i')
cTexto := Strtran(cTexto,'Æ','a')
cTexto := Strtran(cTexto,'¢','o')
cTexto := Strtran(cTexto,'ÿ','')
cTexto := Strtran(cTexto,'ˆ','E')
cTexto := Strtran(cTexto,'“','O')
cTexto := Strtran(cTexto,'¡','I')

Return cTexto
