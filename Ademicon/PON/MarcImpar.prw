#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  RepMarc    ¦ Autor ¦ Tiago Santos        ¦ Data ¦11.06.23 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Reprocessamento das marcações com intervalo automatico    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
// Programa desenvolvido por SMS Consultoria

User function MarcImpar()

Local dPerIni		:= Ctod("//")
Local dPerFim		:= Ctod("//")
Local aLogfile	:= {}  // Array para conter as ocorrencias a serem impressas  
Local aMarcImp	:= {}
Local lPerCompleto	:= .F.
Local cLastFil  := xFilial("SRA")
Local lPriImpar		:= .T.
local lRet := .T.
Local lContinua := .T.

Private cPerg 	:= "" 
dbSelectArea("SX1")  
dbSetOrder(1)
cPerg := "MIMPAR" +Replicate(" ",Len(X1_GRUPO)- Len("MIMPAR"))

//Carrega os Parï¿½metros
//********************************************************************************
GeraPerg(cPerg)
  
If !Pergunte(cPerg,.T.)
   Return
Endif  


/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carrega Log do Inicio do Processo de Fechamento			   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
aAdd(aLogFile, "- Inicio do Fechamento Mensal em "  + Dtoc(MsDate()) + ', as ' + Time() + '.') 
//Seleciona os registros
//********************************************************************************
// carrega dados do período
checkPonMes( @dPerIni , @dPerFim , NIL , NIL , .T. , cLastFil , NIL , @lPerCompleto )


If Select("QRY")>0         
	QRY->(dbCloseArea())
Endif

If Select("SRA")==0         
	DBSELECTAREA( "SRA" )
Endif


cQry := " Select "
cQry += "  P8_FILIAL,P8_MAT,P8_DATA, P8_DATAAPO  ,P8_TPMCREP from " + RetSqlName("SP8")
cQry += " Where"
cQry += " D_E_L_E_T_ =' ' and P8_DATAAPO >= '"+dTos(dPerIni)+"' and P8_DATAAPO <= '"+DtoS(dPerFim)+"'"
cQry += " order by 1,2,4"
TcQuery cQry New Alias "QRY"  
cMatInc := ""
While QRY->( !EoF() )
	nMarcs		:= 0
	cSP8Fil		:= QRY->P8_FILIAL
	cSP8Mat		:= QRY->P8_MAT
	cSP8Data	:= QRY->P8_DATA                
 	cSP8DtApo 	:= QRY->P8_DATAAPO 	
    While QRY->(P8_FILIAL + P8_MAT + P8_DATAAPO) == cSP8Fil + cSP8Mat + cSP8DtApo
        IIf(QRY->P8_TPMCREP != "D", nMarcs++, nMarcs)
        QRY->(DbSkip())
    Enddo

    If ( ( nMarcs % 2 ) != 0 )
        SRA->(DBGOTOP(  ))
        if SRA->( DbSeek(QRY->(P8_FILIAL + cSP8Mat )))
            cTexto := Space(1) + cSP8Fil + Space(1) + ": " + cSP8Mat + " "+SRA->RA_NOME
            if cSP8Mat <> cMatInc
                cHelp := "Existem Marcações Ímpares para o Funcionário: " + cTexto//"Existem Marcações Ímpares para o Funcionário: "
                aAdd( aMarcImp , cHelp )
                cMatInc := cSP8Mat
            Endif                        
            aAdd(aMarcImp, + "Data: " + SUBSTR( cSP8Data, 7, 2) + '/' +SUBSTR( cSP8Data, 5, 2) +'/'+ SUBSTR( cSP8Data, 1, 4) )
            lContinua 	:= .F.      
        Endif  
    EndIf

End While
	
If !lContinua
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³  Grava e Imprime Log										  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	fMakeLog( { aLogFile, aMarcImp } , { 'Log de Ocorrencias:', OemToAnsi("Funcionário(s) com Marcacoes impares") } , NIL , .T. , FunName() )
    lRet:= .F.
ELSE
    fMakeLog( { aLogFile, aMarcImp } , { 'Log de Ocorrencias:', OemToAnsi("Não há marcações ímpares para o período selecionado") } , NIL , .T. , FunName() )    
EndIf
return lRet



Static Function GeraPerg(cPerg) 
Local aRegs:= {}

aAdd(aRegs,{cPerg,"01","Filial"         ,"Filial De"        ,"Filial De"       ,"mv_ch1","C",06,0,0,"G"," ","mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"02","Filial Ate"     ,"Filial Ate"       ,"Filial Ate"      ,"mv_ch2","C",06,0,0,"G","naovazio()","mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"03","Centro Custo"   ,"Centro Custo De"  ,"Centro Custo De" ,"mv_ch3","C",09,0,0,"G"," ","mv_par03","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"04","Centro Ate"     ,"Centro Custo Ate" ,"Centro Custo Ate","mv_ch4","C",09,0,0,"G","naovazio()","mv_par04","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"05","Matricula"      ,"Matricula De"     ,"Matricula De"    ,"mv_ch5","C",06,0,0,"G"," ","mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"06","Matricula Ate"  ,"Matricula Ate"    ,"Matricula Ate"   ,"mv_ch6","C",06,0,0,"G","naovazio()","mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"07","Data de"        ,"Data de"          ,"Data de"         ,"mv_ch7","D",08,0,0,"G","naovazio()","mv_par07","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Data Ate"       ,"Data ate"         ,"Data ate"        ,"mv_ch8","D",08,0,0,"G","naovazio()","mv_par08","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Depto de"       ,"Depto De"         ,"Depto De"        ,"mv_ch9","C",09,0,0,"G"," ","mv_par09","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Depto Ate"      ,"Depto Ate"        ,"Depto Ate"       ,"mv_ch9","C",09,0,0,"G","naovazio()","mv_par10","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
U_BuscaPerg(aRegs)
Return
