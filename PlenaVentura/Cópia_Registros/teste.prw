#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"


user function testetela()
Local oSay1
Local nTamFonte := 200
Local _cEmpOri :=Space(2)
Local _cFilOri :=Space(6)
Local _cEmpOld :=cEmpAnt


Static oDlg
DEFINE MSDIALOG oDlg TITLE "Memória de cálculo formação do preço de venda" FROM 000, 000 TO 500, 500 COLORS 0, 16777215 PIXEL
@ 010, 010 SAY oSay1 PROMPT "Empresa Origem"                                                    SIZE nTamFonte, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 020, 010 MsGet _cEmpOri	Size 040 , 010 When .T.  Pixel F3 "SM0MRP" 

@ 030, 010 SAY oSay1 PROMPT "Filial Origem"                                                   SIZE nTamFonte, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 040, 010 MsGet _cFilOri	Size 040 , 010 When .T.  Pixel F3 "SM0" 

/*
@ nLinha, nColuna MSGET VARIAVEL SIZE nLargura,nAltura UNIDADE OF oObjetoRef F3 cF3 VALID validação WHEN condição PICTURE cPicture

@ 020, 040 SAY oSay1 PROMPT "2 - Markup (Cliente -> Produto -> Grupo Tributário -> Estado)"             SIZE nTamFonte, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 030, 040 SAY oSay1 PROMPT "3 - Soma tributos"                                                         SIZE nTamFonte, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 040, 040 SAY oSay1 PROMPT "4 - Calcula Preço Venda(Custo Médio + Markup  / (1 -(Soma tributos/100)))" SIZE nTamFonte, 007 OF oDlg COLORS 0, 16777215 PIXEL

@ 100, 064 SAY oSay1 PROMPT "Custo Médio Produto: "+transform( nCustoMedio, "@E 999,999.99")             SIZE nTamFonte, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 110, 064 SAY oSay1 PROMPT "Markup: "  + cValtoChar(nMarkup ) +" %"                               SIZE nTamFonte, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 120, 064 SAY oSay1 PROMPT "Soma tributos: " + cValtoChar(nSomaAliq ) +" %"                        SIZE nTamFonte, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 130, 064 SAY oSay1 PROMPT "	ICMS: " + cValtoChar(nAliqICMS ) +" %"                        SIZE nTamFonte, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 140, 064 SAY oSay1 PROMPT "	PIS: " + cValtoChar(nAliqPIS ) +" %"                        SIZE nTamFonte, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 150, 064 SAY oSay1 PROMPT "	COFINS: " + cValtoChar(nAliqCofins ) +" %"                        SIZE nTamFonte, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 170, 064 SAY oSay1 PROMPT "Preço Venda: "  +  transform(  nPrecoVenda , "@E 999,999.99") SIZE nTamFonte, 007 OF oDlg COLORS 0, 16777215 PIXEL
*/
@ 210, 150 BUTTON Sair PROMPT "Sair"                                                   SIZE 037, 012 OF oDlg PIXEL Action oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

Return
