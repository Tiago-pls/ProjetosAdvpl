#INCLUDE "GPER1070.CH"
#INCLUDE "PROTHEUS.CH"

STATIC lItemClvl := SuperGetMv("MV_ITMCLVL", .F., "2") $ "13" // VERIFICA SE UTILIZA ITEM CONT�BIL E CLASSE DE VALOR
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � GPER070  � Autor � Emerson Rosa de Souza � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Impressao da Provisao de Ferias                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER070(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           ���
�������������������������������������������������������������������������Ĵ��
���PROGRAMADOR � DATA	�CHAMADO/REQ�  MOTIVO DA ALTERACAO                ���
�������������������������������������������������������������������������Ĵ��
���Mohanad Odeh�20/12/13�RQ1020     �UNIFICACAO DA FOLHA V12              ���
���            �        �M12RH01    �                                     ��� 
���Christiane V�17/04/14�M12RH01    �UNIFICACAO DA FOLHA V12              ���
���            �        �RQ1021     �                                     ��� 
���Allyson M   �24/07/14�TPZKBZ	    �Ajuste p/ ordenacao e quebra do      ���
���	       	   �  		�  	    	�relatorio por CC, Item e Classe.	  ���
���Renan Borges�14/01/15�TRHITA	    �Ajuste para imprimir os relat�rios de���
���			   �		�			�provis�o de f�rias e de 13� correta- ���
���			   �		�			�mente quando o pa�s for Brasil, inde-���
���			   �		�			�pendentemente do par�metro MV_CENT.  ���
���Victor A.   �02/05/16�TUKZ84	    �Ajuste para imprimir os dias de      ���
���			   �		�			�f�rias corretamente quando a pergunta���
���			   �		�			�Forma de Apresenta��o for igual a    ���
���			   �		�			�"Resumida" 						  ���
���Renan Borges�24/06/16�TVIRBJ	    �Ajuste para gerar relat�rio de provi-���
���			   �		�			�s�o de f�rias apresentando os dias de���
���			   �		�			�direitos nos campos de faltas e de to���
���			   �		�			�tais corretamente.                   ���
���Renan Borges�03/01/17�MRH-3280   �Ajuste para imprimir relatorio Mensal���
���            �        �           �com rateio com os valores na linha   ���
���            �        �           �certa.                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
user Function FTGPER070()
Local cString :="SRA"        	    // alias do arquivo principal (Base)
Local aAreaSRA:= SRA->( GetArea() )
Local aOrd	  := {STR0001,STR0002,STR0003,STR0004} //"Matricula"###"C.Custo"###"Nome"###"C.Custo+Nome"
Local cDesc1  := STR0005			//"Emiss�o da Provis�o de F�rias."
Local cDesc2  := STR0006			//"ser� impresso de acordo com os parametros solicitados"
Local cDesc3  := STR0007			//"pelo usu�rio."
Private aReturn  := {STR0008, 1,STR0009, 2, 2, 1, "",1 }		// "Zebrado"###"Administra��o"
Private nomeprog := "GPER070"
Private nLastKey := 0
Private cPerg	 := "GPR070"
Private cPict1  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 999,999,999.99",TM(999999999,14,MsDecimais(1)))  // "@E 99,999,999,999.99
Private cPict2  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 999999999.99"  ,TM(999999999,12,MsDecimais(1)))  // "@E 999999999.99
Private cPict3  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 9999999999.99" ,TM(9999999999,13,MsDecimais(1)))  // "@E 9999999999.99
Private cPict4  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 99999999999.99",TM(99999999999,14,MsDecimais(1)))  // "@E 99999999999.99
Private cPict5  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 9999999.99"  ,TM(9999999,10,MsDecimais(1)))  		// "@E 9999999.99
//VARIAVEIS UTILIZADAS NA FUNCAO IMPR
Private Titulo	 := STR0010			//"PROVIS�O DE FERIAS "
Private AT_PRG	 := "GPER070"
Private wCabec0  := 1
Private wCabec1  := STR0011 //"Data Base: "
Private CONTFL   :=1
Private LI		 :=0
Private nTamanho :="M"
Private lItemClVl:= SuperGetMv( "MV_ITMCLVL", .F., "2" ) $ "13"	// Determina se utiliza Item Contabil e Classe de Valores

Private aFldRot 	:= {'RA_NOME'}
Private aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Private lOfuscaNom 	:= .F. 
Private aFldOfusca	:= {}

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
		lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
ENDIF

TCInternal(5,"*OFF") //DESLIGA REFRESH NO LOCK DO TOP

If lItemClVl
	aAdd( aOrd, STR0076 ) // "C.Custo + Item + Classe"
EndIf

If Type("cFilAntBkp") <> "U"
	cFilAnt := cFilAntBkp
	SM0->( DbSeek(cEmpAnt+cFilAnt) )
EndIf

//VERIFICA AS PERGUNTAS SELECIONADAS
pergunte("GPR070",.F.)

//ENVIA CONTROLE PARA A FUNCAO SETPRINT
wnrel:="GPER070"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

//CARREGA VARIAVEIS PRIVATES COMUNS A GPEA070,GPER070 E GPEM070
GPEProvisao(wnRel,cString,Titulo,,2)

RestArea( aAreaSRA )

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � GP070imp � Autor � Emerson Rosa de Souza � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Provisao de Ferias                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GP070Imp(lEnd,WnRel,cString)                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
static Function GP070IMP(lEnd,WnRel,cString)
Local cMapa       := 0
Local nLaco       := nByte := 0
Local cMascCus    := GetMv( "MV_MASCCUS" ) // Mascara do p/Niveis do C.Custo
Local cAcessaSRA  := "{ || " + ChkRH("GPER070","SRA","2") + "}"
Local aAreaSRA    := SRA->(GetArea())
Local nQ
Local nCnt2
Local nCnt1
Local lCalcula    := .T.
Local lFerias     := .T.
Local l13oSal     := .F.
Local cFiltro070	:= aReturn[7]
Private aFerVenc     := Array(_Linhas,_Colunas)
Private aFerProp     := Array(_Linhas,_Colunas)
Private aTotVePr     := Array(_Linhas,_Colunas)
Private aCabProv     := {}
Private aVerba  	 := {}
Private aTransf      := {}
Private aTotCc1      := {}
Private aTotCc2      := {}
Private aTotCc3      := {}
Private aTotFil1     := {}
Private aTotFil2     := {}
Private aTotFil3     := {}
Private aTotEmp1     := {}
Private aTotEmp2     := {}
Private aTotEmp3     := {}
Private aInfo	     := {}
Private aCodFol  	 := {}
Private aNiveis      := {} // Niveis do Centro de Custo
Private lSalInc    	 := .F.
Private lTrataTrf    := .F.
Private lCalcPis	 := .F.
Private nTamCC		 := TamSX3("RA_CC")[1]
//CARREGA VARIAVEIS MV_PARXX PARA VARIAVEIS DO SISTEMA

//Faz o tratamento abaixo pois o relatorio de rateio mensal da provisao ja utiliza a ordem 5
If IsInCallStack("GP056FER") //Se foi chamado pelo relat�rio de provis�o rateada, altera o n�mero da ordem pois as ordens de centro de custo e centro de custos mais nome foram exclu�das.
	nOrdem		:= Iif( aReturn[8] == 2 , 3, If( aReturn[8] == 3, 5, aReturn[8] ) )
Else
	//Faz o tratamento abaixo pois o relatorio de rateio mensal da provisao ja utiliza a ordem 5
	nOrdem		:= Iif( IsInCallStack("GPER070") .And. aReturn[8] == 5 , 6, aReturn[8] )
EndIf
dDataRef   	:= mv_par01                             // Data de Referencia
cFilDe	   	:= mv_par02								//	Filial De
cFilAte    	:= mv_par03								//	Filial Ate
cCcDe	   	:= mv_par04								//	Centro de Custo De
cCcAte	   	:= mv_par05								//	Centro de Custo Ate
cMatDe	   	:= mv_par06								//	Matricula De
cMatAte     := mv_par07								//	Matricula Ate
cNomeDe     := mv_par08								//	Nome De
cNomeAte    := mv_par09								//	Nome Ate
nAnaSin     := mv_par10								//	Analitica / Sintetica
nGerRes     := mv_par11								//	Geral / Resumida
lImpNiv     := If(mv_par12 == 1,.T.,.F.)		    //  Imprimir Niveis C.Custo
cCateg	    := mv_par13								//	Categorias (Utilizada em fMonta_TPR)
Titulo  := STR0012+If(nAnaSin==1,STR0013,STR0014)+;		//"RELACAO DE PROVISAO DE FERIAS "###"ANALITICA"###"SINTETICA"
               " "+If(nGerRes == 1,STR0015,STR0016)		//"(GERAL)"###"(RESUMIDA)"

wCabec1 += Dtoc(dDataRef)
//aNiveis-ARMAZENA AS CHAVES DE QUEBRA
If lImpNiv
	aNiveis:= MontaMasc(cMascCus)
	//CRIAR OS ARRAYS COM OS NIVEIS DE QUEBRAS
    For nQ := 1 to Len(aNiveis)
        cQ := cValToChar(NQ)
        Private aTotCc1&cQ   := {} // Niveis dos Centro de Custo
        Private aTotCc2&cQ   := {}
		Private aTotCc3&cQ   := {}
        cCcAnt&cQ            := "" // Variaveis c.custo dos niveis de quebra
    Next nQ
Endif

//MONTA O ARQUIVO TEMPORARIO "TPR" A PARTIR DO SRA E SRE
Processa({ || fMontaTPR(nOrdem, dDataRef, @lSalInc, @lTrataTrf, @aTransf, , cAcessaSRA, cFiltro070)}, STR0010) //"PROVIS�O DE FERIAS "

dbSelectArea("SRA")
dbSetOrder(1)

dbSelectArea(cTBLXPROV)
dbGoTop()

//CARREGA REGUA DE PROCESSAMENTO
SetRegua( RecCount() )
cFilialAnt := Replicate("!", FWGETTAMFILIAL)
cCcAnt	   := "!!!!!!!!!"
While !Eof()
	IncRegua() 	//MOVIMENTA REGUA DE PROCESSAMENTO
	//GARANTE O POSICIONAMENTO DO FUNCIONARIO NO SRA
	dbSelectArea("SRA")
	dbSeek((cTBLXPROV)->PR_FILIAL + (cTBLXPROV)->PR_MAT)
	dbSelectArea(cTBLXPROV)
	If lEnd
		@Prow()+1,0 PSAY cCancel
   		Exit
    Endif
	If (cTBLXPROV)->PR_FILIAL # cFilialAnt //QUEBRA DE FILIAL       
		If !Fp_CodFol(@aCodFol,(cTBLXPROV)->PR_FILIAL) .Or.;
		   !fInfo(@aInfo,(cTBLXPROV)->PR_FILIAL)
			Exit
		Endif
		cFilialAnt := (cTBLXPROV)->PR_FILIAL
		//CARREGA OS IDENTIFICADORES DA PROVISAO
		fIdentProv(@aVerba,aCodFol,.T.,.F.)
		//VERIFICA A EXISTENCIA DOS IDENTIFICADORES DO PIS
		lCalcPis := (!Empty(aCodFol[416,1]))
	Endif
	//LIMPA O ARRAY COM O CONTEUDO ESPECIFICADO NO 2� PARAMETRO
	fLimpaArray(@aTotVePr, 0)
	//BUSCA INFORMACOES DE CABECALHO NO SRT
	If !fBusCabSRT(dDataRef,@aCabProv)
		fTestaTotal(_FerVenc)
		Loop
	EndIf

	//BUSCA OS LANCAMENTOS DE FERIAS VENCIDAS E PROPORCIONAIS
	fQryDetSRT(aVerba,aTransf,dDataRef,lTrataTrf,lCalcula,lFerias,l13oSal)

	//TOTALIZADOR -> VENCIDAS + PROPORCIONAIS
	For nCnt1 := 1 To _Linhas
		For nCnt2 := 1 To _Colunas
			aTotVePr[nCnt1,nCnt2] := aFerVenc[nCnt1,nCnt2]+aFerProp[nCnt1,nCnt2]
		Next nCnt2
	Next nCnt1
	//TOTALIZADORES DOS NIVEIS DE QUEBRA
	If nOrdem != 6 // Nao imprime niveis de c.custo na ordem de item + classe
		fTotNivCC(aFerVenc, aFerProp, aTotVePr) 							    // Niveis do Centro de Custo
	EndIf
	fAtuCont(@aToTCc1 , @aTotCc2 , @aTotCc3, aFerVenc, aFerProp, aTotVePr)  // Centro de Custo
	fAtuCont(@aTotFil1, @aTotFil2, @aTotFil3, aFerVenc, aFerProp, aTotVePr) // Filial
	fAtuCont(@aTotEmp1, @aTotEmp2, @aTotEmp3, aFerVenc, aFerProp, aTotVePr) // Empresa
	If nAnaSin == 1
		fImpFunFer() //IMPRIME O FUNCIONARIO
	EndIf	
	fTestaTotal(_FerVenc) //QUEBRAS E SKIPS
Enddo

//TERMINO DO RELATORIO
dbSelectArea("SRA")
Set Filter To
dbSetOrder(1)

If aReturn[5] == 1
	Set Printer To
	ourspool(wnrel)
EndIf

MS_FLUSH()

(cTBLXPROV)->(dbCloseArea())

//Elimina arquivo tempor�rio de provis�o
fDelTMPPRV()

//RETORNA AREA ORIGINAL DO CADASTRO DE FUNCIONARIOS
RestArea(aAreaSRA)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � GPER090  � Autor � Emerson Rosa de Souza � Data � 25.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Provisao de 13� Salario                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER090(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
static Function GPER090()
Local cString := "SRA"        			// Alias do arquivo principal (Base)
Local aAreaSRA:= SRA->( GetArea() )
Local aOrd	  := {STR0001,STR0002,STR0003,STR0004}   //"Matricula"###"C.Custo"###"Nome"###"C.Custo+Nome"
Local cDesc1  := STR0059				//"Emiss�o de Provis�o de 13o Salario."
Local cDesc2  := STR0006				//"Ser� impresso de acordo com os parametros solicitados pelo"
Local cDesc3  := STR0007				//"usu�rio."
Private cPict1  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 999,999,999.99",TM(999999999,14,MsDecimais(1)))  // "@E 99,999,999,999.99
Private cPict2  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 999999999.99"  ,TM(999999999,12,MsDecimais(1)))  // "@E 999999999.99
Private cPict3  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 9999999999.99" ,TM(9999999999,13,MsDecimais(1)))  // "@E 9999999999.99
Private cPict4  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 99999999999.99",TM(99999999999,14,MsDecimais(1)))  // "@E 99999999999.99
Private cPict5  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 9999999.99"  ,TM(9999999,10,MsDecimais(1)))  		// "@E 9999999.99
Private aReturn  := {STR0008,1,STR0009, 2, 2, 1, "",1 }		// "Zebrado"###"Administra��o"
Private NomeProg := "GPER090"
Private nLastKey := 0
Private cPerg	 := "GPR090"
//VARIAVEIS UTILIZADAS NA FUNCAO IMPR
Private Titulo	 := STR0058		//"PROVIS�O DE 13o SALARIO"
Private AT_PRG	 := "GPER090"
Private wCabec0  := 1
Private wCabec1  := STR0011	//"Data Base: "
Private CONTFL	 := 1
Private LI		 := 0
Private nTamanho := "M"
Private lItemClVl:= SuperGetMv( "MV_ITMCLVL", .F., "2" ) $ "13"	// Determina se utiliza Item Contabil e Classe de Valores

TCInternal(5,"*OFF") //DESLIGA REFRESH NO LOCK DO TOP

If lItemClVl
	aAdd( aOrd, STR0076 ) // "C.Custo + Item + Classe"
EndIf

If Type("cFilAntBkp") <> "U"
	cFilAnt := cFilAntBkp
	SM0->( DbSeek(cEmpAnt+cFilAnt) )
EndIf

Pergunte("GPR090",.F.) //VERIFICA AS PERGUNTAS SELECIONADAS

//ENVIA CONTROLE PARA A FUNCAO SETPRINT
wnrel := "GPER090"            //Nome Default do relatorio em Disco
wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

//CARREGA VARIAVEIS PRIVATES COMUNS A GPEA070,GPER070 E GPEM070
GPEProvisao(wnRel,cString,Titulo,,3)

RestArea( aAreaSRA )

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � GP090imp � Autor � Emerson Rosa de Souza � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Provisao de 13� Salario                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GP090Imp(lEnd,WnRel,cString)                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
static Function GP090IMP(lEnd,WnRel,cString)
Local cMapa      := 0
Local nLaco      := nByte := 0
Local cMascCus   := GetMv( "MV_MASCCUS" ) // Mascara do p/Niveis do C.Custo
Local cAcessaSRA := "{ || " + ChkRH("GPER090","SRA","2") + "}"
Local aAreaSRA   := SRA->(GetArea())
Local nQ
Local nCnt2
Local nCnt1
Local lCalcula    := .T.
Local lFerias     := .F.
Local l13oSal     := .T.
Local cFiltro070	:= aReturn[7]
Private a13Salar     := Array(_Linhas,_Colunas)
Private a14Salar     := Array(_Linhas,_Colunas)
Private aTot1314     := Array(_Linhas,_Colunas)
Private aCabProv     := {}
Private aVerba  	 := {}
Private aTransf      := {}
Private aTotCc1      := {}
Private aTotCc2      := {}
Private aTotCc3      := {}
Private aTotFil1     := {}
Private aTotFil2     := {}
Private aTotFil3     := {}
Private aTotEmp1     := {}
Private aTotEmp2     := {}
Private aTotEmp3     := {}
Private aInfo	     := {}
Private aCodFol  	 := {}
Private aNiveis      := {} // Niveis do Centro de Custo
Private lTrataTrf    := .F.
Private lSalInc    	 := .F.
Private lCalcPis	 := .F.
Private nTamCC		 := TamSX3("RA_CC")[1]
//CARREGANDO VARIAVEIS MV_PARXX PARA VARIAVEIS DO SISTEMA

If IsInCallStack("GP056DEC") //Se foi chamado pelo relat�rio de provis�o rateada, altera o n�mero da ordem pois as ordens de centro de custo e centro de custos mais nome foram exclu�das.
	//Faz o tratamento abaixo pois o relatorio de rateio mensal da provisao ja utiliza a ordem 5
	nOrdem		:= Iif( aReturn[8] == 2 , 3, If( aReturn[8] == 3, 5, aReturn[8] ) )
Else
	//Faz o tratamento abaixo pois o relatorio de rateio mensal da provisao ja utiliza a ordem 5
	nOrdem		:= Iif( IsInCallStack("GPER090") .And. aReturn[8] == 5 , 6, aReturn[8] )
EndIf
dDataRef   	:= mv_par01                             // Data de Referencia
cFilDe	   	:= mv_par02								//	Filial De
cFilAte    	:= mv_par03								//	Filial Ate
cCcDe	   	:= mv_par04								//	Centro de Custo De
cCcAte	   	:= mv_par05								//	Centro de Custo Ate
cMatDe	   	:= mv_par06								//	Matricula De
cMatAte     := mv_par07								//	Matricula Ate
cNomeDe     := mv_par08								//	Nome De
cNomeAte    := mv_par09								//	Nome Ate
nAnaSin     := mv_par10								//	Sintetica / Analitica
nGerRes     := mv_par11								//	Resumida  / Geral
lImpNiv     := If(mv_par12 == 1,.T.,.F.)		    //  Imprimir Niveis C.Custo
cCateg	    := mv_par13								//	Categorias (Utilizada em fMonta_TPR)

Titulo  := STR0060+If(nAnaSin==1,STR0013,STR0014)+;		//"RELACAO DE PROVISAO DE 13o SALARIO "###"ANALITICA"###"SINTETICA"
               " "+If(nGerRes == 1,STR0015,STR0016)		//"(GERAL)"###"(RESUMIDA)"
wCabec1 += Dtoc(dDataRef)

//aNiveis - ARMAZENA AS CHAVES DE QUEBRA
If lImpNiv
	aNiveis:= MontaMasc(cMascCus)
	//CRIAR OS ARRAYS COM OS NIVEIS DE QUEBRAS
	For nQ := 1 to Len(aNiveis)
        cQ := cValToChar(NQ)
        Private aTotCc1&cQ   := {} // Niveis dos Centro de Custo
        Private aTotCc2&cQ   := {}
	    Private aTotCc3&cQ   := {}
        cCcAnt&cQ            := "" // Variaveis c.custo dos niveis de quebra
    Next nQ
Endif

//MONTA O ARQUIVO TEMPORARIO "TPR" A PARTIR DO SRA E SRE
Processa({ || fMontaTPR(nOrdem, dDataRef, @lSalInc, @lTrataTrf, @aTransf, , cAcessaSRA, cFiltro070)}, STR0058) //"PROVIS�O DE 13� SALARIO"

dbSelectArea("SRA")
dbSetOrder(1)

dbSelectArea(cTBLXPROV)
dbGoTop()

//CARREGA REGUA DE PROCESSAMENTO
SetRegua(RecCount())
cFilialAnt := Replicate("!",FWGETTAMFILIAL)
cCcAnt	   := "!!!!!!!!!"
While !Eof()
	IncRegua() //MOVIMENTA REGUA DE PROCESSAMENTO
	//GARANTE O POSICIONAMENTO DO FUNCIONARIO NO SRA
	dbSelectArea("SRA")
	dbSeek((cTBLXPROV)->PR_FILIAL + (cTBLXPROV)->PR_MAT)
	dbSelectArea(cTBLXPROV)
	If lEnd
		@Prow()+1,0 PSAY cCancel
   		Exit
    Endif
	If (cTBLXPROV)->PR_FILIAL # cFilialAnt //QUEBRA DE FILIAL       
		If !Fp_CodFol(@aCodFol,(cTBLXPROV)->PR_FILIAL) .Or.;
		   !fInfo(@aInfo,(cTBLXPROV)->PR_FILIAL)
			Exit
		Endif
		cFilialAnt := (cTBLXPROV)->PR_FILIAL
		//CARREGA OS IDENTIFICADORES DA PROVISAO
		fIdentProv(@aVerba,aCodFol,.F.,.T.)
		//VERIFICA A EXISTENCIA DOS IDENTIFICADORES DO PIS
		lCalcPis := ( !Empty( aCodFol[416,1] ) )
	Endif
	//LIMPA O ARRAY COM O CONTEUDO ESPECIFICADO NO 2� PARAMETRO
	fLimpaArray(@aTot1314, 0)
	//BUSCA INFORMACOES DE CABECALHO NO SRT
	If !fBusCabSRT(dDataRef,@aCabProv)
		fTestaTotal(_13Salar)
		Loop
	EndIf
	//BUSCA OS LANCAMENTOS DE 13� E 14� SALARIO
	fQryDetSRT(aVerba,aTransf,dDataRef,lTrataTrf,lCalcula,lFerias,l13oSal)
	//TOTALIZADOR (13� + 14�)
	For nCnt1 := 1 To _Linhas
		For nCnt2 := 1 To _Colunas
			aTot1314[nCnt1,nCnt2] := a13Salar[nCnt1,nCnt2]+a14Salar[nCnt1,nCnt2]
		Next nCnt2
	Next nCnt1
	//TOTALIZADORES DOS NIVEIS DE QUEBRA
    If nOrdem != 6 // Nao imprime niveis de c.custo na ordem de item + classe
    	fTotNivCC(a13Salar, a14Salar, aTot1314) 								// Niveis do Centro de Custo
    EndIf
	fAtuCont(@aToTCc1 , @aTotCc2 , @aTotCc3, a13Salar, a14Salar, aTot1314)  // Centro de Custo
	fAtuCont(@aTotFil1, @aTotFil2, @aTotFil3, a13Salar, a14Salar, aTot1314) // Filial
	fAtuCont(@aTotEmp1, @aTotEmp2, @aTotEmp3, a13Salar, a14Salar, aTot1314) // Empresa
	//IMPRIME O FUNCIONARIO
	If nAnaSin == 1
		fImpFun13o()
	EndIf

	//QUEBRAS E SKIPS
	fTestaTotal(_13Salar)
Enddo

//TERMINO DO RELATORIO
dbSelectArea("SRA")
Set Filter To
dbSetOrder(1)

If aReturn[5] == 1
	Set Printer To
	ourspool(wnrel)
Endif
MS_FLUSH()

RestArea(aAreaSRA)

(cTBLXPROV)->(dbCloseArea())

//Elimina arquivo tempor�rio de provis�o
fDelTMPPRV()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � fAtuCont � Autor � Equipe R.H.           � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Atualiza Acumuladores                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fAtuCont(aTotal1,aTotal2,aTotal3,aValor1,aValor2,aValor3)  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fAtuCont(aTotal1,aTotal2,aTotal3,aValor1,aValor2,aValor3)
Local x
Local z

If Len(aTotal1) > 0
	For x:= 1 To _Linhas
		For z:= 1 To _Colunas
			aTotal1[x,z] += aValor1[x,z]
			aTotal2[x,z] += aValor2[x,z]
			aTotal3[x,z] += aValor3[x,z]
		Next z
	Next x
Else
	aTotal1 := Aclone(aValor1)
	aTotal2 := Aclone(aValor2)
	aTotal3 := Aclone(aValor3)
Endif
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fTestaTota� Autor � Equipe R.H.           � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Totalizadores                                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fTestaTotal(nTipProv)                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fTestaTotal(nTipProv)
Local cCusto
Local nQ

dbSelectArea(cTBLXPROV)
cFilialAnt := (cTBLXPROV)->PR_FILIAL
cCcAnt	   := If(nOrdem == 5, (cTBLXPROV)->PR_CCMVTO, (cTBLXPROV)->PR_CC )
If nOrdem == 6//"C.Custo + Item + Classe"
	cItAnt	   := (cTBLXPROV)->PR_ITEM
	cClAnt	   := (cTBLXPROV)->PR_CLVL
EndIf
dbSkip()

If lImpNiv .And. Len(aNiveis) > 0
    For nQ := 1 TO Len(aNiveis)
        cQ        := cValToChar(nQ)
        cCcAnt&cQ := Subs(cCcAnt,1,aNiveis[nQ])
    Next nQ
Endif

If Eof()
	cCusto := (cTBLXPROV)->PR_CC 
	fImpCc(nTipProv)
	fImpNiv(cCcAnt,.T.,nTipProv)
	fImpFil(nTipProv)
	fImpEmp(nTipProv)
Elseif cFilialAnt # (cTBLXPROV)->PR_FILIAL
	fImpCc(nTipProv)
    fImpNiv(cCcAnt,.T.,nTipProv)
	fImpFil(nTipProv)
ElseIf nOrdem == 6 .And. cCcAnt + cItAnt + cClAnt != (cTBLXPROV)->PR_CC + (cTBLXPROV)->PR_ITEM + (cTBLXPROV)->PR_CLVL//"C.Custo + Item + Classe"
	fImpCc(nTipProv)
ElseIf nOrdem == 5 .And. cCcAnt # (cTBLXPROV)->PR_CCMVTO
	cCusto := (cTBLXPROV)->PR_CCMVTO
	fImpCc(nTipProv)
    fImpNiv(cCusto,.F.,nTipProv)
Elseif nOrdem <> 5 .And. cCcAnt # (cTBLXPROV)->PR_CC
	cCusto := (cTBLXPROV)->PR_CC
	fImpCc(nTipProv)
    fImpNiv(cCusto,.F.,nTipProv)
Endif

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fImpFunFer� Autor � Equipe R.H.           � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Impressao dos Funcionarios                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fImpFunFer()                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fImpFunFer()
Local lRetu1   := .T.
Local lRetu2   := .T.             
Local cDemissa := If(MesAno((cTBLXPROV)->PR_DEMISSA) <= MesAno(dDataRef),(cTBLXPROV)->PR_DEMISSA,CTOD(""))
Local lRateio  := !Empty(cTpRtProv)

cSituacao := If(aCabProv[_MovProv] == _Cong_Fer .Or. aCabProv[_MovProv] == _Cong_F13,STR0048,If(aCabProv[_MovProv] == _Trfe_Sai,STR0047,"")) // CONGELADO##TRANSFERENCIA 
cSituacao := Left( Upper(cSituacao) + Space(27), 27)

If nTamCC <= 10
	cDET:=STR0017+(cTBLXPROV)->PR_FILIAL+STR0018+Subs(If(lRateio,(cTBLXPROV)->PR_CCMVTO,(cTBLXPROV)->PR_CC)+Space(10),1,10)+STR0019+Subs((cTBLXPROV)->PR_MAT,1,30) 	//"FILIAL: "###" CCTO: "###" MAT: "
	cDET+=STR0020+If(lOfuscaNom,Replicate('*',15),(cTBLXPROV)->PR_NOME)+STR0021+DtoC(aCabProv[_DBsProv])           									//" NOME: "###" DT.BASE FER: "
	cDET+=STR0022+AllTrim(TRANSFORM(aCabProv[_SalProv],cPict1))		 												//" SALARIO: "
Else
	cDET:=STR0017+(cTBLXPROV)->PR_FILIAL+STR0079+Subs(If(lRateio,(cTBLXPROV)->PR_CCMVTO,(cTBLXPROV)->PR_CC)+Space(nTamCC),1,nTamCC)+STR0019+Subs((cTBLXPROV)->PR_MAT,1,30) 	//"FILIAL: "###" CC: "###" MAT: "
	cDET+=STR0020+If(lOfuscaNom,Replicate('*',15),(cTBLXPROV)->PR_NOME)+STR0080+DtoC(aCabProv[_DBsProv])           									//" NOME: "###" DT.BASE: "
	cDET+=STR0081+AllTrim(TRANSFORM(aCabProv[_SalProv],cPict1))		 												//" SAL: "
EndIf
Impr(cDet,"C")
cDet:=Space(11)+cSituacao+STR0044+Dtoc((cTBLXPROV)->PR_ADMISSA)+SPACE(3)+STR0045+Dtoc(cDemissa)  //"DATA ADMISSAO: "###"DATA DEMISSAO: "
cDet+=Space(3)+STR0046+Transform(aCabProv[_DFerAnt],"999.9")	                          //"DIAS FERIAS ANTECIP.: "
Impr(cDet,"C")

lRetu1 := fImpComp(aFerVenc,1,.T.,_FerVenc)
lRetu2 := fImpComp(aFerProp,2,.T.,_FerVenc)

If lRetu1 .And. lRetu2
	fImpComp(aTotVePr,3,.T.,_FerVenc)
Endif

cDet := Repl("-",132)
Impr(cDet,"C")
Impr("","C")

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fImpFun13o� Autor � Equipe R.H.           � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Impressao dos Funcionarios                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fImpFun13o()                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fImpFun13o()
Local lRetu1   := .T.
Local lRetu2   := .T.
Local cDemissa := If(MesAno((cTBLXPROV)->PR_DEMISSA) <= MesAno(dDataRef),(cTBLXPROV)->PR_DEMISSA,CTOD(""))
Local lRateio  := !Empty(cTpRtProv)

cSituacao := If(aCabProv[_MovProv] == _Cong_13s .Or. aCabProv[_MovProv] == _Cong_F13,STR0048,If(aCabProv[_MovProv] == _Trfe_Sai,STR0047,"")) // CONGELADO##TRANSFERENCIA 
cSituacao := Left( Upper(cSituacao) + Space(27), 27)

cDET := STR0023+(cTBLXPROV)->PR_FILIAL+STR0024+Subs(If(lRateio,(cTBLXPROV)->PR_CCMVTO,(cTBLXPROV)->PR_CC)+Space(nTamCC),1,nTamCC)+STR0019+Subs((cTBLXPROV)->PR_MAT,1,30)	//"FILIAL: "###" CCTO: "###" MAT: "
cDET += STR0020+If(lOfuscaNom,Replicate('*',15),(cTBLXPROV)->PR_NOME)								//" NOME: "
cDET += STR0022+AllTrim(TRANSFORM(aCabProv[_SalProv],cPict1))					    //" SALARIO: "
Impr(cDet,"C")

cDet := Space(11)+cSituacao+STR0044+DtoC((cTBLXPROV)->PR_ADMISSA)+Space(3)+STR0045+Dtoc(cDemissa)  //" DT.ADMISSAO: "###" DATA DEMISSAO: "
Impr(cDet,"C")

lRetu1 := fImpComp(a13Salar,1,.T.,_13Salar)
lRetu2 := fImpComp(a14Salar,2,.T.,_13Salar)

If lRetu1 .And. lRetu2
	fImpComp(aTot1314,3,.T.,_13Salar)
Endif

cDet := Repl("-",132)
Impr(cDet,"C")
Impr("","C")

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � fImpCc   � Autor � Equipe R.H.           � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Totalizador do Centro de Custo                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fImpCc(nTipProv)                                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fImpCc(nTipProv)
Local cDescCl:= ""
Local cDescIt:= ""
Local lRetu1 := .T.
Local lRetu2 := .T.

If Len(aTotCc1) == 0 .Or. (nOrdem != 2 .And. nOrdem != 4 .And. nOrdem != 5 .And. nOrdem != 6)
	Return Nil
Endif

cDET:=STR0023+cFilialAnt+STR0024+cCcAnt+" - "+DescCc(cCcAnt,cFilialAnt)		//"FILIAL: "###" CCTO: "
If nOrdem == 6//"C.Custo + Item + Classe"
	cDescIt := AllTrim( fDesc( "CTD", cItAnt, "CTD_DESC01", Nil, cFilialAnt ) )
	cDescCl := AllTrim( fDesc( "CTH", cClAnt, "CTH_DESC01", Nil, cFilialAnt ) )
	cDET += " - " + STR0077 + AllTrim(cItAnt) + " - " + cDescIt + " - " + STR0078 + Alltrim(cClAnt) + " - " + cDescCl//"ITEM: "##"CLASSE: "	
EndIf
Impr(cDet,"C")
Impr("","C")

lRetu1 := fImpComp(aTotCc1,1,.F.,nTipProv)
lRetu2 := fImpComp(aTotCc2,2,.F.,nTipProv)
If lRetu1 .And. lRetu2
	fImpComp(aTotCc3,3,.F.,nTipProv)
Endif

aTotCc1 := {}
aTotCc2 := {}
aTotCc3 := {}

cDet := Repl("=",132)
Impr(cDet,"C")
Impr("","C")

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � fImpNiv  � Autor � Equipe R.H.           � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Totalizador dos niveis                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fImpNiv(cCusto,lGeral,nTipProv)                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fImpNiv(cCusto,lGeral,nTipProv)
Local lRetu1 := .T.
Local lRetu2 := .T.
Local nQ

If nOrdem # 2 .And. nOrdem # 4
	Return Nil
Endif

If lImpNiv .And. Len(aNiveis) > 0
	For nQ := Len(aNiveis) to 1 Step -1
		cQ := cValToChar(nQ)
	    //VERIFICA SE HOUVE QUEBRA DOS NIVEIS DE C.CUSTO
    	If Subs(cCusto,1,aNiveis[nQ]) # cCcAnt&cQ .Or. lGeral
			If (Len(aTotCc1&cQ) # 0 .Or. Len(aTotCc2&cQ) # 0 .Or. Len(aTotCc1&cQ) # 0)
				If cCcAnt&cQ # Nil
				   cDET:=STR0023+cFilialAnt+STR0024+cCcAnt&cQ+" - "+DescCc(cCcAnt&cQ,cFilialAnt)	//"FILIAL: "###" CCTO: "
				Else
				   cDET:=STR0023+cFilialAnt+STR0024+cCcAnt+" - "+DescCc(cCcAnt,cFilialAnt)		//"FILIAL: "###" CCTO: "
				EndIf
				Impr(cDet,"C")
				Impr("","C")
				lRetu1 := fImpComp(aTotCc1&cQ,1,.F.,nTipProv)
				lRetu2 := fImpComp(aTotCc2&cQ,2,.F.,nTipProv)
				If lRetu1 .And. lRetu2
					fImpComp(aTotCc3&cQ,3,.F.,nTipProv)
				Endif
                aTotCc1&cQ   := {} //Zera
	            aTotCc2&cQ   := {}
			    aTotCc3&cQ   := {}
				cDet := Repl("=",132)
				Impr(cDet,"C")
				Impr("","C")
			Endif
		Endif
	Next nQ
Endif

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � fImpFil  � Autor � Equipe R.H.           � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Totalizador da Filial                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fImpFil(nTipProv)                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fImpFil(nTipProv)
Local lRetu1 := .T.
Local lRetu2 := .T.
Local cDescFil

If Len(aTotFil1) == 0
	Return Nil
Endif

cDescFil := aInfo[1] + Space(25)
cDET:=STR0023+cFilialAnt+" - "+cDescFil		//"FILIAL: "
Impr(cDet,"C")
Impr("","C")

lRetu1 := fImpComp(aTotFil1,1,.F.,nTipProv)
lRetu2 := fImpComp(aTotFil2,2,.F.,nTipProv)
If lRetu1 .And. lRetu2
	fImpComp(aTotFil3,3,.F.,nTipProv)
Endif

aTotFil1 :={}
aTotFil2 :={}
aTotFil3 :={}

cDet := Repl("#",132)
Impr(cDet,"C")
Impr("","C")
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � fImpEmp  � Autor � Equipe R.H.           � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Totalizador da Empresa                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fImpEmp(nTipProv)                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fImpEmp(nTipProv)
Local lRetu1 := .T.
Local lRetu2 := .T.
If Len(aTotEmp1) == 0
	Retu Nil
Endif

cDET:=STR0101+FWGrpName()		//"Grupo de Empresas : "
Impr(cDet,"C")
Impr("","C")

lRetu1 := fImpComp(aTotEmp1,1,.F.,nTipProv)
lRetu2 := fImpComp(aTotEmp2,2,.F.,nTipProv)
If lRetu1 .And. lRetu2
	fImpComp(aTotEmp3,3,.F.,nTipProv)
Endif

aTotEmp1 :={}
aTotEmp2 :={}
aTotEmp3 :={}
Impr("","F")

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � fImpComp � Autor � Equipe R.H.           � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Complemento da Impressao                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fImpComp(aPosicao,nNroArray,lImpFunc,nTipProv)             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fImpComp(aPosicao,nNroArray,lImpFunc,nTipProv)
Local lRet := .F.

If nTipProv == _FerVenc
	lRet := fCompFer(aPosicao,nNroArray,lImpFunc)
ElseIf nTipProv == _13Salar
	lRet := fComp13o(aPosicao,nNroArray,lImpFunc)
ElseIf nTipProv == _PlrSalar
	lRet := fCompPlr(aPosicao,nNroArray,lImpFunc)
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � fCompFer � Autor � Equipe R.H.           � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Complemento da Impressao                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fCompFer(aPosicao,nLugar,lImpFunc)                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fCompFer(aPosicao,nNroArray,lImpFunc)
//aPosicao  = ARRAY CONTENDO O QUE SERA IMPRESSO     (Venc/Prop/Total)    
//nNroArray = POSICAO FISICA DOS GRUPOS DE IMPRESSAO (1-Venc,2-Prop,3-Tot)
Local cCab1,cCab2,Sub_C,nDiasImp
Local nValPro,nValAdi,nVal1Te,nValIns,nValFgt,nValPis,nTotFer,nTotEnc,nTotGer,nValSalV
Local nPosImp  := 0
Local lImpTxBx := .T.
Local nTotImp  := _Linhas - 1
Local bChkVal  := { |nArg| ( aPosicao[nArg,_Prov] + aPosicao[nArg,_Adic] + aPosicao[nArg,_1Ter] + aPosicao[nArg,_INSS] + aPosicao[nArg,_FGTS] == 0 ) }

lImpFunc := If(lImpFunc == Nil,.F.,lImpFunc) // SE VERDADEIRO, SERA IMPRESSO O FUNCIONARIO

//NAO IMPRIME NENHUMA DAS COLUNAS SE O VALOR FOR ZERO
If Eval(bChkVal,_Anter) .And. Eval(bChkVal,_NoMes).And. Eval(bChkVal,_Atual) .And. Eval(bChkVal,_BxTot)
	If nGerRes == 1
		Return .F.
	EndIf
Endif

If nGerRes == 1 .Or. (nGerRes == 2 .And. nNroArray == 1)
	Sub_C := If(nGerRes==2,Space(8),If(nNroArray==1,STR0026,If(nNroArray==2,STR0027,STR0028)))	//"VENCIDAS"###"A VENCER"###"TOTAL"
	   cDET  := Sub_C+SPACE(20)+STR0029+SPACE(3)+STR0030		//"VALOR"###"ADICIONAIS  1/3 CONSTIT.   TOTAL FERIAS"
	   If lCalcPis
		   cDET  += SPACE(5)+STR0031+SPACE(5)+STR0072 //"I.N.S.S. "###"F.G.T.S.        P.I.S.    TOTAL GERAL"
	   Else
		   cDET  += SPACE(5)+STR0031+SPACE(5)+STR0032 //"I.N.S.S. "###"F.G.T.S.  TOT.ENCARGOS    TOTAL GERAL"
	   EndIf
	IMPR(cDET,"C")
Endif

For nPosImp := 1 To nTotImp
	If nGerRes == 2
		cCab1:=If(nNroArray == 1,STR0033,If(nNroArray == 2,STR0034,STR0035))		//"Venc. "###"Prop. "###"Total "
		cCab2:=Space(6)
	Else    
		cCab1:= If(nPosImp == _Anter,STR0036,If(nPosImp == _Corre, Space(6),;
			     If(nPosImp == _NoMes,STR0037,If(nPosImp == _Atual,STR0038,If(nPosImp == _TrfEnt .Or. nPosImp == _TrfSai,STR0073,STR0049)))))	//"D.Fer "###"Faltas"###"Saldo "###"Val. Baixa"###"Transf.Saldo"
		cCab2:= If(nPosImp == _Anter,STR0039,If(nPosImp == _Corre,STR0040,;
				 If(nPosImp == _NoMes,STR0041,If(nPosImp == _Atual,STR0043,;
				 If(nPosImp == _BxTrf,STR0050,If(nPosImp == _BxFer,STR0051,;
				 If(nPosImp == _BxRes, STR0052,If(nPosImp == _TrfEnt,STR0074,If(nPosImp == _TrfSai,STR0075,""))))))))) //"Anter "###"Correc"###"No Mes"###"Atual "###"Transf"###"Ferias"###"Rescis"###"Entr."###"Saida"
	EndIf
	//NAO IMPRIME CORRECAO OU BAIXA SE O VALOR FOR ZERO
	If (nPosImp == _Corre .Or. nPosImp > _Atual) .And. Eval(bChkVal,nPosImp)
		Loop
	Endif
	
	If nPosImp == _Anter .Or. nPosImp == _NoMes .Or. nPosImp == _Corre .Or. nPosImp == _Atual
		If nPosImp == _Anter
			nDiasImp := aPosicao[_Atual,_Dias]+aPosicao[_NoMes,_Dias]
		Else
			nDiasImp := aPosicao[nPosImp,_Dias]
		EndIf
	   	cDet:= cCab1+" "+If(lImpFunc,Transform(nDiasImp,"999.9"),Space(05))+" "+cCab2+"  "
	Else
		If lImpTxBx .Or. nPosImp == _TrfEnt
	        cDet:= cCab1+"  "+cCab2+"  "
	     	lImpTxBx := .F.
	    Else
   	     	cDet:= Space(13)+cCab2+"  "
	    EndIf 	
	EndIf           	
	
	nValPro := aPosicao[nPosImp,_Prov]
	nValAdi := aPosicao[nPosImp,_Adic]
	nVal1Te := aPosicao[nPosImp,_1Ter]
    nTotFer := aPosicao[nPosImp,_Prov]+aPosicao[nPosImp,_Adic]+aPosicao[nPosImp,_1Ter]
    nValIns := aPosicao[nPosImp,_INSS]
    nValFgt := aPosicao[nPosImp,_FGTS]
    nValPis := aPosicao[nPosImp,_PIS]
    nValSalV:= aPosicao[nPosImp,_SalV]
	nTotEnc := aPosicao[nPosImp,_INSS]+aPosicao[nPosImp,_FGTS]
    nTotEnc := If(lCalcPis, nValPis, nTotEnc)
    nTotGer := nTotFer + nValIns + nValFgt + If(lCalcPis,nValPis,0)
	    
	cDet +=     TRANSFORM(nValPro,cPict2)
	cDet += " "+TRANSFORM(nValAdi,cPict2)  
	cDet += " "+TRANSFORM(nVal1Te,cPict3)
	cDet += " "+TRANSFORM(nTotFer,cPict4)
    cDet += " "+TRANSFORM(nValIns,cPict2)
    cDet += " "+TRANSFORM(nValFgt,cPict3) 
    cDet += " "+TRANSFORM(nTotEnc,cPict4)
	cDet += " "+TRANSFORM(nTotGer,cPict4)

	If nGerRes == 1 .Or. (nGerRes == 2 .And. nPosImp == _NoMes)
		Impr(cDet,"C")
	EndIf
Next

//MONTAGEM E IMPRESSAO DO VALOR QUE SERA CONTABILIZADO
If nNroArray == 3 .And. !lImpFunc
	If !Eval(bChkVal,_BxTot)
		nValPro := aPosicao[_NoMes,_Prov]-aPosicao[_BxTot,_Prov]
		nValAdi := aPosicao[_NoMes,_Adic]-aPosicao[_BxTot,_Adic]
		nVal1Te := aPosicao[_NoMes,_1Ter]-aPosicao[_BxTot,_1Ter]
   		nValSalV:= aPosicao[_NoMes,_SalV]-aPosicao[_BxTot,_Salv]
		nTotFer := nValPro + nValAdi + nVal1Te
		nValIns := aPosicao[_NoMes,_INSS]-aPosicao[_BxTot,_INSS]
		nValFgt := aPosicao[_NoMes,_FGTS]-aPosicao[_BxTot,_FGTS]
		nValPis := aPosicao[_NoMes,_PIS] -aPosicao[_BxTot,_PIS]
	    nTotEnc := nValIns + nValFgt
   	    nTotEnc := If(lCalcPis, nValPis, nTotEnc)
	    nTotGer := nTotFer + nValIns + nValFgt + If(lCalcPis,nValPis,0)
		cDet := STR0053+"         "  // NO MES-BAIXA
		cDet +=     TRANSFORM(nValPro,cPict2)
		cDet += " "+TRANSFORM(nValAdi,cPict2)
		cDet += " "+TRANSFORM(nVal1Te,cPict3)
		cDet += " "+TRANSFORM(nTotFer,cPict4)
	    cDet += " "+TRANSFORM(nValIns,cPict2)
	    cDet += " "+TRANSFORM(nValFgt,cPict3)
	    cDet += " "+TRANSFORM(nTotEnc,cPict4)
		cDet += " "+TRANSFORM(nTotGer,cPict4)
		Impr(cDet,"C")
	EndIf
EndIf
Li := If(nGerRes == 1 ,Li++,Li)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � fComp13o � Autor � Equipe R.H.           � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Complemento da Impressao                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fComp13o(aPosicao,nLugar,lImpFunc)                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fComp13o(aPosicao,nNroArray,lImpFunc)
//aPosicao  = ARRAY CONTENDO O QUE SERA IMPRESSO     (13�/14�/Total)
//nNroArray = POSICAO FISICA DOS GRUPOS DE IMPRESSAO (1-13o,2-14o,3-Tot)
Local cCab1,cCab2,cMes,Sub_C
Local nValPro,nValAdi,nVal1Pa,nValIns,nValFgt,nTotFer,nTotEnc,nTotGer
Local nPosImp  := 0
Local lImpTxBx := .T.
Local nTotImp  := _Linhas - 1
Local cTexTot  := If(nNroArray == 1, STR0062, If(nNroArray == 2, STR0063, STR0064)) //"ADICIONAIS    1o PARCELA      TOTAL 13o"##"ADICIONAIS    1o PARCELA      TOTAL 14o"##"ADICIONAIS    1o PARCELA      TOT 13/14"
Local bChkVal  := { |nArg| ( aPosicao[nArg,_Prov] + aPosicao[nArg,_Adic] + aPosicao[nArg,_1Par] + aPosicao[nArg,_INSS] + aPosicao[nArg,_FGTS] == 0 ) }

lImpFunc := If(lImpFunc == Nil,.F.,lImpFunc) // SE VERDADEIRO, SERA IMPRESSO O FUNCIONARIO

//NAO IMPRIME NENHUMA DAS COLUNAS SE O VALOR FOR ZERO
If Eval(bChkVal,_Anter) .And. Eval(bChkVal,_NoMes).And. Eval(bChkVal,_Atual) .And. Eval(bChkVal,_BxTot)
	If nGerRes == 1
		Return .F.
	EndIf
Endif

If nGerRes == 1 .Or. (nGerRes == 2 .And. nNroArray == 1)
	cDET:=SPACE(28)+STR0029+SPACE(3)+cTexTot	//"VALOR"###"ADICIONAIS    1o PARCELA      TOTAL 13o"
	If lCalcPis
		cDET+=SPACE(05)+STR0031+SPACE(5)+STR0072 //"I.N.S.S. "###"F.G.T.S.        P.I.S.    TOTAL GERAL"
	Else
		cDET+=SPACE(05)+STR0031+SPACE(5)+STR0065 //"I.N.S.S. "###"F.G.T.S.  TOT.ENCARGOS    TOTAL GERAL"
	EndIf
	IMPR(cDET,"C")
Endif

Sub_C := If(nGerRes==2,Space(5),If(nNroArray==1,If(lImpFunc,STR0061,STR0066),If(nNroArray==2,STR0067,Left(STR0028,5)))) //"MESES"##" 14 �"##"TOTAL"

For nPosImp := 1 To nTotImp
	If nGerRes == 2
		cCab1 := Space(5)
		cCab2 := Space(6)
	Else
		cCab1 := If(nPosImp == _NoMes, Sub_C, If(nPosImp == _TrfEnt .Or. nPosImp == _TrfSai,STR0073,If(nPosImp > _Atual,STR0049,Space(5)))) //"MESES"###"Val. Baixa"###"Transf.Saldo"
		cCab2 := If(nPosImp == _Anter,STR0039,If(nPosImp == _Corre,STR0040 ,;
				  If(nPosImp == _NoMes,STR0041,If(nPosImp == _Atual,STR0043,;
				  If(nPosImp == _BxTrf,STR0050,If(nPosImp == _BxRes,STR0052,;
				  If(nPosImp == _Bx13O .And. nNroArray <> 2 .And. nNroArray <> 3,STR0068,If(nPosImp == _TrfEnt,STR0074,If(nPosImp == _TrfSai,STR0075,If(nNroArray == 3, space(6), STR0067+" "))))))))))	//"Anter "###"Correc"###"No Mes"###"Atual "###"Transf"###"Rescis"###"13.Sal"###"Entr."###"Saida"
	EndIf
	//NAO IMPRIME CORRECAO OU BAIXA SE O VALOR FOR ZERO
	If (nPosImp == _Corre .Or. nPosImp > _Atual) .And. Eval(bChkVal,nPosImp)
		Loop
	Endif
	cMes := If(lImpFunc .And. nPosImp == _NoMes,Transform(aPosicao[_NoMes,_Avos],"99"),Space(02))
	cMes := If (Val(cMes) > 0 , cMes ,"  ")
	If nPosImp == _Anter .Or. nPosImp == _NoMes .Or. nPosImp == _Corre .Or. nPosImp == _Atual
		cDet := cCab1+" "+cMes+Space(5)+cCab2+"  "
	Else
		If lImpTxBx .Or. nPosImp == _TrfEnt
	        cDet:= cCab1+"  "+cCab2+"  "
	     	lImpTxBx := .F.
	    Else
   	     	cDet:= Space(13)+cCab2+"  "
	    EndIf 	
	EndIf

	nValPro := aPosicao[nPosImp,_Prov]
	nValAdi := aPosicao[nPosImp,_Adic]
	nVal1Pa := aPosicao[nPosImp,_1Par]
    nTotFer := aPosicao[nPosImp,_Prov]+aPosicao[nPosImp,_Adic]-aPosicao[nPosImp,_1Par]
    nValIns := aPosicao[nPosImp,_INSS]
    nValFgt := aPosicao[nPosImp,_FGTS]
    nValPis := aPosicao[nPosImp,_PIS]
    nTotEnc := aPosicao[nPosImp,_INSS]+aPosicao[nPosImp,_FGTS]
	nTotEnc := If(lCalcPis, nValPis, nTotEnc)
    nTotGer := nTotFer + nValIns + nValFgt + If(lCalcPis,nValPis,0)

	cDet +=     TRANSFORM(nValPro,cPict2)
	cDet += " "+TRANSFORM(nValAdi,cPict2)
	cDet += " "+TRANSFORM(nVal1Pa,cPict3)
	cDet += " "+TRANSFORM(nTotFer,cPict4)
	cDet += " "+TRANSFORM(nValIns,cPict2)
	cDet += " "+TRANSFORM(nValFgt,cPict3)
	cDet += " "+TRANSFORM(nTotEnc,cPict4)
	cDet += " "+TRANSFORM(nTotGer,cPict4)

	If nGerRes == 1 .Or. (nGerRes == 2 .And. nPosImp == _NoMes)
		Impr(cDet,"C")
	EndIf
Next

//MONTAGEM E IMPRESSAO DO VALOR QUE SERA CONTABILIZADO
If nNroArray == 3 .And. !lImpFunc
	If !Eval(bChkVal,_BxTot)
		nValPro := aPosicao[_NoMes,_Prov]-aPosicao[_BxTot,_Prov]
		nValAdi := aPosicao[_NoMes,_Adic]-aPosicao[_BxTot,_Adic]
		nVal1Te := aPosicao[_NoMes,_1Par]-aPosicao[_BxTot,_1Par]
		nTotFer := nValPro + nValAdi + nVal1Pa
		nValIns := aPosicao[_NoMes,_INSS]-aPosicao[_BxTot,_INSS]
		nValFgt := aPosicao[_NoMes,_FGTS]-aPosicao[_BxTot,_FGTS]
		nValPis := aPosicao[_NoMes,_PIS] -aPosicao[_BxTot,_PIS]
		nTotEnc := nValIns + nValFgt
		nTotEnc := If(lCalcPis, nValPis, nTotEnc)
	    nTotGer := nTotFer + nValIns + nValFgt + If(lCalcPis,nValPis,0)
		cDet := STR0053+"         "  // NO MES-BAIXA
		cDet +=     TRANSFORM(nValPro,cPict2)
		cDet += " "+TRANSFORM(nValAdi,cPict2)
		cDet += " "+TRANSFORM(nVal1Pa,cPict3)
		cDet += " "+TRANSFORM(nTotFer,cPict4)
		cDet += " "+TRANSFORM(nValIns,cPict2)
		cDet += " "+TRANSFORM(nValFgt,cPict3)
		cDet += " "+TRANSFORM(nTotEnc,cPict4)
		cDet += " "+TRANSFORM(nTotGer,cPict4)
		Impr(cDet,"C")
	EndIf
EndIf
Li := If(nGerRes == 1 ,Li++,Li)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fTotNivCC � Autor � Equipe R.H.           � Data � 14.11.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Totaliza os niveis de Centro de Custo para Ferias e 13o Sal���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fTotNivCC(aNivCC1, aNivCC2, aNivCC3, aArray1, aArray2...)  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fTotNivCC(aArray1, aArray2, aTot1e2)
Local aTotTmp1,aTotTmp2,aTotTmp3, nQ

If lImpNiv .And. Len(aNiveis) > 0
    For nQ :=1 To Len(aNiveis)
        cQ := cValToChar(nQ)
        aTotTmp1 := {}; aTotTmp2 := {}; aTotTmp3 := {}
        aTotTmp1 := Aclone(aTotCc1&cQ)
        aTotTmp2 := Aclone(aTotCc2&cQ)
        aTotTmp3 := Aclone(aTotCc3&cQ)
		fAtuCont(@aTotTmp1, @aTotTmp2, @aTotTmp3, aArray1, aArray2, aTot1e2)
		aTotCc1&cQ := Aclone(aTotTmp1)
		aTotCc2&cQ := Aclone(aTotTmp2)
		aTotCc3&cQ := Aclone(aTotTmp3)
    Next nQ
Endif

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � GPER095	� Autor � Emerson Rosa de Souza � Data � 25.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Provisao de PLR Salario									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � GPER095(void)											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso 	 � Generico 										   		  ���
�������������������������������������������������������������������������Ĵ��
��� 		ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao					  ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
static Function GPER095()
//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais (Basicas)							 �
//����������������������������������������������������������������
Local cString := "SRA"        			// Alias do arquivo principal (Base)
Local aAreaSRA:= SRA->( GetArea() )
Local aOrd	  := {STR0001,STR0002,STR0003,STR0004}   //"Matricula"###"C.Custo"###"Nome"###"C.Custo+Nome"
Local cDesc1  := STR0059				//"Emiss�o de Provis�o de 13o Salario."
Local cDesc2  := STR0006				//"Ser� impresso de acordo com os parametros solicitados pelo"
Local cDesc3  := STR0007				//"usu�rio."

Private cPict1  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 999,999,999.99",TM(999999999,14,MsDecimais(1)))  // "@E 99,999,999,999.99
Private cPict2  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 999999999.99"  ,TM(999999999,12,MsDecimais(1)))  // "@E 999999999.99
Private cPict3  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 9999999999.99" ,TM(9999999999,13,MsDecimais(1)))  // "@E 9999999999.99
Private cPict4  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 99999999999.99",TM(99999999999,14,MsDecimais(1)))  // "@E 99999999999.99
Private cPict5  := If (MsDecimais(1)== 2 .OR. cPaisLoc == "BRA","@E 9999999.99"  ,TM(9999999,10,MsDecimais(1)))  		// "@E 9999999.99

//��������������������������������������������������������������Ŀ
//� Define Variaveis Private(Basicas)							 �
//����������������������������������������������������������������
Private aReturn  := {STR0008,1,STR0009, 2, 2, 1, "",1 }		// "Zebrado"###"Administra��o"
Private NomeProg := "GPER095"
Private nLastKey := 0
Private cPerg	 := "GPR090"

//��������������������������������������������������������������Ŀ
//� Variaveis Utilizadas na funcao IMPR 						 �
//����������������������������������������������������������������
Private Titulo	 := STR0088		//"PROVIS�O DE PLR"
Private AT_PRG	 := "GPER095"
Private wCabec0  := 1
Private wCabec1  := STR0011	//"Data Base: "
Private CONTFL	 := 1
Private LI		 := 0
Private nTamanho := "M"
Private lItemClVl:= SuperGetMv( "MV_ITMCLVL", .F., "2" ) $ "13"	// Determina se utiliza Item Contabil e Classe de Valores

TCInternal(5,"*OFF")   // Desliga Refresh no Lock do Top

If lItemClVl
	aAdd( aOrd, STR0083 ) // "C.Custo + Item + Classe"
EndIf

//�������������������������������������������������������Ŀ
//� Ajuste Perguntas									  �
//���������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas							 �
//����������������������������������������������������������������
Pergunte("GPR090",.F.)

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT						 �
//����������������������������������������������������������������

wnrel := "GPER095"            //Nome Default do relatorio em Disco
wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

//��������������������������������������������������������������Ŀ
//� Carrega variaveis privates comuns a GPEA070,GPER070 e GPEM070|
//����������������������������������������������������������������
GPEProvisao(wnRel,cString,Titulo,,8)

RestArea( aAreaSRA )

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 � GP095imp � Autor � Emerson Rosa de Souza � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Provisao de 13� Salario									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � GP090Imp(lEnd,WnRel,cString)								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso	 	 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
static Function GP095IMP(lEnd,WnRel,cString)
//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais (Programa)							 �
//����������������������������������������������������������������
Local cMapa      := 0
Local nLaco      := nByte := 0
Local cMascCus   := GetMv( "MV_MASCCUS" ) // Mascara do p/Niveis do C.Custo
Local cAcessaSRA := ChkRH("GPER095","SRA","2")
Local aAreaSRA   := SRA->(GetArea())
Local nQ
Local nCnt2
Local nCnt1
Local lCalcula    := .T.
Local lFerias     := .F.
Local l13oSal     := .F.
Local lTodosCpos  := !(cAcessaSRA==".T.")
Local cFiltroRel  := aReturn[7]

//�������������������������������������������������������Ŀ
//� Define Variaveis Private(Programa)					  �
//���������������������������������������������������������
Private aPlrSalar     := Array(_Linhas,_Colunas)
Private a14Salar := Array(_Linhas,_Colunas)
Private aTotPlr     := Array(_Linhas,_Colunas)
Private aCabProv     := {}
Private aVerba  	 := {}
Private aTransf      := {}
Private aTotCc1      := {}
Private aTotCc2      := {}
Private aTotCc3      := {}
Private aTotFil1     := {}
Private aTotFil2     := {}
Private aTotFil3     := {}
Private aTotEmp1     := {}
Private aTotEmp2     := {}
Private aTotEmp3     := {}
Private aInfo	     := {}
Private aCodFol  	 := {}
Private aNiveis      := {} // Niveis do Centro de Custo
Private lTrataTrf    := .F.
Private lSalInc    	 := .F.
Private lCalcPis	 := .F.

//��������������������������������������������������������������Ŀ
//� Carregando variaveis mv_par?? para Variaveis do Sistema.	 �
//����������������������������������������������������������������
//Faz o tratamento abaixo pois o relatorio de rateio mensal da provisao ja utiliza a ordem 5
nOrdem		:= Iif( IsInCallStack("GPER095") .And. aReturn[8] == 5 , 6, aReturn[8] )
dDataRef   	:= mv_par01                             // Data de Referencia
cFilDe	   	:= mv_par02								//	Filial De
cFilAte    	:= mv_par03								//	Filial Ate
cCcDe	   	:= mv_par04								//	Centro de Custo De
cCcAte	   	:= mv_par05								//	Centro de Custo Ate
cMatDe	   	:= mv_par06								//	Matricula De
cMatAte     := mv_par07								//	Matricula Ate
cNomeDe     := mv_par08								//	Nome De
cNomeAte    := mv_par09								//	Nome Ate
nAnaSin     := mv_par10								//	Sintetica / Analitica
nGerRes     := mv_par11								//	Resumida  / Geral
lImpNiv     := If(mv_par12 == 1,.T.,.F.)		    //  Imprimir Niveis C.Custo
cCateg	    := mv_par13								//	Categorias (Utilizada em fMonta_TPR)

If !Empty( cFiltroRel )
	lTodosCpos  := .T.
	cAcessaSRA :=  "{ || " +ChkRH("GPER095","SRA","2") + " .And. " + cFiltroRel +"}"
Else
	cAcessaSRA := "{ || " + cAcessaSRA + "}"
Endif
If Empty(cTpRtProv)
	Titulo  := STR0088+If(nAnaSin==1,STR0013,STR0014)+;	//"RELACAO DE PROVISAO DE PLR "###"ANALITICA"###"SINTETICA"
	               " "+If(nGerRes == 1,STR0015,STR0016)		//"(GERAL)"###"(RESUMIDA)" 
Else
	Titulo  := STR0087+If(nAnaSin==1,STR0013,STR0014)+;	//"RELACAO DE PROVISAO MENSAL DE PLR "###"ANALITICA"###"SINTETICA"
	               " "+If(nGerRes == 1,STR0015,STR0016)		//"(GERAL)"###"(RESUMIDA)"
EndIf

wCabec1 += Dtoc(dDataRef)

If cPaisLoc == "ARG"
	cPict1	:=	If (MsDecimais(1)==2,"@E 999,999.99",TM(999999,10,MsDecimais(1)))  // "@E 999,999.99
Endif
//��������������������������������������������������������������Ŀ
//� aNiveis -  Armazena as chaves de quebra.                     �
//����������������������������������������������������������������
If lImpNiv

	aNiveis:= MontaMasc(cMascCus)

    //��������������������������������������������������������������Ŀ
	//� Criar os Arrays com os Niveis de Quebras					 �
	//����������������������������������������������������������������
	For nQ := 1 to Len(aNiveis)
        cQ := cValToChar(NQ)
        Private aTotCc1&cQ   := {} // Niveis dos Centro de Custo
        Private aTotCc2&cQ   := {}
	    Private aTotCc3&cQ   := {}
        cCcAnt&cQ            := "" // Variaveis c.custo dos niveis de quebra
    Next nQ
Endif

//������������������������������������������������������������Ŀ
//� Monta o arquivo temporario "TPR" a partir do SRA e SRE     |
//��������������������������������������������������������������
Processa({ || fMonta_TPR("","",nOrdem,dDataRef,@lSalInc,@lTrataTrf,@aTransf,,cAcessaSRA,,lTodosCpos)},STR0089) //"PROVIS�O DE PLR"

dbSelectArea( "SRA" )
dbSetOrder(1)

dbSelectArea( cTBLXPROV )
dbGoTop()

//������������������������������������������������������������Ŀ
//� Carrega regua de processamento							   �
//��������������������������������������������������������������
SetRegua( RecCount() )

cFilialAnt := Replicate("!", FWGETTAMFILIAL)
cCcAnt	   := "!!!!!!!!!"
While !Eof()

	//��������������������������������������������������������������Ŀ
	//� Movimenta Regua de Processamento							 �
	//����������������������������������������������������������������
	IncRegua()
	
	//��������������������������������������������������������������Ŀ
	//� Garante o Posicionamento do Funcionario no SRA				 �
	//����������������������������������������������������������������
	dbSelectArea( "SRA" )
	dbSeek( (cTBLXPROV)->PR_FILIAL + (cTBLXPROV)->PR_MAT )
	dbSelectArea( cTBLXPROV )

	If lEnd
		@Prow()+1,0 PSAY cCancel
   		Exit
    Endif

	//��������������������������������������������������������������Ŀ
	//� Quebra de Filial											 �
	//����������������������������������������������������������������
	If (cTBLXPROV)->PR_FILIAL # cFilialAnt       
	
		If !Fp_CodFol(@aCodFol,(cTBLXPROV)->PR_FILIAL) .Or.;
		   !fInfo(@aInfo,(cTBLXPROV)->PR_FILIAL)
			Exit
		Endif

		cFilialAnt := (cTBLXPROV)->PR_FILIAL
		
		//��������������������������������������������������������������Ŀ
		//� Carrega os identificadores da Provisaos						 �
		//����������������������������������������������������������������
		fIdentProv(@aVerba,aCodFol,.F.,.T.)

	Endif

	//��������������������������������������������������������������Ŀ
	//� Limpa o array com o conteudo especificado no 2� parametro    �
	//����������������������������������������������������������������
	fLimpaArray( @aTotPlr, 0 )
	fLimpaArray( @a14Salar, 0 )
	//��������������������������������������������������������������Ŀ
	//� Busca informacoes de cabecalho no SRT	 					 �
	//����������������������������������������������������������������
	If !fBusCabSRT(dDataRef,@aCabProv)
		fTestaTotal(_PlrSalar)
		Loop
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Busca os lancamentos de PLR				     �
	//����������������������������������������������������������������
	fQryDetSRT(aVerba,aTransf,dDataRef,lTrataTrf,lCalcula,lFerias,l13oSal,,.T.)
	 
	//��������������������������������������������������������������Ŀ
	//� Totalizador (PLR)	                    			     �
	//����������������������������������������������������������������
	For nCnt1 := 1 To _Linhas
		For nCnt2 := 1 To _Colunas
			aTotPlr[nCnt1,nCnt2] := aPlrSalar[nCnt1,nCnt2]
		Next nCnt2
	Next nCnt1
	
	//��������������������������������������������������������������Ŀ
	//| Totalizadores dos Niveis de Quebra                           |
	//����������������������������������������������������������������
	If nOrdem != 6 // Nao imprime niveis de c.custo na ordem de item + classe
	    fTotNivCC(aPlrSalar, a14Salar, aTotPLr) // Niveis do Centro de Custo
	EndIf
	fAtuCont(@aToTCc1 , @aTotCc2 , @aTotCc3, aPlrSalar, a14Salar, aTotPLr)  // Centro de Custo
	fAtuCont(@aTotFil1, @aTotFil2, @aTotFil3, aPlrSalar, a14Salar, aTotPLr) // Filial
	fAtuCont(@aTotEmp1, @aTotEmp2, @aTotEmp3, aPlrSalar, a14Salar, aTotPLr) // Empresa

	//��������������������������������������������������������������Ŀ
	//| Imprime o funcionario                                        |
	//����������������������������������������������������������������
	If nAnaSin == 1
		fImpFunPlr()
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//| Quebras e Skips                                              |
	//����������������������������������������������������������������
	fTestaTotal(_PlrSalar)
Enddo

//����������������������������������������������������Ŀ
//� Termino do relatorio							   �
//������������������������������������������������������
dbSelectArea( "SRA" )
Set Filter To
dbSetOrder(1)

If aReturn[5] == 1
	Set Printer To
	ourspool(wnrel)
Endif
MS_FLUSH()

//��������������������������������������������������������������Ŀ
//� Retorna area original do cadastro de funcionarios		     �
//����������������������������������������������������������������
RestArea(aAreaSRA)

(cTBLXPROV)->(dbCloseArea())

//Elimina arquivo tempor�rio de provis�o
fDelTMPPRV()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �fImpFunPlr� Autor � Equipe R.H.           � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Impressao dos Funcionarios							      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fImpFun13o()     			             				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso	 	 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fImpFunPlr()
Local lRetu1   := .T.
Local cDemissa := If(MesAno((cTBLXPROV)->PR_DEMISSA) <= MesAno(dDataRef),(cTBLXPROV)->PR_DEMISSA,CTOD(""))

If Empty(cTpRtProv)
	cSituacao := If(aCabProv[_MovProv] == _Cong_13s .Or. aCabProv[_MovProv] == _Cong_F13,STR0048,If(aCabProv[_MovProv] == _Trfe_Sai,STR0047,"")) // CONGELADO##TRANSFERENCIA 
	cSituacao := Left( Upper(cSituacao) + Space(27), 27)
	
	cDET := STR0023+(cTBLXPROV)->PR_FILIAL+STR0024+Subs((cTBLXPROV)->PR_CC+Space(20),1,20)+STR0019+Subs((cTBLXPROV)->PR_MAT,1,30)	//"FILIAL: "###" CCTO: "###" MAT: "
	cDET += STR0020+If(lOfuscaNom,Replicate('*',15),(cTBLXPROV)->PR_NOME)	                       //" NOME: "
	cDET += STR0022+LTrim(TRANSFORM(aCabProv[_SalProv],cPict1))					           //" SALARIO: "
	Impr(cDet,"C")
	
	cDet := Space(17)+cSituacao+STR0044+DtoC((cTBLXPROV)->PR_ADMISSA)+Space(3)+STR0045+Dtoc(cDemissa)  //" DT.ADMISSAO: "###" DATA DEMISSAO: "
	Impr(cDet,"C")
	
	lRetu1 := fImpComp(aPlrSalar,1,.T.,_PlrSalar)
Else

	If nOrdem == 5
		cImpCC1 := STR0082+Subs((cTBLXPROV)->PR_CCMVTO+Space(20),1,20) //"CC.MOVT: "
		cImpCC2 := Space(23)+STR0024+Subs((cTBLXPROV)->PR_CC+Space(20),1,20) // " CCTO: " ##
	Else
		cImpCC1 := STR0024+Subs((cTBLXPROV)->PR_CC+Space(20),1,20) // " CCTO: " ##
		cImpCC2 := Space(19)+STR0082+Subs((cTBLXPROV)->PR_CCMVTO+Space(20),1,20) // "CC.MOVT: "
	EndIf
	cDET:=STR0023+(cTBLXPROV)->PR_FILIAL+Space(5)+cImpCC1+Space(2)+STR0019+Subs((cTBLXPROV)->PR_MAT,1,30)+Space(3) 	//"FILIAL: "#####" CCTO: " ou "CC.MOVT.: "#####" MAT: "###
	cDET+=STR0020+If(lOfuscaNom,Replicate('*',15),(cTBLXPROV)->PR_NOME)+Space(5)          									                    //"NOME: "########
	cDET+=STR0022+LTrim(TRANSFORM(aCabProv[_SalProv],cPict1))		 			 	                    //" SALARIO: "
	Impr(cDet,"C")
	cDet:=cImpCC2+SPACE(3)+STR0044+Dtoc((cTBLXPROV)->PR_ADMISSA)+SPACE(3)+STR0045+Dtoc(cDemissa)   //"CC.MOVT.: " ou " CCTO: "###"DATA ADMISSAO: "###"DATA DEMISSAO: "
	Impr(cDet,"C")
	
	lRetu1 := fImpComp(aPlrSalar,1,.T.,_PlrSalar)
	
EndIf

cDet := Repl("-",132)
Impr(cDet,"C")
Impr("","C")

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 � fCompPlr � Autor � Equipe R.H.           � Data � 16.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Complemento da Impressao								      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fComp13o(aPosicao,nLugar,lImpFunc)       				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso	 	 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fCompPlr(aPosicao,nNroArray,lImpFunc)
//��������������������������������������������������������������������������Ŀ
//| aPosicao  = Array contendo o que sera impresso     (13�/14�/Total)       |
//| nNroArray = Posicao fisica dos grupos de impressao (1-13o,2-14o,3-Tot)   |
//����������������������������������������������������������������������������
Local cCab1,cCab2,cMes,Sub_C
Local nValPro,nValAdi,nVal1Pa,nValIns,nValFgt,nTotFer,nTotEnc,nTotGer
Local nPosImp  := 0
Local lImpTxBx := .T.
Local nTotImp  := _Linhas - 1
Local bChkVal  := { |nArg| ( aPosicao[nArg,_Prov] == 0 ) }

lImpFunc := If(lImpFunc == Nil,.F.,lImpFunc) // Se verdadeiro, sera impresso o funcionario

//��������������������������������������������������������������Ŀ
//� Nao Imprime Nenhuma das Colunas se o Valor for Zero 		 �
//����������������������������������������������������������������
If Eval(bChkVal,_Anter) .And. Eval(bChkVal,_Atual) .And. Eval(bChkVal,_BxTot)
	If nGerRes == 1
		Return .F.
	EndIf
Endif

If nGerRes == 1 .Or. (nGerRes == 2 .And. nNroArray == 1)
   cDET:=SPACE(28)+STR0029	//"VALOR"
   IMPR(cDET,"C")
Endif

Sub_C := If(nGerRes==2,Space(5),If(nNroArray==1,If(lImpFunc,Space(5),STR0086),If(nNroArray==2,STR0067,Left(STR0028,5)))) //"MESES"##" 14 �"##"TOTAL"

For nPosImp := 1 To nTotImp
	
	If nGerRes == 2
		cCab1 := Space(5)
		cCab2 := Space(6)
	Else
		If !Empty(cTpRtProv)
			cCab1 := Space(4)
		Else
			cCab1 := If(nPosImp == _NoMes, Sub_C, If(nPosImp == _TrfEnt .Or. nPosImp == _TrfSai,STR0073,If(nPosImp > _Atual,STR0049,Space(5)))) //"MESES"###"Val. Baixa"###"Transf.Saldo"
		EndIf
		cCab2 := If(nPosImp == _Anter,STR0039,If(nPosImp == _Corre,STR0040 ,;
				  If(nPosImp == _NoMes,STR0041,If(nPosImp == _Atual,STR0043,;
				  If(nPosImp == _BxTrf,STR0050,If(nPosImp == _BxRes,STR0052,;
				  If(nPosImp == _BxPlr,STR0086+space(1),If(nPosImp == _TrfEnt,STR0074,If(nPosImp == _TrfSai,STR0075,"")))))))))	//"Anter "###"Correc"###"No Mes"###"Atual "###"Transf"###"Rescis"###"13.Sal"###"Entr."###"Saida"
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Nao Imprime Correcao ou Baixa se o Valor for Zero    		 �
	//����������������������������������������������������������������
	If (nPosImp == _Corre .Or. nPosImp > _Atual) .And. Eval(bChkVal,nPosImp)
		Loop
	Endif
	
	//cMes := If(lImpFunc .And. nPosImp == _NoMes,Transform(aPosicao[_NoMes,_Avos],"99"),Space(02))
	//cMes := If (Val(cMes) > 0 , cMes ,"  ")
 	cMes := "  "
	If nPosImp == _Anter .Or. nPosImp == _NoMes .Or. nPosImp == _Corre .Or. nPosImp == _Atual .Or. cTpRtProv == "RP13"
		cDet := cCab1+" "+cMes+Space(5)+cCab2+"  "
	Else
		If lImpTxBx .Or. nPosImp == _TrfEnt
	        cDet:= cCab1+"  "+cCab2+"  "
	     	lImpTxBx := .F.
	    Else
   	     	cDet:= Space(13)+cCab2+"  "
	    EndIf 	
	EndIf
	
	nValPro := aPosicao[nPosImp,_Prov]
    
	cDet +=     TRANSFORM(nValPro,cPict2)

	If nGerRes == 1 .Or. (nGerRes == 2 .And. nPosImp == _NoMes) .Or. (nGerRes == 2 .And. cTpRtProv == "RP13")
		Impr(cDet,"C")
	EndIf
Next

//��������������������������������������������������������������Ŀ
//� Montagem e impressao do valor que sera contabilizado 		 �
//����������������������������������������������������������������
If nNroArray == 3 .And. !lImpFunc
	If !Eval(bChkVal,_BxTot)
		nValPro := aPosicao[_NoMes,_Prov]-aPosicao[_BxTot,_Prov]
	
		cDet := STR0053+"         "  // No Mes-Baixa
		cDet +=     TRANSFORM(nValPro,cPict2)
		Impr(cDet,"C")
	EndIf
EndIf
Li := If(nGerRes == 1 ,Li++,Li)

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fGpeProvis� Autor � Emerson Rosa de Souza � Data � 10.08.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cria constantes p/ utilizacao em GPEA070,GPER070 e GPEM070.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � GpeProvisao(uPar1,uPar2,uPar3,nPar4,uPar5)                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
static Function GpeProvisao(uPar1,uPar2,uPar3,uPar4,uPar5,aPar,cTpRtPr,cRetSqlName)
Local cIdPlr	:= GetMvRH("MV_PLRVER",,"XXX;XX1;XX2;XX3;XX4")
Local aPdPlr	:= {}

DEFAULT cRetSqlName := ""
uPar5 := If(uPar5 == Nil, 1, uPar5)

If !Empty(cIdPlr) .And. ";" $ cIdPlr
	aPdPlr := Separa(cIdPlr,";")
EndIf
//plr
Private lPLRPE	  	  := ExistBlock("GP070PLR")
Private _cPDPlr 	  := "XXX"
Private _cPdBxPLR 	  := "XX1"
Private _cPdMesPLR 	  := "XX2"
Private _cPDTrfPLR 	  := "XX3"
Private _cPDResPLR 	  := "XX4"
If Len(aPdPlr) == 5
	_cPDPlr 	  := aPdPlr[1]
	_cPdBxPLR 	  := aPdPlr[2]
	_cPdMesPLR 	  := aPdPlr[3]
	_cPDTrfPLR 	  := aPdPlr[4]
	_cPDResPLR 	  := aPdPlr[5]
EndIf

Private _cFechaPLR 	  := GetMvRH("MV_PLRPER",,"12")
Private _lVlrBaixa 	  := GetMvRH("MV_PLRVLBX",,.F.)

// INDICA O TIPO DE PROVISAO (SERA GRAVADO NO CAMPO RT_TIPPROV)
Private _FerVenc  := 1  // Ferias Vencidas
Private _FerProp  := 2  // Ferias Proporcionais
Private _13Salar  := 3  // 13o Salario
Private _14Salar  := 4  // 14o Salario
Private _FerVMes  := 5	// Ferias Provisao Mes
Private _13SVMes  := 6  // 13o Provisao Mes
Private _RecVenc  := 7	// Recesso Vencido
Private _RecProp  := 8	// Recesso Proporcional
Private _PlrSalar := 9  // PLR Provisao
Private _PlrSVMes := 10  //PLR Provisao Mes

// INDICA A LINHA NA ORDEM EM QUE SERA APRESENTADA NO RELATORIO
Private _Anter    := 01  // Mes Anterior
Private _Corre    := 02  // Correcao
Private _NoMes    := 03  // No Mes
Private _Atual    := 04  // Mes Atual
Private _BxTrf    := 05  // Baixa de Transferencia
Private _BxFer    := 06  // Baixa de Ferias
Private _BX13O    := 06  // Baixa de 13o Salario
Private _Bx14o    := 06  // Baixa de 14o Salario
Private _BxPLR    := 06  // Baixa de PLR
Private _BxRes    := 07  // Baixa de Rescisao
Private _TrfEnt   := 08  // Transferencia de Entrada
Private _TrfSai   := 09  // Transferencia de Saida
Private _BxTot    := 10  // Baixa Total
// INDICA A COLUNA NA ORDEM EM QUE SERA APRESENTADA NO RELATORIO
Private _Dias     := 1  // Dias de Ferias
Private _Avos     := 1  // Avos de 13o Salario
Private _Prov     := 2  // Valor da Provisao de Ferias ou Decimo Terceiro Salario
Private _Adic     := 3  // Adicionais
Private _1Ter     := 4  // Um Terco de Ferias
Private _1Par     := 4  // 1o Parcela do 13o Salario
Private _INSS     := 5  // INSS
Private _FGTS     := 6  // FGTS
Private _SalV	  := 7  // Media Salario Vac
Private _PIS      := 8  // PIS
// CONSTANTES QUE DEFINEM O NUMERO DE LINHAS E COLUNAS DO ARRAY
Private _Linhas   := 10  // Quantidade de Linhas ou Elementos
Private _Colunas  := 08  // Quantidade de colunas para cada Linha ou Elemento
// INDICA A POSICAO DAS INFORMACOES DE CABECALHO EM "aCabProv"
Private _DatCalc  :=  1  // Data do calculo
Private _CentroC  :=  2  // Data do calculo
Private _DBsProv  :=  3  // Data base de ferias
Private _DFerVen  :=  4  // Dias de ferias vencidas
Private _DFerPro  :=  5  // Dias de ferias proporcionais
Private _DFerAnt  :=  6  // Dias de ferias antecipadas
Private _DFalVen  :=  7  // Dias de faltas vencidas
Private _DFalPro  :=  8  // Dias de faltas proporcionais
Private _MovProv  :=  9  // Movimentacao no mes
Private _SalProv  := 10  // Salario da provisao no mes
Private _Avos13S  := 11  // Avos de 13o salario
Private _PStatus  := 12  // Status (Ativo/Excluido)
Private _CItem	  := 13  // Item Contabil
Private _Clvl	  := 14  // Classe de Valor
// INDICA OS TIPOS DE MOVIMENTACAO DO FUNCIONARIO NO MES
Private _Demitido := 1  // Demitido
Private _Cong_Fer := 2  // Congelado Ferias
Private _Cong_13s := 3  // Congelado 13 Salario
Private _Cong_F13 := 4  // Congelado Ferias e 13 Salario
Private _Trfe_Sai := 5  // Transferencia Saida
Private _Trfe_Ent := 6  // Transferencia Entrada
// INDICA AS POSICOES DENTRO DO ARRAY aTransf
Private _TAnter   := 1  // Centro de Custo Anterior
Private _TAtual   := 2  // Centro de Custo Atual
Private _TDest    := 3  // Centro de Custo Destino
Private _TEmp     := 1  // Empresa
Private _TFil     := 2  // Filial
Private _TCC      := 3  // Centro de Custo
Private _TMat     := 4  // Matricula
Private _TDta     := 5  // Data da Transferencia
Private _TInc     := 6  // Funcionario ja incluido no arquivo temporario
Private _TItem	  := 7  // Item Contabil
Private _TClvl	  := 8  // Classe de Valor
Private cTpRtProv
Private lGeraPMes := .F.

Private aFldRot 	:= {'RA_NOME'}
Private aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Private lOfuscaNom 	:= .F.
Private aFldOfusca	:= {}

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
		lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
ENDIF

If GetMvRH("MV_RATPROV",,"N") == "S"
	lGeraPMes	  := fChkRHQBase()	// Verifica a existencia da tabela RHQ
Endif

If ValType(cTpRtPr) == "U"
	cTpRtProv	:= Nil
Else
	cTpRtProv	:= cTpRtPr
EndIf

If uPar5 == 1 		// Cadastro
	gp070Atu(uPar1,uPar2,uPar3)
ElseIf uPar5 == 2  // Relatorio de Ferias
	RptStatus({|lEnd| GP070Imp(@lEnd,uPar1,uPar2)},uPar3)
ElseIf uPar5 == 3  // Relatorio de 13o Salario
	RptStatus({|lEnd| GP090Imp(@lEnd,uPar1,uPar2)},uPar3)
ElseIf uPar5 == 4  // Calculo
	// EM GRID HAVERA UMA BARRA DE PROCESSAMENTO DA LIB //
	If lGrid
		MsAguarde({|lEnd| GPM070Processa(aPar)}, OemToAnsi(STR0051), OemToAnsi(STR0052)) //"Aguarde..."###"Preparando Informa��es para o GRID..."
	Else
		Processa({|| GPM070Processa(aPar)},uPar1,,.T.)
	EndIf
ElseIf uPar5 == 5  // Importacao do arquivo SRF para o novo SRT
//    Processa({|| fConvSRF()},uPar1)
ElseIf uPar5 == 6  // Geracao de lancamentos contabeis da provisao no arquivo SRZ
    Processa({|| fGeraProvSRZ(uPar2,,lPLRPE,cRetSqlName)},uPar1)
ElseIf uPar5 == 7  // Processa a diferencas do calculo de provisa
	Processa({|| fProvProc()},uPar1)
ElseIf uPar5 == 8  // Relatorio de PLR
	RptStatus({|lEnd| GP095Imp(@lEnd,uPar1,uPar2)},uPar3)
EndIf

Return
