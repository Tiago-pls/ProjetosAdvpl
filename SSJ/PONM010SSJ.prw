#include "rwmake.ch"
#include "protheus.ch"

Static lPonaPo1Block	:= ExistBlock( "PONAPO1" )
Static lPonaPo2Block	:= ExistBlock( "PONAPO2" )
Static lPonaPo3Block	:= ExistBlock( "PONAPO3" )
Static lPonaPo5Block	:= ExistBlock( "PONAPO5" )
Static lPonaPo6Block	:= ExistBlock( "PONAPO6" )
Static lPonaPo7Block	:= ExistBlock( "PONAPO7" )
Static lPonaPo8Block	:= ExistBlock( "PONAPO8" )
Static lPnm010CposBlock	:= ExistBlock( "PNM010CPOS" )
Static lPnm010Ref1Block	:= ExistBlock( "PNM010REF1" )
Static lPnm010R2Block	:= ExistBlock( "PNM010R2" )
Static lPnm010IniBlock  := ExistBlock( "PNM010INI" )
Static lExInAs400		  := ExeInAs400()
Static __LastParam__	:= {}
Static lPort1510 		:= Port1510() 	//Verifica se Portaria 1510/2009 esta em vigor.
Static lIntegDef 		:= FindFunction("GETROTINTEG") .And. FindFunction("FWHASEAI")
Static _aAuxPerApo		:= {}


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � PONM010	� Autor � Equipe Advanced RH    � Data �01/03/1996���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Classifica��o das Marca��es                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPON                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Leandro Dr. �13/04/14�      �Retirada de ajustes, database e FieldPos  ���
���            �        �      �que nao serao utilizados na P12.		  ���
���Allyson M.  �16/07/14�TPSJLN�Ajuste em GetMrBySra() p/ ordernar a query���
���			   � 		�      �por PIS caso o relogio seja REP 		  ���
���Luis Artuso �18/07/14�TQCB94�Ajuste em Ponm010Processa para validar o  ���
���			   � 		�      �periodo aberto da filial.				  ���
���Luis Artuso |27/08/14|TQHGBM|Ajuste para nao permitir gerar apontamento���
���			   | 		|      |para filiais que estejam fora do periodo  ���
���			   | 		|      |ou data posterior a database.             ���
���Renan Borges|07/05/15|TSDV21|Ajuste para classificar refei��o correta- ���
���			   | 		|      |mente quando turno for noturno.           ���
���Renan Borges|05/06/15|TSMCG5|Ajuste para utilizar data de apontamento  ���
���			   | 		|      |para realizar o fechamento do per�odo cor-���
���			   | 		|      |retamente.                                ���
���Allyson M.  |16/10/15|TTPMJ1|Ajuste p/ schedule p/ somente efetuar     ���
���			   | 		|      |classificacao dos funcionarios que tive-  ���
���			   | 		|      |ram registros lidos p/ performance; p/    ���
���			   | 		|      |gravar marcacoes de funcionarios alocados ���
���			   | 		|      |em filial diferente da filial do relogio e���
���			   | 		|      |p/ nao efetuar a leitura de relogios com  ���
���			   | 		|      |registro de bloqueado (P0_MSBLQL = 1)     ���
���			   | 		|      |Ajuste p/ validacao do campo P0_INC.      ���
���			   | 		|      |Ao executar a rotina de leitura/apontamen-���
���			   | 		|      |to, deve ser gerado log de ocorrencia     ���
���			   | 		|      |informando relogios do tipo 'REP' que nao ���
���			   | 		|      |tenham o tipo incremental, conforme bole- ���
���			   | 		|      |tim disponivel:                           ���
���			   | 		|      |http://tdn.totvs.com/x/9YRsAQ             ���
���			   | 		|      |Ajuste p/ ajustar a data fim de apontamen-���
���			   | 		|      |to, quando houver demiss�o. Deve ser      ���
���			   | 		|      |enviada como data final a data base, para ���
���			   | 		|      |eliminar os apontamentos gerados apos a   ���
���			   | 		|      |data de demissao.                         ���
���Renan B.    |07/12/15|TTTSI7|Ajuste para considerar corretamente o ran-���
���			   | 		|      |ge de data. Se informar apenas um dia para���
���			   | 		|      |leitura/apontamento (Ex.: 01/10 a 01/10 a ���
���			   | 		|      |rotina ignorava a execucao do apontamento ���
���			   | 		|      |devido erro na cl�usula de validacao em   ���
���			   | 		|      |lContinua.                                ���
���Renan Borges|18/04/16|TUJU54|Ajuste para montar intervalo do filtro cor���
���			   | 		|      |retamente quando o modo de compartilhamen-���
���			   | 		|      |to da tabela de relogio for exclusivo.    ���
���Matheus M.  |06/07/16|TUXBWK|Ajustes na integra��o TSA x Ponto na op��o���
���			   | 		|      |de importa��o de refei��es.				  ���
���Raquel Hager|19/04/16|TVSOVR|Ajuste para n�o realizar leitura de marca-���
���			   | 		|      |��es anteriores � Data de Admiss�o.       ���
���Oswaldo L.  |03/04/17|DRHPONTP-164|       Projeto cTree                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
User Function SPonm010(	lWork		,;	//01 -> Se o "Start" foi via WorkFlow
					lUserDef 	,;	//02 -> Se deve considerar as configuracoes dos parametros do usuario
					lLimita		,;	//03 -> Se deve limitar a Data Final de Apontamento a Data Base
					cProcFil	,;	//04 -> Filial a Ser Processada
					lProcFil	,;	//05 -> Processo por Filial
					lApoNLidas	,;	//06 -> Apontar quando nao Leu as Marcacoes para a Filial
					lForceR		,;	//07 -> Se deve Forcar o Reapontamento
					xAutoCab	,;
					xAutoItens	,;
					nOpcAuto    ,;
					cProcessa   ,;  //11 -> '1'->Leitura , '2'->Apontamento , '3'->Ambos
					cTipoRel    ,;  //12 -> '1'->Funcionario , '2'->Relogio
					dDtIni   	,;  //13 -> Data inicio para leitura das marcacoes - Via Workflow
					dDtFim   	 ;  //14 -> Data Fim para leitura das marcacoes - Via Workflow
				)

Local aArea					:= GetArea()
Local aArqSel				:= {}
Local aSays					:= {}
Local aButtons				:= {}
Local aChkAlias	        	:= {}

Local cChar		 			:= IF( ( TcSrvType() == "AS/400" ) , "9" , "Z" )
Local cSvFilAnt				:= cFilAnt
Local lChkAlias				:= .F.
Local lBarG1ShowTm 			:= .F.
Local lBarG2ShowTm 			:= .F.
Local nOpcA					:= 0
Local cTrbTmp               := GetNextAlias()
Local nAt1					:= 0

DEFAULT lWork				:= .F.
DEFAULT lUserDef			:= .F.
DEFAULT lLimita				:= .T.
DEFAULT cProcFil			:= .F.
DEFAULT lProcFil			:= .F.
DEFAULT lApoNLidas			:= .F.
DEFAULT lForceR				:= .F.

DEFAULT lPonaPo1Block		:= ExistBlock( "PONAPO1" )
DEFAULT lPonaPo2Block		:= ExistBlock( "PONAPO2" )
DEFAULT lPonaPo3Block		:= ExistBlock( "PONAPO3" )
DEFAULT lPonaPo5Block		:= ExistBlock( "PONAPO5" )
DEFAULT lPonaPo6Block		:= ExistBlock( "PONAPO6" )
DEFAULT lPonaPo7Block		:= ExistBlock( "PONAPO7" )
DEFAULT lPonaPo8Block		:= ExistBlock( "PONAPO8" )
DEFAULT lPnm010CposBlock	:= ExistBlock( "PNM010CPOS" )
DEFAULT lPnm010Ref1Block	:= ExistBlock( "PNM010REF1" )
DEFAULT lPnm010R2Block	    := ExistBlock( "PNM010R2" )
DEFAULT lPnm010IniBlock	    := ExistBlock( "PNM010INI" )
DEFAULT lExInAs400			:= ExeInAs400()
DEFAULT xAutoCab   			:= NIL
DEFAULT xAutoItens 			:= NIL
DEFAULT nOpcAuto   			:= NIL
DEFAULT cProcessa			:= "3"
DEFAULT cTipoRel			:= "2"
DEFAULT dDtIni				:= Ctod("//")
DEFAULT dDtFim				:= Ctod("//")

PRIVATE aAutoCab   			:= xAutoCab
PRIVATE aAutoItens 			:= xAutoItens
PRIVATE nAutoOpc   			:= If(nOpcAuto <> NIL,nOpcAuto,3)
PRIVATE lPN010Auto 			:= ValType(xAutoCab)=="A" .And. ValType(xAutoItens) == "A"

Private cCadastro   		:= OemToAnsi('Leitura/Apontamento Marcacoes' ) // 'Leitura/Apontamento Marcacoes'
Private lAbortPrint 		:= .F.

Private lFiltRel			:= .F. //Filtra Relogios
Private lMultThread			:= .F. //Somente � verdadeiro se ambiente for TOP e parametro MV_PONMULT for maior que zero
Private nMultThread			:= 0
Private lGeolocal 			:= SP8->(ColumnPos("P8_LATITU")) > 0 .And. SP8->(ColumnPos("P8_LONGIT")) > 0

/*/
��������������������������������������������������������������Ŀ
� Variaves do Processo WorkFlow								   �
����������������������������������������������������������������/*/
Private lSchedDef		:= FWGetRunSchedule()
Private lWorkFlow		:= lWork .OR. lSchedDef
Private lUserDefParam	:= lUserDef
Private lLimitaDataFim	:= lLimita
Private cFilProc		:= cProcFil
Private lProcFilial		:= lProcFil
Private lApontaNaoLidas := lApoNLidas
Private lForceReaponta	:= lForceR
Private nProcessa		:= Val(cProcessa)
Private nTipoRel		:= Val(cTipoRel)
Private dDtIniWf		:= dDtIni
Private dDtFimWf  		:= dDtFim
Private oTmpTabFO1

If lPort1510
	cCadastro += fPortTit() //Complementa titulo da tela com dizeres referente a portaria.
EndIf

nMultThread := SuperGetMv( "MV_PONMULT" , NIL , 0 )
lMultThread := If(nMultThread > 1,.T.,.F.)

lFiltRel := ( SuperGetMv("MV_FILTREL",NIL,"N") == "S" )

/*/
��������������������������������������������������������������Ŀ
� Carrega a Filial a Ser Processada Quando WorkFlow            �
����������������������������������������������������������������/*/
//N�o � necess�rio carregar quando vem do SchedDef
IF ( lWorkFlow .AND. !lSchedDef )
	cFilAnt := IF( ( ValType( cFilProc ) == "C" ) .and. Len(Alltrim(cFilProc)) > 0 , cFilProc , cFilAnt )
EndIF

/*/
��������������������������������������������������������������Ŀ
� So Executa se os Modos de Acesso dos Arquivos Relacionados es�
� tiverm OK e se For Encontrado o Periodo de Apontamento.      �
����������������������������������������������������������������/*/
IF ValidArqPon( !( lWorkFlow ) )

	If lPn010Auto

		Private dPerDe 			:= Ctod("//")
		Private dPerAte 		:= Ctod("//")
		Private dPerIni			:= Ctod("//")
		Private dPerFim			:= Ctod("//")
		Private dData   		:= Ctod("//")
		Private aLogFile		:= {}
		Private nDiasExtA 		:= 0
		Private nDiasExtP 		:= 0
		Private lChkPonMesAnt	:= .F.
		Private lPonWork		:= IsInCallStack("U_PonScheduler")
		Private nGravadas	 	:= 0
		Private cFunMat			:= ""
		Private cFilFECAux   	:= ""
		Private cFilOld    		:= "__cFilOld__"
		Private nAponta 		:= 1
		Private nTipo      		:= 0

		Begin Sequence

			/*/
			������������������������������������������������������������������Ŀ
			� Verifica se existe o funcionario enviado pelo Rotina Automatica  �
			��������������������������������������������������������������������/*/
			nXFilial := aScan(aAutoCab,{|x| AllTrim(x[1]) == "RA_FILIAL" })
			nXMatric := aScan(aAutoCab,{|x| AllTrim(x[1]) == "RA_MAT" })
	        cFunMat  := aAutoCab[nXFilial][2] + aAutoCab[nXMatric][2]

			If nXFilial > 0 .And. nXMatric > 0
				dbSelectArea("SRA")
				dbSetOrder(1)
				If !dbSeek( cFunMat )
					aAdd(aLogFile,'STR0159'+ " " + aAutoCab[nXFilial][2] + " - " + aAutoCab[nXMatric][2])
					Break
				Endif
			Endif

			/*/
			������������������������������������������������������������������Ŀ
			� Envia o array com as marcacoes para a rotina de gravacao 		   �
			��������������������������������������������������������������������/*/
			If !GetPonMesDat( @dPerDe , @dPerAte , SRA->RA_FILIAL )
				Break
			EndIf

			If !GetPonMesDat( @dPerIni , @dPerFim , SRA->RA_FILIAL )
				dPerIni := dPerDe
				dPerFim	:= dPerAte
			EndIf

			nDiasExtA 	:= Min(Abs( SuperGetMv( "MV_GETDIAA" , NIL , 2  , SRA->RA_FILIAL ) ), 7)	//-- Quantidade de Dias a ser considerada antes do inicio do Periodo de  Apontamento a ser considerada na Leitura/Apontamento
			nDiasExtP 	:= Min(Abs( SuperGetMv( "MV_GETDIAP" , NIL , 2  , SRA->RA_FILIAL ) ), 7)	//-- Quantidade de Dias a ser considerada apos  o fim do Periodo de  Apontamento a ser considerada na Leitura/Apontamento

			// comando para o retorno da Integdef ser direcionado para este fonte
			SetRotInteg( "PONM010" )


			// Inclusao do ExecAuto
			If nAutoOpc == 3
				GetMrBySra()
			Else


				Begin Transaction
					dbSelectArea("SP8")
					dbSetOrder(2) // P8_FILIAL+P8_MAT+DTOS(P8_DATA)+STR(P8_HORA,5,2)

					For nAt1 :=1 to Len(aAutoItens)
						nP1Filial	:= aScan(aAutoItens[nAt1],{|x| AllTrim(x[1]) == "P8_FILIAL" })
						nP1Matric	:= aScan(aAutoItens[nAt1],{|x| AllTrim(x[1]) == "P8_MAT" })
						nP1Data		:= aScan(aAutoItens[nAt1],{|x| AllTrim(x[1]) == "P8_DATA" })
						nP1Hora		:= aScan(aAutoItens[nAt1],{|x| AllTrim(x[1]) == "P8_HORA" })

						If !dbSeek( aAutoItens [nAt1, nP1Filial, 2] + aAutoItens [nAt1, nP1Matric, 2] + DTOS(aAutoItens [nAt1, nP1Data, 2]) + STR(aAutoItens [nAt1, nP1Hora, 2],5,2) )
							aAdd(aLogFile,"Marca��o n�o encontrada!" + " - " + DTOC(aAutoItens[nAt1,nP1Data,2]) + " - " + STR(aAutoItens[nAt1,nP1Hora,2],5,2) ) // "Marca��o n�o encontrada!"
						Else
							If !Empty(SP8->P8_DATAAPO) .And. SP8->P8_APONTA = 'S'
								aAdd(aLogFile,"Marca��o j� apontada, n�o ser� poss�vel a exclus�o!" + " - " + DTOC(aAutoItens[nAt1,nP1Data,2]) + " - " + STR(aAutoItens[nAt1,nP1Hora,2],5,2) ) // "Marca��o j� apontada, n�o ser� poss�vel a exclus�o!"
							Else
								If SP8->P8_TIPOREG == "O"
									aAdd(aLogFile,"Marca��o original n�o poder� ser excluida!" + " - " + DTOC(aAutoItens[nAt1,nP1Data,2]) + " - " + STR(aAutoItens[nAt1,nP1Hora,2],5,2) ) // "Marca��o original n�o poder� ser excluida!"
								Else
									RecLock("SP8",.F.)
									dbDelete()
									MsUnLock()

									If lIntegDef
										Inclui := .F.
										Altera := .F.

										// indica o fonte para chamar na resposta da integra��o e dispara a integra�a�
										SetRotInteg( "PONM010" )
										FwIntegdef( "PONM010" )
									EndIf
								Endif
							Endif
						Endif
					Next
				End Transaction

			Endif

		End Sequence

	Else

		aAdd( aChkAlias , "CTT" )
		aAdd( aChkAlias , "SP0" )
		aAdd( aChkAlias , "SP1" )
		aAdd( aChkAlias , "SP2" )
		aAdd( aChkAlias , "SP3" )
		aAdd( aChkAlias , "SP4" )
		aAdd( aChkAlias , "SP5" )
		aAdd( aChkAlias , "SP6" )
		aAdd( aChkAlias , "SP8" )
		aAdd( aChkAlias , "SP9" )
		aAdd( aChkAlias , "SPA" )
		aAdd( aChkAlias , "SPC" )
		aAdd( aChkAlias , "SPD" )
		aAdd( aChkAlias , "SPE" )
		aAdd( aChkAlias , "SPF" )
		aAdd( aChkAlias , "SPJ" )
		aAdd( aChkAlias , "SPK" )
		aAdd( aChkAlias , "SPM" )
		aAdd( aChkAlias , "SPW" )
		aAdd( aChkAlias , "SPY" )
		aAdd( aChkAlias , "SPZ" )
		aAdd( aChkAlias , "SR6" )
		aAdd( aChkAlias , "SR8" )
		aAdd( aChkAlias , "SRA" )
		aAdd( aChkAlias , "SRW" )
		aAdd( aChkAlias , "SX5" )

		/*/
		��������������������������������������������������������������Ŀ
		� Ponto de Entrada antes da abertura da tela inicial. CH TDVVVX�
		����������������������������������������������������������������/*/
		IF ( !lWorkFlow .and. lPnm010IniBlock )
			ExecBlock( "PNM010INI"  , .F. , .F. )
		EndIF

		/*/
		���������������������������������������������������Ŀ
		� Recupera Valores dos Parametros para Filtragem de �
		� Arquivos de Relogios.								�
		�����������������������������������������������������/*/
	    GetParam(.T., cChar)

		IF !( lWorkFlow )

			aAdd(aSays,OemToAnsi( 'Este programa tem como objetivo efetuar  a leitura do  arquivo gerado pelo' ) ) // 'Este programa tem como objetivo efetuar  a leitura do  arquivo gerado pelo'
			aAdd(aSays,OemToAnsi( 'rel�gio,  e   apontar    as    marca��es   de  acordo   com    a    tabela' ) ) // 'rel�gio,  e   apontar    as    marca��es   de  acordo   com    a    tabela'
			aAdd(aSays,OemToAnsi( 'de hor�rio  do  funcion�rio. ' ) ) // 'de hor�rio  do  funcion�rio. '

			If lPort1510
				aAdd(aButtons, {15,.T.,{|| fHistRFE() }} )
		  	EndIf

			aAdd(aButtons, { 05,.T.,{|| Pergunte( "PNM010" , .T. ), GetParam(,cChar) } } )

			/*/
			���������������������������������������������������Ŀ
			� Se MV_FILTREL for setado para "S" habilita botao  �
			� para filtro de Arquivos de Relogios.				�
			�����������������������������������������������������/*/
			If lFiltRel
		 		aAdd(aButtons, { 17,.T., {||aArqSel:={}, GetParam(, cChar), SelecRel(lWorkFlow, lUserDefParam, cProcFil, lProcFil,  @aArqSel,cTrbTmp)  } } )
	        Endif

			aAdd(aButtons, { 01,.T.,{|o| nOpcA := 1,IF( GpConfOk() , FechaBatch() , nOpcA := 0 ) } } )
			aAdd(aButtons, { 02,.T.,{|o| FechaBatch() }} )

			/*/
			��������������������������������������������������������������������Ŀ
			� Desenha a Tela para o Preenchimento dos Parametros				 �
			����������������������������������������������������������������������/*/
			FormBatch( cCadastro , aSays , aButtons )

			IF ( nOpcA == 1 )
				/*/
				��������������������������������������������������������������������Ŀ
				� Verifica se deve Mostrar Calculo de Tempo nas BarGauge			 �
				����������������������������������������������������������������������/*/
				lBarG1ShowTm := ( SuperGetMv("MV_PNSWTG1",NIL,"N") == "S" )
				lBarG2ShowTm := ( SuperGetMv("MV_PNSWTG2",NIL,"S") == "S" )
				/*/
				��������������������������������������������������������������������Ŀ
				� Executa o Processo de Leitura/Apontamento       					 �
				����������������������������������������������������������������������/*/
				Proc2BarGauge( { || Ponm010Processa(aArqSel, cChar) } , 'Leitura/Apontamento Marcacoes' , NIL , NIL , .T. , lBarG1ShowTm , lBarG2ShowTm ) // 'Leitura/Apontamento Marcacoes'
			EndIF

		Elseif lSchedDef

			/*/
			��������������������������������������������������������������������Ŀ
			� Executa o Processo de Leitura/Apontamento       					 �
			����������������������������������������������������������������������/*/
			Ponm010Processa(,cChar)

		ElseIF ( lChkAlias := RestartNotUse( aChkAlias ) )

			/*/
			�����������������������������������������������������������������������Ŀ
			� Redefine nModulo de forma a Garantir que o Modulo seja o SIGAPON		�
			�������������������������������������������������������������������������/*/
			SetModulo( "SIGAPON" , "PON" )

			/*/
			��������������������������������������������������������������������Ŀ
			� Inicializa as Static do SIGAPON                 					 �
			����������������������������������������������������������������������/*/
			PonDestroyStatic()

			/*/
			��������������������������������������������������������������������Ŀ
			� Executa o Processo de Leitura/Apontamento       					 �
			����������������������������������������������������������������������/*/
			Ponm010Processa(,cChar)

			/*/
			��������������������������������������������������������������������Ŀ
			� Fecha todos os Arquivos Abertos em RestartNotUse()				 �
			����������������������������������������������������������������������/*/
			CloseNotUse()

		EndIF
    Endif
EndIF

/*/
��������������������������������������������������������������Ŀ
� Elimina Arquivo Temporario e Indice						   �
����������������������������������������������������������������/*/
If !Empty(Select(cTrbTmp))
	dbSelectArea(cTrbTmp)
	dbCloseArea()
	If oTmpTabFO1 <> Nil
	    oTmpTabFO1:Delete()
	    Freeobj(oTmpTabFO1)
    EndIf
Endif

cFilAnt := cSvFilAnt

RestArea( aArea )

If lPn010Auto
	Return ( { Len(aLogFile) == 0 , aLogFile } )
Endif

Return( NIL )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ponm010Processa�Autor�Equipe de RH        � Data � 01/03/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realizar a Leitura e Classifica��o das Marca�oes.          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PonM010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Ponm010Processa(aArqSel, cChar)

Local aAreaSP0			:= SP0->( GetArea() )
Local aAreaSP2			:= SP2->( GetArea() )
Local aAreaSP8			:= SP8->( GetArea() )
Local aAreaSPE			:= SPE->( GetArea() )
Local aAreaSRA			:= SRA->( GetArea() )
Local aLogs		 		:= Array( 4 )
Local aLogTitle	 		:= Array( 4 )
Local aAbreArqRel		:= {}
Local aArqRelFilt		:= {}
Local aArqInd	 		:= {}
Local aGet1BarGet		:= {}
Local aGet2BarGet 		:= {}
Local aMultSRA			:= {}
Local aLogPerg			:= {}

Local bBuildDataFile	:= { || NIL }
Local bMsAguarde		:= { || NIL }

Local cArquivo			:= ""
Local cArqSrv			:= ""
Local cMarc				:= ""
Local cTipoArq			:= ""
Local cTipoArqOriginal	:= ""
Local cArqDbf	 		:= ""
Local cLstFilRel		:= "__cLstFilRel__"
Local cFlag				:= ""
Local cFilialSP0		:= ""
Local cFilAntSp0		:= "__cFilAntSp0__"
Local cAviso			:= ""
Local cMsg				:= ""

Local lBuildDataFile	:= .F.
Local lCpyT2Srv			:= .F.
Local lSP0Comp			:= FWModeAccess("SP0",1) == "C" .AND. FWModeAccess("SP0",2) == "C" .AND. FWModeAccess("SP0",3) == "C"
Local lAbreArqRel		:= .F.
Local lGetMrBySra		:= .F.
Local lRobo				:= IsInCallStack("AUTJOBRUNCT")
Local nGetMrBySra		:= 0
Local nX				:= 0
Local nPosArqRel		:= 0
Local nPosRel			:= 0
Local nHandle    		:= 0
Local nCount     		:= 0
Local nLoop				:= 0
Local nCount2     		:= 0
Local nLoop2			:= 0
Local dPerApoI			:= cToD("//")
Local dPerApoF			:= cToD("//")
Local cFilAtu			:= ""
Local lContinua			:= .F.
Local lMsBlQl			:= SP0->( FieldPos( "P0_MSBLQL" ) ) != 0
Local cTbTmpName         := ""
Static aSp8Fields
Static nSp8Fields
Static aRfeFields
Static nRfeFields
Static aMarcFields
Static nMarcFields

Private aRegsRARFE 			:= {}
Private aTabCalend 			:= {}
Private aCalendFunc			:= {}
Private aTabPadrao			:= {}
Private aLogFile   			:= {}
Private aCodigos   			:= {}
Private aRecsBarG			:= {}
Private aSemCracha 			:= {}
Private aVisitante 			:= {}
Private aTabRef				:= {}
Private aMarcNoGer			:= {}
Private bSraScope  			:= { || .F. }
Private bSraScop2  			:= { || .F. }
Private bAcessaSRA 			:= &("{ || " + ChkRH(FunName(),"SRA","2") + "}")
Private bCondDelAut			:= { || .T. }

Private cTxtAlias  			:= ""
Private cCracha    			:= ""
Private cMatricula 			:= ""
Private cFuncao    			:= ""
Private cGiro      			:= ""
Private cCusto	   			:= ""
Private cRelogio   			:= ""
Private cCCDe	   			:= ""
Private cCCAte     			:= ""
Private cTurnoDe   			:= ""
Private cTurnoAte  			:= ""
Private cMatDe     			:= ""
Private cMatAte    			:= ""
Private cNomeDe    			:= ""
Private cNomeAte   			:= ""
Private cFilOld    			:= "__cFilOld__"
Private __cSvFilAnt			:= cFilAnt
Private cFilDe	   			:= ""
Private cFilAte    			:= Space(3)
Private cRelDe     			:= ""
Private cRelAte    			:= Space(3)
Private cTimeIni			:= Time()
Private cFilTnoDe	 		:= ""
Private cFilTnoAte 			:= ""
Private cCategoria			:= ""
Private cFilTnoSRA 			:= ""
Private cFilSRA	 			:= ""
Private cAliasSP8	 		:= "SP8"
Private cQrySp8Alias		:= cAliasSP8
Private cPerAponta			:= Space( IF( ( GetSx3Cache( "P8_PAPONTA" , "X3_TAMANHO" ) == NIL ) , 16 , GetSx3Cache( "P8_PAPONTA" , "X3_TAMANHO" ) ) )
Private cSpaceRegra			:= Space( GetSx3Cache( "RA_REGRA  "	, "X3_TAMANHO" ) )
Private cP8TpMarca			:= Space( GetSx3Cache( "P8_TPMARCA" , "X3_TAMANHO" ) )
Private cP8Turno			:= Space( GetSx3Cache( "P8_TURNO  " , "X3_TAMANHO" ) )
Private cP8Ordem			:= Space( GetSx3Cache( "P8_ORDEM  " , "X3_TAMANHO" ) )
Private cSpCracha	 		:= ""
Private cSpPIS	 			:= ""
Private cSpyCracha	 		:= ""
Private cSpyVisita	 		:= ""
Private cSpyNumero	 		:= ""
Private cSpMatPrv	 		:= ""
Private cFilSP0    			:= ""
Private cFilSP9    			:= ""
Private cFilSPZ				:= ""
Private cLastFil			:= "__cLastFil__"
Private cFilTnoOld			:= "__cFilTnoOld__"
Private cFilTnoSeqOld		:= "__cFilTnoSeqOld__"
Private cFilSPE	 			:= ""
Private cFilRefAnt			:= ""
Private cDurLeitura			:= "00:00:00"
Private cDurApoClas			:= "00:00:00"
Private cIniVisita			:= ""
Private cFimVisita			:= ""
Private cDeAte     			:= ""
Private cMsgBarG1			:= ""
Private cLogFile			:= ""
Private cMsgLog				:= ""
Private cAliasCc			:= "CTT"
Private cCampoCc			:= ( PrefixoCpo( cAliasCc ) + "_CUSTO" )
Private cFilRelLid			:= ""
Private cFilRelUti			:= ""
Private cAliasRfe	 		:= "RFE"
Private cQryRfeAlias		:= cAliasRFE
Private cSituacoes 			:= ""

Private dPerDeVis			:= Ctod("//")
Private dPerAteVis			:= Ctod("//")
Private nSerIniVis
Private nSerFimVis

Private dPerIni				:= Ctod("//")
Private dPerFim				:= Ctod("//")
Private dData      			:= Ctod("//")

Private lChkPonMesAnt		:= .F.
Private lSR6Comp			:= Empty( xFilial( "SR6" ) )
Private lIncProcG1			:= .T.
Private lSraQryOpened		:= .F.
Private lCaClockIn 			:= SuperGetMv( "MV_APICLO0" , NIL , .F. )
Private lTSREP				:= SuperGetMv( "MV_TSREP" , NIL , .F. ) .Or. lCaClockIn

Private nOrdemCc			:= RetOrdem( cAliasCc , ( PrefixoCpo( cAliasCc ) + "_FILIAL" ) + "+" + cCampoCc )
Private nHora      			:= 0
Private nCountTime			:= 0
Private nCount1Time			:= 0
Private nIncPercG1			:= 0
Private nIncPercG2			:= 0
Private nLidas	 			:= 0
Private nSraLstRec	 		:= 0
Private nGravadas	 		:= 0
Private nLenPIS 			:= 0
Private nLenCracha 			:= TamSX3("RA_CRACHA")[1]
Private nLenSPYCracha 		:= TamSX3("PY_CRACHA")[1]
Private nLenSPYNumero 		:= TamSX3("PY_NUMERO")[1]
Private nLenSPYVisita 		:= TamSX3("PY_VISITA")[1]
Private nLenMatPrv 			:= Len( SPE->PE_MATPROV )
Private nReaponta	 		:= 0
Private nFuncProc			:= 0
Private nTipo      			:= 0
Private nRecsBarG			:= 0
Private nDiasExtA			:= 0
Private nDiasExtP			:= 0
Private nRecnoSRA			:= 0
Private cPerg				:= ""
Private cFilFECAux   		:= ""
Private lPn090Lock			:= .F.
Private lPonWork			:= IsInCallStack("U_PonScheduler")

If lPort1510
	nLenPIS	:= TamSX3("RFE_PIS")[1]
EndIf

/*/
�������������������������������������������������������������Ŀ
�Conteudo padrao para array de Arquivos de Marcacoes Filtrados�
�conforme parametro MV_FiltRel. Nao eh valido para WorkFlow   �
���������������������������������������������������������������/*/
DEFAULT aArqSel				:= {}

Private lSp8QryOpened := .F.

DEFAULT aSp8Fields		:= ( cAliasSP8 )->( dbStruct() )
DEFAULT nSp8Fields 		:= Len( aSp8Fields )

/*/
�������������������������������������������������������������Ŀ
�Carrega os MV_'s do SX6 para Variaveis do Sistema            �
���������������������������������������������������������������/*/
cIniVisita	:= SuperGetMv("MV_VISIINI")
cFimVisita	:= SuperGetMv("MV_VISIFIM")
cIniVisita	:= IF( cIniVisita==NIL, Replicate("Z",nLenCracha), Substr(Alltrim(cIniVisita),1,nLenCracha)  )
cFimVisita	:= IF( cFimVisita==NIL, Replicate("Z",nLenCracha), Substr(Alltrim(cFimVisita),1,nLenCracha) )
cSpCracha	:= Space( nLenCracha )
cSpPIS 		:= Space( nLenPIS )
cSpyCracha	:= Space( nLenSPYCracha )
cSpyNumero	:= Space( nLenSPYNumero )
cSpyVisita	:= Space( nLenSPYVisita )
cSpMatPrv	:= Space( nLenMatPrv )

nDiasExtA 	:= Min(Abs( SuperGetMv( "MV_GETDIAA" , NIL , 2  , cFilAnt ) ), 7)	//-- Quantidade de Dias a ser considerada antes do inicio do Periodo de  Apontamento a ser considerada na Leitura/Apontamento
nDiasExtP 	:= Min(Abs( SuperGetMv( "MV_GETDIAP" , NIL , 2  , cFilAnt ) ), 7)	//-- Quantidade de Dias a ser considerada apos  o fim do Periodo de  Apontamento a ser considerada na Leitura/Apontamento
cFilRelUti	:= If( !Empty( SuperGetMv("MV_PM010LA",,"N") ), SuperGetMv("MV_PM010LA"), "N" )
/*/
��������������������������������������������������������������Ŀ
� Setando as Perguntas que serao utilizadas no Programa        �
����������������������������������������������������������������/*/
If !lSchedDef
	Pergunte( "PNM010" , .F. )
	If lWorkFlow .And. !lUserDefParam
		If !Empty(dDtIniWf)
			dPerIni := dDtIniWf
			dPerFim := dDtFimWf
		ElseIf !PerAponta( @dPerIni , @dPerFim , Nil , .F. )
			dPerIni := Ctod("//")
			dPerFim := Ctod("//")
		EndIf
	EndIf
	If FindFunction("RetPergLog")
		RetPergLog(aLogPerg, "PNM010")
	EndIf
Endif


/*/
��������������������������������������������������������������Ŀ
� Carregando as Perguntas                                      �
����������������������������������������������������������������/*/
cFilDe    := IF( lWorkFlow .and. lUserDefParam .and. !lProcFilial , mv_par01 , IF( !lWorkFlow .or. lSchedDef , mv_par01 , IF( lProcFilial , xFilial("SP0", cFilAnt) , Space(FwGetTamFilial) ) ) )								//Filial De
cFilAte   := IF( lWorkFlow .and. lUserDefParam .and. !lProcFilial , mv_par02 , IF( !lWorkFlow .or. lSchedDef , mv_par02 , IF( lProcFilial , cFilAnt , Replicate(cChar,Len(SRA->RA_FILIAL) ) ) ) )								//Filial Ate
cCCDe     := IF( lWorkFlow .and. lUserDefParam , mv_par03 , IF( !lWorkFlow .or. lSchedDef , mv_par03 , ""	) )																													//Centro de Custo De
cCCAte    := IF( lWorkFlow .and. lUserDefParam , mv_par04 , IF( !lWorkFlow .or. lSchedDef , mv_par04 , Replicate(cChar,Len(SRA->RA_CC) )	) )																					//Centro de Custo Ate
cTurnoDe  := IF( lWorkFlow .and. lUserDefParam , mv_par05 , IF( !lWorkFlow .or. lSchedDef , mv_par05 , ""	) )																													//Turno De
cTurnoAte := IF( lWorkFlow .and. lUserDefParam , mv_par06 , IF( !lWorkFlow .or. lSchedDef , mv_par06 , Replicate(cChar,Len(SRA->RA_TNOTRAB) ) ) )																				//Turno Ate
cMatDe    := IF( lWorkFlow .and. lUserDefParam , mv_par07 , IF( !lWorkFlow .or. lSchedDef , mv_par07 , ""  ) )																													//Matricula De
cMatAte   := IF( lWorkFlow .and. lUserDefParam , mv_par08 , IF( !lWorkFlow .or. lSchedDef , mv_par08 , Replicate(cChar,Len(SRA->RA_MAT) ) ) )																					//Matricula Ate
cNomeDe   := IF( lWorkFlow .and. lUserDefParam , mv_par09 , IF( !lWorkFlow .or. lSchedDef , mv_par09 , ""	) )																													//Nome De
cNomeAte  := IF( lWorkFlow .and. lUserDefParam , mv_par10 , IF( !lWorkFlow .or. lSchedDef , mv_par10 , Replicate(cChar,Len(SRA->RA_NOME) ) ) )																					//Nome Ate
cRelDe    := IF( lWorkFlow .and. lUserDefParam , mv_par11 , IF( !lWorkFlow .or. lSchedDef , mv_par11 , ""	) )																													//Relogio De
cRelAte   := IF( lWorkFlow .and. lUserDefParam , mv_par12 , IF( !lWorkFlow .or. lSchedDef , mv_par12 , Replicate(cChar,Len(SP0->P0_RELOGIO) ) ) )																				//Relogio Ate
dPerDe 	  := IF( lWorkFlow .and. lUserDefParam , mv_par13 , IF( !lWorkFlow .or. lSchedDef , mv_par13 , dPerIni	) )																												//Periodo De
dPerAte	  := IF( lWorkFlow .and. lUserDefParam , IF( lLimitaDataFim , Min( dDataBase , mv_par14 ) , mv_par14 )  , IF( !lWorkFlow .or. lSchedDef , mv_par14 , IF( lLimitaDataFim , Min( dDataBase , dPerFim ) , dPerFim ) ) )	//Periodo Ate
cRegDe 	  := IF( lWorkFlow .and. lUserDefParam , mv_par15 , IF( !lWorkFlow .or. lSchedDef , mv_par15 , ""	) )																													//Regra De
cRegAte	  := IF( lWorkFlow .and. lUserDefParam , mv_par16 , IF( !lWorkFlow .or. lSchedDef , mv_par16 , Replicate(cChar,Len(SRA->RA_REGRA) ) ) )																				//Regra Ate
nTipo     := IF( lWorkFlow .and. lUserDefParam , mv_par17 , IF( !lWorkFlow .or. lSchedDef , mv_par17 , nProcessa	) )																													//Tipo de Processamento 1=Leitura 2=Apontamento 3=Ambos
nAponta	  := IF( lWorkFlow .and. lUserDefParam , mv_par18 , IF( !lWorkFlow .or. lSchedDef , mv_par18 , 4	) )																													//Leitura/Apontamento 1=Marcacoes 2=Refeicoes 3=Acesso 4=Marcacoes e Refeicoes 5=Todos
nReaponta := IF( lWorkFlow .and. lUserDefParam , mv_par19 , IF( !lWorkFlow .or. lSchedDef , mv_par19 , IF( lForceReaponta , 3 , 4 ) ) )																						//Reapontar 1= Marcacoes 2=Refeicoes 3=Ambos 4=Nenhum
nGetMrBySra:= IF( lWorkFlow .and. lUserDefParam , mv_par20 , IF( !lWorkFlow .or. lSchedDef , mv_par20 , nTipoRel )  )																						//Reapontar 1= Marcacoes 2=Refeicoes 3=Ambos 4=Nenhum
cCategoria := IF( lWorkFlow .and. lUserDefParam , mv_par21 , IF( !lWorkFlow .or. lSchedDef , mv_par21 , "ACDEGHMPST"	) )																				//Categorias
cSituacoes := IF( lWorkFlow .and. lUserDefParam , mv_par22 , IF( !lWorkFlow .or. lSchedDef , mv_par22 , " ADFT"	) )																				//Situa��es

If lWorkFlow .and. !lUserDefParam .and. Empty(dPerDe) .and. !lSchedDef
	If !GetPonMesDat( @dPerDe , @dPerAte , cFilProc )
		Return Nil
	EndIf
EndIf

If lSP0Comp //Se rel�gio for compartilhado, verifica se fechamento esta sendo efetuado
	If !Pn090Open(@cMsg, @cAviso,.T.,DtoS(dPerDe) + DtoS(dPerAte),.T.,,,"A")
		If !lWorkFlow
			MsgStop( cMsg, cAviso )
		Else
			ConOut("")
			ConOut( cAviso )
			ConOut( cMsg )
			ConOut("")
		EndIf
		Return Nil
	EndIf
EndIf

/*/
��������������������������������������������������������������Ŀ
� Verifica o Tipo de Controle                              	   �
����������������������������������������������������������������/*/
lGetMrBySra:= If( nGetMrBySra == 1, .T., .F. )

/*/
��������������������������������������������������������������Ŀ
� Inicializa Filial/Turno De/Ate							   �
����������������������������������������������������������������/*/
cFilTnoDe	:= ( cFilDe + cTurnoDe )
cFilTnoAte	:= ( cFilAte + cTurnoAte )

/*/
��������������������������������������������������������������Ŀ
� Cria o Bloco dos Funcionarios que atendam ao Scopo	   	   �
����������������������������������������������������������������/*/
bSraScope := { || (;
						( RA_TNOTRAB	>= cTurnoDe	) .and. ( RA_TNOTRAB	<= cTurnoAte	) .and. ;
						( RA_FILIAL		>= cFilde	) .and. ( RA_FILIAL		<= cFilAte		) .and. ;
						( RA_NOME		>= cNomeDe	) .and. ( RA_NOME		<= cNomeAte		) .and. ;
						( RA_MAT		>= cMatDe	) .and. ( RA_MAT		<= cMatAte		) .and. ;
						( RA_CC			>= cCCDe	) .and. ( RA_CC			<= cCCAte		) .and. ;
						( RA_REGRA		>= cRegDe	) .and. ( RA_REGRA		<= cRegAte		) .and. ;
						( RA_REGRA <> cSpaceRegra	) .and. ( RA_CATFUNC $ cCategoria ) .and. ;
						( RA_SITFOLH $ cSituacoes );
					  );
		     }
bSraScop2 := { || (;
						( RA_TNOTRAB	>= cTurnoDe	) .and. ( RA_TNOTRAB	<= cTurnoAte	) .and. ;
						( RA_NOME		>= cNomeDe	) .and. ( RA_NOME		<= cNomeAte		) .and. ;
						( RA_MAT		>= cMatDe	) .and. ( RA_MAT		<= cMatAte		) .and. ;
						( RA_CC			>= cCCDe	) .and. ( RA_CC			<= cCCAte		) .and. ;
						( RA_REGRA		>= cRegDe	) .and. ( RA_REGRA		<= cRegAte		) .and. ;
						( RA_REGRA <> cSpaceRegra	) .and. ( RA_CATFUNC $ cCategoria ) .and. ;
						( RA_SITFOLH $ cSituacoes );
					  );
		     }

/*/
��������������������������������������������������������������Ŀ
� Carrega Log do Inicio do Processo de Leitura/Apontamento     �
����������������������������������������������������������������/*/
aAdd(aLogFile, '- Inicio da Leitura/Apontamento em '  + Dtoc(MsDate()) + ', as ' + Time() + '.') // '- Inicio da Leitura/Apontamento em '

Begin Sequence

	/*/
	��������������������������������������������������������������Ŀ
	� Verifica o Tipo de Controle                              	   �
	����������������������������������������������������������������/*/
	IF nGetMrBySra == 1 .and. nAponta = 3
		aAdd(aLogFile, '*** ATENCAO: LEITURA NAO CONCLUIDA ***' )// '*** ATENCAO: LEITURA NAO CONCLUIDA ***'
		aAdd(aLogFile, '- '+'- Para o Controle de Acesso, a Leitura deve ser feita a apartir do Cad.Rel�gios.' )//'- Para o Controle de Acesso, a Leitura deve ser feita a apartir do Cad.Rel�gios.'
		Break
	ENDIF

	/*/
	��������������������������������������������������������������Ŀ
	� >>				Se Leitura ou Ambos			  			<< �
	����������������������������������������������������������������/*/
	IF ( ( nTipo == 1 ) .or. ( nTipo == 3 ) )

		/*/
		��������������������������������������������������������������Ŀ
		� Define o Bloco para a MsAguarde()                            �
		����������������������������������������������������������������/*/
		bMsAguarde		:= { ||;
									lBuildDataFile := SP0BldData(;
																	@cTipoArq,;
																	IF( !Empty( cArqSrv ) , cArqSrv , cArquivo ),;
																	@cArqDbf,;
																	@aArqInd,;
																	@cTxtAlias,;
																	@aLogFile,;
																	dPerDe	,;
																	dPerAte	,;
																	nDiasExtA,;
																	nDiasExtP,;
																	.F.,;
																	lWorkFlow,;
																	cArquivo;
																),;
									dbSelectArea( "SP0" );
							}

		/*/
		��������������������������������������������������������������Ŀ
		� Define o Bloco para a Criacao do .DBF a partir do .TXT       �
		����������������������������������������������������������������/*/
		bBuildDataFile	:= { ||	IF( lWorkFlow ,;
								( Eval( bMsAguarde ) ),;
								MsAguarde( bMsAguarde , OemToAnsi( "Carregando Marca��es. " + "Aguarde..."  ) , If(SP0->P0_TIPOARQ="R",IIf(lCaClockIn,"Carregando Marca��es. ","Aguarde..."),Lower( cArquivo )) );//"Carregando Marca��es. "###"Aguarde..." ### Arquivo de Integracao Carol Clock in...  ### "Arquivo de Integracao TSA..."
							   ),;
							lBuildDataFile;
			 	   			}

		/*/
		��������������������������������������������������������������Ŀ
		� Carrega Log do Inicio do Processo de Leitura                 �
		����������������������������������������������������������������/*/
		cMsgLog := ( '- Inicio da Leitura em '  + Dtoc(MsDate()) + ', as ' + Time() + '.' ) // '- Inicio da Leitura em '
		aAdd( aLogFile , cMsgLog )
		IF lWorkFlow .And. !lRobo
			/*/
			�����������������������������������������������������������������������Ŀ
			� Enviando Mensagens para o Console do Server                 			�
			�������������������������������������������������������������������������/*/
			ConOut("")
			ConOut( cMsgLog )
			ConOut("")
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Inicializa as Ordens para Leitura                            �
		����������������������������������������������������������������/*/
		SP0->( dbSetOrder( RetOrdem( "SP0" , "P0_FILIAL+P0_RELOGIO" ) ) )								//-- Rel�gios
	    SPY->( dbSetOrder( RetOrdem( "SPY" , "PY_FILIAL+PY_CRACHA+DTOS(PY_DTVISIT)+PY_NUMERO" ) ) )				//-- Visitas
	    SPZ->( dbSetOrder( RetOrdem( "SPZ" , "PZ_FILIAL+PZ_CRACHA+DTOS(PZ_DATA)" ) ) )							//-- Marcacoes de Visitas (Cracha  + Data da Marcacao)

		/*/
		��������������������������������������������������������������Ŀ
		� Monta Filtro para Validacao do Relogio a ser Lido            �
		����������������������������������������������������������������/*/
		cFilSP0 := IF( Len(Alltrim( xFilial("SP0"))) > 0, cFilDe , Space(FwGetTamFilial) )
		cDeAte  := IF( lSP0Comp ,"P0_RELOGIO<=cRelAte","P0_FILIAL+P0_RELOGIO<=cFilAte+cRelAte")

		/*/
		��������������������������������������������������������������Ŀ
		� Obtem Filial das Marcacoes de Acessos				           �
		����������������������������������������������������������������/*/
		cFilSPZ := xFilial("SPZ", cFilSP0)


		/*/
		��������������������������������������������������������������Ŀ
		� Posiciona no Relogio de Acordo com os Parametros do usuario  �
		����������������������������������������������������������������/*/
		SP0->( MsSeek( cFilSP0 + cRelDe , .T. ) )

		IF !( lWorkFlow )
			/*/
			��������������������������������������������������������������Ŀ
			� Inicializa Mensagem na 2a BarGauge                           �
			����������������������������������������������������������������/*/
			IncProcG2( 'Lendo...' , .F. ) //'Lendo...'
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Percorre todos os Relogios para Leitura                      �
		����������������������������������������������������������������/*/
		While SP0->( !Eof() .and. &( cDeAte ) )

			If lMsBlQl .And. SP0->P0_MSBLQL == '1'
				SP0->( dbSkip() )
				Loop
			EndIf

			If lPort1510
				IF !(SP0->P0_INC $"1.2")  //--Relogio sem configuracao
					aAdd(aLogFile, "No cadastro de rel�gios, informe se o arquivo de marca��es � incrementado ou n�o. Filial: " + Space(1) + SP0->P0_RELOGIO) //"No cadastro de rel�gios, informe se o arquivo de marca��es � incrementado ou n�o. Filial: "  + xFilial("SP0") + 	"No cadastro de rel�gios, informe se o arquivo de marca��es � incrementado ou n�o. Filial: " + Space(1) + SP0->P0_RELOGIO) //"No cadastro de rel�gios, informe se o arquivo de marca��es � incrementado ou n�o. Filial: "##"Rel�gio:"##
					SP0->( dbSkip() )
				    Loop
				Else
					If ( !(Empty(SP0->P0_REP)) .AND. (SP0->P0_INC == '2') )
						aAdd(aLogFile, " - " + 'O tipo do rel�gio: '  + xFilial("SP0") + Space(1) + SP0->P0_RELOGIO + 'deve ser incremental. Corrija o cadastro.') //"O tipo do rel�gio: xxx # deve ser incremental. Corrija o cadastro.
						SP0->( dbSkip() )
						Loop
					EndIf
				EndIF
			EndIf

			/*/
			��������������������������������������������������������������Ŀ
			� Incrementa Contador de Tempos                      		   �
			����������������������������������������������������������������/*/
			++nCountTime

			/*/
			��������������������������������������������������������������Ŀ
			� Seta filial corrente do rel�gio lido se param. igual S	   �
			����������������������������������������������������������������/*/
			cFilRelLid := If ( cFilRelUti == "S" .and. ( Len(Alltrim( xFilial("SP0") ) ) > 0 ), SP0->P0_FILIAL, "" )

			/*/
			��������������������������������������������������������������Ŀ
			� Atualiza a Mensagem para a IncProcG1() ( Relogio )		   �
			����������������������������������������������������������������/*/
			IF !( lWorkFlow )
				/*/
				��������������������������������������������������������������Ŀ
				� Atualiza a Mensagem para a BarGauge do Relogio			   �
				����������������������������������������������������������������/*/
				IF !( lSP0Comp )
					//'Filial:'###'Relogio:'
					cMsgBarG1 := SP0->( 'Filial:' + " " + P0_FILIAL + " / " + 'Relogio:' + " " + P0_RELOGIO + " - " + P0_DESC )
				Else
					//'Relogio:'
					cMsgBarG1 := SP0->( 'Relogio:' + " " + P0_RELOGIO + " - " + P0_DESC )
		    	EndIF
				/*/
				��������������������������������������������������������������Ŀ
				� Obtem o % de Incremento da  BarGauge					   	   �
				����������������������������������������������������������������/*/
				IF !( cLstFilRel == SP0->P0_FILIAL )
					cLstFilRel := SP0->P0_FILIAL
					/*/
					��������������������������������������������������������������Ŀ
					� 1a. BarGauge                         				   	       �
					����������������������������������������������������������������/*/
					nIncPercG1 := SuperGetMv( "MV_PONINC1" , NIL , 5 , SP0->P0_FILIAL )
					/*/
					��������������������������������������������������������������Ŀ
					� 2a. BarGauge                         				   	       �
					����������������������������������������������������������������/*/
					nIncPercG2 := SuperGetMv( "MV_PONINCP" , NIL , 5 , SP0->P0_FILIAL )
					/*/
					��������������������������������������������������������������Ŀ
					� Realimenta a Barra de Gauge para os Relogios       		   �
					����������������������������������������������������������������/*/
					IF ( !( lSP0Comp ) .or. ( nRecsBarG == 0 ) )
						aRecsBarG := {}
						//CREATE SCOPE aRecsBarG FOR ( P0_FILIAL == cLstFilRel .or. Len(Alltrim(P0_FILIAL)) = 0)
						nRecsBarG := SP0->( ScopeCount( aRecsBarG ) )
					EndIF
					/*/
					��������������������������������������������������������������Ŀ
					� Define o Contador para o Processo 1                          �
					����������������������������������������������������������������/*/
					--nCount1Time
					/*/
					��������������������������������������������������������������Ŀ
					� Define o Numero de Elementos da BarGauge                     �
					����������������������������������������������������������������/*/
					BarGauge1Set( nRecsBarG )
					/*/
					��������������������������������������������������������������Ŀ
					� Inicializa Mensagem na 1a BarGauge                           �
					����������������������������������������������������������������/*/
					IncProcG1( cMsgBarG1 , .F. )
				EndIF
				/*/
				��������������������������������������������������������������Ŀ
				� Incrementa a BarGauge do Relogio                             �
				����������������������������������������������������������������/*/
		    	IncPrcG1Time( cMsgBarG1 , nRecsBarG , cTimeIni , .F. , nCount1Time , nIncPercG1 )
		    EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Le Somente os Relogios Selecionados                          �
			����������������������������������������������������������������/*/
	        //-- Verifica se relogio esta entre os filtrados
	        nPosRel:= 0
	        If !(lWorkFlow) .AND. lFiltRel .AND.!Empty(aArqSel)
	           If Empty((nPosRel:=Ascan(aArqSel,{|x |x[1] == SP0->(P0_FILIAL+P0_RELOGIO) } ) ))
		          SP0->( dbSkip() )
				  Loop
			   EndIF
	        Else
		        IF SP0->(	( P0_FILIAL  < cFilSP0 ) .or. ( P0_FILIAL  > cFilAte ) .or. ;
				    		( P0_RELOGIO < cRelDe  ) .or. ( P0_RELOGIO > cRelAte ) )
					SP0->( dbSkip() )
				    Loop
				EndIF
			Endif

			/*/
			��������������������������������������������������������������Ŀ
			� Verifica o Tipo de Leitura a Ser Feita                       �
			����������������������������������������������������������������/*/
	        IF !( nAponta == 5 )
	        	IF SP0->(;
	        				( ( nAponta == 1 ) .and. ( P0_CONTROL $ "R.A" ) );
	        				.or.;
	        				( ( nAponta == 2 ) .and. ( P0_CONTROL $ "P.A" ) );
	        				.or.;
				   			( ( nAponta == 3 ) .and. ( P0_CONTROL $ "R.P" ) );
				   			.or.;
				   			( ( nAponta == 4 ) .and. ( P0_CONTROL $ "A"   ) );
				   		)
	        		SP0->( dbSkip() )
			    	Loop
			    EndIF
			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Abandona o Processamento									   �
			����������������������������������������������������������������/*/
			IF ( lAbortPrint )
				aAdd(aLogFile, '- Cancelado pelo Operador em '  + Dtoc(MsDate()) + ', as ' + Time() + ' ...') // '- Cancelado pelo Operador em '
				Break
			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Carrega a configura��o b�sica do rel�gio ( cabe�alho ).      �
			����������������������������������������������������������������/*/
			cFilialSp0		:= SP0->P0_FILIAL
			cRelogio  		:= AllTrim( SP0->P0_RELOGIO )
			cTipoArq  		:= SP0->P0_TIPOARQ
			cTipoArqOriginal:=cTipoArq
			cControle 		:= SP0->P0_CONTROL

			If cFilialSP0 != cFilAntSp0
				cFilAntSp0 := cFilialSP0
				If !GetPonMesDat( @dPerIni , @dPerFim , cFilialSP0 )
					dPerIni := dPerDe
					dPerFim	:= dPerAte
				EndIf
			EndIf

			/*/
			�������������������������������������������������������������Ŀ
			� Se o controle da Leitura/Apontamento for pelo Cadastro de   �
			� relogios identifica o tipo do mesmo. 					      �
			���������������������������������������������������������������/*/
			If !lGetMrBySra

				If cControle == "A"
					/*/
					�������������������������������������������������������������Ŀ
					� Para controle de Acesso de Visitantes Seta o Periodo        �
					� conforme pergunte.									      �
					���������������������������������������������������������������/*/

					dPerDeVis 	:= IF( lWorkFlow .and. lUserDefParam , mv_par13 , IF( !lWorkFlow .or. lSchedDef , mv_par13 , dPerIni	) )																												//Periodo De
					dPerAteVis	:= IF( lWorkFlow .and. lUserDefParam , IF( lLimitaDataFim , Min( dDataBase , mv_par14 ) , mv_par14 )  , IF( !lWorkFlow .or. lSchedDef , mv_par14 , IF( lLimitaDataFim , Min( dDataBase , mv_par14 ) , mv_par14 ) ) )	//Periodo Ate

					nSerIniVis 	:= Round( __fDhtoNS( dPerDeVis	,00.00 )  , 5 )
					nSerFimVis 	:= Round( __fDhtoNS( dPerAteVis	,23.59 )  , 5 )
			    Endif
			Endif

			/*/
			��������������������������������������������������������������Ŀ
			� Trata a Selecao de Arquivos de Marcacoes a serem lidos       �
			����������������������������������������������������������������/*/
			If !(lWorkFlow) .AND. lFiltRel .AND.!Empty(aArqSel)
			   aArqRelFilt:= aClone( aArqSel[nPosRel,2] )
			Else
			   aArqRelFilt:= {SP0->P0_ARQUIVO}
			Endif
            //-- Corre cada Arquivo de Marcacoes para cada Relogio Lido
		    For nLoop:= 1 To Len(aArqRelFilt)
				cArquivo  := AllTrim( aArqRelFilt[nLoop] )

	            /*/
				��������������������������������������������������������������Ŀ
				� Recupera o valor original do Tipo de Arquivo alterado pela   �
				� funcao SP0BldData()										   �
				����������������������������������������������������������������/*/
	            cTipoArq := cTipoArqOriginal

				/*/
				��������������������������������������������������������������Ŀ
				� Nao Abre arquivos com D'river quando processo via WorkFlow    �
				����������������������������������������������������������������/*/
				IF ( lWorkFlow )
					IF ( At( ":" , cArquivo ) > 0 )
						Conout('Arquivo'  + AllTrim(cArquivo) + ' nao pode ser aberto e sera ignorado.')
						Conout(aLogFile, '  Verifique a existencia do arquivo e a configuracao do Relogio '  + AllTrim(cRelogio))
						aAdd(aLogFile, '- O arquivo '  + AllTrim(cArquivo) + ' nao pode ser aberto e sera ignorado.' )	// '- O arquivo '###' nao pode ser aberto e sera ignorado.'
						aAdd(aLogFile, '  Verifique a existencia do arquivo e a configuracao do Relogio '  + AllTrim(cRelogio))			// '  Verifique a existencia do arquivo e a configuracao do Relogio '
						Loop
					EndIF
				EndIF

				/*/
				��������������������������������������������������������������Ŀ
				� Tenta abrir o arquivo gerado pelo rel�gio                    �
				����������������������������������������������������������������/*/
				IF !( lAbreArqRel := AbreArqRel( cTipoArq , cArquivo , @nHandle , .F. , .F. , @cArqSrv , @lCpyT2Srv ) )
					If GetRemoteType() == 5 .Or. SubStr(cArquivo,1,1) != "\"
						aAdd(aLogFile, "- Durante a utiliza��o do WebApp, arquivos que est�o fora da pasta Protheus_Data n�o ser�o lidos.") // "- Durante a utiliza��o do WebApp, arquivos que est�o fora da pasta Protheus_Data n�o ser�o lidos."
						aAdd(aLogFile, "- Por favor coloque o arquivo do rel�gio dentro da pasta Protheus_Data e altere o cadastro do rel�gio") // "- Por favor coloque o arquivo do rel�gio dentro da pasta Protheus_Data e altere o cadastro do rel�gio"
						aAdd(aLogFile, "- ou execute a rotina pelo Smartclient.") // "- ou execute a rotina pelo Smartclient."
						aAdd(aLogFile, "- " + "- Relogio: " + " " + AllTrim( cRelogio ) ) // "- Relogio: "
					Else
						aAdd(aLogFile, '- O arquivo '  + AllTrim(cArquivo) + ' nao pode ser aberto e sera ignorado.' ) // '- O arquivo '###' nao pode ser aberto e sera ignorado.'
						aAdd(aLogFile, '- O arquivo '  + AllTrim(cArquivo) + ' nao pode ser aberto e sera ignorado.' ) // '- O arquivo '###' nao pode ser aberto e sera ignorado.'
						aAdd(aLogFile, '  Verifique a existencia do arquivo e a configuracao do Relogio '  + AllTrim(cRelogio))			// '  Verifique a existencia do arquivo e a configuracao do Relogio '
					EndIf
					IF ( cTipoArq == "D" ) //-- Fecha o Arquivo atualmente aberto
						TxtAliasClose( @cTxtAlias )
					Else
						IF ( nHandle > 0 )
							fClose(nHandle)
						EndIF
					EndIF
					Loop
				Else
					IF ( ( nPosArqRel := aScan( aAbreArqRel , { |x| x[1] == cFilAnt } ) ) == 0 )
						aAdd( aAbreArqRel , { cFilAnt , SP0->P0_FILIAL  , { cArquivo } } )
					Else
						aAdd( aAbreArqRel[ nPosArqRel , 03 ] , cArquivo )
					EndIF
				EndIF

				/*/
				��������������������������������������������������������������Ŀ
				� Verifica se o Arquivo foi Aberto                             �
				����������������������������������������������������������������/*/
				IF ( cTipoArq == "T" )
					IF ( nHandle <= 0 )
						aAdd(aLogFile, '- O arquivo '  + AllTrim(cArquivo) + ' nao pode ser aberto e sera ignorado.' )	// '- O arquivo '###' nao pode ser aberto e sera ignorado.'
						aAdd(aLogFile, '  Verifique a existencia do arquivo e a configuracao do Relogio '  + AllTrim(cRelogio))			// '  Verifique a existencia do arquivo e a configuracao do Relogio '
						Loop
					Else
						fClose( nHandle )
					EndIF
				EndIF

				/*/
				��������������������������������������������������������������Ŀ
				� Converte o Arquivo                                       	   �
				����������������������������������������������������������������/*/
				IF !Eval( bBuildDataFile )
					Loop
				EndIF

				/*/
				�������������������������������������������������������������Ŀ
				� Salva as Informacoes das Barras de Processamento		  	  �
				���������������������������������������������������������������/*/
				IF !( lWorkFlow )
					aGet1BarGet := Get1BarSet()
					aGet2BarGet := Get2BarSet()
				EndIF

				//Se portaria estiver ativa utiliza tabela RFE ao inv�s do arquivo temporario
				If lPort1510
					cTxtAlias := "RFE"
				EndIf

				/*/
				��������������������������������������������������������������Ŀ
				� Carregando as Marcacoes                                  	   �
				����������������������������������������������������������������/*/
				IF ( lGetMrBySra )
	               	GetMrBySra()
				Else
		           	GetMrBySp0()
				EndIF

				If ( lPort1510 )
					If SP0->P0_INC == '2' .And. SP0->P0_TIPOARQ != "R"
						// Se relogio nao incremental e nao TSA
						/*/
						�����������������������������������������������������������������Ŀ
						|Deleta marcacoes copiadas para RFE que nao foram classificadas.  |
						|Rotina necessaria pois quando o arquivo nao e incremental, se a  |
						|leitura for feita somente para um funcionario, todos os registros|
						|do TXT sao gravados na RFE, pois nao e feita consistencia dos    |
						|parametros informados no PONM010 no PONA030, isto ocasionava     |
						|marcacoes duplicadas na proxima leitura, no caso do mesmo TXT    |
						|ser lido, mas com parametros de branco a ZZZZZZ na matricula     |
						|por exemplo.													  |
						�������������������������������������������������������������������/*/
						fDelRFE(SP0->P0_FILIAL, SP0->P0_RELOGIO)
					EndIf
				EndIf

				/*/
				�������������������������������������������������������������Ŀ
				� Restaura as Informacoes das Barras de Processamento		  �
				���������������������������������������������������������������/*/
				IF !( lWorkFlow )
					Rst1BarSet( aGet1BarGet )
					Rst2BarSet( aGet2BarGet )
				EndIF

				/*/
				�������������������������������������������������������������Ŀ
				� Fecha e Exclui os Arquivos Temporarios					  �
				���������������������������������������������������������������/*/
				CloseTxtAlias( cTxtAlias , cArqDbf , aArqInd , lCpyT2Srv , cArqSrv , cArquivo )

		    Next

			/*/
			�������������������������������������������������������������Ŀ
			� Posiciona no Proximo Relogio                                �
			���������������������������������������������������������������/*/
			SP0->( dbSkip() )

		EndDo

		/*/
		�������������������������������������������������������������Ŀ
		� Gera o Log de Final de Leitura e Calcula o Tempo            �
		���������������������������������������������������������������/*/
		cDurLeitura := FinalLeitura( @aLogFile, nLidas, nGravadas, lWorkFlow, lRobo )

		/*/
		�������������������������������������������������������������Ŀ
		� Reinicializa Variaveis da BarGauge1                         �
		���������������������������������������������������������������/*/
		aRecsBarG	:= {}
		nRecsBarG	:= 0

	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	�Se for WorkFlow e nao Conseguiu Abrir os Arquivos para Leitura�
	�nao Efetua o Apontamento									   �
	����������������������������������������������������������������/*/
	IF ( ( lWorkFlow ) .and. ( lProcFilial ) .and.  !( lApontaNaoLidas ) )
		/*/
		��������������������������������������������������������������Ŀ
		�Se nTipo for Leitura ou Leitura e Apontamento, Nao efetua    a�
		�Classificacao/Apontamento para Filiais nao Lidas			   �
		����������������������������������������������������������������/*/
		IF ( ( nTipo == 1 ) .or. ( nTipo == 3 ) )
			IF !( lAbreArqRel := ( aScan( aAbreArqRel , { |x| x[1] == cFilAnt } ) > 0 ) )
				cMsgLog := ( '- Nao foi encontrado arquivo do Relogio para a filial: ' )		//'- Nao foi encontrado arquivo do Relogio para a filial: '
				aAdd( aLogFile , cMsgLog )
				IF ( lWorkFlow )
					/*/
					�����������������������������������������������������������������������Ŀ
					� Enviando Mensagens para o Console do Server                 			�
					�������������������������������������������������������������������������/*/
					ConOut("")
					ConOut( cMsgLog )
					ConOut("")
				EndIF
				cMsgLog := ( '- As marcacoes dessa filial nao foram apontadas.' )		//'- As marcacoes dessa filial nao foram apontadas.'
				aAdd( aLogFile , cMsgLog )
				IF ( lWorkFlow )
					/*/
					�����������������������������������������������������������������������Ŀ
					� Enviando Mensagens para o Console do Server                 			�
					�������������������������������������������������������������������������/*/
					ConOut("")
					ConOut( cMsgLog )
					ConOut("")
				EndIF
				Break
			EndIF
		EndIF
	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	� Abandona o Processamento									   �
	����������������������������������������������������������������/*/
	IF ( lAbortPrint )
		aAdd(aLogFile, '- Cancelado pelo Operador em '  + Dtoc(MsDate()) + ', as ' + Time() + ' ...') // '- Cancelado pelo Operador em '
		Break
	EndIF

	/*/
	�������������������������������������������������������������Ŀ
	� Para Leitura de Marcacoes de Acessos Nao Prossegue.	      �
	���������������������������������������������������������������/*/
	IF ( nAponta == 3 )
	   Break
	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	� Log ao Inicio da Classificacao/Apontamento				   �
	����������������������������������������������������������������/*/
	IF ( nTipo == 1 )
		cMsgLog := ( '- Inicio da Classificacao em ' + Dtoc(MsDate()) + ', as ' + Time() + '.' )	//'- Inicio da Classificacao em '
		aAdd(aLogFile, cMsgLog )
	ElseIF ( ( nTipo == 2 ) .or. ( nTipo == 3 ) )
		cMsgLog := ( '- Inicio da Classificacao/Apontamento em ' + Dtoc(MsDate()) + ', as ' + Time() + '.' )	//'- Inicio da Classificacao/Apontamento em '
		aAdd(aLogFile, cMsgLog )
	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	� >>  		Classifica��o e/ou Apontamento                	<< �
	����������������������������������������������������������������/*/
	IF lWorkFlow .And. !lRobo
		/*/
		�����������������������������������������������������������������������Ŀ
		� Enviando Mensagens para o Console do Server                 			�
		�������������������������������������������������������������������������/*/
		ConOut("")
		ConOut( cMsgLog )
		ConOut("")
	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	� Inicializa as Ordens para a Classifica��o/Apontamento        �
	����������������������������������������������������������������/*/
	SP8->( dbSetOrder( RetOrdem( "SP8" , "P8_FILIAL+P8_MAT+DTOS(P8_DATA)+STR(P8_HORA,5,2)" ) ) )	//-- Marca��es
	SPF->( dbSetOrder( RetOrdem( "SPF" , "PF_FILIAL+PF_MAT+DtoS(PF_DATA)" ) ) )						//-- Altera��es de Turno

	/*/
	��������������������������������������������������������������Ŀ
	� Seleciona Informacoes dos Funcionarios                       �
	����������������������������������������������������������������/*/
	IF !SelectSra()
		Break
	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	� Atualiza Mensagem da Segunda Barra de Gauge        		   �
	����������������������������������������������������������������/*/
	IF !( lWorkFlow )
		IF ( ( nTipo == 2 ) .or. ( nTipo == 3 ) )
			IncProcG2( 'Apontando...' , .F. )	//'Apontando...'
		Else
			IncProcG2( 'Classificando...' , .F. )	//'Classificando...'
		EndIF
	EndIF

	/*/
	��������������������������������������������������������������Ŀ
	� Reinicializa cFilOld										   �
	����������������������������������������������������������������/*/
	cFilOld := "__cFilOld__"

	/*/
	��������������������������������������������������������������Ŀ
	� Processa o Apontamento de Marcacoes/Refeicoes                �
	����������������������������������������������������������������/*/
	While SRA->(;
					!Eof();
					.and.;
					( ( cFilTnoSRA := ( RA_FILIAL + RA_TNOTRAB ) ) >= cFilTnoDe );
					.and.;
		            ( cFilTnoSRA <= cFilTnoAte );
		        )

		If (SRA->RA_FILIAL $ cFilFECAux)
			SRA->( dbSkip() )
			Loop
		EndIf

 		IF !( lSraQryOpened )
			/*/
			��������������������������������������������������������������Ŀ
			� Consiste filtro do intervalo De / Ate                        �
			����������������������������������������������������������������/*/
			IF SRA->( !Eval( bSraScope ) )
				SRA->( dbSkip() )
				Loop
 			EndIF
 		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Aborta o processamento caso seja pressionado Alt + A         �
		����������������������������������������������������������������/*/
		IF ( lAbortPrint )
			aAdd(aLogFile, '- Cancelado pelo Operador em '  + Dtoc(MsDate()) + '- Cancelado pelo Operador em ' + Time() + ' ...') // '- Cancelado pelo Operador em '###', as '
			Break
		EndIF

		If !( SRA->RA_FILIAL == cFilAtu ) // Verifica o periodo de apontamento da filial
			GetPonMesDat( @dPerApoI , @dPerApoF , SRA->RA_FILIAL )
			lContinua	:=  ( dPerApoI <= dPerAte )
			cFilAtu	:=	SRA->RA_FILIAL
		EndIf

		If ( lContinua )
			If !( lMultThread )
				/*/
				�������������������������������������������������������������Ŀ
				� Efetua a Classificacao e o Apontamento das Marcacoes        �
				���������������������������������������������������������������/*/
				IF !Ponm010Aponta( .T. )
					Break
				EndIF
			Else
				aAdd(aMultSRA, {SRA->RA_FILIAL, SRA->RA_MAT} )
			EndIf
		EndIf

		/*/
		�������������������������������������������������������������Ŀ
		� Seleciona pr�ximo funcion�rio                               �
		���������������������������������������������������������������/*/
		SRA->( dbSkip() )

	EndDo

	If lMultThread
		Pnm010MultProc(aMultSRA, cFilFECAux, lPonWork, lSchedDef, lUserDefParam)
	EndIf

/*
	��������������������������������������������������������������Ŀ
	� Exclui fisicamente os registros deletados na SPC             �
	����������������������������������������������������������������*/
	If !lWorkFlow
		MsgRun(OemToAnsi("Preparando arquivo de apontamentos"),OemToAnsi("Aguarde..."),{|| Chk_Pack( "SPC" , -1 , 1 ) } ) //"Preparando arquivo de apontamentos"###"Aguarde..."
	Else
		Chk_Pack( "SPC" , -1 , 1 )
	EndIf
	/*/
	�������������������������������������������������������������Ŀ
	� Apura a Duracao da Classificacao/Apontamento                �
	���������������������������������������������������������������/*/
	cDurApoClas := RemainingTime( NIL , nCountTime , .F. )

Recover

	/*/
	��������������������������������������������������������������Ŀ
	� >>				Se Leitura ou Ambos			  			<< �
	����������������������������������������������������������������/*/
	IF ( ( nTipo == 1 ) .or. ( nTipo == 3 ) )

		/*/
		�������������������������������������������������������������Ŀ
		� Fecha e Exclui os Arquivos Temporarios					  �
		���������������������������������������������������������������/*/
		CloseTxtAlias( cTxtAlias , cArqDbf , aArqInd , lCpyT2Srv , cArqSrv , cArquivo )

		/*/
		�������������������������������������������������������������Ŀ
		� Gera o Log de Final de Leitura e Calcula o Tempo            �
		���������������������������������������������������������������/*/
		IF ( cDurLeitura == "00:00:00" )
			cDurLeitura := FinalLeitura( @aLogFile, nLidas, nGravadas, lWorkFlow, lRobo )
			++nCountTime
		EndIF
	EndIF

	/*/
	�������������������������������������������������������������Ŀ
	� Apura a Duracao da Classificacao/Apontamento                �
	���������������������������������������������������������������/*/
	cDurApoClas := RemainingTime( NIL , nCountTime , .F. )

End Sequence

If lSP0Comp .or. lPn090Lock
	Pnm090UnlockPer(,.T.,,,"A") //Desfaz o lock virtual da filial
EndIf

/*/
�������������������������������������������������������������Ŀ
� Fecha as Querys e Restaura os Padros                        �
���������������������������������������������������������������/*/
IF ( lSp8QryOpened )
	IF ( ( Select( cQrySp8Alias ) > 0 ) .and. !( cQrySp8Alias == cAliasSP8 ) )
		( cQrySp8Alias )->( dbCloseArea() )
		dbSelectArea( "SP8" )
	EndIF
EndIF
IF ( lSraQryOpened )
	SRA->( dbCloseArea() )
	ChkFile( "SRA" )
EndIF

lSraQryOpened := .F.

/*/
�����������������������������������������������������������������������Ŀ
� Log ao Final da Classificacao/Apontamento                             �
�������������������������������������������������������������������������/*/
IF ( nTipo == 1 )
	cMsgLog := ( '- Final da Classificacao em ' + Dtoc(MsDate()) + ', as ' + Time() + '.' )	//'- Final da Classificacao em '
	aAdd( aLogFile , cMsgLog )
ElseIF ( ( nTipo == 2 ) .or. ( nTipo == 3 ) )
	cMsgLog := ( '- Final da Classificacao/Apontamento em ' + Dtoc(MsDate()) + ', as ' + Time() + '.' )	//'- Final da Classificacao/Apontamento em '
	aAdd( aLogFile , cMsgLog )
EndIF
IF lWorkFlow .And. !lRobo
	/*/
	�����������������������������������������������������������������������Ŀ
	� Enviando Mensagens para o Console do Server                 			�
	�������������������������������������������������������������������������/*/
	ConOut("")
	ConOut( cMsgLog )
	ConOut("")
EndIF

/*/
�������������������������������������������������������������Ŀ
� Gera Log de Ocorrencias                                     �
���������������������������������������������������������������/*/
aAdd(aLogFile, '- Final da Leitura/Apontamento em ' + Dtoc(MsDate()) + ", as " + Time() + ".")								// '- Final da Leitura/Apontamento em '
aAdd(aLogFile, "- " + 'Decorridos' + ": " + RemainingTime( cTimeIni , GetFirstRemaining() , .F. ) )	// 'Decorridos'
IF ( ( nTipo == 1 ) .or. ( nTipo == 3 ) )
	aAdd(aLogFile , '- Tempo de Leitura:' + " " + cDurLeitura )								// '- Tempo de Leitura:'
	aAdd(aLogFile , '- Tempo medio de Leitura: ' + MediumTime( cDurLeitura , nLidas , .T. ) )		// '- Tempo medio de Leitura: '
EndIF
IF ( nTipo == 1 )
	aAdd(aLogFile, '- Tempo de Classificacao:' + " " + cDurApoClas )								// '- Tempo de Classificacao:'
	aAdd(aLogFile , '- Tempo medio de Classificacao: ' + MediumTime( cDurApoClas , nFuncProc , .T. ) )		// '- Tempo medio de Classificacao: '
ElseIF ( ( nTipo == 2 ) .or. ( nTipo == 3 ) )
	aAdd(aLogFile, '- Tempo de Classificacao/Apontamento:' + " " + cDurApoClas )								// '- Tempo de Classificacao/Apontamento:'
	aAdd(aLogFile , '- Tempo medio Classificacao/Apontamento: ' + MediumTime( cDurApoClas , nFuncProc , .T. ) )		// '- Tempo medio Classificacao/Apontamento: '
EndIF
cMsgLog := ( '- Numero de Funcionarios Processados: ' + StrZero( nFuncProc , 10 ) + "." )
aAdd( aLogFile , cMsgLog )														// '- Numero de Funcionarios Processados: '

//-- Forca quebra de pagina pelo 'estouro' de linhas
IF !Empty( aMarcNoGer )
	aAdd( aLogFile , " "	 )
	aAdd( aLogFile , " "	 )
	aAdd( aLogFile , " "	 )
	aAdd( aLogFile , " "	 )
Endif

IF lWorkFlow .And. !lRobo
	/*/
	�����������������������������������������������������������������������Ŀ
	� Enviando Mensagens para o Console do Server                 			�
	�������������������������������������������������������������������������/*/
	ConOut("")
	ConOut( cMsgLog )
	ConOut("")
EndIF

/*/
�������������������������������������������������������������Ŀ
� Carrega o Titulo das Ocorrencias do Log                     �
���������������������������������������������������������������/*/
aLogTitle[1] := 'OCORRENCIAS DURANTE A LEITURA/APONTAMENTO'	// 'OCORRENCIAS DURANTE A LEITURA/APONTAMENTO'
aLogTitle[2] := 'CRACHAS/PIS NAO CADASTRADOS' // 'CRACHAS/PIS NAO CADASTRADOS'
aLogTitle[3] := 'CRACHAS DE VISITANTES' // 'CRACHAS DE VISITANTES'
aLogTitle[4] := 'INTEGRA��O COM A CAROL' // 'INTEGRA��O COM A CAROL'

/*/
�������������������������������������������������������������Ŀ
� Carrega em aLogs os Logs de Ocorrencia                      �
���������������������������������������������������������������/*/
aLogs[1] := aClone( aLogFile	)
aLogs[2] := aClone( aSemCracha	)
aLogs[3] := aClone( aVisitante	)

/*/
�������������������������������������������������������������Ŀ
� Redefine o Array aSemCracha 								  �
���������������������������������������������������������������/*/
aSemCracha := {}
IF ( ( nCount := Len( aLogs[2] ) ) > 0 )
	aAdd( aSemCracha , '- No. Cracha/PIS   No. de Marcacoes Encontradas' ) // '- No. Cracha/PIS   No. de Marcacoes Encontradas'
	aAdd( aSemCracha , "" )
	For nX := 1 To nCount
		aAdd( aSemCracha , Left( aLogs[ 2 , nX , 1 ] + cSpPIS , nLenPis ) + " - " + StrZero( aLogs[ 2 , nX , 2 ] , 5 ) )
	Next nX
EndIF
aLogs[2] := aClone( aSemCracha )

/*/
�������������������������������������������������������������Ŀ
� Redefine o Array aVisitante				  				  �
���������������������������������������������������������������/*/
aVisitante := {}
IF ( ( nCount := Len( aLogs[3] ) ) > 0 )
	aAdd( aVisitante , '- No. Cracha/PIS   No. de Marcacoes Encontradas' ) // '- No. Cracha/PIS   No. de Marcacoes Encontradas'
	aAdd( aVisitante , "" )
	For nX := 1 To nCount
		aAdd( aVisitante , Left( aLogs[ 3 , nX , 1 ] + cSpCracha , nLenCracha ) + " - " + StrZero( aLogs[ 3 , nX , 2 ] , 5 ) )
	Next nX
EndIF
aLogs[3] := aClone( aVisitante )


/*/
������������������������������������������������������������������������Ŀ
� Carrega Informa��es sobre marca��es n�o geradas no Log de Ocorrencia   �
��������������������������������������������������������������������������/*/
IF !Empty( aMarcNoGer )

   AADD(aLogTitle, 'Marca��es N�o Geradas' ) // 'Marca��es N�o Geradas'
   AADD(aLogs, aClone(aMarcNoGer))

   	/*/
	�������������������������������������������������������������Ŀ
	� Redefine o Array aMarcNoGer 								  �
	���������������������������������������������������������������/*/
	aMarcNoGer := {}
	IF ( ( nCount := Len( aLogs[Len(aLogs)] ) ) > 0 )
		AADD(aMarcNoGer, PADR('Data',10) + SPACE(1) + PADR('Marca��es',90) + SPACE(1) +  'Observa��o' ) // //' Data     Marca��es                                        Observa��o'

	  	For nLoop := 1 To nCount
	  	    nCount2		:=Len(aLogs[Len(aLogs), nLoop, 2 ] )
	  	    cMat		:=aLogs[Len(aLogs), nLoop, 1 ]
   		    aAdd( aMarcNoGer , __PrtThinLine() )
	  	    aAdd( aMarcNoGer , cMat )
   		    aAdd( aMarcNoGer , __PrtThinLine() )
	  		For nLoop2:= 1 To nCount2
			   	//-- Corre todas as marcacoes do dia
			   	dData	:= PADR(Dtoc(aLogs[Len(aLogs), nLoop, 2, nLoop2, 1 ]),10) //Data
		 	   	cMsg 	:= "Marca��pes em quantidade �mpar" 											//"Marca��pes em quantidade �mpar"
		   		cMarc	:= ""
				For nX := 1 TO Len( aLogs[ Len(aLogs), nLoop, 2, nLoop2, 2] )     //Array das Marcacoes
					If Len(cMarc) > 81
					   IF "IMPAR"$ UPPER(aLogs[Len(aLogs), nLoop, 2, nLoop2,3 ])  //Tipo de Ocorrencia ('Impar')
				  		  aAdd( aMarcNoGer , dData  + SPACE(1) +  PADR(cMarc, 90) )
			  			  dData 	:= Space(10)
						  cMarc	:= ""
					   ENDIF
					Endif

	    			cFlag:=  If( aLogs[ Len(aLogs), nLoop,  2, nLoop2, 2, nX, 4 ] <> "A", Space(3), "[A]" )
	    			cMarc+= StrTran(StrZero(aLogs[ Len(aLogs), nLoop,  2, nLoop2, 2, nX, 2 ],5,2),'.',':') + cFlag + Space(1)

				Next nX
				IF "IMPAR"$ UPPER(aLogs[Len(aLogs), nLoop,  2, nLoop2, 3 ])
					aAdd( aMarcNoGer , dData + SPACE(1) +  PADR(cMarc, 90) + SPACE(1) + cMsg ) // "Marca��pes em quantidade �mpar"
				ENDIF
			Next nLoop2
		Next nLoop
	EndIF
	aLogs[ Len(aLogs) ] := aClone( aMarcNoGer )

Endif

If lCaClockIn
	aLogs[4] := { "Configura��o do par�metro MV_APICLO3: " + SuperGetMv("MV_APICLO3", .F., '') } //"Configura��o do par�metro MV_APICLO3: "
EndIf

/*/
�������������������������������������������������������������Ŀ
� Gera e Mostra o Log 										  �
���������������������������������������������������������������/*/
If !lWorkFlow
	/*/
	�������������������������������������������������������������Ŀ
	� Gera e Mostra o Log 										  �
	���������������������������������������������������������������/*/
	cTbTmpName := "L" + dtos(dDataBase) + StrTran(Time(),':','',1,4)
	cLogFile := fMakeLog(	aLogs																,;	//Array que contem os Detalhes de Ocorrencia de Log
							aLogTitle															,;	//Array que contem os Titulos de Acordo com as Ocorrencias
							"PNM010"															,;	//Pergunte a Ser Listado
							.T.																	,;	//Se Havera "Display" de Tela
							IF( lProcFilial , cTbTmpName , Nil )					,;	//Nome Alternativo do Log
							NIL																	,;	//Titulo Alternativo do Log
							"G"																	,;	//Tamanho Vertical do Relatorio de Log ("P","M","G")
							"L"																	,;	//Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
							NIL																	,;	//Array com a Mesma Estrutura do aReturn
							NIL 						 										,;	//Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
							aLogPerg															;	//Array com as perguntas selecionadas
						 )
Endif

/*/
�������������������������������������������������������������Ŀ
� Ponto de Entrada ao Final do Processo						  �
���������������������������������������������������������������/*/
IF ( lPonaPo8Block )
	ExecBlock( "PONAPO8" , .F. , .F. , { aAbreArqRel , cLogFile } )
EndIF

aRegsRARFE := Nil

/*/
�������������������������������������������������������������Ŀ
� Restaura os Dados de Entrada         						  �
���������������������������������������������������������������/*/
RestArea( aAreaSP0 )
RestArea( aAreaSP2 )
RestArea( aAreaSP8 )
RestArea( aAreaSPE )
RestArea( aAreaSRA )

Return( NIL )

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �CloseTxtAlias� Autor �Marinaldo de Jesus   � Data �22/01/2003�
������������������������������������������������������������������������Ĵ
�Descri��o �Fecha a Area e Exclui os Arquivos Temporarios utilizados   no�
�          �processo de Leitura das Marcacoes							 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/
Static Function CloseTxtAlias( cTxtAlias , cArqDbf , aArqInd , lCpyT2Srv , cArqSrv , cArquivo )

Local nLoop
Local nLoops
Local cPonArq := If( !Empty( SuperGetMv("MV_POARQ",.F.,"N") ), SuperGetMv("MV_POARQ",.F.,"N"), "2" )

If !lPort1510
	IF ( !Empty( cTxtAlias ) .and. ( Select( cTxtAlias ) > 0 ) )
		/*/
		�������������������������������������������������������������Ŀ
		� Fecha o Arquivo atualmente aberto 						  �
		���������������������������������������������������������������/*/
		TxtAliasClose( cTxtAlias )
		/*/
		�������������������������������������������������������������Ŀ
		� Exclui os Arquivos Temporarios 							  �
		���������������������������������������������������������������/*/
		IF ( cTxtAlias == "__TMPRELOG" )
			fErase( cArqDbf )
			nLoops := Len( aArqInd )
			For nLoop := 1 To nLoops
				fErase( aArqInd[ nLoop ] )
			Next nLoop
		EndIF
	EndIF
EndIf

/*/
��������������������������������������������������������������Ŀ
�cPonArq - indica que s� copia o arquivo para o StartPath caso �
�o parametro MV_POARQ esteja com valor N�O					   �
����������������������������������������������������������������/*/
If (cPonArq != "1")
	/*/
	������������������������������������������������������������������������Ŀ
	� Se copiou para o server, Exclui                           			 �
	��������������������������������������������������������������������������/*/
	IF ( ( lCpyT2Srv ) .and. !Empty( cArqSrv ) )
		IF !( Upper( AllTrim( cArquivo ) ) == Upper( AllTrim( cArqSrv ) ) )
			fErase( cArqSrv )
		EndIF
	EndIF
EndIf

Return( NIL )

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �FinalLeitura � Autor �Marinaldo de Jesus   � Data �22/01/2003�
������������������������������������������������������������������������Ĵ
�Descri��o �Gera Log do Final da Leitura e Retorna o Tempo de Processamen�
�          �to															 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/
Static Function FinalLeitura( aLogFile, nLidas, nGravadas, lWorkFlow, lRobo )

Local cDurLeitura	:= "00:00:00"
Local cMsgLog		:= ""

/*/
�������������������������������������������������������������Ŀ
� Adiciona ao Log o Final do Processo de Leitura e o Numero de�
� Marcacoes Lidas											  �
���������������������������������������������������������������/*/
cMsgLog := ( '- Final da Leitura em '  + Dtoc(MsDate()) + ', as ' + Time() + '.' )	// '- Final da Leitura em '
aAdd( aLogFile , cMsgLog )
IF lWorkFlow .And. !lRobo
	/*/
	�����������������������������������������������������������������������Ŀ
	� Enviando Mensagens para o Console do Server                 			�
	�������������������������������������������������������������������������/*/
	ConOut("")
	ConOut( cMsgLog )
	ConOut("")
EndIF
cMsgLog := ( '- Numero de Marcacoes Lidas: '  + StrZero( nLidas	, 10 ) + '.' )			// '- Numero de Marcacoes Lidas: '
aAdd( aLogFile , cMsgLog )
IF lWorkFlow .And. !lRobo
	/*/
	�����������������������������������������������������������������������Ŀ
	� Enviando Mensagens para o Console do Server                 			�
	�������������������������������������������������������������������������/*/
	ConOut("")
	ConOut( cMsgLog )
	ConOut("")
EndIF
cMsgLog := ( '- Numero de Marcacoes Gravadas: '  + StrZero( nGravadas , 10 ) + '.' )			// '- Numero de Marcacoes Gravadas: '
aAdd( aLogFile , cMsgLog )
IF lWorkFlow .And. !lRobo
	/*/
	�����������������������������������������������������������������������Ŀ
	� Enviando Mensagens para o Console do Server                 			�
	�������������������������������������������������������������������������/*/
	ConOut("")
	ConOut( cMsgLog )
	ConOut("")
EndIF

/*/
�������������������������������������������������������������Ŀ
� Guarda o Tempo Final da Leitura							  �
���������������������������������������������������������������/*/
cDurLeitura := RemainingTime( NIL , GetFirstRemaining() , .F. )

Return( cDurLeitura )

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o	   �Ponm010Ref� Autor �Equipe Advanced RH     � Data �06/03/1996�
�����������������������������������������������������������������������Ĵ
�Descri��o � Grava as marca��es do refeit�rio.						  	�
�����������������������������������������������������������������������Ĵ
� Uso  	   � PONM010													�
�������������������������������������������������������������������������/*/
Static Function Ponm010Ref(	cCodRel		,;	//Codigo do Relogio
							cFil		,;	//Filial do Funcionario
							cMatricula	,;	//Matricula do Funcionario
							dData		,;	//Data da Marcacao
							nHorario	,;	//Horario da Marcacao
							cCusto		,;	//Centro de Custo da Marcacao
							cTipDesp	,;	//Tipo do Parametro Despreza Marcacao
							nDespRef	,;	//Quantidade/Minutos a Serem Desprezadas
							nGravadas	 ;	//Quantidade de Marcacoes Gravadas
						 )

Local cSvFilAnt	:= cFilAnt
Local cSeek		:= ""
Local cKey		:= ""
Local lMin		:= .F.
Local lGrava	:= .T.
Local nRefs		:= 1

DEFAULT nGravadas	:= 0

/*/
��������������������������������������������������������������Ŀ
�Se Existir o Parametro MV_DESPREF verifica quais marcacoes  de�
�verao ser Desprezadas	- By Naldo							   �
����������������������������������������������������������������/*/
IF ( !Empty(cTipDesp) .and. cTipDesp $ "N_M" )
	IF ( lMin  := ( cTipDesp == "M" ) )
		nDespRef	:= __Hrs2Min( nDespRef )
		cSeek		:= ( cFil + cMatricula + Dtos(dData) )
	Else
		cSeek		:= ( cFil + cMatricula + Dtos(dData) + Str(nHorario,5,2) )
	EndIF
	/*
	��������������������������������������������������������������Ŀ
	�Descricao: Ponto de Entrada antes da gravacao padrao da refei-�
	�cao. Se for retornado .T. processa a gravacao padrao caso     �
	�contrario nao executa a gravacao.							   �
	����������������������������������������������������������������*/
	If lPnm010R2Block
	   	IF ( ValType( uRetBlock := ExecBlock("PNM010R2",.F.,.F.,;
		   	{	 cCodRel	,;	//Codigo do Relogio
				 cFil		,;	//Filial do Funcionario
				 cMatricula	,;	//Matricula do Funcionario
				 dData		,;	//Data da Marcacao
				 nHorario	,;	//Horario da Marcacao
				 cCusto		,;	//Centro de Custo da Marcacao
				 cTipDesp	,;	//Tipo do Parametro Despreza Marcacao
				 nDespRef	;	//Quantidade/Minutos a Serem Desprezadas
		   })  ) == "L" )
	   	   lGrava:= uRetBlock
	    Else
		    lGrava:= .F.
	    Endif
	Else
		IF SP5->( MsSeek( cSeek , .F. ) )
			cKey := ( cFil + cMatricula + Dtos(dData) )
			While SP5->( !Eof() .and. ( P5_FILIAL + P5_MAT + Dtos(P5_DATA) == cKey ) ;
							    .and. IF(lMin,lMin,P5_HORA == nHorario ) )

				IF ( !( lMin ) .and. ( ( ++nRefs ) > nDespRef ) )
					lGrava := .F.
				ElseIF ( ( lMin ) .and. ( __Hrs2Min( SP5->( DataHora2Val(P5_DATA,P5_HORA,dData,nHorario) ) ) <= nDespRef ) )
					lGrava := .F.
				EndIF
				IF !( lGrava )
					Exit
				EndIF
				SP5->( dbSkip() )
			EndDo
		EndIF
	Endif
EndIF

IF ( lGrava )
    //-- Troca Filial para Integridade
    cFilAnt	:= IF( !Empty( cFil ) , cFil , cFilAnt )
	IF RecLock( "SP5" , .T. , .T. )
		SP5->P5_FILIAL	:= cFil
		SP5->P5_MAT		:= cMatricula
		SP5->P5_DATA	:= dData
		SP5->P5_HORA	:= nHorario
		SP5->P5_RELOGIO := cCodRel
		SP5->P5_CC		:= cCusto
		SP5->P5_FLAG	:= "E"
		SP5->( MsUnlock() )
	EndIF
	/*/
	��������������������������������������������������������������Ŀ
	�Incrementa o contador de Marcacoes Gravadas				   �
	����������������������������������������������������������������/*/
	++nGravadas
	/*/
	��������������������������������������������������������������Ŀ
	�Ponto de Entrada Apos a Gravacao de Um novo Registro de  Refei�
	�cao - By Naldo												   �
	����������������������������������������������������������������/*/
	IF ( lPonapo7Block )
		ExecBlock( "PONAPO7" , .F. , .F. , SP5->( Recno() ) )
	EndIF
EndIF

//-- Restaura valor original da Filial de Entrada
cFilAnt	:=	cSvFilAnt

Return( NIL )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fChkPer   � Autor �Equipe Advanced RH     � Data �05/12/1998���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida o Periodo de acordo com o MV_PAPONTA				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �fChkPer( dPerDe , dPerAte )								  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �PONM010	 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function fChkPer( dPerDe , dPerAte , cFil )

Local dPerIni	:= Ctod("//")
Local dPerFim	:= Ctod("//")
Local lRet		:= .T.

DEFAULT dPerDe	:= Ctod("//")
DEFAULT dPerAte	:= Ctod("//")

Begin Sequence
	IF !( lRet := !Empty( dPerDe ) )
		Break
	EndIF
	IF !( lRet := !Empty( dPerAte ) )
		Break
	EndIF
	IF !( lRet := !( dPerDe > dPerAte ) )
		Break
	EndIF
	IF !( lRet := GetPonMesDat( @dPerIni , @dPerFim , cFil ) )
		Break
	EndIF
	IF !( lRet := !( dPerAte < dPerIni ) )
		Break
	EndIF
	IF !( lRet := !( dPerDe >= dPerIni .and. dPerDe <= dPerFim .and. dPerAte > dPerFim ) )
		Break
	EndIF
End Sequence

Return( lRet )

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �GetNewResult� Autor �Marinaldo de Jesus    � Data �31/07/2001�
������������������������������������������������������������������������Ĵ
�Descri��o �Remonta aResult Apenas com Marcacoes nao Alteradas e ja  Apon�
�          �tadas														 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �GetNewResult(@aResult,aLastApo,aMarcacoes,aTabCalend)		 �
������������������������������������������������������������������������Ĵ
�Parametros�aResult		-> Array com os Resultados Dia a Dia			 �
�          �aLastApo	-> Array com os Resultados Dia a Dia Ja Apontados�
�          �aMarcacoes	-> Array com as Marcacoes a Serem Apontadas      �
�          �aTabCalend 	-> Calendario de Marcacoes                       �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/
Static Function GetNewResult(aResult,aLastApo,aMarcacoes,aTabCalend)

Local cOrdem	:= ""
Local nFornY	:= Len( aLastApo )
Local nOrdIni	:= Val( aTabCalend[ 01 , 2 ] )
Local nOrdFim	:= Val( aTabCalend[ Len( aTabCalend ) , 2 ] )
Local nPos		:= 0
Local nPos1		:= 0
Local nY		:= 0
Local nX		:= 0

IF ( nFornY > 0 )
	For nX := nOrdIni To nOrdFim
		cOrdem := StrZero( nX , 2 )
		IF aScan( aMarcacoes , { |x| x[3] == cOrdem .and. x[10] != "S" } ) > 0 .or. ;
		   aScan( aMarcacoes , { |x| x[3] == cOrdem } ) == 0
			Loop
		EndIF
		IF ( nPos1 := aScan( aTabCalend , { |x|  x[ 2 ] == cOrdem .and. x[ 4 ] == "1E" } ) ) > 0
			IF ( nPos := aScan( aLastApo , { |x| x[ 01 ] == aTabCalend[ nPos1 , 1 ] } ) ) > 0
				For nY := nPos To nFornY
					IF aLastApo[ nY , 01 ] == aTabCalend[ nPos1 , 1 ]
						fGeraRes(	@aResult						,; //01 -> Array com os Resultados do Dia
									aLastApo[ nY, 01 ]				,; //02 -> Data da Geracao
									aLastApo[ nY, 03 ]				,; //03 -> Numero de Horas Resultantes
									aLastApo[ nY, 02 ]				,; //04 -> Codigo do Evento
									aLastApo[ nY, 04 ]				,; //05 -> Centro de Custo a ser Gravado
									aLastApo[ nY, 05 ]				,; //06 -> Tipo de Marcacao
									.F.								,; //07 -> True para Acumular as Horas
									/*cPeriodo	*/					,; //08 -> Periodo de Apuracao
									/*nTole		*/					,; //09 -> Tolerancia
									/*cArred	*/					,; //10 -> Tipo de Arredondamento a Ser Utilizado
									/*lSubstitui*/					,; //11 -> Substitui a(s) Hora(s) Existente(s)
									/*cFuncao	*/					,; //12 -> Funcao
				  					/*cDepto	*/					,; //13 -> Depto para gravacao
									/*cPosto	*/					,; //14 -> Posto para gravacao
									/*cProcesso	*/					,; //15 -> Periodo para Gravacao
									/*cRoteiro	*/					,; //16 -> Processo para Gravacao
									/*cPerApo	*/					,; //17 -> Periodo para Gravacao
									/*cNumPagto	*/ 					,; //18 -> NumPagto para Gravacao
									aLastApo[ nY, ARESULT_TURNO  ]	,; //19 -> Turno de Trabalho
									aLastApo[ nY, ARESULT_SEMANA ]	,; //20 -> Semana/Sequencia do Turno
									aLastApo[ nY, ARESULT_TIPOHE ]	,; //21 -> Tipo de Hora Extra
									aLastApo[ nY, ARESULT_PERCENT]	;  //22 -> Percentual de Valorizacao
								 )
					Else
						Exit
					EndIF
				Next nY
			EndIF
		EndIF
	Next nX
EndIF

Return( NIL )

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �GetMrBySra   � Autor �Marinaldo de Jesus   � Data �07/09/2004�
������������������������������������������������������������������������Ĵ
�Descri��o �Obtem as marcacoes dos Funcionarios							 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/
Static Function GetMrBySra()

Local cSvFilAnt		:= cFilAnt
Local nDespMin		:= GetDespMin()
Local aLastMarca
Local aMarcacoes
Local aNewMarca
Local aProvCrachas
Local aCrachas
Local aGetArea 		:= {}
Local cMarcFer
Local cMvDespRef
Local cNumRep
Local cEmpOrg
Local cDhOrg
Local cIdOrg
Local cSpaceMotVrg := If(lPort1510,Space( GetSx3Cache( "P8_MOTIVRG" , "X3_TAMANHO" ) ),Nil)
Local cMotivo	   := If(lPort1510,fInitMotivo( xFilial("RFD"), "1" , "3" ),Nil)
Local cPerDe       := DtoS(dPerDe - nDiasExtA)
Local cPerAte      := DtoS(dPerAte + nDiasExtP)

Local dIniGet
Local dFimGet

Local lCpoUser		:= .F.
Local lDespMin		:= ( nDespMin != 0 )//com o parametro igual o zero, nao havera desprezo de marcacoes
Local lIntMen
Local lGetMarcAuto	:= .F.
Local lRfeQryOpened := .F.
Local lSP0Comp		:= FWModeAccess("SP0",1) == "C" .AND. FWModeAccess("SP0",2) == "C" .AND. FWModeAccess("SP0",3) == "C"

Local nLoop
Local nLoops
Local nCracha
Local nCrachas
Local nDespRef
Local nTab
Local nRecQry
Local nX
Local nY

Static nSerIni
Static nSerFim

Local ATotCracha		:= {}
Local cQuery	 		:= ""
Local cSvQuery			:= ""
Local cSvCracha			:= ""
Local cSvDat			:= ""
Local nField			:= 0
Local cPrefixo
Local cRfeRetSqlName

Local lCaClockIn := SuperGetMv( "MV_APICLO0" , NIL , .F. )

If !lPn010Auto
   	If lPort1510
	   	cPrefixo			:= ( PrefixoCpo( cAliasRFE ) + "_" )
		cRfeRetSqlName	    := InitSqlName( cAliasRfe )
		DEFAULT aRfeFields	:= ( cAliasRfe )->( dbStruct() )
		DEFAULT nRfeFields 	:= Len( aRfeFields )
		cQryRfeAlias := ( "__Q" + cAliasRfe + "QRY" )
	EndIf
Endif

Private lREP := .F.

If Type("lPn010Auto") == "U"
	Private lPn010Auto := .F.
Endif

If lPort1510
	lREP := !Empty(SP0->P0_REP) .Or. (lCaClockIn .And. SP0->P0_TIPOARQ == "R") 
EndIf

Begin Sequence

	SPE->( dbSetOrder( RetOrdem( "SPE" , "PE_FILIAL+PE_MAT" ) ) )
	SPF->( dbSetOrder( RetOrdem( "SPF" , "PF_FILIAL+PF_MAT+DtoS(PF_DATA)" ) ) )
	SP8->( dbSetOrder( RetOrdem( "SP8" , "P8_FILIAL+P8_MAT+DTOS(P8_DATA)+STR(P8_HORA,5,2)" ) ) )

	/*/
	��������������������������������������������������������������Ŀ
	� Seleciona Informacoes dos Funcionarios                       �
	����������������������������������������������������������������/*/
	If !lPn010Auto
		IF !SelectSra()
			Break
		EndIF
	Endif

	/*/
	��������������������������������������������������������������Ŀ
	� Inicializo aMarcacoes										   �
	����������������������������������������������������������������/*/
	aMarcacoes := Array( 01 , Array( ELEMENTOS_AMARC ) )

	If !lPn010Auto
		cCondSRA := "( ( cFilTnoSRA := ( RA_FILIAL + RA_TNOTRAB ) ) >= cFilTnoDe ) .and. ( cFilTnoSRA <= cFilTnoAte )
	Else
		cCondSRA := "( ( cFilFunSRA := ( RA_FILIAL + RA_MAT ) ) >= cFunMat ) .and. ( cFilFunSRA <= cFunMat )
	Endif
	/*/
	��������������������������������������������������������������Ŀ
	� Processa o Apontamento de Marcacoes/Refeicoes                �
	����������������������������������������������������������������/*/
	While SRA->(;
					!Eof();
					.and.;
                    &(cCondSRA) ;
		        )

		/*/
		��������������������������������������������������������������Ŀ
		� Obtenho Filial e Matricula do Funcionario                    �
		����������������������������������������������������������������/*/
		cFilSRA 	:= SRA->RA_FILIAL
		cMatricula	:= SRA->RA_MAT

		/*/
		��������������������������������������������������������������Ŀ
		� Abandona o Processamento									   �
		����������������������������������������������������������������/*/
		IF ( lAbortPrint )
			aAdd( aLogFile , '- Cancelado pelo Operador em ' + Dtoc(MsDate()) + ', as ' + Time() + ' ...') // '- Cancelado pelo Operador em '
			Break
		EndIF

		If !lPn010Auto
	 		IF !( lSraQryOpened )
				/*/
				��������������������������������������������������������������Ŀ
				� Consiste filtro do intervalo De / Ate                        �
				����������������������������������������������������������������/*/
				IF SRA->( !Eval( bSraScope ) )
					SRA->( dbSkip() )
					Loop
	 			EndIF
	 		EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Incrementa a Regua de Processamento                          �
			����������������������������������������������������������������/*/
			IF !( lWorkFlow )
				//'Lidas...: '
				IncPrcG2Time( 'Lidas...: ' , nSraLstRec , cTimeIni , .F. , nCountTime , nIncPercG2 )
				/*/
				��������������������������������������������������������������Ŀ
				� Consiste controle de acessos e filiais validas               �
				����������������������������������������������������������������/*/
				IF SRA->( !( cFilSRA $ fValidFil() ) .or. !Eval( bAcessaSRA ) )
					SRA->( dbSkip() )
					Loop
				EndIF
			Else
				/*/
				��������������������������������������������������������������Ŀ
				� So processa para a Filial Corrente                           �
				����������������������������������������������������������������/*/
				IF ( lProcFilial )
					IF ( cFilSRA <> cFilProc )
						SRA->( dbSkip() )
						Loop
					Endif
				EndIF
			EndIF
		EndIf

		If cFilSRA $ cFilFECAux //Per�odo bloqueado
			SRA->( dbSkip() )
			Loop
		EndIf
		/*/
		�������������������������������������������������������������Ŀ
		� Verifica o Periodo de Apontamento                           �
		���������������������������������������������������������������/*/
        IF !( cFilSRA == cFilOld )
        	cFilOld := cFilSRA

			If !lPn010Auto .And. !lSP0Comp //Se rel�gio n�o for compartilhado, verifica se fechamento esta sendo efetuado para a filial atual
				If !Pn090Open(, ,.T.,DtoS(dPerDe) + DtoS(dPerAte),.F.,cFilSRA,.F.,"A")
					If !lWorkFlow
						aAdd( aLogFile , '- O fechamento da filial '  + cFilSRA + ' esta sendo efetuado em outro processo. Tente novamente mais tarde.' ) // '- O fechamento da filial ' + SRA->RA_FILIAL + ' esta sendo efetuado em outro processo. Tente novamente mais tarde.'
					Else
						ConOut("")
						ConOut( '- O fechamento da filial ' + cFilSRA + ' esta sendo efetuado em outro processo. Tente novamente mais tarde.' )
						ConOut("")
					EndIf
					cFilFECAux += cFilSRA + "/"
					SRA->( dbSkip() )
					Loop
				Else
					lPn090Lock := .T.
				EndIf
			EndIf

       		IF !( CheckPonMes( @dPerIni , @dPerFim , .F. , .T. , ( !( lWorkFlow ) .and. !( lChkPonMesAnt ) .and. !(lMultThread) .And. !(lPn010Auto) ) , cFilOld ) )
				lChkPonMesAnt := .F.
				aAdd( aLogFile , '- O Periodo Informado nos Parametros e invalido. Informe um Periodo Valido' ) 					// '- O Periodo Informado nos Parametros e invalido. Informe um Periodo Valido'
				aAdd( aLogFile , 'ou' ) 					// 'ou'
				aAdd( aLogFile , '- Nao Foi Encontrado periodo de Apontamento para a Filial: ' + " " + cFilOld )	// '- Nao Foi Encontrado periodo de Apontamento para a Filial: '
				aAdd( aLogFile , '- A Leitura/Apontamento nao puderam ser concluidos. Favor Cadastrar o Periodo' ) 					// '- A Leitura/Apontamento nao puderam ser concluidos. Favor Cadastrar o Periodo'
				IF !( lWorkFlow )
					lAbortPrint := .T.
					If lRfeQryOpened
						(cQryRfeAlias)-> (dbCloseArea())
						RestArea( aGetArea )
					EndIf
					Break
				EndIF
			Else
				lChkPonMesAnt := .T.
			EndIF

			/*/
			�������������������������������������������������������������Ŀ
			� Seta o Periodo conforme Pergunte             				  �
			���������������������������������������������������������������/*/
			/*
			dPerDe 	  := IF( lWorkFlow .and. lUserDefParam , mv_par13 , IF( !lWorkFlow , mv_par13 , dPerIni	) )																												//Periodo De
			dPerAte	  := IF( lWorkFlow .and. lUserDefParam , IF( lLimitaDataFim , Min( dDataBase , mv_par14 ) , mv_par14 )  , IF( !lWorkFlow , mv_par14 , IF( lLimitaDataFim , Min( dDataBase , dPerFim ) , dPerFim ) ) )	//Periodo Ate
			*/
			/*/
			�������������������������������������������������������������Ŀ
			� Verifica se o Periodo eh Valido              				  �
			���������������������������������������������������������������/*/
			IF !fChkPer( dPerDe , dPerAte , cFilOld )
				aAdd( aLogFile , '- O Periodo Informado nos Parametros e invalido. Informe um Periodo Valido' ) // '- O Periodo Informado nos Parametros e invalido. Informe um Periodo Valido'
				IF !( lWorkFlow )
					lAbortPrint := .T.
					Break
				EndIF
			EndIF
			nSerIni := Round( __fDhtoNS( Max( dPerIni , dPerDe  ) - nDiasExtA, 00.00 )  , 5 )
			nSerFim := Round( __fDhtoNS( Min( dPerFim , dPerAte ) + nDiasExtP, 23.59 )  , 5 )

			dIniGet	:= ( Max( dPerIni , dPerDe  ) - 8 )
			dFimGet := ( Min( dPerFim , dPerAte ) + 8 )

			/*/
			�������������������������������������������������������������Ŀ
			� Obtem parametro se le marcacoes funcionarios em ferias	  �
			���������������������������������������������������������������/*/
			cMarcFer 	:= SuperGetMv("MV_MARCFER",,"N",cFilSRA)

			/*/
			�������������������������������������������������������������Ŀ
			� Verifica se Devera Carregar as Marcacoes Automaticas      em�
			� GetMarcacoes												  �
			���������������������������������������������������������������/*/
			lGetMarcAuto := ( SuperGetMv( "MV_GETMAUT" , NIL , "S" , cFilSRA ) == "S" )
		EndIF

		/*/
		�������������������������������������������������������������Ŀ
		� Inicializa os Arrays de Marcacoes Anteriores e Novas		  �
		���������������������������������������������������������������/*/
		aNewMarca	:= {}
		aLastMarca	:= {}
		aTabCalend	:= {}

		/*/
		�������������������������������������������������������������Ŀ
		� Carrega as Marcacoes Anteriores do Funcionario			  �
		���������������������������������������������������������������/*/
		IF !GetMarcacoes(	@aLastMarca 		,;	//01 -> Marcacoes dos Funcionarios
							@aTabCalend			,;	//02 -> Calendario de Marcacoes
							NIL					,;	//03 -> Tabela Padrao
							NIL					,;	//04 -> Turnos de Trabalho
							dIniGet				,;	//05 -> Periodo Inicial
							dFimGet				,;	//06 -> Periodo Final
							cFilSRA				,;	//07 -> Filial
							cMatricula			,;	//08 -> Matricula
							NIL					,;	//09 -> Turno
							NIL					,;	//10 -> Sequencia de Turno
							NIL					,;	//11 -> Centro de Custo
							NIL					,;	//12 -> Alias para Carga das Marcacoes
							NIL					,;	//13 -> Se carrega Recno em aMarcacoes
							NIL					,;	//14 -> Se considera Apenas Ordenadas
							NIL					,;  //15 -> Verifica as Folgas Automaticas
							NIL					,;  //16 -> Se Grava Evento de Folga Mes Anterior
							NIL					,;	//17 -> Se Carrega as Marcacoes Automaticas
							NIL					,;	//18 -> Registros de Marcacoes Automaticas que deverao ser Deletados
							NIL					,;	//19 -> Bloco para avaliar as Marcacoes Automaticas que deverao ser Desprezadas
							.F.					,;	//20 -> Se Considera o Periodo de Apontamento das Marcacoes
							.F.					 ;	//21 -> Se Efetua o Sincronismo dos Horarios na Criacao do Calendario
					 	)
			aAdd(aLogFile, '- Nao Foi Possivel Carregar as Marcacoes do Funcionario'  + AllTrim(SRA->RA_TNOTRAB) + '.')													// '- Nao Foi Possivel Carregar as Marcacoes do Funcionario'
			SRA->( aAdd(aLogFile, '  As marca��es do funcionario '+ AllTrim(SRA->RA_MAT) + ' - ' + AllTrim(SRA->RA_NOME) + ' nao' ) )			// '  As marca��es do funcionario '###' nao'
			aAdd(aLogFile, 'STR0119' )
			SRA->( dbSkip() )
			Loop
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Processo para o Periodo Selecionado nos Parametos            �
		����������������������������������������������������������������/*/
		dData		:= ( __fNStoDH( nSerIni , "D" ) - 1 )
		nLoops		:= ( nSerFim - nSerIni )
		aProvCrachas:= GetProv(__fNStoDH( nSerIni , "D" ), __fNStoDH( nSerFim , "D" ))

		// Se nao for via ExecAuto
		If !lPn010Auto

			//Se a portria estiver ativa e for TOP, cria query da RFE
			If lPort1510 .and. TcSrvType() != "AS/400"
				//Monta array com todos os crachas do periodo
				ATotCracha := {}
				For nLoop := 0 To nLoops
					++dData

				    IF  ( cMarcFer == "N" )
				   		IF ( nTab := aScan(aTabCalend, {|x| x[1] == dData .and. x[4] == '1E' }) ) > 0.00
							IF ( aTabCalend[ nTab , 24 ] )  .AND. 	( aTabCalend[	nTab	,	25		] == "F" )
								Loop
							EndIF
						EndIF
					EndIF

					cData := Dtos( dData )

					aCrachas	:= GetCracha( dData, aProvCrachas )
					nCrachas	:= Len( aCrachas )
					For nX := 1 To nCrachas
						If aScan(ATotCracha, { |x| x[2] == aCrachas[nX] } ) == 0
							aAdd(ATotCracha, {cData,aCrachas[nX]} )
						EndIf
					Next nX
				Next nLoop

				aGetArea	:= GetArea()
				nCrachas := Len(aTotCracha)

				If !(nCrachas > 0 )
					SRA->( dbSkip() )
					Loop
				EndIf

				If lRep
					( cTxtAlias )->(dbSetOrder(RetOrder("RFE","RFE_PIS+DTOS(RFE_DATA)+STR(RFE_HORA,5,2)")))
				Else
					( cTxtAlias )->(dbSetOrder(RetOrder("RFE","RFE_CRACHA+DTOS(RFE_DATA)+STR(RFE_HORA,5,2)")))
				EndIf

				cQuery := "SELECT "
		  		For nField := 1 To nRfeFields
					cQuery += aRfeFields[ nField , 01 ] + ", "
				Next nField
				cQuery += "R_E_C_N_O_ RECNO  "

				cQuery := SubStr( cQuery , 1 , Len( cQuery ) - 2 )

				cQuery += ( " FROM " + cRfeRetSqlName + " " + cAliasRFE )
				cQuery += ( " WHERE ( " )
				For nY := 1 to nCrachas
					cQuery += ( cAliasRFE + "." + cPrefixo )
					If !lRep
						cQuery += ( "CRACHA='"+aTotCracha[nY,2]+"'" )
					Else
						cQuery += ( "PIS='"+aTotCracha[nY,2]+"'" )
					EndIf
					If nY < nCrachas
						cQuery += ( " OR " )
					EndIf
				Next nY

				cQuery += ( " ) AND ( " )

				cQuery += ( cAliasRFE + "." + cPrefixo )
				cQuery += ( "DATA>='"+cPerDe+"'" )
				cQuery += ( " AND " )
				cQuery += ( cAliasRFE + "." + cPrefixo )
				cQuery += ( "DATA<='"+cPerAte+"'" )

				cQuery += ( " ) AND ( " )

				cQuery += ( cAliasRFE + "." + cPrefixo )
				cQuery += ( "FLAG='0'" )
				cQuery += ( " OR " )
				cQuery += ( cAliasRFE + "." + cPrefixo )
				cQuery += ( "NATU='3'" )

				cQuery += ( " ) AND " )

				cQuery += ( cAliasRFE + "." + cPrefixo )
				cQuery += ( "RELOGI='"+cRelogio+"'" )
				cQuery += ( " AND " )

				cQuery += ( cAliasRFE + ".D_E_L_E_T_=' ' " )
				cQuery += ( "ORDER BY " + SqlOrder( (cAliasRFE)->( IndexKey() ) ) )
				/*/
				�������������������������������������������������������������Ŀ
				� Salva Query Atual Para Posterior Remontagem                 �
				���������������������������������������������������������������/*/
				cSvQuery	:= cQuery
				/*/
				�������������������������������������������������������������Ŀ
				� Salva Cracha e Data Para Posterior remontagem   da Query	  �
				���������������������������������������������������������������/*/
	   			cSvCracha	:= cCracha
	 			cSvDat		:= cData

				cQuery := ChangeQuery( cQuery )

				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQryRfeAlias, .F., .T.)

				For nField := 1 To nRfeFields
					IF !( aRfeFields[ nField , 02 ] == "C" )
						TcSetField(cQryRfeAlias,aRfeFields[nField,01],aRfeFields[nField,02],aRfeFields[nField,03],aRfeFields[nField,04])
					EndIF
				Next nField

				lRfeQryOpened := .T.

				//Fixa nLoops e nCrachas para fazer apenas uma vez os FOR abaixo
				nLoops := 0
				nCrachas := 1
			EndIf

			For nLoop := 0 To nLoops

				//Se nao montou query
				If !(lRfeQryOpened)  .And. !lPn010Auto
					/*/
					��������������������������������������������������������������Ŀ
					� Obtem a Data para Pesquisa                                   �
					����������������������������������������������������������������/*/
					++dData

					/*/
					��������������������������������������������������������������Ŀ
					� Consiste Afastamento do funcionario                          �
					����������������������������������������������������������������/*/
				    IF  ( cMarcFer == "N" )
				   		IF ( nTab := aScan(aTabCalend, {|x| x[1] == dData .and. x[4] == '1E' }) ) > 0.00
							IF ( aTabCalend[ nTab , 24 ] )  .AND. 	( aTabCalend[	nTab	,	25		] == "F" )
								Loop
							EndIF
						EndIF
					EndIF

					/*/
					�������������������������������������������������������������Ŀ
					�Transforma a Data em String para Montagem da Query e da Chave�
					�de Pesquisa												  �
					���������������������������������������������������������������/*/
					cData := Dtos( dData )

					/*/
					��������������������������������������������������������������Ŀ
					� Obtem os Crachas do Funcionario na Data					   �
					����������������������������������������������������������������/*/
					aCrachas	:= GetCracha( dData, aProvCrachas )
					nCrachas	:= Len( aCrachas )

					If lPort1510
						( cTxtAlias )->(dbSetOrder(RetOrder("RFE","RFE_CRACHA+DTOS(RFE_DATA)+STR(RFE_HORA,5,2)")))
					EndIf
				EndIf

				For nCracha := 1 To nCrachas

					//Se nao montou query
					If !(lRfeQryOpened)
						cCracha := aCrachas[ nCracha ]

						/*/
						��������������������������������������������������������������Ŀ
						� Verifica se Existem Marcacoes para o Cracha                  �
						����������������������������������������������������������������/*/
						If !lPort1510
							IF !( cTxtAlias )->( MsSeek( ( cCracha + cData ) , .F. ) )
								Loop
							EndIF
							cQryRfeAlias := cTxtAlias
						EndIf
					EndIF

					/*/
					��������������������������������������������������������������Ŀ
					� Loop para ler o arquivo gerado pelo relogio.                 �
					����������������������������������������������������������������/*/
					While ( cQryRfeAlias )->(	!Eof() )

	        			If lPort1510
							If !( lRfeQryOpened ) .and. (!( ( cQryRfeAlias )->RFE_CRACHA == cCracha ) .or. !( ( cQryRfeAlias )->RFE_DATA == dData ))
								Exit
							EndIf
							/*/
							��������������������������������������������������������������Ŀ
							� Desconsidera as marcacoes ja processadas e cujo cracha foi   �
							� reconhecido.												   �
							����������������������������������������������������������������/*/
							If !(( cQryRfeAlias )->RFE_FLAG == "0")  .AND. (( cQryRfeAlias )->RFE_NATU <> "3")
								( cQryRfeAlias )->( dbSkip() )
								Loop
							EndIf
							
							If !lSP0Comp .and. !Empty(( cQryRfeAlias )->RFE_FILIAL) .and. !(AllTrim(( cQryRfeAlias )->RFE_FILIAL) $ cFilSRA)
								( cQryRfeAlias )->( dbSkip() )
								Loop
							EndIf 
	        			Else
							If !( ( cQryRfeAlias )->CRACHA == cCracha ) .or. !( ( cQryRfeAlias )->DDATE == dData )
								Exit
							EndIf
	        			EndIf

						/*/
						�������������������������������������������������������������Ŀ
						� Obtem o conteudo dos campos                                 �
						���������������������������������������������������������������/*/
						If lPort1510
							dData   := ( cQryRfeAlias )->RFE_DATA
							nHora   := ( cQryRfeAlias )->RFE_HORA
							cCodRel := ( cQryRfeAlias )->RFE_RELOGI
							cFuncao := ( cQryRfeAlias )->RFE_FUNCAO
							cGiro   := ( cQryRfeAlias )->RFE_GIRO
							cCusto  := ( cQryRfeAlias )->RFE_CC
							cNumRep := ( cQryRfeAlias )->RFE_NUMREP
							cEmpOrg := ( cQryRfeAlias )->RFE_EMPORG
							cDhOrg	:= ( cQryRfeAlias )->RFE_DHORG
							cIdOrg  := ( cQryRfeAlias )->RFE_IDORG
						Else
							nHora   := ( cQryRfeAlias )->HORA
							cCodRel := ( cQryRfeAlias )->CODREL
							cFuncao := ( cQryRfeAlias )->FUNCAO
							cGiro   := ( cQryRfeAlias )->GIRO
							cCusto  := ( cQryRfeAlias )->CUSTO
						EndIf

	 						/*/
						�������������������������������������������������������������Ŀ
						� N�o considera marca��es que n�o sejam do rel�gio atual.     �
						���������������������������������������������������������������/*/
						IF !( lRfeQryOpened ) .and. ( cCodRel <> cRelogio )
							( cQryRfeAlias )->( dbSkip() )
							Loop
						EndIF

						If SRA->RA_SITFOLH == 'D' .and. lPort1510 .and. SRA->RA_DEMISSA <= dData
							( cQryRfeAlias )->( dbSkip() )
							Loop
						EndIf

						/*/
						��������������������������������������������������������������Ŀ
						� Numero de Marcacoes Lidas                                    �
						����������������������������������������������������������������/*/
						++nLidas

						/*/
						��������������������������������������������������������������Ŀ
						� Consiste Funcion�rio quanto � Admiss�o                      �
						����������������������������������������������������������������/*/
						If SRA->RA_ADMISSA > dData
							( cQryRfeAlias )->( dbSkip() )
							Loop
						EndIf

						/*/
						�������������������������������������������������������������Ŀ
						� Controle de refeitorio.                                     �
						���������������������������������������������������������������/*/
						IF ( cControle == "R" )
							cMvDespRef	:= StrTran(Upper(Alltrim(SuperGetMv("MV_DESPREF",,"",cFilSRA)))," ","")
							nDespRef	:= Val( SubStr( cMvDespRef , 2 ) )
							Ponm010Ref(cCodRel,cFilSRA,cMatricula,dData,nHora,Ponm010CcChk( cCusto ),SubStr(cMvDespRef,1,1),nDespRef,@nGravadas)

							If lPort1510
								/*/
								�������������������������������������������������������������Ŀ
								� Atualiza Flag de marcacao do RFE                            �
								���������������������������������������������������������������/*/
								If lRfeQryOpened
									dbSelectArea(cQryRfeAlias)
									nRecQry := (cQryRfeAlias)->RECNO
									dbSelectArea(cAliasRFE)
									( cAliasRFE )->(dbGoTo(nRecQry))
									IF RecLock( cAliasRFE , .F. )
										( cAliasRFE )->RFE_FLAG   := "1"
										( cAliasRFE )->( MsUnLock() )
									EndIf
									dbSelectArea(cQryRfeAlias)
								Else
									IF RecLock( cQryRfeAlias , .F. )
										( cQryRfeAlias )->RFE_FLAG   := "1"
										( cQryRfeAlias )->( MsUnLock() )
									EndIf
								EndIf
							EndIf

							( cQryRfeAlias )->( dbSkip() )
							Loop
						EndIF

						/*/
						�������������������������������������������������������������Ŀ
						� Verifica se Esta Dentro do Intervalo definido do MV_DESPMIN �
						���������������������������������������������������������������/*/
						lIntMen := lDespMin .And. ( aScan( aLastMarca , { |x| ( __Min2Hrs( DataHora2Val( x[ 1 ] , x[ 2 ] , dData , nHora ) ) <= nDespMin ) .and. ( x[ 4 ] <> 'A' .or.  ( lGetMarcAuto .and. x[ 4 ] == 'A'))} ) > 0 )

						/*/
						�������������������������������������������������������������Ŀ
						� N�o Considera Marca��es com intervalo menor que o permitido �
						���������������������������������������������������������������/*/
						IF ( lIntMen ) .and. !lPort1510 //-- Se portaria estiver ativa gravara como desconsiderada
							/*/
							��������������������������������������������������������������Ŀ
							� PONTO DE ENTRADA                                             �
							� Chamado quando alguma marcacao for descartada em funcao do   �
							� parametro MV_DESPMIN.                                        �
							����������������������������������������������������������������/*/
							IF ( lPonaPo6Block )
								/*/
								�������������������������������������������������������������Ŀ
								� Atualizo a Variavel cCusto para Uso no Ponto de Entrada	  �
								���������������������������������������������������������������/*/
								cCusto := Ponm010CcChk( cCusto )
								/*/
								�������������������������������������������������������������Ŀ
								� Troca Filiais para Integridade		                      �
								���������������������������������������������������������������/*/
							    cFilAnt	:= IF( !Empty( cFilSRA ) , cFilSRA , cFilAnt )
								ExecBlock( "PONAPO6" , .F. , .F. )
								cFilAnt	:= cSvFilAnt
							EndIF

							( cQryRfeAlias )->( dbSkip() )
							Loop
						EndIF

						/*/
						�������������������������������������������������������������Ŀ
						� Carrega aMarcacoes                                          �
						���������������������������������������������������������������/*/
						aMarcacoes[ 01 , 1    	] := dData					//01 - Data da Marcacao
						aMarcacoes[ 01 , 2    	] := nHora					//02 - Hora da Marcacao
						aMarcacoes[ 01 , 3   	] := cP8Ordem				//03 - Ordem da Marcacao
						aMarcacoes[ 01 , 4    	] := "E"					//04 - Flag (Origem) da Marcacao
						aMarcacoes[ 01 , 5   	] := 0						//05 - Recno
						aMarcacoes[ 01 , 6   	] := cP8Turno				//06 - Turno da Marcacao (Sera Carregado na PutOrdMarc())
						aMarcacoes[ 01 , 7  	] := cFuncao				//07 - Funcao do Relogio
						aMarcacoes[ 01 , 8    	] := cGiro					//08 - Giro do Relogio
						aMarcacoes[ 01 , 9      	] := Ponm010CcChk( cCusto )	//09 - Centro de Custo da Marcacao
						aMarcacoes[ 01 , 10  	] := "N"					//10 - Flag de Marcacao Apontada
						aMarcacoes[ 01 , 11	] := cCodRel				//11 - Relogio da Marcacao
						aMarcacoes[ 01 , 12	] := cP8TpMarca				//12 - Flag de Tipo de Marcacao
						aMarcacoes[ 01 , 13	] := .F.					//13 - Define Se a Marcacao Pode ou Nao ser (Re)Ordenada
						aMarcacoes[ 01 , 15] := cPerAponta				//15 - String de Data com o Periodo de Apontamento
						If lPort1510
							aMarcacoes[ 01 , 25		] := CtoD('//')					  		//25 - Data de Apontamento
							aMarcacoes[ 01 , 26		] := cNumRep					   		//26 - Numero do REP
							aMarcacoes[ 01 , 27		] := If(lIntMen,"D",Space(01))	   		//27 - Tipo de Marcacao no REP
							aMarcacoes[ 01 , 28		] := "O"								//28 - Tipo de Registro
							aMarcacoes[ 01 , 29		] := If(lIntMen,cMotivo,cSpaceMotVrg)	//29 - Motivo da desconsideracao/inclusao
							aMarcacoes[ 01 , 31		] := cEmpOrg					   		//31 - Empresa Origem da marcacao
							aMarcacoes[ 01 , 32		] := cFilSRA       				   		//32 - Filial Origem da marcacao
							aMarcacoes[ 01 , 33		] := cMatricula							//33 - Matricula Origem da marcacao
							aMarcacoes[ 01 , 34		] := cDhOrg								//34 - Data/Hora Origem da marcacao
							aMarcacoes[ 01 , 35		] := cIdOrg						   		//35 - Identificacao da Origem da marcacao

							If lRfeQryOpened
								nRecQry := (cQryRfeAlias)->RECNO
								dbSelectArea(cAliasRFE)
								( cAliasRFE )->(dbGoTo(nRecQry))

								IF RecLock( cAliasRFE , .F. )
									( cAliasRFE )->RFE_FILORG := cFilSRA
									( cAliasRFE )->RFE_MATORG := cMatricula
									( cAliasRFE )->RFE_NATU   := "0"
									( cAliasRFE )->RFE_FLAG   := "1"
									( cAliasRFE )->( MsUnLock() )
								EndIf
								dbSelectArea(cQryRfeAlias)
							Else
								IF RecLock( cQryRfeAlias , .F. )
									( cQryRfeAlias )->RFE_FILORG := cFilSRA
									( cQryRfeAlias )->RFE_MATORG := cMatricula
									( cQryRfeAlias )->RFE_NATU   := "0"
									( cQryRfeAlias )->RFE_FLAG   := "1"
									( cQryRfeAlias )->( MsUnLock() )
								EndIf
							EndIf
						EndIf

						/*/
						�������������������������������������������������������������Ŀ
						� Carrega a Nova Marcacao a Ser Gravadas                 	  �
						���������������������������������������������������������������/*/
						aAdd( aNewMarca		, aClone( aMarcacoes[ 01 ] ) )

						/*/
						�������������������������������������������������������������Ŀ
						� Carrega Marcacao para Comparacao no MV_DESPMIN			  �
						���������������������������������������������������������������/*/
						aAdd( aLastMarca	, aClone( aMarcacoes[ 01 ] ) )

						/*/
						�������������������������������������������������������������Ŀ
						� Posiciona na Proxima marca�ao                               �
						���������������������������������������������������������������/*/

						( cQryRfeAlias )->( dbSkip() )

					EndDo

				Next nCracha

			Next nLoop

			If lRfeQryOpened
				(cQryRfeAlias)-> (dbCloseArea())
				RestArea( aGetArea )
				lRfeQryOpened	:=	.F.
			EndIf
        Else
			// Atualizacao Automatica
			nLoops := Len(aAutoItens)
			For nLoop := 1 To nLoops
				If aScan(aAutoItens[nLoop], { |x| GetSx3Cache(x[1], "X3_PROPRI") == "U"  } ) > 0
					lCpoUser	:= .T.
					Exit
				EndIf
			Next nLoop			

			For nLoop := 1 To nLoops


				/*/
				�������������������������������������������������������������Ŀ
				� Verifica a existencia das marcacoes e desconsidera          �
				���������������������������������������������������������������/*/
				dbSelectArea("SP8")
				dbSetOrder(2)
				If dbSeek( Pn010AutoRead( aAutoItens[nLoop] , "P8_FILIAL" ) + ;
							Pn010AutoRead( aAutoItens[nLoop] , "P8_MAT" ) + ;
							DTOS(Pn010AutoRead( aAutoItens[nLoop] , "P8_DATA" )) + ;
							STR(Pn010AutoRead( aAutoItens[nLoop] , "P8_HORA" ),5,2) 	)
							aAdd(aLogFile,"Marca��o j� existente!" + " - " + DTOC(Pn010AutoRead( aAutoItens[nLoop] , "P8_DATA" ))+ " - " + STR(Pn010AutoRead( aAutoItens[nLoop] , "P8_HORA" ),5,2) ) // "Marca��o j� existente!"
					Loop
				Endif

				dbSelectArea("SRA")

				/*/
				�������������������������������������������������������������Ŀ
				� Carrega aMarcacoes                                          �
				���������������������������������������������������������������/*/
				aMarcacoes[ 01 , 1    	] := Pn010AutoRead( aAutoItens[nLoop] , "P8_DATA" )					//01 - Data da Marcacao
				aMarcacoes[ 01 , 2    	] := Pn010AutoRead( aAutoItens[nLoop] , "P8_HORA" )			//02 - Hora da Marcacao
				aMarcacoes[ 01 , 3   	] := " "					//03 - Ordem da Marcacao
				aMarcacoes[ 01 , 4    	] := "I"					//04 - Flag (Origem) da Marcacao
				aMarcacoes[ 01 , 5   	] := 0						//05 - Recno
				aMarcacoes[ 01 , 6   	] := SRA->RA_TNOTRAB		//06 - Turno da Marcacao (Sera Carregado na PutOrdMarc())
				aMarcacoes[ 01 , 7  	] := " "					//07 - Funcao do Relogio
				aMarcacoes[ 01 , 8    	] := " "					//08 - Giro do Relogio
				aMarcacoes[ 01 , 9      	] := SRA->RA_CC				//09 - Centro de Custo da Marcacao
				aMarcacoes[ 01 , 10  	] := "N"					//10 - Flag de Marcacao Apontada
				aMarcacoes[ 01 , 11	] := " "					//11 - Relogio da Marcacao
				aMarcacoes[ 01 , 12	] := " "					//12 - Flag de Tipo de Marcacao
				aMarcacoes[ 01 , 13	] := .F.					//13 - Define Se a Marcacao Pode ou Nao ser (Re)Ordenada
				aMarcacoes[ 01 , 15] := " "					//15 - String de Data com o Periodo de Apontamento
				If lPort1510
					aMarcacoes[ 01 , 25		] := CtoD('//')					  		//25 - Data de Apontamento
					aMarcacoes[ 01 , 26		] := " "						   		//26 - Numero do REP
					aMarcacoes[ 01 , 27		] := " "						   		//27 - Tipo de Marcacao no REP
					aMarcacoes[ 01 , 28		] := "I"								//28 - Tipo de Registro
					aMarcacoes[ 01 , 29		] := fInitMotivo(xFilial("RFD"),"1","1")//29 - Motivo da desconsideracao/inclusao
					aMarcacoes[ 01 , 31		] := " "						   		//31 - Empresa Origem da marcacao
					aMarcacoes[ 01 , 32		] := " "   	    				   		//32 - Filial Origem da marcacao
					aMarcacoes[ 01 , 33		] := " "								//33 - Matricula Origem da marcacao
					aMarcacoes[ 01 , 34		] := " "								//34 - Data/Hora Origem da marcacao
					aMarcacoes[ 01 , 35		] := " "						   		//35 - Identificacao da Origem da marcacao
				EndIf
				If lGeolocal
					aMarcacoes[ 01 , 36	] := " "					  				//36 - Latitude (marcacao geolocalizacao)
					aMarcacoes[ 01 , 37	] := " "				 					//37 - Longitude (marcacao geolocalizacao)
				EndIf
				If lCpoUser
					aEval( aAutoItens[nLoop], { |x| Iif( GetSx3Cache(x[1], "X3_PROPRI") == "U", aAdd(aMarcacoes[ 01 ], {x[1], x[2]}), Nil ) } ) 
				EndIf

				/*/
				�������������������������������������������������������������Ŀ
				� Carrega a Nova Marcacao a Ser Gravadas                 	  �
				���������������������������������������������������������������/*/
				aAdd( aNewMarca		, aClone( aMarcacoes[ 01 ] ) )

				/*/
				�������������������������������������������������������������Ŀ
				� Carrega Marcacao para Comparacao no MV_DESPMIN			  �
				���������������������������������������������������������������/*/
				aAdd( aLastMarca	, aClone( aMarcacoes[ 01 ] ) )

			Next nLoop

        Endif

		/*/
		�������������������������������������������������������������Ŀ
		� Contador para Numero de Marcacoes Gravadas                  �
		���������������������������������������������������������������/*/
		nGravadas += Len( aNewMarca )

		/*/
		�������������������������������������������������������������Ŀ
		� Grava o arquivo de marca��es.                               �
		���������������������������������������������������������������/*/
		PutMarcacoes( aNewMarca , cFilSRA , cMatricula , "SP8" , .T., Nil, Nil, Nil, lWorkFlow, nTipo, lCpoUser )

		SRA->( dbSkip() )

	EndDo

End Sequence

cFilAnt := cSvFilAnt

Return( NIL )

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �GetCracha    � Autor �Marinaldo de Jesus   � Data �22/01/2003�
������������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Cracha do Funcionario								 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �GetMrBySra() em PONM010                                      �
��������������������������������������������������������������������������/*/
Static Function GetCracha( dData, aProvCrachas )
Local aCrachas	:= { }
Local cPIS		:= ""
Local nI

If !lREP
	aAdd( aCrachas, SRA->RA_CRACHA )
Else
	If Len(cPIS := AllTrim(SRA->RA_PIS)) == 11
		cPIS	:= PadL( cPIS, nLenPIS, "0" )
	EndIf
	aAdd( aCrachas, cPIS )
EndIf

For nI:= 1 to Len(aProvCrachas)
		If ( dData >= aProvCrachas[nI, 2] ) .and. 	( dData <=  aProvCrachas[nI, 3] )
			cCracha :=  aProvCrachas[nI, 1]
			aAdd( aCrachas , cCracha  )
			Exit
		EndIF
Next nI

Return( aCrachas )

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �GetProv      � Autor �Marinaldo de Jesus   � Data �22/01/2003�
������������������������������������������������������������������������Ĵ
�Descri��o �                                					 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �                                                             �
��������������������������������������������������������������������������/*/
Static Function GetProv(dPerIni, dPerFim)

Local aCrachas	:= {}
Local cFilSPE 	:= xFilial( "SPE" , SRA->RA_FILIAL )
Local cKeySeek	:= ( cFilSPE + SRA->RA_MAT )

IF SPE->( MsSeek( cKeySeek , .F. ) )
	While SPE->( !Eof() .and. ( cKeySeek == ( PE_FILIAL + PE_MAT ) ) )
		IF SPE->(;
					( PE_DATAINI > dPerFim );
					.or.;
					( PE_DATAFIM < dPerIni );
				)
				SPE->( dbSkip() )
				Loop
		Else
			aAdd( aCrachas , {AllTrim( SPE->PE_MATPROV ), SPE->PE_DATAINI, SPE->PE_DATAFIM} )
		Endif
		SPE->( dbSkip() )
	EndDo
EndIF

Return( aCrachas )

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �GetMrBySp0	 � Autor �Marinaldo de Jesus   � Data �07/09/2004�
������������������������������������������������������������������������Ĵ
�Descri��o �Obtem as marcacoes dos Funcionarios							 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/
Static Function GetMrBySp0()

Local cSvFilAnt		:= cFilAnt
Local lFound		:= .F.
Local nDespMin		:= GetDespMin()

Local aMarcacoes
Local aTbMultAux	:= {}

Local cMvDespRef
Local cMvDespVis
Local cMarcFer
Local cKeyAux
Local cKeyCracha
Local cTipAfas
Local cNumRep
Local cEmpOrg
Local cDhOrg
Local cIdOrg
Local cSpaceMotVrg := If(lPort1510,Space( GetSx3Cache( "P8_MOTIVRG" , "X3_TAMANHO" ) ),Nil)
Local cMotivo	   := If(lPort1510, fInitMotivo( xFilial("RFD"), "1" , "3" ),Nil)

Local dIniAfas
Local dFimAfas

Local lDespMin		:= ( nDespMin != 0 )//com o parametro igual o zero, nao havera desprezo de marcacoes
Local lIntMen
Local lGetMarcAuto	:= .F.
Local lMarcQryOpened := .F.
Local lREP			:= .F.
Local lExit			:= .F.

Local nDespVis
Local nOrdSRA
Local nSerMarc
Local nPos
Local nLastRec
Local nCount
Local nLenaFuncs
Local nPosDia		:= 0
Local nHorFim		:= 0
Local nSerMIni		:= 0
Local nSerMFim		:= 0
Local nSerMar		:= 0

Static nSerIni
Static nSerFim

Local cQuery	 		:= ""
Local cQueryMarc		:= ""
Local cSvQuery			:= ""
Local cSvFil			:= ""
Local cSvMat			:= ""
Local cSvDat			:= ""
Local cFilRFE			:= ""
Local cPrefixo			:= ( PrefixoCpo( cAliasSP8 ) + "_" )
Local cSp8Fields		:= ( Padr( cPrefixo+"FILIAL" , 10 ) + "/" + Padr( cPrefixo+"MAT" , 10) + "/" + Padr( cPrefixo+"DATA" , 10 )+ "/" + Padr( cPrefixo+"DATAAPO" , 10 )+ "/" + Padr( cPrefixo+"HORA" , 10 ) + "/" + Padr( cPrefixo+"FLAG" , 10 ) )
Local cSp8RetSqlName	:= InitSqlName( cAliasSP8 )
Local lChangeQry		:= .T.
Local lSP0Comp			:= FWModeAccess("SP0",1) == "C" .AND. FWModeAccess("SP0",2) == "C" .AND. FWModeAccess("SP0",3) == "C"
Local nField			:= 0

If lPort1510
	Private aGetArea		:= {}
	Private cAliasMarc		:= ""

	cAliasMarc		:= "RFE"

	Private cPrefMarc		:= ( PrefixoCpo( cAliasMarc ) + "_" )
	Private cMarcRetSqlName	:= InitSqlName( cAliasMarc )
	Private cPerDe			:= ""
	Private cPerAte			:= ""
	Private nRecQry			:= 0

	DEFAULT aMarcFields		:= ( cAliasMarc )->( dbStruct() )
	DEFAULT nMarcFields 	:= Len( aMarcFields )

	cQryMarcAlias := ( "__Q" + cAliasMarc + "QRY" )

EndIf

cQrySp8Alias := ( "__Q" + cAliasSP8 + "QRY" )

Private lMultVinc	:= .F.
Private aTabMult	:= {}

Begin Sequence

	/*/
	��������������������������������������������������������������Ŀ
	� Aqui Fecho a Query do SRA.                                   �
	����������������������������������������������������������������/*/
	IF ( lSraQryOpened )
		SRA->( dbCloseArea() )
		ChkFile( "SRA" )
	EndIF

	lSraQryOpened := .F.

	If lPort1510
		lREP := !Empty(SP0->P0_REP) .Or. (lCaClockIn .And. SP0->P0_TIPOARQ == "R") 
	EndIf

	If !lTSREP .And. !lREP .Or. !lPort1510
		SRA->( dbSetOrder( RetOrdem( "SRA" , "RA_CRACHA+RA_FILIAL" ) ) )
	Else
		SRA->( dbSetOrder( RetOrdem( "SRA" , "RA_PIS+RA_FILIAL" ) ) )
	EndIf
	SPE->( dbSetOrder( RetOrdem( "SPE" , "PE_FILIAL+PE_MATPROV+PE_MAT+DTOS(PE_DATAINI)" ) ) )
	SP8->( dbSetOrder( RetOrdem( "SP8" , "P8_FILIAL+P8_MAT+DTOS(P8_DATA)+STR(P8_HORA,5,2)" ) ) )

	/*/
	��������������������������������������������������������������Ŀ
	� Inicia regua de processamento.                               �
	����������������������������������������������������������������/*/
	IF !( lWorkFlow )
		/*/
		��������������������������������������������������������������Ŀ
		� Verifica o Total de Registros a Serem Processados            �
		����������������������������������������������������������������/*/
		nLastRec := ( cTxtAlias )->( LastRec() )
		/*/
		��������������������������������������������������������������Ŀ
		� Seta a Regua de Processamento (2a. BarGauge)                 �
		����������������������������������������������������������������/*/
		BarGauge2Set( nLastRec )
	EndIF

	//--Integracao SIGAPON x TSREP
	If lPort1510
		dbSelectArea( cTxtAlias )
	EndIf

	//Se a portria estiver ativa e for TOP, cria query da RFE
	If lPort1510 .and. TcSrvType() != "AS/400"
		aGetArea	:= GetArea()
		cPerDe      := DtoS(dPerDe - nDiasExtA)
		cPerAte     := DtoS(dPerAte + nDiasExtP)

		( cTxtAlias )->(dbSetOrder(RetOrder("RFE","RFE_FILIAL+RFE_CRACHA+DTOS(RFE_DATA)+STR(RFE_HORA,5,2)")))

		cQueryMarc := "SELECT "
  		For nField := 1 To nMarcFields
			cQueryMarc += aMarcFields[ nField , 01 ] + ", "
		Next nField

		cQueryMarc += "R_E_C_N_O_ RECNO  "

		cQueryMarc := SubStr( cQueryMarc , 1 , Len( cQueryMarc ) - 2 )

		cQueryMarc += ( " FROM " + cMarcRetSqlName + " " + cAliasMarc )
		cQueryMarc += ( " WHERE ( " )

		cQueryMarc += ( cAliasMarc + "." + cPrefMarc )
		cQueryMarc += ( "FILIAL>='"+cFilDe+"'" )
		cQueryMarc += ( " AND " )
		cQueryMarc += ( cAliasMarc + "." + cPrefMarc )
		cQueryMarc += ( "FILIAL<='"+cFilAte+"'" )
		cQueryMarc += ( " ) AND ( " )
		cQueryMarc += ( cAliasMarc + "." + cPrefMarc )
		cQueryMarc += ( "DATA>='"+cPerDe+"'" )
		cQueryMarc += ( " AND " )
		cQueryMarc += ( cAliasMarc + "." + cPrefMarc )
		cQueryMarc += ( "DATA<='"+cPerAte+"'" )
		cQueryMarc += ( " ) AND ( " )
		cQueryMarc += ( cAliasMarc + "." + cPrefMarc )
		cQueryMarc += ( "FLAG='0'" )
		cQueryMarc += ( " OR " )
		cQueryMarc += ( cAliasMarc + "." + cPrefMarc )
		cQueryMarc += ( "NATU='3'" )
		cQueryMarc += ( " ) AND " )
		cQueryMarc += ( cAliasMarc + "." + cPrefMarc )
		cQueryMarc += ( "RELOGI='"+cRelogio+"'" )

		cQueryMarc += ( " AND " )

		cQueryMarc += ( cAliasMarc + ".D_E_L_E_T_=' ' " )
		cQueryMarc += ( "ORDER BY " + SqlOrder( (cAliasMarc)->( IndexKey() ) ) )
		/*/
		�������������������������������������������������������������Ŀ
		� Salva Query Atual Para Posterior Remontagem                 �
		���������������������������������������������������������������/*/
		cSvQuery	:= cQueryMarc

		cQueryMarc := ChangeQuery( cQueryMarc )

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryMarc), cQryMarcAlias, .F., .T.)

		For nField := 1 To nMarcFields
			IF !( aMarcFields[ nField , 02 ] == "C" )
				TcSetField(cQryMarcAlias,aMarcFields[nField,01],aMarcFields[nField,02],aMarcFields[nField,03],aMarcFields[nField,04])
			EndIF
		Next nField

		lMarcQryOpened := .T.

	EndIf

	/*/
	��������������������������������������������������������������Ŀ
	� Pocisiona no Inicio do Arquivo a Ser Lido e Verifica o Numero�
	� de Campos                                                    �
	����������������������������������������������������������������/*/
	If !lMarcQryOpened
		cQryMarcAlias := cTxtAlias
		( cQryMarcAlias )->( dbGotop() )
	EndIf

	/*/
	��������������������������������������������������������������Ŀ
	� Loop para ler o arquivo gerado pelo relogio.                 �
	����������������������������������������������������������������/*/
	While ( cQryMarcAlias )->( !Eof() )

		/*/
		��������������������������������������������������������������Ŀ
		� Aborta o processamento 									   �
		����������������������������������������������������������������/*/
		IF ( lAbortPrint )
			aAdd(aLogFile, '- Cancelado pelo Operador em '  + Dtoc(MsDate()) + ', as ' + Time() + ' ...') // '- Cancelado pelo Operador em '
			Break
		EndIF

		/*/
		�������������������������������������������������������������Ŀ
		� Obtem o conteudo dos campos                                 �
		���������������������������������������������������������������/*/
		If lPort1510
			/*/
			��������������������������������������������������������������Ŀ
			� Desconsidera as marcacoes ja processadas e cujo cracha foi   �
			� reconhecido.												   �
			����������������������������������������������������������������/*/
			If !(( cQryMarcAlias )->RFE_FLAG == "0")  .AND. (( cQryMarcAlias )->RFE_NATU <> "3")
				( cQryMarcAlias )->( dbSkip() )
				Loop
			EndIf
			If !lSP0Comp
				cFilRFE := ( cQryMarcAlias )->RFE_FILIAL
			Else
				cFilRFE := ""
			EndIf
			cCracha := ( cQryMarcAlias )->RFE_CRACHA
			cPIS	:= AllTrim(( cQryMarcAlias )->RFE_PIS)
			dData	:= ( cQryMarcAlias )->RFE_DATA
			nHora   := ( cQryMarcAlias )->RFE_HORA
			cCodRel := ( cQryMarcAlias )->RFE_RELOGI
			cFuncao := ( cQryMarcAlias )->RFE_FUNCAO
			cGiro   := ( cQryMarcAlias )->RFE_GIRO
			cCusto  := ( cQryMarcAlias )->RFE_CC
			cNumRep := ( cQryMarcAlias )->RFE_NUMREP
			cEmpOrg := ( cQryMarcAlias )->RFE_EMPORG
			cDhOrg	:= ( cQryMarcAlias )->RFE_DHORG
			cIdOrg  := ( cQryMarcAlias )->RFE_IDORG
		ElseIf !lTSREP .And. !lPort1510
			cCracha := ( cQryMarcAlias )->CRACHA
			dData	:= ( cQryMarcAlias )->DDATE
			nHora   := ( cQryMarcAlias )->HORA
			cCodRel := ( cQryMarcAlias )->CODREL
			cFuncao := ( cQryMarcAlias )->FUNCAO
			cGiro   := ( cQryMarcAlias )->GIRO
			cCusto  := ( cQryMarcAlias )->CUSTO
		EndIf

		/*/
		�������������������������������������������������������������Ŀ
		� N�o considera marca��es que n�o sejam do rel�gio atual.     �
		���������������������������������������������������������������/*/
		If !lTSREP .And. !( lMarcQryOpened ) .and. ( cCodRel # cRelogio )
			( cQryMarcAlias )->( dbSkip() )
			Loop
		EndIf

		/*/
		��������������������������������������������������������������Ŀ
		� Numero de Marcacoes Lidas                                    �
		����������������������������������������������������������������/*/
		++nLidas

		/*/
		��������������������������������������������������������������Ŀ
		� Incrementa a Regua de Processamento                          �
		����������������������������������������������������������������/*/
		IF !( lWorkFlow )
			//'Lidas...: '
			IncPrcG2Time( 'Lidas...: ' , nLastRec , cTimeIni , .F. , nCountTime , nIncPercG2 )
		EndIF

		/*/
		�������������������������������������������������������������Ŀ
		� Se Relogio for de Acesso Grava Marcacao Sem consistir Cracha�
		���������������������������������������������������������������/*/
		If (cControle == "A" )

		    /*/
			�������������������������������������������������������������Ŀ
			� Desconsidera marca��es fora do periodo informado			  �
			���������������������������������������������������������������/*/
			IF ( ( ( nSerMarc := __fDhtoNS(dData,nHora) ) < nSerIniVis ) .or. ( nSerMarc > nSerFimVis  ) )
				( cQryMarcAlias )->( dbSkip() )
				Loop
			EndIF

			/*/
			��������������������������������������������������������������Ŀ
			� Trata as Marcacoes de Acessos						           �
			����������������������������������������������������������������/*/
			cMvDespVis	:= StrTran(Upper(Alltrim(SuperGetMv("MV_DESPVIS",,"N99",cFilSPZ)))," ","")
			nDespVis	:= Val( SubStr( cMvDespVis , 2 ) )
		   	fVisitante(cFilSPZ, cCracha, cSpyCracha , nLenSpyCracha, cSpyVisita, nLenSpyVisita, cSpyNumero, nLenSpyNumero, dData, nHora, cCodRel, cCusto, @nGravadas, SubStr(cMvDespVis,1,1), nDespVis )

		   	If lPort1510
				If lMarcQryOpened
				   	nRecQry := ( cQryMarcAlias )->RECNO
			   		dbSelectArea(cAliasMarc)
			   		( cAliasMarc )->(dbGoTo(nRecQry))
					IF RecLock( cAliasMarc , .F. )
						( cAliasMarc )->RFE_NATU   := "2"
						( cAliasMarc )->RFE_FLAG   := "1"
						( cAliasMarc )->( MsUnLock() )
					EndIf
					dbSelectArea(cQryMarcAlias)
				Else
					IF RecLock( cQryMarcAlias , .F. )
						( cQryMarcAlias )->RFE_NATU   := "2"
						( cQryMarcAlias )->RFE_FLAG   := "1"
						( cQryMarcAlias )->( MsUnLock() )
					EndIf
		   		EndIf
		   	EndIf

		   	( cQryMarcAlias )->( dbSkip() )
			Loop
		Endif

		/*/
		�������������������������������������������������������������Ŀ
		� Adiciona crach� na lista de "Crach�s de Visitantes"         �
		���������������������������������������������������������������/*/
		If !lTSREP .And. ( cCracha >= cIniVisita .and. cCracha <= cFimVisita )
			If (nPos := aScan(aVisitante, {|x| x[1] == cCracha})) > 0
				aVisitante[nPos,2] ++
			Else
				aAdd(aVisitante, {cCracha, 1})
			EndIf
		   	If lPort1510
				If lMarcQryOpened
				   	nRecQry := ( cQryMarcAlias )->RECNO
			   		dbSelectArea(cAliasMarc)
			   		( cAliasMarc )->(dbGoTo(nRecQry))
					IF RecLock( cAliasMarc , .F. )
						( cAliasMarc )->RFE_NATU   := "1"
						( cAliasMarc )->RFE_FLAG   := "1"
						( cAliasMarc )->( MsUnLock() )
					EndIf
					dbSelectArea(cQryMarcAlias)
				Else
					IF RecLock( cQryMarcAlias , .F. )
						( cQryMarcAlias )->RFE_NATU   := "1"
						( cQryMarcAlias )->RFE_FLAG   := "1"
						( cQryMarcAlias )->( MsUnLock() )
					EndIf
				EndIf
		   	EndIf
			( cQryMarcAlias )->( dbSkip() )
			Loop
		EndIf

		/*/
		�������������������������������������������������������������Ŀ
		� Posiciona o Arquivo de Funcion�rios de acordo com o Crach�  �
		���������������������������������������������������������������/*/
		lFound		:= .T.
		If !lTSREP .And. !lREP
			cKeyCracha	:= Left( cCracha + cSpCracha , nLenCracha )
		ElseIf !lTSREP .And. lREP
			If Len( cPIS ) == 12
				cPIS	:= SubStr( cPIS, 2, 11 )
			EndIf
			cKeyCracha	:= cPIS
		ElseIf lTSREP
			cPIS		:= cValToChar( cPIS )
			If Len( cPIS ) == 12
				cPIS	:= SubStr( cPIS, 2, 11 )
			EndIf
			If !Empty(cPis)
				cKeyCracha	:= cPIS
			Else
				cKeyCracha	:= Left( cCracha + cSpCracha , nLenCracha )
			Endif
		EndIf

        //For�a SetOrder para o SRA.
	    If lPort1510
	        If !( SRA->(IndexOrd()) >= 1 ) .Or. (Empty(cPIS) .And. lTSREP)
		        If (!lTSREP .And. !lREP) .Or. Empty(cPIS)
					SRA->( dbSetOrder( RetOrdem( "SRA" , "RA_CRACHA+RA_FILIAL" ) ) )
				Else
					SRA->( dbSetOrder( RetOrdem( "SRA" , "RA_PIS+RA_FILIAL" ) ) )
				EndIf
			EndIf
		Else
         	If !( SRA->(IndexOrd()) >= 1 )
				SRA->( dbSetOrder( RetOrdem( "SRA" , "RA_CRACHA+RA_FILIAL" ) ) )
			Endif
		Endif
		IF SRA->( !MsSeek( cKeyCracha , .F. ) )
			lFound		:= .F.
			cKeyCracha	:= Left( cCracha + cSpMatPrv , nLenMatPrv )

	 		/*/
			�������������������������������������������������������������Ŀ
			� Para localizar a filial cracha provisorio considera a filial�
			| do relogio, caso o arquivo seja exclusivo					  |
			���������������������������������������������������������������/*/
	 		cFilSPE	 	:= xFilial( "SPE" , If ( !Empty(cFilRelLid), cFilRelLid, cFilSP0) )
		 	/*/
			�������������������������������������������������������������Ŀ
			� Procura no Cadastro de Crachas Provisorios                  �
			���������������������������������������������������������������/*/
			IF SPE->( MsSeek( cFilSPE + cKeyCracha , .F. ) )
				nOrdSRA := SRA->( IndexOrd() )
				SRA->( dbSetOrder( RetOrdem( "SRA" , "RA_FILIAL+RA_MAT" ) ) )
				cKeyAux := ( cFilSPE + cKeyCracha )
				While SPE->( !Eof() .and. cKeyAux == ( PE_FILIAL + PE_MATPROV ) )
					IF SPE->( ( dData >= PE_DATAINI ) .and. ( dData <= PE_DATAFIM ) )
						cFilSRA := xFilial( "SRA" , IF( Empty( cFilSPE ) , NIL , cFilSPE ) )
						IF ( lFound := SRA->( MsSeek( cFilSRA + SPE->PE_MAT , .F. ) ) )
							cFilSRA		:= SRA->RA_FILIAL
							cMatricula	:= SRA->RA_MAT
							Exit
						EndIF
					EndIF
					SPE->( dbSkip() )
				EndDo
				SRA->( dbSetOrder( nOrdSRA ) )
			EndIF

		Else

			cFilSRA 	:= SRA->RA_FILIAL
			cMatricula	:= SRA->RA_MAT
			nRecnoSRA	:= SRA->( Recno() )

			//--Tratamento para verificar se ha multiplos vinculos, so para relogio REP
			If lREP
				aFuncs 		:= fVerMultVinc(cPIS,cFilRFE)
				nLenaFuncs 	:= Len(aFuncs)

	  			If lMultVinc
					For nCount := 1 To nLenaFuncs

						aTabCalend 	:= {}
						aTabMult 	:= {}
						lExit		:= .F.
						nHorFim		:= 0
						nSerMIni	:= 0
						nSerMFim	:= 0
						nSerMar 	:= 0

						SRA->( dbGoTo(aFuncs[nCount, 05]) )
						CriaCalend(	mv_par13		,;	//01 -> Data Inicial do Periodo
								mv_par14			,;	//02 -> Data Final do Periodo
								aFuncs[nCount, 04]	,;	//03 -> Turno Para a Montagem do Calendario
								'01'				,;	//04 -> Sequencia Inicial para a Montagem Calendario
								@aTabMult			,;	//05 -> Array Tabela de Horario Padrao
								@aTabCalend			,;	//06 -> Array com o Calendario de Marcacoes
								aFuncs[nCount, 01]	,;	//07 -> Filial para a Montagem da Tabela de Horario
								aFuncs[nCount, 02]	,;	//08 -> Matricula para a Montagem da Tabela de Horario
								aFuncs[nCount, 03]	,;	//09 -> Centro de Custo para a Montagem da Tabela
								NIL     			,;	//10 -> Array com as Trocas de Turno
								NIL					,;	//11 -> Array com Todas as Excecoes do Periodo
								NIL					,;	//12 -> Se executa Query para a Montagem da Tabela Padrao
								.T.					,;	//13 -> Se executa a funcao se sincronismo do calendario
								NIL			 		;	//14 -> Se Forca a Criacao de Novo Calendario
							  						)
						If Empty(aTabMult) .and. !Empty(aTabCalend) .and. !Empty(aTbMultAux)
							aTabMult := aTbMultAux
						EndIf
						//Procura o horario na tabela padrao de acordo com o dia da semana
						IF !Empty(aTabMult) .And. ( nPosDia := aScan( aTabMult[1][3] , { |x| x[20] == Dow( dData ) } ) ) > 0
							//Verifica o serial do horario inicial do dia
							nSerMIni  := __fDHtoNS( dData, SubHoras( aTabMult[1][3][nPosDia][1], aTabMult[1][3][nPosDia][30] ) )
							//Verifica o serial do horario final do dia
							If !Empty( aTabMult[1][3][nPosDia][8] )
								nHorFim := aTabMult[1][3][nPosDia][8]
							ElseIf !Empty( aTabMult[1][3][nPosDia][6] )
								nHorFim := aTabMult[1][3][nPosDia][6]
							ElseIf !Empty( aTabMult[1][3][nPosDia][4] )
								nHorFim := aTabMult[1][3][nPosDia][4]
							Else
								nHorFim := aTabMult[1][3][nPosDia][2]
							EndIf
							nSerMFim  := __fDHtoNS( dData, SomaHoras( nHorFim, aTabMult[1][3][nPosDia][31] ) )
							//Verifica o serial do horario da marcacao
							nSerMar  := __fDHtoNS( dData, nHora )

						If (nSerMar >= nSerMIni .And. nSerMar <= nSerMFim) .And. !Empty(SRA->RA_REGRA)
								lExit := .T.
							EndIf
						EndIF

						aTbMultAux := aTabMult

						If lExit
							Exit
						EndIf

					Next

					If !lExit
						nCount := 1
					EndIf

					If nLenaFuncs > 0
						cFilSRA 	:= aFuncs[nCount, 01]
						cMatricula	:= aFuncs[nCount, 02]
						SRA->( dbGoTo(aFuncs[nCount , 05]) )
					Else
						SRA->( dbGoTo(nRecnoSRA) )
					EndIf

				Else
					SRA->( dbGoTo(nRecnoSRA) )
				EndIf

			EndIf
		EndIF

		/*/
		�������������������������������������������������������������Ŀ
		� Adiciona crach� na lista de "Marca�oes n�o Encontradas"     �
		���������������������������������������������������������������/*/
		IF !( lFound )
			If lREP
            	cCracha := cPIS
			EndIf

			IF ( nPos := aScan(aSemCracha,{|x|x[1]==cCracha}) ) > 0
				aSemCracha[nPos,2] ++
			Else
				aAdd(aSemCracha, {cCracha, 1} )
			EndIF

		   	If !lTSREP .And. lPort1510
				If lMarcQryOpened
				   	nRecQry := ( cQryMarcAlias )->RECNO
			   		dbSelectArea(cAliasMarc)
			   		( cAliasMarc )->(dbGoTo(nRecQry))
					IF RecLock( cAliasMarc , .F. )
						( cAliasMarc )->RFE_FLAG   := "1"
						( cAliasMarc )->( MsUnLock() )
					EndIf
					dbSelectArea(cQryMarcAlias)
				Else
					IF RecLock( cQryMarcAlias , .F. )
						( cQryMarcAlias )->RFE_FLAG   := "1"
						( cQryMarcAlias )->( MsUnLock() )
					EndIf
				EndIf
		   	EndIf

			( cQryMarcAlias )->( dbSkip() )
			Loop
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� So processa para a Filial Corrente                           �
		����������������������������������������������������������������/*/
		IF lWorkFlow .And. lProcFilial .And. SP0->P0_TIPOARQ != "R"
			IF !( cFilSRA == cFilAnt )
				( cQryMarcAlias )->( dbSkip() )
				Loop
			EndIF
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Consiste Funcionarios Demitidos                              �
		����������������������������������������������������������������/*/
		IF SRA->( RA_SITFOLH == "D" .and. !Empty(RA_DEMISSA) .and. dData > RA_DEMISSA )
			( cQryMarcAlias )->( dbSkip() )
			Loop
		EndIF
		
		/*/
		��������������������������������������������������������������Ŀ
		� Se o cadastro do relogio � exclusivo n�o ser� realizada      �
		� a leitura/apontamento de funcionarios de outra filial        �
		����������������������������������������������������������������/*/
		IF !Empty( cFilRFE ) .And. !( AllTrim( cFilRFE ) $ SRA->( RA_FILIAL ) )
			( cQryMarcAlias )->( dbSkip() )
			Loop
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Consiste Funcionarios quanto � Admiss�o                      �
		����������������������������������������������������������������/*/
		IF SRA->RA_ADMISSA > dData
			( cQryMarcAlias )->( dbSkip() )
			Loop
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Consiste filtro do intervalo De / Ate ( Leituta TXT )        �
		����������������������������������������������������������������/*/
		IF SRA->( !Eval( bSraScop2 ) )
			( cQryMarcAlias )->( dbSkip() )
			Loop
		EndIf

		/*/
		��������������������������������������������������������������Ŀ
		� Consiste controle de acessos e filiais validas               �
		����������������������������������������������������������������/*/
		IF !( lWorkFlow )
			IF SRA->( !( cFilSRA $ fValidFil() ) .or. !Eval(bAcessaSRA) )
				( cQryMarcAlias )->( dbSkip() )
				Loop
			EndIF
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Consiste Afastamento do funcionario                          �
		����������������������������������������������������������������/*/
		IF fAfasta(cFilSRA,cMatricula,dData,@dIniAfas,@dFimAfas,@cTipAfas)
			cMarcFer := SuperGetMv("MV_MARCFER",,"N",cFilSRA)
			IF ( cMarcFer == "N" )
				IF (;
						( dData >= dIniAfas .and. dData <= dFimAfas );
						.or.;
				   		( dData >= dIniAfas .and. Empty( dFimAfas ) );
				   	)
					( cQryMarcAlias )->( dbSkip() )
					Loop
				EndIF
			EndIF
		EndIF

		If cFilSRA $ cFilFECAux //Per�odo bloqueado
			(cQryMarcAlias)->( dbSkip() )
			Loop
		EndIf

		/*/
		�������������������������������������������������������������Ŀ
		� Verifica o Periodo de Apontamento                           �
		���������������������������������������������������������������/*/
        IF !( cFilSRA == cFilOld )
          	cFilOld := cFilSRA

			If !lSP0Comp //Se rel�gio n�o for compartilhado, verifica se fechamento esta sendo efetuado para a filial atual
				If !Pn090Open(, ,.T.,DtoS(dPerDe) + DtoS(dPerAte),.F.,cFilSRA,.F.,"A")
					If !lWorkFlow
						aAdd( aLogFile , '- O fechamento da filial '  + cFilSRA + ' esta sendo efetuado em outro processo. Tente novamente mais tarde.' ) // '- O fechamento da filial ' + SRA->RA_FILIAL + ' esta sendo efetuado em outro processo. Tente novamente mais tarde.'
					Else
						ConOut("")
						ConOut( '- O fechamento da filial '  + cFilSRA + ' esta sendo efetuado em outro processo. Tente novamente mais tarde.' )
						ConOut("")
					EndIf
					cFilFECAux += cFilSRA + "/"
					(cQryMarcAlias)->( dbSkip() )
					Loop
				Else
					lPn090Lock := .T.
				EndIf
			EndIf


			IF !( CheckPonMes( @dPerIni , @dPerFim , .F. , .T. , ( !( lWorkFlow ) .and. !( lChkPonMesAnt ) .and. !(lMultThread) ) , cFilOld ) )
				lChkPonMesAnt := .F.
				aAdd( aLogFile , '- O Periodo Informado nos Parametros e invalido. Informe um Periodo Valido' ) 					// '- O Periodo Informado nos Parametros e invalido. Informe um Periodo Valido'
				aAdd( aLogFile , 'ou' ) 					// 'ou'
				aAdd( aLogFile , '- Nao Foi Encontrado periodo de Apontamento para a Filial: ' + " " + cFilOld )	// '- Nao Foi Encontrado periodo de Apontamento para a Filial: '
				aAdd( aLogFile , '- A Leitura/Apontamento nao puderam ser concluidos. Favor Cadastrar o Periodo' ) 					// '- A Leitura/Apontamento nao puderam ser concluidos. Favor Cadastrar o Periodo'
				IF !( lWorkFlow )
					lAbortPrint := .T.
					If lMarcQryOpened
						(cQryMarcAlias)-> (dbCloseArea())
						RestArea( aGetArea )
					EndIf
					Break
				EndIF
			Else
				lChkPonMesAnt := .T.
			EndIF

			/*
			�������������������������������������������������������������Ŀ
			� Verifica se o Periodo eh Valido              				  �
			���������������������������������������������������������������/*/
			IF !fChkPer( dPerDe , dPerAte , cFilOld )
				aAdd( aLogFile , '- O Periodo Informado nos Parametros e invalido. Informe um Periodo Valido' ) // '- O Periodo Informado nos Parametros e invalido. Informe um Periodo Valido'
				IF !( lWorkFlow )
					lAbortPrint := .T.
					Break
				EndIF
			EndIF

			If lSchedDef
				nSerIni := Round( __fDhtoNS( dPerDe - nDiasExtA, 00.00 ), 5 )
				nSerFim := Round( __fDhtoNS(mv_par14 + nDiasExtP, 23.59 ), 5 )
			Else
				nSerIni := Round( __fDhtoNS( Max( dPerIni, dPerDe  ) - nDiasExtA, 00.00 ), 5 )
				nSerFim := Round( __fDhtoNS( Min( dPerFim, dPerAte ) + nDiasExtP, 23.59 ), 5 )
			EndIf

			/*/
			�������������������������������������������������������������Ŀ
			� Verifica se Devera Carregar as Marcacoes Automaticas      em�
			� GetMarcacoes												  �
			���������������������������������������������������������������/*/
			lGetMarcAuto := ( SuperGetMv( "MV_GETMAUT" , NIL , "S" , cFilSRA ) == "S" )
		EndIF

		/*/
		�������������������������������������������������������������Ŀ
		� Desconsidera marca��es com diferen�as de datas maiores que 2�
		���������������������������������������������������������������/*/
		IF ( ( ( nSerMarc := __fDhtoNS(dData,nHora) ) < nSerIni ) .or. ( nSerMarc > nSerFim  ) )
			( cQryMarcAlias )->( dbSkip() )
			Loop
		EndIF

		/*/
		�������������������������������������������������������������Ŀ
		� Controle de refeitorio.                                     �
		���������������������������������������������������������������/*/
		IF ( cControle == "R" )
			cMvDespRef	:= StrTran(Upper(Alltrim(SuperGetMv("MV_DESPREF",,"",cFilSRA)))," ","")
			nDespRef	:= Val( SubStr( cMvDespRef , 2 ) )
			Ponm010Ref(cCodRel,cFilSRA,cMatricula,dData,nHora,Ponm010CcChk( cCusto ),SubStr(cMvDespRef,1,1),nDespRef,@nGravadas)

		   	If lPort1510
				If lMarcQryOpened
				   	dbSelectArea(cQryMarcAlias)
				   	nRecQry := ( cQryMarcAlias )->RECNO
			   		dbSelectArea(cAliasMarc)
			   		( cAliasMarc )->(dbGoTo(nRecQry))
					IF RecLock( cAliasMarc , .F. )
						( cAliasMarc )->RFE_FLAG   := "1"
						( cAliasMarc )->( MsUnLock() )
					EndIf
					dbSelectArea(cQryMarcAlias)
				Else
					IF RecLock( cQryMarcAlias , .F. )
						( cQryMarcAlias )->RFE_FLAG   := "1"
						( cQryMarcAlias )->( MsUnLock() )
					EndIf
				EndIf
			EndIf

			( cQryMarcAlias )->( dbSkip() )
			Loop
		EndIF

		/*/
		�������������������������������������������������������������Ŀ
		� Reinicializa lIntMen										  �
		���������������������������������������������������������������/*/
		lIntMen := .F.

		/*/
		�������������������������������������������������������������Ŀ
		�Transforma a Data em String para Montagem da Query e da Chave�
		�de Pesquisa												  �
		���������������������������������������������������������������/*/
		cData := Dtos( dData )

		/*/
		�������������������������������������������������������������Ŀ
		� Monta Chave Auxiliar Para Pesquisa no SP8					  �
		���������������������������������������������������������������/*/
		cKeyAux := ( cFilSRA + cMatricula + cData )

		/*/
		�������������������������������������������������������������Ŀ
		� Consiste diferen�a entre a Marca��o Gravada e a Atual       �
		���������������������������������������������������������������/*/
		IF !( lExInAs400 )
			/*/
			�������������������������������������������������������������Ŀ
			� Monta a Query Para Verificar as Marcacoes Ja Gravadas do SP8�
			���������������������������������������������������������������/*/
			IF ( lChangeQry := Empty( cQuery ) )
				cQuery := "SELECT "
				For nField := 1 To nSp8Fields
					IF ( aSp8Fields[ nField , 01 ] $ cSp8Fields )
						cQuery += aSp8Fields[ nField , 01 ] + ", "
					EndIF
				Next nField
				cQuery := SubStr( cQuery , 1 , Len( cQuery ) - 2 )
				cQuery += ( " FROM " + cSp8RetSqlName + " " + cAliasSP8 )
				cQuery += ( " WHERE " )
				cQuery += ( cAliasSP8 + "." + cPrefixo )
				cQuery += ( "FILIAL='"+cFilSRA+"'" )
				cQuery += ( " AND " )
				cQuery += ( cAliasSP8 + "." + cPrefixo )
				cQuery += ( "MAT='"+cMatricula+"'" )
				cQuery += ( " AND " )
				cQuery += ( cAliasSP8 + "." + cPrefixo )
				cQuery += ( "DATA='"+cData+"'" )
				cQuery += ( " AND " )
				cQuery += ( cAliasSP8 + ".D_E_L_E_T_=' ' " )
				cQuery += ( "ORDER BY " + SqlOrder( (cAliasSP8)->( IndexKey() ) ) )
				/*/
				�������������������������������������������������������������Ŀ
				� Salva Query Atual Para Posterior Remontagem                 �
				���������������������������������������������������������������/*/
				cSvQuery	:= cQuery
				/*/
				�������������������������������������������������������������Ŀ
				� Sava Filial, Matricula e Data Para Posterior remontagem   da�
				� Query														  �
				���������������������������������������������������������������/*/
				cSvFil		:= cFilSRA
   					cSvMat		:= cMatricula
 					cSvDat		:= cData
   				Else
				/*/
				�������������������������������������������������������������Ŀ
				� Remonta a Query Substituindo os Valores Anteriores pelos atu�
				� ais														  �
				���������������������������������������������������������������/*/
   					IF ( lChangeQry := !( cKeyAux == ( cSvFil + cSvMat + cSvDat ) ) )
   						cQuery		:= StrTran( cSvQuery	, ( "FILIAL='"+cSvFil+"'"	) , ( "FILIAL='"+cFilSRA+"'"	) )
   						cQuery		:= StrTran( cQuery		, ( "MAT='"+cSvMat+"'"		) , ( "MAT='"+cMatricula+"'"	) )
   						cQuery		:= StrTran( cQuery 		, ( "DATA='"+cSvDat+"'"		) , ( "DATA='"+cData+"'"		) )
					/*/
					�������������������������������������������������������������Ŀ
					� Salva Query Atual Para Posterior Remontagem                 �
					���������������������������������������������������������������/*/
					cSvQuery	:= cQuery
					/*/
					�������������������������������������������������������������Ŀ
					� Salva Filial, Matricula e Data Para Posterior remontagem  da�
					� Query														  �
					���������������������������������������������������������������/*/
					cSvFil		:= cFilSRA
   						cSvMat		:= cMatricula
   						cSvDat		:= cData
   					EndIF
   				EndIF
			IF ( lChangeQry )
				cQuery := ChangeQuery( cQuery )
			EndIF
			IF ( lSp8QryOpened := MsOpenDbf(.T.,"TOPCONN",TcGenQry(NIL,NIL,cQuery),cQrySp8Alias,.T.,.T.,.F.,.F.))
				For nField := 1 To nSp8Fields
					IF !( aSp8Fields[ nField , 02 ] == "C" )
						IF ( aSp8Fields[ nField , 01 ] $ cSp8Fields )
							TcSetField(cQrySp8Alias,aSp8Fields[nField,01],aSp8Fields[nField,02],aSp8Fields[nField,03],aSp8Fields[nField,04])
						EndIF
					EndIF
				Next nField
			EndIF
		EndIF
		IF !( lSp8QryOpened )
			cQrySp8Alias	:= cAliasSP8
			( cQrySp8Alias )->( MsSeek( cKeyAux , .F. ) )
		Else
			cKeyAux := ( cFilSRA + cMatricula )
		EndIF
		/*/
		�������������������������������������������������������������Ŀ
		� Verifica se Esta Dentro do Intervalo definido do MV_DESPMIN �
		���������������������������������������������������������������/*/
		While lDespMin .And. ( cQrySp8Alias )->( !Eof() .and. ( cKeyAux == ( P8_FILIAL + P8_MAT + If(lSp8QryOpened,"",DtoS(P8_DATAAPO))) ) )
			If lSp8QryOpened .and. ( cQrySp8Alias )->P8_DATAAPO > dData
				Exit
			EndIf

			IF lIntMen := ( __Min2Hrs( ( cQrySp8Alias )->( DataHora2Val( P8_DATA , P8_HORA , dData , nHora ) ) ) <= nDespMin ) .and. ( ( cQrySp8Alias )->P8_FLAG <> 'A' .or.  ( lGetMarcAuto .and. ( cQrySp8Alias )->P8_FLAG == 'A'))
				Exit
			EndIF
			( cQrySp8Alias )->( dbSkip() )
		EndDo

		IF ( lSp8QryOpened )
			( cQrySp8Alias )->( dbCloseArea() )
			dbSelectArea(cQryMarcAlias)
			lSp8QryOpened := .F.
		EndIF

		/*/
		�������������������������������������������������������������Ŀ
		� N�o Aponta Marca��es com intervalo menor que o permitido    �
		���������������������������������������������������������������/*/
		IF ( lIntMen ) .and. !lPort1510
			/*/
			��������������������������������������������������������������Ŀ
			� PONTO DE ENTRADA                                             �
			� Chamado quando alguma marcacao for descartada em funcao do   �
			� parametro MV_DESPMIN.                                        �
			����������������������������������������������������������������/*/
			IF ( lPonaPo6Block )
				/*/
				�������������������������������������������������������������Ŀ
				� Atualizo a Variavel cCusto para Uso no Ponto de Entrada	  �
				���������������������������������������������������������������/*/
				cCusto := Ponm010CcChk( cCusto )
				/*/
				�������������������������������������������������������������Ŀ
				� Troca Filiais para Integridade		                      �
				���������������������������������������������������������������/*/
			    cFilAnt	:= IF( !Empty( cFilSRA ) , cFilSRA , cFilAnt )
				ExecBlock( "PONAPO6" , .F. , .F. )
				cFilAnt	:= cSvFilAnt
			EndIF

			( cQryMarcAlias )->( dbSkip() )
			Loop
		EndIF

		/*/
		�������������������������������������������������������������Ŀ
		� Carrega aMarcacoes                                          �
		���������������������������������������������������������������/*/
		IF Empty( aMarcacoes )
			aMarcacoes := Array( 01 , Array( ELEMENTOS_AMARC ) )
		EndIF
		aMarcacoes[ 01 , 1    	] := dData				  			//01 - Data da Marcacao
		aMarcacoes[ 01 , 2    	] := nHora				  			//02 - Hora da Marcacao
		aMarcacoes[ 01 , 3   	] := cP8Ordem			  			//03 - Ordem da Marcacao
		aMarcacoes[ 01 , 4    	] := "E"				  			//04 - Flag (Origem) da Marcacao
		aMarcacoes[ 01 , 5   	] := 0					   			//05 - Recno
		aMarcacoes[ 01 , 6   	] := cP8Turno			   			//06 - Turno da Marcacao (Sera Carregado na PutOrdMarc())
		aMarcacoes[ 01 , 7  	] := cFuncao			   			//07 - Funcao do Relogio
		aMarcacoes[ 01 , 8    	] := cGiro				   			//08 - Giro do Relogio
		aMarcacoes[ 01 , 9      	] := Ponm010CcChk( cCusto )			//09 - Centro de Custo da Marcacao
		aMarcacoes[ 01 , 10  	] := "N"				   			//10 - Flag de Marcacao Apontada
		aMarcacoes[ 01 , 11	] := cRelogio			  			//11 - Relogio da Marcacao
		aMarcacoes[ 01 , 12	] := cP8TpMarca			  			//12 - Flag de Tipo de Marcacao
		aMarcacoes[ 01 , 13	] := .F.				  			//13 - Define Se a Marcacao Pode ou Nao ser (Re)Ordenada
		aMarcacoes[ 01 , 15] := cPerAponta			 			//15 - String de Data com o Periodo de Apontamento
		If lPort1510
			aMarcacoes[ 01 , 25		] := CtoD('//')	  		   				//25 - Data de Apontamento
			aMarcacoes[ 01 , 26		] := cNumRep	  		   				//26 - Numero do REP
			aMarcacoes[ 01 , 27		] := If(lIntMen,"D",Space(01))			//27 - Tipo de Marcacao no REP
			aMarcacoes[ 01 , 28		] := "O"								//28 - Tipo de Registro
			aMarcacoes[ 01 , 29		] := If(lIntMen,cMotivo,cSpaceMotVrg)	//29 - Motivo da desconsideracao/inclusao
			aMarcacoes[ 01 , 31		] := cEmpOrg			   				//31 - Empresa Origem da marcacao
			aMarcacoes[ 01 , 32		] := cFilSRA      		   				//32 - Filial Origem da marcacao
			aMarcacoes[ 01 , 33		] := cMatricula    						//33 - Matricula Origem da marcacao
			aMarcacoes[ 01 , 34		] := cDhOrg				   				//34 - Data/Hora Origem da marcacao
			aMarcacoes[ 01 , 35		] := cIdOrg		   		   				//35 - Identificacao da Origem da marcacao

			If lMarcQryOpened
			   	nRecQry := ( cQryMarcAlias )->RECNO
		   		dbSelectArea(cAliasMarc)
		   		( cAliasMarc )->(dbGoTo(nRecQry))
				IF RecLock( cAliasMarc , .F. )
					( cAliasMarc )->RFE_FILORG := cFilSRA
					( cAliasMarc )->RFE_MATORG := cMatricula
					( cAliasMarc )->RFE_NATU   := "0"
					( cAliasMarc )->RFE_FLAG   := "1"
					( cAliasMarc )->( MsUnLock() )
				EndIf
				dbSelectArea(cQryMarcAlias)
			Else
				IF RecLock( cQryMarcAlias , .F. )
					( cQryMarcAlias )->RFE_FILORG := cFilSRA
					( cQryMarcAlias )->RFE_MATORG := cMatricula
					( cQryMarcAlias )->RFE_NATU   := "0"
					( cQryMarcAlias )->RFE_FLAG   := "1"
					( cQryMarcAlias )->( MsUnLock() )
				EndIf
	   		EndIf

		EndIf
		If lGeolocal
			aMarcacoes[ 01 , 36	] := " "		//36 - Latitude (marcacao geolocalizacao)
			aMarcacoes[ 01 , 37	] := " "		//37 - Longitude (marcacao geolocalizacao)
		EndIf

		/*/
		�������������������������������������������������������������Ŀ
		� Contador para Numero de Marcacoes Gravadas                  �
		���������������������������������������������������������������/*/
		++nGravadas

		/*/
		�������������������������������������������������������������Ŀ
		� Grava o arquivo de marca��es.                               �
		���������������������������������������������������������������/*/
		PutMarcacoes( aMarcacoes , cFilSRA , cMatricula , "SP8" , .T., Nil, Nil, Nil, lWorkFlow, nTipo )

		If lMarcQryOpened .And. aScan( aRegsRARFE, { |x| x[1] == SRA->( Recno() ) } ) == 0
			aAdd(aRegsRARFE, { SRA->( Recno() ) } )
		EndIf

		/*/
		�������������������������������������������������������������Ŀ
		� Posiciona na Proxima marca�ao                               �
		���������������������������������������������������������������/*/
		( cQryMarcAlias )->( dbSkip() )

	EndDo

	If lMarcQryOpened
		(cQryMarcAlias)-> (dbCloseArea())
		RestArea( aGetArea )
	EndIf

End Sequence

cFilAnt := cSvFilAnt

Return( NIL )

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �SelectSra	 � Autor �Marinaldo de Jesus   � Data �09/09/2004�
������������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Selecionar as Informacoes do SRA				 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/
Static Function SelectSra()

Local lSelectOk := .F.

Local nField
Local uRet

Local aStruSRA			:= {}
Local aTempSRA			:= SRA->( dbStruct() )
Local aCposSRA			:= {}
Local cCatQuery			:= ""
Local cQuery	 		:= ""
Local cQueryCond		:= ""
Local cSitQuery         := ""
Local cRecQuery         := ""
Local nCont     		:= 0
Local nContField		:= 0
Local nCateg			:= 0
Local nSitua			:= 0

For nCateg:=1 to Len(cCategoria)
	cCatQuery += "'"+Subs(cCategoria,nCateg,1)+"'"
	If ( nCateg+1) <= Len(cCategoria)
		cCatQuery += ","
	EndIf
Next nCateg

For nSitua:=1 to Len(cSituacoes)
	cSitQuery += "'" + Subs(cSituacoes,nSitua,1) + "'"
	If (nSitua+1) <= Len(cSituacoes)
		cSitQuery += ","
	EndIf
Next nSitua

Begin Sequence

	IF !( lSraQryOpened )
		If lWorkFlow .And. nTipo == 1 .And. Len( aRegsRARFE ) == 0//Workflow e leitura de marcacoes
			Break
		EndIf
		SRA->( dbSetOrder( RetOrdem( "SRA" , "RA_FILIAL+RA_TNOTRAB+RA_SEQTURN+RA_REGRA+RA_MAT" ) ) )
		/*/
		�������������������������������������������������������������Ŀ
		� Seta apenas os Campos do SRA que serao Utilizados           �
		���������������������������������������������������������������/*/
		nContField	:= Len(aTempSRA)
		aAdd( aCposSRA , "RA_FILIAL"	)
		aAdd( aCposSRA , "RA_MAT" 		)
		aAdd( aCposSRA , "RA_NOME"		)
		aAdd( aCposSRA , "RA_CC"		)
		aAdd( aCposSRA , "RA_TNOTRAB"	)
		aAdd( aCposSRA , "RA_SEQTURN"	)
		aAdd( aCposSRA , "RA_REGRA"  	)
		aAdd( aCposSRA , "RA_ADMISSA"  	)
		aAdd( aCposSRA , "RA_DEMISSA"  	)
		aAdd( aCposSRA , "RA_CATFUNC"  	)
		aAdd( aCposSRA , "RA_SITFOLH"  	)
		aAdd( aCposSRA , "RA_HRSEMAN" 	)
		aAdd( aCposSRA , "RA_AFASFGT" 	)
		aAdd( aCposSRA , "RA_RESCRAI"   )
		aAdd( aCposSRA , "RA_MSBLQL"    )
		aAdd( aCposSRA , "RA_CRACHA"    )
		aAdd( aCposSRA , "RA_PIS"    	)

		/*/
		��������������������������������������������������������������Ŀ
		�Verifica e Seta os campos a mais incluidos no Mex             �
		����������������������������������������������������������������/*/
		fAdCpoSra(aCposSra)

		/*/
		��������������������������������������������������������������Ŀ
		� Ponto de Entrada para Campos do Usuario                      �
		����������������������������������������������������������������/*/
		IF ( lPnm010CposBlock )
			IF ( ValType( uRet := ExecBlock("PNM010CPOS",.F.,.F.,aCposSRA) ) == "A" )
				IF Len( uRet ) >= Len( aCposSRA )
					aCposSRA := aClone(uRet)
					uRet	 := NIL
				EndIF
			EndIF
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Abandona o Processamento									   �
		����������������������������������������������������������������/*/
		IF ( lAbortPrint )
			aAdd(aLogFile, '- Cancelado pelo Operador em '  + Dtoc(MsDate()) + ', as ' + Time() + ' ...') // '- Cancelado pelo Operador em '
			Break
		EndIF

		For nField := 1 To nContField
			/*/
			��������������������������������������������������������������Ŀ
			� Abandona o Processamento									   �
			����������������������������������������������������������������/*/
			IF ( lAbortPrint )
				aAdd(aLogFile, '- Cancelado pelo Operador em '  + Dtoc(MsDate()) + ', as ' + Time() + ' ...') // '- Cancelado pelo Operador em '
				Break
			EndIF
			/*/
			��������������������������������������������������������������Ŀ
			� Carrega os Campos do SRA para a Montagem da Query			   �
			����������������������������������������������������������������/*/
			IF aScan( aCposSRA , { |x| x == AllTrim( aTempSRA[ nField , 1 ] ) } ) > 0
				aAdd( aStruSRA , aClone( aTempSRA[ nField ] ) )
			EndIF
		Next nField
		aCposSRA	:= aTempSRA := NIL
		nContField	:= Len( aStruSRA )
		cQuery := "SELECT "
		For nField := 1 To nContField
			/*/
			��������������������������������������������������������������Ŀ
			� Abandona o Processamento									   �
			����������������������������������������������������������������/*/
			IF ( lAbortPrint )
				aAdd(aLogFile, '- Cancelado pelo Operador em '  + Dtoc(MsDate()) + ', as ' + Time() + ' ...') // '- Cancelado pelo Operador em '
				Break
			EndIF
			/*/
			��������������������������������������������������������������Ŀ
			� Inclui os Campos na Montagem da Query						   �
			����������������������������������������������������������������/*/
			cQuery += aStruSRA[ nField , 1 ] + ", "
		Next nField
		cQuery		:= SubStr( cQuery , 1 , Len( cQuery ) - 2 )

		cQueryCond	:= " FROM "
		cQueryCond	+= InitSqlName("SRA") + " SRA "
		cQueryCond	+= "WHERE "
		If lWorkFlow .And. nTipo == 1 .and. Len(aRegsRARFE) <= 1000 //Workflow e leitura de marcacoes -- Muitos itens na clausula IN diminuem a performance o BD e no Oracle especificamente, � gerado erro caso exista mais de 1000 itens na lista.
			For nCont := 1 To Len(aRegsRARFE)
				cRecQuery += "'" + cValToChar(aRegsRARFE[nCont,1]) + "'"
				If ( nCont+1 ) <= Len(aRegsRARFE)
					cRecQuery += ","
				EndIf
			Next nCont
			cQueryCond  += "SRA.R_E_C_N_O_ IN (" + Upper(cRecQuery) + ")"
			cQueryCond	+= " AND "
		EndIf
		cQueryCond	+= "("
		cQueryCond	+=		"SRA.RA_DEMISSA='"+Space(Len(Dtos(dPerDe)))+"'"
		cQueryCond	+= 		" OR "
		cQueryCond	+= 		"SRA.RA_DEMISSA>='"+Dtos(dPerDe)+"'"
		cQueryCond	+= ")"
		cQueryCond	+= " AND "
		cQueryCond	+= "SRA.RA_ADMISSA<='"+Dtos(dPerAte)+"'"
		cQueryCond	+= " AND "
		cQueryCond	+= "SRA.RA_FILIAL>='"+cFilDe+"'"
		cQueryCond	+= " AND "
		cQueryCond	+= "SRA.RA_FILIAL<='"+cFilAte+"'"
		cQueryCond	+= " AND "
		cQueryCond	+= "SRA.RA_TNOTRAB>='"+cTurnoDe+"'"
		cQueryCond	+= " AND "
		cQueryCond	+= "SRA.RA_TNOTRAB<='"+cTurnoAte+"'"
		cQueryCond	+= " AND "
		cQueryCond	+= "SRA.RA_MAT>='"+cMatDe+"'"
		cQueryCond	+= " AND "
		cQueryCond	+= "SRA.RA_MAT<='"+cMatAte+"'"
		cQueryCond	+= " AND "
		cQueryCond	+= "SRA.RA_NOME>='"+cNomeDe+"'"
		cQueryCond	+= " AND "
		cQueryCond	+= "SRA.RA_NOME<='"+cNomeAte+"'"
		cQueryCond	+= " AND "
		cQueryCond	+= " ( "
		cQueryCond	+= 		"SRA.RA_REGRA<>'"+cSpaceRegra+"'"
		cQueryCond	+= 		" AND "
		cQueryCond	+= 		" ( "
		cQueryCond	+= 			"SRA.RA_REGRA>='"+cRegDe+"'"
		cQueryCond	+= 			" AND "
		cQueryCond	+= 			"SRA.RA_REGRA<='"+cRegAte+"'"
		cQueryCond	+= 		" ) "
		cQueryCond	+= " ) "
		cQueryCond	+= " AND "
		cQueryCond	+= "SRA.RA_CC>='"+cCCDe+"'"
		cQueryCond	+= " AND "
		cQueryCond	+= "SRA.RA_CC<='"+cCCAte+"'"
		cQueryCond  += " AND "
		cQueryCond  += "SRA.RA_CATFUNC IN (" + Upper(cCatQuery) + ")"
		cQueryCond	+= " AND "
		cQueryCond  += "SRA.RA_SITFOLH IN (" + Upper(cSitQuery) + ")"
		cQueryCond	+= " AND "
		cQueryCond	+= "SRA.D_E_L_E_T_=' ' "

		cQuery		+= cQueryCond
		cQuery		+= "ORDER BY "+SqlOrder( SRA->( IndexKey() ) )
		cQuery		:= ChangeQuery(cQuery)

		/*/
		��������������������������������������������������������������Ŀ
		� Abandona o Processamento									   �
		����������������������������������������������������������������/*/
		IF ( lAbortPrint )
			aAdd(aLogFile, '- Cancelado pelo Operador em '  + Dtoc(MsDate()) + ', as ' + Time() + ' ...') // '- Cancelado pelo Operador em '
			Break
		EndIF
		SRA->( dbCloseArea() ) //Fecha o SRA para uso da Query
		IF ( lSraQryOpened := MsOpenDbf(.T.,"TOPCONN",TcGenQry(,,cQuery),"SRA",.T.,.T.,.F.,.F.))
			For nField := 1 To nContField
				IF ( aStruSRA[nField,2] <> "C" )
					TcSetField("SRA",aStruSRA[nField,1],aStruSRA[nField,2],aStruSRA[nField,3],aStruSRA[nField,4])
				EndIF
			Next nField
			IF !( lWorkFlow )
				/*/
				��������������������������������������������������������������Ŀ
				� Verifica o Total de Registros a Serem Processados            �
				����������������������������������������������������������������/*/
				cQuery := "SELECT COUNT(*) QRYLASTREC "
				cQuery += cQueryCond
				cQuery := ChangeQuery(cQuery)
        		IF ( MsOpenDbf(.T.,"TOPCONN",TcGenQry(,,cQuery),"__QRYCOUNT",.T.,.T.,.F.,.F.))
					nSraLstRec := __QRYCOUNT->QRYLASTREC
					__QRYCOUNT->( dbCloseArea() )
					dbSelectArea( "SRA" )
            	Else
					aRecsBarG := {}
					//CREATE SCOPE aRecsBarG FOR SRA->( Eval( bSraScope ) )
					MsAguarde( { || nSraLstRec := SRA->( ScopeCount( aRecsBarG , NIL , NIL , .F. ) ) } )
					SRA->( dbGotop() )
				EndIF
			EndIF
		Else
			/*/
			�������������������������������������������������������������Ŀ
			� Restaura Arquivo Padrao e Ordem                             �
			���������������������������������������������������������������/*/
			ChkFile( "SRA" )
			SRA->( dbSetOrder( RetOrdem( "SRA" , "RA_FILIAL+RA_TNOTRAB+RA_SEQTURN+RA_REGRA+RA_MAT" ) ) )
			/*/
			�������������������������������������������������������������Ŀ
			� Procura primeiro funcion�rio.                               �
			���������������������������������������������������������������/*/
			SRA->( MsSeek( cFilTnoDe , .T. ) )
			/*/
			��������������������������������������������������������������Ŀ
			� Verifica o Total de Registros a Serem Processados            �
			����������������������������������������������������������������/*/
			IF !( lWorkFlow )
				aRecsBarG := {}
				//CREATE SCOPE aRecsBarG FOR SRA->( Eval( bSraScope ) )
				MsAguarde( { || nSraLstRec := SRA->( ScopeCount( aRecsBarG ) ) } )
			EndIF
		EndIF
	Else
		SRA->( dbGotop() )
	EndIF

	IF !( lWorkFlow )
		/*/
		��������������������������������������������������������������Ŀ
		� Atualiza Regua de Processamento Para IncProcG2()			   �
		����������������������������������������������������������������/*/
		BarGauge2Set( nSraLstRec )
		/*/
		��������������������������������������������������������������Ŀ
		� Incrementa Contador de Tempos                      		   �
		����������������������������������������������������������������/*/
		++nCountTime
	EndIF

	lSelectOk := .T.

End Sequence

Return( lSelectOk  )

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �Ponm010Aponta� Autor �Marinaldo de Jesus   � Data �09/09/2004�
������������������������������������������������������������������������Ĵ
�Descri��o �Classificacao e Apontamento das Marcacoes   				 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/
Static Function Ponm010Aponta( lIncProc )

Local aAreaSP8		:= SP8->( GetArea("SP8") )
Local aAbonosPer	:= {}
Local aPeriodos		:= {}
Local cSvFilAnt		:= cFilAnt
Local lApHeDtm	 	:= .F.
Local lGetMarcAuto	:= .T.
Local lApontaOk		:= .T.

Local aLastApo
Local aMarcacoes
Local aMarcTot
Local aMarcDel
Local aMarcClone
Local aRecsMarcAutDele
Local aResult
Local aCalenAux		:= {}

Local cDsrAutPa
Local cPd
Local cPdEmpr
Local cFil
Local cTno
Local cMat
Local cSeq
Local cCc
Local cNome
Local cPaponta		:= SuperGetMv("MV_PAPONTA",,"")

Local dPerIGeA
Local dPerFGeA

Local lAjustMarc

Local nX
Local nSerIni
Local nSerFim
Local nMinSize
Local nSizeaMcClo
Local nSizeaMarca
Local nMarc
Local nLoop			:= 1
Local nLoopFim      := 1
Local nPosIni		:= 0
Local nPosFim		:= 0
Local nPosUtMarc
Local nPosPerIni
Local nPosPerFim

Local uPerIniDel
Local uPerFimDel
Local uRet
Local nLenCalend	:=	0
Local nOrdemData	:=	0
Local dPer1Ini
Local dPer1Fim
Local dPer2Ini
Local dPer2Fim

DEFAULT lIncProc := .T.

Begin Sequence

	/*/
	�������������������������������������������������������������Ŀ
	� Redefine variaveis.										  �
	���������������������������������������������������������������/*/
	SRA->(;
				cFil 	:= RA_FILIAL	,;
				cTno 	:= RA_TNOTRAB	,;
				cMat 	:= RA_MAT		,;
				cSeq	:= RA_SEQTURN	,;
				cCC		:= RA_CC		,;
				cNome	:= RA_NOME		 ;
		 )

	lAjustMarc	:= ( ( PosSR6( cTno , cFil , "R6_MCIMPJC" , 01 ) == "2" ) )

	/*/
	��������������������������������������������������������������Ŀ
	� Movimenta a R�gua de Processamento                           �
	����������������������������������������������������������������/*/
	IF !( lWorkFlow ) .and. !lMultThread

		/*/
		��������������������������������������������������������������Ŀ
		� Atualiza a Mensagem para a IncProcG1() ( Turnos )			   �
		����������������������������������������������������������������/*/
		IF !( cFilTnoSeqOld == ( cFil + cTno + cSeq ) )
			/*/
			��������������������������������������������������������������Ŀ
			� Atualiza o Filial/Turno/Sequencias Anteriores				   �
			����������������������������������������������������������������/*/
			cFilTnoSeqOld := ( cFil + cTno + cSeq )
			/*/
			��������������������������������������������������������������Ŀ
			� Atualiza a Mensagem para a BarGauge do Turno 				   �
			����������������������������������������������������������������/*/
			//"Filial:"###"Turno:"###"Sequencia:"
			cMsgBarG1 := ( "Filial:" + " " + cFil + " - " + "Turno:"+ " " + cTno + " - " + Left(AllTrim( PosAlias( "SR6" , cTno , cFil , "R6_DESC" , 1 , .F. ) ),50) + " - " + "Sequencia:" + " " + cSeq )
			/*/
			��������������������������������������������������������������Ŀ
			� Verifica se Houve Troca de Filial para Verificacai dos Turnos�
			����������������������������������������������������������������/*/
			IF !( cLastFil == cFil )
				/*/
				��������������������������������������������������������������Ŀ
				� Atualiza o Filial Anterior								   �
				����������������������������������������������������������������/*/
				cLastFil := cFil
				/*/
				��������������������������������������������������������������Ŀ
				� Se Houver Interacao no Processamento   					   �
				����������������������������������������������������������������/*/
				IF ( lIncProc )
					/*/
					��������������������������������������������������������������Ŀ
					� Obtem o % de Incremento da 2a. BarGauge					   �
					����������������������������������������������������������������/*/
					nIncPercG1 := SuperGetMv( "MV_PONINC1" , NIL , 5 , cLastFil )
					/*/
					��������������������������������������������������������������Ŀ
					� Obtem o % de Incremento da 2a. BarGauge					   �
					����������������������������������������������������������������/*/
					nIncPercG2 := SuperGetMv( "MV_PONINCP" , NIL , 5 , cLastFil )
					/*/
					��������������������������������������������������������������Ŀ
					� Realimenta a Barra de Gauge para os Turnos de Trabalho       �
					����������������������������������������������������������������/*/
					IF (;
							!( lSR6Comp );
							.or.;
							( nRecsBarG == 0 );
						)
						aRecsBarG := {}
						//CREATE SCOPE aRecsBarG FOR ( R6_FILIAL == cLastFil .or. Empty( R6_FILIAL ) )
						nRecsBarG := SR6->( ScopeCount( aRecsBarG ) )
					EndIF
					/*/
					��������������������������������������������������������������Ŀ
					� Define o Contador para o Processo 1                          �
					����������������������������������������������������������������/*/
					--nCount1Time
					/*/
					��������������������������������������������������������������Ŀ
					� Define o Numero de Elementos da BarGauge                     �
					����������������������������������������������������������������/*/
					BarGauge1Set( nRecsBarG )
					/*/
					��������������������������������������������������������������Ŀ
					� Inicializa Mensagem na 1a BarGauge                           �
					����������������������������������������������������������������/*/
					IncProcG1( cMsgBarG1 , .F. )
	   			EndIF
	   			/*/
				��������������������������������������������������������������Ŀ
				� Reinicializa a Filial/Turno Anterior                         �
				����������������������������������������������������������������/*/
				cFilTnoOld := "__cFilTnoOld__"
            EndIF
			/*/
			��������������������������������������������������������������Ŀ
			�Verifica se Deve Incrementar a Gauge ou Apenas Atualizar a Men�
			�sagem														   �
			����������������������������������������������������������������/*/
			IF ( lIncProcG1 := !( cFilTnoOld == ( cFil + cTno ) ) )
				cFilTnoOld := ( cFil + cTno )
			EndIF
			/*/
			��������������������������������������������������������������Ŀ
			�Incrementa a Barra de Gauge referente ao Turno				   �
			����������������������������������������������������������������/*/
			IncPrcG1Time( cMsgBarG1 , nRecsBarG , cTimeIni , .F. , nCount1Time , nIncPercG1 , lIncProcG1 )
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Se Houver Interacao no Processamento   					   �
		����������������������������������������������������������������/*/
		IF ( lIncProc )
			/*/
			��������������������������������������������������������������Ŀ
			� Movimenta a Regua de Processamento Principal            	   �
			����������������������������������������������������������������/*/
			IF ( ( nTipo == 2 ) .or. ( nTipo == 3 ) )
				IncPrcG2Time( 'Apontadas...: ' , nSraLstRec , cTimeIni , .F. , nCountTime , nIncPercG2 )	//'Apontadas...: '
			Else
				IncPrcG2Time( 'Classificadas...: ' , nSraLstRec , cTimeIni , .F. , nCountTime , nIncPercG2 )	//'Classificadas...: '
			EndIF
		EndIF

		/*/
		��������������������������������������������������������������Ŀ
		� Consiste controle de acessos e filiais validas               �
		����������������������������������������������������������������/*/
		IF SRA->(;
					!( cFil $ fValidFil() );
					.or.;
					!Eval( bAcessaSRA );
				)
			Break
		EndIF

	EndIF

	/*/
	�������������������������������������������������������������Ŀ
	� Reinicializa aTaPadrao Quando Nao for Compartilhada         �
	���������������������������������������������������������������/*/
	IF !( cFil == cFilOld ) //cFil eh Atribuida a cFilOld Na proxima Comparacao
		/*/
		�������������������������������������������������������������Ŀ
		� Verifica o Periodo de Apontamento                           �
		���������������������������������������������������������������/*/
		IF !( cFil == cFilOld )
			IF !CheckPonMes( @dPerIni , @dPerFim , .F. , .T. , ( !( lWorkFlow ) .and. !( lChkPonMesAnt ) .and. !(lMultThread) ) , cFil )
				lChkPonMesAnt := .F.
				aAdd( aLogFile , '- Nao Foi Encontrado periodo de Apontamento para a Filial: ' ) // '- Nao Foi Encontrado periodo de Apontamento para a Filial: '
				aAdd( aLogFile , '- A Leitura/Apontamento nao puderam ser concluidos. Favor Cadastrar o Periodo' ) // '- A Leitura/Apontamento nao puderam ser concluidos. Favor Cadastrar o Periodo'
				IF !( lWorkFlow )
					Break
				EndIF
			Else
				lChkPonMesAnt := .T.
			EndIF
			IF !fChkPer( dPerDe , dPerAte )
				aAdd( aLogFile , '- O Periodo Informado nos Parametros e invalido. Informe um Periodo Valido' ) // '- O Periodo Informado nos Parametros e invalido. Informe um Periodo Valido'
				IF !( lWorkFlow )
					lChkPonMesAnt := .F.
					Break
				EndIF
			EndIF
		EndIF
		/*/
		�������������������������������������������������������������Ŀ
		� Reinicializa a Tabela de Horario Padrao                     �
		���������������������������������������������������������������/*/
		IF xRetModo("SRA","SPJ",.F.)
			aTabPadrao := {}
		EndIF
		/*/
		�������������������������������������������������������������Ŀ
		� Verifica se Devera Carregar as Marcacoes Automaticas      em�
		� GetMarcacoes												  �
		���������������������������������������������������������������/*/
		lGetMarcAuto := ( SuperGetMv( "MV_GETMAUT" , NIL , "S" , cFil ) == "S" )
	EndIF

	/*/
	�������������������������������������������������������������Ŀ
	� Verifica se o funcionario foi demitido antes do Per�odo     �
	���������������������������������������������������������������/*/
	IF SRA->(;
				( RA_SITFOLH == "D" );
				.and.;
				!Empty( RA_DEMISSA );
				.and.;
				( RA_DEMISSA < dPerIni );
			 )
    	Break
	EndIF

	/*/
	�������������������������������������������������������������Ŀ
	� Define o Periodo para a Geracao das Marcacoes Automaticas e �
	� Para a Montagem do Calendario e Para o Apontamento das  Mar �
	� cacoes                                                      �
	���������������������������������������������������������������/*/
	dPerIGeA		:= dPerDe
	dPerFGeA		:= dPerAte
	IF SRA->( RA_ADMISSA > dPerDe .and. RA_ADMISSA <= dPerAte )
		dPerIGeA	:= SRA->RA_ADMISSA
	EndIF
	IF SRA->( RA_DEMISSA < dPerAte .and. !Empty( RA_DEMISSA ) )
		dPerFGeA	:= dDataBase
	EndIF
	dPerIGeA	:= Max( dPerIGeA , dPerDe  )
	dPerFGeA	:= Min( dPerFGeA , dPerAte )
	IF ( dPerFGeA < dPerIGeA )
		Break //Demissao Anterior aa data inicial
	EndIF
	
	//sempre fazemos o apontamento do periodo anterior, atual e do proximo, pois podemos estar no fim de um periodo e inicio de outro, e conter marca��es dos 2 periodos nos TXT.
	// ou podem existir marca��es do per�odo anterior, no caso de hor�rio noturno
	nLoopFim := 2
	
	If Len(cPaponta) > 5
		dPer1Ini := DaySum(dPerFim, 1) // O pr�ximo per�odo come�a no dia seguinte ao termino do per�odo atual
		dPer1Fim := DaySum(dPer1Ini, DateDiffDay(dPerIni, dPerFim)) // O per�odo seguite ter� a mesma quantidade de dias do per�odo atual
		dPer2Ini := MonthSub(dPerIni,1)
		dPer2Fim := DaySub(dPerIni,1)
	Else
		dPer1Ini := MonthSum(dPerIni,1)
		dPer1Fim := MonthSum(dPerFim,1)
		dPer2Ini := MonthSub(dPerIni,1)
		dPer2Fim := MonthSub(dPerFim,1)
	EndIf
	If lWorkFlow .And. !lSchedDef .And. !lUserDefParam .And. lLimitaDataFim
		dPerFim := Min(dDataBase, dPerFim)
	EndIf
	
	aAdd(aPeriodos,dPerIni)
	aAdd(aPeriodos,dPerFim)
	aAdd(aPeriodos,dPer1Ini)
	aAdd(aPeriodos,dPer1Fim)
	If fApontAnt(dPer2Ini, dPer2Fim)
		aAdd(aPeriodos,dPer2Ini)
		aAdd(aPeriodos,dPer2Fim)
		nLoopFim := 3
	EndIf
	
	For nLoop := 1 to nLoopFim
		aTabPadrao 	:= {}
		aCalenAux  	:= {}
		
		If nLoop == 1
			nPosPerIni := nLoop
			nPosPerFim := nPosPerIni + 1
		Else
			nPosPerIni += 2
			nPosPerFim += 2
		EndIf

		/*/
		�������������������������������������������������������������Ŀ
		� Cria Tabela de Horario Padrao do Funcionario                �
		���������������������������������������������������������������/*/
		IF SRA->( !CriaCalend(	aPeriodos[nPosPerIni]	,;	//01 -> Data Inicial do Periodo
								aPeriodos[nPosPerFim]	,;	//02 -> Data Final do Periodo
								cTno		,;	//03 -> Turno Para a Montagem do Calendario
								cSeq		,;	//04 -> Sequencia Inicial para a Montagem Calendario
								@aTabPadrao	,;	//05 -> Array Tabela de Horario Padrao
								@aTabCalend	,;	//06 -> Array com o Calendario de Marcacoes
								cFil		,;	//07 -> Filial para a Montagem da Tabela de Horario
								cMat		,;	//08 -> Matricula para a Montagem da Tabela de Horario
								cCc			,;	//09 -> Centro de Custo para a Montagem da Tabela
								NIL     	,;	//10 -> Array com as Trocas de Turno
								NIL			,;	//11 -> Array com Todas as Excecoes do Periodo
								NIL			,;	//12 -> Se executa Query para a Montagem da Tabela Padrao
								.T.			,;	//13 -> Se executa a funcao se sincronismo do calendario
								NIL			 ;	//14 -> Se Forca a Criacao de Novo Calendario
							);
				)
			aAdd(aLogFile, '- Foram encontradas inconsistencias na Tabela do Turno'  + AllTrim(cTno) + '.')													// '- Foram encontradas inconsistencias na Tabela do Turno'
			SRA->( aAdd(aLogFile, '  As marca��es do funcionario ' + AllTrim(cMat) + ' - ' + AllTrim(cNome) + ' nao' ) )			// '  As marca��es do funcionario '###' nao'
			aAdd(aLogFile, '  serao classificadas. Verificar o castramento de Tabelas de Hor�rio para este Turno.' )																		// '  serao classificadas. Verificar o castramento de Tabelas de Hor�rio para este Turno.'
			Break
		EndIF

		If !Empty(aTabCalend) .And. aTabCalend[Len(aTabCalend), 6] == "D" .And. aTabCalend[Len(aTabCalend), 1] > aTabCalend[Len(aTabCalend), 1]
			SRA->( CriaCalend(	aPeriodos[nPosPerFim]+1	,;	//01 -> Data Inicial do Periodo
								aPeriodos[nPosPerFim]+1	,;	//02 -> Data Final do Periodo
								cTno		,;	//03 -> Turno Para a Montagem do Calendario
								cSeq		,;	//04 -> Sequencia Inicial para a Montagem Calendario
								{}			,;	//05 -> Array Tabela de Horario Padrao
								@aCalenAux	,;	//06 -> Array com o Calendario de Marcacoes
								cFil		,;	//07 -> Filial para a Montagem da Tabela de Horario
								cMat		,;	//08 -> Matricula para a Montagem da Tabela de Horario
								cCc			,;	//09 -> Centro de Custo para a Montagem da Tabela
								NIL     	,;	//10 -> Array com as Trocas de Turno
								NIL			,;	//11 -> Array com Todas as Excecoes do Periodo
								NIL			,;	//12 -> Se executa Query para a Montagem da Tabela Padrao
								.T.			,;	//13 -> Se executa a funcao se sincronismo do calendario
								NIL			 ;	//14 -> Se Forca a Criacao de Novo Calendario
							);
				)		
		EndIf

	   	/*/
		��������������������������������������������������������������Ŀ
		� Monta Condicoes para verificacao das Marcacoes    Automaticas�
		� que devera ser Desprezadas								   �
		����������������������������������������������������������������/*/
		IF !( lGetMarcAuto )
			/*/
			�������������������������������������������������������������Ŀ
			� Periodo Incicial											  �
			���������������������������������������������������������������/*/
			uPerIniDel	:= GetInfoPosTab( 17 , "1E" , dPerIGeA , aTabCalend )
			uPerIniDel	:= DataHora2Str( uPerIniDel[1] , uPerIniDel[2] )
			/*/
			�������������������������������������������������������������Ŀ
			� Periodo Final    											  �
			���������������������������������������������������������������/*/
			uPerFimDel	:= GetInfoPosTab( 17 , "__LASTMARC__" , dPerFGeA , aTabCalend )
			uPerFimDel	:= DataHora2Str( uPerFimDel[1] , uPerFimDel[2] )
			/*/
			�������������������������������������������������������������Ŀ
			� Condicao         											  �
			���������������������������������������������������������������/*/
			bCondDelAut	:= { |cDataHora| cDataHora := DataHora2Str( P8_DATA , P8_HORA ) , ( ( cDataHora >= uPerIniDel ) .and. ( cDataHora <= uPerFimDel ) ) }
		EndIF

		/*/
		�������������������������������������������������������������Ŀ
		� Inicio do Processo de Classificacao das Marcacoes           �
		���������������������������������������������������������������/*/
			IF (;
					( nAponta == 1 );//1=Apontamento
					.or.;
					( nAponta == 4 );//4=Marc. e Ref.
					.or.;
					( nAponta == 5 );//5=Todos
				)

				/*/
				�������������������������������������������������������������Ŀ
				� Verifica a Troca de Filial                                  �
				���������������������������������������������������������������/*/
				IF !( cFil == cFilOld )

					/*/
					�������������������������������������������������������������Ŀ
					� Atualiza cFilOld                                            �
					���������������������������������������������������������������/*/
					cFilOld := cFil //A Atribuicao deve ser Feita Aqui pois eh a ultima comparacao

					/*/
					�������������������������������������������������������������Ŀ
					� Carrega Codigos de Eventos.                                 �
					���������������������������������������������������������������/*/
					IF ( ( nTipo == 2 ) .or. ( nTipo == 3 ) ) //2=Apontamento;3=Ambos
						lApHeDtm	:= ( SuperGetMv( "MV_APHEDTM" , NIL , "N" , cFil ) == "S" )
				        cFilSP9		:= fFilFunc("SP9") //-- Obtem a Filial de Eventos
						//-- Nao carregar novamente o cadastro de eventos qdo o mesmo for compartilhado
						IF ( !Empty( cFilSP9 ) .or. ( Len( aCodigos ) == 0 ) )
							aCodigos := {}
							IF !( fCargaId( @aCodigos , cFilSP9 , .F. ) )
								aAdd(aLogFile, '- Nao foram encontrados eventos cadastrados para a filial '  + AllTrim(cFil) + '.')													// '- Nao foram encontrados eventos cadastrados para a filial '
								SRA->( aAdd(aLogFile, '  As marca��es do funcionario '  + AllTrim(cMat) + ' - ' + AllTrim(cNome) + ' nao' ) )		// '  As marca��es do funcionario '###' nao'
								aAdd(aLogFile, '  serao classificadas. Verificar o cadastramento de Eventos para esta filial.' )																		// '  serao classificadas. Verificar o cadastramento de Eventos para esta filial.'
								Break
							EndIF
							cDsrAutPa	:= PosSP9( "036N" , cFilOld , "P9_CODIGO" , 2 ) //Evento DSR Mes Anterior
		   					cPd			:= PosSP9( "016A" , cFilOld , "P9_CODIGO" , 2 ) //Evento Desc. Ref.Parte Func.
	       					cPdEmpr		:= PosSP9( "015A" , cFilOld , "P9_CODIGO" , 2 ) //Evento Desc. Ref.Parte Empresa
						EndIF
		            EndIF

				EndIF

		        /*/
				�������������������������������������������������������������Ŀ
				� Cria array com as marca��es do Periodo para o funcion�rio.  �
				���������������������������������������������������������������/*/
				IF !GetMarcacoes(	@aMarcTot	 		,;	//01 -> Marcacoes dos Funcionarios
									@aTabCalend			,;	//02 -> Calendario de Marcacoes
									NIL					,;	//03 -> Tabela Padrao
									NIL					,;	//04 -> Turnos de Trabalho
									NIL 				,;	//05 -> Periodo Inicial
									NIL					,;	//06 -> Periodo Final
									NIL					,;	//07 -> Filial
									NIL					,;	//08 -> Matricula
									NIL					,;	//09 -> Turno
									NIL					,;	//10 -> Sequencia de Turno
									NIL					,;	//11 -> Centro de Custo
									NIL					,;	//12 -> Alias para Carga das Marcacoes
									NIL					,;	//13 -> Se carrega Recno em aMarcacoes
									NIL					,;	//14 -> Se considera Apenas Ordenadas
									NIL					,;  //15 -> Verifica as Folgas Automaticas
									NIL					,;  //16 -> Se Grava Evento de Folga Mes Anterior
									lGetMarcAuto		,;	//17 -> Se Carrega as Marcacoes Automaticas
									@aRecsMarcAutDele	,;	//18 -> Registros de Marcacoes Automaticas que deverao ser Deletados
									bCondDelAut			,;	//19 -> Bloco para avaliar as Marcacoes Automaticas que deverao ser Desprezadas
									.T.					,;	//20 -> Se Considera o Periodo de Apontamento das Marcacoes
									NIL					,;	//21 -> Se Efetua o Sincronismo dos Horarios na Criacao do Calendario
									.T.					 ;	//22 -> Se carrega as marcacoes desconsideradas (Uso com lPort1510)
							 	)
					aAdd(aLogFile, '- Nao Foi Possivel Carregar as Marcacoes do Funcionario'  + AllTrim(cTno) + '.')													// '- Nao Foi Possivel Carregar as Marcacoes do Funcionario'
					SRA->( aAdd(aLogFile, '  As marca��es do funcionario '  + AllTrim(cMat) + ' - ' + AllTrim(cNome) + ' nao' ) )			// '  As marca��es do funcionario '###' nao'
					aAdd(aLogFile,  '  serao classificadas/apontadas.' )																		// '  serao classificadas/apontadas.'
					Break
				EndIF

		        /*/
				�������������������������������������������������������������Ŀ
				� Copia de aMarcacoes para Comparacao na Saida                �
				���������������������������������������������������������������/*/
				aMarcClone := aClone( aMarcTot )
				
				If lPort1510
					aMarcacoes := {}
					aMarcDel   := {}
					aScan( aMarcTot, { |x| If (x[27] == "D",aAdd(aMarcDel,aClone(x)),aAdd(aMarcacoes,aClone(x))) } )
				Else
					aMarcacoes := aMarcTot
				EndIf

				/*/
				��������������������������������������������������������������Ŀ
				� Aborta o processamento caso seja pressionado Alt + A         �
				����������������������������������������������������������������/*/
				IF ( lAbortPrint )
					aAdd(aLogFile, '- Cancelado pelo Operador em '  + Dtoc(MsDate()) + ', as ' + Time() + ' ...') // '- Cancelado pelo Operador em '
					Break
				EndIF

				/*/
				��������������������������������������������������������������Ŀ
				�Ponto de Entrada Para Array a Marcacoes antes da Ordenacao das�
				�Marcacoes, Antes do Apontamento e Antes de Gravar no SP8.     �
				����������������������������������������������������������������/*/
				IF ( lPonapo1Block )
					IF ( ValType( uRet := ExecBlock( "PONAPO1" , .F. , .F. , aMarcacoes ) ) == "A" )
						aMarcacoes	:= aClone( uRet )
						uRet		:= NIL
					EndIF
				EndIF

				If lPort1510 .and. !Empty(aMarcDel)
					For nMarc := 1 to Len(aMarcDel)
						aAdd( aMarcacoes , aClone(aMarcDel[nMarc]) )
					Next nMarc
				EndIf


				/*/
				�������������������������������������������������������������Ŀ
				� Ordena as marca��es                                         �
				���������������������������������������������������������������/*/
				PutOrdMarc( @aMarcacoes , aTabCalend , ( ( nReaponta == 1 ) .or. ( nReaponta == 3 ) ), lAjustMarc, If( nLoopFim == 1, dPerIGeA,( If( nLoop == 1, dPerIGeA, If( lLimitaDataFim, Min( dDataBase, dPerIni ), dPerIni ) ) ) ), If( nLoopFim == 1, dPerFGeA,( If( nLoop == 1, dPerFGeA, If( lLimitaDataFim, Min( dDataBase, dPerFim ), dPerFim ) ) ) ), cFil, cMat, aCalenAux )

				If lPort1510 .and. !Empty(aMarcDel)
					aMarcTot   := aMarcacoes
					aMarcacoes := {}
					aMarcDel   := {}
					aScan( aMarcTot, { |x| If (x[27] == "D",aAdd(aMarcDel,aClone(x)),aAdd(aMarcacoes,aClone(x))) } )
				EndIf

				/*/
				�������������������������������������������������������������Ŀ
				� Gera marca�oes Autom�ticas.                                 �
				���������������������������������������������������������������/*/
				aMarcAux:={}
				PutMarcAuto( aTabCalend , @aMarcacoes , If( nLoopFim == 1, dPerIGeA,( If( nLoop == 1, dPerIGeA, If( lLimitaDataFim, Min( dDataBase, dPerIni ), dPerIni ) ) ) ) , If( nLoopFim == 1, dPerFGeA,( If( nLoop == 1, dPerFGeA, If( lLimitaDataFim, Min( dDataBase, dPerFim ), dPerFim ) ) ) ), cFil, Nil, NIl, @aMarcAux )

				//-- Inclui ocorrencias de marcacoes n�o geradas
				If !Empty(aMarcAux)
					AADD(aMarcNoGer,{cMat + "-" + cNome, aMarcAux})
				EndIf

				/*/
				��������������������������������������������������������������Ŀ
				�Ponto de Entrada Para Array a Marcacoes Apos Ordenado e Com as�
				�Marcacoes Automaricas Antes do Apontamento e Antes de   Gravar�
				�no SP8                                                        �
				����������������������������������������������������������������/*/
				IF ( lPonaPo5Block )
					IF ( ValType( uRet := ExecBlock("PONAPO5" , .F. , .F. , { aMarcacoes , aTabcalend } ) ) == "A" )
						aMarcacoes	:= aClone(uRet)
						uRet 		:= NIL
					EndIF
				EndIF

				/*/
				�������������������������������������������������������������Ŀ
				� Troca Filiais para Integridade		                      �
				���������������������������������������������������������������/*/
				cFilAnt := IF( !Empty( cFil ) , cFil , cFilAnt )

				IF (;
						( nTipo == 2 );	//2=Apontamento
						.or.;
						( nTipo == 3 );	//3=Ambos
					 )

					aResult := {}

				    /*/
					��������������������������������������������������������������Ŀ
					� Quando o Apontamento nao for pela data da Marcacao e nao  for�
					� forcado o Reapontamento, carrega os Eventos que ja Haviam  si�
					� do Apontados e que nao Sofreram  alteracoes.				   �
					����������������������������������������������������������������/*/
					IF (;
							!( lApHeDtm );
							.and.;
							(;
								( nReaponta == 2 );
								.or.;
								( nReaponta == 4 );
							 );
						)
						aLastApo := GetLastApo( If( nLoopFim == 1, dPerIGeA,( If( nLoop == 1, dPerIGeA, If( lLimitaDataFim, Min( dDataBase, dPerIni ), dPerIni ) ) ) ) , If( nLoopFim == 1, dPerFGeA,( If( nLoop == 1, dPerFGeA, If( lLimitaDataFim, Min( dDataBase, dPerFim ), dPerFim ) ) ) ) )
						GetNewResult( @aResult , aLastApo , aMarcacoes , aTabCalend )
					EndIF

					/*/
					�������������������������������������������������������������Ŀ
					� Verifica param.Turno se a 1a.Falta � DSR e                  �
					� Verifica as datas de Excecoes quando for 1a.Falta=Folga     �
					���������������������������������������������������������������/*/
					fDiasFolga( aClone( aMarcacoes ) , @aTabCalend , dPerIni , dPerFim , cDsrAutPa )

					/*/
					�������������������������������������������������������������Ŀ
					� Efetua o apontamento das marca��es                          �
					���������������������������������������������������������������/*/
					dPerFGeA	:= Min( dDataBase , dPerFGeA )
					IF !Aponta(	If( nLoop == 1 .And. !lPonWork, dPerIGeA, aPeriodos[nPosPerIni] ) 	,;	//01 - Periodo Inicial do Apontamento
								If( nLoop == 1 .And. !lPonWork, dPerFGeA, aPeriodos[nPosPerFim] ) 	,;	//02 - Periodo Final do Apontamento
								@aMarcacoes								,;	//03 - Array com as Marcacoes dos Funcionarios
								aTabCalend								,;	//04 - Array com o Calendario de Marcacoes
								cFil									,;	//05 - Filial do Funcionario
								cMat									,;	//06 - Matricula do Funcionario
								aCodigos								,;	//07 - Array com os Eventos do Ponto
								@aResult								,;	//08 - Array com os Resultados Dia a Dia
								If(nLoop == 1, .T., .F.)				,;	//09 - Gravar Apontamento
								.F.										,;	//10 - Se Permite interrupcao durante o Processamento (HELP)
								@aLogFile								,;	//11 - Array com os Logs de Apontamento
								@aAbonosPer								 ;	//12 - Array com Todos os Abonos do Periodo (Por Referencia)
							   )
						SRA->( aAdd( aLogFile , '- Nao foi possivel realizar o apontamento das marcacoes do' + 'funcionario ' + AllTrim(cMat) + ' - ' + cFil+'/'+AllTrim( cNome ) + "."  ) ) // '- Nao foi possivel realizar o apontamento das marcacoes do' ###'funcionario '
					EndIF

				EndIF

				If lPort1510 .and. !Empty(aMarcDel)
					For nMarc := 1 to Len(aMarcDel)
						aAdd( aMarcacoes , aClone(aMarcDel[nMarc]) )
					Next nMarc
				EndIf

			    /*/
				�������������������������������������������������������������Ŀ
				� Verifica se Houve alteracao para efetuar a gravacao         �
				���������������������������������������������������������������/*/
				IF !( ArrayCompare( aMarcClone , aMarcacoes ) )
			    	/*/
					��������������������������������������������������������������Ŀ
					� Deleta os Registros de Marcacoes Automaticas que foram  recar�
					� regadas													   �
					����������������������������������������������������������������/*/
					IF !( lGetMarcAuto )
						PonDelRecnos( "SP8" , aRecsMarcAutDele , bCondDelAut )
					EndIF
			    	/*/
					�������������������������������������������������������������Ŀ
					� Procura o Elemento inicial para a Gravacao das Marcacoes    �
					���������������������������������������������������������������/*/
					nSizeaMcClo		:= Len( aMarcClone )
					nSizeaMarca		:= Len( aMarcacoes )
					nMinSize		:= Min( nSizeaMcClo , nSizeaMarca )
	   				/*/
					�������������������������������������������������������������Ŀ
					�Grava as Marcacoes no SP8         						  	  �
					���������������������������������������������������������������/*/
					IF ( nMinSize > 0 )
						For nX := 1 To nMinSize
							IF !( ArrayCompare( aMarcClone[ nX ] , aMarcacoes[ nX ] ) )
			    				/*/
								�������������������������������������������������������������Ŀ
								� Grava Apenas o que foi Alterado							  �
								���������������������������������������������������������������/*/
								PutMarcacoes( { aMarcacoes[ nX ] } , cFil , cMat , "SP8" , .F., Nil, Nil, Nil, lWorkFlow, nTipo )
							EndIF
						Next nX
						/*/
						�������������������������������������������������������������Ŀ
						� Grava as Novas informacoes                                  �
						���������������������������������������������������������������/*/
						IF ( ( nX > nMinSize ) .and. ( nMinSize < nSizeaMarca ) )
							PutMarcacoes( aMarcacoes , cFil , cMat , "SP8" , .F. , NIL , nX, Nil, lWorkFlow, nTipo )
						EndIF
					Else
	    				/*/
						�������������������������������������������������������������Ŀ
						� Grava Todas as Marcacoes        							  �
						���������������������������������������������������������������/*/
						PutMarcacoes( aMarcacoes , cFil , cMat , "SP8" , .F., Nil, Nil, Nil, lWorkFlow, nTipo )
					EndIF
			    	/*/
					�������������������������������������������������������������Ŀ
					� Reinicializa aMarcClone									  �
					���������������������������������������������������������������/*/
					aMarcClone := {}
				EndIF

				If lPort1510 .and. !Empty(aMarcDel)
					aMarcTot   := aMarcacoes
					aMarcacoes := {}
					aMarcDel   := {}
					aScan( aMarcTot, { |x| If (x[27] == "D",aAdd(aMarcDel,x),aAdd(aMarcacoes,x)) } )
				EndIf

			    /*/
				��������������������������������������������������������������Ŀ
				� Ponto de Entrada Para Array a Marcacoes apos Gravar o SP8    �
				����������������������������������������������������������������/*/
				IF ( lPonapo2Block )
					IF ( ValType( uRet := ExecBlock( "PONAPO2" , .F. , .F. , { aMarcacoes , aTabcalend } ) ) == "A" )
						aMarcacoes	:= aClone( uRet )
						uRet		:= NIL
					EndIF
				EndIF

				/*/
				��������������������������������������������������������������Ŀ
				� Executa o Ponto de Entrada Que Deixou de Ser Executado     no�
				� Apontamento												   �
				����������������������������������������������������������������/*/
				IF ( lPonaPo3Block )
					ExecBlock( "PONAPO3" , .F. , .F. , { aClone( aMarcacoes ) , aClone( aTabCalend ) } , .F. )
				EndIF

			    /*/
				��������������������������������������������������������������Ŀ
				� Restaura Filial de entrada da Rotina						   �
				����������������������������������������������������������������/*/
				cFilAnt	:= cSvFilAnt

		    EndIF

		/*/
		�������������������������������������������������������������Ŀ
		� Final do Processo de Classificacao das Marcacoes            �
		���������������������������������������������������������������/*/

		/*/
		�������������������������������������������������������������Ŀ
		� Inicio do Processo de Classificacao das Refeicoes           �
		���������������������������������������������������������������/*/
			IF ( ( nAponta == 2 )  .or. ( nAponta == 4 ) .or. ( nAponta == 5 ) ) //2=Refeicoes;4=Marc e Ref ;5=Todos

				IF ( ( nTipo == 2 ) .or. ( nTipo == 3 ) ) //2=Apontamento 3=Ambos

					/*/
					�������������������������������������������������������������Ŀ
					� Carrega Tabela de Refeicao                                  �
					���������������������������������������������������������������/*/
					IF ( cFil <> cFilRefAnt )
						cFilRefAnt := cFil
						IF !fTabRef( @aTabRef , fFilFunc("SP1") )
							//--Registra Inconsistencia
							IF ( aScan( aLogFile , { |x| ( x == '*** ATENCAO: APONTAMENTO NAO CONCLUIDO ***' ) } ) == 0 )
								aAdd(aLogFile,  '*** ATENCAO: APONTAMENTO NAO CONCLUIDO ***' )			// '*** ATENCAO: APONTAMENTO NAO CONCLUIDO ***'
								aAdd(aLogFile, 'Tabela de Refeicao Inconsistente:' )  	  		// 'Tabela de Refeicao Inconsistente:'
								aAdd(aLogFile, '- Tipo de Refeicao Nao Cadastrado: ' + "ZZ")		//'- Tipo de Refeicao Nao Cadastrado: '
							EndIF
							IF ( nAponta == 2 )
								lApontaOk := .F.
							EndIF
							Break
						EndIF
					EndIF

					nLenCalend	:=	Len(aTabCalend)
					nOrdemData	:= aTabCalend[nLenCalend,2]
					nPosFim 	:= aScan( aTabCalend, { |x| x[2] == nOrdemData } )
					nPosUtMarc	:= nLenCalend - nPosFim
					
					/*/
					�������������������������������������������������������������Ŀ
					� Estabelece Datas para Inicio e Final do Per�odo            �
					���������������������������������������������������������������/*/
					If ( ( ( nPosIni := aScan( aTabCalend, { |x| x[1] == dPerDe } ) ) > 0 ) .And. ( nPosFim > 0 ) .And. ( Len( aTabCalend ) >= nPosFim + nPosUtMarc ) )
						nSerIni := __fDhtoNS( aTabCalend[ nPosIni , 17 , 1 ], aTabCalend[ nPosIni, 17 , 2 ] )
						nPosFim	+= nPosUtMarc
						nSerFim := __fDhtoNS( aTabCalend[ nPosFim , 17 , 1 ], aTabCalend[ nPosFim ,17 , 2 ] )
						//-- Quando Ultima Sequencia da Tabela Tiver Horario Zerado, soma mais um dia
						IF ( aTabCalend[ nPosFim , 3 ] == 0 )
							++nSerFim
						EndIF
					Else
						nSerIni := __fDhtoNS( aTabCalend[ 1 , 17 , 1 ], aTabCalend[ 1, 17 , 2 ] )
						nSerFim := __fDhtoNS( aTabCalend[Len(aTabCalend),17,1] , aTabCalend[Len(aTabCalend),17,2] )
						//-- Quando Ultima Sequencia da Tabela Tiver Horario Zerado, soma mais um dia
						IF ( aTabCalend[ Len( aTabCalend ) , 3 ] == 0 )
							++nSerFim
						EndIF
					EndIf
					/*/
					�������������������������������������������������������������Ŀ
					� Classifica as Refeicoes dos Funcionarios                    �
					���������������������������������������������������������������/*/
					IF !fGeraRef( aTabCalend , cFil , cMat , nSerIni , nSerFim , ( ( nReaponta == 2 ) .or. ( nReaponta == 3 ) ) , cPd , cPdEmpr )
					 	//--Registra Inconsistencia
			      	    aAdd(aLogFile, "" )
					    aAdd(aLogFile, '*** ATENCAO: APONTAMENTO NAO CONCLUIDO ***' )      // '*** ATENCAO: APONTAMENTO NAO CONCLUIDO ***'
						IF ( nAponta == 2 )
							lApontaOk := .F.
						EndIF
						Break
					EndIF

				EndIF

			EndIF
		/*/
		�������������������������������������������������������������Ŀ
		� Final do Processo de Classificacao das Refeicoes            �
		���������������������������������������������������������������/*/
	Next nLoop

End Sequence

cFilAnt := cSvFilAnt
RestArea( aAreaSP8 )

/*/
�������������������������������������������������������������Ŀ
� Numero de Funcionarios Processados						  �
���������������������������������������������������������������/*/
++nFuncProc

/*/
�������������������������������������������������������������Ŀ
� Verifica se Deve continuar o Processamento				  �
���������������������������������������������������������������/*/
IF ( lApontaOk )
	lApontaOk := (;
						!( lAbortPrint );
						.and.;
						( lChkPonMesAnt );
				 )
EndIF

Return( lApontaOk )

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �GetDespMin   � Autor �Marinaldo de Jesus   � Data �09/09/2004�
������������������������������������������������������������������������Ĵ
�Descri��o �Retorna Conteudo Valido Referente ao parametro MV_DESPMIN	 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/
Static Function GetDespMin()
Return( Min( __Min2Hrs( Val( SuperGetMv("MV_DESPMIN",NIL,"0") ) ) , 0.59 ) )

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �Ponm010CcChk � Autor �Marinaldo de Jesus   � Data �15/09/2004�
������������������������������������������������������������������������Ĵ
�Descri��o �Verifica se o Centro de Custo do Relogio eh Valido       	 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
�Uso       �PONM010                                                      �
��������������������������������������������������������������������������/*/
Static Function Ponm010CcChk( cCusto )

IF Empty( cCusto )				// Se nao Tiver Centro de Custo
	cCusto := SP0->P0_CC		//Assume o Cadastrado no Relogio
	IF Empty( cCusto )      	//Caso Contrario
		cCusto := SRA->RA_CC	//Assume o Centro de Custo do SRA
	ElseIF !( Upper( AllTrim( cCusto ) ) == Upper( AllTrim( PosAlias( cAliasCc , cCusto , cFilSRA , cCampoCc , nOrdemCc , .F. ) ) ) )
		cCusto := SRA->RA_CC	//Assume o Centro de Custo do SRA Se o Centro de Custo nao Estiver Cadastrado
	EndIF
ElseIF !( Upper( AllTrim( cCusto ) ) == Upper( AllTrim( PosAlias( cAliasCc , cCusto , cFilSRA , cCampoCc , nOrdemCc , .F. ) ) ) )
	cCusto := SP0->P0_CC		//Assume o Cadastrado no Relogio
	IF Empty( cCusto )      	//Caso Contrario
		cCusto := SRA->RA_CC	//Assume o Centro de Custo do SRA
	ElseIF !( Upper( AllTrim( cCusto ) ) == Upper( AllTrim( PosAlias( cAliasCc , cCusto , cFilSRA , cCampoCc , nOrdemCc , .F. ) ) ) )
		cCusto := SRA->RA_CC	//Assume o Centro de Custo do SRA Se o Centro de Custo nao Estiver Cadastrado
	EndIF
EndIF

Return( cCusto )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fGeraRef � Autor � Mauricio MR           � Data � 02/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Classificar as marcacoes de refeicoes                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
static Function fGeraRef( aTabCalend , cFil , cMat , nSerIni , nSerFim , lReaponta , cPdPar , cPdEmprPar )

Local aArea			:= GetArea()
Local aStruSP5		:= SP5->( dbStruct() )       //Colocar no Inicio do Programa
Local cAliasSP5		:= 'SP5'
Local cFilMat		:= ""
Local cSvFilAnt		:= cFilAnt
Local uRet

//-- Marcacoes de Refeicao
Local aCampos		:=	{}
//-- Query
Local nContField	:=	0
Local cQuery		:= ''
Local nX			:=	0
Local nPosCalend	:=	0
//-- Identificacao da Refeicao
Local cCodRef		:=	''
Local cSeqRef		:=	''
Local cTipoRef		:=	''
Local cGeraFol		:=	''
Local cPD			:=	''
Local cPDEmpr		:=	''
Local nSeqMarc		:=	0
Local nValref		:=	0
Local nDescFun		:=	0
Local nSerMarc		:=  0
Local cRelogio		:= ''
Local dDataApo		:= CTOD("//")

//-- Variaveis auxiliares para buscar a Identificacao das Refeicoes
Local cData			:=	''
Local cHora			:=	''
Local cHoraAux		:=	''
Local aTabRef		:=	{}   //Tabela com as Informacoes de Identificacao de Refeicao
Local aContSeq		:=	{}   //Array contador de Seq de Marcacao por Data/Tipo
Local nPosTipo		:=	0
Local lRet			:=	.T.
Local lSp5QryOpened	:= .F.

/*/
�������������������������������������������������������������Ŀ
� Troca Filial para Integridade								  �
���������������������������������������������������������������/*/
cFilAnt	:= IF( !Empty( cFil ) , cFil , cFilAnt )

//�������������������������������������������������������������Ŀ
//� Cria array com as marca��es do Periodo para o funcion�rio.  �
//���������������������������������������������������������������
aMarcRef := {}
SP5->( dbSetOrder( RetOrdem( "SP5" , "P5_FILIAL+P5_MAT+DTOS(P5_DATA)+STR(P5_HORA,5,2)" ) ) )

IF !( lExInAs400 )
	cInicio		:= Dtos( aTabCalend[ 01 , 01 ] - 7 )
	cFinal		:= Dtos( aTabCalend[ Len(aTabCalend) , 01 ] + 7 )
	cAliasSP5	:= "QSP5"
	nContField	:= Len(aStruSP5)
	cQuery := "SELECT "
	For nX := 1 To nContField
        cQuery += aStruSP5[ nX , 01 ] + ", "
	Next nX
	cQuery += "R_E_C_N_O_ RECNO "
	cQuery += "FROM "+InitSqlName("SP5")+" SP5 "
	cQuery += "WHERE SP5.P5_FILIAL='"+SRA->RA_FILIAL+"' AND "
	cQuery += "SP5.P5_MAT='"+SRA->RA_MAT+"' AND "
	cQuery += "SP5.P5_DATA>='"+cInicio+"' AND "
	cQuery += "SP5.P5_DATA<='"+cFinal+"' AND "
	cQuery += "SP5.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "+SqlOrder( SP5->( IndexKey() ) )
	cQuery := ChangeQuery(cQuery)
	IF ( lSp5QryOpened := MsOpenDbf(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSP5,.T.,.T.,.F.,.F.))
		For nX := 1 To nContField
			IF ( aStruSP5[nX][2] <> "C" )
				TcSetField(cAliasSP5,aStruSP5[nX][1],aStruSP5[nX][2],aStruSP5[nX][3],aStruSP5[nX][4])
			EndIF
		Next nX
	EndIF
EndIF
IF !( lSp5QryOpened )
	cAliasSP5 := "SP5"
EndIF

cFilMat := ( cFil + cMat )

IF !( lSp5QryOpened )
	(cAliasSP5)->( MsSeek( cFilMat , .F.) )
EndIF
//--Carrega as Marcacoes de Refeicao do Filial + Mat para o Array aCampos
While (cAliasSP5)->( !Eof() .and. ( cFilMat == P5_FILIAL + P5_MAT ) )

	//��������������������������������������������������������������Ŀ
	//� Aborta o processamento caso seja pressionado Alt + A         �
	//����������������������������������������������������������������
	IF ( lAbortPrint )
		aAdd(aLogFile, '- Cancelado pelo Operador em '  + Dtoc(MsDate()) + ', as ' + Time() + ' ...') // '- Cancelado pelo Operador em '
		Exit
	EndIF

	//-- Ignora marca��es fora do Per�odo
	IF (cAliasSP5)->( nSerMarc := __fDhtoNS(P5_DATA,P5_HORA) ) < nSerIni .or. nSerMarc > nSerFim
		(cAliasSP5)->( dbSkip() )
		Loop
	EndIF
	aAdd(aCampos, Array( 16 ) )             					//-- ** Array aCampos **
 	nLenCampos := Len( aCampos )
	(cAliasSP5)->(aCampos[nLenCampos,01] := P5_DATA			)	//-- 01 Data
	(cAliasSP5)->(aCampos[nLenCampos,02] := P5_HORA			)	//-- 02 Hora
	IF !( lSp5QryOpened )
		(cAliasSP5)->(aCampos[nLenCampos,03] := Recno() )	//-- 03 Recno em SP5
	Else
		(cAliasSP5)->(aCampos[nLenCampos,03] := RECNO	)	//-- 03 Recno em SP5
	EndIF

	(cAliasSP5)->(aCampos[nLenCampos,04] := P5_CC  			)	//-- 04 Centro de Custo
	(cAliasSP5)->(aCampos[nLenCampos,05] := P5_RELOGIO 		)	//-- 05 Relogio
	(cAliasSP5)->(aCampos[nLenCampos,06] := P5_FLAG    		)	//-- 06 Flag Origem Marc
 	(cAliasSP5)->(aCampos[nLenCampos,07] := P5_SEQ    	   		)	//-- 07 Seq. Refeicao
	(cAliasSP5)->(aCampos[nLenCampos,08] := P5_TIPOREF    		)	//-- 08 Tipo Refeicao
	(cAliasSP5)->(aCampos[nLenCampos,09] := P5_GERAFOL   		)	//-- 09 Gerar p/folha
 	(cAliasSP5)->(aCampos[nLenCampos,10] := P5_PD   			)	//-- 10 Cod. Desc. Ref. Func.
  	(cAliasSP5)->(aCampos[nLenCampos,11] := P5_VALREF   		)	//-- 11 Valor da Refeicao
	(cAliasSP5)->(aCampos[nLenCampos,12] := P5_APONTA   		)	//-- 12 Flag de Apontamento
   	(cAliasSP5)->(aCampos[nLenCampos,13] := P5_CODREF  		)	//-- 13 Cod. da Refeicao
    (cAliasSP5)->(aCampos[nLenCampos,14] := P5_PDEMPR 			)	//-- 14 Cod. Desc. Ref. Empresa
	(cAliasSP5)->(aCampos[nLenCampos,15] := P5_DESCFUN			)	//-- 15 Desc. Ref. Funcionario
	(cAliasSP5)->(aCampos[nLenCampos,16] := P5_DATAAPO			)	//-- 16 Data de Apontamento
	(cAliasSP5)->( dbSkip() )

EndDo

IF ( lSp5QryOpened )
   ( cAliasSP5 )->( dbCloseArea() )
   dbSelectArea( "SP5" )
EndIF

//-- Indexa as Marcacoes de Refeicao  por Data + Hora
aSort(@aCampos,,,{|x,y| DtoS(x[1])+StrTran(StrZero(x[2],5,2),'.','') < DtoS(y[1])+StrTran(StrZero(y[2],5,2),'.','')})

//-- Inicia a Gravacao das Informacoes de Identificacao das Refeicoes
SP5->( dbSetOrder( RetOrdem( "SP5" , "P5_FILIAL+P5_MAT+DTOS(P5_DATA)+STR(P5_HORA,5,2)" ) ) )

//-- Inicializa as variavies auxiliares
nLenCampos 	:= 	Len( aCampos )  	//-- Total de Marcacoes de Refeicoes
cData		:= 	''               	//-- Variavel para verificacao de quebra de Data
cHora       := 	'' 					//-- Variavel para verificacao de quebra de Hora
cHoraAux	:= 	''

//-- Corre Todas as Marcacoes de Refeicoes para Identificar o Tipo de Refeicao
For nX := 1 to nLenCampos

	//-- Se Nao Reaponta e Aponta ='S' desconsidera para efeito de classificacao
	//-- da refeicao
	IF !lReaponta .and. aCampos[ nX , 12 ] == "S"
		Loop
	EndIF

	//-- Se quebra de Data
	If cData <> Dtos( aCampos[ nX,1 ] )
	   //-- Posiciona na Tabela Calendario (Data)  para obter o Codigo de Ref. da Data
		IF ( nPosCalend := aScan( aTabCalend, {|x| (x[17,1] == aCampos[nX,1] .and. x[17,2] >= aCampos[nX,2]) .OR. (x[17,1] > aCampos[nX,1]) } ) ) > 0
			//-- Obtem o Codigo de Refeicao da Data da Marcacao lida na TabCalend
			cCodRef	:=	aTabCalend[nPosCalend][18]
			dDataApo:=	aTabCalend[nPosCalend][1]
		EndIF
	Endif

	//Inicializa variavel auxiliar para conter a Hora da Refeicao
	cHoraaux :=	Str( aCampos[ nX,2 ],5,2 )

	//-- Se Codigo de Refeicao em Branco Nao houve controle sobre a Marcacao da Refeicao
	//-- gera Valores Padrao  ("ZZ" - Outros)
	If Empty(cCodRef)
	   cSeqRef		:=	''
	   cTipoRef		:=	'ZZ'
	   cGeraFol		:=	'S'
	   cPD			:=	cPdPar
       cPDEmpr		:=	cPdEmprPar
	   nValRef		:=	0
	   nDescFun		:=	0
	   dDataApo		:=  CTOD("//")
	Else
	   //Se marcacao gerada pela Leitura do Relogio
	   If aCampos[nX,6] == 'E'
		    cRelogio:=	aCampos[nX,5]
			//Identifica a Refeicao na Data/Hora marcada (Somente Checa Refeicoes Geradas)
		    If Empty(Len(aTabRef:=Aclone(fIdentRef(aTabCalend,cHoraAux,cCodRef,Dtoc( aCampos[ nX,1 ] ), cRelogio  ))))
		    	//Nao Encontrou a Tabela de Refeicao /Tipo de Refeicao de Acordo com o Codigo passado
			    lRet:= .F.
				Exit
			Endif

           	//-- Iguala Conteudo de Variaveis utilizadas para atualizacao de campos
           	//-- Conteudo de aTabRef
	   		//----	{P1_Seq, P1_TipoRef, P1_Horaini, P1_HoraFim, P1_GeraFol, P1_PD, PM_ValRef, PM_PDEMPR, PM_DESCFUN}
			cSeqRef		:=	aTabRef[1]
			cTipoRef	:=	aTabRef[2]
			cPD			:=	aTabRef[6]
			nValRef		:=	aTabRef[7]
			cPDEmpr		:=	aTabRef[8]
			nDescFun	:=	aTabRef[9]

   			//-- Se o Valor da Refeicao Nao For Nulo e Nao Houver Desconto do Funcionario
   			//-- Flag serah setado para Nao descontar o valor da refeicao na Folha de Pagto.
   			If !Empty(nValRef) .and. Empty(nDescFun)
   	  			cGeraFol	:="N"
   			Else
   				cGeraFol	:=	aTabRef[5]
   			Endif

	   Else
	   		//-- Marcacoes Cadastradas pelo Usuario sao Regravadas
			cSeqRef		:=	aCampos[nX,07]
			cTipoRef	:=	aCampos[nX,08]
			cGeraFol	:=	aCampos[nX,09]
			cPD	   		:=	aCampos[nX,10]
			nValRef		:=	aCampos[nX,11]
			cCodRef		:=  aCampos[nX,13]
			cPDEmpr		:=	aCampos[nX,14]
			nDescFun	:=	aCampos[nX,15]
	   Endif
	Endif
	//--Iguala Variaveis verificadoras de quebra Data/Hora
	cData 	:= Dtos( aCampos[ nX,1 ] )
	cHora 	:= Str( aCampos[ nX,2 ],5,2 )

	aCampos[nX,07]	:= cSeqRef
	aCampos[nX,08]	:= cTipoRef
	aCampos[nX,09]	:= cGeraFol
	aCampos[nX,10]	:= cPD
	aCampos[nX,11]	:= nValRef
	aCampos[nX,12]	:= "S"
	aCampos[nX,13]	:= cCodRef
	aCampos[nX,14]	:= cPDEmpr
	aCampos[nX,15]	:= nDescFun
	aCampos[nX,16]	:= dDataApo
	//Pega Proxima Marcacao de Refeicao
Next nX

//Se Nao foi encontrada inconformidade na rotina de classificacao gera as seq ref
If lRet
	//-- Indexa as Marcacoes de Refeicao  por Data + Tippo
	aSort(@aCampos,,,{|x,y| DtoS(x[1])+ x[8] < DtoS(y[1])+ y[8]})

	/*/
	�������������������������������������������������������������Ŀ
	� Ponto de Entrada para Tratamento das Refeicoes antes da	  �
	� classificacao e gravacao de suas sequencias				  �
	���������������������������������������������������������������/*/
	IF ( lPnm010Ref1Block )
		IF ( ValType( uRet := ExecBlock("PNM010REF1",.F.,.F.,aClone(aCampos) ) ) == "A" )
			 aCampos		:= If( ValType(uRet) == "A", uRet , aCampos	)
		EndIF
	EndIF

	//-- Inicializa as variavies auxiliares
	nSeqMarc 	:=	0 		//-- Sequencia da Marcacao da Refeicao
	cData		:= ''       //-- Variavel para verificacao de quebra de Data
	cTipoRef	:=	'' 		//-- Variavel para verificacao de Tipo de Refeicao

	//-- Corre Todas as Marcacoes de Refeicoes
	For nX := 1 to nLenCampos

		//--Verifica a Quebra de Data/Tipo da Marcacao
		If (cData + cTipoRef ) <>	;
		   ( Dtos( aCampos[ nX,1 ] ) + aCampos[ nX,8 ] )


			//-- Se quebra de Data
			If cData <> Dtos( aCampos[ nX,1 ] )
				cData 		:= 	Dtos( aCampos[ nX,1 ] )
			  	//-- Inicializa array contador de seq de tipo ref por Tipo
				aContSeq := {}
				nPosTipo := 0
				//-- Se ocorreu quebra de data, zera contador de Sequencia de Refeicao
				nSeqMarc :=	0
			Endif

			//Se Houve Quebra de Tipo de Refeicao na Data Lida
		    If cTipoRef  <> aCampos[ nX,8 ]

				cTipoRef	:=	aCampos[ nX,8 ]

		    	//--Inicializa a Sequencia de Marcacoes de Refeicao
				//-- Se aContSeq nao Vazia
				IF nPosTipo > 0
					aContSeq[ nPosTipo , 2 ] := nSeqMarc
					nSeqMarc := 0
				EndIF

				IF ( nPosTipo := aScan( aContSeq,{ |xtipo| xtipo[1] == cTipoRef } ) ) == 0
				    aAdd( aContSeq , { cTipoRef , 0 } )
					nPosTipo := Len( aContSeq )
				EndIF

				//-- Iguala a variavel contador de seq com o valor anterior da seq
				nSeqMarc := aContSeq[ nPosTipo , 2 ]

			Endif

		Endif

		//--Posiciona no Registro do SP5  conforme numero de registro armazenado anteriormente
		SP5->(DbGoto(aCampos[nX][3]))

		IF SP5->( RecLock( "SP5" , .F. ) )
			SP5->P5_CODREF		:= aCampos[nX][13]
			SP5->P5_SEQ			:= aCampos[nX][07]
			SP5->P5_TIPOREF		:= aCampos[nX][08]
			SP5->P5_SEQMARC		:= StrZero(++nSeqMarc,2)
			SP5->P5_GERAFOL 	:= aCampos[nX][09]
			SP5->P5_PD			:= aCampos[nX][10]
			SP5->P5_VALREF		:= aCampos[nX][11]
			SP5->P5_APONTA		:= aCampos[nX][12]
			SP5->P5_PDEMPR		:= aCampos[nX][14]
			SP5->P5_DESCFUN		:= aCampos[nX][15]
			SP5->P5_DATAAPO		:= aCampos[nX][16]
			SP5->( MsUnLock() )
		EndIF
		//Pega Proxima Marcacao de Refeicao
	Next nX
Endif

RestArea(aArea)

cFilAnt	:= cSvFilAnt

Return( lRet )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fIdentRef� Autor � Mauricio MR           � Data � 02/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Identifica as Refeicao da Marcacao                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
static Function fIdentRef(aTabCalend,pHora,cCodRef,cData, cRelogio)
Local aRet			:=	{}
Local nPosTabRef	:=	0
Local nPosTipoRef	:=	0
Local cHoraOrig		:=	''

cHoraOrig	:=	pHora

pHora		:=Val(pHora)


//--Procura a Tabela de Refeicao
nPosTabRef:=Ascan(aTabRef,{|xRef| xRef[1] == cCodRef})

//--Se Encontrou
If !EMPTY(nPosTabRef)

    //-- Procura o Tipo de Refeicao de acordo com o horario da marcacao
    //-- Verifica se Hora ini e Hora fim forem zeradas o Tipo Ref  eh "ZZ" e por
    //-- isso nao  considera esse horario para enquadramento da hora a ser classificada
    nPosTipoRef:=Ascan(aTabRef[nPosTabRef][2],;
           {|xTabTipoRef|Iif(	!Empty(xTabTipoRef[3]) .or. !Empty(xTabTipoRef[4]) 			,;
	                             ( Pna150Hor(,xTabTipoRef[3] , xTabTipoRef[4], pHora) 	.AND.   ;
	 	                         	(xTabTipoRef[10] == cRelogio)								;
	                             )		,;
                             	.F.		 ;
                             ) 			 ;
           })

    //-- Procura pelo Horario para Relogio em Branco se Nao encontrou para o relogio especifico
    If Empty(nPosTipoRef)
     	nPosTipoRef:=Ascan(aTabRef[nPosTabRef][2],;
           {|xTabTipoRef|Iif(	!Empty(xTabTipoRef[3]) .or. !Empty(xTabTipoRef[4]) 			,;
	                             ( Pna150Hor(,xTabTipoRef[3] , xTabTipoRef[4], pHora) 	.AND.   ;
	 	                         	(xTabTipoRef[10] == SPACE(LEN(xTabTipoRef[10])) )			;
	                             )		,;
                             	.F.		 ;
                             ) 			 ;
           })
    Endif

    //--Se Encontrou
    If !EMPTY(nPosTipoRef)

       //Obtem as informacoes sobre a refeicao
       // nSeqRef, cTipoRef ,  nSeqMarc	, cGeraFol	,  cPD
       aRet:=aTabRef[nPosTabRef][2][nPosTipoRef]

    Else

       	//--Registra Inconsistencia Sem Abortar Operacao
		aAdd(aLogFile, 'Tabela de Refeicao Inconsistente:' + cCodRef )  // 'Tabela de Refeicao Inconsistente:'
		aAdd(aLogFile, '- Horario nao encontrado: ' + cData+ ' '+ cHoraOrig) // '- Horario nao encontrado: '

       //Prenche array com conteudo para tipo de refeicao -> "Outros"
       	//--	{P1_Seq, P1_TipoRef, P1_Horaini, P1_HoraFim, P1_GeraFol, P1_PD, PM_ValRef}
        //-- Procura o Tipo de Refeicao "ZZ"
        nPosTipoRef:=Ascan(aTabRef[nPosTabRef][2],{|xTipoRef| xTipoRef[2] == "ZZ" })

        //--Se Encontrou Tipo "ZZ"
    	If !EMPTY(nPosTipoRef)

       		//Obtem as informacoes sobre a refeicao
       		// nSeqRef, cTipoRef ,  nSeqMarc	, cGeraFol	,  cPD
       		aRet:=aTabRef[nPosTabRef][2][nPosTipoRef]

    	Else

       		//--Registra Inconsistencia Sem Abortar Operacao
			aAdd(aLogFile, 'Tabela de Refeicao Inconsistente:' + cCodRef )  // 'Tabela de Refeicao Inconsistente:'
			aAdd(aLogFile, '- Tipo de Refeicao Nao Cadastrado: ' + "ZZ")	    //'- Tipo de Refeicao Nao Cadastrado: '
            aRet	:=	{'' , 'ZZ' ,,,'','', 0 }
        Endif
    Endif
Else
	//--Aborta Operacao
	aAdd(aLogFile, 'Tabela de Refeicao Inconsistente:' + cCodRef ) // 'Tabela de Refeicao Inconsistente:'
	aAdd(aLogFile, '- Codigo de Tabela nao encontrado' ) 			// '- Codigo de Tabela nao encontrado'
    aRet	:= {}
Endif

Return( aRet )

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � FTABREF   � Autor � Mauricio MR           � Data � 02/08/01 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Carregar Array com os Dados das Refeicoes para uma Filial   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � FTABREF(aTabRef,cFil)                                       ���
��������������������������������������������������������������������������Ĵ��
���Parametros� aTabRef = Array com os Dados das Refeicoes                  ���
���          � cFil    = Filial a ser Pesquisada                           ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Ponm010                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
static Function FTABREF( aTabRef, cFil )

Local aArea			:= 	GetArea()
Local aAreaSP1		:= 	{}
Local aAreaSPM		:= 	{}
Local aTabTipoRef	:=	{}
Local cTipoRefAnt	:=	''
Local nValRef		:=	0
Local cPD			:=	''
Local cPDEmpr		:=	''
Local nDescFun      := 	0
Local nElem			:=	0
Local lRet      	:= 	.T.

Local cCodRefAnt:= ''

//-- Carrega Tabela de Tipos de Refeicao
dbSelectArea('SPM')
aAreaSPM	:= GetArea()
SPM->(MsSeek(cFil))
While SPM->( !Eof() .and. PM_FILIAL == cFil )
	aAdd(aTabTipoRef, {	SPM->PM_TIPOREF,SPM->PM_VALREF, SPM->PM_PD, SPM->PM_PDEMPR,;
	              Round(SPM->PM_VALREF	* (SPM->PM_PERCFUN / 100),2) })

	SPM->(dbSkip())
EndDo

//-- Deve Haver pelo menos o Tipo de Refeicao ZZ
If Empty(Len( aTabTipoRef ) )
	lRet :=	.F.
Endif



//-- Corre Refeicoes se Houver Tipos Cadastrados
If LRet
	dbSelectArea('SP1')
	aAreaSP1	:= GetArea()

	// |--aTabRef  (ESTRUTURA)    (Nivel 01) ----------------------------------------------
	//	 |--CodRef                (Nivel 02)
	//   	|-------P1_Seq
	//		|-------P1_TipoRef
	//		|-------P1_Horaini
	//		|-------P1_HoraFim    (Nivel 03)
	//		|-------P1_GeraFol
	//		|-------P1_PD
	//		|-------PM_ValRef
	//		|-------PM_PDEmpr
	//		|-------PM_DescFun
	//-------------------------------------------------------------------------------

	SP1->(MsSeek(cFil))
	While SP1->( !Eof() .and. P1_FILIAL == cFil )

		If SP1->P1_CODREF <> cCodRefAnt
		   cCodRefAnt	:=	SP1->P1_CODREF
		   AAdd(aTabRef , {SP1->P1_CODREF,{}} )

		Endif

		//-- Verifica a Existencia do TipoRef na Tabela de Refeicoes
		If cTipoRefAnt# SP1->P1_TipoRef
			cTipoRefAnt:=SP1->P1_TipoRef
			nElem:=Ascan(aTabTipoRef,{|x| x[1] == SP1->P1_TIPOREF })
			If Empty(nElem)
			   aTabRef:={}
			   //--Registra Inconsistencia Aborta Operacao
				aAdd(aLogFile,  'Tabela de Refeicao Inconsistente:' + SP1->P1_CODREF )  // 'Tabela de Refeicao Inconsistente:'
				aAdd(aLogFile, '- Tipo de Refeicao Nao Cadastrado: ' + SP1->P1_TIPOREF)	//'- Tipo de Refeicao Nao Cadastrado: '

			   Exit
			Endif
			//-- Atualiza o Valor da Refeicao de acordo com o seu tipo
			nValref	:=	aTabTipoRef[nElem,2]
			//-- Atualiza o Cod.Evento Desc. Refeicao Parte Funcionario
			cPD		:=	aTabTipoRef[nElem,3]
			//-- Atualiza o Cod.Evento Desc. Refeicao Parte Empresa
			cPDEmpr	:=	aTabTipoRef[nElem,4]
			//-- Atualiza o Valor Desconto da Refeicao Parte Funcionario
			nDescFun	:=	aTabTipoRef[nElem,5]

		Endif

		aAdd(aTabRef[Len(aTabRef)][2] , {	SP1->P1_SEQ			,;
											SP1->P1_TIPOREF 	,;
											SP1->P1_HORAINI 	,;
											SP1->P1_HORAFIM  	,;
											SP1->P1_GERAFOL   	,;
											cPD 		    	,;
											nValRef 		    ,;
											cPDEmpr		    	,;
											nDescFun			})

	    //-- Se Existir o campo Relogio na Tabela de Refeicoes adiciona-o
	    aAdd(aTabRef[Len(aTabRef)][2][Len(aTabRef[Len(aTabRef)][2])] , SP1->P1_RELOGIO			)

		SP1->(dbSkip())
	EndDo
	RestArea( aAreaSP1 )
Endif

RestArea( aArea )

Return( lRet )

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �fVisitante   � Autor �Mauricio MR		   � Data �17/12/2003�
������������������������������������������������������������������������Ĵ
�Descri��o �Grava Marcacoes de Visitantes								 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/
Static Function fVisitante(cFilSPZ, cCracha, cSpyCracha , nLenSpyCracha, cSpyVisita, nLenSpyVisita, cSpyNumero, nLenSpyNumero, dData, nHora, cCodRel, cCusto , nGravadas,  cTipDesp, nDespVis)

Local aArea			:= GetArea()
Local aSPZArea		:= SPZ->(GetArea())
Local cKey			:= ''
Local cSeek 		:= ''
Local cSetOrdem		:= ""
Local cSvFilAnt		:= cFilAnt
Local lGrava		:= .T.
Local lMin
Local nAcessos		:= 1
Local nSetOrder

DEFAULT cSpyNumero:= Space(nLenSpyNumero)
DEFAULT cSpyVisita:= Space(nLenSpyVisita)


cSetOrder			:= ""

/*
�������������������������������������������������������������������������������������Ŀ
�Data  <=> _FILIAL+_MAT+_VISITA+_CRACHA+_NUMERO+_DTOS(_DATA)+STR(_HORA,5,2)    	  	  �
���������������������������������������������������������������������������������������*/
cSetOrdem += "PZ_FILIAL+PZ_VISITA+PZ_CRACHA+PZ_NUMERO+DTOS(PZ_DATA)+STR(PZ_HORA,5,2)"

nSetOrder	:= RetOrdem( "SPZ" , cSetOrdem )

SPZ->( dbSetOrder( nSetOrder ) )


cCracha	:= Left(cCracha + cSpyCracha, nLenSpyCracha)

cSeek 	:= ( cFilSPZ + cSpyVisita + cCracha + cSpyNumero + Dtos(dData) + Str(nHora,5,2)+ "3" )

IF ( !Empty(cTipDesp) .and. cTipDesp $ "N_M" )
	IF ( lMin  := ( cTipDesp == "M" ) )
		nDespVis	:= __Hrs2Min( nDespVis )
		cSeek		:= (  cFilSPZ + cSpyVisita + cCracha + cSpyNumero + Dtos(dData)  )
	Else
		cSeek		:= (  cFilSPZ + cSpyVisita + cCracha + cSpyNumero + Dtos(dData) + Str(nHora,5,2)+ "3" )
	EndIF
	IF SPZ->( dbSeek( cSeek , .F. ) )
		cKey := ( cFilSPZ + cSpyVisita + cCracha + cSpyNumero + Dtos(dData) )
		While SPZ->( !Eof() .and. ( PZ_FILIAL + PZ_VISITA + PZ_CRACHA + PZ_NUMERO + Dtos(PZ_DATA) == cKey ) ;
						    .and. IF(lMin,lMin,PZ_HORA == nHora ) )
			IF ( !( lMin ) .and. ( ( ++nAcessos ) > nDespVis ) )
				lGrava := .F.
			ElseIF ( ( lMin ) .and. ( __Hrs2Min( SPZ->( DataHora2Val(PZ_DATA,PZ_HORA,dData,nHora) ) ) <= nDespVis ) )
				lGrava := .F.
			EndIF
			IF !( lGrava )
				Exit
			EndIF
			SPZ->( dbSkip() )
		EndDo
	EndIF
EndIF

If lGrava
	cFilAnt		:= IF( !Empty( cFilSPZ ) , cFilSPZ , cFilAnt )
	IF RecLock( "SPZ" , .T. , .T. )
		SPZ->PZ_FILIAL	:= cFilSPZ
		SPZ->PZ_CRACHA  := cCracha
		SPZ->PZ_DATA	:= dData
		SPZ->PZ_HORA	:= nHora
		SPZ->PZ_RELOGIO := cCodRel
		SPZ->PZ_TPMARCA	:= "3"
		SPZ->PZ_FLAG	:= "E"
		SPZ->( MsUnlock() )
	EndIF
	++ nGravadas
Endif

RestArea(aSPZArea)
RestArea(aArea)

cFilAnt := cSvFilAnt

Return( NIL )




/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �SelecRel     � Autor �Mauricio MR		   � Data �07/03/2005�
������������������������������������������������������������������������Ĵ
�Descri��o �Seleciona Relogios e Arquivos para Leitura de marcacoes		 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/

Static Function SelecRel(lWorkFlow, lUserDefParam, cProcFil, lProcFil,  aArqSel,cTrbTmp)
Local cMarK				:= GetMark()
Local aSvKeys			:= GetKeys()
Local aAdvSize			:= {}
Local aInfoAdvSize		:= {}
Local aObjCoords		:= {}
Local aObjSize			:= {}
Local aButtons			:= {}

Local bSet15 			:= { || NIL }
Local bSet24			:= { || NIL }
Local bInitDlg			:= { || NIL }
Local bLDblClick		:= { || RhMkMrk( cTrbTmp , .F., .F. , cCpoCtrl, cMark, @aArqSel ),oDlg:Refresh() }
Local bAllMark			:= { || RhMkAll( cTrbTmp , .F., .T. , cCpoCtrl, cMark, oDlg, @aArqSel ),oDlg:Refresh() }
Local bAllUnMark		:= { || RhMkAll( cTrbTmp , .T., .T. , cCpoCtrl, cMark, oDlg, @aArqSel ),oDlg:Refresh() }

Local aBrowseFields		:= {}
Local cCpoCtrl			:= 'MARK'
Local cMsg				:= ""
Local oDlg
Local oMsSelect

//-- Variaveis de Parametros
Local nAponta
Local cFilDe
Local cFilAte
Local cFilSP0
Local cRelDe
Local cRelAte
Local lRelogios


/*/
��������������������������������������������������������������Ŀ
�Obtem conteudo dos parametros para pesquisa		     	   �
����������������������������������������������������������������/*/
cFilDe    := __LastParam__[1]
cFilAte   := __LastParam__[2]
cRelDe    := __LastParam__[3]
cRelAte   := __LastParam__[4]
nAponta	  := __LastParam__[5]

cFilSP0   := IF( !Empty( xFilial("SP0") ) , cFilDe , Space(02) )

CursorWait()
lRelogios:= Relogios(cTrbTmp,@aBrowseFields,  cMark, aArqSel, cFilSP0, cFilAte, cRelDe, cRelAte, nAponta)
CursorArrow()

Begin Sequence

    //-- Verifica a Existencia de Relogios conforme parametros
	If !lRelogios
		cMsg := "N�o foram encontrados"	//"N�o foram encontrados"
   		cMsg += CRLF
   		cMsg += 'Rel�gios conforme os ' //Rel�gios conforme os "
   		cMsg += CRLF
   		cMsg += 'par�metros:' //"par�metros:"
    	cMsg += CRLF
   		cMsg += 'Filial De e At�, ' //"Filial De e At�, "
    	cMsg += CRLF
   		cMsg += 'Rel�gio De e At�,' //"Rel�gio De e At�, "
    	cMsg += CRLF
   		cMsg += 'ou Leitura/Apontamento.' //"ou Leitura/Apontamento."
   		MsgInfo( OemToAnsi( cMsg ) , cCadastro )
		Break
	Endif

	(cTrbTmp)->(dbGotop())

	/*/
		��������������������������������������������������������������Ŀ
		�Verifica se Existem Registros para serem Selecionados     	   �
		����������������������������������������������������������������/*/
	If (cTrbTmp)->(BOF() .and. EOF())
		HELP(" ",1,"RECNO")
		Break
	Endif

	CursorWait()




		/*/
		��������������������������������������������������������������Ŀ
		�Define a Tecla de Atalho para Marcar Todos <F9>       	   	   �
		����������������������������������������������������������������/*/

		bMarkAll	:= { || CursorWait() ,;
							Eval(bAllMark),;
							CursorArrow(),;
							SetKey( VK_F6 , bMarkAll );
						}
		aAdd( aButtons ,	{;
								"CHECKED"							,;
		       					bMarkAll							,;
		    					OemToAnsi( "Marca Todos" + "...<F6>" )	,;			//"Marca Todos"
		    					OemToAnsi( "Mc.Todos" )				 ;			//"Mc.Todos"
		       				};
			)

		/*/
		��������������������������������������������������������������Ŀ
		�Define a Tecla de Atalho para Desmarcar Todos <F10>   	   	   �
		����������������������������������������������������������������/*/

		bUnMarkAll	:= { || CursorWait() ,;
							Eval(bAllUnMark),;
							CursorArrow(),;
							SetKey( VK_F7 , bUnMarkAll );
						}
		aAdd( aButtons ,	{;
								"UNCHECKED"							,;
		       					bUnMarkAll							,;
		    					OemToAnsi( "Inverte" + "...<F7>" )	,;			//"Inverte"
		    					OemToAnsi( "Inverte" )				 ;			//"Inverte"
		       				};
			)

	    /*/
		��������������������������������������������������������������Ŀ
		� Define os Blocos para as Teclas <CTRL-O>					   �
		����������������������������������������������������������������/*/
		bSet15 	:= { ||  GetKeys(), aArqSel:={}, RhRel( cTrbTmp, @aArqSel ), oDlg:End() }

		/*/
		��������������������������������������������������������������Ŀ
		� Define os Blocos para as Teclas <CTRL-X>     	   			   �
		����������������������������������������������������������������/*/
		bSet24	:= { ||  GetKeys() , aArqSel:={}, oDlg:End() }

		/*/
		��������������������������������������������������������������Ŀ
		� Define o Bloco para o Init do Dialog         	   			   �
		����������������������������������������������������������������/*/

		bInitDlg := { ||	Eval( oMsSelect:oBrowse:bGotop )	,;
							oMsSelect:oBrowse:Refresh()			,;
							SetKey( VK_F6 	, bMarkAll		) 	,;
							SetKey( VK_F7	, bUnMarkAll	) 	,;
							EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons );
				 	}


		/*/
		��������������������������������������������������������������Ŀ
		� Monta as Dimensoes para o Dialogo Principal				   �
		����������������������������������������������������������������/*/
		aAdvSize	:= MsAdvSize()

		/*/
		��������������������������������������������������������������Ŀ
		� Monta as Dimensoes dos Objetos                               �
		����������������������������������������������������������������/*/

		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
		aMsSltCoords	:= { aObjSize[1,1] , aObjSize[1,2] , aObjSize[1,3] , aObjSize[1,4] }



		/*/
		��������������������������������������������������������������Ŀ
		� Monta Dialogo 						                       �
		����������������������������������������������������������������/*/

		DEFINE MSDIALOG oDlg TITLE OemToAnsi( "Sele��o de Rel�gios" ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF GetWndDefault() PIXEL	//"Sele��o de Rel�gios"

			oMsSelect := MsSelect():New(;
											cTrbTmp	,;	//Alias	do Arquivo de Filtro
											cCpoCtrl        ,;	//Campo para controle do mark
											NIL				,;	//Condicao para o Mark
											aBrowseFields	,;	//Array com os Campos para o Browse
											.F.				,;	//lInverte
											cMark			,;	//Conteudo a Ser Gravado no campo de controle do Mark
											aMsSltCoords	,;	//Coordenadas do Objeto
											NIL				,;  //?
											NIL				,;	//?
											oDlg			 ;	//Objeto Dialog
									)

			//oMsSelect:oBrowse:bLDblClick 	:= bLDblClick
			oMsSelect:oBrowse:lCanAllMark	:= .T.
			oMsSelect:oBrowse:lHasMark	 	:= .T.
			oMsSelect:bMark	 				:= bLDblClick
			oMsSelect:oBrowse:bAllMark      := bMarkAll
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( bInitDlg )


	RestKeys( aSvKeys , .T. )

	CursorArrow()

End


Return

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �GetParam     � Autor �Mauricio MR		   � Data �14/03/2005�
������������������������������������������������������������������������Ĵ
�Descri��o �Obtem os conteudos dos parametros			   		         �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/
Static Function GetParam(lInicializa, cChar)
//-- Variaveis de Parametros
Local nAponta
Local cFilDe
Local cFilAte
Local cRelDe
Local cRelAte
Local lok := .F.

DEFAULT lInicializa	:=.F.
/*/
��������������������������������������������������������������Ŀ
� Setando as Perguntas que serao utilizadas no Programa        �
����������������������������������������������������������������/*/
If lInicializa .AND. !lSchedDef
	Pergunte( "PNM010" , .F. )
Endif

While !lOk

	lOk := .T.

	cFilDe    := IF( lWorkFlow .and. lUserDefParam .and. !lProcFilial , mv_par01 , IF( !lWorkFlow .OR. lSchedDef , mv_par01 , IF( lProcFilial , cFilAnt , "" ) ) )		//Filial De
	cFilAte   := IF( lWorkFlow .and. lUserDefParam .and. !lProcFilial , mv_par02 , IF( !lWorkFlow .OR. lSchedDef , mv_par02 , IF( lProcFilial , cFilAnt , Replicate(cChar,Len(SRA->RA_FILIAL) ) ) ) )								//Filial Ate
	cRelDe    := IF( lWorkFlow .and. lUserDefParam , mv_par11 , IF( !lWorkFlow .OR. lSchedDef , mv_par11 , ""	) )										  // Relogio De
	cRelAte   := IF( lWorkFlow .and. lUserDefParam , mv_par12 , IF( !lWorkFlow .OR. lSchedDef , mv_par12 , Replicate(cChar,Len(SP0->P0_RELOGIO) ) ) ) // Relogio Ate
	nAponta	  := IF( lWorkFlow .and. lUserDefParam , mv_par18 , IF( !lWorkFlow .OR. lSchedDef , mv_par18 , 3	) )																													//Leitura/Apontamento 1=Marcacoes 2=Refeicoes 3=Acesso 4=Marcacoes e Refeicoes 5=Todos

	__LastParam__:= {cFilDe,cFilAte,cRelDe,cRelAte, nAponta}


	//-- Validar se a tabela SP0 - rel�gios � compartilhada
	//-- e se o mv_par20 est� por rel�gio e o mv_par01 preenchido
	If !lInicializa
		If Empty(xFilial("SP0"))
			If mv_par20 == 2 .and. !Empty(mv_par01)
				Help("",1,"PONM010VALPAR")
				lOk := .F.
				Pergunte( "PNM010" , .T. )
			EndIf
		EndIf
	EndIf

Enddo

Return

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �RhMkAll      � Autor �Mauricio MR		   � Data �07/03/2005�
������������������������������������������������������������������������Ĵ
�Descri��o �Marca/Desmarca todos os elementos do browse   		         �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/

Static Function RhMkAll( cAlias, lInverte, lTodos, cCpoCtrl, cMark, oDlg, aArqSel )
Local nRecno		:= (cAlias)->(Recno())

(cAlias)->( dbGotop() )

While (cAlias)->( !Eof() )

	RhMkMrk( cAlias , lInverte , lTodos, cCpoCtrl, cMark, aArqSel)

	(cAlias)->( dbSkip() )
EndDo

(cAlias)->( MsGoto( nRecno ) )

oDlg:Refresh()
Return

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �RhMkMrk      � Autor �Mauricio MR		   � Data �07/03/2005�
������������������������������������������������������������������������Ĵ
�Descri��o �Marca/Desmarca um elemento do browse   				         �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/

static Function RhMkMrk( cAlias , lInverte , lTodos, cCpoCtrl, cMark, aRel)
Local cTemp
Local cSpaceMarca	:= Space(Len(cMark))

DEFAULT cAlias		:= Alias()

If lTodos
    If lInverte
	   	If IsMark( cCpoCtrl, cMarK)
		  cTemp:= cSpaceMarca
		Else
	      cTemp:= cMark
		Endif
	Else
		cTemp:=cMark
	Endif
Else
	If IsMark( cCpoCtrl, cMarK, lInverte)
		cTemp:= If(lInverte, cSpaceMarca, cMark)
	Else
	   cTemp:= If(lInverte, cMark, cSpaceMarca)
	Endif
Endif


//-- Alteracao Selecao
(cAlias)->(RecLock(cAlias,.F.))
	&(cAlias+'->'+cCpoCtrl) := cTemp
(cAlias)->(MsUnlock())

Return .T.


/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �RhRel        � Autor �Mauricio MR		   � Data �07/03/2005�
������������������������������������������������������������������������Ĵ
�Descri��o �Array FINAL com os Relogios Selecionados			   		 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/

Static Function RhRel( cAlias, aRel )
Local nPosRel

(cAlias)->( dbGotop() )

//-- Corre Todos os Registros de Filial+Relogios+Arquivos
While (cAlias)->( !Eof() )

 	//Se Selecionou novo Arquivo
     If !Empty( (cAlias)->MARK )
		 If !Empty(aRel) .AND. !Empty((nPosRel:=Ascan(aRel,{|x| x[1] = (cAlias)->(Filial+Relogio)})))
	 		//-- Adiciona o Novo Arquivo Selecionado a Filial+Relogio ja existente
		 	AADD(aRel[nPosRel,2], (cAlias)->Arquivo)
		 Else
		     //-- Adiciona nova Chave Filial+Relogio e o Novo Arquivo
		   	  AADD(aRel, { (cAlias)->(Filial+Relogio), {(cAlias)->Arquivo} } )
		 Endif
	 Endif
	(cAlias)->( dbSkip() )
EndDo

Return

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �Relogios     � Autor �Mauricio MR		   � Data �07/03/2005�
������������������������������������������������������������������������Ĵ
�Descri��o �Obtem os Relogios para Selecao via  browse  		         �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/

Static Function Relogios(cAliasTemp, aBrowseFields,   cMark, aRel, cFilSP0, cFilAte, cRelDe, cRelAte, nAponta)
Local aHeader
Local aCposOrigem:= { "P0_FILIAL", "P0_RELOGIO", "P0_DESC","P0_TIPOARQ", "P0_CONTROL", "P0_ARQUIVO"}
Local aCols
Local aSelArq
Local lRet		:=.T.

//-- Carrega todos os Registros de Relogios conforme Filial e Relogio
If !Empty((aCols	:= 	GetRelogios(@aHeader, cFilSP0, cFilAte, cRelDe, cRelAte, nAponta)))

	//-- Carrega todos os Arquivos conforme os diretorios especificados em cada Relogio
	If !Empty( aSelArq	:=	AppendArquivos(aHeader, aCols) )

		//-- Cria Arquivo temporario conforme a chave: Filial+Relogio+Arquivo de Marcacoes
		CriaArqRel(cMark, aCposOrigem, @aBrowseFields, aHeader, aSelArq, aRel, cAliasTemp,'FILIAL+RELOGIO' )
	Else
		//-- Nao existem relogios conforme parametros informados
	    lRet:=.F.
	Endif
Else
    //-- Nao existem relogios conforme parametros informados
    lRet:=.F.
Endif

Return (lRet)

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �CriaArqRel   � Autor �Mauricio MR		   � Data �07/03/2005�
������������������������������������������������������������������������Ĵ
�Descri��o �Cria Arquivo de Relogios para Selecao via  browse  	         �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/

Static Function CriaArqRel(cMarca, aCposOrigem,aBrowseFields,  aHeader, aSelArq, aRel, cAliasTemp, cKeyInd)
Local cSpaceMarca	:= Space(Len(cMarca))
Local aFields		:= {}
Local cCampo
Local cRotina		:= 'PONM010'
Local lRet			:= .T.
Local nLoop
Local nOriginal
Local nPosCpo
Local nTotLoop
Local aLstIndices := {}
If !Empty(Select(cAliasTemp))
	dbSelectArea(cAliasTemp)
	dbCloseArea()

	If oTmpTabFO1 <> Nil
	    oTmpTabFO1:Delete()
	    Freeobj(oTmpTabFO1)
    EndIf
Endif



//-- Adiciona Campo de Selecao para o MarkBorwse
AADD(aFields,{	'MARK','C',2,	0 })
AADD(aBrowseFields,	{'MARK', cRotina, 'OK'}) //OK

//-- Adiciona Demais Campos do Arquivo Temporario
nTotLoop	:= Len(aCposOrigem)
For nLoop:=1 To nTotLoop
	nPosCpo	:= 	GdFieldPos(aCposOrigem[nLoop]	,aHeader)
	cCampo	:=	STRTRAN(aHeader[nPosCpo,__AHEADER_FIELD__], 'P0_',"")

	If cCampo == "DESC"//erro de frame caso exista um campo de nome DESC no aFields.Por esta raz�o, modifiquei o nome
		cCampo := "XDESC"
	EndIf

	AADD(aFields,{	cCampo          					,;
	               	aHeader[nPosCpo,__AHEADER_TYPE__]	,;
	               	aHeader[nPosCpo,__AHEADER_WIDTH__]	,;
	               	aHeader[nPosCpo,__AHEADER_DEC__] 	;
	             };
	      )
   AADD(aBrowseFields,{	cCampo, cRotina, aHeader[nPosCpo,__AHEADER_TITLE__] } )
Next nLoop

//Abre o Arquivo Temporario

AAdd (aLstIndices, {"FILIAL","RELOGIO"}  )
oTmpTabFO1:= RhCriaTrab(cAliasTemp, aFields, aLstIndices)

IF ( lRet := ( Select( cAliasTemp ) > 0.00 ) )

	nTotLoop	:= Len(aSelarq)
	nOriginal	:= Len( aSelArq[1] )

	ProcRegua( (cAliasTemp)->(RecCount()) / ((cAliasTemp)->(RecCount())) )

	For nLoop:=1 to nTotLoop

   	    (cAliasTemp)->(Reclock(cAliasTemp,.T.) )

   		(cAliasTemp)->MARK 		:= If( aSelArq[nLoop,nOriginal], cMarca, cSpaceMarca)
		(cAliasTemp)->FILIAL 	:= aSelArq[nLoop,1]
	    (cAliasTemp)->RELOGIO 	:= aSelArq[nLoop,2]
	    (cAliasTemp)->TIPOARQ 	:= aSelArq[nLoop,3]
	    (cAliasTemp)->CONTROL 	:= aSelArq[nLoop,4]
	    (cAliasTemp)->XDESC 	:= aSelArq[nLoop,5]
   		(cAliasTemp)->ARQUIVO	:= aSelArq[nLoop,6]

   	    (cAliasTemp)->(MsUnlock())


 		//Se Selecionou novo Arquivo
    	If !Empty((cAliasTemp)->MARK )
	       //-- Adiciona nova Chave Filial+Relogio e o Novo Arquivo
    	   AADD(aRel, { (cAliasTemp)->(FILIAL+RELOGIO), {(cAliasTemp)->ARQUIVO} } )
    	Endif

       	IncProc( 'Filial ' + (cAliasTemp)->FILIAL+ " / " + (cAliasTemp)->RELOGIO )

	Next nLoop
	(cAliasTemp)->( dbGotop() )
EndIF

Return( lRet )

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �AppendArquivos   � Autor �Mauricio MR	   � Data �07/03/2005�
������������������������������������������������������������������������Ĵ
�Descri��o �Obtem Arquivos para cada Relogio Existente				     �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/

Static Function AppendArquivos(aHeader, aCols)
Local aFiles
Local aSelArq    	:= {}
Local cFilRel
Local cFile
Local cTipo
Local cRelogio
Local cControle
Local cDesc
Local nLoop
Local nTot 			:= Len(aCols)
Local nPosFilial
Local nPosArq
Local nPosDesc
Local nPosTipo
Local nPosRelogio
Local nPosControle

nPosFilial	:=	GdFieldPos("P0_FILIAL"	,aHeader)
nPosArq		:=	GdFieldPos("P0_ARQUIVO"	,aHeader)
nPosTipo	:=	GdFieldPos("P0_TIPOARQ"	,aHeader)
nPosDesc 	:=	GdFieldPos("P0_DESC"	,aHeader)
nPosRelogio :=	GdFieldPos("P0_RELOGIO"	,aHeader)
nPosControle:=	GdFieldPos("P0_CONTROL",aHeader)

////-- Corre Todos os Relogios
For nLoop:=1 To nTot
  cFilRel	:= aCols[nLoop, nPosFilial]
  cDesc		:= aCols[nLoop, nPosDesc]
  cRelogio	:= aCols[nLoop, nPosRelogio]
  cControle	:= aCols[nLoop, nPosControle]
  cFile		:= GetDir(aCols[nLoop, nPosArq])
  cTipo		:= aCols[nLoop, nPosTipo]
  aFiles	:= Directory(cFile+'\'+If(cTipo == 'T', '*.TXT', '*.DBF'),"D")

  Aeval(aFiles,{|x|AADD(aSelArq, {cFilRel,cRelogio,cTipo,cControle, cDesc,cFile+x[1], (UPPER(ALLTRIM(cFile+x[1])) == UPPER(ALLTRIM(aCols[nLoop, nPosArq]))) })})

Next nLoop

Return (Aclone(aSelArq))


/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �GetDir			 � Autor �Mauricio MR	   � Data �07/03/2005�
������������������������������������������������������������������������Ĵ
�Descri��o �Obtem o Diretorio a partir do nome de Arquivo do Cad. Relogio�
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/

Static Function  GetDir(cCols)
Local cDrive
Local cDir

SplitPath(cCols, @cDrive, @cDir)
cDir := Alltrim(cDrive) + Alltrim(cDir)
cDir := StrTran(cDir, "/", "\" )
Return cDir


/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �GetRelogios		 � Autor �Mauricio MR	   � Data �07/03/2005�
������������������������������������������������������������������������Ĵ
�Descri��o �Obtem os registros de relogios a partir do Cad. Relogio      �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/

Static function  GetRelogios(aHeader, cFilSP0, cFilAte, cRelDe, cRelAte, nAponta)

Local bSkip
Local cKey		:= cFilSP0
Local uQueryCond
Local aRecnos
Local aNotFields := {'P0_FILIAL', 'P0_RELOGIO', 'P0_ARQUIVO','P0_DESC','P0_TIPOARQ','P0_CONTROL'}
/*/
��������������������������������������������������������������Ŀ
� Le Somente os Relogios conforme Parametros Informados        �
����������������������������������������������������������������/*/

bSkip:= {|| SP0->(	( P0_FILIAL  < cFilSP0 ) .or. ( P0_FILIAL  > cFilAte ) .or. ;
			    		( P0_RELOGIO < cRelDe  ) .or. ( P0_RELOGIO > cRelAte ) ) .OR.;
			    	 !VerControle(nAponta);
		 }



uQueryCond:=  Array( 09 )
uQueryCond[01]	:= "P0_FILIAL >='"+cFilSP0+"'"
uQueryCond[02]	:= " AND "
uQueryCond[03]	:= "P0_FILIAL <='"+cFilAte+"'"
uQueryCond[04]	:= " AND "
uQueryCond[05]	:= "P0_RELOGIO >='"+cRelDe+"'"
uQueryCond[06]	:= " AND "
uQueryCond[07]	:= "P0_RELOGIO <='"+cRelAte+"'"
uQueryCond[08]	:= " AND "
uQueryCond[09]	:= "D_E_L_E_T_=' ' "

aCols:=	GdMontaCols(	@aHeader		,;	//01 -> Array com os Campos do Cabecalho da GetDados
						    			,;	//02 -> Numero de Campos em Uso
						           		,;	//03 -> [@]Array com os Campos Virtuais
						       			,;	//04 -> [@]Array com os Campos Visuais
						'SP0'			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
						aNotFields		,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
						@aRecnos		,;	//07 -> [@]Array unidimensional contendo os Recnos
						'SP0'		   	,;	//08 -> Alias do Arquivo Pai
						cKey			,;	//09 -> Chave para o Posicionamento no Alias Filho
						NIL				,;	//10 -> Bloco para condicao de Loop While
						bSkip			,;	//11 -> Bloco para Skip no Loop While
						.T.          	,;	//12 -> Se Havera o Elemento de Delecao no aCols
						.T.     		,;	//13 -> Se cria variaveis Publicas
						.T.             ,;	//14 -> Se Sera considerado o Inicializador Padrao
						.T.    	        ,;	//15 -> Lado para o inicializador padrao
						          		,;	//16 -> Opcional, Carregar Todos os Campos
						            	,;	//17 -> Opcional, Nao Carregar os Campos Virtuais
						uQueryCond		,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
						.T.         	,;	//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
						.T.         	,;	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
						.F.         	,;	//21 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
						.T.           	,;	//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
						.F.          	,;	//23 -> Verifica se Deve Checar se o campo eh usado
						.T.     		,;	//24 -> Verifica se Deve Checar o nivel do usuario
						.F.         	,;	//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
						            	,;	//26 -> [@]Array que contera as chaves conforme recnos
						.F.				,;	//27 -> [@]Se devera efetuar o Lock dos Registros
						.F.				,;	//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
						         		,;	//29 -> Numero maximo de Locks a ser efetuado
						.F.         	,;	//30 -> Utiliza Numeracao na GhostCol
						.T.      		 ;	//31 -> Carrega os Campos de Usuario
					)
Return (aClone(aCols))

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �VerControle		 � Autor �Mauricio MR	   � Data �13/05/2005�
������������������������������������������������������������������������Ĵ
�Descri��o �Consiste o controle do relogio e a opcao de processo esco-   �
�          �lhido.                                                       �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/

Static Function VerControle(nAponta)
Local lRet	:= .T.

/*/
��������������������������������������������������������������Ŀ
� Verifica o Tipo de Leitura a Ser Feita                       �
����������������������������������������������������������������/*/
IF !( nAponta == 5 )
   	IF SP0->(;
  				( ( nAponta == 1 ) .and. ( P0_CONTROL $ "R.A" ) );
   				.or.;
   				( ( nAponta == 2 ) .and. ( P0_CONTROL $ "P.A" ) );
   				.or.;
	   			( ( nAponta == 3 ) .and. ( P0_CONTROL $ "R.P" ) );
	  			.or.;
	   			( ( nAponta == 4 ) .and. ( P0_CONTROL $ "A"   ) );
	   		)
	   		lRet:= .F.
	  EndIF
Endif

Return lRet

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �Pnm010Proc 		 � Autor �Equipe RH        � Data �          �
������������������������������������������������������������������������Ĵ
�Descri��o �                                                             �
������������������������������������������������������������������������Ĵ
�Sintaxe   �                             								 �
������������������������������������������������������������������������Ĵ
�Parametros�                         									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/
static Function Pnm010Proc()
Local lRet:= .T.

If mv_par20 == 1 .and. mv_par18= 3
	Aviso( "Atencao", ' Para o Controle de Acesso, a Leitura deve ser feita a apartir do Cad.Rel�gios.', {"Ok"} ) //"Atencao"###' Para o Controle de Acesso, a Leitura deve ser feita a apartir do Cad.Rel�gios.'
ENDIF

If Empty(xFilial("SP0"))
	If mv_par20 == 2 .and. !Empty(mv_par01)
		Help("",1,"PONM010VALPAR")
		lRet := .F.
	EndIf
EndIf

Return(lRet)

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �fHistRFE 		 � Autor �Leandro Drumond  � Data �15/10/2009�
������������������������������������������������������������������������Ĵ
�Descri��o �Exibe o historico de leitura.                                �
������������������������������������������������������������������������Ĵ
�Sintaxe   �                             								 �
������������������������������������������������������������������������Ĵ
�Parametros�                         									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
� Uso      �PONM010                                                      �
��������������������������������������������������������������������������/*/
Static Function fHistRFE()
Local aArea				:= GetArea()
Local oDlg				:= NIL
Local nRecno			:= 0

Begin Sequence

	DEFINE DIALOG oDlg TITLE "Hist�rico de Leitura" FROM 180,180 TO 550,700 PIXEL  //"Hist�rico de Leitura"

	    DbSelectArea('RFB')
	    nRecno := ('RFB')->( LastRec() )
	    If ( ( nRecno - 100 ) > 0 )
	    	DbGoTo(nRecno-100)
	    EndIf
	    oBrowse := BrGetDDB():New( 1,1,260,184,,,,oDlg,,,,,,,,,,,,.F.,'RFB',.T.,,.F.,,, )
		oBrowse:bCustomEditCol	:= {||.T.}
		oBrowse:bDelOk			:= {||.T.}
	    oBrowse:AddColumn(TCColumn():New(PosAlias( "SX3" , "RFB_FILIAL" , "" , "X3Titulo()" , 2 , .F. ),{||RFB->RFB_FILIAL },,,,'LEFT',,.F.,.F.,,,,.F.,))
	    oBrowse:AddColumn(TCColumn():New(PosAlias( "SX3" , "RFB_RELOGI" , "" , "X3Titulo()" , 2 , .F. ),{||RFB->RFB_RELOGI },,,,'LEFT',,.F.,.F.,,,,.F.,))
	    oBrowse:AddColumn(TCColumn():New(PosAlias( "SX3" , "RFB_NUMREP" , "" , "X3Titulo()" , 2 , .F. ),{||RFB->RFB_NUMREP },,,,'LEFT',,.F.,.F.,,,,.F.,))
	    oBrowse:AddColumn(TCColumn():New(PosAlias( "SX3" , "RFB_ARQ"    , "" , "X3Titulo()" , 2 , .F. ),{||RFB->RFB_ARQ    },,,,'LEFT',,.F.,.F.,,,,.F.,))
	    oBrowse:AddColumn(TCColumn():New(PosAlias( "SX3" , "RFB_DTHRLI" , "" , "X3Titulo()" , 2 , .F. ),{||RFB->RFB_DTHRLI },,,,'LEFT',,.F.,.F.,,,,.F.,))
	    oBrowse:AddColumn(TCColumn():New(PosAlias( "SX3" , "RFB_DTHRLF" , "" , "X3Titulo()" , 2 , .F. ),{||RFB->RFB_DTHRLF },,,,'LEFT',,.F.,.F.,,,,.F.,))
	    oBrowse:GoUp()


	  ACTIVATE DIALOG oDlg CENTERED

End Sequence

RestArea(aArea)

Return (Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fVerMultVinc  � Autor � Allyson M.        � Data � 06/08/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verificar se ha multiplos vinculos conforme PIS.			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �            												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � PONM010  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function fVerMultVinc(cPIS,cFilRFE)

Local aArea	   		:= GetArea()
Local aFuncs   		:= {}
Local cAliasQry		:= ""
Local cAlias		:= "SRA"

Local nCont	   		:= 0
Local nSraOrder		:= 0

Local lQueryOpened	:= .F.

DEFAULT cPIS		:= ""

cPIS := Padr(cPIS,12)

If !Empty(cPIS)

	IF !lExInAs400
		lQueryOpened  := .T.

		cAliasQry	:= GetNextAlias()

		BeginSql alias cAliasQry
			SELECT	SRA.RA_FILIAL, SRA.RA_PIS, SRA.RA_MAT, SRA.RA_CC, SRA.RA_TNOTRAB,
					SRA.RA_SITFOLH, SRA.RA_DEMISSA, R_E_C_N_O_ RECNO
			FROM %table:SRA% SRA
			WHERE SRA.RA_PIS = %exp:cPIS% AND SRA.%notDel%
			ORDER BY SRA.RA_PIS, SRA.RA_FILIAL
		EndSql

	EndIf
EndIf

IF !lQueryOpened
	(cAlias)->( dbGoTop() )
	(cAlias)->( dbSeek( cPIS ) )

	While (cAlias)->( !Eof() .And. AllTrim((cAlias)->RA_PIS) == cPIS)
		nCont++//contador do numero de funcionarios com mesmo pis
		//Se a data da marcacao nao for maior do que a data de demissao
		If !(cAlias)->( RA_SITFOLH == "D" .and. !Empty(RA_DEMISSA) .and. dData > RA_DEMISSA ) .and. ( Empty(cFilRFE) .or. AllTrim(cFilRFE) $ RA_FILIAL ) 
		   	aAdd( aFuncs, { (cAlias)->RA_FILIAL, (cAlias)->RA_MAT, (cAlias)->RA_CC, (cAlias)->RA_TNOTRAB, (cAlias)->( RECNO() ) } )
		EndIf

		(cAlias)->( dbSkip() )
		Loop
	EndDo

	(cAlias)->( dbSetOrder( nSraOrder ) )
Else
	While (cAliasQry)->( !Eof() )
		nCont++//contador do numero de funcionarios com mesmo pis
		//Se a data da marcacao nao for maior do que a data de demissao
        If !(cAliasQry)->( RA_SITFOLH == "D" .and. !Empty(RA_DEMISSA) .and. Dtos(dData) > RA_DEMISSA ) .and. ( Empty(cFilRFE) .or. AllTrim(cFilRFE) $ RA_FILIAL )
		   	aAdd( aFuncs, { (cAliasQry)->RA_FILIAL, (cAliasQry)->RA_MAT, (cAliasQry)->RA_CC, (cAliasQry)->RA_TNOTRAB, (cAliasQry)->RECNO } )
		EndIf

		(cAliasQry)->( dbSkip() )
	EndDo

	( cAliasQry )->( dbCloseArea() )
Endif

If nCont > 1
	lMultVinc := .T.
Else
	lMultVinc := .F.
EndIf

RestArea( aArea )

Return( aFuncs )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fDelRFE       � Autor � Leandro Dr.       � Data � 13/04/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Apagar registros nao classificados da RFE.      			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �            												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � PONM010  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/
Static Function fDelRFE(cFilRFE, cRelRFE)

Local aArea 		:= GetArea()
Local cQuery		:= ""

cQuery := "DELETE FROM " + InitSqlName("RFE") + " WHERE RFE_FILIAL = '" + cFilRFE + "' AND RFE_RELSP0 ='" + cRelRFE + "' AND RFE_NATU = '3' AND RFE_FLAG = '0' "

TcSqlExec( cQuery )

TcRefresh( InitSqlName("RFE") )

RestArea(aArea)

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Pnm010MntThread� Autor � Leandro Dr.      � Data � 01/05/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta o array para utilizar multi-thread.      			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �            												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � PONM010  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/
Static Function Pnm010MntThread(aRegSRA)
Local aThreads	 := {}
Local nQtdRec	 := Len(aRegSRA)
Local nRegProc   := 0
Local nInicio	 := 1
Local nX		 := 0
Local nY		 := 0

If nMultThread > 20
	nMultThread := 20  //Limita threads a 20
EndIf

If Len(aRegSRA) > nMultThread
	aThreads := Array(nMultThread)

	For nX := 1 to nMultThread
		// Quantidade de registros a processar
		nRegProc += IIf( nX == nMultThread , nQtdRec - nRegProc, Int(nQtdRec/nMultThread) )
		aThreads[nX] := {}

        For nY := nInicio to nRegProc
			aAdd(aThreads[nX],aRegSRA[nY])
        	nInicio := nRegProc
        Next nY
        nInicio++
	Next nX
Else
	aAdd(aThreads,aRegSRA)
EndIf

Return aThreads

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Pnm010MultProc � Autor � Leandro Dr.      � Data � 01/05/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Processa multi threads.                        			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 �            												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � PONM010  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/
Static Function Pnm010MultProc(aRegSRA, cFilFECAux, lPonWork, lSchedDef, lUserDefParam)
Local aJobAux		:= {}
Local aMarcNo		:= {}
Local cJobFile		:= ''
Local cJobAux		:= ''
Local cStartPath 	:= GetSrvProfString("Startpath","")
Local cLogError		:= ''
Local nLoop 		:= 0
Local nLoops		:= 0
Local nLoopAux 		:= 0
Local nMarcs		:= 0
Local nRetry_0 		:= 0
Local nRetry_1 		:= 0
Local nPos			:= 0
Local nX			:= 0
Local nTotRegs		:= 0
Local nTotThread	:= 0
Local nRegsOk		:= 0
Local nRegsAux		:= 1
Local nQtdSRA		:= Len(aRegSRA)
Local cTabTmpName   := ''
Local lFechOk		:= .T.
aRegSRA := Pnm010MntThread(aRegSRA)

nLoops := Len(aRegSRA)

nTotRegs 	:= nQtdSRA / nLoops
nTotThread  := nTotRegs

cUserBkp	:=__cUserId
__cUserId	:= "000000"

If nLoops > 0
	PutGlbValue("nFunProc","0")
	GlbUnLock()

	/*/
	��������������������������������������������������������������Ŀ
	� Movimenta a R�gua de Processamento                           �
	����������������������������������������������������������������/*/
	If !( lWorkFlow )

		cMsgBarG1 := 'STR0147'

		/*/
		��������������������������������������������������������������Ŀ
		� Obtem o % de Incremento da 2a. BarGauge					   �
		����������������������������������������������������������������/*/
		nIncPercG1 := SuperGetMv( "MV_PONINC1" , NIL , 5 , cLastFil )
		/*/
		��������������������������������������������������������������Ŀ
		� Obtem o % de Incremento da 2a. BarGauge					   �
		����������������������������������������������������������������/*/
		nIncPercG2 := SuperGetMv( "MV_PONINCP" , NIL , 5 , cLastFil )

		/*/
		��������������������������������������������������������������Ŀ
		� Define o Contador para o Processo 1                          �
		����������������������������������������������������������������/*/
		--nCount1Time
		/*/
		��������������������������������������������������������������Ŀ
		� Define o Numero de Elementos da BarGauge                     �
		����������������������������������������������������������������/*/
		BarGauge1Set( nLoops )
		/*/
		��������������������������������������������������������������Ŀ
		� Inicializa Mensagem na 1a BarGauge                           �
		����������������������������������������������������������������/*/
		IncProcG1( cMsgBarG1 , .F. )

	EndIf

	For nLoop:=1 to nLoops
	    cTabTmpName := "J" + Alltrim(STR(nLoop)) + dtos(dDataBase) + StrTran(Time(),':','',1,4)
		// Informacoes do semaforo
		cJobFile:= cStartPath +  cTabTmpName +".job"

		// Adiciona o nome do arquivo de Job no array aJobAux
		aAdd(aJobAux,{StrZero(nLoop,2),cJobFile})

		// Inicializa variavel global de controle de thread
		cJobAux:="PNM010"+cEmpAnt+cFilAnt+StrZero(nLoop,2)
		PutGlbValue(cJobAux,"0")
		GlbUnLock()

		PutGlbValue("nFun"+StrZero(nLoop,2),"0")
		GlbUnLock()

		PutGlbValue('aLog'+StrZero(nLoop,2),"")
		GlbUnLock()

		PutGlbValue('aMarc'+StrZero(nLoop,2),"")
		GlbUnLock()
		//�������������������Ŀ
		//� Dispara thread    �
		//���������������������
		StartJob("Pnm010Thread",GetEnvServer(),.F.,{cEmpAnt,cFilAnt,aRegSRA[nLoop],cJobFile,StrZero(nLoop,2),lWorkFlow,dPerIni,dPerFim,dPerDe,dPerAte,nAponta,nTipo,nReaponta,dDataBase,__cUserId,cUserBkp, lLimitaDataFim, lGeolocal, cFilFECAux, lPonWork, lSchedDef, lUserDefParam})

	Next nLoop

	//���������������������������������������������������������������������������Ŀ
	//� Controle de Seguranca para MULTI-THREAD                                   �
	//�����������������������������������������������������������������������������
	For nLoop:=1 to nLoops

		nPos := aScan(aJobAux,{|x| x[1] == StrZero(nLoop,2)})

		// Informacoes do semaforo
		cJobFile:= aJobAux[nPos,2]

		// Inicializa variavel global de controle de thread
		cJobAux:="PNM010"+cEmpAnt+cFilAnt+StrZero(nLoop,2)

		While .T.

			If !( lWorkFlow )

				nRegsOk := 0

				For nLoopAux := 1 to nLoops
					nRegsOk += Val(GetGlbValue("nFun"+StrZero(nLoopAux,2)))
				Next nLoopAux

				If nRegsOk >= nTotRegs
					nTotRegs += nTotThread

					/*/
					��������������������������������������������������������������Ŀ
					�Incrementa a Barra de Gauge referente ao Turno				   �
					����������������������������������������������������������������/*/
					IncPrcG1Time( cMsgBarG1 , nRecsBarG , cTimeIni , .F. , nCount1Time , nIncPercG1 , lIncProcG1 )
				EndIf

				For nRegsAux := nRegsAux to nRegsOk
					IF ( ( nTipo == 2 ) .or. ( nTipo == 3 ) )
						IncPrcG2Time( 'Apontadas...: ' , nSraLstRec , cTimeIni , .F. , nCountTime , nIncPercG2 )	//'Apontadas...: '
					Else
						IncPrcG2Time( 'Classificadas...: ' , nSraLstRec , cTimeIni , .F. , nCountTime , nIncPercG2 )	//'Classificadas...: '
					EndIf
				Next nRegsAux
			EndIf

			Do Case
				// TRATAMENTO PARA ERRO DE SUBIDA DE THREAD
				Case GetGlbValue(cJobAux) == '0'
					If nRetry_0 > 50
						Conout(Replicate("-",65))				  						//"-----------------------------------------------------"
						Conout("PONM010: " + "PONM010: N�o foi possivel subir a thread" + " " + StrZero(nLoop,2) )		//"PONM010: N�o foi possivel subir a thread"
						Conout(Replicate("-",65))  										//"-----------------------------------------------------"
						//���������������������������������������������Ŀ
						//� Atualiza o log de processamento			    �
						//�����������������������������������������������
						Final("PONM010: N�o foi possivel subir a thread") 	 												//"N�o foi possivel subir a thread"
					Else
						nRetry_0 ++
					EndIf
				// TRATAMENTO PARA ERRO DE CONEXAO
				Case GetGlbValue(cJobAux) == '1'
					If FCreate(cJobFile) # -1
						If nRetry_1 > 5
							Conout(Replicate("-",65)) 						//"------------------------------------------------"
							Conout("PONM010: " + "PONM010: Erro de conexao na thread" ) 					//"PONM010: Erro de conexao na thread"
							Conout("Thread numero : " + StrZero(nLoop,2) )				//"Thread numero : "
							Conout("Numero de tentativas excedidas")									//"Numero de tentativas excedidas"
							Conout(Replicate("-",65))  						//"------------------------------------------------"
							//���������������������������������������������Ŀ
							//� Atualiza o log de processamento			    �
							//�����������������������������������������������
							Final("PONM010: " + "PONM010: Erro de conexao na thread")   					//"PONM010: Erro de conexao na thread"
						Else
			    			// Inicializa variavel global de controle de Job
							PutGlbValue(cJobAux, "0" )
							GlbUnLock()
							// Reiniciar thread
							Conout(Replicate("-",65))				 				//"------------------------------------------------"
							Conout("PONM010: " + "PONM010: Erro de conexao na thread" ) 							//"PONM010: Erro de conexao na thread"
							Conout("Tentativa numero: "	+ StrZero(nRetry_1,2))					//"Tentativa numero: "
							Conout("Reiniciando a thread : " + StrZero(nLoop,2))						//"Reiniciando a thread : "
							Conout(Replicate("-",65))                 				//"------------------------------------------------"
							//���������������������������������������������Ŀ
							//� Dispara thread 						        �
							//�����������������������������������������������
							StartJob("Pnm010Thread",GetEnvServer(),.F.,{cEmpAnt,cFilAnt,aRegSRA[nLoop],cJobFile,StrZero(nLoop,2),lWorkFlow,dPerIni,dPerFim,dPerDe,dPerAte,nAponta,nTipo,nReaponta,dDataBase,__cUserId,cUserBkp, lLimitaDataFim, lGeolocal, cFilFECAux, lPonWork},@lFechOk)
						EndIf
						nRetry_1 ++
					EndIf
				// TRATAMENTO PARA ERRO DE APLICACAO
				Case GetGlbValue(cJobAux) == '2'
					If FCreate(cJobFile) # -1
						Conout(Replicate("-",65))									//"-------------------------------------------------"
						Conout("PONM010: " + "PONM010: Erro de aplicacao na thread"  )								//"PONM010: Erro de aplicacao na thread"
						Conout("Thread numero : " + StrZero(nLoop,2))							//"Thread numero : "
						Conout(Replicate("-",65))  									//"--------------------------------------------------"
						//���������������������������������������������Ŀ
						//� Atualiza o log de processamento			    �
						//�����������������������������������������������
						Final("PONM010: " + "PONM010: Erro de aplicacao na thread") 								//"PONM010: Erro de aplicacao na thread"
					EndIf
				// THREAD PROCESSADA CORRETAMENTE
				Case GetGlbValue(cJobAux) == '3'
					Exit
			EndCase
			Sleep(2500)
		End
	Next nLoop

	For nLoop := 1 to nLoops
		cLogError  := GetGlbValue("aLog"+StrZero(nLoop,2))
		GetGlbVars( "aMarc" + StrZero(nLoop, 2), @aMarcNo )
		nX := 1
		If !Empty(cLogError)
			While .T.
				If At("*",cLogError) == 0
					aAdd(aLogFile,cLogError)
					Exit
				Else
					aAdd(aLogFile,SubStr(cLogError,nX,At("*",cLogError)-1))
					cLogError := SubStr(cLogError,At("*",cLogError)+1,Len(cLogError))
				EndIf
			EndDo
		EndIf

		If !Empty(aMarcNo)
			For nMarcs := 1 To Len(aMarcNo)
				aAdd( aMarcNoGer, aClone( aMarcNo[nMarcs] ) )
			Next nMarcs
		EndIf
	Next nLoop
	
	nFuncProc := Val(GetGlbValue("nFunProc"))
	
	For nLoop := 1 to Len(aJobAux)
		cJobFile:= aJobAux[nLoop,2]
		If File(cJobFile)
			fErase(cJobFile) // Apaga arquivo ja existente
		EndIf
	Next nLoop
EndIf

__cUserId:=cUserBkp

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pnm010Thread  � Autor � Leandro Drumond   � Data �27.04.2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Job para execucao das multi-threads.                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PONM010()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
static Function Pnm010Thread(aParam,lFechOk)
Local nLoop	  	:= 0
Local nLoops   	:= 0
Local nX		:= 0
Local cEmp		:= aParam[1]
Local cFil		:= aParam[2]
Local aRegSRA	:= aParam[3]
Local cJobFile	:= aParam[4]
Local cThread	:= aParam[5]
Local cLogError := ''
Local bErro		:= Nil

Private aTabCalend		:= {}
Private aTabPadrao		:= {}
Private aLogFile		:= {}
Private aCodigos   		:= {}
Private aMarcNoGer		:= {}
Private aTabRef			:= {}
Private bCondDelAut		:= { || .T. }
Private cFilTnoSeqOld	:= "__cFilTnoSeqOld__"
Private cLastFil		:= "__cLastFil__"
Private cFilOld    		:= "__cFilOld__"
Private cFilRefAnt		:= ""
Private dPerIni			:= aParam[7]
Private dPerFim			:= aParam[8]
Private dPerDe			:= aParam[9]
Private dPerAte			:= aParam[10]
Private nIncPercG1		:= 0
Private nIncPercG2		:= 0
Private nAponta			:= aParam[11]
Private nTipo			:= aParam[12]
Private nReaponta		:= aParam[13]
Private nFuncProc		:= 0
Private lSR6Comp		:= .F.
Private lIncProcG1		:= .T.
Private lMultThread		:= .T.
Private lChkPonMesAnt	:= .F.
Private lAbortPrint		:= .F.
Private lWorkFlow 		:= aParam[6]
Private lLimitaDataFim	:= aParam[17]
Private cFilFECAux	    := aParam[19]
Private lPonWork	    := aParam[20]
Private lSchedDef	    := aParam[21]
Private lUserDefParam	:= aParam[22]

DEFAULT lFechOk	:= .T.

bErro := ErrorBlock( { |oErr| ErroForm( oErr , @lFechOk, @aLogFile, cThread ) } )

// Apaga arquivo ja existente
If File(cJobFile)
	fErase(cJobFile)
EndIf

// Criacao do arquivo de controle de jobs
nHd1 := MSFCreate(cJobFile)

// STATUS 1 - Iniciando execucao do Job
PutGlbValue("PNM010"+cEmp+cFil+cThread, "1" )
GlbUnLock()

// Seta job para nao consumir licensas
RpcSetType(3)

// Seta job para empresa filial desejada
RpcSetEnv( cEmp, cFil,,,'PON')

IF Empty(cFilAnt)
	cFilAnt:= cFil
Endif

//Iguala database com thread principal
dDataBase := aParam[14]
__cUserId := aParam[15]

Conout(DtoC(Date())+ " " + Time() + " PONM010: " + 'STR0155' + cThread + 'STR0156' )

lSR6Comp := Empty( xFilial( "SR6" ) )

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue("PNM010"+cEmp+cFil+cThread, "2" )
GlbUnLock()

DbSelectArea('SRA')

nLoops  := Len(aRegSRA)
Begin Transaction

	Begin Sequence

		For nLoop := 1 to nLoops
		
			If SRA->( dbSeek( aRegSRA[nLoop][1]+aRegSRA[nLoop][2] ) )

				If !(SRA->RA_FILIAL $ cFilFECAux)
					__cUserId := aParam[16]
					lFechOk := Ponm010Aponta( .F. )
					__cUserId := aParam[15]
				EndIf
		
			EndIf
		
			PutGlbValue("nFun"+cThread,AllTrim(STR(nLoop)))
			GlbUnLock()
		
		Next nLoop

	End Sequence

	If !lFechOk
		DisarmTransaction()
		Break
	EndIf

End Transaction

ErrorBlock( bErro )

If !Empty(aLogFile)
	For nX := 1 to Len(aLogFile)
		If nX == 1
			cLogError += aLogFile[nX]
		Else
			cLogError += "*" + aLogFile[nX]
		EndIf
		PutGlbValue("aLog"+cThread,cLogError)
		GlbUnLock()
	Next nX
EndIf

If !Empty(aMarcNoGer)
	For nX := 1 to Len(aMarcNoGer)
		PutGlbVars( "aMarc" + cThread, { aClone( aMarcNoGer[nX] ) } )
		GlbUnLock()
	Next nX
Else
	PutGlbVars( "aMarc" + cThread, {} )
EndIf

Conout(DtoC(Date())+ " " + Time() + " PONM010: " + 'STR0155' + cThread + 'STR0157')

// STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("PNM010"+cEmp+cFil+cThread,"3")
GlbUnLock()

//Incrementa contador de funcionarios processados
nFuncProc += Val(GetGlbValue("nFunProc"))
PutGlbValue("nFunProc", STR(nFuncProc) )
GlbUnLock()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pn010AutoRead � Autor � IP Rh Inovacao    � Data �09.01.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o conteudo do array da rotina automatica.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 - array aAutoItens com os itens a serem incluidos	  ���
���          � ExpC1 - Nome do campo a ser pesquisado    				  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PONM010()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Pn010AutoRead( aArray , cCampo )
Local nPos 		:= 0
Local cConteudo := ""

If Len(aArray) > 0
	If ( nPos := aScan ( aArray , {|x| UPPER(AllTrim(x[1])) == UPPER(AllTrim(cCampo)) }) ) > 0
		cConteudo := aArray [ nPos ,2 ]
	Endif
Endif

Return cConteudo

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �IntegDef	    � Autor � 				    � Data �22.03.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chama a fun��o PONN010 para fazer integra��o				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PONM010()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage, cVersaoMU )

Local aRet := {}

aRet:= PONN010( cXml, nTypeTrans, cTypeMessage, cVersaoMU )

Return aRet



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao   �SchedDef	    						    � Data �19/02/2018���
�������������������������������������������������������������������������Ĵ��
���Descricao � Chama a fun��o PONN010 pelo Scheduler					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PONM010()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function SchedDef()

Local aParam := {}
Local aOrd	 := {}

aParam := { "P" 		,;
			"PNM010" 	,;
			""			,;
			aOrd		,;
}

Return aParam

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �ErroForm 		�Autor�Leandro Drumond     � Data �27/07/2015�
������������������������������������������������������������������������Ĵ
�Descri��o �Verifica os Erros na Execucao da Formula                     �
������������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �NIL                                                  	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
�Uso       �Generico                                                     �
��������������������������������������������������������������������������/*/
Static Function ErroForm(	oErr			,;	//01 -> Objeto oErr
							lNotErro		,;	//02 -> Se Ocorreu Erro ( Retorno Por Referencia )
							aLog			,;
							cNumJob			;
						)

Local aErrorStack
Local cMsgHelp	:= ""

DEFAULT lNotErro	:= .T.

IF !( lNotErro := !( oErr:GenCode > 0 ) )
	cMsgHelp += "Error Description: "
	cMsgHelp += oErr:Description
	aAdd( aLog, cMsgHelp )
	aErrorStack	:= Str2Arr( oErr:ErrorStack , Chr( 10 ) )
	aEval( aErrorStack , { |X| aAdd(aLog, X) } )

	PutGlbValue("nTemErro"+cNumJob,"1")
	GlbUnLock()
EndIF

Break

Return( NIL )

/*/{Protheus.doc} fApontAnt
Verifica se realiza o apontamento do per�odo anterior caso exista algum registro apontado para esse per�odo
@author Allyson Mesashi
@since 26/01/2021
@version P12.1.27
/*/
Static Function fApontAnt( dPerIni, dPerFim )

Local cAliasQry	:= ""
Local cFilSP8	:= "%'"+SRA->RA_FILIAL+"'%"
Local cPerApo	:= "%'"+dToS(dPerIni)+dToS(dPerFim)+"'%"
Local lApont 	:= .F.
Local nPos		:= 0

If (nPos := aScan( _aAuxPerApo, { |x| x[1] == SRA->RA_FILIAL } )) == 0
	cAliasQry	:= GetNextAlias()
	
	BeginSql alias cAliasQry
		SELECT COUNT(*) AS CONT
		FROM %table:SP8% SP8
		WHERE SP8.P8_FILIAL = %exp:cFilSP8% AND 
		SP8.P8_PAPONTA = %exp:cPerApo% AND 
		SP8.%notDel%
	EndSql

	If (cAliasQry)->( !EoF() )
		lApont := (cAliasQry)->CONT > 0
	EndIf

	(cAliasQry)->( dbCloseArea() )
	aAdd( _aAuxPerApo, { SRA->RA_FILIAL, lApont } )
Else
	lApont := _aAuxPerApo[nPos, 2]
EndIf

Return lApont
