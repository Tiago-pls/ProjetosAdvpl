#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'

/*__________________________________________________________________________
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½+-----------------------------------------------------------------------+ï¿½ï¿½
ï¿½ï¿½ï¿½Funï¿½ï¿½o    ï¿½  ImportaSP8   ï¿½ Autor ï¿½ Tiago Santos      ï¿½ Data ï¿½27.09.19 ï¿½ï¿½ï¿½
ï¿½ï¿½+----------+------------------------------------------------------------ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½Descriï¿½ï¿½o ï¿½  Relatorio Gerencial Folha de Pagamento         		      ï¿½ï¿½ï¿½
ï¿½ï¿½+-----------------------------------------------------------------------+ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½*/

User Function ExtratoBH
                      
Private cPerg 	:= "" 
dbSelectArea("SX1")  
dbSetOrder(1)
cPerg := "EXTRATOBH" +Replicate(" ",Len(X1_GRUPO)- Len("EXTRATOBH"))

//Carrega os Parï¿½metros
//********************************************************************************
GeraPerg(cPerg)
  
If !Pergunte(cPerg,.T.)
   Return
Endif  

MsAguarde({|| GeraRel()}, "Aguarde...", "Gerando Registros...")
Return

/*__________________________________________________________________________
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½+-----------------------------------------------------------------------+ï¿½ï¿½
ï¿½ï¿½ï¿½Funï¿½ï¿½o    ï¿½  GeraRel    ï¿½ Autor ï¿½ Tiago Santos        ï¿½ Data ï¿½18.09.19 ï¿½ï¿½ï¿½
ï¿½ï¿½+----------+------------------------------------------------------------ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½Descriï¿½ï¿½o ï¿½  Gera o Relatï¿½io                              		      ï¿½ï¿½ï¿½
ï¿½ï¿½+-----------------------------------------------------------------------+ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½*/

static function GeraRel()
Local cTitle    := OemToAnsi("Relatï¿½rio Conferencia BH")
Local cHelp     := OemToAnsi("Relatï¿½rio Conferencia BH")   
Local aOrdem 	:= {}                
Local oRel
Local oDados             

//Tï¿½tulo do relatï¿½rio no cabeï¿½alho
cTitle := OemToAnsi("Relatorio Conferencia BH")

//Criacao do componente de impressï¿½o
oRel := tReport():New("Relatorio Conferencia BH",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)

//Seta a orientaï¿½ï¿½o do papel
oRel:SetLandscape()

//Seta impressï¿½o em planilha                      
oRel:SetDevice(4)    

//Inicia a Sessï¿½o
oDados := trSection():New(oRel,cTitle,{"SRA","SRJ","SQB"},aOrdem)
//oDados:SetHeaderSection(.F.)    
//oDados:HeaderBreak()     
oDados:SetHeaderBreak() 

// Definiï¿½ï¿½o das colunas a serem impressas no relatï¿½rio

trCell():New(oDados,"RA_FILIAL"           ,"QRY" ,"Cod Filial"   	     ,"@!",02)
trCell():New(oDados,"RA_MAT"              ,"QRY" ,"Matricula"     	     ,"@!",06)
trCell():New(oDados,"RA_NOME"             ,"QRY" ,"Nome"     	         ,"@!",30)
trCell():New(oDados,"RA_SALARIO"          ,"QRY" ,"Salário"              ,"@E 999,999,999.99",17)
trCell():New(oDados,"RA_DEPTO"            ,"QRY" ,"Depto"                ,"@!",20) 
trCell():New(oDados,"QB_DESCRIC"          ,"QRY" ,"Nome Depto"           ,"@!",20) 
trCell():New(oDados,"RA_CC"               ,"QRY" ,"Centro Custo"         ,"@!",20) 
trCell():New(oDados,"DESC_CC"             ,"QRY" ,"Desc C. Custo"        ,"@!",20) 
trCell():New(oDados,"PROV"                ,"QRY" ,"Proventos"            ,"@E 999,999,999.99",17)
trCell():New(oDados,"DESC"                ,"QRY" ,"Descontos"            ,"@E 999,999,999.99",17) 
trCell():New(oDados,"LIQ"                 ,"QRY" ,"Líquido"              ,"@E 999,999,999.99",17)
trCell():New(oDados,"LIQ65"               ,"QRY" ,"Liquido 65%"          ,"@E 999,999,999.99",17)
trCell():New(oDados,"LIQ100"              ,"QRY" ,"Líquido 100%"         ,"@E 999,999,999.99",17) 
trCell():New(oDados,"DESCONTOS"           ,"QRY" ,"Descontos"            ,"@E 999,999,999.99",17) 
trCell():New(oDados,"VAL_FOL"             ,"QRY" ,"Valor Folha"          ,"@E 999,999,999.99",17) 

//Executa o relatorio
oRel:PrintDialog()

Return

/*-----------------+---------------------------------------------------------+
!Nome              ! ReportPrint                                             !
+------------------+---------------------------------------------------------+
!Descriï¿½ï¿½o         ! Processamento dos dados e impressao do relatï¿½rio        !
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

cQry := MontaQry()

TcQuery cQry New Alias "QRY"                          
cChave := ""
nCont := 0
nProvento := 0
nDesconto := 0

If QRY->(!Eof())
	While QRY->(!Eof()) .and. !oRel:Cancel() 
  		ProcRegua(10)
  		nCont ++

		MsProcTxt("Analisando registro " )
		 
		//Cancelado pelo usuario
		If oRel:Cancel()
			Exit
		EndIf   

		if QRY->P9_TIPOCOD=='1' //SMS
			nProvento := SomaHoras(QRY->PI_QUANT, nProvento) //'H',,3)
		else
			nDesconto := SomaHoras(QRY->PI_QUANT , nDesconto)
		Endif
		cChave := QRY->(RA_FILIAL + RA_MAT)	
		cFilQRY := QRY->RA_FILIAL
		cMat := QRY->RA_MAT
		cNome := QRY->RA_NOME
		cDepto := QRY->RA_DEPTO
		cNomeDepto := QRY->QB_DESCRIC
		nSalario := QRY->RA_SALARIO
		cCC := QRY->RA_CC
		cNomeCC := POSICIONE( "CTT",1,XFILIAL("CTT")+QRY->RA_CC,"CTT_DESC01")

		QRY->(dbSkip())		
		if cChave <> QRY->(RA_FILIAL + RA_MAT)
			
			nLiq := SubHoras(nProvento, nDesconto)
			nLiq100 := iif(Min(nLiq,20) < 20, 0 , nLiq - Min(nLiq,20))
			oDados:Cell("RA_FILIAL"):SetValue( cFilQRY)
			oDados:Cell("RA_MAT"):SetValue( cMat)
			oDados:Cell("RA_NOME"):SetValue( cNome)
			oDados:Cell("RA_SALARIO"):SetValue( nSalario)
			oDados:Cell("RA_DEPTO"):SetValue( cDepto)
			oDados:Cell("QB_DESCRIC"):SetValue( cNomeDepto)
			oDados:Cell("RA_CC"):SetValue( cCC)
			oDados:Cell("DESC_CC"):SetValue( cNomeCC)

			oDados:Cell("PROV"):SetValue( nProvento)
			oDados:Cell("DESC"):SetValue( nDesconto)
			oDados:Cell("LIQ"):SetValue( nLiq)
			oDados:Cell("LIQ65"):SetValue(iif(nLiq<0 , 0 ,  Min(nLiq,20)))
			oDados:Cell("LIQ100"):SetValue( nLiq100)
			oDados:Cell("DESCONTOS"):SetValue( iif(nLiq < 0, nLiq * -1 , 0))
			oRel:IncMeter(10)  
			oDados:PrintLine()			
			oDados:SetHeaderSection(.F.)    
			nProvento := 0
			nDesconto := 0
		Endif		
	Enddo	
Else		
	MsgInfo("Nao foram encontrados registros para os parametros informados!")
    Return .F.
Endif
		
Return

/*__________________________________________________________________________
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½+-----------------------------------------------------------------------+ï¿½ï¿½
ï¿½ï¿½ï¿½Funï¿½ï¿½o    ï¿½  GeraPerg     ï¿½ Autor ï¿½ Tiago Santos      ï¿½ Data ï¿½18.09.19 ï¿½ï¿½ï¿½
ï¿½ï¿½+----------+------------------------------------------------------------ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½Descriï¿½ï¿½o ï¿½  Atualiza SX1                                		      ï¿½ï¿½ï¿½
ï¿½ï¿½+-----------------------------------------------------------------------+ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½*/

Static Function GeraPerg(cPerg) 
Local aRegs:= {}

aAdd(aRegs,{cPerg,"01","Filial"         ,"Filial De"        ,"Filial De"       ,"mv_ch1","C",06,0,0,"G"," ","mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"02","Filial Ate"     ,"Filial Ate"       ,"Filial Ate"      ,"mv_ch2","C",06,0,0,"G","naovazio()","mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"03","Depto de"       ,"Are De"           ,"Centro Custo De" ,"mv_ch3","C",09,0,0,"G"," ","mv_par03","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SQB","",""})
aAdd(aRegs,{cPerg,"04","Depto Ate"      ,"Are Ate"          ,"Centro Custo Ate","mv_ch4","C",09,0,0,"G","naovazio()","mv_par04","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SQB","",""})
aAdd(aRegs,{cPerg,"05","Centro Custo"   ,"Centro Custo De"  ,"Centro Custo De" ,"mv_ch5","C",09,0,0,"G"," ","mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"06","Centro Ate"     ,"Centro Custo Ate" ,"Centro Custo Ate","mv_ch6","C",09,0,0,"G","naovazio()","mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"07","Matricula"      ,"Matricula De"     ,"Matricula De"    ,"mv_ch7","C",06,0,0,"G"," ","mv_par07","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"08","Matricula Ate"  ,"Matricula Ate"    ,"Matricula Ate"   ,"mv_ch8","C",06,0,0,"G","naovazio()","mv_par08","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"09","Data Inicio"    ,"Data Inicio"      ,"Data Inicio"     ,"mv_ch9","D",08,0,0,"G","naovazio()","mv_par09","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Data Fim"       ,"Data Fim"         ,"Data Fim"        ,"mv_chA","D",08,0,0,"G","naovazio()","mv_par10","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})

U_BuscaPerg(aRegs)

Return

// funï¿½ï¿½o para retornar a query conforme tipo do relatï¿½rio selecionado
static Function MontaQry ()                                   
Local cQuery := " " 

cQuery := " select * from  " +RetSqlName("SPI")+" SPI"
cQuery += " Inner join "  + RetSqlName("SRA")+ " SRA on PI_FILIAL = RA_FILIAL and PI_MAT = RA_MAT"
cQuery += " Inner join "  + RetSqlName("SP9")+ " SP9 on  PI_PD = P9_CODIGO"
cQuery +=" left join " + RetSqlName("SQB")+" SQB on RA_DEPTO = QB_DEPTO"
cQuery +=" Where SPI.D_E_L_E_T_ =' 'and  PI_FILIAL Between '" + mv_par01 +"' and '" + mv_par02 +"'" 
cquery +=" and RA_DEPTO Between '" + mv_par03 +"' and '" + mv_par04 +"'" 
cquery +=" and RA_CC Between '" + mv_par05 +"' and '" + mv_par06 +"'" 
cquery +=" and PI_MAT Between '" + mv_par07 +"' and '" + mv_par08 +"'" 
cquery +=" and PI_DATA >='" +DtoS(mv_par09)+ "' and PI_DATA <='" +DtoS(mv_par10)+"'"
cQuery +=" and SPI.D_E_L_E_T_ =' 'and SRA.D_E_L_E_T_ =' ' and SP9.D_E_L_E_T_ =' 'and SQB.D_E_L_E_T_ =' '"
cQuery +=" order by PI_FILIAL, PI_MAT " 
				
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
