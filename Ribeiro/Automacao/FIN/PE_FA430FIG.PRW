#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA430FIG  ³ Autor ³ Alfred Andersen      ³ Data ³ 20/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Permite modificar o CNPJ obtido da leitura do arquivo de   ³±±
±±			 ³ retorno DDA, de modo que a tabela SA2 seja posicionada     ³±±
±±			 ³ através do CNPJ modificado neste ponto de entrada.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Permitir modificar CNPJ retorno DDA ( < cCNPJ> ) --> cCNP  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Antes da gravação do movimento DDA na tabela FIG.          ³±±
±±           ³ Programa Fonte										      ³±±
±±           ³ FINA430.PRX                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FA430FIG
	
Local cCNPJ 	:= ParamIxb[1]
LOCAL _cFornec	:= ParamIxb[2] //POSICIONE("SA2",3,xFilial("SA2")+cCNPJ,"A2_COD") 
LOCAL _nReg		:= 0
LOCAL _cValpgto
LOCAL _cVencto	

//Tratamento Valor
_cValpgto 	:= nValPgto

//Tratamento Data
_cVencto	:= DTOS(dBaixa)

IF(SELECT("QSE2")<>0)
	QSE2->(DBCLOSEAREA())
ENDIF

//Monta Query
BEGINSQL ALIAS "QSE2"

	SELECT * FROM %TABLE:SE2% SE2
	JOIN %TABLE:SA2% SA2 ON A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA AND A2_TIPO <> 'X' AND SA2.%NOTDEL%
	WHERE E2_FORNECE = %EXP:_cFornec%
	AND E2_VALOR = %EXP:_cValpgto%
	AND E2_VENCREA = %EXP:_cVencto%
	AND E2_BAIXA = ' '
	AND SE2.%NOTDEL%
ENDSQL

//ALERT(GETLASTQUERY()[2])

DbSelectArea("QSE2")

//Conta Nº de Registros
COUNT TO _nReg
QSE2->(DBGOTOP())

//Verifica condições conforme nº de registros
If	_nReg == 1
	cCNPJ := POSICIONE("SA2",1,xFilial("SA2")+QSE2->E2_FORNECE+QSE2->E2_LOJA,"A2_CGC")
ElseIf _nReg >= 2      
	cDir    := "C:\temp\"
	cArq    := "Log_Ocorrencia.txt"

	nHandle := FCreate(cDir+cArq)
	nCount  := 0
	If nHandle < 0
		MsgAlert("Erro durante criação do arquivo.")
		return
	Else
		While ! QSE2->( EOF())
			FWrite(nHandle, "Fornecedor: " +QSE2->E2_FORNECE + CRLF)
			FWrite(nHandle, "Valor: " +QSE2->E2_VALOR + CRLF)
			FWrite(nHandle, "Vencimento Real: " +QSE2->E2_VENCREA + CRLF)
			
			QSE2->(DbSkip())
		enddo
		FClose(nHandle)
	EndIf

Endif

QSE2->(DbCloseArea())
Return cCNPJ
