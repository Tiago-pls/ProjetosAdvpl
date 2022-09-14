#include "protheus.ch"          

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  TestSelec    ¦ Autor ¦ Tiago Santos      ¦ Data ¦02.02.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Testa a seleção dos modelos a serem gerados em PDF        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function TestSelec()    
Local _stru:={}
Local aCpoBro := {}
Local aSX5 := SX5->( GetArea())
aCores := {}
Private lInverte := .F.
Private cMark   := GetMark()   
Private oMark//Cria um arquivo de Apoio
Private aParametros:= {}
Private cPerg    := PadR('GERAPDF',10,Space(1))

AjustaSx1(cPerg)

	If Len(aParametros) = 0
		If	( !Pergunte(cPerg,.T.) )
			Return( Nil )
		EndIf
	Else
		Pergunte(cPerg,.F.)
		//Carrega os parametros pelo array passado.
		mv_par01 	:= aParametros[1]               //Filial de 
		mv_par02 	:= aParametros[2]               //Filial Ate
		mv_par03 	:= aParametros[3]               //Centro Custo de
		mv_par04 	:= aParametros[4]               //Cenrto Custo ate
		mv_par05 	:= aParametros[5]               //Matricula de 
		mv_par06 	:= aParametros[6]               //Matricula ate
		mv_par07 	:= aParametros[7]               //Situacao
		mv_par08 	:= aParametros[8]               //Cetegoria
		mv_par09 	:= aParametros[9]               //Admissao de 
		mv_par10 	:= aParametros[10]               //Admissao Ate
		mv_par11    := aParametros[11]
	EndIf

AADD(_stru,{"OK"     ,"C"	,2		,0		})
AADD(_stru,{"COD"    ,"C"	,2		,0		})
AADD(_stru,{"MODELO"   ,"C"	,50		,0		})

cArq:=Criatrab(_stru,.T.)
DBUSEAREA(.t.,,carq,"TTRB")
//Alimenta o arquivo de apoio com os registros do cadastro de clientes (SA1)
DbSelectArea("SX5")
DbGotop()
SX5->( DbSeek( xFilial() + 'Z5'))

DbSelectArea("TTRB")	
While  SX5->(!Eof()).and. SX5->X5_TABELA =='Z5'
	if ! Empty(SX5->X5_CHAVE)
		RecLock("TTRB",.T.)		
		TTRB->COD     :=  SX5->X5_CHAVE		
		TTRB->MODELO  :=  SX5->X5_DESCRI	
		MsunLock()	
	Endif
	SX5->(DbSkip())
Enddo

//Define as cores dos itens de legenda.
aCores := {}

//Define quais colunas (campos da TTRB) serao exibidas na MsSelect
aCpoBro	:= {{ "OK"			,, "Mark"           ,"@!"},;			
{ "COD"			,, "Codigo"         ,"@!"},;			
{ "MODELO"		,, "Modelo"         ,"@1!"}}

//Cria uma Dialog
DEFINE MSDIALOG oDlg TITLE "Modelos" From 8,0 To 325,800 PIXEL
DbSelectArea("TTRB")
DbGotop()
//Cria a MsSelect
oMark := MsSelect():New("TTRB","OK","",aCpoBro,@lInverte,@cMark,{17,1,150,400},,,,,aCores)
oMark:bMark := {| | Disp()} 
//Exibe a Dialog
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()})
MontaEsc()
//Fecha a Area e elimina os arquivos de apoio criados em disco.
TTRB->(DbCloseArea())
Iif(File(cArq + GetDBExtension()),FErase(cArq  + GetDBExtension()) ,Nil)
RestArea(aSX5)
Return//Funcao executada ao Marcar/Desmarcar um registro.   

Static Function Disp()

RecLock("TTRB",.F.)
	If Marked("OK")	
		TTRB->OK := cMark
	Else	
		TTRB->OK := ""
	Endif             
MSUNLOCK()
oMark:oBrowse:Refresh()

Return()


static function MontaEsc()
Local aEscolhidos := {}

DbSelectArea("TTRB")
DbGotop()
While TTRB->( ! EOF())
	if TTRB->OK == cMark
		Aadd(aEscolhidos, TTRB->COD)
	Endif

	TTRB->( DbSkip())
Enddo

if len(aEscolhidos)==0
	msgStop("Não foi escolhido nenhum modelo para geração.")
	return nil
else
	u_GeraPdf(aEscolhidos)
Endif
return


Static Function AjustaSX1(cPerg)
	Local	aRegs   := {},;
	_sAlias := Alias(),;
	nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Campos a serem grav. no SX1³
	//³aRegs[nx][01] - X1_GRUPO   ³
	//³aRegs[nx][02] - X1_ORDEM   ³
	//³aRegs[nx][03] - X1_PERGUNTE³
	//³aRegs[nx][04] - X1_PERSPA  ³
	//³aRegs[nx][05] - X1_PERENG  ³
	//³aRegs[nx][06] - X1_VARIAVL ³
	//³aRegs[nx][07] - X1_TIPO    ³
	//³aRegs[nx][08] - X1_TAMANHO ³
	//³aRegs[nx][09] - X1_DECIMAL ³
	//³aRegs[nx][10] - X1_PRESEL  ³
	//³aRegs[nx][11] - X1_GSC     ³
	//³aRegs[nx][12] - X1_VALID   ³
	//³aRegs[nx][13] - X1_VAR01   ³
	//³aRegs[nx][14] - X1_DEF01   ³
	//³aRegs[nx][15] - X1_DEF02   ³
	//³aRegs[nx][16] - X1_DEF03   ³
	//³aRegs[nx][17] - X1_F3      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria uma array, contendo todos os valores...³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aRegs,{cPerg,'01','Filial de          ?','Filial de          ?','Filial de          ?','mv_ch1','C', 2,0,0,'G','','mv_par01','','','','SM0'})
	aAdd(aRegs,{cPerg,'02','Filial Ate         ?','Filial Ate         ?','Filial Ate         ?','mv_ch2','C', 2,0,0,'G','','mv_par02','','','','SM0'})
	aAdd(aRegs,{cPerg,'03','C.Custo de         ?','C.Custo de         ?','C.Custo de         ?','mv_ch3','C', 9,0,0,'G','','mv_par03','','','','CTT'})
	aAdd(aRegs,{cPerg,'04','C.Custo Ate        ?','C.Custo Ate        ?','C.Custo Ate        ?','mv_ch4','C', 9,0,0,'G','','mv_par04','','','','CTT'})
	aAdd(aRegs,{cPerg,'05','Matricula de       ?','Matricula de       ?','Matricula de       ?','mv_ch5','C', 6,0,0,'G','','mv_par05','','','','SRA'})
	aAdd(aRegs,{cPerg,'06','Matricula ate      ?','Matricula ate      ?','Matricula ate      ?','mv_ch6','C', 6,0,0,'G','','mv_par06','','','','SRA'})
	aAdd(aRegs,{cPerg,'07','Situação           ?','Situação           ?','Situação           ?','mv_ch7','C', 5,0,0, 'G','fSituacao()','mv_par07','','','',''})
	aAdd(aRegs,{cPerg,'08','Categoria          ?','Categoria          ?','Categoria          ?','mv_ch8','C', 15,0,0,'G','fCategoria()','mv_par08','','','',''})
	aAdd(aRegs,{cPerg,'09','Admissao de        ?','Admissao de        ?','Admissao de        ?','mv_ch9','D', 8,0,0,'G','','mv_par09','','','',''})
	aAdd(aRegs,{cPerg,'10','Admissao Ate       ?','Admissao Ate       ?','Admissao Ate       ?','mv_cha','D', 8,0,0,'G','','mv_par10','','','',''})
	aAdd(aRegs,{cPerg,'11','Arquivo             ','Arquivo            ?','Arquivo            ?','mv_cha','C', 80,0,0,'G','','mv_par11','','','',''})
	
	DbSelectArea('SX1')
	SX1->(DbSetOrder(1))

	For nX:=1 to Len(aRegs)
		If	( !SX1->(DbSeek(aRegs[nx][01]+aRegs[nx][02])) )
			If	RecLock('SX1',.T.)
				Replace X1_GRUPO	With aRegs[nx][01]
				Replace X1_ORDEM   	With aRegs[nx][02]
				Replace X1_PERGUNTE	With aRegs[nx][03]
				Replace X1_PERSPA	With aRegs[nx][04]
				Replace X1_PERENG	With aRegs[nx][05]
				Replace X1_VARIAVL	With aRegs[nx][06]
				Replace X1_TIPO		With aRegs[nx][07]
				Replace X1_TAMANHO	With aRegs[nx][08]
				Replace X1_DECIMAL	With aRegs[nx][09]
				Replace X1_PRESEL	With aRegs[nx][10]
				Replace X1_GSC		With aRegs[nx][11]
				Replace X1_VALID	With aRegs[nx][12]
				Replace X1_VAR01	With aRegs[nx][13]
				Replace X1_DEF01	With aRegs[nx][14]
				Replace X1_DEF02	With aRegs[nx][15]
				Replace X1_DEF03	With aRegs[nx][16]
				Replace X1_F3   	With aRegs[nx][17]
				MsUnlock('SX1')
			Else
				Help('',1,'')
			EndIf
		Endif
	Next nX
Return
