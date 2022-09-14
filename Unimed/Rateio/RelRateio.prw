#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"    

/*/
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RATEIOFOL   º Autor ³ SIDNEY GAMA        º Data ³  24/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ LIQUIDI CAIXA BANCO FERIAS                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
/*/
User Function RelRateio
Local cTitle    := OemToAnsi("Relatorio Rateio FOL")
Local cHelp     := OemToAnsi("Relatorio Rateio FOL")
Local aOrdem 	:= {"Matricula","Nome","Rateio"}//
Local oRel
Local oDados
Private cPerg      := "RATEIOFOL"

If !Pergunte(cPerg,.T.)
   Return
Endif                                                       

//T?tulo do relat?rio no cabe?alho
cTitle := OemToAnsi("Relatorio Rateio FOL")

//Criacao do componente de impress?o
oRel := tReport():New("Relatorio Rateio FOL",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)

//Seta a orienta??o do papel
oRel:SetLandscape()

//Seta impress?o em planilha                      
oRel:SetDevice(4)                       

//Inicia a Sess?o
oDados := trSection():New(oRel,cTitle,{"SRA","CTT","Z39","Z40"},aOrdem)
//oDados:SetHeaderSection(.F.)    
//oDados:HeaderBreak()     
oDados:SetHeaderBreak()

cTipoRel := MV_PAR07
// Celulas comuns a todos os tipos de relat?rios
trCell():New(oDados,"Z39_FILIAL" 	,"QRY" ,"Filial"   	,"@!",02)
trCell():New(oDados,"Z39_NUM"	      ,"QRY" ,"Rateio"   	,"@!",06)
trCell():New(oDados,"Z39_FUNCIO" 	,"QRY" ,"Matricula"  	,"@!",06)
trCell():New(oDados,"RA_NOME" 	   ,"QRY" ,"Nome"     	,"@!",30)
trCell():New(oDados,"RA_CC"         ,"QRY" ,"C.Custo Func"     	,"@!",09)
trCell():New(oDados,"DESC_CC" 	   ,"QRY" ,"Desc Custo Fun" ,"@!",30)
trCell():New(oDados,"Z39_VIGENC" 	,"QRY" ,"Ativo" 	,"@!",10)
trCell():New(oDados,"Z39_DTINIC"    ,"QRY" ,"Dt Inic"    ,"@!",06) 
trCell():New(oDados,"Z39_DATAFI"	   ,"QRY" ,"Dt Fim"	,"@!",8)
trCell():New(oDados,"Z40_CC"	      ,"QRY" ,"C. Custo Rateio"	,"@!",9)
trCell():New(oDados,"DESC_CC_RAT" 	,"QRY" ,"Desc Custo Rateio" ,"@!",30)
trCell():New(oDados,"Z40_PERCRA"	   ,"QRY" ,"Perc"	,"@E 99.99 ",6)
trCell():New(oDados,"CUSTOTOTAL"	   ,"QRY" ,"Custo Funcionario"	,"@E 999,999,999.99",6)
trCell():New(oDados,"Z42_VERBA"	   ,"QRY" ,"Cod Verba"	,"@!",4)
trCell():New(oDados,"RV_DESC"	      ,"QRY" ,"Desc Verba"	,"@!",35)
trCell():New(oDados,"CUSTORATEADO"	,"QRY" ,"Custo Rateado"	,"@E 999,999,999.99",6)                                            	
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
_cQuery := Query(nOrdem)
TcQuery _cQuery New Alias "QRY"

TCSetField("QRY","Z39_DTINIC","D",8,0)  
TCSetField("QRY","Z39_DATAFI","D",8,0)  

If QRY->(!Eof())
	While QRY->(!Eof()) .and. !oRel:Cancel()  
	    	
		//Cancelado pelo usu?rio
		If oRel:Cancel()
			Exit
		EndIf
		
		oRel:IncMeter(10)
        
      oDados:Cell("DESC_CC"	 ):SetValue(alltrim(  POSICIONE("CTT",1,XFILIAL("CTT")+QRY->RA_CC,"CTT_DESC01")))  
      oDados:Cell("DESC_CC_RAT"):SetValue(alltrim(  POSICIONE("CTT",1,XFILIAL("CTT")+QRY->Z40_CC,"CTT_DESC01")))  
      oDados:Cell("CUSTOTOTAL"):SetValue(QRY->RD_VALOR)  
      oDados:Cell("CUSTORATEADO"):SetValue(QRY->RD_VALOR * (Z40_PERCRA /100))  	   
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
   sx1->x1_pergunt:='Centro de Custo de'
   sx1->x1_variavl:='mv_ch3'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=9
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par03'
   sx1->x1_f3     :='CTT'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"04")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='04'
   sx1->x1_pergunt:='Centro de Custo Até'
   sx1->x1_variavl:='mv_ch4'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=9
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par04'
   sx1->x1_f3     :='CTT'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"05")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='05'
   sx1->x1_pergunt:='Matrícula de'
   sx1->x1_variavl:='mv_ch5'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=6
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par05'
   sx1->x1_f3     :='SRA'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"06")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='06'
   sx1->x1_pergunt:='Matrícula Até'
   sx1->x1_variavl:='mv_ch6'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=6
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par06'
   sx1->x1_f3     :='SRA'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"07")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.F.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='07'
   sx1->x1_pergunt:='Rateio De'
   sx1->x1_variavl:='mv_ch7'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=6
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par07'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"08")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='08'
   sx1->x1_pergunt:='Rateio Até'
   sx1->x1_variavl:='mv_ch8'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=6
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par08'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"09")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
    sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='09'
   sx1->x1_pergunt:= 'Competencia'
   sx1->x1_variavl:='mv_ch9'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=8
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par09'
   sx1->(MsUnlock())
   
   dbSelectArea(_sAlias)
Return

static Function Query(nOrdem )
_cQuery := " With RATEIO as ("
   _cQuery += "select Z39_DTINIC, Z39_DATAFI,Z39_VIGENC,Z39_FILIAL, Z39_FUNCIO,Z39_NUM, Z40.*, RA_NOME, RA_CC from " + RetSqlName("Z39")+" Z39"
   _cQuery += " inner join " + RetSqlName("Z40")+" Z40 on Z39_FILIAL = Z40_FILIAL and Z39_NUM = Z40_NUM"
   _cQuery += " inner join " + RetSqlName("SRA")+" SRA on Z39_FILIAL = RA_FILIAL and Z39_FUNCIO = RA_MAT"
   _cQuery += " Where Z39.D_E_L_E_T_ =' ' and Z40.D_E_L_E_T_ =' ' and SRA.D_E_L_E_T_ =' ' "
   _cQuery += " and Z39_FILIAL between '" + mv_par01 + "' and '"+mv_par02+"'"
   _cQuery += " and RA_CC between '" + mv_par03 + "' and '"+mv_par04+"'"
   _cQuery += " and RA_MAT between '" + mv_par05 + "' and '"+mv_par06+"'"
   _cQuery += " and Z39_NUM between '" + mv_par07 + "' and '"+mv_par08+"'"
_cQuery += ") , "
_cQuery += " CUSTOFUN AS ("

_cQuery += " select RD_FILIAL,RD_MAT,Z42_VERBA, sum(RD_VALOR) RD_VALOR,  max(RV_DESC) RV_DESC from " + RetSqlName("SRD")+" SRD"
_cQuery += " inner join " + RetSqlName("SRV") +" SRV on RD_PD = RV_COD  "
_cQuery += " inner join " + RetSqlName("Z42") +" Z42 on RD_PD = Z42_VERBA"
_cQuery += " Where SRD.D_E_L_E_T_ =' ' and SRV.D_E_L_E_T_ =' ' and RD_DATARQ ='" + Alltrim(mv_par09)+"'"
_cQuery += " group by RD_FILIAL,RD_MAT, Z42_VERBA"
_cQuery += ")"
_cQuery += " select * from RATEIO "
_cQuery += " inner join CUSTOFUN on Z39_FILIAL = RD_FILIAL and Z39_FUNCIO = RD_MAT"
_cQuery += " where Z39_DATAFI <= '" + Alltrim(mv_par09) + "'  and Z39_DTINIC <= '" + Alltrim(mv_par09) + "' "
if nOrdem ==1
   _cQuery += " Order by Z39_FUNCIO , Z40_SEQ"
Elseif nOrdem ==2
   _cQuery += " Order by RA_NOME,  Z40_SEQ"
else
   _cQuery += " Order by Z39_NUM, Z40_SEQ"
Endif

Return _cQuery
