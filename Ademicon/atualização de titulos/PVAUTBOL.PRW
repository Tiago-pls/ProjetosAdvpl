
#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TBICONN.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "RPTDEF.CH"
#include "shell.ch" 
#INCLUDE "colors.ch"
#INCLUDE "font.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "fileio.ch" 

/*/{Protheus.doc} AUTOBOL
Fun��o para gera��o de border� D-1 contas a receber
@type function
@version  
@author EMERSON
@since 13/06/2022
@return variant, return_description
/*/

User Function AUTOBOL(aTit) 
    //Trava rotina para ser executada somente por um agente
    RPCSetType(3)
    //Seta job para empresa filial desejada
    RPCSetEnv('05', '050101' )

    If !LockByName("GRBORAUT",.T.,.F.)
        Conout("[GRBORAUT] - Rotina est� sendo executada, execu��o cancelada. . ")
       // RPCClearEnv()
    else
        RpcSetType(3)
        PREPARE ENVIRONMENT EMPRESA '05' FILIAL '050101' TABLES 'SA1','SE1','SE5','SED'
        If LockByName("GRBORAUT",.T.,.F.)
            Conout("[GRBORAUT] - Rotina est� sendo executada, execu��o cancelada. . ")
            dbSelectArea("SA1")
            IF Len(strtokarr(SuperGetMv("AD_BCOBOL",.F.),';')) > 1
                conout("[GRBORAUT] - INICIO - "  + AllTrim(DtoS(Date())) + " | " + TIME())
                GRBORAUT(aTit)
                conout("[GRBORAUT] - FIM - "     + AllTrim(DtoS(Date())) + " | " + TIME())
            EndIF
            UnLockByName("GRBORAUT",.T.,.F.)	    
        Endif
        RPCClearEnv()
    EndIF
Return



Static Function GRBORAUT( aTitulos)
    Local cTmp := "TMPBOR"
    Local cFilAnt_Bkp := cFilAnt
    Local aTit := {} 
    Local aBor := {}

    Local cSituaca := "1"
    Local dDataMov := ""

    //-- Vari�veis utilizadas para o controle de erro da rotina autom�tica
    Local aErroAuto :={}
    Local cErroRet :=""
    Local nCntErr :=0

    Local  cMsg 	    := ''

    Local cLogBol       := ''
    Local cMsgLog       := ''

    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .T.
    Private lAutoErrNoFile := .T.

    Private cBanco    := ''
    Private cAgencia  := ''
    Private cConta    := ''
    Private cArqConf  := ''  

    Private cNumBor       := ''
    Private _aBCO    := {}
    Private  cLocal2	:= "\temp\imp\"
    Private cFileLog 	:= ""
    cFilant :=  aTitulos[1]
    dDataMov := iif(Dow(Date()-1)==1,Date()-3,Date()-1) //Date()-1 valida se � uma segunda feira e roda o dia de sexta

    _aBCO       := strtokarr(SuperGetMv("AD_BCOBOL",.F.),';')
    cBanco      := PadR(_aBCO[1] ,TamSX3("A6_COD")[1]) 
    cAgencia    := PadR(_aBCO[2] ,TamSX3("A6_AGENCIA")[1]) 
    cConta      := PadR(_aBCO[3] ,TamSX3("A6_NUMCON")[1])
    cArqConf    := _aBCO[4] // Arquivo de configura��o
    cTitulo :=""

    /*
    aTitulos [1] Filial
    aTitulos [2] Vencimento
    aTitulos [3] Numero titulo
    aTitulos [4] Parcela titulo
    */
    cTitulo :=aTitulos[3]// '000034762'
    
    SEA->(DbSetOrder(1))

    cNumBor := Soma1(GetMV("MV_NUMBORR"),6)
    cNumBor := Replicate("0",6-Len(AllTrim(cNumBor)))+AllTrim(cNumBor)
    While SEA->(DbSeek(xFilial("SEA")+cNumBor))
        // busca o proximo numero disponivel
        cNumBor := Soma1(cNumBor)
    EndDo
    dDataMov := dToS(dDataMov)

    If Select( cTmp ) > 0
        (cTmp)->( dbCloseArea() )
    EndIf
    BeginSQL Alias cTmp
        SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO, E1_CLIENTE, E1_LOJA, SE1.R_E_C_N_O_ as REC_ 
        FROM %table:SE1% SE1
        INNER JOIN %TABLE:SA1% SA1 ON A1_FILIAL = %xFilial:SA1% AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND SA1.D_E_L_E_T_ = ' '
        WHERE 
        E1_FILIAL =%exp:  aTitulos[1]% AND
        E1_NUM in (%exp: cTitulo %) AND
        E1_NUMBOR = ' ' AND
        E1_PARCELA = (%exp: aTitulos[4]%) AND
        E1_SALDO > 0 AND 
        E1_BAIXA = ' ' AND 
        E1_TIPO = 'DP' AND
        E1_VENCREA  = %exp: aTitulos[2]% AND
        SE1.D_E_L_E_T_ = ' '
        ORDER BY E1_FILIAL,E1_NUM, E1_PARCELA, E1_PREFIXO, E1_CLIENTE, E1_LOJA, E1_EMISSAO
    EndSQL   
    //Adiciona os t�tulos no array
    While (cTmp)->(!EOF())
        if len(aTit) == 0
            WriteLog(" In�cio gera��o de border�: " + cNumBor + " Hora In�cio  : "+Time())
        EndIF

        aAdd(aTit,;
            {;
            {"E1_FILIAL" ,(cTmp)->E1_FILIAL },;
            {"E1_PREFIXO" ,(cTmp)->E1_PREFIXO },;
            {"E1_NUM" ,(cTmp)->E1_NUM },;
            {"E1_PARCELA" ,(cTmp)->E1_PARCELA },;
            {"E1_TIPO" ,(cTmp)->E1_TIPO },;
            {"E1_CLIENTE" ,(cTmp)->E1_CLIENTE },;
            {"E1_LOJA" ,(cTmp)->E1_LOJA },;
            {"E1_HIST" ,(cTmp)->REC_ };
            })
        (cTmp)->(dbSkip())

    EndDo     
    (cTmp)->(dbCloseArea()) //Fecho a tabela tempor�ria    
    If Empty(aTit) .OR. cSituaca == "0" //Caso n�o encontre t�tulos ou situa��o 0 deve sair da rotina.
        WriteLog(" A rotina n�o encontrou boletos para a filial  : " + SM0->M0_CODFIL)
        WriteLog(" Data de refer�ncia : " + Dtoc(Stod(dDataMov)))
    else

        //Informa��es bac�rias para o border�
        SA6->(DbSetOrder(1))
        SEA->(DbSetOrder(1))
        //Border� j� existe?
        if SEA->(DbSeek(xFilial("SEA")+PadR(cNumBor ,TamSX3("E1_NUMBOR")[1]))) 
            WriteLog(" ###ERRO na gera��o do border� " + cNumBor + " a numera��o utilizada j� existe na filial " + xFilial("SEA"))
        ElseIF SA6->(DbSeek(xFilial("SA6")+cBanco+cAgencia+cConta)) 

            aAdd(aBor, {"AUTBANCO" ,    SA6->A6_COD })
            aAdd(aBor, {"AUTAGENCIA" ,  SA6->A6_AGENCIA })
            aAdd(aBor, {"AUTCONTA" ,    SA6->A6_NUMCON })
            aAdd(aBor, {"AUTSITUACA" ,  PadR(cSituaca ,TamSX3("E1_SITUACA")[1]) })
            aAdd(aBor, {"AUTNUMBOR" ,   PadR(cNumBor ,TamSX3("E1_NUMBOR")[1]) }) 
            //AAdd(aTit, {"AUTDATAMOV",   dDataMov,       Nil})
            //AAdd(aTit, {"AUTGRVFI2",    .T.,            Nil})

            If cSituaca $ "2|7" // Carteira descontada deve ser informada as taxas e data do movimento
                aAdd(aBor, {"AUTTXDESC" ,10})
                aAdd(aBor, {"AUTTXIOF" ,5})
                aAdd(aBor, {"AUTDATAMOV" ,dDataMov})
            EndIf

            MSExecAuto({|a, b| FINA060(a, b)}, 3,{aBor,aTit})
            //FINA060(3, {aBor,aTit})

            If lMsErroAuto
                aErroAuto := GetAutoGRLog()
                For nCntErr := 1 To Len(aErroAuto)
                    cErroRet += aErroAuto[nCntErr]
                Next
                Conout(cErroRet)
            else
                WriteLog(" Border� " + cNumBor + " gerado para filial " + xFilial('SEA') + " com " + cValToChar(Len(aTit)) + " t�tulo(s)")
            EndIf
        EndIf
        
        //Gera PDF e Envio por e-mail
        U_EnvBol(aTit,cMsg)
        //Fim 

        WriteLog(" Hora Fim  : "+Time())
        //Envia e-mail de log
    Endif    
    // retorna ao valor antigo
    cFilant := cFilant_bkp
Return

/*/{Protheus.doc} WriteLog
//TODO Fun��o para salvar os LOG
@author Tiago Santos
@since 30/08/2023
@version undefined
@param cText, characters, descricao
@param cErro, characters, descricao
@type function
/*/
Static Function WriteLog(cText)
	
	Local nAux		 
	Local _Arqv		:= "BOL" 

    if Empty(cFileLog)
        cFileLog += cLocal2                                                                             
        cFileLog += _Arqv + cEmpAnt + cFilAnt + "-" +AllTrim( DtoS(Date()) ) + ".LOG"
    EndIf
	
	If File(cFileLog)
		nAux := fOpen(cFileLog, FO_READWRITE+FO_SHARED)		
	Else
		nAux := fCreate(cFileLog,0)
	EndIf
	
	If nAux != -1
	   	FSeek(nAux,0,2)
		FWrite(nAux, AllTrim(DtoS(Date())) + " | " + TIME() + " | " + cText + CRLF)
		FClose(nAux)
	EndIf
	
Return NIL

/*
Gera PDF e faz os envios de boleto por e-mail
*/
User Function EnvBol(aTit,cMsg)
    Local n1            := 0 
    Local _AuxFiL       := cFiLAnt
    Local _cAssunto	    := " "
    
    Local _cArqBol      := "\Temp\BOLETO_"+dtos(date())+StrTran(time(),":","")
    Local cCamBolServ   := ''
    Local _cSenha       := '1234'
    Local _cNewArq      := ''

    Local aBols         := {}
    Local cChave        := ''
    Local cEmailCod     := ''
    Local cNome         := ''

    DEFAULT cLocal2 := "\temp\imp\"

    if empty(AllTRim(cMsg))
        cMsg 	    := "Segue em anexo o boleto banc�rio.<BR />";
                        +  "Informe os 4 primeiros d�gitos do seu CPF/CNPJ para abrir o PDF.<BR />"
    EndIf

    SA1->(DbSetOrder(1))
    SE1->(DbSetOrder(1))

    For n1 := 1 To Len(aTit)
        _AuxFiL   := cFiLAnt
        cFiLAnt   := aTit[n1,1,2]
        if SA1->(DbSeek(xFilial("SA1")+aTit[n1,6,2]+aTit[n1,7,2])) /*.and. SA1->A1_ZRECBOL == '1'  .AND. !Empty(ALLTRIM(SA1->A1_ZEMCOB))*/
            
            if cChave != aTit[n1,3,2]+aTit[n1,6,2]+aTit[n1,7,2]
                cChave := aTit[n1,3,2]+aTit[n1,6,2]+aTit[n1,7,2]
                if Len(aBols) > 0 
                    U_Mail033("BOLETO",cEmailCod,_cAssunto,cMsg,aBols,cNome)
                   // WriteLog(" Boleto "+ cNumBol +" enviado para : " + Alltrim(cEmailCod) + " Senha: " + _cSenha)
                    WriteLog(" Boleto "+ cNumBol +" enviado para : " + Alltrim(cEmailCod))
                EndIf
                cEmailCod :=  'tiago.santos@smsti.com.br'// Lower(SA1->A1_EMAIL)
                cNumBol   := aTit[n1,3,2]
                _cAssunto	:= "Boleto Banc�rio Ref. NF n� "+aTit[n1,3,2]
                cNome       := Alltrim(SA1->A1_NOME)
                aBols := {}
            EndIf
   
            SE1->(dBgOtO(aTit[n1,8,2]))//Posicio ssna na SE1 antes de chamar a impress�o 
            _cSenha := substr(SA1->A1_CGC,1,4)

            _cArqBol	:= strtran("BOLETO_"+SE1->E1_PORTADO+"_"+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_NUM+SE1->E1_PARCELA+DTOS(DATE())+strtran(time(),":","")+".PDF",' ')
            //PLENAVENTURA_BOLETO_CAIXA.PRW	
            u_BolBrad(cLocal2,_cArqBol,.F.,'1')

            sleep(10000)
            
            _cArqBol	:= cLocal2+_cArqBol
            _cNewArq    := strtran(_cArqBol,'.PDF','PW.PDF')//nome com senha
            
            cCamBolServ := GetSrvProfString("RootPath", "")
            
            WaitRunSrv(cCamBolServ+"\pdftk\pdftk.exe "+ cCamBolServ+_cArqBol + " output " + cCamBolServ+_cNewArq + " owner_pw foo user_pw "+_cSenha +" allow printing", .T., cCamBolServ+cLocal2)
            
            IF File(_cNewArq)
                aAdd(aBols,_cNewArq)
            ELSE           
                WriteLog(" ###ERRO Boleto " + aTit[n1,3,2] + " n�o foi poss�vel gerar o border� para o cadastro do cliente: " + SA1->A1_COD+"/"+SA1->A1_LOJA+" "+ ALLTRIM(SA1->A1_NOME))
            ENDIF
        else 
            WriteLog(" ###ERRO Boleto " + aTit[n1,3,2] + " verifique o cadastro do cliente: " + SA1->A1_COD+"/"+SA1->A1_LOJA+" "+ ALLTRIM(SA1->A1_NOME))  
        EndIF 
        cFiLAnt := _AuxFiL 
    Next n1

    //Ultimo e-mail
    if Len(aBols) > 0 
        U_Mail033("BOLETO",cEmailCod,_cAssunto,cMsg,aBols,cNome)
        //WriteLog(" Boleto "+ cNumBol +" enviado para : " + Alltrim(SA1->A1_ZEMCOB) + " Senha: " + _cSenha)
        WriteLog(" Boleto "+ cNumBol +" enviado para : " + Alltrim(SA1->A1_ZEMCOB))
    EndIf

Return

/*
Envia boleto por e-mail
*/

User Function Mail033(cTipo,cDest,cAssunto,cMsg,_cAnexo,_cNome)
  
    Local cTracker  := ''
    Local cCompLink := ""
    Local cDirWF  	:= Alltrim(GetMv('MV_WFDIR'))
    Private cEndServ:= GetMv('MV_WFBRWSR') // Endere�o do servidor da pagina do Portal
    Private cLFRC	:= chr(13)+chr(10)
    Private cCSS	:= ""
    Private cLogoSMS:= ""
    
    If !Empty(cDest)                  
        If Empty(cDirWF)
                cDirWf := '\WORKFLOW\'
        Else
            If Right(cDirWF,1) <> '\'
                cDirWF += '\'
            Endif
        Endif
        cDirWF += 'PortalWF\'
        
        cCSS := MontaCSS()

        oProcAprov := TWFProcess():New('MAILWF','Workflow SMS')
        oProcAprov:cSubject := cAssunto
        oProcAprov:NewTask('WFOK',cDirWF+'MAILWF.HTM')
        oProcAprov:cTo := cDest
        oProcAprov:cCC := ""

        //Carrega todos os boletos 

        If ValType(_cAnexo) == "C"
            oProcAprov:AttachFile(_cAnexo)
        Elseif ValType(_cAnexo) == "A"
            aEval(_cAnexo, {|cFile| oProcAprov:AttachFile(cFile)})
        Endif

        oProcAprov:oHtml:ValByName('cTipo',Upper(cTipo))
        oProcAprov:oHtml:ValByName('cDest',Capital(_cNome))
        oProcAprov:oHtml:ValByName('cMsg',cMsg)
        oProcAprov:oHtml:ValByName('cCSS',cCSS)
        oProcAprov:oHtml:ValByName('TRACKER',cTracker)
        //oProcAprov:oHtml:ValByName('cLogoSms',cLogoSms)
        oProcAprov:oHtml:ValByName('LINK',cCompLink)
        
        oProcAprov:Start()
        oProcAprov:Finish()
        sleep(10000) // 30 Segundos
    Endif

Return

user function tst
u_AUTOBOL({'050101','20231023','000034762','002'})
return
