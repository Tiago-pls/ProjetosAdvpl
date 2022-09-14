#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"    

/*/
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RATEIOCTQ   º Autor ³ SIDNEY GAMA        º Data ³  24/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ LIQUIDI CAIXA BANCO FERIAS                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
/*/
User Function RelCTQ
local lExcel := .F.

lExcel := MSGYESNO( 'Deseja imprimir em excel', 'Relatorio' )

if lExcel
   RatOffLine()
else
   RatFol()
Endif
RETURN

static Function RatFol()
Local cDesc1  := "Cadastro de Rateios para apura??o cont?bil"
Local cDesc2  := "Sera  impresso de acordo com os parametros solicitados pelo"
Local cDesc3  := "usuario."
Local cPict   := ""
Local nLin    := 80
Local Cabec1  := "                                                   Situac        *--- Periodo  ---*  *--- Dias ---*   *----- Historico -----*"
Local Cabec2  := "Matric  Nome                                      Periodo          Inicio   Termino  Dir Conc Saldo   Concessao Gozo Abomo   "
Local imprime := .T.
Local cString := "CTQ"        // alias do arquivo principal (Base)
Local aOrd    := {"Rareio"}//
Private limite     := 120
Private lEnd       := .F.
Private lAbortPrint:= .F.
Private CbTxt      := ""
Private tamanho    := "M"
Private nomeprog   := "RATEIOCTQ" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo      := 15
Private aReturn    := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "RATEIOCTQ" // Coloque aqui o nome do arquivo usado para impressao em disco
Private aReturn    := {"Zebrado",1,"Administracao",2,2,1,"",1 }   //,
Private NomeProg   := "RATEIOCTQ"
Private aLinha     := { }
Private nLastKey   := 0
Private cPerg      := "RATEIOCTQ"
Private cIndCond

Private Titulo   := "Geracao Relatorio Rateio Nfe"
Private AT_PRG   := "RATEIOCTQ"
Private Wcabec0  := 2
Private Wcabec1  := "                                                   Situac        *--- Periodo  ---*  *--- Dias ---*   *----- Historico -----*"
Private Wcabec2  := "Matric  Nome                                      Periodo          Inicio   Termino  Dir Conc Saldo   Concessao Gozo Abomo   "
Private CONTFL   := 1
Private LI       := 0

cPerg := PadR(cPerg,10)
VldPerg(cPerg)
Pergunte(cPerg,.F.)

wnrel:="RATEIOCTQ"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho)

If nLastKey = 27
   Return
Endif
SetDefault(aReturn,cString)
If nLastKey = 27
   Return
Endif
nTipo := If(aReturn[4]==1,15,18)
RptStatus({|lEnd| RATEIOCTQImp(@lEnd,wnRel,cString)},Titulo)
Return              

Static Function RATEIOCTQImp(lEnd,WnRel,cString)
//ÿÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais (Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÿ
Local FimPAqui    := ""
Local DFimPAqui   := ""
Local DPRPAqui    := ""
Local cAcessaSRA  := &("{ || " + ChkRH("GPER400","SRA","2") + "}")
Local lTemPendente

//ÿÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Private(Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÿ
Private Normal    := 0
Private Descanso  := 0
Private cPerFeAc  := GetNewPar("MV_FERPAC", "N") // Ferias por ano civil

//ÿÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÿ
nOrdem     := aReturn[8]
cFilDe     := mv_par01                          //  Filial De
cFilAte    := mv_par02                          //  Filial Ate
cCcDe      := mv_par03                          //  Centro de Custo De
cCcAte     := mv_par04                          //  Centro de Custo Ate

_cQuery := Query()

_cQuery += "   ORDER BY CTQ_FILIAL, CTQ_RATEIO, CTQ_SEQUEN "

TcQUERY _cQuery NEW ALIAS "TSRA"

Cabec1 := "Filial  Rateio    Descri??o                             Tipo                  Perc. Base     Bloqueado"
//         0.........1.........2.........3.........4.........5.........6.........7.........8.........9.........0.........1.........2.........3
nLin := 80                                                                                                        
nTotGer := 0   
nTotBan := 0   
nOrdImp := 1
TSRA->(dbgotop())
cChave := " "

cLinha:="__________________________________________________________________________________________________________________________________"

cCabec2:="Seq   Conta Origem          C.Custo Origem                  Conta Para          C.Custo Para                   Percentual"
While !TSRA->(EOF())
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   
   If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,"",NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif
   If TSRA->( CTQ_FILIAL + CTQ_RATEIO) <> cChave // Salto de Página. Neste caso o formulario tem 55 linhas...
      if ! Empty(cChave)
         nLin++    
         @nLin,002 PSAY cLinha   
         nLin := nLin + 3
      Endif      

      cTipo := Iif(TSRA->CTQ_TIPO =='1', "Movimento Mes","Movimento Acumulado")
      cBloqueio := Iif(TSRA->CTQ_STATUS =='1', "Ativo","Bloqueado")
      @nLin,002 PSAY Alltrim(TSRA->CTQ_FILIAL)
      @nLin,008 PSAY Alltrim(TSRA->CTQ_RATEIO)
      @nLin,018 PSAY Alltrim(TSRA->CTQ_DESC)
      @nLin,053 PSAY Alltrim(cTipo)
      @nLin,080 PSAY TSRA->CTQ_PERBAS
      @nLin,095 PSAY Alltrim(cBloqueio)  
      

      nLin := nLin + 2
      // Imprimir Cabe?alho2   
      @nLin,002 PSAY cCabec2 
      
   Endif

   nLin++  
   
   @nLin,002 PSAY Alltrim(TSRA->CTQ_SEQUEN)
   @nLin,008 PSAY Alltrim(TSRA->CTQ_CTORI)

   @nLin,023 PSAY Alltrim(TSRA->CTQ_CCORI)  
   CTT->( dbseek( xFilial(TSRA->CTQ_FILIAL) + TSRA->CTQ_CCORI)) 
   @nLin,041 PSAY substr(CTT->CTT_DESC01,1,15)

   @nLin,061 PSAY Alltrim(TSRA->CTQ_CTPAR)
   
   @nLin,073 PSAY Alltrim(TSRA->CTQ_CCPAR)
   CTT->( dbseek( xFilial(TSRA->CTQ_FILIAL) + TSRA->CTQ_CCPAR)) 
   @nLin,88 PSAY substr(CTT->CTT_DESC01,1,15)

   @nLin,120 PSAY TSRA->CTQ_PERCEN
   
  
   cChave:= TSRA->( CTQ_FILIAL + CTQ_RATEIO)
   TSRA->(dbskip())
Enddo

nLin++      

nLin++ 
nLin++      

dbSelectArea("TSRA")
dbcloseArea("TSRA")

SET DEVICE TO SCREEN
If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif
MS_FLUSH()
Return


/*/{Protheus.doc} RatOffLine
//TODO Funcao gerar relatorio excel
@author Tiago Santos
@since 23/03/2020
@type function
justes para gera??o na vers?o 12.1.25
/*/


static function RatOffLine
Local cTitle    := OemToAnsi("Geracao Relatorio Rateio Nfe")
Local cHelp     := OemToAnsi("Geracao Relatorio Rateio Nfe")
Local aOrdem 	:= {"Rateio"}//
Local oRel
Local oDados
Private cPerg      := "RATEIOCTQ"

If !Pergunte(cPerg,.T.)
   Return
Endif                                                       


//T?tulo do relat?rio no cabe?alho
cTitle := OemToAnsi("Geracao Relatorio Rateio Nfe")

//Criacao do componente de impress?o
oRel := tReport():New("Geracao Relatorio Rateio Nfe",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)

//Seta a orienta??o do papel
oRel:SetLandscape()

//Seta impress?o em planilha                      
oRel:SetDevice(4)                       

//Inicia a Sess?o
oDados := trSection():New(oRel,cTitle,{"CTQ","CTT"},aOrdem)
//oDados:SetHeaderSection(.F.)    
//oDados:HeaderBreak()     
oDados:SetHeaderBreak()

// Celulas comuns a todos os tipos de relat?rios
trCell():New(oDados,"CTQ_FILIAL"   ,"QRY" ,"Filial"   	 ,"@!",02)
trCell():New(oDados,"CTQ_RATEIO"	  ,"QRY" ,"Rateio"   	 ,"@!",06)
trCell():New(oDados,"CTQ_DESC" 	  ,"QRY" ,"Descricao"    ,"@!",30)
trCell():New(oDados,"CTQ_STATUS"   ,"QRY" ,"Status"  	    ,"@!",06)
trCell():New(oDados,"CTQ_PERBAS"   ,"QRY" ,"Perc"     	 ,"@!",09)
trCell():New(oDados,"CTQ_SEQUEN"   ,"QRY" ,"Seq"          ,"@!",10)
trCell():New(oDados,"CTQ_CTORI" 	  ,"QRY" ,"Conta Ori" 	 ,"@!",10)
trCell():New(oDados,"CONTAORI"     ,"QRY" ,"Desc Conta"   ,"@!",30) 
trCell():New(oDados,"CTQ_CCORI"    ,"QRY" ,"C.Custo Ori"  ,"@!",09) 
trCell():New(oDados,"CCUSTOORI"    ,"QRY" ,"C.Custo"      ,"@!",06) 
trCell():New(oDados,"CTQ_CTCPAR"	  ,"QRY" ,"Conta Para"	 ,"@!",08)
trCell():New(oDados,"CONTAPAR"     ,"QRY" ,"Desc Conta"   ,"@!",30) 
trCell():New(oDados,"CTQ_CCCPAR"	  ,"QRY" ,"C.Custo Para" ,"@!",09)
trCell():New(oDados,"CCUSTOPAR"    ,"QRY" ,"C.Custo"      ,"@!",06) 
trCell():New(oDados,"CTQ_PERCEN"	  ,"QRY" ,"Percentual"   ,"@!",07)
trCell():New(oDados,"TOTAL"	     ,"QRY" ,"Custo Total"	,"@E 999,999,999.99",6)
trCell():New(oDados,"CUSTORATEADO" ,"QRY" ,"Custo Rateado"	,"@E 999,999,999.99",6)                                     	
//Executa o relat?rio
oRel:PrintDialog()

Return

/*-----------------+---------------------------------------------------------+
!Nome              ! ReportPrint                                             !
+------------------+---------------------------------------------------------+
!Descri??o         ! Processamento dos dados e impressao do relat?rio        !
+------------------+---------------------------------------------------------+
!Autor             ! Lucilene Mendes	                                     !
+------------------+--------------------------------------------------------*/
Static Function ReportPrint(oRel)

Local oDados  	:= oRel:Section(1)
Local nOrdem  	:= oDados:GetOrder()
Local dDataDe	:= ""
Local dDataAte	:= ""
Local cTes		:= ""
Local cNotIn	:= "" 

oDados:Init()

//Seleciona os registros
//********************************************************************************
If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif

_cQuery := Query()

TcQuery _cQuery New Alias "QRY"
//ShellExecute( "Open","C:\TEMP\TESTE.DOC","","C:\TEMP\", 1 )

If QRY->(!Eof())
	While QRY->(!Eof()) .and. !oRel:Cancel()  
	    	
		//Cancelado pelo usu?rio
		If oRel:Cancel()
			Exit
		EndIf
		
		oRel:IncMeter(10)        
        
      oDados:Cell("CONTAPAR"):SetValue(alltrim(  POSICIONE("CT1",1,XFILIAL("CT1")+QRY->CTQ_CTCPAR,"CT1_DESC01")))  
      oDados:Cell("CONTAORI"):SetValue(alltrim(  POSICIONE("CT1",1,XFILIAL("CT1")+QRY->CTQ_CTORI,"CT1_DESC01")))        
      oDados:Cell("CCUSTOORI"):SetValue(alltrim(  POSICIONE("CTT",1,XFILIAL("CTT")+QRY->CTQ_CCORI,"CTT_DESC01")))  
      oDados:Cell("CCUSTOPAR"):SetValue(alltrim(  POSICIONE("CTT",1,XFILIAL("CTT")+QRY->CTQ_CCCPAR,"CTT_DESC01")))  
      oDados:Cell("CUSTORATEADO"):SetValue(QRY->TOTAL * (CTQ_PERCEN /100)) 


	   oDados:PrintLine()
	   oDados:SetHeaderSection(.F.)    
		QRY->(dbSkip())
		
	End
Else
	MsgInfo("N?o foram encontrados registros para os par?metros informados!")
    Return .F.
Endif

oDados:Finish()

Return



Static Function VldPerg(cPerg)
   _sAlias := Alias()
   dbSelectArea("SX1")
   dbSetOrder(1)
   If !dbSeek(cPerg+"01")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='01'
   sx1->x1_pergunt:='Filial de'
   sx1->x1_variavl:='mv_ch1'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=2
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par01'
   sx1->x1_f3     :='XM0'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"02")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='02'
   sx1->x1_pergunt:='Filial Até'
   sx1->x1_variavl:='mv_ch2'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=2
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par02'
   sx1->x1_f3     :='XM0'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"03")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='03'
   sx1->x1_pergunt:='Rateio De'
   sx1->x1_variavl:='mv_ch3'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=6
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par03'
   sx1->x1_f3     :='CTQ'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"04")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='04'
   sx1->x1_pergunt:='Rateio Ate'
   sx1->x1_variavl:='mv_ch4'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=6
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par04'
   sx1->x1_f3     :='CTQ'
   sx1->(MsUnlock())
   
   If !dbSeek(cPerg+"05")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='05'
   sx1->x1_pergunt:='Data'
   sx1->x1_variavl:='mv_ch5'
   sx1->x1_tipo   :='D'
   sx1->x1_tamanho:=8
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par05'
   sx1->x1_f3     :=''
   sx1->(MsUnlock())

   dbSelectArea(_sAlias)
Return

Static Function Query()

_cQuery := "with "
_cQuery += "CTQ as ("
_cQuery += "select * from " + RetSqlName("CTQ") + " CTQ"
_cQuery += " Where CTQ.D_E_L_E_T_ =' ' "
_cQuery += " and CTQ_FILIAL between '" + MV_PAR01+"' and '" + MV_PAR02+"' "
_cQuery += " and CTQ_RATEIO between '" + MV_PAR03+"' and '" + MV_PAR04+"' "
_cQuery += " ), CQ2 as("
_cQuery += " select CQ2_CONTA, CQ2_CCUSTO, Round(CQ2_DEBITO - CQ2_CREDIT,2) TOTAL from " + RetSqlName("CQ2") + " CQ2 "
_cQuery += " where CQ2_DATA ='" + DtoS(MV_PAR05) +"' "
_cQuery += ")"
_cQuery += " select * from CTQ"
_cQuery += " inner join CQ2 on CTQ_CTORI = CQ2_CONTA and CTQ_CCORI = CQ2_CCUSTO  "
_cQuery += "   ORDER BY CTQ_FILIAL, CTQ_RATEIO, CTQ_SEQUEN "

Return _cQuery