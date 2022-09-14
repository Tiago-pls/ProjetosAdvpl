#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#include 'tbiconn.ch'
#include "RWMAKE.CH"
#include 'parmtype.ch'
#Define ENTER  ''
User function MDM(lSchedule)


MsAguarde({|| u_GeraXML(lSchedule)}, "Aguarde...", "Processando Registros...")

Return
user function GeraXML(lSchedule)
Local cXML        := ""

Local cPerg		  := "XMLMDM"
Local cPL         := Chr(13) + Chr(10) 
Local nHrsMes     := 220//GetMv("MV_HRSMES")
Default lSchedule := .T.
private nHandle     := 0 
// atualizar o campo RA_MDMCOD com o retorno do MDM
//u_FROMMDM()

cDir        :="c:\temp\"
cArq        := "PayrollExtraction_TOTVS_"+dTos(dDatabase)+'_'+Left(StrTran(TIME(),':',''),4)+".xml"

//Cria a pergunta de acordo com o tamanho da SX1
dbSelectArea("SX1")  
dbSetOrder(1)
cPerg := cPerg+Replicate(" ",Len(X1_GRUPO)- Len(cPerg))
		
//Carrega os Parâmetros
//********************************************************************************
GeraPerg(cPerg)

If !Pergunte(cPerg,.T.)
   Return
Endif

cQuery := " Select RA_FILIAL, RA_MAT, RA_NOMECMP,RA_SEXO,RA_LOGRNUM, RA_COMPLEM, RA_LOGRDSC, RA_CEP, RA_MUNICIP, RA_ESTADO, RA_XPAIS, ZRA_BSMID, "         +cPL
cQuery += " SubString(RA_ADMISSA,1,4)+'-'+SubString(RA_ADMISSA,5,2)+'-'+ SubString(RA_ADMISSA,7,2) RA_ADMISSA, RA_XLGSTAR, "                            +cPL
cQuery += " SubString(RA_DEMISSA,1,4)+'-'+SubString(RA_DEMISSA,5,2)+'-'+ SubString(RA_DEMISSA,7,2) RA_DEMISSA, "                                        +cPL
cQuery += " RA_CATFUNC,RA_SITFOLH, RJ_DESC,RA_XCHAVE, RA_CC, RA_CLVL,RA_HRSMES, RA_XCOURDT,ZRA_XJOBRE, RA_GRINRAI, "                                    +cPL
cQuery += " Case When RA_SITFOLH ='D' then '1' else '2' end SITUACAO, RA_SEXO,  RA_XPOOLST, ZRA_XHRDTI, "                                               +cPL
cQuery += " SubString(RA_NASC,1,4)+'-'+SubString(RA_NASC,5,2)+'-'+ SubString(RA_NASC,7,2) RA_NASC,"                                                     +cPL
cQuery += " (select ZR1_PAYCOD from " +RetSqlName("ZR1")+ " ZR1 Where ZR1.D_E_L_E_T_ =' ' and ZR1_TAB ='LGS' and ZR1_PRVALU =   RA_XLGSTAT) RA_XLGSTAT,"  +cPL
cQuery += " (select ZR1_PAYCOD from " +RetSqlName("ZR1")+ " ZR1 Where ZR1.D_E_L_E_T_ =' ' and ZR1_TAB ='EXP' and ZR1_PRVALU = RA_XEXPATR) RA_XEXPATR,"  +cPL
cQuery += " (select ZR1_PAYCOD from " +RetSqlName("ZR1")+ " ZR1 Where ZR1.D_E_L_E_T_ =' ' and ZR1_TAB ='TSO' and ZR1_PRVALU = ZRA_TRVORG) ZRA_TRVORG,"  +cPL
cQuery += " (select ZR1_PAYCOD from " +RetSqlName("ZR1")+ " ZR1 Where ZR1.D_E_L_E_T_ =' ' and ZR1_TAB ='GCT' and ZR1_PRVALU = RA_TPCONTR) RA_TPCONTR,"  +cPL
cQuery += " (select ZR1_PAYCOD from " +RetSqlName("ZR1")+ " ZR1 Where ZR1.D_E_L_E_T_ =' ' and ZR1_TAB ='BU'  and ZR1_PRVALU = RA_XAREAOR) RA_XAREAOR,"  +cPL
cQuery += " (select ZR1_PRVALU from " +RetSqlName("ZR1")+ " ZR1 Where ZR1.D_E_L_E_T_ =' ' and ZR1_TAB ='GLP' and ZR1_PAYCOD = RA_FILIAL) RA_GLP,"       +cPL
cQuery += " (select ZR1_MDMDES from " +RetSqlName("ZR1")+ " ZR1 Where ZR1.D_E_L_E_T_ =' ' and ZR1_TAB ='GLP' and ZR1_PAYCOD = RA_FILIAL) RA_DTFILIAL,"  +cPL
cQuery += " (select ZR1_PAYCOD from " +RetSqlName("ZR1")+ " ZR1 Where ZR1.D_E_L_E_T_ =' ' and ZR1_TAB ='CRH' and ZR1_PRVALU = RA_XMOTCON) RA_XMOTCON,"  +cPL
cQuery += " (select ZR1_PAYCOD from " +RetSqlName("ZR1")+ " ZR1 Where ZR1.D_E_L_E_T_ =' ' and ZR1_TAB ='RTH' and ZR1_PRVALU = RA_XMOTCTE) RA_XMOTCTE,"  +cPL
cQuery += " (select ZR1_PAYCOD from " +RetSqlName("ZR1")+ " ZR1 Where ZR1.D_E_L_E_T_ =' ' and ZR1_TAB ='DPM' and ZR1_PRVALU = RA_XCOURSE) RA_XCOURSE,"  +cPL
cQuery += " ZRA_JOBREP, ZRA_XJOBRE , RE_DATA, RA_XPOOLID, ZRA_BHIERM, ZRA_TRANSD, ZRA_BHRMAN,"                                                          +cPL
cQuery += " case"                                                                                                                                       +cPL
cQuery += "  when RA_CATFUNC ='M' then (select ZR1_PAYCOD from ZR1020 ZR1 Where ZR1.D_E_L_E_T_ =' ' and ZR1_TAB ='GCT' and ZR1_CODE ='M') "             +cPL
cQuery += "  when RA_CATFUNC IN('A','P') then (select ZR1_PAYCOD from ZR1020 ZR1 Where ZR1.D_E_L_E_T_ =' ' and ZR1_TAB ='GCT' and ZR1_CODE ='A') "      +cPL
cQuery += "  when RA_TPCONTR ='2' then (select ZR1_PAYCOD from ZR1020 ZR1 Where ZR1.D_E_L_E_T_ =' ' and ZR1_TAB ='GCT' and ZR1_CODE =RA_TPCONTR) "      +cPL
cQuery += "  when RA_TPCONTR ='3' then (select ZR1_PAYCOD from ZR1020 ZR1 Where ZR1.D_E_L_E_T_ =' ' and ZR1_TAB ='GCT' and ZR1_CODE =RA_TPCONTR) "      +cPL
cQuery += "  when RA_CATFUNC IN ('E','G') then (select ZR1_PAYCOD from ZR1020 ZR1 Where ZR1.D_E_L_E_T_ =' ' and ZR1_TAB ='GCT' and ZR1_CODE ='E') "     +cPL
cQuery += "  when RA_CATEG   = '07' then (select ZR1_PAYCOD from ZR1020 ZR1 Where ZR1.D_E_L_E_T_ =' ' and ZR1_TAB ='GCT' and ZR1_CODE ='7') "           +cPL
cQuery += " End"                                                                                                                                        +cPL
cQuery += " TPCONTR "                                                                                                                                   +cPL
cQuery += " from "+ RetSqlName("SRA") +" SRA"                                                                                                           +cPL
cQuery += " left join " + RetSqlName("ZRA") + " ZRA on RA_FILIAL = ZRA_FILIAL and RA_MAT = ZRA_MAT"                                                    +cPL
cQuery += " Left join  " + RetSqlName("SRJ") + " SRJ on RA_CODFUNC = RJ_FUNCAO"                                                                         +cPL
cQuery += " Left join SRE010 SRE on SRE.D_E_L_E_T_ =' ' and RA_FILIAL = RE_FILIALP and RA_MAT = RE_MATP and RE_EMPD <> RE_EMPP"                         +cPL
cQuery += " Where SRA.D_E_L_E_T_ =' ' "                                                                                                                 +cPL
cQuery += " And RA_FILIAL >= '" + MV_PAR01 + "' and RA_FILIAL <= '" + MV_PAR02 + "'"                                                                    +cPL
cQuery += " And RA_CC     >= '" + MV_PAR03 + "' and RA_CC     <= '" + MV_PAR04 + "'"                                                                    +cPL
cQuery += " And RA_MAT    >= '" + MV_PAR05 + "' and RA_MAT    <= '" + MV_PAR06 + "'"                                                                    +cPL
cQuery += " And RA_SITFOLH <> 'T' and RA_MDMCOD =' ' "                                                                                                  +cPL
cQuery += " order by 1,2 "                                                                                                                              +cPL  

if select("XML") > 0
    XML->( dbcloseArea())
Endif
TcQuery cQuery New Alias "XML" 
cCategoria := MV_PAR08
cSit       := MV_PAR07
nHandle := FCreate(cDir+cArq)
If nHandle < 0
    ConOut("Erro durante criação do arquivo.")
    Return
Endif

// Nome Filial   		
SM0->(dbSetOrder(1))
nRecnoSM0 := SM0->(Recno())
nCont := 0
if XML->(! EOF())

    cXML := '<?xml version="1.0" encoding="UTF-8"?>' + ENTER
    cXML +="<Employees>" + ENTER
    While XML->(! EOF())
        If !(XML->RA_CATFUNC $ cCategoria)
            XML->(dbSkip())
            Loop
        Endif

        If !(XML->RA_SITFOLH $ cSit)
            XML->(dbSkip())
            Loop
        Endif
        If XML->RA_CATFUNC $ 'A|P' .and. !(Alltrim(XML->RA_XEXPATR) $ 'O|I')
            XML->(dbSkip())
            Loop
        Endif
        nCOnt +=1
        cInicio := iif(empty(XML->RE_DATA), XML->RA_ADMISSA , transform(XML->RE_DATA,"@R 9999-99-99") )
        cPool   := iif(empty(XML->RA_XPOOLST), XML->RA_ADMISSA , subStr(XML->RA_XPOOLST, 1,4)+'-' +subStr(XML->RA_XPOOLST, 5,2)+'-'+subStr(XML->RA_XPOOLST, 7,2))
        cTpResc := ""
        If XML->RA_SITFOLH ='D'            
            SRG->( DbGotop())
            if SRG->( DbSeek(XML->(RA_FILIAL + RA_MAT)))                
                cTpResc := SRG->RG_TIPORES
            else
                cTpResc := '01'
            endif 
            cDataDemi   := XML->RA_DEMISSA
        else
                cDataDemi:=""
        Endif
        cdata := u_RetCCData(XML->RA_FILIAL, XML->RA_MAT, XML->RA_CC)
        cDataCC := iif(Empty(cdata), XML->RA_ADMISSA, transform(cdata,"@R 9999-99-99"))
        cAgnome:= Alltrim(U_Agnome(Alltrim(XML->RA_NOMECMP)))
        cTrans:=''
        cDtCurso := ""
        cLGStar :=""
        cJob:=""
        cHR :=""
        //cDiplomaId :=Alltrim(posicione('SX5',1,xFilial("SX5")+"26" + , 'X5_DESCRI'))


        if !Empty(XML->ZRA_TRANSD)
            cTrans:= SubString(XML->ZRA_TRANSD,1,4)+'-'+SubString(XML->ZRA_TRANSD,5,2)+'-'+ SubString(XML->ZRA_TRANSD,7,2) 
        endif
        if !Empty(XML->RA_XCOURDT)
            cDtCurso:= SubString(XML->RA_XCOURDT,1,4)+'-'+SubString(XML->RA_XCOURDT,5,2)+'-'+ SubString(XML->RA_XCOURDT,7,2) 
        endif 
        if !Empty(XML->RA_XLGSTAR)
            cLGStar:= SubString(XML->RA_XLGSTAR,1,4)+'-'+SubString(XML->RA_XLGSTAR,5,2)+'-'+ SubString(XML->RA_XLGSTAR,7,2) 
        endif 
        if !Empty(XML->ZRA_XJOBRE)
            cJob:= SubString(XML->ZRA_XJOBRE,1,4)+'-'+SubString(XML->ZRA_XJOBRE,5,2)+'-'+ SubString(XML->ZRA_XJOBRE,7,2) 
        endif 
        if !Empty(XML->ZRA_XHRDTI)
            cHR= SubString(XML->ZRA_XHRDTI,1,4)+'-'+SubString(XML->ZRA_XHRDTI,5,2)+'-'+ SubString(XML->ZRA_XHRDTI,7,2) 
        endif

  
        SM0->(dbSeek(FWCodEmp() +XML->RA_FILIAL))
        if nCOnt < 10000
            cXML += "<Employee>"+ ENTER
            cXML += '<Employee_Group_Id>'+alltrim(StrZero(val(XML->ZRA_BSMID),8))+'</Employee_Group_Id>'+ ENTER
            cXML += '<Employee_Local_Payroll_Id>'+Alltrim(XML->RA_MAT)+'</Employee_Local_Payroll_Id>'+ ENTER
            cXML += '<Employee_Payroll_System>LSABR-TOTVS</Employee_Payroll_System>'+ ENTER
            cXML += '<Employee_Payroll_System_Start_Date>'+XML->RA_ADMISSA+'</Employee_Payroll_System_Start_Date>'+ ENTER
            cXML += '<Group_Start_Date>'+XML->RA_ADMISSA+'</Group_Start_Date>'+ENTER
            cXML += ' <General_Information>'+ ENTER
            cXML += '    <First_Name>'+Alltrim( Substr(XML->RA_NOMECMP, 1 , At(' ',XML->RA_NOMECMP)))+'</First_Name>'+ ENTER
            cXML += '    <First_Name_WC>'+Alltrim( Substr(XML->RA_NOMECMP, 1 , At(' ',XML->RA_NOMECMP)))+'</First_Name_WC>'+ ENTER
            cXML += '    <Name>'+cAgnome+'</Name>'+ ENTER
            cXML += '    <Name_WC>'+cAgnome+'</Name_WC>'+ ENTER
            cXML += '    <Maiden_Name></Maiden_Name>'+ ENTER
            cXML += '    <Gender>'+Alltrim(XML->RA_SEXO) +'</Gender>'+ ENTER
            cXML += '    <Title></Title>'+ ENTER
            cXML += '    <Civility></Civility>'+ ENTER
            cXML += '    <Nationality_1>'+Alltrim(XML->RA_XPAIS)+'</Nationality_1>'+ ENTER
            cXML += '    <Nationality_2></Nationality_2>'+ ENTER
            cXML += '    <Disabled>' + alltrim(XML->SITUACAO) + '</Disabled>'+ ENTER
            cXML += '    <Children_Number_In_Charge></Children_Number_In_Charge>'+ ENTER
            cXML += '    <Children_Number></Children_Number>'+ ENTER
            cXML += '    <Birth>'+ ENTER
            cXML += '        <Birth_Date>'+XML->RA_NASC+'</Birth_Date>'+ ENTER
            cXML += '        <Birth_Place_Country></Birth_Place_Country>'+ ENTER
            cXML += '        <Birth_Place_State></Birth_Place_State>'+ ENTER
            cXML += '        <Birth_Place_Town></Birth_Place_Town>'+ ENTER
            cXML += '    </Birth>'+ ENTER
            cXML += '    <Address>'+ ENTER
            cXML += '        <Address_Street_Number>'+Alltrim(XML->RA_LOGRNUM)+'</Address_Street_Number>'+ ENTER
            cXML += '        <Address_Street_Number_Complement></Address_Street_Number_Complement>'+ ENTER
            cXML += '        <Address_Street_Type></Address_Street_Type>'+ ENTER
            cXML += '        <Address_Street_Name></Address_Street_Name>'+ ENTER
            cXML += '        <Address_Adress_Complement></Address_Adress_Complement>'+ ENTER
            cXML += '        <Address_Zip_Code></Address_Zip_Code>'+ ENTER
            cXML += '        <Address_City>'+Alltrim(XML->RA_MUNICIP)+'</Address_City>'+ ENTER
            cXML += '        <Address_Region_State>'+Alltrim(XML->RA_ESTADO)+'</Address_Region_State>'+ ENTER
            cXML += '        <Address_Country>BRA</Address_Country>'+ ENTER
            cXML += '    </Address>'+ ENTER
            cXML += '</General_Information>'+ ENTER
            cXML += '<Professionnal_Information>'+ ENTER
            cXML += '	    <Diplomas>'+ ENTER
            cXML += '	        <Diploma>'+ ENTER
            cXML += '	            <Diploma_ID>DIP_001</Diploma_ID>'+ ENTER
            cXML += '	 		    <Group_Diploma_Level></Group_Diploma_Level>'+ ENTER
            cXML += '	 		    <Local_Diploma_Level>'+Alltrim(XML->RA_GRINRAI)+'</Local_Diploma_Level>'+ ENTER
            cXML += '	 		    <Diploma_Major_1>'+Alltrim(XML->RA_XCOURSE)+'</Diploma_Major_1>'+ ENTER
            cXML += '	 		    <Diploma_Major_2></Diploma_Major_2>'+ ENTER
            cXML += '	 		    <Diploma_Location></Diploma_Location>'+ ENTER
            cXML += '	 		    <Diploma_School_Name></Diploma_School_Name>'+ ENTER
            cXML += '	 		    <Diploma_Date_Of_Graduation>'+Alltrim(cDtCurso)+'</Diploma_Date_Of_Graduation>'+ ENTER
            cXML += '	 		    <Diploma_Name></Diploma_Name>'+ ENTER
            cXML += '	 		</Diploma>'+ ENTER
            cXML += '	    </Diplomas>'+ ENTER
            cXML += '        <Job_Repository_Family>'+Alltrim(u_TrataCar(XML->ZRA_JOBREP))+'</Job_Repository_Family>'+ ENTER
            cXML += '        <Job_Repository_Attachement_Start_Date>'+Alltrim(cJob)+'</Job_Repository_Attachement_Start_Date>'+ ENTER
            cXML += '        <Payroll_Job_Title>'+Alltrim(XML->RJ_DESC)+'</Payroll_Job_Title>'+ ENTER
            cXML += '        <Payroll_Job_Title_Start_Date>'+cInicio+'</Payroll_Job_Title_Start_Date>'+ ENTER
            cXML += '        <Limagrain_Status>'+Alltrim(XML->RA_XLGSTAT)+'</Limagrain_Status>'+ ENTER
            cXML += '        <Limagrain_Status_Start_Date>'+Alltrim(cLGStar)+'</Limagrain_Status_Start_Date>'+ ENTER
            cXML += '        <Local_Status></Local_Status>'+ ENTER
            cXML += '        <Local_Status_Start_Date></Local_Status_Start_Date>'+ ENTER
            cXML += '    </Professionnal_Information>'+ ENTER
            cXML += '    <Management_Organization>'+ ENTER
            cXML += '        <Expatriate>' +Alltrim(XML->RA_XEXPATR)+'</Expatriate>'+ ENTER
            cXML += '        <Expatriate_Start_Date>'+Iif( XML->RA_XEXPATR = 'N','',XML->RA_ADMISSA)+'</Expatriate_Start_Date>'+ ENTER
            cXML += '        <Expatriate_End_Date></Expatriate_End_Date>'+ ENTER
            cXML += '        <Type_Of_Expatriate>'+Iif( XML->RA_XEXPATR = 'N','','TE001')+'</Type_Of_Expatriate>'+ ENTER
            cXML += '        <Organizations>'+ ENTER
            cXML += '            <Organization>'+ ENTER
            cXML += '                <Transversal_Organization>'+Alltrim(XML->ZRA_TRVORG)+'</Transversal_Organization>'+ ENTER
            cXML += '                <Transversal_Organization_Start_Date>'+cTrans+'</Transversal_Organization_Start_Date>'+ ENTER
            cXML += '                <Transversal_Organization_End_Date></Transversal_Organization_End_Date>'+ ENTER
            cXML += '            </Organization>'+ ENTER
            cXML += '        </Organizations>'+ ENTER
            cXML += '        <Pools>'+ ENTER
            cXML += '            <Pool>'+ ENTER
            cXML += '                <Pool_Identification>'+Alltrim(XML->RA_XPOOLID)+'</Pool_Identification>'+ ENTER
            cXML += '                <Pool_Identification_Start_Date>'+Iif( Empty(Alltrim(XML->RA_XPOOLID)),'',cPool)+'</Pool_Identification_Start_Date>'+ ENTER
            cXML += '                <Pool_Identification_End_Date></Pool_Identification_End_Date>'+ ENTER
            cXML += '            </Pool>'+ ENTER
            cXML += '        </Pools>'+ ENTER
            cXML += '        <Management>'+ ENTER
            cXML += '            <Employee_HR_Manager_Group_ID>'+alltrim(StrZero(val(XML->ZRA_BHRMAN),8))+'</Employee_HR_Manager_Group_ID>'+ ENTER
            cXML += '            <Employee_HR_Manager_Start_Date>'+alltrim(cHR)+'</Employee_HR_Manager_Start_Date>'+ ENTER
            cXML += '            <Employee_Direct_Line_Manager_Group_ID>'+alltrim(StrZero(val(XML->ZRA_BHIERM),8))+'</Employee_Direct_Line_Manager_Group_ID>'+ ENTER
            cXML += '            <Employee_Direct_Line_Manager_Start_Date>'+cInicio+'</Employee_Direct_Line_Manager_Start_Date>'+ ENTER
            cXML += '            <Employee_Other_Manager_Group_ID></Employee_Other_Manager_Group_ID>'+ ENTER
            cXML += '            <Employee_Other_Manager_Start_Date></Employee_Other_Manager_Start_Date>'+ ENTER
            cXML += '        </Management>'+ ENTER
            cXML += '    </Management_Organization>'+ ENTER
            cXML += '    <Legal_Information>'+ ENTER
            cXML += '        <Contract>'+ ENTER
            cXML += '            <ID_Contract>'+Alltrim(XML->RA_XCHAVE)+'</ID_Contract>'+ ENTER
            //cXML += '            <Local_Contract_Type>'+Alltrim(XML->TPCONTR)+'</Local_Contract_Type>'+ ENTER
            cXML += '            <Local_Contract_Type>'+iif(Alltrim(XML->RA_XEXPATR) =='I', 'GCT1',Alltrim(XML->TPCONTR))+'</Local_Contract_Type>'+ ENTER
            cXML += '            <Local_Contract_Type_Start_Date>'+cInicio+'</Local_Contract_Type_Start_Date>'+ ENTER
            cXML += '            <Local_Contract_Type_End_Date></Local_Contract_Type_End_Date>'+ ENTER
            cXML += '            <Contract_Nature></Contract_Nature>'+ ENTER
            cXML += '            <Contract_Nature_Start_Date></Contract_Nature_Start_Date>'+ ENTER
            cXML += '            <Contract_Nature_End_Date>'+Iif( XML->RA_DEMISSA='D', XML->RA_DEMISSA,'' )+'</Contract_Nature_End_Date>'+ ENTER
            cXML += '            <Contract_Reason_For_Hiring>'+Alltrim(XML->RA_XMOTCON)+'</Contract_Reason_For_Hiring>'+ ENTER
            cXML += '            <Contract_Reason_For_Departure>'+alltrim(cTpResc)+'</Contract_Reason_For_Departure>'+ ENTER
            cXML += '            <Local_Contract_Reason_For_Temporary_Hiring>'+Alltrim(XML->RA_XMOTCTE)+'</Local_Contract_Reason_For_Temporary_Hiring>'+ ENTER
            cXML += '            <Contract_First_End_Date_Of_Trial_Period></Contract_First_End_Date_Of_Trial_Period>'+ ENTER
            cXML += '            <Contract_Second_End_Date_Of_Trial_Period></Contract_Second_End_Date_Of_Trial_Period>'+ ENTER
            cXML += '            <Average_Hourly_Currency></Average_Hourly_Currency>'+ ENTER
            cXML += '            <Average_Hourly_Rate></Average_Hourly_Rate>'+ ENTER
            cXML += '            <Begin_Date_Hourly_Rate></Begin_Date_Hourly_Rate>'+ ENTER
            cXML += '        </Contract>'+ ENTER
            cXML += '        <Collective_Labour_Agreement></Collective_Labour_Agreement>'+ ENTER
            cXML += '        <Legal_Position_Level></Legal_Position_Level>'+ ENTER
            cXML += '        <Legal_Position_Level_Start_Date></Legal_Position_Level_Start_Date>'+ ENTER
            cXML += '        <Working_Time_Value>'+cValtoChar(Round((XML->RA_HRSMES / nHrsMes)*100,2))+'</Working_Time_Value>'+ ENTER
            cXML += '        <Working_Time_Start_Date>'+cDataCC+'</Working_Time_Start_Date>'+ ENTER
            cXML += '    </Legal_Information>'+ ENTER
            cXML += '    <Entities>'+ ENTER
            cXML += '        <Financials>'+ ENTER
            cXML += '            <Financial>'+ ENTER
            cXML += '                <Cost_Center_Code>'+alltrim(XML->RA_CLVL)+'</Cost_Center_Code>'+ ENTER
            cXML += '                <Cost_Center_Repartition>100</Cost_Center_Repartition>'+ ENTER
            cXML += '                <Cost_Center_Start_Date>'+cDataCC+'</Cost_Center_Start_Date>'+ ENTER
            cXML += '                <Cost_Center_End_Date></Cost_Center_End_Date>'+ ENTER
            cXML += '            </Financial>'+ ENTER
            cXML += '        </Financials>'+ ENTER
            cXML += '        <Geographical_Global_Localization></Geographical_Global_Localization>'+ ENTER
            cXML += '        <Geographical_Localization>'+alltrim(XML->RA_FILIAL)+'</Geographical_Localization>'+ ENTER
            cXML += '        <Geographical_Localization_Start_Date>'+XML->RA_ADMISSA+'</Geographical_Localization_Start_Date>'+ ENTER
            cXML += '        <Legal_Entity_Code>2</Legal_Entity_Code>'+ ENTER
            cXML += '        <Legal_Entity_Name>LIMAGRAIN BRASIL S.A.</Legal_Entity_Name>'+ ENTER
            cXML += '        <Legal_Entity_Start_Date>'+Alltrim(XML->RA_DTFILIAL)+'</Legal_Entity_Start_Date>'+ ENTER
            cXML += '        <BU_Organization_Level>'+alltrim(XML->RA_CLVL)+'</BU_Organization_Level>'+ ENTER
            cXML += '        <BU_Organization_Start_Date>'+cInicio+'</BU_Organization_Start_Date>'+ ENTER
            cXML += '    </Entities>'+ ENTER
            cXML += '</Employee>'+ ENTER     
            cXML += cPL           
        endif
        XML->(DbSkip())
    Enddo
    cXML +="</Employees>"
    cXML := U_TrataCar(cXML)
  
    FWrite(nHandle, cXML)
    FClose(nHandle)
Endif
SM0->(dbGoto(nRecnoSM0))

Return


//  Cria as perguntas na SX1                               
//********************************************************************************

Static Function GeraPerg(cPerg) 

Local aRegs:= {}

aAdd(aRegs,{cPerg,'01','Filial De' 			,'','','mv_ch1','C',2                  ,0,0,'G','','MV_PAR01','' ,'           ','','','','','','','','','','','','','','','','','','','','','','','SM0','','',''})
aAdd(aRegs,{cPerg,'02','Filial Até'			,'','','mv_ch2','C',2                  ,0,0,'G','','MV_PAR02','' ,'           ','','','','','','','','','','','','','','','','','','','','','','','SM0','','',''})
aAdd(aRegs,{cPerg,'03','Centro de Custo De' ,'','','mv_ch3','' ,TamSx3('RD_CC')[1] ,0,0,'G','           ','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','CTT','','',''})
aAdd(aRegs,{cPerg,'04','Centro de Custo Até','','','mv_ch4','' ,TamSx3('RD_CC')[1] ,0,0,'G' ,'           ','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','CTT','','',''})
aAdd(aRegs,{cPerg,'05','Matrícula De'		,'','','mv_ch5','' ,TamSx3('RA_MAT')[1],0,0,'G','           ','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','SRA' ,'','',''})
aAdd(aRegs,{cPerg,'06','Matrícula Até'		,'','','mv_ch6','' ,TamSx3('RA_MAT')[1],0,0,'G','           ','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','SRA' ,'','',''})
aAdd(aRegs,{cPerg,'07','Situacoes   '		,'','','mv_ch7','' ,5                  ,0,0,'G','fSituacao()','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','',''    ,'','',''})
aAdd(aRegs,{cPerg,'08','Categoria   '		,'','','mv_ch8','' ,12                 ,0,0,'G','fCategoria','MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','',''     ,'','',''})
U_BuscaPerg(aRegs)

return



user Function fDescRes(cCodigo,cConteudo,nPos1,nPos2,nPos3,nPos4,lValidFil)
Local cRet := ""

DEFAULT lValidFil := .F.

_aArea := GetArea()

If nPos1 = Nil
	nPos1 := 0
EndIf
If nPos2 = Nil
	nPos2 := 0
EndIf

If cCodigo <> Nil .AND. cConteudo <> Nil
	dbSelectArea( "RCC" )
	dbSetOrder(1)
	dbSeek(xFilial("RCC")+ cCodigo)
	While !Eof() .AND. RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC")+cCodigo
		If RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC")+cCodigo .AND. Alltrim(Substr(RCC->RCC_CONTEU,nPos1,nPos2)) == Alltrim(cConteudo)
			If !lValidFil .or. RCC->RCC_FIL == xFilial("RCC") .or. RCC->RCC_FIL == SRA->RA_FILIAL 
				cRet := Substr(RCC->RCC_CONTEU,nPos3,nPos4)
				Exit
			EndIf
		EndIf
		dBSkip()	
	EndDo
EndIf

RestArea(_aArea)
Return(cRet)           
user function RetCCData(cFil, cMat, cCC)
cQuery := " Select case when MAX(RE_DATA) is null then '' else MAX(RE_DATA) end RE_DATA from SRE010"
cQuery += " where D_E_L_E_T_ =' ' and RE_EMPP ='"+FWCodEmp()+"' and RE_FILIALP = '"+cFil+"' and RE_MATP = '"+ cMat+"'"
cQuery += " and RE_CCP ='"+cCC+"' and RE_CCD <> RE_CCP"
if select("QRY")>0
    QRY->( DbCloseArea())
Endif

TcQuery cQuery New Alias "QRY" 

Return QRY->RE_DATA


user function TrataCar(cTexto)
cTexto := Strtran(cTexto,"&","")
cTexto := Strtran(cTexto,"Ø","")
cTexto := Strtran(cTexto,"¿","")
cTexto := Strtran(cTexto,"¡","i")
cTexto := Strtran(cTexto,"‡","c")
cTexto := Strtran(cTexto,"Æ","a")
cTexto := Strtran(cTexto,"ƒ","a")
cTexto := Strtran(cTexto,"ˆ","e")
cTexto := Strtran(cTexto,"µ","a")
cTexto := Strtran(cTexto,"£","a")
cTexto := NoAcento(cTexto)
Return cTexto

user function Agnome(cNome)
Local cAgnomePar := GetMV("LG_AGNOME")
Local nPos := RAT(" ", cNome)

cAgnome := RIGHT(cNome , LEN(alltrim(XML->RA_NOMECMP)) - nPos)

While cAgnome $ cAgnomePar
    cNome:= Alltrim(SubStr(cNome, 1, nPos))
    nPos := RAT(" ", cNome)
    cAgnome := RIGHT(cNome , LEN(cNome) - nPos)
enddo

Return cAgnome
