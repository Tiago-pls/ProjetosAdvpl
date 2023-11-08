#include 'totvs.ch'
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

user function ADMCGBOR()
    Local cFilAnt_Bkp := cFilAnt
    Local aTit := {} 
    Local aBor := {}

    Local cSituaca := "1"
    Local dDataMov := ""
	local oObjLog   := LogSMS():new()
    local oObjParm  := JsonObject():New() as Object
    local cParam as character
    local xRet

	private lAutoErrNoFile := .T.
	private lMsErroAuto := .F.
    Private cBanco    := ''
    Private cAgencia  := ''
    Private cConta    := ''
    Private cArqConf  := ''  
	oObjLog:setFileName("\temp\"+procname()+"_"+dtos(date())+".txt")
	oObjLog:saveMsg("================")
    _aBCO       := strtokarr(SuperGetMv("AD_BCOBOL",.F.),';')
    cBanco      := PadR(_aBCO[1] ,TamSX3("A6_COD")[1]) 
    cAgencia    := PadR(_aBCO[2] ,TamSX3("A6_AGENCIA")[1]) 
    cConta      := PadR(_aBCO[3] ,TamSX3("A6_NUMCON")[1])
    cNumBor := Soma1(GetMV("MV_NUMBORR"),6)

    RECLOCK( "SEA", .T. )
        SEA->EA_FILIAL  := xFilial("SEA")
        SEA->EA_DATABOR := dDataBase
        SEA->EA_PORTADO := cBanco
        SEA->EA_AGEDEP  := cAgencia
        SEA->EA_NUMCON  := cConta
        SEA->EA_SITUACA := cSituaca
        SEA->EA_NUM 	:= SE1->E1_NUM
        SEA->EA_PARCELA := SE1->E1_PARCELA
        SEA->EA_PREFIXO := SE1->E1_PREFIXO
        SEA->EA_TIPO	:= SE1->E1_TIPO
        SEA->EA_CART	:= "R"
        SEA->EA_SITUANT := ' '//cSituAnt
        SEA->EA_FILORIG := SE1->E1_FILORIG
    SEA->( MSUNLOCK())

    
    RECLOCK( "SE1", .F. )
            SE1->E1_PORTADO := cBanco
            SE1->E1_AGEDEP  := cAgencia
            SE1->E1_SITUACA := cSituaca
            SE1->E1_CONTRAT := SEE->EE_NUMCONTR
            SE1->E1_NUMBCO  := cBanco
            SE1->E1_MOVIMEN := ddatabase
            SE1->E1_CONTA	:= cConta
    SE1->(MSUNLOCK())

Return
