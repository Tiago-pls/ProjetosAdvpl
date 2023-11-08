#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  RepMarc    ¦ Autor ¦ Tiago Santos        ¦ Data ¦02.08.23 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Marcações ìmpares                                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
// Programa desenvolvido por SMS Consultoria

user function CTBEst()

Local _lOk := .T.
Local aItens := {}
Local     nOpcao := 3
Local aCab := {}
Local aItens := {}
//MV_CONTSB  deixar esse parâmetro como S

    aAdd(aCab,{'DDATALANC' , dDataBase,NIL})
    aAdd(aCab,{'CLOTE'     , '000001',NIL})
    aAdd(aCab,{'CSUBLOTE'  , '001'   ,NIL})
   	aAdd(aCab,{'CDOC'      , '01'    ,NIL})
    aAdd(aCab,{'CPADRAO'   , ''      ,NIL})
    aAdd(aCab,{'NTOTINF'   , 0       ,NIL})
    aAdd(aCab,{'NTOTINFLOT', 0       ,NIL})

 aAdd(aItens,{{'CT2_FILIAL', xFilial("CT2"), NIL},;
    	             {'CT2_LINHA' , '001'        , NIL},;
        	         {'CT2_MOEDLC', '01'          , NIL},;
            	     {'CT2_DC'    , '1'           , NIL},;
                	 {'CT2_DEBITO', '1839000056'    , NIL},;
	                 {'CT2_CREDIT', ''    , NIL},;
    	             {'CT2_VALOR' ,10000 , NIL},;
        	         {'CT2_ORIGEM', 'CTBA102'              , NIL},;
            	     {'CT2_HP'    , ''                     , NIL},;
                	 {'CT2_HIST'  , 'VLR REF ESTOQUES FINAIS D/MÊS CFE INV',NIL}})
PRIVATE lMsErroAuto := .F.

	lMsErroAuto := .F.
	//Executa a transação
	If Len(aCab) > 0 .AND. Len(aItens) > 0 // .and. (nValor > 0)
		MSExecAuto({|x,y,z| CTBA102(x,y,z)}, aCab ,aItens, nOpcao)
		If lMsErroAuto
			If !IsBlind()
				MsgAlert('Erro na inclusao da Contabilizacao do variacao cambial (CT2)!')
				MostraErro()
			EndIf
		EndIf
	EndIf

Return
