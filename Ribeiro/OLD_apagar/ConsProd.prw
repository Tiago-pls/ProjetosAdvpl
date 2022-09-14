#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.CH"


/*__________________________________________________________________________
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฆฆ+-----------------------------------------------------------------------+ฆฆ
ฆฆฆFun??o    ฆ  ENVEMAIL     ฆ Autor ฆ Tiago Santos      ฆ Data ฆ11.03.21 ฆฆฆ
ฆฆ+----------+------------------------------------------------------------ฆฆฆ
ฆฆฆDescri??o ฆ  Envio de email com texto padrใo                           ฆฆฆ
ฆฆ+-----------------------------------------------------------------------+ฆฆ
ฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆฆ
ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ*/
user function ConsProd


Local aAreaZZ:= SB1->(getarea())
Local oButton1
Local oButton2
Local oButton3
Local oButton4
Local oButton5
Local oGet1
Local cGet1		:= space(40)
Local oGroup1
Local oGroup2
Local oSay1
Local oSay2
Local oRadMenu1
Local nRadMenu1 := 4
Local oComboBo1 
Local cComboBo1 := ""
Local cComboBo2 := ""
Local aGrupo	:= {}
//Local cCampoSB1 := "B1_COD#B1_DESC#B1_GRUPO#B1_TL_DGRU#B1_TL_DSBG"
Local cCampoSB1 := "B1_COD#B1_DESC#B1_GRUPO"
Local aProd		:= {}
Local lTipo		:= AllTrim(FunName())<>'MATA415'
Private oComboBo2 
Private aSubGrp	:= {}
Private xRet	:= .f.
Private _Ret	:= ''
Public _aIndexSB1 := {}
Public _cFiltra := "B1_MSBLQL<>'1' "+iif(lTipo,''," .AND. (!B1_GRUPO $ ('990011#990012#990013#990042'))")
//Public _cFiltra := "B1_MSBLQL<>'1' "
Static oDlgProd

If type("cCadastro")=="U"
	cCadastro:= "Consulta Produtos"
Endif

bFiltraBrw	:= { || FilBrowse( "SB1", @_aIndexSB1, @_cFiltra ) }

dbSelectArea( "SB1" )
Eval( bFiltraBrw )


dbSelectArea('SB1')
dbSetOrder(9)
SB1->(dbGoTop())

dbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SB1")
aProd:={}
While !Eof().And.(x3_arquivo=="SB1")
	If X3USO(x3_usado).And.cNivel>=x3_nivel .and. alltrim(X3_CAMPO) $ cCampoSB1
		Aadd(aProd,{  x3_campo, TRIM(x3_titulo), x3_picture,;
		x3_tamanho, x3_decimal,"AllwaysTrue()",;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	dbSkip()
End
                   
Aadd(aGrupo	,"" )

SBM->(dbSetOrder(2))
SBM->(dbGoTop())
While SBM->(!Eof())
   	Aadd(aGrupo	,SBM->BM_GRUPO+"="+SBM->BM_DESC )  	
	SBM->(dbSkip())
Enddo

cQry:= " Select X5_CHAVE, X5_DESCRI "
cQry+= " From " 
cQry+= RetSqlName("SX5")
cQry+= " Where "
cQry+= " D_E_L_E_T_ = '' AND "
cQry+= " X5_TABELA  = 'ZA' AND "
cQry+= " X5_FILIAL  = '"+xFilial("SX5")+"' "
cQry+= " Order By X5_DESCRI " 

TcQuery cQry New Alias "QSUBGRUP"
                        
Aadd(aSubGrp,"" )  	                 
While QSUBGRUP->(!Eof())      
       Aadd(aSubGrp	,QSUBGRUP->(X5_CHAVE+"="+X5_DESCRI) )  	                 
QSUBGRUP->(dbSkip())
Enddo
QSUBGRUP->(dbCloseArea())       
                   
 dbSelectArea('SB1')
 
DEFINE MSDIALOG oDlgProd TITLE "Consulta de Produtos" FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL

@ 008, 008 MSGET oGet1 VAR cGet1 SIZE 200, 010 OF oDlgProd COLORS 0, 16777215 PIXEL
@ 007, 215 BUTTON oButton3 PROMPT "Pesquisar" SIZE 037, 012 OF oDlgProd ACTION u_Fat006Fil(nRadMenu1,cGet1,cComboBo1,cComboBo2) PIXEL
@ 025, 008 TO 137, 288 Browse "SB1" Fields aProd Object oDlgP
@ 142, 004 GROUP oGroup1 TO 194, 097 PROMPT "Filtrar Por: " OF oDlgProd COLOR 0, 16777215 PIXEL
@ 152, 013 RADIO oRadMenu1 VAR  nRadMenu1 ITEMS "Desc Produto","Cod Produto" SIZE 061, 039 OF oDlgProd COLOR 0, 16777215 PIXEL

@ 145, 120 SAY oSay1 PROMPT "Grupo" SIZE 035, 010 OF oDlgProd COLORS 0, 16777215 PIXEL
@ 145, 200 SAY oSay2 PROMPT "Sub Grupo" SIZE 035, 010 OF oDlgProd COLORS 0, 16777215 PIXEL
@ 155, 120 MSCOMBOBOX oComboBo1 VAR cComboBo1 ITEMS aGrupo  SIZE 072, 010 OF oDlgProd valid(u_Fat006Fil(4,"",cComboBo1,""),oComboBo2:Refresh(),.t.) COLORS 0, 16777215 PIXEL 
@ 155, 200 MSCOMBOBOX oComboBo2 VAR cComboBo2 ITEMS aSubGrp SIZE 072, 010 OF oDlgProd valid(u_Fat006Fil(4,"",cComboBo1,cComboBo2)) COLORS 0, 16777215 PIXEL 

if FunName()=="MATA010"
	@ 182, 113 BUTTON oButton4 PROMPT "Visualizar" SIZE 037, 012 OF oDlgProd ACTION A010Visul('SB1',SB1->(RecNo()),2) PIXEL
	@ 182, 174 BUTTON oButton1 PROMPT "Alterar" SIZE 037, 012 OF oDlgProd ACTION A010ALTERA('SB1',SB1->(RecNo()),4) PIXEL
	@ 182, 237 BUTTON oButton2 PROMPT "Sair" SIZE 037, 012 OF oDlgProd ACTION oDlgProd:end() PIXEL
	oDlgP:oBrowse:bLDblClick:= {||A010Visul('SB1',SB1->(RecNo()),2)}
Else
	@ 182, 110 BUTTON oButton2 PROMPT "Sair" SIZE 037, 012 OF oDlgProd ACTION oDlgProd:end() PIXEL
	@ 182, 155 BUTTON oButton4 PROMPT "Visualizar" SIZE 037, 012 OF oDlgProd ACTION A010Visul('SB1',SB1->(RecNo()),2) PIXEL
	@ 182, 200 BUTTON oButton5 PROMPT "Estoque" SIZE 037, 012 OF oDlgProd ACTION U_TLEST001() PIXEL
	@ 182, 245 BUTTON oButton1 PROMPT "OK" SIZE 037, 012 OF oDlgProd ACTION {|| xRet:=.t., oDlgProd:End()} PIXEL
	oDlgP:oBrowse:bLDblClick:= {||xRet:=.t., oDlgProd:End()}
Endif



if type('TMP1->CK_PRODUTO')<>'U'
	if !Empty(TMP1->CK_PRODUTO)
		dbSetorder(1)
		dbSeek(xFilial('SB1')+TMP1->CK_PRODUTO)
		dbSetorder(9)
	Endif
Endif

if AllTrim(FunName())$'MATA121#MATA103#MATA140' .or. type("acols[n,2]")=="C"
	if !Empty(acols[n,2])
		dbSetorder(1)
		dbSeek(xFilial('SB1')+acols[n,2])
		dbSetorder(9)
	Endif
Endif

oGet1:setFocus()

ACTIVATE MSDIALOG oDlgProd CENTERED

If (_aIndexSB1 # NIL)
	EndFilBrw("SB1",_aIndexSB1)
Endif                                                            

Return xRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTLFAT006  บAutor  ณLeoberto Mendes     บ Data ณ  04/13/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Filtra a tabela SB1 de acordo com os parโmetros            บฑฑ
ฑฑบ          ณ passados pela rotina anterior                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function Fat006Fil(nOpcPesq,cPesq,cGrupo,cSubGrupo)

Local _cFiltra 	:= ''
Local lTipo		:=  AllTrim(FunName())$'MATA121#MATA103#MATA140' 

cPesq:= UPPER(alltrim(cPesq))

If (_aIndexSB1 # NIL)
			EndFilBrw("SB1",_aIndexSB1)
Endif

if nOpcPesq = 1
	_cFiltra:= "'"+cPesq+"' $ B1_DESC"
Elseif nOpcPesq = 2
	_cFiltra:= "'"+cPesq+"' $ B1_COD"
Elseif nOpcPesq = 3
	//_cFiltra:= "'"+cPesq+"' $ B1_TL_DSBG"
Elseif nOpcPesq = 4
	//_cFiltra:= "'"+cPesq+"' $ B1_TL_PARN"
Endif

_cFiltra+= " .and. B1_MSBLQL<>'1' "+iif(lTipo,''," .AND. (!B1_GRUPO $ ('990011#990012#990013#990042'))")
//_cFiltra+= " B1_MSBLQL<>'1' "

if empty(cPesq)
	_cFiltra:= " B1_MSBLQL<>'1' "+iif(lTipo,''," .AND. (!B1_GRUPO $ ('990011#990012#990013#990042'))")
Endif

if !Empty(cGrupo)
	_cFiltra+= " .and. B1_GRUPO = '"+cGrupo+"'"
Endif	
if !empty(cSubGrupo)
	//_cFiltra+= ".and. B1_TL_SUBG = '"+cSubGrupo+"' "
Endif

if !Empty(cGrupo) .and. Empty(cSubGrupo)
	cQry:= " Select X5_CHAVE, X5_DESCRI "
	cQry+= " From "
	cQry+= RetSqlName("SX5") + " SX5, "
	cQry+= RetSqlName("SB1") + " SB1 "
	cQry+= " Where "
	cQry+= " SX5.D_E_L_E_T_ = '' AND "
	cQry+= " SB1.D_E_L_E_T_ = '' AND "
	cQry+= " X5_TABELA  = 'ZA' AND "
	cQry+= " X5_FILIAL  = '"+xFilial("SX5")+"' AND "
	cQry+= " B1_FILIAL  = '"+xFilial("SB1")+"' AND "
//	cQry+= " B1_TL_SUBG  = X5_CHAVE			   AND "
	cQry+= " B1_GRUPO    = '"+cGrupo+"'	 "
	cQry+= " Group by X5_CHAVE, X5_DESCRI "
	cQry+= " Order By X5_DESCRI "
	
	TcQuery cQry New Alias "QSUBGRUP"
	aSubGrp:= {}
	Aadd(aSubGrp,"")
	
	While QSUBGRUP->(!Eof())
		Aadd(aSubGrp	,QSUBGRUP->(X5_CHAVE+"="+X5_DESCRI) )
		QSUBGRUP->(dbSkip())
	Enddo
	QSUBGRUP->(dbCloseArea())
	
	oComboBo2:aItems:=aSubGrp
	oComboBo2:Refresh()
Endif

	bFiltraBrw	:= { || FilBrowse( "SB1", @_aIndexSB1, @_cFiltra ) }
	
	dbSelectArea( "SB1" )
	Eval( bFiltraBrw )
	dbGoTop()
	
_cFiltra:= "B1_MSBLQL<>'1' "+iif(lTipo,''," .AND. (!B1_GRUPO $ ('990011#990012#990013#990042'))")
//_cFiltra:= "B1_MSBLQL<>'1' "

oDlgP:obrowse:refresh()

Return .t.
