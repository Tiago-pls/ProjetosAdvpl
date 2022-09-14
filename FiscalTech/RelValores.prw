#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  CustoFun   - Autor - Tiago Santos      - Data -06.04.22 ---
--+----------+---------------------------------------------------------------
---Descri--o -  Relatorio Gerencial Folha de Pagamento         		      ---
--+-----------------------------------------------------------------------+--
--- Flexibilização das verbas para inclusão no relatório   13/04/2022     ---
--- Inclusão de novos campos CTT_DESC01, CTD_DESC01, RJ_DESC              ---
--- Impressão dos valores com a folha aberta ou fechada                   ---
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/

User Function CustoFun
                      
Private cPerg 	:= "" 
Private cLFRC	:= chr(13)+chr(10)
dbSelectArea("SX1")  
dbSetOrder(1)
cPerg := "CUSTOFUN" +Replicate(" ",Len(X1_GRUPO)- Len("CUSTOFUN"))

//Carrega os Par-metros
//********************************************************************************
GeraPerg(cPerg)
  
If !Pergunte(cPerg,.T.)
   Return
Endif  

MsAguarde({|| GeraRel()}, "Aguarde...", "Gerando Registros...")
Return

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  GeraRel    - Autor - Tiago Santos        - Data -06.04.22 ---
--+----------+---------------------------------------------------------------
---Descri--o -  Gera o Relat-io                              		      ---
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/

static function GeraRel()
Local cTitle    := OemToAnsi("Relat-rio Conferencia ")
Local cHelp     := OemToAnsi("Relat-rio Conferencia ")   
Local aOrdem 	:= {}                
Local oRel
Local oDados             

//T-tulo do relat-rio no cabe-alho
cTitle := OemToAnsi("Relatorio Custo Funcionario")

//Criacao do componente de impress-o
oRel := tReport():New("Custo Funcionario",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)

//Seta a orienta--o do papel
oRel:SetLandscape()

//Seta impress-o em planilha                      
oRel:SetDevice(4)    

//Inicia a Sess-o
oDados := trSection():New(oRel,cTitle,{"SRA","SRJ","SQB"},aOrdem)
//oDados:SetHeaderSection(.F.)    
//oDados:HeaderBreak()     
oDados:SetHeaderBreak() 

// Defini--o das colunas a serem impressas no relat-rio


cTab := RetFol()
cPre := right(cTab,2)

trCell():New(oDados, cPre+"_FILIAL"               ,"QRY" ,   ,"@!",06)
trCell():New(oDados, cPre+"_MAT" 	              ,"QRY" ,   ,"@!",06)
trCell():New(oDados, "RA_NOME" 	                  ,"QRY" ,   ,"@!",30)
trCell():New(oDados, "RA_ADMISSA"                 ,"QRY" ,   ,"@!",15)
trCell():New(oDados, "RJ_DESC" 	                  ,"QRY" , "Funcao"  ,"@!",30)
trCell():New(oDados, cPre+"_PERIODO" 	          ,"QRY" ,   ,"@!",06)
trCell():New(oDados, cPre+"_CC" 	              ,"QRY" ,   ,"@!",09)
trCell():New(oDados,"CTT_DESC01" 	              ,"QRY" , "Desc Centro Custo"  ,"@!",09)
trCell():New(oDados, cPre+"_ITEM" 	              ,"QRY" ,   ,"@!",09)
trCell():New(oDados, "CTD_DESC01" 	              ,"QRY" , "Desc Item" ,"@!",30)

trCell():New(oDados,"V_051_DSRSOBREMEDIASABO  ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_052_DSRSOBREMEDIASABO  ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_096_HE50NOT            ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_099_HE150NOT           ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_101_SALARIOMENSAL      ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_107_ESTAGIARIO         ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_108_HE50               ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_109_HE100              ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_113_HEXTRA150          ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_117_ADICNOT            ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_118_DSRSHEAN           ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_119_ANUENIO            ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_121_HORAEXTRA90        ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_124_SALARIOFAMILIA     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_126_SALARIOMATERNIDADE ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_128_COMPLAUXDOENCA     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_129_AUXILIOACIDENTE    ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_136_INSUFSALDOSALARIO  ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_140_SALDODESALARIO     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_144_1PARCELA13SAL      ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_149_COMPLEMENTOSALARIO ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_155_ABONODEFERIAS      ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_156_13ABONOPECUNIARIO  ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_157_FERIASEMDOBRO      ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_158_13FERIASEMDOBRO    ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_159_FERIAS             ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_160_FERIASMS           ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_161_13FERIAS           ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_162_13FERIASMS         ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_163_MEDIAFERIASVLR     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_164_MEDIAFERIASVLRMS   ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_165_MEDSHEXTRAS        ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_166_MEDSHEXTRASMS      ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_169_DSRSMEDFERIAS      ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_170_DSRSMEDFERIASMS    ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_171_FERIASVENCIDAS     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_172_FERIASPROPORCIONAIS","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_173_13FERIASQUITACAO   ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_178_DIFSFERIAS         ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_180_DIF13FERIAS        ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_181_DIF13FERIASMS      ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_182_DIFABONOPECUNIARIO ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_183_DIF13ABONOPECUNI   ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_184_DIFMEDHEFERIAS     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_188_DIFDSRFERIAS       ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_190_ARREDFERIAS        ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_195_AVISOPREVIOINDENIZ ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_197_PGTOMULTAEXPER     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_205_13SALARIORESCISAO  ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_207_13SAVISOPREVIO     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_218_REEMBOLSO          ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_252_DIFMEDFERVLR       ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_253_DIFMEDFERVLRMS     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_254_13FERIASPROPRES    ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_269_FERIASSAVINDENIZA  ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_270_13FERSAVINDENIZ    ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_275_ABONODEFERIASMS    ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_276_13ABONOPECUNMS     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_279_MEDHORASSABONO     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_280_MEDVALORSABONO     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_281_MEDHORASABONOMS    ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_282_MEDVLRSABONOMS     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_283_SOBREAVISO         ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_301_ABONOSPAGOSMESANT  ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_305_GRATIFICACAOFUNCAO ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_324_PROVENTOPONTOMES   ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_336_MEDFERVENRES       ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_336_MEDFERVENRESC      ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_337_MEDFERPROPRES      ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_337_MEDFERPROPRESC     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_338_MEDAVISOPREVIORES  ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_339_MED13ºSALRESC      ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_339_MED13ºSALRES       ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_340_MEDFERSAVPRERES    ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_341_MED13SAAVINRESC    ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_399_ARREDONDAMENTO     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_401_INSSSALARIO        ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_403_INSSFERIAS         ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_405_INSS13SALARIO      ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_407_IMPRENDAFONTE      ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_409_IRFERIAS           ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_412_DESCREEMBDESPESAS  ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_414_INSSFERIASMS       ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_420_CONTRIBASSISTENC   ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_425_FALTAINTEGRAL      ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_426_ATRASOS            ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_428_SAIDAANTECIPADA    ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_430_ARREDONDAMENTO     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_431_INSUFSALDOSALARIO  ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_433_VALEREFEICAO       ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_435_VALETRANSPORTE     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_440_PENSAOALIMENTICIA  ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_455_PENSAO2DEP         ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_457_DESCDSRFALTA       ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_458_SAIDAANTECIPADA    ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_460_LIQUIDOPAGOFERIAS  ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_462_ADIANTFERIAS       ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_465_VALEALIMENTACAO    ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_470_AVISOPREVIODESCONT ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_472_DESCMULTACONTEXP   ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_476_LIQUIDONARESCISAO  ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_502_PLANOODONTO        ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_504_PLANOODONTODEP     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_604_PLANOMEDICO        ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_605_PLANOMEDICODEP     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_606_COPARTICIPACAO     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_905_EMPRESTCONITAU     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_951_MULTADETRANSITO    ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_988_PLR                ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_991_ADNOTCWB           ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_996_ADNOTCWB           ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"V_999_BASEVALEREFEIC     ","QRY" ,  ,"@E 999,999,999.99",17)
//Executa o relatorio
oRel:PrintDialog()

Return

/*-----------------+---------------------------------------------------------+
!Nome              ! ReportPrint                                             !
+------------------+---------------------------------------------------------+
!Descri--o         ! Processamento dos dados e impressao do relat-rio        !
+------------------+---------------------------------------------------------+
!Autor             ! Lucilene Mendes	                                     !
+------------------+--------------------------------------------------------*/
Static Function ReportPrint(oRel)

Local oDados  	:= oRel:Section(1)
Local nOrdem  	:= oDados:GetOrder()

oDados:Init()

//Seleciona os registros
//********************************************************************************
If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif
cQry := MontaQry()
TcQuery cQry New Alias "QRY"                          

TCSetField("QRY","RA_ADMISSA","D",8,0)  
nCont := 0
If QRY->(!Eof())
	While QRY->(!Eof()) .and. !oRel:Cancel() 
  		ProcRegua(10)
  		nCont ++
		 MsProcTxt("Analisando registro " )		 
		//Cancelado pelo usuario
		If oRel:Cancel()
			Exit
		EndIf   		
  		oRel:IncMeter(10)
  		oDados:PrintLine()
        oDados:SetHeaderSection(.F.)   	
	QRY->(dbSkip())						
	Enddo	
Else		
	MsgInfo("Nao foram encontrados registros para os parametros informados!")
    Return .F.
Endif
		
Return

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  GeraPerg     - Autor - Tiago Santos      - Data -18.09.19 ---
--+----------+---------------------------------------------------------------
---Descri--o -  Atualiza SX1                                		      ---
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/

Static Function GeraPerg(cPerg) 
Local aRegs:= {}

aAdd(aRegs,{cPerg,"01","Filial"         ,"Filial De"        ,"Filial De"       ,"mv_ch1","C",04,0,0,"G"," "           ,"mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"02","Filial Ate"     ,"Filial Ate"       ,"Filial Ate"      ,"mv_ch2","C",04,0,0,"G","naovazio()"  ,"mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"03","Centro Custo"   ,"Centro Custo De"  ,"Centro Custo De" ,"mv_ch5","C",09,0,0,"G"," "           ,"mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"04","Centro Ate"     ,"Centro Custo Ate" ,"Centro Custo Ate","mv_ch6","C",09,0,0,"G","naovazio()"  ,"mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"05","Item"           ,"Item De"          ,"Item De"         ,"mv_ch5","C",09,0,0,"G"," "           ,"mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTD","",""})
aAdd(aRegs,{cPerg,"06","Item Ate"       ,"Item Ate"         ,"Item Ate"        ,"mv_ch6","C",09,0,0,"G" ,"naovazio()" ,"mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTD","",""})
aAdd(aRegs,{cPerg,"07","Matricula"      ,"Matricula De"     ,"Matricula De"    ,"mv_ch7","C",06,0,0,"G"," "           ,"mv_par07","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"08","Matricula Ate"  ,"Matricula Ate"    ,"Matricula Ate"   ,"mv_ch8","C",06,0,0,"G","naovazio()"  ,"mv_par08","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"09","Competencia de" ,"Competencia"      ,"Competencia"     ,"mv_ch9","C",06,0,0,"G","naovazio()"  ,"mv_par09","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Competencia Ate","Competencia"      ,"Competencia"     ,"mv_chA","C",06,0,0,"G","naovazio()"  ,"mv_par10","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})

U_BuscaPerg(aRegs)

Return

// fun--o para retornar a query conforme tipo do relat-rio selecionado
static Function MontaQry ()                                   
Local cQuery := " " 
Local nCont :=0
Local aVerbas1 := strtokarr (GetMV("FT_VBREL01"), ",") 
Local aVerbas2 := strtokarr (GetMV("FT_VBREL02"), ",") 

cTab := RetFol()
cPre := right(cTab,2)

cQuery += " SELECT " + cPre+"_FILIAL, " + cPre+"_MAT, RA_NOME, " + cPre+"_PERIODO, " + cPre+"_CC, " + cPre+"_ITEM, RA_ADMISSA, RJ_DESC, CTT_DESC01,CTD_DESC01,"    + cLFRC
cQuery += " [051] as V_051_DSRSOBREMEDIASABO,  "    + cLFRC
cQuery += " [052] as V_052_DSRSOBREMEDIASABO,  "    + cLFRC
cQuery += " [096] as V_096_HE50NOT,            "    + cLFRC
cQuery += " [099] as V_099_HE150NOT,           "    + cLFRC
cQuery += " [101] as V_101_SALARIOMENSAL,      "    + cLFRC
cQuery += " [107] as V_107_ESTAGIARIO,         "    + cLFRC
cQuery += " [108] as V_108_HE50,               "    + cLFRC
cQuery += " [109] as V_109_HE100,              "    + cLFRC
cQuery += " [113] as V_113_HEXTRA150,          "    + cLFRC
cQuery += " [117] as V_117_ADICNOT,            "    + cLFRC
cQuery += " [118] as V_118_DSRSHEAN,           "    + cLFRC
cQuery += " [119] as V_119_ANUENIO,            "    + cLFRC
cQuery += " [121] as V_121_HORAEXTRA90,        "    + cLFRC
cQuery += " [124] as V_124_SALARIOFAMILIA,     "    + cLFRC
cQuery += " [126] as V_126_SALARIOMATERNIDADE, "    + cLFRC
cQuery += " [128] as V_128_COMPLAUXDOENCA,     "    + cLFRC
cQuery += " [129] as V_129_AUXILIOACIDENTE,    "    + cLFRC
cQuery += " [136] as V_136_INSUFSALDOSALARIO,  "    + cLFRC
cQuery += " [140] as V_140_SALDODESALARIO,     "    + cLFRC
cQuery += " [144] as V_144_1PARCELA13SAL,      "    + cLFRC
cQuery += " [149] as V_149_COMPLEMENTOSALARIO, "    + cLFRC
cQuery += " [155] as V_155_ABONODEFERIAS,      "    + cLFRC
cQuery += " [156] as V_156_13ABONOPECUNIARIO,  "    + cLFRC
cQuery += " [157] as V_157_FERIASEMDOBRO,      "    + cLFRC
cQuery += " [158] as V_158_13FERIASEMDOBRO,    "    + cLFRC
cQuery += " [159] as V_159_FERIAS,             "    + cLFRC
cQuery += " [160] as V_160_FERIASMS,           "    + cLFRC
cQuery += " [161] as V_161_13FERIAS,           "    + cLFRC
cQuery += " [162] as V_162_13FERIASMS,         "    + cLFRC
cQuery += " [163] as V_163_MEDIAFERIASVLR,     "    + cLFRC
cQuery += " [164] as V_164_MEDIAFERIASVLRMS,   "    + cLFRC
cQuery += " [165] as V_165_MEDSHEXTRAS,        "    + cLFRC
cQuery += " [166] as V_166_MEDSHEXTRASMS,      "    + cLFRC
cQuery += " [169] as V_169_DSRSMEDFERIAS,      "    + cLFRC
cQuery += " [170] as V_170_DSRSMEDFERIASMS,    "    + cLFRC
cQuery += " [171] as V_171_FERIASVENCIDAS,     "    + cLFRC
cQuery += " [172] as V_172_FERIASPROPORCIONAIS,"    + cLFRC
cQuery += " [173] as V_173_13FERIASQUITACAO,   "    + cLFRC
cQuery += " [178] as V_178_DIFSFERIAS,         "    + cLFRC
cQuery += " [180] as V_180_DIF13FERIAS,        "    + cLFRC
cQuery += " [181] as V_181_DIF13FERIASMS,      "    + cLFRC
cQuery += " [182] as V_182_DIFABONOPECUNIARIO, "    + cLFRC
cQuery += " [183] as V_183_DIF13ABONOPECUNI,   "    + cLFRC
cQuery += " [184] as V_184_DIFMEDHEFERIAS,     "    + cLFRC
cQuery += " [188] as V_188_DIFDSRFERIAS,       "    + cLFRC
cQuery += " [190] as V_190_ARREDFERIAS,        "    + cLFRC
cQuery += " [195] as V_195_AVISOPREVIOINDENIZ, "    + cLFRC
cQuery += " [197] as V_197_PGTOMULTAEXPER,     "    + cLFRC
cQuery += " [205] as V_205_13SALARIORESCISAO,  "    + cLFRC
cQuery += " [207] as V_207_13SAVISOPREVIO,     "    + cLFRC
cQuery += " [218] as V_218_REEMBOLSO,          "    + cLFRC
cQuery += " [252] as V_252_DIFMEDFERVLR,       "    + cLFRC
cQuery += " [253] as V_253_DIFMEDFERVLRMS,     "    + cLFRC
cQuery += " [254] as V_254_13FERIASPROPRES,    "    + cLFRC
cQuery += " [269] as V_269_FERIASSAVINDENIZA,  "    + cLFRC
cQuery += " [270] as V_270_13FERSAVINDENIZ,    "    + cLFRC
cQuery += " [275] as V_275_ABONODEFERIASMS,    "    + cLFRC
cQuery += " [276] as V_276_13ABONOPECUNMS,     "    + cLFRC
cQuery += " [279] as V_279_MEDHORASSABONO,     "    + cLFRC
cQuery += " [280] as V_280_MEDVALORSABONO,     "    + cLFRC
cQuery += " [281] as V_281_MEDHORASABONOMS,    "    + cLFRC
cQuery += " [282] as V_282_MEDVLRSABONOMS,     "    + cLFRC
cQuery += " [283] as V_283_SOBREAVISO,         "    + cLFRC
cQuery += " [301] as V_301_ABONOSPAGOSMESANT,  "    + cLFRC
cQuery += " [305] as V_305_GRATIFICACAOFUNCAO, "    + cLFRC
cQuery += " [324] as V_324_PROVENTOPONTOMES,   "    + cLFRC
cQuery += " [336] as V_336_MEDFERVENRES,       "    + cLFRC
cQuery += " [336] as V_336_MEDFERVENRESC,      "    + cLFRC
cQuery += " [337] as V_337_MEDFERPROPRES,      "    + cLFRC
cQuery += " [337] as V_337_MEDFERPROPRESC,     "    + cLFRC
cQuery += " [338] as V_338_MEDAVISOPREVIORES,  "    + cLFRC
cQuery += " [339] as V_339_MED13ºSALRESC,      "    + cLFRC
cQuery += " [339] as V_339_MED13ºSALRES,       "    + cLFRC
cQuery += " [340] as V_340_MEDFERSAVPRERES,    "    + cLFRC
cQuery += " [341] as V_341_MED13SAAVINRESC,    "    + cLFRC
cQuery += " [399] as V_399_ARREDONDAMENTO,     "    + cLFRC
cQuery += " [401] as V_401_INSSSALARIO,        "    + cLFRC
cQuery += " [403] as V_403_INSSFERIAS,         "    + cLFRC
cQuery += " [405] as V_405_INSS13SALARIO,      "    + cLFRC
cQuery += " [407] as V_407_IMPRENDAFONTE,      "    + cLFRC
cQuery += " [409] as V_409_IRFERIAS,           "    + cLFRC
cQuery += " [412] as V_412_DESCREEMBDESPESAS,  "    + cLFRC
cQuery += " [414] as V_414_INSSFERIASMS,       "    + cLFRC
cQuery += " [420] as V_420_CONTRIBASSISTENC,   "    + cLFRC
cQuery += " [425] as V_425_FALTAINTEGRAL,      "    + cLFRC
cQuery += " [426] as V_426_ATRASOS,            "    + cLFRC
cQuery += " [428] as V_428_SAIDAANTECIPADA,    "    + cLFRC
cQuery += " [430] as V_430_ARREDONDAMENTO,     "    + cLFRC
cQuery += " [431] as V_431_INSUFSALDOSALARIO,  "    + cLFRC
cQuery += " [433] as V_433_VALEREFEICAO,       "    + cLFRC
cQuery += " [435] as V_435_VALETRANSPORTE,     "    + cLFRC
cQuery += " [440] as V_440_PENSAOALIMENTICIA,  "    + cLFRC
cQuery += " [455] as V_455_PENSAO2DEP,         "    + cLFRC
cQuery += " [457] as V_457_DESCDSRFALTA,       "    + cLFRC
cQuery += " [458] as V_458_SAIDAANTECIPADA,    "    + cLFRC
cQuery += " [460] as V_460_LIQUIDOPAGOFERIAS,  "    + cLFRC
cQuery += " [462] as V_462_ADIANTFERIAS,       "    + cLFRC
cQuery += " [465] as V_465_VALEALIMENTACAO,    "    + cLFRC
cQuery += " [470] as V_470_AVISOPREVIODESCONT, "    + cLFRC
cQuery += " [472] as V_472_DESCMULTACONTEXP,   "    + cLFRC
cQuery += " [476] as V_476_LIQUIDONARESCISAO,  "    + cLFRC
cQuery += " [502] as V_502_PLANOODONTO,        "    + cLFRC
cQuery += " [504] as V_504_PLANOODONTODEP,     "    + cLFRC
cQuery += " [604] as V_604_PLANOMEDICO,        "    + cLFRC
cQuery += " [605] as V_605_PLANOMEDICODEP,     "    + cLFRC
cQuery += " [606] as V_606_COPARTICIPACAO,     "    + cLFRC
cQuery += " [905] as V_905_EMPRESTCONITAU,     "    + cLFRC
cQuery += " [951] as V_951_MULTADETRANSITO,    "    + cLFRC
cQuery += " [988] as V_988_PLR,                "    + cLFRC
cQuery += " [991] as V_991_ADNOTCWB,           "    + cLFRC
cQuery += " [996] as V_996_ADNOTCWB,           "    + cLFRC
cQuery += " [999] as V_999_BASEVALEREFEIC,     "    + cLFRC
cQuery += " [944] as V_944_BSVALEALIMENTACAO,  "    + cLFRC
cQuery += " [954] as V_954_EMPRASSMEDIC,       "    + cLFRC
cQuery += " [957] as V_957_EMPRASSODONTTIT     "    + cLFRC
cQuery += " FROM                               "    + cLFRC
cQuery += " (                                  "    + cLFRC

//cQuery += " SELECT RD_FILIAL, RD_MAT, RA_NOME, RD_DATARQ, RD_CC, RD_ITEM, RD_PD, RD_VALOR" +cLFRC
cQuery += " SELECT " + cPre+"_FILIAL, " + cPre+"_MAT, RA_NOME, " + cPre+"_PERIODO, " + cPre+"_CC, CTT_DESC01, RJ_DESC, " + cPre+"_ITEM, " + cPre+"_PD, " + cPre+"_VALOR," +cLFRC
cQuery += " RA_ADMISSA , CTD_DESC01 " +cLFRC
cQuery += " FROM dbo."+RetSqlName(cTab)+" "+ cTab +cLFRC
cQuery += " Inner join dbo."+RetSqlName("SRA")+" SRA on " + cPre+"_FILIAL = RA_FILIAL and " + cPre+"_MAT = RA_MAT" +cLFRC
cQuery += " Inner join dbo."+RetSqlName("SRJ")+" SRJ on SubString(" + cPre+"_FILIAL,1,2) = RJ_FILIAL and RA_CODFUNC = RJ_FUNCAO" +cLFRC
cQuery += " Inner join dbo."+RetSqlName("CTT")+" CTT on " + cPre+"_CC = CTT_CUSTO" +cLFRC
cQuery += " Inner join dbo."+RetSqlName("CTD")+" CTD on " + cPre+"_ITEM = CTD_ITEM" +cLFRC
cQuery += " where "+cTab+".D_E_L_E_T_ =' ' and " + cPre+"_ROTEIR ='FOL' and " +cLFRC
cQuery +=  + cPre+"_FILIAL >= '"+MV_PAR01+"' and " + cPre+"_FILIAL <= '"+ MV_PAR02+"' and " +cLFRC
cQuery +=  + cPre+"_CC     >= '"+MV_PAR03+"' and " + cPre+"_CC    <= '"+ MV_PAR04+"' and "  +cLFRC
cQuery +=  + cPre+"_ITEM   >= '"+MV_PAR05+"' and " + cPre+"_ITEM  <= '"+ MV_PAR06+"' and "  +cLFRC
cQuery +=  + cPre+"_MAT    >= '"+MV_PAR07+"' and " + cPre+"_MAT   <= '"+ MV_PAR08+"' and "  +cLFRC
cQuery +=  + cPre+"_PERIODO >= '"+MV_PAR09+"' and " + cPre+"_PERIODO <= '"+ MV_PAR10+"' "     +cLFRC

cQuery += " ) C "                                                              +cLFRC
cQuery += " PIVOT "                                                            +cLFRC
cQuery += " ("                                                                 +cLFRC
cQuery += " Sum(" + cPre+"_VALOR) "                                                    +cLFRC
cQuery += " FOR " + cPre+"_PD IN ("                                                    +cLFRC

For nCont := 1 to Len(aVerbas1)
	cQuery += "["+aVerbas1[nCont]+"],"
Next nCont
cQuery +=  +cLFRC

For nCont := 1 to Len(aVerbas2)
	cQuery += "["+aVerbas2[nCont]+"],"
Next nCont
cQuery := left(cQuery, len(cQuery) -1)
cQuery +=  +cLFRC

cQuery += " )      "     +cLFRC                                                                 
cQuery += " ) AS P "   +cLFRC
cQuery += " order by 1,2,3 "   +cLFRC

return cQuery                   

User Function BuscaPerg(aRegsOri)

Local cGrupo	:= ''
Local cOrdem	:= ''
Local aRegAux   := {}
Local aEstrut   := {}
Local nCount    := 0
Local nLenGrupo := 0
Local nLenOrdem := 0
Local nX	 	:= 0
Local nY		:= 0
Local aRegs		:= aClone(aRegsOri)

If ValType('aRegs') <> 'C'
	Return
Endif

If Len(aRegs) <= 0
	Return
Endif

// Buscar Estrutura da tabela SX1
dbSelectArea('SX1');dbSetOrder(1)
aEstrut   := SX1->(dbStruct())
nCount	  := Len(aEstrut)

// Definir o Tamanho dos Campos de Pesquisa
nLenGrupo := aEstrut[1][3] // Tamanho do campo X1_GRUPO
nLenOrdem := aEstrut[2][3] // Tamanho do campo X1_ORDEM

// Compatibilizando o Array de Perguntas
For nX := 1 To Len(aRegs)
	aAdd(aRegAux,Array(nCount))
	For nY := 1 To nCount
		aRegAux[Len(aRegAux)][nY]:=Space(aEstrut[nY][3])
	Next nY
	For nY := 1 To nCount
		If nY <= Len(aRegs[nX])
			aRegAux[Len(aRegAux)][nY]:= aRegs[nX,nY]
		Endif
	Next nY
Next nX

// Recarregando o Array de Peguntas compatibilizado
aRegs := {}
aRegs := aClone(aRegAux)

// Testando se ele nao ficou vazio
If Len(aRegs) <= 0
	Return
Endif

// Buscando no SX1 e incluindo caso nao exista
dbSelectArea('SX1')
For nX := 1 to Len(aRegs)
	cGrupo := Padr(aRegs[nX,1],nLenGrupo)
	cOrdem := Padr(aRegs[nX,2],nLenOrdem)
	If !dbSeek(cGrupo+cOrdem,.F.)
		RecLock('SX1',.T.)
		For nY := 1 to nCount
			If nY <= Len(aRegs[nX])
				FieldPut(nY,aRegs[nX,nY])
			Endif
		Next nY
		MsUnlock()
	Endif
Next nX

Return 

sTatic function RetFol ()
Local aPerAberto :={}
Local aPerFechado :={}
//Carregar os periodos abertos (aPerAberto) e/ou
// os periodos fechados (aPerFechado), dependendo
// do periodo (ou intervalo de periodos) selecionado
RetPerAbertFech('00001'	,; // Processo selecionado na Pergunte.
				'FOL'	,; // Roteiro selecionado na Pergunte.
				MV_PAR09	,; // Periodo selecionado na Pergunte.
				'01'		,; // Numero de Pagamento selecionado na Pergunte.
				NIL			,; // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
				NIL			,; // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
				@aPerAberto	,; // Retorna array com os Periodos e NrPagtos Abertos
				@aPerFechado ) // Retorna array com os Periodos e NrPagtos Fechados

return iif(Len(aPerAberto) ==0 , 'SRD','SRC')
