#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/11/00
/*/{Protheus.doc} ValUser
//TODO Funcao validar usuario logado, para liberacao ou nao dos acessos
@author Tiago Santos
@since 22/04/2020
@type function
justes para gera??o na vers?o 12.1.25
/*/

user function ContRateio()

Local cPerg := "CONTRATEIO" 
if !u_ValUser(RetCodUsr( ))
	MsgBox("Usuario sem acesso " ,"Atencao","ALERT")	      	
	return
Endif
ValidPerg(cPerg)

If !Pergunte (PadR(cPerg,10),.T.)
	Return
Else
	cData := DTOS(MV_PAR01)
    dData := MV_PAR01  
     Processa({|| ProcRat(dData)}, "Processando dados", "Aguarde...")
EndIf  

RETURN

Static Function ProcRat(dData)
Local cQuery:=""
Local aContas :={}


cQuery := Query()

if Select("TRB") <> 0
    TRB->(DbCloseArea())
endif
TcQUERY cQuery NEW ALIAS "TRB"

TRB->(dbgotop())
//Inclusão/Alteração na tabela CT2(Cabeçalho é gravados como crédito)
lMSHelpAuto := .t. // para mostrar os erros na tela
lMsErroAuto := .f.

//Para esse tipo de lançamento, foi estabelecido o lote = '008860' e sublote = '001',
_cLote     := '008863'
_dData     := MV_PAR01//STOD(cMesFn)
_cSbLote  := '001'

// Obtem o novo DOC
_cDoc := GetLot(_cLote, _dData, _cSbLote)
aCab := {} // Array com dados do CABECALHO para a tabela CT2
aTotItem := {}
aCab  := {{"dDataLanc"   ,_dData    ,NIL},;
{"cLote"       ,_clote    ,NIL},;
{"cSubLote"    ,_cSblote  ,NIL},;
{"cDoc"        ,_cDoc     ,NIL},;
{"NTOTINF"     ,0         ,NIL},;
{"NTOTINFLOT"  ,0         ,NIL}}

nLinha := 1                        
cHist := 'VLR REF RATEIO DESP FOLHA '
cDc := '3' // sempre sera partida dobrada

While TRB->( !EOF())
    IncProc("Processando registros. Aguarde...")

    cHist := TRB->RV_LCTOP + " Rateio Folha " + Substr(DtoS(_dData),5,2) +"."+Substr(DtoS(_dData),1,4)
	cHist += " - "+TRB->RD_PD
    aAdd(aTotItem,{ {'CT2_FILIAL' ,'  ' , NIL},;
    {'CT2_LINHA' ,StrZero(nLinha,3) , NIL},;
    {'CT2_MOEDLC' ,'01' , NIL},;
    {'CT2_DC' ,cDc , NIL},; // 1-Debito  2-Credito 3-Partida Dobrada
    {"CT2_CREDIT"  , Alltrim( TRB->CT5_DEBITO )             , NIL},;
    {"CT2_DEBITO"  , alltrim( TRB->Z42_CCONTA )             , NIL},;
    {'CT2_VALOR' , TRB->RATEADO , NIL},; // Valor do lan?amento
    {'CT2_ORIGEM' ,'MSEXECAUT', NIL},;
    {'CT2_HP' ,'' , NIL},;
    {"CT2_ITEMC"  ,'001'            , Nil},;
    {"CT2_CCC"    ,TRB->RA_CC  , Nil},;
    {"CT2_CCD"    ,TRB->Z40_CC  , Nil},;
    {"CT2_MANUAL"   ,'2'                  , Nil},;
    {"CT2_TPSAL1"   ,'2'                  , Nil},;
    {"CT2_AGLUT"    ,'1'                  , Nil},;
    {"CT2_ROTINA"    ,'ContRateio'                  , Nil},;
    {"CT2_LP"       ,TRB->RV_LCTOP                  , Nil},; // LP
    {"CT2_CRCONV"    ,'1'                  , Nil},;
    {"CT2_DTCV3"    ,mv_par01                  , Nil},;
    {'CT2_HIST' ,cHist, NIL} } )

    nLinha ++
    TRB->( DbSkip())
Enddo

MSExecAuto({|x,y,Z| Ctba102(x,y,Z)},aCab,aTotItem,3)

If lMsErroAuto
	MostraErro()
Else 
	MsgInfo("Rateio Finalizado! Favor verificar.")
EndIf

Return




Static Function GetLot(_cLote, _dData, _cSbLote)

CT2->(dbSetOrder(1))
if (CT2->(dbSeek(xFilial("CT2")+DTOS(_dData)+_cLote+_cSbLote)))
	
	cQuery := " SELECT MAX(CT2_DOC) + 1 AS ULTIMO "
	cQuery += " FROM " + RetSqlName("CT2") + " CT2 "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND CT2_DATA = '"+DTOS(_dData)+"' "
	cQuery += " AND CT2_LOTE = '"+_cLote+"' "
	cQuery += " AND CT2_SBLOTE = '"+_cSbLote+"' "
	
	TcQuery cQuery new Alias "QWZ"
	_cDoc := STRZERO(QWZ->ULTIMO,6)
	QWZ->(dbCloseArea())
else
	_cDoc := '000001'
endif

Return _cDoc            

static function Query()

cQuery := " With RATEIO as ("
cQuery += "    select Z39_DTINIC, Z39_DATAFI,Z39_VIGENC,Z39_FILIAL, Z39_FUNCIO,Z39_NUM, Z40.*, RA_NOME, RA_CC from "+RetSqlName("Z39")+" Z39"
cQuery += "     inner join "+RetSqlName("Z40")+" Z40 on Z39_FILIAL = Z40_FILIAL and Z39_NUM = Z40_NUM"
cQuery += "     inner join "+RetSqlName("SRA")+" SRA on Z39_FILIAL = RA_FILIAL and Z39_FUNCIO = RA_MAT"
cQuery += "     Where Z39.D_E_L_E_T_ =' ' and Z40.D_E_L_E_T_ =' ' and SRA.D_E_L_E_T_ =' ' "
cQuery += "     and Z39_FILIAL between ' ' and '99'"
cQuery += "     and RA_CC between ' ' and 'ZZZZZZZZZ'"
cQuery += "     and RA_MAT between ' ' and 'ZZZZZZ'"
cQuery += "     and Z39_NUM between ' ' and 'ZZZZZZ' "
cQuery += " ),"
cQuery += " FOLHA as ("
cQuery += " select RD_FILIAL,RD_MAT, RD_PD, RD_VALOR, TRIM(CT5_DEBITO) CT5_DEBITO , RV_LCTOP,Z42_CCONTA"
cQuery += "  from " + RetSqlName("SRD")+" SRD"
cQuery += " inner join "+RetSqlName("SRV")+" SRV on RD_PD = RV_COD and SRV.D_E_L_E_T_ =' '"
cQuery += " inner join "+RetSqlName("CT5")+" CT5 on RV_LCTOP = CT5_LANPAD"
cQuery += " inner join "+RetSqlName("Z42")+" Z42 on RD_PD = Z42_VERBA "
cQuery += " Where SRD.D_E_L_E_T_ =' ' and RD_DATARQ ='" + AnoMes(mv_par01)+"' and RV_CONTABI ='S'"
cQuery += " and CT5_DC in ('1','3')"
cQuery += " )"
cQuery += " select  Z39_FILIAL,Z39_FUNCIO, Z40_CC, Z40_PERCRA , RD_PD, RD_VALOR, round(RD_VALOR * Z40_PERCRA /100,2) RATEADO, CT5_DEBITO"
cQuery += " , RV_LCTOP , RA_CC , Z42_CCONTA from RATEIO "
cQuery += " inner join FOLHA on Z39_FILIAL = RD_FILIAL and Z39_FUNCIO = RD_MAT"
cQuery += " where Z39_DATAFI <= '" + AnoMes(mv_par01)+"'  and Z39_DTINIC <= '" + AnoMes(mv_par01)+"' "
cQuery += " order by Z40_FUNCIO, Z40_SEQ"
Return cQuery 
//----------------------------------------//
// Perguntas do Rateio -------------------//
//----------------------------------------//

Static Function ValidPerg(cPerg)

SX1->(DbSetOrder(1))
If !SX1->(dbSeek(cPerg+'01'))
	RecLock("SX1",.T.)
	SX1->X1_GRUPO   := cPerg
	SX1->X1_ORDEM   := '01'
	SX1->X1_PERGUNT := 'Data de inicio?'
	SX1->X1_PERSPA  := 'Data de inicio?'
	SX1->X1_PERENG  := 'Data de inicio?'
	SX1->X1_VARIAVL := 'mv_ch1'
	SX1->X1_VAR01   := 'MV_PAR01'
	SX1->X1_GSC     := 'G'
	SX1->X1_TIPO    := 'D'
	SX1->X1_TAMANHO := 8
	MsUnlock("SX1")
EndIf

Return
