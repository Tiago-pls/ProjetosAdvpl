#include "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOGZ40
Emite a relação dos LOG´s gerados conforme data e campo
@author  Marcio Biagini
date: 02/09/2022
/*/
//-------------------------------------------------------------------

User Function LOGZ40()

    Local   _oReport

    Private _cPerg := PADR("LOGZ40",Len(SX1->X1_GRUPO))
    Private _aSelFil    := {}

    PERGLog()

    if(!Pergunte(_cPerg))
        Return()
    Endif

    If MV_PAR04==1 .And. Len( _aSelFil ) <= 0 
	    _aSelFil := AdmGetFil()
	    If Len( _aSelFil ) <= 0
		    Return()
	    EndIf 
    EndIf

    _oReport := DefLOG()
    _oReport:PrintDialog()

Return()

/*
    Inicializa o relatório
*/
Static Function DefLog()

    Local _oReport
    Local _cArq    := "LOGZ40"
    Local _bReport := { |_oReport|	_oReport:SetTitle( _oReport:Title()) , ReportPrint( _oReport ) }
    Local _cTitulo := "Log de registros"
    Local _cDescri := "Este relatório emitirá relação com o LOG dos campos definidos."
    Local _oSection1
    Local _aOrd    := {}

    _oReport  := TReport():New( _cArq, _cTitulo, _cPerg, _bReport, _cDescri )
    _oSection1 := TRSection():New( _oReport, "LOG", {"Z40"}, _aOrd ) // "Entidade Contabil"
    TRCell():New( _oSection1, "FILIAL"	   , "Z40", "FILIAL",     PesqPict("Z40","Z40_FILIAL"),  TAMSX3("Z40_FILIAL")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New( _oSection1, "TABELA"	   , "Z40", "TABELA",     PesqPict("Z40","Z40_TABELA"),  TAMSX3("Z40_TABELA")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New( _oSection1, "CHAVE"	   , "Z40", "CHAVE",      PesqPict("Z40","Z40_CHAVE"),   TAMSX3("Z40_CHAVE")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New( _oSection1, "DATA"	   , "Z40", "DATA",       PesqPict("Z40","Z40_DATA"),    TAMSX3("Z40_DATA")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New( _oSection1, "HORA"	   , "Z40", "HORA",       PesqPict("Z40","Z40_HORA"),    TAMSX3("Z40_HORA")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New( _oSection1, "USUARIO"	   , "Z40", "USUARIO",    PesqPict("Z40","Z40_NOME"),    TAMSX3("Z40_NOME")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New( _oSection1, "DESCRICAO"  , "Z40", "DESCRICAO",  PesqPict("Z40","Z40_DESCRI"),  TAMSX3("Z40_DESCRI")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New( _oSection1, "COMPUTADOR" , "Z40", "COMPUTADOR", PesqPict("Z40","Z40_NMCOMP"),  TAMSX3("Z40_NMCOMP")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New( _oSection1, "IP"         , "Z40", "IP",         PesqPict("Z40","Z40_IPCOMP"),  TAMSX3("Z40_IPCOMP")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New( _oSection1, "ROTINA"     , "Z40", "ROTINA",     PesqPict("Z40","Z40_ROTINA"),  TAMSX3("Z40_ROTINA")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New( _oSection1, "LOG"        , "Z40", "LOG",        PesqPict("Z40","Z40_LOG"),     200 ,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(_oReport)

/*
    Rotina de impressão
*/

Static Function ReportPrint( _oReport )

    Local _oSection1  := _oReport:Section(1)
    Local _cTmpZ40Fi1 := ""
    Local _cQuery     := ""
    Local _nTotal    := 0

    _cQuery := "SELECT *, ISNULL(CAST(CAST(Z40_LOG AS VARBINARY(8000)) AS VARCHAR(8000)),'') LOG "
    _cQuery += "FROM "+RetSqlName("Z40")+" "
    _cQuery += "WHERE Z40_FILIAL "+ GetRngFil( _aSelFil ,"Z40", .T., @_cTmpZ40Fi1) +" "
    _cQuery += "AND Z40_DATA BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
    //Se for selecionado o campo para impressão
    if(!Empty(MV_PAR03))
        _cQuery += "AND ISNULL(CAST(CAST(Z40_LOG AS VARBINARY(8000)) AS VARCHAR(8000)),'') LIKE '%"+Alltrim(MV_PAR03)+"%' "
    Endif
    //Quando selecionado o tipo de relatório
    if(MV_PAR05<>3)
        if(MV_PAR05==1)
            _cQuery += "AND UPPER(Z40_DESCRI) LIKE '%PEDIDO%' "
        else
            _cQuery += "AND UPPER(Z40_DESCRI) LIKE '%ORÇAMENTO%' "
        Endif
    Endif
    _cQuery += "AND D_E_L_E_T_=' '"
    TcQuery _cQuery NEW ALIAS "TRBZ40"
    Dbselectarea("TRBZ40")
    TcSetField("TRBZ40","Z40_DATA","D",TAMSX3("Z40_DATA")[1])
	count to _ntotal
    Procregua(_nTotal)
 	_oReport:SetMeter( _nTotal )
	_oSection1:Init()
    TRBZ40->( DBGotop())
    While !TRBZ40->( EOF())
        _oReport:IncMeter()
        _oSection1:Cell("FILIAL"):SetValue(TRBZ40->Z40_FILIAL)
        _oSection1:Cell("TABELA"):SetValue(TRBZ40->Z40_TABELA)
        _oSection1:Cell("CHAVE"):SetValue(TRBZ40->Z40_CHAVE)
        _oSection1:Cell("DATA"):SetValue(TRBZ40->Z40_DATA)
        _oSection1:Cell("HORA"):SetValue(TRBZ40->Z40_HORA)
        _oSection1:Cell("USUARIO"):SetValue(TRBZ40->Z40_NOME)
        _oSection1:Cell("DESCRICAO"):SetValue(TRBZ40->Z40_DESCRI)
        _oSection1:Cell("COMPUTADOR"):SetValue(TRBZ40->Z40_NMCOMP)
        _oSection1:Cell("IP"):SetValue(TRBZ40->Z40_IPCOMP)
        _oSection1:Cell("ROTINA"):SetValue(TRBZ40->Z40_ROTINA)
        _oSection1:Cell("LOG"):SetValue(TRBZ40->LOG)
        _oSection1:Printline()
        TRBZ40->( Dbskip() )
    End
    _oSection1:Finish()
    TRBZ40->( Dbclosearea() )
Return()

/*
    Mantêm as perguntas do relatório
*/
Static Function PERGLog()

	SX1->(dbSetOrder(1))
	If !SX1->(dbSeek(_cPerg+"01"))
		RecLock("SX1",.T.)
			SX1->X1_GRUPO   := _cPerg
			SX1->X1_ORDEM   := '01'
    Else
        Reclock("SX1",.F.)
    Endif
        SX1->X1_PERGUNT := "Da Data?"
        SX1->X1_PERSPA  := "Da Data?"
        SX1->X1_PERENG  := "Da Data?"
        SX1->X1_VARIAVL := 'mv_ch1'
        SX1->X1_VAR01   := 'MV_PAR01'
        SX1->X1_GSC     := 'G'
        SX1->X1_TIPO    := 'D'
        SX1->X1_TAMANHO := 8
    SX1->(MsUnlock())

	If !SX1->(dbSeek(_cPerg+"02"))
		RecLock("SX1",.T.)
			SX1->X1_GRUPO   := _cPerg
			SX1->X1_ORDEM   := '02'
    Else
        Reclock("SX1",.F.)
    Endif
        SX1->X1_PERGUNT := "Até Data?"
        SX1->X1_PERSPA  := "Até Data?"
        SX1->X1_PERENG  := "Até Data?"
        SX1->X1_VARIAVL := 'mv_ch2'
        SX1->X1_VAR01   := 'MV_PAR02'
        SX1->X1_GSC     := 'G'
        SX1->X1_TIPO    := 'D'
        SX1->X1_TAMANHO := 8
    SX1->(MsUnlock())

	If !SX1->(dbSeek(_cPerg+"03"))
		RecLock("SX1",.T.)
			SX1->X1_GRUPO   := _cPerg
			SX1->X1_ORDEM   := '03'
    Else
        Reclock("SX1",.F.)
    Endif
        SX1->X1_PERGUNT := "Campo?"
        SX1->X1_PERSPA  := "Campo?"
        SX1->X1_PERENG  := "Campo?"
        SX1->X1_VARIAVL := 'mv_ch3'
        SX1->X1_VAR01   := 'MV_PAR03'
        SX1->X1_GSC     := 'G'
        SX1->X1_TIPO    := 'C'
        SX1->X1_TAMANHO := 12
    SX1->(MsUnlock())

	If !SX1->(dbSeek(_cPerg+"04"))
		RecLock("SX1",.T.)
		sx1->x1_grupo   := _cPerg
		sx1->x1_ordem   := '04'
	Else
		RecLock("SX1",.F.)
	EndIf
		sx1->x1_PERGUNT := 'Seleciona Filiais?'
        SX1->X1_PERSPA  := "Seleciona Filiais?"
        SX1->X1_PERENG  := "Seleciona Filiais?"
		SX1->X1_VARIAVL := 'mv_ch4'
		SX1->X1_TIPO    := 'N'
		SX1->X1_TAMANHO := 1
		SX1->X1_DECIMAL := 0
		SX1->X1_GSC     := 'C'
		SX1->X1_VAR01   := 'MV_PAR04'
		SX1->X1_DEF01   := 'Sim'
		SX1->X1_DEF02   := 'Não'
	MsUnlock("SX1")

	If !SX1->(dbSeek(_cPerg+"05"))
		RecLock("SX1",.T.)
		sx1->x1_grupo   := _cPerg
		sx1->x1_ordem   := '05'
	Else
		RecLock("SX1",.F.)
	EndIf
		sx1->x1_PERGUNT := "Tipo?"
        SX1->X1_PERSPA  := "Tipo?"
        SX1->X1_PERENG  := "Tipo?"
		SX1->X1_VARIAVL := 'mv_ch5'
		SX1->X1_TIPO    := 'N'
		SX1->X1_TAMANHO := 1
		SX1->X1_DECIMAL := 0
		SX1->X1_GSC     := 'C'
		SX1->X1_VAR01   := 'MV_PAR05'
		SX1->X1_DEF01   := 'Pedido'
		SX1->X1_DEF02   := 'Orçamento'
        SX1->X1_DEF03   := 'Ambos'
	MsUnlock("SX1")

Return()
