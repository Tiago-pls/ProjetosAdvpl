#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE2.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"  
//----------------------------------------------------------
/*/{Protheus.doc} ANALISE
Fun��o ANALISE
@param N�o recebe par�metros
@return N�o retorna nada
@author Reinaldo Dias
@owner Totvs S/A
@version Protheus 10, Protheus 11
@since 04/10/2012 - data de revis�o do artefato
 

/*/
//----------------------------------------------------------

Static cPict        := ""

User Function CptTables()            
Local oDlgMain    
Local aArea          := GetArea()
Local oNoMarked      := LoaDBitmap( GetResources(), "LBNO" )
Local oMarked        := LoaDBitmap( GetResources(), "LBOK" )
Local cPerg          := "ANALISE"
 
Private cLFRC	:= chr(13)+chr(10)
Private cPict2UM     := PesqPict('SB2','B2_QTSEGUM')
Private cPictD5      := PesqPict('SD5','D5_QUANT')
Private cPictDB      := PesqPict('SDB','DB_QUANT')
Private cPictB1      := PesqPict('SB1','B1_CONV')

private  lChSED  := .F.
private  lChZM9  := .F.
private  lChSA2  := .F.


private lChSAH       := .F.
private lChSB1       := .F.
private lChSBM       := .F.
private lChZ01       := .F.
private lChZ02       := .F.
private lChSE4       := .F.
private lChCT1   := .F.
private lChCTD   := .F.
private lChCTH   := .F.
private lChCVD   := .F.
private lChCVN   := .F.
private lChCT5   := .F.
private lChSF4   := .F.
private lChSF7   := .F.
private lChCVE   := .F.
private lChCVF   := .F.
private lChCTN   := .F.
private lChSAL   := .F.
private lChSY1   := .F.
private lChDHL   := .F.
private lChSFM   := .F.
private lChF3K   := .F.
private lChSA6   := .F.
private lChSM4   := .F.
private lChSA1   := .F.
private lChSA3   := .F.
private lChCTS   := .F.
private lChCTT   := .F.
private lChSNG   := .F.
private lChNNR   := .F.
private lMarkTd   := .F.
private aOpcoes  := {}
                                             
Private aNumSeq      := {}
Private _cFilOri       := Space(6)
Private _cFilDes       := Space(6)
Private dDtProces    := dDataBase
Private _cEmpDes     := Space(2)

Private nSldKarLocal := nSldKarLote := nSldKarEnde := 0
Private _cEmpOri     := Space(2)
Private _cEmpOld     := Space(2)
Private _cEmpIni     := cEmpant
Private _cFilIni     := cFilant
Private cDescEmpOri  := Space(40)
Private cDescEmpDes  := Space(40)
Private nOpSB8       := 1
Private nOpSBF       := 1
Private cMensagem    := ""
Private cMensOK      := ""
Private cMensErro    := ""
Private cMensSB8     := ""
Private cMensSBF     := ""        
Private cCrlLot      := ""        
Private cCrlEnd      := ""        
Private cDescFilOri         := ""
Private cDescFilDes         := ""
Private c2UM         := ""
Private nFatConv     := 0
Private cTipConv     := ""
Private cZona        := ""
Private aSx3Box      := RetSx3Box(Posicione('SX3',2,'BE_STATUS','X3CBox()'),,,1)
Private cMensB8BF    := ""
Private cMensBJBK    := ""
Private cMensDocto   := ""
Private cMensNumSeq  := ""
Private cMensDAB8    := ""
Private _lReturn     := .F.

cPict        := PesqPict('SB2','B2_QATU')

#IFDEF TOP
    IF !fDigSenha()
       Return
    Endif
#ELSE
    MsgStop("Essa rotina funciona somente no ambiente TOP.")
    Return
#ENDIF

Pergunte(cPerg,.F.)               

DEFINE MSDIALOG oDlgMain TITLE "C�pia registros"  OF oMainWnd PIXEL FROM 040,040 TO 670,1017
DEFINE FONT oBold   NAME "Arial" SIZE 0, -12 BOLD
DEFINE FONT oBold2  NAME "Arial" SIZE 0, -40 BOLD
DEFINE FONT oBold3  NAME "Arial" SIZE 0, -80 BOLD
DBSelectArea("SB1")

//@ 100,006 FOLDER oFolder OF oDlgMain PROMPT "&Faturamento","Financeiro","Compras","Contabilidade","XX","XX","XX","XX","XX","XX","XX","XX" PIXEL SIZE 478,241
@ 100,006 FOLDER oFolder OF oDlgMain PROMPT "&Faturamento","Financeiro","Compras","Contabilidade","Fiscal","Ativo Fixo","Estoque"  PIXEL SIZE 478,241
//                                           01                 02         03          04           05          06        07    08                09                 10                11                   12

@ 005,005 TO 070, 220 PROMPT "Origem"             PIXEL OF oDlgMain 
@ 020,010 SAY "Empresa "                                     SIZE 040,10 PIXEL OF oDlgMain FONT oBold 
@ 019,040 MSGET oVar   VAR _cEmpOri Picture "@!"         SIZE 010,10 PIXEL OF oDlgMain F3 "SM0MRP" VALID(ValEmpDe( 1))
@ 019,065 MSGET oVar   VAR cDescEmpOri   Picture "@!"    SIZE 150,10 PIXEL OF oDlgMain When .F.

@ 041,010 SAY "Filial"                                   SIZE 040,10 PIXEL OF oDlgMain FONT oBold 
@ 040,029 MSGET oVar   VAR _cFilOri Picture "@!"         SIZE 030,10 PIXEL OF oDlgMain F3 "SM0"  VALID(ValEmpDe(2))
@ 040,065 MSGET oVar   VAR cDescFilOri      Picture "@!" SIZE 150,10 PIXEL OF oDlgMain When .F.


@ 005,245 TO 070, 485 PROMPT "Destino"               PIXEL OF oDlgMain
@ 020,250 SAY "Empresa"                                 SIZE 040,10 PIXEL OF oDlgMain FONT oBold 
@ 019,281 MSGET oVar   VAR _cEmpDes  Picture "@!"       SIZE 010,10 PIXEL OF oDlgMain F3 "SM0MRP" VALID(ValEmpPa( 1))
@ 019,310 MSGET oVar   VAR cDescEmpDes   Picture "@!"   SIZE 150,10 PIXEL OF oDlgMain When .F.

@ 041,250 SAY "Filial"                                  SIZE 070,10 PIXEL OF oDlgMain FONT oBold 
@ 040,271 MSGET oVar   VAR _cFilDes    Picture "@!"     SIZE 030,10 PIXEL OF oDlgMain F3 "SM0"  VALID(ValEmpPa(2))
@ 040,310 MSGET oVar   VAR cDescFilDes     Picture "@!" SIZE 150,10 PIXEL OF oDlgMain When .F.

// op��es para selecioar as tabelas para c�pia
//@ 005,005 TO 070, 220 PROMPT "*Marcar todas"        PIXEL OF oFolder:aDialogs[1] change(sfMkAll())

//@ 005,005 CHECKBOX oChFAT VAR lMarkTd PROMPT "Marcar/Desmarcar Todos" When .T. SIZE 200,017 PIXEL of oFolder:aDialogs[1] ON CHANGE sfMkAll(lMarkTd,1)
@ 005,005 BUTTON "&Marcar todos"        SIZE 50,12 PIXEL of oFolder:aDialogs[1] ACTION sfMkAll(.T., 1)
@ 005,075 BUTTON "&Desmarcar todos"     SIZE 60,12 PIXEL of oFolder:aDialogs[1] ACTION sfMkAll(.F., 1)

@ 030, 006 checkbox oChFAT var lChSBM size 100, 008 pixel of oFolder:aDialogs[1] prompt "SBM - Grupo Produtos" pixel  
@ 040, 006 checkbox oChFAT var lChSB1 size 100, 008 pixel of oFolder:aDialogs[1] prompt "SB1 - Produtos" pixel  
@ 050, 006 checkbox oChFAT var lChZ01 size 100, 008 pixel of oFolder:aDialogs[1] prompt "Z01 - Sub Grupo Produtos" pixel  
@ 060, 006 checkbox oChFAT var lChZ02 size 100, 008 pixel of oFolder:aDialogs[1] prompt "Z02 - Fam�lia" pixel  
@ 070, 006 checkbox oChFAT var lChSAH size 100, 008 pixel of oFolder:aDialogs[1] prompt "SAH - Unidade Medidas" pixel  
@ 080, 006 checkbox oChFAT var lChSE4 size 100, 008 pixel of oFolder:aDialogs[1] prompt "SE4 - Condi��o Pagamento" pixel  
@ 090, 006 checkbox oChFAT var lChSM4 size 100, 008 pixel of oFolder:aDialogs[1] prompt "SM4 - Formulas" pixel  
@ 100, 006 checkbox oChFAT var lChSA1 size 100, 008 pixel of oFolder:aDialogs[1] prompt "SA1 - Clientes" pixel  
@ 110, 006 checkbox oChFAT var lChSA3 size 100, 008 pixel of oFolder:aDialogs[1] prompt "SA3 - Vendedores" pixel  

@ 080,450 BUTTON "&Processar"   SIZE 40,16 PIXEL ACTION Processa({||fValida()})

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 02
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////       
@ 005,005 BUTTON "&Marcar todos"        SIZE 50,12 PIXEL of oFolder:aDialogs[2] ACTION sfMkAll(.T., 2)
@ 005,075 BUTTON "&Desmarcar todos"     SIZE 60,12 PIXEL of oFolder:aDialogs[2] ACTION sfMkAll(.F., 2)

@ 030, 006 checkbox oChFAT var lChSA6 size 100, 008 pixel of oFolder:aDialogs[2] prompt "SA6 - Bancos" pixel  
@ 040, 006 checkbox oChFAT var lChSED size 100, 008 pixel of oFolder:aDialogs[2] prompt "SED - Natureza Financeira" pixel  
@ 050, 006 checkbox oChFAT var lChZM9 size 100, 008 pixel of oFolder:aDialogs[2] prompt "ZM9 - Empresa Fluig" pixel  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 03
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@ 005,005 BUTTON "&Marcar todos"        SIZE 50,12 PIXEL of oFolder:aDialogs[3] ACTION sfMkAll(.T., 3)
@ 005,075 BUTTON "&Desmarcar todos"     SIZE 60,12 PIXEL of oFolder:aDialogs[3] ACTION sfMkAll(.F., 3)

@ 030, 006 checkbox oChFAT var lChSA2 size 100, 008 pixel of oFolder:aDialogs[3] prompt "SA2 - Fornecedores" pixel  
@ 040, 006 checkbox oChFAT var lChSY1 size 100, 008 pixel of oFolder:aDialogs[3] prompt "SY1 - Comprador" pixel  
@ 050, 006 checkbox oChFAT var lChSAL size 100, 008 pixel of oFolder:aDialogs[3] prompt "SAL - Alcadas" pixel  
@ 060, 006 checkbox oChFAT var lChDHL size 100, 008 pixel of oFolder:aDialogs[3] prompt "DHL - Perfil Aprovacao" pixel  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FOLDER 04
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@ 005,005 BUTTON "&Marcar todos"        SIZE 50,12 PIXEL of oFolder:aDialogs[4] ACTION sfMkAll(.T., 4)
@ 005,075 BUTTON "&Desmarcar todos"     SIZE 60,12 PIXEL of oFolder:aDialogs[4] ACTION sfMkAll(.F., 4)

@ 030, 006 checkbox oChFAT var lChCT1 size 100, 008 pixel of oFolder:aDialogs[4] prompt "CT1 - Plano de Contas" pixel  
@ 040, 006 checkbox oChFAT var lChCTD size 100, 008 pixel of oFolder:aDialogs[4] prompt "CTD - Item Cont�bil" pixel  
@ 050, 006 checkbox oChFAT var lChCTH size 100, 008 pixel of oFolder:aDialogs[4] prompt "CTH - Classe Valor" pixel  
@ 060, 006 checkbox oChFAT var lChCVD size 100, 008 pixel of oFolder:aDialogs[4] prompt "CVD - Plano Contas Referencial" pixel  
@ 070, 006 checkbox oChFAT var lChCVN size 100, 008 pixel of oFolder:aDialogs[4] prompt "CVN - Amarra��o Plano Contas referencial" pixel  
@ 080, 006 checkbox oChFAT var lChCT5 size 100, 008 pixel of oFolder:aDialogs[4] prompt "CT5 - Lan�amento Padr�o" pixel  
//@ 090, 006 checkbox oChFAT var lChFK3 size 100, 008 pixel of oFolder:aDialogs[4] prompt "FK3 - Produtos X Valores declarat�rios" pixel  
@ 090, 006 checkbox oChFAT var lChCVE size 100, 008 pixel of oFolder:aDialogs[4] prompt "CVE - Vis�o Gerencial" pixel  
@ 100, 006 checkbox oChFAT var lChCVF size 100, 008 pixel of oFolder:aDialogs[4] prompt "CVF - Vis�o Gerencial" pixel  
@ 110, 006 checkbox oChFAT var lChCTN size 100, 008 pixel of oFolder:aDialogs[4] prompt "CTN - Livro Cont�bil" pixel  
@ 120, 006 checkbox oChFAT var lChCTS size 100, 008 pixel of oFolder:aDialogs[4] prompt "CTS - Visoes Gerenciais" pixel  
@ 130, 006 checkbox oChFAT var lChCTT size 100, 008 pixel of oFolder:aDialogs[4] prompt "CTT - Centro de Custo" pixel  
// FOLDER 05
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@ 005,005 BUTTON "&Marcar todos"        SIZE 50,12 PIXEL of oFolder:aDialogs[5] ACTION sfMkAll(.T., 5)
@ 005,075 BUTTON "&Desmarcar todos"     SIZE 60,12 PIXEL of oFolder:aDialogs[5] ACTION sfMkAll(.F., 5)

@ 030, 006 checkbox oChFAT var lChSF4 size 100, 008 pixel of oFolder:aDialogs[5] prompt "SF4 - Tipos Entrada Saida" pixel  
@ 040, 006 checkbox oChFAT var lChSF7 size 100, 008 pixel of oFolder:aDialogs[5] prompt "SF7 - Excecao Fiscal" pixel  
@ 050, 006 checkbox oChFAT var lChSFM size 100, 008 pixel of oFolder:aDialogs[5] prompt "SFM - TES Inteligente" pixel  
@ 060, 006 checkbox oChFAT var lChF3K size 100, 008 pixel of oFolder:aDialogs[5] prompt "F3K - Produto X Cod Valores Declarat�rios" pixel  
@ 080,320 BUTTON "&Sair"        SIZE 40,16 PIXEL ACTION oDlgMain:End()

// FOLDER 06 - Ativo Fixo
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@ 005,005 BUTTON "&Marcar todos"        SIZE 50,12 PIXEL of oFolder:aDialogs[6] ACTION sfMkAll(.T., 6)
@ 005,075 BUTTON "&Desmarcar todos"     SIZE 60,12 PIXEL of oFolder:aDialogs[6] ACTION sfMkAll(.F., 6)

@ 030, 006 checkbox oChFAT var lChSNG size 100, 008 pixel of oFolder:aDialogs[6] prompt "SNG - Grupo Bens" pixel  
// FOLDER 07 - Estoque
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@ 005,005 BUTTON "&Marcar todos"        SIZE 50,12 PIXEL of oFolder:aDialogs[7] ACTION sfMkAll(.T., 7)
@ 005,075 BUTTON "&Desmarcar todos"     SIZE 60,12 PIXEL of oFolder:aDialogs[7] ACTION sfMkAll(.F., 7)

@ 030, 006 checkbox oChFAT var lChNNR size 100, 008 pixel of oFolder:aDialogs[7] prompt "NNR - Locais Estoque" pixel  


ACTIVATE MSDIALOG oDlgMain  CENTERED
cEmpAnt := _cEmpOld
RestArea(aArea)        

Return(.T.)

//----------------------------------------------------------
/*/{Protheus.doc} sfMkAll
Fun��o sfMkAll
@param lMark Recebo o lMark
@return N�o retorna nada
@author Reinaldo Dias
@owner Totvs S/A
@obs Marca todos os itens do folder
@history
04/10/2012 - Acrescimo de cabecalho Protheus.Doc
/*/
//----------------------------------------------------------
Static Function sfMkAll(lMark, nOpc)

if nOpc == 1 .or. nOpc == 0
   lChSBM := lMark
   lChSB1 := lMark
   lChZ01 := lMark 
   lChZ02 := lMark
   lChSAH := lMark
   lChSE4 := lMark 
   lChSM4 := lMark 
   lChSA1 := lMark 
   lChSA3 := lMark 
endif
if nOpc == 2 .or. nOpc == 0
   lChSA6 := lMark
   lChSED := lMark
   lChZM9 := lMark
endif

if nOpc ==3 .or. nOpc == 0
   lChSA2 := lMark
   lChSY1 := lMark
   lChSAL := lMark
   lChDHL := lMark
endif
if nOpc ==4 .or. nOpc == 0
   lChCT1 := lMark
   lChCTD := lMark
   lChCTH := lMark
   lChCVD := lMark
   lChCVN := lMark
   lChCT5 := lMark
   lChCVE := lMark
   lChCVF := lMark
   lChCTN := lMark
   lChCTS := lMark
   lChCTT := lMark
Endif
if nOpc ==5 .or. nOpc == 0
   lChSF4 := lMark
   lChSF7 := lMark
   lChSFM := lMark
   lChF3K := lMark
endif
if nOpc ==6 .or. nOpc == 0
   lChSNG := lMark
endif
if nOpc ==7 .or. nOpc == 0
   lChNNR := lMark
endif
Return

//----------------------------------------------------------
/*/{Protheus.doc} fValida
Fun��o fValida
@param N�o recebe par�metros
@return N�o retorna nada
@author Tiago Santos
@owner SMSTI
@obs Fun��o para validar os registros antes das c�pias
/*/
//----------------------------------------------------------
Static Function fValida()
Local aTabelas := {}
if _cEmpOri + _cFilOri == _cEmpDes + _cFilDes
   MsgStop("Empresa + Filial Origem iguais a Empresa Filial Destino !!!")
   return
Endif

// Se tabela selecionada, inclui no Array para processamento
aTabelas := retTabelas()
// definir a variavel de empresa e filial conforme sele��o na tela

if len(aTabelas) ==0
      MsgStop("N�o Foram selecionadas tabelas para C�pia !!!")
      return
endif

oProcess := MsNewProcess():New({|| fProcessa(oProcess, aTabelas)}, "Processando...", "Aguarde...", .T.)
oProcess:Activate()

Return

//----------------------------------------------------------
/*/{Protheus.doc} fProcessa
Fun��o fProcessa
@param N�o recebe par�metros
@return N�o retorna nada
@author Tiago Santos
@owner SMSTI
@obs Fun��o para validar os registros antes das c�pias
/*/
//----------------------------------------------------------
static function fProcessa(oOBj, aTab)
Local nAtual := 0
Local nTotal := 0
local nAtu2  := 0
Local nTot2  := 90

For nCont :=1 to len (aTab)

   // verificar se h� dados no destino

   if TrocaEmp(aTab[nCont])
  
   endif

Next nConta

return

//----------------------------------------------------------
/*/{Protheus.doc} TrocaEmp
Fun��o TrocaEmp
@param N�o recebe par�metros
@return Query da tabela selecionada
@author Tiago Santos
@owner SMSTI
@obs Query da tabela selecionada
/*/
//----------------------------------------------------------
static function TrocaEmp(cTab)
Local cFilBus := left(_cFilOri,4)
Local cFilDes := left(_cFilDes,4)
Local lRet := .T.
Local _nQtdReg :=0

// pegar o nome da tabela SX2 destino
cQuery := " Select *  From SX2" +_cEmpDes + "0 Where D_E_L_E_T_ =' '"
cQuery += " and  X2_CHAVE = '" +cTab + "' "
if select("QRX2") <> 0
   QRX2->( DBCLOSEAREA(  ))
Endif
TCQuery cQuery New Alias "QRX2"


// verificar se a table existe no banco
if QRX2->( !EOF())
   cQuery := "select table_name TN from ALL_TABLES where table_name = '" + alltrim(QRX2->X2_ARQUIVO) +"'"
   if select("QRALL") <> 0
      QRALL->( DBCLOSEAREA(  ))
   Endif
   TCQuery cQuery New Alias "QRALL"

   // verificar compartilhamento table
   if QRX2->X2_MODO == 'E'
      cFilBus :=_cFilOri
      cFilDes := _cFilDes
   Elseif QRX2->(X2_MODO + X2_MODO + X2_MODOEMP) =='CCC'
      cFilBus = Space(6)
      cFilDes = Space(6)
   Endif
   cFilWhere := iif(left(cTab,1)=="S", right(cTab,2),cTab) + '_FILIAL'   

   // buscar campos SX3 n�o virtuais
   cQuery := "Select X3_CAMPO, X3_TIPO from SX3"+_cEmpOri+"0 Where X3_ARQUIVO ='"+cTab+"' and D_E_L_E_T_ =' ' and X3_CONTEXT <> 'V' "
   cQuery += "and X3_CAMPO <>  '"+cFilWhere+"'  and X3_CAMPO NOT like ('%USERLG%')   Order by X3_ORDEM"
   if select("QX3") <> 0
      QX3->( DBCLOSEAREA(  ))
   Endif
   TCQuery cQuery New Alias "QX3"
   // for�a a mudan�a de empresas antes da fun��o EmpOpenFile
   if cEmpant == _cEmpDes
      cEmpant := '01'
   endif

   // buscar registros tabela origem
   //cQuery := "select * from " + alltrim(QRALL->TN )+ " Where "+cFilWhere +"='"+cFilBus+"' and D_E_L_E_T_ =' '"
   cQuery := "select * from " + cTab+ _cEmpOri+ "0 Where "+cFilWhere +"='"+cFilBus+"' and D_E_L_E_T_ =' '"
   if select("QOR") <> 0
      QOR->( DBCLOSEAREA(  ))
   Endif
   TCQuery cQuery New Alias "QOR"
   cModo :=""
   cCampo := ''
   cValor := ' '
   nTotal := 0
   Count To nTotal
   QOR->(DbGoTop())
   
   oprocess:IncRegua1("Tabela: "+cTab)
   oprocess:SetRegua2(nTotal)
   if cTab =='Z01'
     lTst :=  TST(cTab,cTab,1,.T.,_cEmpDes,@cModo)
   Endif
   if EmpOpenFile(cTab,cTab,1,.T.,_cEmpDes,@cModo)
      // se existir registros da filial destino, pergunta se deseja excluir antes da c�pia
      if (cTab)->(DbSeek(cFilDes))
         cMsg := "H� Dados na tabela " + cTab +" da empresa: "+ _cEmpDes
         cMsg += " Filial: "+ _cFilDes
         cMsg += '<br><br><font color="#ff0000"> Deseja Sobrepor os dados ?  </font> '
         if (ApMsgYesNo(cMsg, "Aten��o"))            
            //MsAguarde({|| DelReg(cTab, cFilWhere, cFilDes)}, "Aguarde...", "Deletando Registros "+cTab +" Emp: " + _cEmpDes +" Filial: "+_cFilDes)
             DelReg(cTab, cFilWhere, cFilDes,nTotal)
         else
            return
         Endif
      Endif
      nAtual :=0
      While QOR ->( ! EOF())
         nAtual++
         oProcess:IncRegua2("Copiando Registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) )
         Begin Transaction
            RecLock(cTab, .T.)	
               &(cTab+'->'+cFilWhere)     :=  cFilDes
                  QX3->( Dbgotop())
                  While QX3->(!EOF())   
                     //oprocess:IncRegua2("Campo: "+QX3->X3_CAMPO )  
                     if QX3->X3_TIPO =='D'
                        &(ctab+ '->'+QX3->X3_CAMPO)  :=  Stod(&('QOR->'+QX3->X3_CAMPO)   )                        
                     elseif QX3->X3_TIPO =='L'
                        &(ctab+ '->'+QX3->X3_CAMPO)  := iif(&('QOR->'+QX3->X3_CAMPO)=='T', .T., .F.)
                     elseif QX3->X3_TIPO <>'M'
                        &(ctab+ '->'+QX3->X3_CAMPO)  :=      &('QOR->'+QX3->X3_CAMPO)    
                     Endif                     
                     QX3->( DbSkip())
                  Enddo                        
            (cTab)->( MsUnLock())         
         End Transaction
         QOR->( DbSkip())
      Enddo 
   Endif
else
   cMsg := '<br><br><font color="#ff0000"> Tabela: '+cTab+' nao criada na empresa: '+_cEmpDes+'   </font> '
   MSGALERT( cMsg, 'Atencao'  )
   lRet := .F.
Endif

Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} fDigSenha
Fun��o fDigSenha
@param N�o recebe par�metros
@return N�o retorna nada
@author Reinaldo Dias
@owner Totvs S/A
@obs Funcao para solicitar a senha para acessar a rotina de analise.
@history
04/10/2012 - Acrescimo de cabecalho Protheus.Doc
/*/
//----------------------------------------------------------
Static Function fDigSenha()
Private cSenha   := Space(20)         
Private cSenhAce := "cpd**%$#@!**"
@ 067,020 To 169,312 Dialog Senhadlg Title OemToAnsi("Libera��o de Acesso")
@ 015,005 Say OemToAnsi("Informe a senha para o acesso ?") Size 80,8
@ 015,089 Get cSenha Size 50,20 Password
@ 037,106 BmpButton Type 1 Action fOK()
@ 037,055 BmpButton Type 2 Action Close(Senhadlg)
Activate Dialog Senhadlg CENTERED
Return(_lReturn)                     

//----------------------------------------------------------
/*/{Protheus.doc} fOK
Fun��o fOK
@param N�o recebe par�metros
@return N�o retorna nada
@author Reinaldo Dias
@owner Totvs S/A
@obs Funcao para validar a senha digitada
@history
04/10/2012 - Acrescimo de cabecalho Protheus.Doc
/*/
//----------------------------------------------------------
Static Function fOK()

If ALLTRIM(cSenha)<> cSenhAce
   MsgStop("Senha n�o Confere !!!")
   cSenha  := Space(20)
   dlgRefresh(Senhadlg)
Else
   _lReturn  := .T.
   Close(Senhadlg)
Endif
Return

/*
Valida��o empresa / Filial
*/
static Function ValEmpDe(nOp)
Local lRet := .T.
SM0->( Dbgotop())

cBusca := iif (nOp ==1, _cEmpOri, _cEmpOri + _cFilOri)

if SM0->( dbSeek(cBusca))
   cDescEmpOri:=Alltrim(SM0->M0_NOME)
   cDescFilOri:= iif (EMPTY( _cFilOri ), " ",   Alltrim(SM0->M0_FILIAL))
   cEmpAnt := _cEmpOri
else   
   lRet := .F.
endif
return lRet


/*
Valida��o empresa / Filial
*/
static Function ValEmpPa(nOp)
Local lRet := .T.
SM0->( Dbgotop())

cBusca := iif (nOp ==1, _cEmpDes, _cEmpDes + _cFilDes)

if SM0->( dbSeek(cBusca))
   cDescEmpDes:=Alltrim(SM0->M0_NOME)
   cDescFilDes:= iif (EMPTY( _cFilDes ), " ",   Alltrim(SM0->M0_FILIAL))
   cEmpAnt := _cEmpDes
else   
   lRet := .F.
endif
return lRet


static function retTabelas ()
atabelas := {}
if lChSBM
	aadd(atabelas,'SBM')
Endif 
if lChSB1
	aadd(atabelas,'SB1')
Endif
if lChZ01
	aadd(atabelas,'Z01')
Endif
if lChZ02
	aadd(atabelas,'Z02')
Endif
if lChSAH
	aadd(atabelas,'SAH')
Endif
if lChSE4
	aadd(atabelas,'SE4')
Endif
if lChSM4
	aadd(atabelas,'SM4')
Endif
if lChSA1
	aadd(atabelas,'SA1')
Endif
if lChSA3
	aadd(atabelas,'SA3')
Endif
if lChSED
	aadd(atabelas,'SED')
endif
if lChZM9
	aadd(atabelas,'ZM9')
endif
if lChSA2
	aadd(atabelas,'SA2')
endif
if lChCT1
	aadd(atabelas,'CT1')
endif
if lChCTD
	aadd(atabelas,'CTD')
endif
if lChCTH
	aadd(atabelas,'CTH')
endif
if lChCVD
	aadd(atabelas,'CVD')
endif
if lChCVN
	aadd(atabelas,'CVN')
endif
if lChCT5
	aadd(atabelas,'CT5')
endif
if lChCTS
	aadd(atabelas,'CTS')
endif
if lChCTT
	aadd(atabelas,'CTT')
endif
if lChCVE
	aadd(atabelas,'CVE')
endif
if lChCVF
	aadd(atabelas,'CVF')
endif
if lChCTN
	aadd(atabelas,'CTN')
endif
if lChSAL
	aadd(atabelas,'SAL')
endif
if lChDHL
	aadd(atabelas,'DHL')
endif
if lChSY1
	aadd(atabelas,'SY1')
endif
if lChSF4
	aadd(atabelas,'SF4')
endif
if lChSF7
	aadd(atabelas,'SF7')
endif
if lChSFM
	aadd(atabelas,'SFM')
endif
if lChF3K
	aadd(atabelas,'F3K')
endif
if lChSA6
	aadd(atabelas,'SA6')
endif
if lChSNG
	aadd(atabelas,'SNG')
endif
if lChNNR
	aadd(atabelas,'NNR')
endif

Return atabelas




static function DelReg (cTab, cFilWhere, cFilDel,nTotal)
local aArea := (cTab)->(GetArea())
Local nAtual :=0
cFilDel := cFilDel + Space(tamsx3("A2_FILIAL")[1] - len(cFilDel)) 

(cTab)->(DBGOTOP(  ))
if (cTab)->(DbSeek(cFilDel))
   While (cTab)->( !EOF()) .and. &(ctab+ '->'+cFilWhere) == cFilDel
      nAtual += 1
      oProcess:IncRegua2("Deletando Registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) )
      RecLock(cTab, .F.)
         DBDelete()
      (cTab)->(MSUNLOCK())
      (cTab)->(DbSkip())
   Enddo
Endif

(cTab)->(RestArea(aArea))
Return


static function TST(cExp1,cExp2,nExp3,lExp4,cExp5,cExp6)
//TST(cTab,cTab,1,.T.,_cEmpDes,@cModo)
//https://terminaldeinformacao.com/knowledgebase/opensxs/
Local cSX2 := "SX2", cAlias := Alias(), nRegX2
Local lRet := .t.

DEFAULT lExp4 := .T.
DEFAULT cExp5 := cEmpAnt
DEFAULT nExp3 := 1

IF Select(cExp1) > 0
	dbSelectArea(cExp1)
	dbCloseArea()
Endif

IF lExp4
  IF cExp5 != cEmpAnt
	 OpenSXs( , , , ,cExp5,"SX2TMP")
	 cSX2 := "SX2TMP"
  Endif
  dbSelectArea(cSX2)
  nRegX2 := Recno()
  dbSeek(cExp2)
  cExp6 := (cSX2)->X2_MODO
  IF ( lRet := ChkFile(cExp2,.f.,cExp1,,,,,cSX2,.F.) )
  	dbSelectArea(cExp1)
	dbSetOrder(nExp3)
  EndIF	
  (cSX2)->(dbGoto(nRegX2))
  IF cSX2 == "SX2TMP"
  	dbSelectArea("SX2TMP")
  	dbCloseArea()
  Endif
Endif

IF !empty(cAlias) .and. Select(cAlias) > 0
	dbSelectArea(cAlias)
Endif

Return lRet
