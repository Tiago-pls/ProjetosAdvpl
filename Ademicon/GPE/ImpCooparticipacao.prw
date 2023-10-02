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
		_aDados := gravaVal( Separa( cLinha,";",.T.))
		cTipo     := _aDados[5]
		cFilial   := _aDados[1]
		cFornec   := _aDados[7]
		cPlano    := _aDados[8]
		cCodigo   := _aDados[6]
		cMatr     := _aDados[2]
		cStatus   := _aDados[4]
		cExSra := POSICIONE("SRA",5,_aDados[1]+cCPF,"RA_NOME")
		IF Empty(cMatr) 
			aadd(_aErros,{STRZERO(cIdReg,6),cNome,nValEvent,"Carteirinha não cadastrado no Protheus"})		
			nQtd++
		ELSEIF Empty(cFornec) .And. cTipo = "T"
			aadd(_aErros,{STRZERO(cIdReg,6),cNome,nValEvent,"Titular não cadastrado no plano Ativo"})
			nQtd++
		ELSEIF Empty(cFornec) .And. cTipo = "D"
			aadd(_aErros,{STRZERO(cIdReg,6),cNome,nValEvent,"Dependente não cadastrado no plano Ativo"})
			nQtd++
		ELSE
			DbSelectArea("ZRH")
			DbSetOrder(1)
			DbGoTop()
		
			IF !DbSeek(_aDados[1]+cMatr+dtos(dDtOcor)+cTipo+cvaltochar(cIdReg))
				RecLock("ZRH",.t.)
				ZRH->ZRH_FILIAL	:= _aDados[1]
				ZRH->ZRH_MAT	:= cMatr
				ZRH->ZRH_CARTEI	:= cBenefic
				ZRH->ZRH_TIPO	:= cTipo
				ZRH->ZRH_PERIOD	:= dDtOcor
				ZRH->ZRH_VALOR	:= nValEvent
				ZRH->ZRH_ID     := cIdReg
				ZRH->ZRH_CODIGO := cCodigo
				ZRH->ZRH_CODFOR := cFornec
				ZRH->ZRH_TPPLAN := cPlano
				nConta++
				MsUnLock()
			ELSE
				RecLock("ZRH",.f.)
				ZRH->ZRH_VALOR	:= nValEvent
				MsUnLock()
			ENDIF
		ENDIF

	EndIf
		
	FT_FSKIP()
EndDo

return

static function gravaVal( aDados)

if Alltrim(aDados[6]) == Alltrim(aDados[9])  // Titular
	
	//recupera o registro mais recente do funcionário
	cQuery := " Select  RA_MAT MATRICULA from  " + RetSqlName("SRA") +" SRA"
	cQuery += " INNER JOIN RHK010 RHK ON RHK_TPFORN = '1' AND RA_FILIAL = RHK_FILIAL AND RA_MAT = RHK_MAT AND RHK_PERFIM = ' ' AND RHK.D_E_L_E_T_ = ' '	"
	cQuery += " Where SRA.D_E_L_E_T_ =' ' and RA_CIC ='" +aDados[43] + "' and RA_UNIMED ='" +aDados[46] + "'"
	cQuery += " and RA_ADMISSA = ( select Max(RA_ADMISSA) from " + RetSqlName("SRA") + " SRA where RA_CIC ='"+aDados[43]+"' and D_E_L_E_T_ =' ')"

else
	//recupera o registro mais recente do dependente
	cQuery := " Select  RB_MAT MATRICULA from  " + RetSqlName("SRB") +" SRB"
	CQuery += " inner join " + RetSqlName("SRA") +" SRA on RB_FILIAL = RA_FILIAL and RB_MAT = RA_MAT  and SRA.D_E_L_E_T =' ' " 
	cQuery += " LEFT JOIN RHL010 RHL ON RHL_TPFORN = '1' AND RA_FILIAL = RHL_FILIAL AND RA_MAT = RHL_MAT AND RHL_PERFIM = ' ' AND RHL.D_E_L_E_T_ = ' '	"
	cQuery += " Where SRB.D_E_L_E_T_ =' ' and RB_CIC ='" +aDados[43] + "' and RB_UNIMED ='" +aDados[46] + "'"
	cQuery += " and RA_ADMISSA = ( select Max(RA_ADMISSA) from " + RetSqlName("SRA") + " B "
	cQuery +=" where B.RA_FILIAL = SRA.RA_FILIAL and B.RA_MAT = SRA.RA_MAT  and B.D_E_L_E_T_  =' ')"
Endif 

if select(QR1) <> 0
	DbCloseArea("QR1")
Endif

TcQuery cQuery New Alias "QR1"
if QR1->(!EOF())
	aRet := aadd(aDados,{QR1->FILIAL,QR1->MATRICULA,QR1->UNIMED,QR1->STATUS,QR1->TIPO,QR1->CODIGO,QR1->FORNECEDOR,QR1->PLANO})
else
	aRet := {'','','','','','','',''}
Endif
return aRet
 