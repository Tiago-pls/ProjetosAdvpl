#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*__________________________________________________________________________
-----------------------------------------------------------------------------
--+-----------------------------------------------------------------------+--
---Fun--o    -  ValPoten   - Autor - Tiago Santos      - Data -02.02.23   ---
--+----------+---------------------------------------------------------------
---Descri--o -  Relatório para geração dos valores vendidos e potencias    ---
--+-----------------------------------------------------------------------+--
--+-----------------------------------------------------------------------+--
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/

User Function ValTitulos
                      
Private cPerg 	:= "" 
Private cLFRC	:= chr(13)+chr(10)
dbSelectArea("SX1")  
dbSetOrder(1)
cPerg := "VALTIT" +Replicate(" ",Len(X1_GRUPO)- Len("VALTIT"))

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
Local oDados2             

//T-tulo do relat-rio no cabe-alho
cTitle := OemToAnsi("Relatorio Títulos")

//Criacao do componente de impress-o
oRel := tReport():New("Relatorio Títulos",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)

//Seta a orienta--o do papel
oRel:SetLandscape()

//Seta impress-o em planilha                      
oRel:SetDevice(4)    

//Inicia a Sess-o
oDados := trSection():New(oRel,cTitle,{"SF2","SD2","SA3"},aOrdem)
oDados2 := trSection():New(oRel,cTitle,{"SF2","SD2","SA3"},aOrdem)
//oDados:SetHeaderSection(.F.)    
//oDados:HeaderBreak()     
oDados:SetHeaderBreak() 

// Defini--o das colunas a serem impressas no relat-rio
// Titulo Principal
trCell():New(oDados,"E1_CLIENTE   ","QRY" ,  ,"@!",TamSx3("E5_CLIFOR")[1])
trCell():New(oDados,"E1_LOJA       ","QRY" ,  ,"@!",TamSx3("E5_CLIFOR")[1])
trCell():New(oDados,"A1_NOME       ","QRY" ,  ,"@!",TamSx3("A1_NOME")[1])
trCell():New(oDados,"E1_NUM       ","QRY" ,  ,"@!",TamSx3("E5_NUMERO")[1])
trCell():New(oDados,"E1_VENCTO     ","QRY" ,  ,"@!",TamSx3("E1_VENCTO")[1])
trCell():New(oDados,"E1_VENCREA     ","QRY" ,  ,"@!",TamSx3("E1_VENCREA")[1])
trCell():New(oDados,"E1_VALOR     ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados,"E1_SALDO          ","QRY" ,  ,"@E 999,999,999.99",17)

// Movimentações Títulos
trCell():New(oDados2,"E5_NUMERO   ","QRY" ,  ,"@!",TamSx3("E5_NUMERO")[1])
trCell():New(oDados2,"E5_CLIFOR   ","QRY" ,  ,"@!",TamSx3("E5_CLIFOR")[1])
trCell():New(oDados2,"E5_LOJA     ","QRY" ,  ,"@!",TamSx3("E5_LOJA")[1])
trCell():New(oDados2,"NOMECLI     ","QRY" ,  ,"@!",TamSx3("A1_NOME")[1])
trCell():New(oDados2,"E5_DATA     ","QRY" ,  ,"@!",TamSx3("E5_DATA")[1])
trCell():New(oDados2,"E5_VALOR    ","QRY" ,  ,"@E 999,999,999.99",17)
trCell():New(oDados2,"E5_DOCUMEN  ","QRY" ,  ,"@E",TamSx3("E5_DOCUMEN")[1])
trCell():New(oDados2,"E5_HISTOR   ","QRY" ,  ,"@E",TamSx3("E5_HISTOR")[1])

// Remessa
trCell():New(oDados3,"E5_HISTOR   ","QRY" ,  ,"@E",TamSx3("E5_HISTOR")[1])
oRel:SetTotalInLine(.F.)
       
//Aqui, farei uma quebra  por seção
oDados:SetPageBreak(.T.)
oDados:SetTotalText(" ")		
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
Local oDados2   := oRel:Section(2) 
Local oDados3   := oRel:Section(3)
Local oTotVenda := oRel:Section(4)     
Local oTotGeral := oRel:Section(5) 



//Seleciona os registros
//********************************************************************************
If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif
cQry := MontaQry()
TcQuery cQry New Alias "QRY"                          

TCSetField("QRY","E5_DATA","D",8,0)  
TCSetField("QRY","E1_VENCTO","D",8,0)  
TCSetField("QRY","E1_VENCREA","D",8,0)  
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
        oDados:Init()
  		oRel:IncMeter(10)   
        //nSaldo := SaldoTit(QRY->E1_PREFIXO,QRY->E1_NUM,QRY->E1_PARCELA,QRY->E1_TIPO,QRY->E1_NATUREZ,"P",QRY->E5_CLIFOR,1,,,QRY->E5_LOJA,,0)
        //oDados:Cell("LIQ"):SetValue(nSaldo)	
        
  		oDados:PrintLine()
        oDados:SetHeaderSection(.T.)  

        oDados2:init() 	
        nTotVendV1 := 0
        nTotVendV2 := 0
        nTotVendV3 := 0
        cChave := QRY->(E1_CLIENTE + E1_LOJA +E1_NUM)
	    //While cChave == QRY->(E1_CLIENTE + E1_LOJA + E1_NUM)            
	    while cChave == QRY->(E1_CLIENTE + E1_LOJA + E1_NUM)  
            oDados2:Cell("NOMECLI"):SetValue(posicione('SA1',1,xFilial('SA1')+QRY->E5_CLIFOR +QRY->E5_LOJA ,'A1_NOME')) 
            oDados2:PrintLine()                     
            QRY->( dbSkip())
        Enddo
        oDados2:Finish()
 		oRel:ThinLine()
 		oRel:Skipline()
 		//finalizo a primeira seção
		oDados:Finish()

//	QRY->(dbSkip())	
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
aAdd(aRegs,{cPerg,"03","Titulo"         ,"Titulo"              ,"Doc"             ,"mv_ch5","C",09,0,0,"G"," "           ,"mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"04","Titulo ate"     ,"Titulo ate"          ,"Doc ate"         ,"mv_ch6","C",09,0,0,"G","naovazio()"  ,"mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"05","Cliente"        ,"Item De"          ,"Item De"         ,"mv_ch5","C",06,0,0,"G"," "           ,"mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTD","",""})
aAdd(aRegs,{cPerg,"06","Cliente Ate"    ,"Item Ate"         ,"Item Ate"        ,"mv_ch6","C",06,0,0,"G" ,"naovazio()" ,"mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTD","",""})
aAdd(aRegs,{cPerg,"07","Loja Cli"       ,"Loja Cli"         ,"Loja Cli"        ,"mv_ch7","C",04,0,0,"G"," "           ,"mv_par07","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"08","Loja Cli Ate"   ,"Loja Cli Ate"     ,"Loja Cli Ate"    ,"mv_ch8","C",04,0,0,"G","naovazio()"  ,"mv_par08","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})

U_BuscaPerg(aRegs)

Return


// fun--o para retornar a query conforme tipo do relat-rio selecionado
static Function MontaQry ()                                   
Local cQuery := " " 
cQuery += " select E5_CLIFOR, E5_NUMERO,  E1_VENCTO, E1_VENCREA, E1_VALOR,  E1_PREFIXO, E1_NUM, E1_PARCELA, E1_SALDO, " +cLFRC 
cQuery += " E1_TIPO, E1_NATUREZ, E1_CLIENTE, E1_LOJA, A1_NOME,  SE5.* from " + RetSqlName("SE1")+" SE1"+cLFRC
cQuery += " left join "+RetSqlName("SE5")+" SE5 on E1_FILIAL = E5_FILIAL and E1_NUM = E5_NUMERO and E1_CLIENTE = E5_CLIFOR and E1_LOJA = E5_LOJA and SE1.D_E_L_E_T_ =' '"+cLFRC
cQuery += " inner join "+RetSqlName("SA1")+" SA1 on E1_CLIENTE = A1_COD and E1_LOJA = A1_LOJA and SA1.D_E_L_E_T_ =' '"+cLFRC
cQuery += " where  E1_TIPO ='NF' and E1_NUM  >='"+MV_PAR03+"'and E1_NUM <='"+MV_PAR04+"'"
//cQuery += " and E1_FILIAL  >='"+MV_PAR01+"'and E1_FILIAL <='"+MV_PAR02+"'"
cQuery += " and E1_CLIENTE  >='"+MV_PAR05+"'and E1_CLIENTE <='"+MV_PAR07+"'"
cQuery += " and E1_LOJA  >='"+MV_PAR06+"'and E1_LOJA <='"+MV_PAR08+"'"
cQuery += " and SE1.D_E_L_E_T_ =' '"

return cQuery
