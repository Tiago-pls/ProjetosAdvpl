#include "totvs.ch"
#include "protheus.ch"
#include "TOPCONN.CH"

/***************************************************************************************************/
/** SIGAFAT - FATURAMENTO                                                                         **/
/** IMPORTAÇÃO TABELA DE PREÇO - COMPRA                                                           **/
/** Autor: Thiago Senne 	                                                                      **/
/** SMS SOLUCOES - CURITIBA                                                                       **/
/** Data: 30/09/2021	                                                                          **/
/** Ultima Atualizacao: 30/09/2021                                                                **/
/***************************************************************************************************/
/** Fonte utilizado para importar TABELA DE PREÇO COMPRA, através do arquivo TXT/CSV              **/
/**	Neste arquivo, importamos via csv ou txt.  Realiza a importação somente da AIB.               **/
/**	Vale lembrar que temos que observar os campos obrigatórios que existem dentro do sistema ao   **/
/**	CSV/TXT.                                                                                      **/
/***************************************************************************************************/
/** Data       | Responsavel                    | Descricao                                       **/
/***************************************************************************************************/
/** 30/09/2021 | Thiago Senne				    | Criacao da rotina/procedimento.                 **/
/***************************************************************************************************/

User Function fImpCsv() 
Local cDiret
Local cLinha  := ""
Local lPrimlin   := .T.
Local aCampos := {}
Local aDados  := {}
Local i
Local j 
Private aErro := {}
 
cDiret :=  cGetFile( 'Arquito CSV|*.csv| Arquivo TXT|*.txt| Arquivo XML|*.xml',; //[ cMascara], 
                         'Selecao de Arquivos',;                  //[ cTitulo], 
                         0,;                                      //[ nMascpadrao], 
                         'C:\TOTVS\',;                            //[ cDirinicial], 
                         .F.,;                                    //[ lSalvar], 
                         GETF_LOCALHARD  + GETF_NETWORKDRIVE,;    //[ nOpcoes], 
                         .T.)         

FT_FUSE(cDiret)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()
While !FT_FEOF()
 
	IncProc("Lendo arquivo texto...")
 
	cLinha := FT_FREADLN()
 
	If lPrimlin
		aCampos := Separa(cLinha,";",.T.)
		lPrimlin := .F.
	Else
		AADD(aDados,Separa(cLinha,";",.T.))
	EndIf
 
	FT_FSKIP()
EndDo
 
Begin Transaction
	ProcRegua(Len(aDados))
	For i:=1 to Len(aDados)
 
		IncProc("Importando Registros...")
 
		dbSelectArea("ST9")
		dbSetOrder(1)
		dbGoTop()
		If !dbSeek(xFilial("ST9")+aDados[i,1]+aDados[i,2]+aDados[i,4])
			Reclock("ST9",.T.)
			ST9->ST9_FILIAL := xFilial("ST9")
			For j:=1 to Len(aCampos)
				cCampo  := "ST9->" + aCampos[j]
			SX3->(dbSetOrder(2))
			SX3->(dbSeek(aCampos[j]))	
			If  SX3->X3_TIPO  = 'N'	
				&cCampo := val(aDados[i,j])
			elseif SX3->X3_TIPO  = 'D'				
				&cCampo := Stod(aDados[i,j])
			Else
				&cCampo := aDados[i,j]
			EndIf
			Next j
			ST9->(MsUnlock())
		EndIf
	Next i
End Transaction
  
ApMsgInfo("Importação concluída com sucesso!","Sucesso!")
 
Return
