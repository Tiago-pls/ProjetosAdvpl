#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TCFA040.CH"
#INCLUDE "PONCALEN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! FTGPESOL                                                !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o       ! Aprovação em lote aprovações                            !
+------------------+---------------------------------------------------------+
!Autor             ! Fiscaltech                                              !
+------------------+---------------------------------------------------------!
!Alterações        !                                                         !
!chamado 11987     !  inclusao do controle de filiais na tabela SQB          !
+------------------+--------------------------------------------------------*/

user function FTGPESOL()
//Declarar variáveis locais
    Local aCampos    := {}
    Local cArqTrb
    Local cIndice1, cIndice2 := ""
    Local lMarcar      := .F.
    Local aSeek   := {}
    Local aFieFilter := {}
    Local cQryEmp
    Local bKeyF12    := {||  MCFG6Invert(),oBrowse:SetInvert(.F.),oBrowse:Refresh(),oBrowse:GoTop(.T.) } //Programar a tecla F12
    //Declarar variáveis privadas
    Private oBrowse     := Nil
    Private cCadastro     := "Efetivar Solicitações do Portal em lote"
    Private aRotina         := Menudef() //Se for criar menus via MenuDef
    Private nTamFilial := FWGETTAMFILIAL
    
    //Criar a tabela temporária
    AAdd(aCampos,{"TR_OK"      ,"C",002,0}) //Este campo será usado para marcar/desmarcar
    AAdd(aCampos,{"TR_FILIAL"  ,"C",nTamFilial,0})
    AAdd(aCampos,{"TR_CODIGO"  ,"C",005,0})
    AAdd(aCampos,{"TR_SOLICIT" ,"C",050,0})
    //AAdd(aCampos,{"TR_DEPTO","C",006,0})
    //AAdd(aCampos,{"TR_DESCD","C",050,0})
    AAdd(aCampos,{"TR_ORIGEM","C",006,0})
    AAdd(aCampos,{"TR_TIPO","C",025,0})
    AAdd(aCampos,{"TR_DATA" ,"C",010,0})
    //Se o alias estiver aberto, fechar para evitar erros com alias aberto
    If (Select("TRB") <> 0)
        dbSelectArea("TRB")
        TRB->(dbCloseArea ())
    Endif
    //A função CriaTrab() retorna o nome de um arquivo de trabalho que ainda não existe e dependendo dos parâmetros passados, pode criar um novo arquivo de trabalho.
    cArqTrb   := CriaTrab(aCampos,.T.)
    
    //Criar indices
    cIndice1 := Alltrim(CriaTrab(,.F.))
    cIndice2 := cIndice1
    cIndice3 := cIndice1
    cIndice4 := cIndice1
    
    cIndice1 := Left(cIndice1,5) + Right(cIndice1,2) + "A"
    cIndice2 := Left(cIndice2,5) + Right(cIndice2,2) + "B"

    
    //Se indice existir excluir
    If File(cIndice1+OrdBagExt())
        FErase(cIndice1+OrdBagExt())
    EndIf
    If File(cIndice2+OrdBagExt())
        FErase(cIndice2+OrdBagExt())
    EndIf
    
     //A função dbUseArea abre uma tabela de dados na área de trabalho atual ou na primeira área de trabalho disponível
    dbUseArea(.T.,,cArqTrb,"TRB",Nil,.F.)
    //A função IndRegua cria um índice temporário para o alias especificado, podendo ou não ter um filtro
    IndRegua("TRB", cIndice1, "TR_CODIGO"    ,,, "Indice Codigo...")
    IndRegua("TRB", cIndice2, "TR_SOLICIT",,, "Indice Solicitante...")
    
    //Fecha todos os índices da área de trabalho corrente.
    dbClearIndex()
    //Acrescenta uma ou mais ordens de determinado índice de ordens ativas da área de trabalho.
    dbSetIndex(cIndice1+OrdBagExt())
    dbSetIndex(cIndice2+OrdBagExt())
    	
	cQryEmp := " select "
	cQryEmp += " RH3_FILIAL FILIAL, "
	cQryEmp += " RH3_CODIGO CODIGO, "
	cQryEmp += " RH3_MAT+' - '+SRA.RA_NOME SOLICITANTE, "  
	cQryEmp += " RH3_TIPO+' - '+X5_DESCRI TIPO_SOLIC, "
	cQryEmp += " RH3_ORIGEM ORIGEM,  "
	//cQryEmp += " case RH3_STATUS when '1' then 'AGUARDANDO APROVAÇÃO DO GESTOR' when '2' then 'ATENDIDA' when '3' then 'REPROVADA' when '4' then 'AGUARDANDO EFETIVAÇÃO DO RH' end STATUS, " 
	cQryEmp += " CONVERT(varchar, CONVERT(datetime, RH3_DTSOLI), 103) DATA_SOLIC "
	//cQryEmp += " SRA.RA_DEPTO+'- '+QB_DESCRIC DEPARTAMENTO "
	cQryEmp += " from "+RetSqlName("RH3")+" RH3  "
	cQryEmp += " inner join "+RetSqlName("SRA")+" SRA ON RH3_MAT = SRA.RA_MAT and SRA.D_E_L_E_T_ = '' "
	//cQryEmp += " inner join "+RetSqlName("SQB")+" SQB ON QB_DEPTO = RA_DEPTO and SQB.D_E_L_E_T_ = '' "
	cQryEmp += " inner join "+RetSqlName("SQB")+" SQB ON QB_DEPTO = RA_DEPTO and SQB.D_E_L_E_T_ = '' and SubString(RH3_FILIAL,1,2) = QB_FILIAL"
	cQryEmp += " inner join "+RetSqlName("SX5")+" SX5 ON X5_TABELA = 'JQ' and X5_CHAVE = RH3_TIPO and SX5.D_E_L_E_T_ = '' "
	cQryEmp += " left  join "+RetSqlName("SRA")+" SRA2 ON RH3_FILIAL = SRA2.RA_FILIAL and RH3_MATAPR = SRA2.RA_MAT and SRA2.D_E_L_E_T_ = '' "
	cQryEmp += " where RH3.D_E_L_E_T_ = ''  "
	cQryEmp += " and RH3_STATUS = '4' "
	cQryEmp += " and RH3_TIPO IN ('8','Z') "
	cQryEmp += " order by RH3_DTSOLI "
	
	If Select("QRY") > 0
	   QRY->(DbCloseArea())
	EndIF
	
	//crio o novo alias
	TCQUERY cQryEmp New Alias "QRY"
    
    dbSelectArea("QRY")
	dbGoTop()
	
	While QRY->(!EOF())

	    //Popular tabela temporária, irei colocar apenas um unico registro
	    If RecLock("TRB",.t.)
	        TRB->TR_OK    := "  "
	        TRB->TR_FILIAL:= QRY->FILIAL
	        TRB->TR_CODIGO:= QRY->CODIGO
	        TRB->TR_SOLICIT:= QRY->SOLICITANTE
	        TRB->TR_TIPO  := QRY->TIPO_SOLIC
	        TRB->TR_ORIGEM:= QRY->ORIGEM
	        TRB->TR_DATA := QRY->DATA_SOLIC
	        MsUnLock()
	    Endif
	    
	    QRY->(dbSkip())
	EndDo
    
    TRB->(DbGoTop())
    
    If TRB->(!Eof())
        //Irei criar a pesquisa que será apresentada na tela
        aAdd(aSeek,{"Codigo"    ,{{"","C",005,0,"Codigo"    ,"@!"}} } )
        aAdd(aSeek,{"Solicit"    ,{{"","C",050,0,"Solicitante","@!"}} } )
        //Campos que irão compor a tela de filtro
        Aadd(aFieFilter,{"TR_FILIAL"   , "FILIAL"             , "C",nTamFilial, 0,"@!"})
        Aadd(aFieFilter,{"TR_CODIGO"    , "CODIGO"          , "C",005, 0,"@!"})
        Aadd(aFieFilter,{"TR_DATA"    , "DATA"           , "C",010, 0,""})
        Aadd(aFieFilter,{"TR_SOLICIT" , "SOLICITANTE"    , "C",050, 0,""})
        Aadd(aFieFilter,{"TR_ORIGEM"  , "ORIGEM"         , "C",006, 0,"@!"})
        
        //Agora iremos usar a classe FWMarkBrowse
        oBrowse:= FWMarkBrowse():New()
        oBrowse:SetDescription(cCadastro) //Titulo da Janela
        oBrowse:SetParam(bKeyF12) // Seta tecla F12
        oBrowse:SetAlias("TRB") //Indica o alias da tabela que será utilizada no Browse
        oBrowse:SetFieldMark("TR_OK") //Indica o campo que deverá ser atualizado com a marca no registro
        oBrowse:oBrowse:SetDBFFilter(.T.)
        oBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
        oBrowse:oBrowse:SetFixedBrowse(.T.)
        oBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
        oBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
        oBrowse:SetTemporary() //Indica que o Browse utiliza tabela temporária
        oBrowse:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
        oBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
        oBrowse:oBrowse:SetFieldFilter(aFieFilter)
        oBrowse:DisableDetails()
        //Permite adicionar legendas no Browse
        //Adiciona uma coluna no Browse em tempo de execução
        oBrowse:SetColumns(MCFG006TIT("TR_FILIAL"    ,"FILIAL"        ,03,"@!",0,nTamFilial,0))
        oBrowse:SetColumns(MCFG006TIT("TR_CODIGO"    ,"CODIGO"   ,04,"@!",1,005,0))
        oBrowse:SetColumns(MCFG006TIT("TR_SOLICIT"   ,"SOLICITANTE"   ,05,"@!",1,050,0))
        oBrowse:SetColumns(MCFG006TIT("TR_TIPO","TIPO"    ,06,"@!",1,025,0))
        oBrowse:SetColumns(MCFG006TIT("TR_ORIGEM","ORIGEM"    ,07,"@!",1,006,0))
        oBrowse:SetColumns(MCFG006TIT("TR_DATA","DATA"    ,08,"",1,010,0))
        
        //Adiciona botoes na janela
        oBrowse:AddButton("Efetivar"    , { || EFESOL()},,,, .F., 2 )
        oBrowse:AddButton("Detalhes"        , { || DETAILS() },,,, .F., 2 )
        
        //Indica o Code-Block executado no clique do header da coluna de marca/desmarca
        oBrowse:bAllMark := { || MCFG6Invert(oBrowse:Mark(),lMarcar := !lMarcar ), oBrowse:Refresh(.T.)  }
        //Método de ativação da classe
        oBrowse:Activate()
        
        oBrowse:oBrowse:Setfocus() //Seta o foco na grade
    Else
    	MSGINFO( "Não há dados para efetivar por parte do RH", "EFETIVAÇÃO DO RH")
        Return
    EndIf
    
    //Limpar o arquivo temporário
    If !Empty(cArqTrb)
        Ferase(cArqTrb+GetDBExtension())
        Ferase(cArqTrb+OrdBagExt())
        cArqTrb := ""
        TRB->(DbCloseArea())
    Endif
Return(.T.)

//Função para marcar/desmarcar todos os registros do grid
Static Function MCFG6Invert(cMarca,lMarcar)
    Local cAliasSD1 := 'TRB'
    Local aAreaSD1  := (cAliasSD1)->( GetArea() )
    dbSelectArea(cAliasSD1)
    (cAliasSD1)->( dbGoTop() )
    While !(cAliasSD1)->( Eof() )
        RecLock( (cAliasSD1), .F. )
        (cAliasSD1)->TR_OK := IIf( lMarcar, cMarca, '  ' )
        MsUnlock()
        (cAliasSD1)->( dbSkip() )
    EndDo
    RestArea( aAreaSD1 )
Return .T.

//Caso crie os botões por função, abaixo seque um exemplo
Static Function MenuDef()
    Local aRot := {}
    
    //ADD OPTION aRot TITLE "Enviar Mensagem" ACTION "U_MCFG006M()"  OPERATION 6 ACCESS 0
    //ADD OPTION aRot TITLE "Detalhes"         ACTION "MsgRun('Coletando dados de usuário(s)','Relatório',{|| U_RCFG0005() })"  OPERATION 6 ACCESS 0
    //ADD OPTION aRot TITLE "Legenda"         ACTION ""  OPERATION 6 ACCESS 0
Return(Aclone(aRot))

//Função para criar as colunas do grid
Static Function MCFG006TIT(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
    Local aColumn
    Local bData     := {||}
    Default nAlign     := 1
    Default nSize     := 20
    Default nDecimal:= 0
    Default nArrData:= 0  
        
    If nArrData > 0
        bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
    EndIf
    
    /* Array da coluna
    [n][01] Título da coluna
    [n][02] Code-Block de carga dos dados
    [n][03] Tipo de dados
    [n][04] Máscara
    [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
    [n][06] Tamanho
    [n][07] Decimal
    [n][08] Indica se permite a edição
    [n][09] Code-Block de validação da coluna após a edição
    [n][10] Indica se exibe imagem
    [n][11] Code-Block de execução do duplo clique
    [n][12] Variável a ser utilizada na edição (ReadVar)
    [n][13] Code-Block de execução do clique no header
    [n][14] Indica se a coluna está deletada
    [n][15] Indica se a coluna será exibida nos detalhes do Browse
    [n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
    */
    aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return {aColumn}

//Função para criar a tela de legenda
/*
Static Function MCFG006LEG()
    Local oLegenda  :=  FWLegend():New()
    oLegenda:Add( '', 'BR_VERDE'   , "Usuários Liberados" )
    oLegenda:Add( '', 'BR_VERMELHO', "Usuários Bloqueados")
    
    oLegenda:Activate()
    oLegenda:View()
    oLegenda:DeActivate()
Return Nil
*/

Static Function EFESOL()
Local nCont := 0
Local cAliasQry, cAliasRF0Qry
Local cMat := ""
Local dDtPreI := cToD("//")
Local nHorIni := 0
Local dDtPreF := cToD("//")
Local nHorFim := 0
Local cCodAbo := ""
Local cFilRF0 := ""
Local nRet
Local cMsg	  := ""
Local cAviso  := ""	

	TRB->( DbSetOrder(1) )
    TRB->( DbGoTop() )
    
    dbSelectArea('RH3')
	dbSetOrder(1) // RH3_FILIAL + RH3_CODIGO
    
    If MSGYESNO("Deseja confirmar a efetivação das solcitações selecionadas? Esta operação não tem reversão.","Deseja confirmar?")
		While !TRB->(Eof())
        	If !Empty(TRB->TR_OK) //Se diferente de vazio, é porque foi marcado
       
	        	If LEFT(TRB->TR_TIPO,1) == "Z" //Marcação de Ponto via Portal
		        	nRet := fAprovPon( TRB->TR_FILIAL, LEFT(TRB->TR_SOLICIT,6), TRB->TR_CODIGO, @cMsg, @cAviso, .F. )
	
					DbSelectArea("SRA")
					DbSetOrder(1)
					SRA->(DbSeek(TRB->TR_FILIAL + LEFT(TRB->TR_SOLICIT,6)))
		
					If nRet == 1
						MsgStop( cMsg, cAviso )
						Return(.F.)			
					ElseIf nRet == 2
						MsgAlert(STR0076 , STR0007) //"Marcação esta fora do período aberto, não poderá ser incluída!"
						Return .F.
					Else
						RH3->(dbSeek(TRB->TR_FILIAL+TRB->TR_CODIGO))
			        	If RecLock("RH3",.F.)
					        RH3->RH3_STATUS	:= '2'
					        RH3->RH3_DTATEN	:= DDATABASE
					        MsUnLock()
				        Endif
		
					EndIf

				EndIf
				
				If LEFT(TRB->TR_TIPO,1) == "8" //Marcação de Ponto via Portal
					// **************************** Justificativa de Horario
					// Busca RH4
					cAliasQry := "JUSTIFHOR"
					BeginSql alias cAliasQry
						SELECT RH4.RH4_CAMPO, RH4.RH4_VALNOV
						FROM %table:RH4% RH4
						WHERE RH4.RH4_FILIAL = %exp:TRB->TR_FILIAL% AND
							   RH4.RH4_CODIGO = %exp:TRB->TR_CODIGO% AND
					    	 RH4.%notDel%
					EndSql
	
			//Verifica se ha um pre-abono cadastrado com todas informacoes iguais
					Dbselectarea(cAliasQry)
					While !(cAliasQry)->(eof())
						Do Case
						Case Alltrim((cAliasQry)->RH4_CAMPO) == "RF0_MAT"
							cMat := AllTrim( (cAliasQry)->RH4_VALNOV )
						Case Alltrim((cAliasQry)->RH4_CAMPO) == "RF0_DTPREI"
							dDtPreI	:= dToS( cToD( AllTrim( (cAliasQry)->RH4_VALNOV ) ) )
						Case Alltrim((cAliasQry)->RH4_CAMPO) == "RF0_HORINI"
							nHorIni := Str( Val( AllTrim( (cAliasQry)->RH4_VALNOV ) ), 5, 2 )
						Case Alltrim((cAliasQry)->RH4_CAMPO) == "RF0_DTPREF"
							dDtPreF := dToS( cToD( AllTrim( (cAliasQry)->RH4_VALNOV ) ) )
						Case Alltrim((cAliasQry)->RH4_CAMPO) == "RF0_HORFIM"
							nHorFim := Str( Val( AllTrim( (cAliasQry)->RH4_VALNOV ) ), 5, 2 )
						Case Alltrim((cAliasQry)->RH4_CAMPO) == "RF0_CODABO"
							cCodAbo := AllTrim( (cAliasQry)->RH4_VALNOV )
						Case Alltrim((cAliasQry)->RH4_CAMPO) == "RF0_FILIAL"
							cFilRF0 := SubStr( (cAliasQry)->RH4_VALNOV, 1, nTamFilial)
						EndCase
	
						(cAliasQry)->(dbskip())               
					Enddo
	
					cAliasRF0Qry := "QRF0"
					BeginSql alias cAliasRF0Qry
						SELECT COUNT(*) as nRegs
						FROM %table:RF0% RF0
						WHERE RF0.RF0_FILIAL  = %exp:cFilRF0% AND
							   RF0.RF0_MAT    = %exp:cMat%    AND
							   RF0.RF0_DTPREI = %exp:dDtPreI% AND
							   RF0.RF0_HORINI = %exp:nHorIni% AND
							   RF0.RF0_DTPREF = %exp:dDtPreF% AND
							   RF0.RF0_HORFIM = %exp:nHorFim% AND
							   RF0.RF0_CODABO = %exp:cCodAbo% AND
					    	   RF0.%notDel%
					EndSql
	
					// Atualiza RF0
					If (cAliasRF0Qry)->nRegs == 0
						Begin Transaction
							RecLock("RF0", .T.)
							RF0->RF0_FILIAL	:= cFilRF0
							RF0->RF0_MAT	:= cMat
							RF0->RF0_DTPREI	:= sToD(dDtPreI)
							RF0->RF0_HORINI	:= Val(nHorIni)
							RF0->RF0_DTPREF	:= sToD(dDtPreF)
							RF0->RF0_HORFIM	:= Val(nHorFim)
							RF0->RF0_CODABO	:= cCodAbo
							RF0->RF0_HORTAB	:= "N"
							RF0->RF0_ABONA 	:= "N"
							RF0->RF0_USUAR 	:= UsrRetName(RetCodUsr())
							RF0->RF0_FLAG  	:= "I"
			
							MsUnLock()
						End Transaction					
					EndIf
					(cAliasQry)->( DbCloseArea() )
					(cAliasRF0Qry)->( DbCloseArea() )
	
					RH3->(dbSeek(TRB->TR_FILIAL+TRB->TR_CODIGO))
		        	If RecLock("RH3",.F.)
				        RH3->RH3_STATUS	:= '2'
				        RH3->RH3_DTATEN	:= DDATABASE
				        MsUnLock()
			        Endif
			        
				EndIf
			
				nCont++
			EndIf
			TRB->( dbSkip() )
		EndDo
	Else
		CloseBrowse()
		return
	Endif
    
    dbCloseArea()
       
    if nCont == 0
        Alert("Selecione pelo menos um registro!")
        oBrowse:Refresh(.T.)
        return
    Else
    	MSGINFO( "As solicitações selecionadas foram aprovadas e efetivadas!", "APROVACAO")
        CloseBrowse()
    Endif
    
    oBrowse:Refresh(.T.)
Return

Static Function DETAILS()
Local cQRY := ""
Local cDetail := ""
	
	cQRY += "select RH4_CAMPO, RH4_VALNOV from "+RetSqlName("RH4")+" RH4 "
	cQRY += " where RH4_FILIAL = '"+fieldget(fieldpos("TR_FILIAL"))+"' and RH4_CODIGO = '"+fieldget(fieldpos("TR_CODIGO"))+"' "
	cQRY += " order by RH4_ITEM"
	
	//crio o novo alias
	TCQUERY cQRY New Alias "QRYD"
    
    dbSelectArea("QRYD")
	QRYD->(dbGoTop())
	
	While QRYD->(!EOF())
		cDetail += QRYD->RH4_CAMPO + ": " +ALLTRIM(QRYD->RH4_VALNOV) + Chr(13) + Chr(10)
		QRYD->(DBSkip())
	EndDo
	
	MSGINFO(cDetail,"Detalhes da solicitação")
	QRYD->(DBCloseArea())
Return
