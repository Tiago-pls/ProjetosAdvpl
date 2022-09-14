#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"    

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  ImpLog       ¦ Autor ¦ Tiago Santos      ¦ Data ¦18.08.20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Impressão de Logs Z41	      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function RelLOG

Local cTitle    := OemToAnsi("Geracao Relatorio Log")
Local cHelp     := OemToAnsi("Geracao Relatorio Log")
Local aOrdem 	:= {"Rateio"}//
Local oRel
Local oDados
Private cPerg      := "RATEIOLOG"

//VldPerg(cPerg)

If !Pergunte(cPerg,.T.)
   Return
Endif                                                       

//T?tulo do relat?rio no cabe?alho
cTitle := OemToAnsi("Geracao Relatorio Log")

//Criacao do componente de impress?o
oRel := tReport():New("Geracao Relatorio Log",cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)

//Seta a orienta??o do papel
oRel:SetLandscape()

//Seta impress?o em planilha                      
oRel:SetDevice(4)                       

//Inicia a Sess?o
oDados := trSection():New(oRel,cTitle,{"Z41"},aOrdem)
oDados:SetHeaderBreak()


trCell():New(oDados,"Z41_FILIAL"   ,"QRY" ,"Filial"   	  ,"@!",02)
trCell():New(oDados,"Z41_NUM"  	  ,"QRY" ,"Rateio"   	  ,"@!",06)
trCell():New(oDados,"Z41_TIPO" 	  ,"QRY" ,"Tipo Rateio"   ,"@!",15)
trCell():New(oDados,"Z41_CAMPO"   ,"QRY" ,"Campo"   	  ,"@!",02)
trCell():New(oDados,"INF_ANTERIOR" ,"QRY" ,"Inf Anterior"  ,"@!",15)
trCell():New(oDados,"INF_ATUAL" 	  ,"QRY" ,"Inf Atual"     ,"@!",15)
trCell():New(oDados,"Z41_DTGRAV"   ,"QRY" ,"Data"   	     ,"@!",10)
trCell():New(oDados,"Z41_HRGRAV"   ,"QRY" ,"Horário"   	  ,"@!",15)
trCell():New(oDados,"Z41_NOME" 	  ,"QRY" ,"Usuário"       ,"@!",40)
 
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
TCSetField("QRY","Z41_DTGRAV","D",8,0) 
aSX3:= SX3->( GetArea())
If QRY->(!Eof())
	While QRY->(!Eof()) .and. !oRel:Cancel()  
	    	
		//Cancelado pelo usu?rio
		If oRel:Cancel()
			Exit
		EndIf
		if QRY->Z41_TIPO ='F'
         cRateio := "Rateio Folha de Pagamento"    
      else
         cRateio := "Rateio Contábil"
      Endif
      oDados:Cell("Z41_TIPO"):SetValue(cRateio)
   SX3->( DbsetOrder(2)) // Campo
   SX3->( DbSeek(QRY->Z41_CAMPO))
   cTipo := SX3->X3_TIPO

      cPrefix :="QRY->Z41_"
      
      DO CASE
         CASE cTipo =='C'
            oDados:Cell("INF_ANTERIOR"):SetValue(Alltrim(& (cPrefix + "TEXTOD")))
            oDados:Cell("INF_ATUAL"):SetValue( Alltrim(& (cPrefix + "TEXTOP")))

         CASE cTipo =='D'
         
            if & (cPrefix + "DATAD") <> " "
               cData := & (cPrefix + "DATAD")
               cData := SubStr(cData,7,2) + "/" + SubStr(cData,5,2) + "/"+SubStr(cData,1,4)
               oDados:Cell("INF_ANTERIOR"):SetValue( cData)
            else
               oDados:Cell("INF_ANTERIOR"):SetValue(  "")
            Endif

            if & (cPrefix + "DATAP") <> " "
               cData := & (cPrefix + "DATAP")
               cData := SubStr(cData,7,2) + "/" + SubStr(cData,5,2) + "/"+SubStr(cData,1,4)
               oDados:Cell("INF_ATUAL"):SetValue( cData )
            else
               oDados:Cell("INF_ATUAL"):SetValue(  "")
            Endif            
         CASE cTipo =='N'
            oDados:Cell("INF_ANTERIOR"):SetValue( & (cPrefix + "NUMERD"))
            oDados:Cell("INF_ATUAL"):SetValue(  & (cPrefix + "NUMERP"))
      ENDCASE

		oRel:IncMeter(10)        
	   oDados:PrintLine()
	   oDados:SetHeaderSection(.F.)    
		QRY->(dbSkip())		
	End
Else
	MsgInfo("N?o foram encontrados registros para os par?metros informados!")
    Return .F.
Endif
RestArea(aSX3)
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
   sx1->x1_pergunt:='Rateio FOL De'
   sx1->x1_variavl:='mv_ch3'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=6
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par03'
   sx1->x1_f3     :='Z39'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"04")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='04'
   sx1->x1_pergunt:='Rateio FOL Ate'
   sx1->x1_variavl:='mv_ch4'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=6
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par04'
   sx1->x1_f3     :='Z39'
   sx1->(MsUnlock())
      If !dbSeek(cPerg+"05")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='05'
   sx1->x1_pergunt:='Rateio Nfe De'
   sx1->x1_variavl:='mv_ch3'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=6
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par03'
   sx1->x1_f3     :='CTQ'
   sx1->(MsUnlock())

   If !dbSeek(cPerg+"06")
      RecLock("SX1",.T.)
   else
      RecLock("SX1",.f.)
   EndIf
   sx1->x1_grupo  :=cPerg
   sx1->x1_ordem  :='06'
   sx1->x1_pergunt:='Rateio Nfe Ate'
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
   sx1->x1_ordem  :='07'
   sx1->x1_pergunt:='Tipo'
   sx1->x1_variavl:='mv_ch5'
   sx1->x1_tipo   :='C'
   sx1->x1_tamanho:=1
   sx1->x1_decimal:=0
   sx1->x1_presel :=0
   sx1->x1_gsc    :='G'
   sx1->x1_var01  :='mv_par05'
   sx1->x1_f3     :=''
   sx1->(MsUnlock())

   dbSelectArea(_sAlias)
Return

Static Function Query()

_cQuery := "select * from " + RetSqlName("Z41") + " Z41"
_cQuery += " where Z41.D_E_L_E_T_ =' ' " 
_cQuery += " and Z41_FILIAL between '" + MV_PAR01+"' and '" + MV_PAR02+"' "

 
if MV_PAR07 = 1 // FOL
   _cQuery +=" and Z41_TIPO ='F'"
   _cQuery += " and Z41_NUM between '" + MV_PAR03+"' and '" + MV_PAR04+"' "
elseif MV_PAR07 = 2
   _cQuery +=" and Z41_TIPO ='C'"
   _cQuery += " and Z41_NUM between '" + MV_PAR03+"' and '" + MV_PAR04+"' "

else
   _cQuery += " and Z41_NUM between '" + MV_PAR03+"' and '" + MV_PAR04+"' "
   _cQuery += " and Z41_NUM between '" + MV_PAR05+"' and '" + MV_PAR06+"' "
endif
_cQuery += " order by Z41_NUM, Z41_TIPO, Z41_DTGRAV, Z41_HRGRAV "
Return _cQuery
