
#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TBICONN.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "RPTDEF.CH"
#include "shell.ch" 
#INCLUDE "colors.ch"
#INCLUDE "font.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "fileio.ch"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÔ[¿ 
//³FUNÇÃO PARA GERAR O VALOR DO TITULOS       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÔ[Ù
User Function VlTitulo()
Local nValorAbatimentos := SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",/*data*/,/*nValorImpostos*/,/*nTotIrAbt*/,/*nTotCsAbt*/,/*nTotPisAbt*/,/*nTotCofAbt*/,/*nTotInsAbt*/,SE1->E1_FILIAL, /*nTxMoeda*/, /*nTotISS*/)
Local nValorDocumento := Round((((SE1->E1_SALDO+SE1->E1_ACRESC)-SE1->E1_DECRESC)*100)-(nValorAbatimentos*100),0)/100
nValorDocumento :=  STRZERO(nValorDocumento*100,13)
Return nValorDocumento

 
