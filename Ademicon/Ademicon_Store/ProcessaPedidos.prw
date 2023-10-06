#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#Include "TBICONN.ch"
#include "Fileio.ch"

user function ProcPed
Local cTmp := "TMPPED"
PREPARE ENVIRONMENT EMPRESA '05' FILIAL '040101' TABLES 'SC5','SC6','SE4','SB1','SB2','SF4'

 If Select( cTmp ) > 0
    (cTmp)->( dbCloseArea() )
EndIf
 BeginSQL Alias cTmp
    select * from  %table:ZAL% ZAL
    WHERE         
    ZAL_STATUS =  '0' and
    ZAL.D_E_L_E_T_ = ' '
EndSQL
if select("SC5")==0
    DBSELECTAREA("SC5")
Endif
if select("ZAL")==0
    DBSELECTAREA("ZAL")
Endif
ZAL->( DBSETORDER( 1 ))

While (cTmp)->(!EOF())
	SC5->( DbOrderNickName('IDFLUIG'))
    if SC5->( DbSeek(xFilial("SC5") + (cTmp)->ZAL_IDFLUI))
	    conout("Pedido a ser faturado: "+ (cTmp)->ZAL_IDFLUI)
        cNota := pedToNf((cTmp)->ZAL_FILIAL, SC5->C5_NUM, '1')
        cChoosedState := iif (Empty(cNota), '77','62')
        
        if AtuFluig((cTmp)->ZAL_IDFLUI, cChoosedState)        
            ZAL->( DBGOTOP(  ))
            if ZAL->( dbseek((cTmp)->ZAL_FILIAL + (cTmp)->ZAL_IDFLUI)  )
                RECLOCK( "ZAL", .F. )
                    ZAL->ZAL_STATUS :=  '1'
                ZAL->(MSUNLOCK())
            Endif
        Endif
    Endif
    (cTmp)->(DbSkip())
enddo

RpcClearEnv()
Return


/*
+----------------------------------------------------------------------------------+
! Função    ! pedToNf     ! Autor ! Tiago Santos              ! Data !  19/05/2023 !
+-----------+--------------+-------+--------------------------+------+-------------+
! Parâmetros! cFilPed, cNumPed, cSerie                                             !
+-----------+----------------------------------------------------------------------+
! Retorno   ! Numero da Nota + Serie                                               !
+-----------+----------------------------------------------------------------------+
! Descricao ! fatura o pedido passado por parametro                                !
+-----------+----------------------------------------------------------------------+
*/

Static Function pedToNf(cFilPed, cNumPed, cSerie)

Local aArea		:= GetArea()
	Local aPvlNfs   := {}
	Local cNota

	SC9->(DbSetOrder(1))
	SC9->(DbSeek(cFilPed+cNumPed) )		// FILIAL+NUMERO+ITEM
	While !SC9->(Eof()) .and. SC9->C9_FILIAL+SC9->C9_PEDIDO == cFilPed+cNumPed
		SC5->(DbSetOrder(1))
		SC5->(DbSeek(xFilial("SC5")+cNumPed ) ) // FILIAL+NUMERO
		SC6->(DbSetOrder(1))
		SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM+SC9->C9_ITEM) )	// FILIAL+NUMERO+ITEM
		SE4->(DbSetOrder(1))
		SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG) )			// FILIAL+CONDPAG
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO) )			// FILIAL+PRODUTO
		SB2->(DbSetOrder(1))
		SB2->(DbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL) ) // FILIAL+PRODUTO+LOCAL
		SF4->(DbSetOrder(1))
		SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES ))                                   //FILIAL+CODIGO
          
		aAdd( aPvlNfs , {	SC5->C5_NUM, ;		// NUMERO PEDIDO
							SC9->C9_ITEM,;		// ITEM PEDIDO
							SC9->C9_SEQUEN,;	// SEQUENCIA
							SC9->C9_QTDLIB,;	// QUANTIDADE
							SC9->C9_PRCVEN,;	// PRECO VENDA
							SC9->C9_PRODUTO,;	// PRODUTO
							.F.,;
							SC9->(RecNo()),;
							SC5->(RecNo()),;
							SC6->(RecNo()),;
							SE4->(RecNo()),;
							SB1->(RecNo()),;
							SB2->(RecNo()),;
							SF4->(RecNo())})          
		SC9->(dbSkip())
	EndDo     
	conout("Preparando os itens para nota ....maPvlNfs" )
	cNota	:= maPvlNfs(aPvlNfs,cSerie,.F.,.F.,.F.,.F.,.F.,0,0,.F.,.F.)
	aPvlNfs := {}	
	RestArea(aArea)
Return cNota


static function AtuFluig(cIdFluig,cChoosedState)

Local oWsdl
Local lRet
Local cMsg       := ""
//PREPARE ENVIRONMENT EMPRESA '05' FILIAL '040101' TABLES 'SC5','SC6','SE4','SB1','SB2','SF4'

 cFluigUsr 	:= AllTrim(GetMv("MV_FLGUSER"))
 cFluigPss		:= AllTrim(GetMv("MV_FLGPASS"))
oWsdl := TWsdlManager():New()
xRet := oWsdl:ParseURL("http://proseg-hml.ademicon.net.br/webdesk/ECMWorkflowEngineService?wsdl")
if xRet == .F.
    conout( "Erro: " + oWsdl:cError )
    Return
endif

cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.workflow.ecm.technology.totvs.com/">'
cMsg += '<soapenv:Header/>'
cMsg += '<soapenv:Body>'
cMsg += '<ws:saveAndSendTaskClassic>'
cMsg += "<username>"+cFluigUsr+"</username>"
cMsg += "<password>"+cFluigPss+"</password>"
cMsg += '<companyId>1</companyId>'
cMsg += "<processInstanceId>"+cIdFluig+"</processInstanceId>"
cMsg += "<choosedState>"+cChoosedState+"</choosedState>"
cMsg += '<colleagueIds>'
cMsg += '<item></item>'
cMsg += '</colleagueIds>'
cMsg += '<comments></comments>'
cMsg += '<userId>proseg</userId>'
cMsg += '<completeTask>true</completeTask>'
cMsg += '<attachments>'
cMsg += '</attachments>'
cMsg += '<cardData>'
cMsg += '</cardData>'
cMsg += '<appointment>'
cMsg += '</appointment>'
cMsg += '<managerMode>false</managerMode>'
cMsg += '<threadSequence>0</threadSequence>'
cMsg += '</ws:saveAndSendTaskClassic>'
cMsg += '</soapenv:Body>'
cMsg += '</soapenv:Envelope>'

//Tenta definir a operação
lRet := oWsdl:SetOperation("saveAndSendTaskClassic")
 
If ! lRet 
    conout("Erro SetOperation: " + oWsdl:cError, "Atenção")
    lRet := .F.
EndIf
 //Se for continuar o processamento
If lRet
    //Envia o XML montado
    if  oWsdl:SendSoapMsg( cMsg )
		cMsgRet := oWsdl:GetSoapResponse()
		If  At('>ERROR<', cMsgRet) > 0
			lRet :=.F.
		Endif
	Endif
Endif
return lRet
