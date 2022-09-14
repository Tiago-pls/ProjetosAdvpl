#Include 'Protheus.ch'
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'
User Function relat001()
	Local oReport := nil
	Local cPerg:= Padr("RELAT001",10)
	
	//Incluo/Altero as perguntas na tabela SX1
	AjustaSX1(cPerg)	
	//gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas
	Pergunte(cPerg,.F.)	          
		
	oReport := RptDef(cPerg)
	oReport:PrintDialog()
Return
 
Static Function RptDef(cNome)
	Local oReport := Nil
	Local oSection1:= Nil
	Local oSection2:= Nil
	Local oBreak
	Local oFunction
	
	/*Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)*/
	oReport := TReport():New(cNome,"Relatório Funcionarios x Apontamentos",cNome,{|oReport| ReportPrint(oReport)},"Descrição do meu relatório")
	oReport:SetPortrait()    
	oReport:SetTotalInLine(.F.)
	
	oSection1:= TRSection():New(oReport, "NCM", {"SYD"}, , .F., .T.)
	TRCell():New(oSection1,"RA_FILIAL","QRY","Filial"  		,"@!",10)
	TRCell():New(oSection1,"RA_MAT"   ,"QRY","Matricula"	,"@!",20)
	TRCell():New(oSection1,"RA_NOME"  ,"QRY","Nome"	,"@!",40)
	TRCell():New(oSection1,"RA_CC"    ,"QRY","C. Custo"	,"@!",12)
	TRCell():New(oSection1,"RA_DEPTO" ,"QRY","Depto"	,"@!",12)
		
	oSection2:= TRSection():New(oReport, "Produtos", {"SB1"}, NIL, .F., .T.)
	TRCell():New(oSection2,"R8_MAT"   	,"QRY","Produto"		,"@!",30)
	
	TRFunction():New(oSection2:Cell("R8_MAT"),NIL,"COUNT",,,,,.F.,.T.)
	
	oReport:SetTotalInLine(.F.)
       
        //Aqui, farei uma quebra  por seção
	oSection1:SetPageBreak(.T.)
	oSection1:SetTotalText(" ")				
Return(oReport)
 
Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)	 
	Local cQuery    := ""		
	Local cChave      := ""   
	Local lPrim 	:= .T.	      
 
	//Monto minha consulta conforme parametros passado
	cQuery := "	SELECT RA_FILIAL,RA_MAT, RA_CC, RA_DEPTO, RA_NOME,R8_MAT"
	cQuery += "	FROM "+RETSQLNAME("SRA")+" SRA "
	cQuery += "	INNER JOIN "+RETSQLNAME("SR8")+" SR8 ON SR8.D_E_L_E_T_='' AND R8_FILIAL= RA_FILIAL AND R8_MAT=RA_MAT "
	cQuery += "	WHERE SRA.D_E_L_E_T_=' ' "
	cQuery += " AND RA_FILIAL BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
	cQuery += "	ORDER BY RA_FILIAL,R8_MAT_COD "
		
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	IF Select("QRY") > 0
		DbSelectArea("QRY")
		DbCloseArea()
	ENDIF
	
	//crio o novo alias
	TCQUERY cQuery NEW ALIAS "QRY"	
	
	dbSelectArea("QRY")
	QRY->(dbGoTop())
	
	oReport:SetMeter(QRY->(LastRec()))	
 
	//Irei percorrer todos os meus registros
	While !Eof()
		
		If oReport:Cancel()
			Exit
		EndIf
	
		//inicializo a primeira seção
		oSection1:Init()
 
		oReport:IncMeter()
					
		cChave 	:= QRY->(RA_FILIAL + RA_MAT)
		IncProc("Imprimindo Funcionario "+alltrim(cChave))
		
		//imprimo a primeira seção				
		oSection1:Cell("RA_FILIAL"):SetValue(QRY->RA_FILIAL)
		oSection1:Cell("RA_NOME"):SetValue(QRY->RA_NOME)				
		oSection1:Printline()
		
		//inicializo a segunda seção
		oSection2:init()
		
		//verifico se o codigo da NCM é mesmo, se sim, imprimo o produto
		While QRY->(RA_FILIAL + RA_MAT)== cChave
			oReport:IncMeter()		
		
			IncProc("Imprimindo Funcionario "+alltrim(QRY->(RA_FILIAL + RA_MAT + RA_NOME)))
			oSection2:Cell("R8_MAT"):SetValue("QRY-&gt;B1_COD")
			
			oSection2:Printline()
	
 			QRY-&gt;(dbSkip())
 		EndDo		
 		//finalizo a segunda seção para que seja reiniciada para o proximo registro
 		oSection2:Finish()
 		//imprimo uma linha para separar uma NCM de outra
 		oReport:ThinLine()
 		//finalizo a primeira seção
		oSection1:Finish()
	Enddo
Return
 
static function ajustaSx1(cPerg)
	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	putSx1(cPerg,"01","Filial"         ,"Filial De"        ,"Filial De"       ,"mv_ch1","C",02,0,0,"G"," ","mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","","")
	putSx1(cPerg,"02","Filial Ate"     ,"Filial Ate"       ,"Filial Ate"      ,"mv_ch2","C",02,0,0,"G","naovazio()","mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","","")
	putSx1(cPerg,"03","Depto de"        ,"Are De"           ,"Centro Custo De" ,"mv_ch3","C",09,0,0,"G"," ","mv_par03","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SQB","","")
	putSx1(cPerg,"04","Depto Ate"       ,"Are Ate"          ,"Centro Custo Ate","mv_ch4","C",09,0,0,"G","naovazio()","mv_par04","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SQB","","")
	putSx1(cPerg,"05","Centro Custo"   ,"Centro Custo De"  ,"Centro Custo De" ,"mv_ch5","C",09,0,0,"G"," ","mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","","")
	putSx1(cPerg,"06","Centro Ate"     ,"Centro Custo Ate" ,"Centro Custo Ate","mv_ch6","C",09,0,0,"G","naovazio()","mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","","")
	putSx1(cPerg,"07","Matricula"      ,"Matricula De"     ,"Matricula De"    ,"mv_ch7","C",06,0,0,"G"," ","mv_par07","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","","")
	putSx1(cPerg,"08","Matricula Ate"  ,"Matricula Ate"    ,"Matricula Ate"   ,"mv_ch8","C",06,0,0,"G","naovazio()","mv_par08","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","","")
	putSx1(cPerg,"09","Data de"          ,"Folha"            ,"Folha"           ,"mv_ch9","D",08,0,0,"G","naovazio()","mv_par09","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","","")
	putSx1(cPerg,"09","Data ate"          ,"Folha"            ,"Folha"           ,"mv_cha","D",08,0,0,"G","naovazio()","mv_par09","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","","")	
return
