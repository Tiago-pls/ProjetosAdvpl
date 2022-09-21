#include 'totvs.ch'
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

user function altped()
	Local _aGrp := UsrRetGrp(RetCodUsr())
	Local w
	Local _Grpf := "000004"
	Local _GrpAdm := SuperGetMV("SL_ALETAPA",.F.,"000000")
	Local _cUser  := SuperGetMV("ZZ_ALTPED",.F.,"000000")
	Local _lFiltra := .F.
	Local _lFind := .F.
	Local _lAdm  := .F.
	//testes
	Private ntplib := ""
	Private oDlg1
	Private oPanel
	Private oSay
	Private oGet
	Private oButConfirm
	Private oButClose
	Private aEtapas := {"02=Aguardando Depósito/Cartão",;
						"03=Aguardando Adiantamento",;
						"04=Análise Custo",;
						"05=Análise Crédito",;
						"06=Bloqueio de Estoque",;
						"07=Movimentação de Estoque",;
						"08=Entrega Futura",;
						"09=Listagem",;
						"10=Faturamento",;
						"15=Separação",;
						"16=Conferência",;
						"11=Expedição",;
						"12=Finalizado",;
						"20=Plano de Corte",;
						"21=Ag. Mont. Carga",;
						"22=Rentabilidade/Regras",;
						"23=Mesa de Corte",;
						"24=Lapidação",;
						"95=Programação",;
						"96=Estorno da Liberacao de Estoque",;
						"97=Cancelado/Residuo",;
						"98=Crédito Rejeitado",;
						"99=Nota Cancelada"};

	If !(RetCodUsr() $ _cUser)
		MsgAlert("Você não tem permissão para acessar esta rotina!")
		Return
	Endif

	For w:=1 to Len(_aGrp)

		If  alltrim(_aGrp[w]) $ _GrpAdm
			_lAdm := .T.
			EXIT
		Endif

		If _aGrp[w] == _Grpf .and. !_lFind
			_lFiltra := .T.
			_lFind := .T.
		Endif

	Next w

    If RetCodUsr() $ _GrpAdm
		_lAdm := .T.
	Endif

	_cNomCli     := GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,1,"")
	_cCliente    := SC5->C5_CLIENTE + " - " + _cNomCli
	_cCodCli 	 := SC5->C5_CLIENTE
	_cLoja 		 := SC5->C5_LOJACLI
	_nPesoL      := SC5->C5_PESOL   //Str(SC5->C5_PESOL)
	_nPesoB      := SC5->C5_PBRUTO  //Str(SC5->C5_PBRUTO)
	_nVolume     := SC5->C5_VOLUME1 //Str(SC5->C5_VOLUME1)
	_cEspeci1    := SC5->C5_ESPECI1
	_cTransp     := SC5->C5_TRANSP
	_cDesTra 	 := Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME")
	_MsgNF       := SC5->C5_MENNOTA
	_NUMPV		 := SC5->C5_NUM
	_cMenPad	 := SC5->C5_MENPAD
	_cDesMen	 := Posicione("SM4",1,xFilial("SM4")+SC5->C5_MENPAD,"M4_DESCR")
	_cEtapa	     := SC5->C5_ZETAPA
	_cRedesp	 := SC5->C5_REDESP
	_cDesRed 	 := Posicione("SA4",1,xFilial("SA4")+SC5->C5_REDESP,"A4_NOME")
	_cNota 		 := SC5->C5_NOTA
	_ObsInt		 := SC5->C5_ZOBSINT
	//_cMenPad2	 := SC5->C5_MENPAD2
	//_cMenPad3	 := SC5->C5_MENPAD3

	ntplib := SC5->C5_TIPLIB

	@ 0,0 TO 500,700 DIALOG oDlg1 TITLE "Atualizacao de Dados do Pedido de Venda - "+SC5->C5_NUM

	@ 021,010 Say " Pedido de Venda: "
	@ 020,060 Get  _NUMPV     Size 064,050 When .F.
	@ 031,010 Say " Cod. do Cliente: "
	@ 030,060 Get  _cCliente  Size 205,205 When .F.
	@ 051,010 Say " Peso Liquido   : "
	@ 050,060 Get  _nPesoL    Size 070,050 Picture PesqPict("SC5","C5_PESOL")
	@ 061,010 Say " Peso Bruto     : "
	@ 060,060 Get  _nPesoB    Size 070,050 Picture PesqPict("SC5","C5_PBRUTO")
	@ 071,010 Say " Qtd. de Volumes: "
	@ 070,060 Get  _nVolume   Size 030,050 Picture "@E 9999"
	@ 081,010 Say " Especie        : "
	@ 080,060 Get  _cEspeci1  Size 070,050
	@ 101,010 Say " Transportadora : "
	@ 100,060 Get  _cTransp   Size 030,050 F3 "SA4" Valid Vazio().or.ExistCpo("SA4") .and. GatTransp(_cTransp,@_cDesTra)
	@ 100,095 Get  _cDesTra Size 170,050 When .F.
	@ 111,010 Say " Msg. Pad. 1 : "
	@ 110,060 Get  _cMenpad   Size 030,050 F3 "SM4" Valid Vazio().or.ExistCpo("SM4") .and. GatMenPad(_cMenpad,@_cDesMen)
	@ 110,095 Get _cDesMen	  Size 170,050 When .F.

	@ 121,010 Say " Tipo de Lib. : "
	@ 120,060 MSCOMBOBOX ctplib VAR ntplib ITEMS {"2=Por Pedido","1=Por Item"} SIZE 058, 010 OF oDlg1 COLORS 0, 16777215 PIXEL When .F.
	IF _lAdm
		@ 131,010 Say " Etapa do Pedido : "
		@ 130,060 MSCOMBOBOX cEtapa VAR _cEtapa ITEMS aEtapas  SIZE 120, 010 OF oDlg1 VALID _cEtapa $ ("02/03/04/05/06/08/09/10/15/16/11/12/20/21/23/24/95/98/99") COLORS 0, 16777215 PIXEL WHEN _cEtapa $ ("02/03/04/05/06/09/10/15/16/11/12/20/21/23/24/95/98/99")
	ELSE
		If SC5->C5_FILIAL != "0202"
			@ 131,010 Say " Etapa do Pedido : "
			@ 130,060 MSCOMBOBOX cEtapa VAR _cEtapa ITEMS aEtapas  SIZE 058, 010 OF oDlg1 VALID _cEtapa $ ("09/16/15/10/11/12") COLORS 0, 16777215 PIXEL WHEN _cEtapa $ ("09/16/15/10/11/12")
		Else
			If _lFiltra
				@ 131,010 Say " Etapa do Pedido : "
				@ 130,060 MSCOMBOBOX cEtapa VAR _cEtapa ITEMS aEtapas  SIZE 058, 010 OF oDlg1 VALID _cEtapa $ ("09/20/15/21/23/24") COLORS 0, 16777215 PIXEL WHEN _cEtapa $ ("09/20/15/21/23/24")
			Else
				@ 131,010 Say " Etapa do Pedido : "
				@ 130,060 MSCOMBOBOX cEtapa VAR _cEtapa ITEMS aEtapas  SIZE 058, 010 OF oDlg1 VALID _cEtapa $ ("09/20/15/21/10/12/23/24") COLORS 0, 16777215 PIXEL WHEN _cEtapa $ ("09/20/15/21/10/12/23/24")
			Endif
		Endif
	ENDIF
	@ 141,010 Say " Msg na NF: "
	@ 140,060 Get  _MsgNF     Size 300,205
	@ 151,010 Say " Redespacho: "
	@ 150,060 Get _cRedesp Size 030,050 F3 "SA4" Valid Vazio().or.ExistCpo("SA4") .and. GatTransp(_cRedesp,@_cDesRed)
	@ 150,095 Get _cDesRed Size 170,050 When .F.
	@ 161,010 Say " Obs.Internas: "
	@ 160,060 Get  _ObsInt     Size 300,205 When .F.


	@ 190,130 BMPBUTTON TYPE 1 ACTION (GRAVA_C5(),Close(Odlg1))
	@ 190,170 BMPBUTTON TYPE 2 ACTION Close(oDlg1)

	ACTIVATE DIALOG oDlg1 CENTERED

return


Static FUNCTION GRAVA_C5()
	Local cLog	:= ""

	// Compara os campos gravados com os campos em memória e concatena o Log
	If SC5->C5_PESOL <> _nPesoL
		cLog += "Alterado campo [C5_PESOL] DE: " + AllTrim(Str(SC5->C5_PESOL)) + " => PARA: " + AllTrim(Str(_nPesoL)) + " | " + CRLF
	EndIf

	If SC5->C5_PBRUTO <> _nPesoB
		cLog += "Alterado campo [C5_PBRUTO] DE: " + AllTrim(Str(SC5->C5_PBRUTO)) + " => PARA: " + AllTrim(Str(_nPesoB)) + " | " + CRLF
	EndIf

	If SC5->C5_VOLUME1 <> _nVolume
		cLog += "Alterado campo [C5_VOLUME1] DE: " + AllTrim(Str(SC5->C5_VOLUME1)) + " => PARA: " + AllTrim(Str(_nVolume)) + " | " + CRLF
	EndIf

	If AllTrim(SC5->C5_ESPECI1) <> AllTrim(_cEspeci1)
		cLog += "Alterado campo [C5_ESPECI1] DE: " + AllTrim(SC5->C5_ESPECI1) + " => PARA: " + AllTrim(_cEspeci1) + " | " + CRLF
	EndIf

	If AllTrim(SC5->C5_TRANSP) <> AllTrim(_cTransp)
		cLog += "Alterado campo [C5_TRANSP] DE: " + AllTrim(SC5->C5_TRANSP) + " => PARA: " + AllTrim(_cTransp) + " | " + CRLF
	EndIf

	If AllTrim(SC5->C5_MENNOTA) <> AllTrim(_MsgNF)
		cLog += "Alterado campo [C5_MENNOTA] DE: " + AllTrim(SC5->C5_MENNOTA) + " => PARA: " + AllTrim(_MsgNF) + " | " + CRLF
	EndIf

	If AllTrim(SC5->C5_MENPAD) <> AllTrim(_cMenPad)
		cLog += "Alterado campo [C5_MENPAD] DE: " + AllTrim(SC5->C5_MENPAD) + " => PARA: " + AllTrim(_cMenPad) + " | " + CRLF
	EndIf

	If AllTrim(SC5->C5_TIPLIB) <> AllTrim(ntplib)
		cLog += "Alterado campo [C5_TIPLIB] DE: " + AllTrim(SC5->C5_TIPLIB) + " => PARA: " + AllTrim(ntplib) + " | " + CRLF
	EndIf

	If AllTrim(SC5->C5_ZETAPA) <> AllTrim(_cEtapa)
		cLog += "Alterado campo [C5_ZETAPA] DE: " + AllTrim(SC5->C5_ZETAPA) + " => PARA: " + AllTrim(_cEtapa) + " | " + CRLF
	EndIf

	If AllTrim(SC5->C5_REDESP) <> AllTrim(_cRedesp)
		cLog += "Alterado campo [C5_REDESP] DE: " + AllTrim(SC5->C5_REDESP) + " => PARA: " + AllTrim(_cRedesp) + " | " + CRLF
	EndIf

	If AllTrim(SC5->C5_ZOBSINT) <> AllTrim(_ObsInt)
		cLog += "Alterado campo [C5_ZOBSINT] DE: " + AllTrim(SC5->C5_ZOBSINT) + " => PARA: " + AllTrim(_ObsInt) + " | " + CRLF
	EndIf

	// Se existir alguma alteração, grava log
	If !Empty(cLog)
		U_FtGeraLog( cFilAnt, "SC5", xFilial("SC5") + SC5->C5_NUM, "Log Pedido de Venda.", cLog )
	EndIf

	Reclock("SC5",.F.)
	SC5->C5_PESOL   := _nPesoL  //Val(_nPesoL)
	SC5->C5_PBRUTO  := _nPesoB  //Val(_nPesoB)
	SC5->C5_VOLUME1 := _nVolume //Val(_nVolume)
	SC5->C5_ESPECI1 := _cEspeci1
	SC5->C5_TRANSP  := _cTransp
	SC5->C5_MENNOTA := _MsgNF
	SC5->C5_MENPAD  := _cMenPad
	SC5->C5_TIPLIB  := ntplib
	SC5->C5_ZETAPA  := _cEtapa
	//SC5->C5_ZDEMBP  :=  _dEmb
	SC5->C5_REDESP  := _cRedesp
	//SC5->C5_MENPAD2 := _cMenPad2
	//SC5->C5_MENPAD3 := _cMenPad3
	SC5->C5_ZOBSINT  := _ObsInt

	
	// ----- DATAFRETE -----
	// listagem e pedido normal
	If SC5->C5_ZETAPA == "09" .and. Empty(SC5->C5_ZSTATDF)
		SC5->C5_ZSTATDF := "P"	// Envio pendente
	EndIf
	// -----
	MsUnlock()

	u_LogEtapa(_cEtapa,"altped",SC5->C5_NUM)

	//U_MTX05R04(_NUMPV, _cCodCli, _cLoja, _cTransp, _nVolume, _cNota)
Return

//Funï¿½ï¿½o apenas para gatilhar a descriï¿½ï¿½o do redespacho e transportadora
Static Function GatTransp(cCod, cDesc)
	cDesc := Posicione("SA4",1,xFilial("SA4")+cCod,"A4_NOME")
Return .T.

//Funï¿½ï¿½o apenas para gatilhar a descriï¿½ï¿½o da msg padrï¿½o
Static Function GatMenPad(cCod, cDesc)
	cDesc := Posicione("SM4",1,xFilial("SM4")+cCod,"M4_DESCR")
Return .T.
