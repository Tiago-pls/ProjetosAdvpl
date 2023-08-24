
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

/*/{Protheus.doc} PVAUTOBOL
Função para geração de borderô D-1 contas a receber
@type function
@version  
@author EMERSON
@since 13/06/2022
@return variant, return_description
/*/

User Function PVAUTOBOL(cEmpT, cFilialT) 
    //Trava rotina para ser executada somente por um agente
    If !LockByName("GRBORAUT",.T.,.F.)
        Conout("[GRBORAUT] - Rotina está sendo executada, execução cancelada. . ")
        RPCClearEnv()
    else
        If LockByName("GRBORAUT",.T.,.F.)
            Conout("[GRBORAUT] - Rotina está sendo executada, execução cancelada. . ")
            dbSelectArea("SA1")
            //If Fieldpos("A1_ZRECBOL") > 0 
            IF Len(strtokarr(SuperGetMv("AD_BCOBOL",.F.),';')) > 1
                conout("[GRBORAUT] - INICIO - "  + AllTrim(DtoS(Date())) + " | " + TIME())
                GRBORAUT()
                conout("[GRBORAUT] - FIM - "     + AllTrim(DtoS(Date())) + " | " + TIME())
            EndIF
            //EndIF
            UnLockByName("GRBORAUT",.T.,.F.)	    
        Endif
        RPCClearEnv()
       // Next nI
    EndIF
Return


Static Function GRBORAUT(aParam)
    Local cTmp := "TMPBOR"
    Local aTit := {} 
    Local aBor := {}

    Local cSituaca := "1"
    Local dDataMov := ""

    //-- Variáveis utilizadas para o controle de erro da rotina automática
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
    
    dDataMov := iif(Dow(Date()-1)==1,Date()-3,Date()-1) //Date()-1 valida se é uma segunda feira e roda o dia de sexta

    _aBCO       := strtokarr(SuperGetMv("AD_BCOBOL",.F.),';')
    cBanco      := PadR(_aBCO[1] ,TamSX3("A6_COD")[1]) 
    cAgencia    := PadR(_aBCO[2] ,TamSX3("A6_AGENCIA")[1]) 
    cConta      := PadR(_aBCO[3] ,TamSX3("A6_NUMCON")[1])
    cArqConf    := _aBCO[4] // Arquivo de configuração

    /*
    Gerar borderô
    I22G13 - Borderô Itau do dia itau 13/07/2022
    I = ITAU
    22 = Ano 2022
    G  = Mês 07 
    13 = Dia 13
    */
    
    //cNumBor :=  iif(cBanco=='341','I','S') + SubStr(cValToChar(year(dDataMov)),3) + chr(64+month(dDataMov)) + StrZero(Day(dDataMov),2)
    //Alterado para pegar o sequencial 
    
    SEA->(DbSetOrder(1))

    cNumBor := Soma1(GetMV("MV_NUMBORR"),6)
    cNumBor := Replicate("0",6-Len(AllTrim(cNumBor)))+AllTrim(cNumBor)
    //While !MayIUseCode("SE1"+xFilial("SE1")+cNumBor) .OR. !FA060Num(cNumBor, .F.)  //verifica se esta na memoria, sendo usado e se o número é válido
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
        E1_FILIAL = %xFilial:SE1% AND 
        E1_EMIS1 = %Exp:dDataMov% AND
        E1_NUMBOR = ' ' AND
        E1_SALDO > 0 AND 
        E1_BAIXA = ' ' AND 
        E1_TIPO = 'NF' AND
        A1_ZRECBOL = '1' AND 
        SE1.D_E_L_E_T_ = ' '
        ORDER BY E1_FILIAL,E1_NUM, E1_PARCELA, E1_PREFIXO, E1_CLIENTE, E1_LOJA, E1_EMISSAO
    EndSQL

    //Adiciona os títulos no array
    While (cTmp)->(!EOF())
        if len(aTit) == 0
            WriteLog(" Início geração de borderô: " + cNumBor + " Hora Início  : "+Time())
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

    (cTmp)->(dbCloseArea()) //Fecho a tabela temporária

    If Empty(aTit) .OR. cSituaca == "0" //Caso não encontre títulos ou situação 0 deve sair da rotina.
        WriteLog(" A rotina não encontrou boletos para a filial  : " + SM0->M0_CODFIL)
        WriteLog(" Data de referência : " + Dtoc(Stod(dDataMov)))
        //RETURN(.F.)
    else
    
        /*
        Pegar numero do borderô

        I22F31 - Banco/Ano/Mês/Dia
        S22F31 - Banco/Ano/Mês/Dia

        char(1) 
        char(2)
        converter
        */
        //Informações bacárias para o borderô
        SA6->(DbSetOrder(1))
        SEA->(DbSetOrder(1))
        //Borderô já existe?
        if SEA->(DbSeek(xFilial("SEA")+PadR(cNumBor ,TamSX3("E1_NUMBOR")[1]))) 
            WriteLog(" ###ERRO na geração do borderô " + cNumBor + " a numeração utilizada já existe na filial " + xFilial("SEA"))
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
                WriteLog(" Borderô " + cNumBor + " gerado para filial " + xFilial('SEA') + " com " + cValToChar(Len(aTit)) + " título(s)")
            EndIf
        EndIf
        
        //Gera PDF e Envio por e-mail
        //U_EnvBol(aTit,cMsg)
        //Fim 

        WriteLog(" Hora Fim  : "+Time())
        //Envia e-mail de log
    Endif

    cLogBol       := SuperGetMv("AD_BOLLOG",.F.,'TIAGO.SANTOS@SMSTI.COM.BR')
    cMsgLog       := "Segue em anexo o arquivo de LOG referente ao envio dos boletos automáticos.<BR />";
                     +"Empresa: "+SM0->M0_CODIGO+"<BR />";
                     +"Filial: "+SM0->M0_CODFIL+"<BR />";
                     +"Borderô: "+cNumBor+"<BR />";
                     +"Data referência:  "+dtoc(sTod(dDataMov))+"<BR />";
                     +"Banco/AG/Conta: " +cBanco+"/"+cAgencia+"/"+cConta+"<BR />"

    U_Mail033("BOLETO",Lower(cLogBol),"Borderô: "+ cNumBor ,cMsgLog,cFileLog,"")

    //Envia borderô para o e-mail do usuário que fará a transmissão do arquivo
    GeraArq(dDataMov)

    //RpcClearEnv()
Return
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
        cMsg 	    := "Segue em anexo o boleto bancário.<BR />";
                        +  "Informe os 4 primeiros dígitos do seu CPF/CNPJ para abrir o PDF.<BR />"
    EndIf

    SA1->(DbSetOrder(1))
    SE1->(DbSetOrder(1))

    For n1 := 1 To Len(aTit)
        _AuxFiL   := cFiLAnt
        cFiLAnt   := aTit[n1,1,2]
        if SA1->(DbSeek(xFilial("SA1")+aTit[n1,6,2]+aTit[n1,7,2])) /*.and. SA1->A1_ZRECBOL == '1' */ .AND. !Empty(ALLTRIM(SA1->A1_ZEMCOB))
            
            if cChave != aTit[n1,3,2]+aTit[n1,6,2]+aTit[n1,7,2]
                cChave := aTit[n1,3,2]+aTit[n1,6,2]+aTit[n1,7,2]
                if Len(aBols) > 0 
                    U_Mail033("BOLETO",cEmailCod,_cAssunto,cMsg,aBols,cNome)
                   // WriteLog(" Boleto "+ cNumBol +" enviado para : " + Alltrim(cEmailCod) + " Senha: " + _cSenha)
                    WriteLog(" Boleto "+ cNumBol +" enviado para : " + Alltrim(cEmailCod))
                EndIf
                cEmailCod := Lower(SA1->A1_ZEMCOB)
                cNumBol   := aTit[n1,3,2]
                _cAssunto	:= "Boleto Bancário Ref. NF nº "+aTit[n1,3,2]
                cNome       := Alltrim(SA1->A1_NOME)
                aBols := {}
            EndIf

            SE1->(dBgOtO(aTit[n1,8,2]))//Posiciona na SE1 antes de chamar a impressão 
            _cSenha := substr(SA1->A1_CGC,1,4)

            _cArqBol	:= strtran("BOLETO_"+SE1->E1_PORTADO+"_"+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_NUM+SE1->E1_PARCELA+DTOS(DATE())+strtran(time(),":","")+".PDF",' ')

            u_BolCaixa(cLocal2,_cArqBol,.F.,'1')

            sleep(10000)
            
            _cArqBol	:= cLocal2+_cArqBol
            _cNewArq    := strtran(_cArqBol,'.PDF','PW.PDF')//nome com senha
            
            cCamBolServ := GetSrvProfString("RootPath", "")
            
            WaitRunSrv(cCamBolServ+"\pdftk\pdftk.exe "+ cCamBolServ+_cArqBol + " output " + cCamBolServ+_cNewArq + " owner_pw foo user_pw "+_cSenha +" allow printing", .T., cCamBolServ+cLocal2)
            
            IF File(_cNewArq)
                aAdd(aBols,_cNewArq)
            ELSE           
                WriteLog(" ###ERRO Boleto " + aTit[n1,3,2] + " não foi possível gerar o borderô para o cadastro do cliente: " + SA1->A1_COD+"/"+SA1->A1_LOJA+" "+ ALLTRIM(SA1->A1_NOME))
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
    Private cEndServ:= GetMv('MV_WFBRWSR') // Endereço do servidor da pagina do Portal
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
        //cLogoSMS := '<img src="http://'+cEndServ+'/images/logoSMS.png" alt="Desenvolvido por SMS Tecnologia da Informação" title="Desenvolvido por SMS Tecnologia da Informação">'
   
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
        /*For nI := 0 to Len(_cAnexo)
            oProcAprov:AttachFile(_cAnexo[nI])
            //oProcAprov:addatthtag(_cAnexo[nI])
        Next nI
*/
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

/*
¦¦¦Descriçäo ¦ Monta o CSS para envio nos emails.                         ¦¦¦
*/
Static Function MontaCSS()
    Local _cCSS := ""

	// Montagem do CSS para formatação do HTML
	_cCSS += 'BODY { margin:0; padding:0;background:#f2f2f2 url(http://'+cEndServ+'/images/fundo.gif) repeat-x top;font-family: Tahoma, Arial, Helvetica, sans-serif;font-size:13px;color:#333; }'
	_cCSS += 'form{margin:0; padding:0; overflow:hidden;}'
	_cCSS += 'P { margin:0 0 15px 0; }'
	_cCSS += 'TD { font-size: 13px; vertical-align: top;}'
	
	_cCSS += 'A { text-decoration:none; color:#000; }'
	_cCSS += 'A:hover { color:#15568C; }'

	_cCSS += 'h1 { font-size:16px; }'
	_cCSS += 'h2 { font-size:14px; }'
	_cCSS += 'h3 { font-size:14px; }'
	_cCSS += 'h4 { font-size:14px; }'
	_cCSS += 'h5 { font-size:14px; }'
	_cCSS += 'h6 { font-size:14px; }'

	_cCSS += '#d_topo { margin:0 auto 0 auto; width:750px; margin-left: auto; margin-right: auto; text-align: center; }'

	_cCSS += '#d_corpo { width:980px; background:#f2f2f2; text-align: center; position:relative; width:750px; margin-top: 10px; margin-left: auto; margin-right: auto; }'
	_cCSS += '#d_rodape { width:100%; }'
	_cCSS += '#d_rodape_creditos { float: left; width:100%; text-align:center; height:40px; }'

	_cCSS += '#d_logo { float:left; background:url(http://'+cEndServ+'/imagens/logounimed.png); width:197px; height:87px; margin-top:20px; }'
	_cCSS += '#d_intranet { margin:0 auto; background:url(http://'+cEndServ+'/imagens/intranet.png); width:247px; height:99px; }'

	_cCSS += '#d_esquerda { width:750px; text-align: left; }'

	_cCSS += '#d_noticias #d_noticias_titulo, '
	_cCSS += '#d_noticias #d_noticias_rodape { width:100%; height:33px; background: #393939; url(http://'+cEndServ+'/imagens/bg_noticias_titulo.png) no-repeat; }'
	_cCSS += '#d_noticias #d_noticias_rodape { background: #393939; url(http://'+cEndServ+'/imagens/bg_noticias_rodape.png) no-repeat; }'

	_cCSS += '#d_noticias #d_noticias_titulo img{ float:left; top:50%; margin-top: -13px; margin-left:10px; position:relative; } '
	_cCSS += '#d_noticias #d_noticias_titulo h2, #d_direita  { float:left; margin-top:9px; margin-left:10px; font-family:Arial, Helvetica, sans-serif; font-size:12px; color:#fff; text-transform:uppercase; } '
	_cCSS += '#d_noticias_conteudo { background:none; } '
	_cCSS += '#d_noticias_conteudo { padding:10px 10px 10px 10px; position:relative; background-color: #fff; } '
	_cCSS += '#d_noticias_conteudo h3 { margin:0px; font-family:Arial, Helvetica, sans-serif; font-size:14px; font-weight:normal; } '
	_cCSS += '#d_noticias_conteudo h3 strong { color:#0858A4; } '
	_cCSS += '#d_noticias_conteudo p { margin:0px; padding:7px 7px 7px 0; color:#818181; } '
	_cCSS += '#d_noticias_conteudo a:hover p { color:#000; } '
	_cCSS += '#d_noticias_conteudo p strong { font-family:Arial, Helvetica, sans-serif; font-size:13px; color:#F90; } '
	_cCSS += '#d_rodape1 { margin: 0 auto; height: 3px; background-color: #ff661b; } '
	_cCSS += '#d_rodape2 { margin: 0 auto; height: 4px; background-color: #ffb200; } '
	_cCSS += '#d_rodape_creditos span { margin:0 auto; font-family:Arial, Helvetica, sans-serif; font-size:11px; font-style:italic; color:#7E7E7E; display:block; } '
	_cCSS += '.centro { text-align:center; } '
	_cCSS += '.direita { text-align: right; } '
	_cCSS += '.negrito { font-weight: bold; } '
	_cCSS += '.sublinhado { text-decoration: underline; } '
	_cCSS += '.cls50porcento { float: left; clear: none; width: 49%; } '
	_cCSS += '#divFaturamento, #divPosicaoCliente { height: 420px; } '

	_cCSS += '.clsQuebra  { clear: none; height: 1px; margin: 0px; padding: 0px; width: 1px; } '
	_cCSS += '.divEmpilhavel, .divEmpilhavelQuebra { width: 50%; float: left; clear: right; height: 50px; } '
	_cCSS += '.divEmpilhavelQuebra { clear: right; } '
	_cCSS += '#tblFaturamento, #tblPosicaoCliente, #tblTracker { border-colapse: colapse; border-top: 1px solid #111; border-left: 1px solid #111; padding: 0px; margin: 0px; background-color: #FFFFCC; } '
	_cCSS += '#tblFaturamento td, #tblPosicaoCliente td, #tblTracker td { padding: 3px; border-right: 1px solid #111; border-bottom: 1px solid #111; border-colapse: colapse; } '
	_cCSS += '#tblPosicaoCliente { background-color: #F0FEFF; } '
	_cCSS += '#divPosicaoCliente { float: right; clear: right; height:420px; } '
	_cCSS += '.linhavermelha { border-bottom: 2px solid #008554; width: 100%; padding-bottom: 5px; margin-bottom: 5px; } '
	_cCSS += '.titulo { font-weight: bold; font-size: 16px; } '
	_cCSS += '.vermelho-escuro { color: #800000; } '
	_cCSS += '.vermelho { color: #C00303; } '
	_cCSS += '.branco { color: #FFF; } '
	_cCSS += '.verde { color: #008000; } '
	_cCSS += '.azul { color:#103090; } '

	_cCSS += '* html img/**/ { '
	_cCSS += '	filter:expression( '
	_cCSS += '	this.alphaxLoaded?"": ( '
	_cCSS += '		this.src.substr(this.src.length-4)==".png" ? ( '
	_cCSS += '			(!this.complete)?"": ( '
	_cCSS += '				this.runtimeStyle.filter= '
	_cCSS += '				("progid:DXImageTransform.Microsoft.AlphaImageLoader(src="+this.src+")")+ '
	_cCSS += '				String(this.onbeforeprint=this.runtimeStyle.filter="";this.src="+this.src+"").substr(0,0)+ '
	_cCSS += '					String(this.alphaxLoaded=true).substr(0,0)+ '
	_cCSS += '				String(this.src="'+cEndServ+'/imagens/spacer.gif").substr(0,0) '
	_cCSS += '			) '
	_cCSS += '		) : '
	_cCSS += '		this.runtimeStyle.filter="" '
	_cCSS += '	)); '
	_cCSS += '} '

Return _cCSS
/*
Reenvia o boleto, posicionado no browser PE Fa740Brw
*/
User Function PVBOLREN()
    Local aTit          := {}
    Local cMsg          := ''
    Local nAcao         := 0
    //Local cPerg         := "PVBOLREN"
    Local cDiretorio    := ''

    Local aPergs := {}

    Private cFileLog 	:= ""

    if  SE1->E1_NUMBOR != ' ' .AND. SE1->E1_SALDO > 0 

        nAcao := Aviso("2º Via de Boleto", "Selecione a opção desejada", {"Reenviar E-mail", "Salvar PDF"}, 1)

        aAdd(aTit,;
            {;
            {"E1_FILIAL" ,SE1->E1_FILIAL },;
            {"E1_PREFIXO" ,SE1->E1_PREFIXO },;
            {"E1_NUM" ,SE1->E1_NUM },;
            {"E1_PARCELA" ,SE1->E1_PARCELA },;
            {"E1_TIPO" ,SE1->E1_TIPO },;
            {"E1_CLIENTE" ,SE1->E1_CLIENTE },;
            {"E1_LOJA" ,SE1->E1_LOJA },;
            {"E1_HIST" ,SE1->(Recno()) };
            })
        //Gera PDF e Envio por e-mail
        if nAcao == 2 
            aAdd(aPergs,{1,"Salvar na Pasta?"     ,Space(99),"@!","ExistDir(mv_par01)" ,"HSSDIR",,99,.T.})	        
            
            IF ParamBox(aPergs, "Informe Diretório",,,,,,,,,.T.,.T.)
                
                cDiretorio := alltrim(mv_par01) + IIF( Right(alltrim(mv_par01),1) == "\","","\")
                _cArqBol	:= strtran("BOLETO_"+SE1->E1_PORTADO+"_"+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_NUM+SE1->E1_PARCELA+DTOS(DATE())+strtran(time(),":","")+".PDF",' ')
                
                u_BolCaixa(cDiretorio,_cArqBol,.F.,'1')
                if file(cDiretorio+_cArqBol)
                    cMsg := "O Arquivo "+ _cArqBol + " foi gerado com sucesso! "
                else
                    cMsg := "Erro ao Salvar o PDF! "
                EndIF

            EndIf

        elseif SA1->A1_ZRECBOL == '1' .AND. !Empty(ALLTRIM(SA1->A1_ZEMCOB))
            U_EnvBol(aTit,cMsg)
            cMsg    := "Boleto envido para: " + ALLTRIM(SA1->A1_ZEMCOB)
        Else
            cMsg    := "Não foi possível enviar o boleto para o cliente, revise os campos para envio! "
        EndIF
    Else
        cMsg := "Não foi encontrado borderô para o título ou o título está baixado!"
    EndIF

    MsgInfo(cMsg, "2º Via de Boleto")

Return
/*/{Protheus.doc} WriteLog
//TODO Função para salvar os LOG
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
Função para enviar o arquivo borderô para o e-mail do usuario
*/

Static Function GeraArq(dDataMov)
    Local cMailBol := ''
    Local cMsgBol  := ''
    Local cUpdate   := ''

    lPergunte := pergunte("AFI150",.T.)

    lAborta := .F.

    MV_PAR01    := cNumBor
    MV_PAR02    := cNumBor
    MV_PAR03    := cArqConf
    //MV_PAR04    := cLocal2+ALLTRIM(SM0->M0_CODIGO)+cNumBor+'.rem'
    MV_PAR04    := cLocal2+iif(ALLTRIM(SM0->M0_CODIGO)=='09',iif(ALLTRIM(SM0->M0_CODFIL)=='090101','9A','9B'),ALLTRIM(SM0->M0_CODIGO))+cNumBor+'.rem'
    MV_PAR05    := cBanco   
    MV_PAR06    := cAgencia
    MV_PAR07    := cConta


    cUpdate += "UPDATE "+ RetSqlName("SEA")+ " SET EA_TRANSF = ' '"
    cUpdate += " WHERE EA_NUMBOR = '"+cNumBor+"'"
    cUpdate += " AND D_E_L_E_T_ = ' '"
    cUpdate += " AND EA_FILIAL = '"+xFilial("SEA")+"'"

    TcSqlExec(cUpdate) // Atualiza borderô se o mesmo já foi gerado, foi criado para não deixar a mensagem em tela

    fa150Gera("SE1") //Gera arquivo grava nos parametros de rotina: 

    cMailBol      := SuperGetMv("AD_MAILBOR",.F.,'TIAGO.SANTOS@SMSTI.COM.BR')
    cMsgBol       := "Segue em anexo o arquivo de remessa referente ao envio dos boletos automáticos.<BR />";
                     +"Empresa: "+SM0->M0_CODIGO+"<BR />";
                     +"Filial: "+SM0->M0_CODFIL+"<BR />";
                     +"Borderô: "+cNumBor+"<BR />";
                     +"Data referência:  "+dtoc(sTod(dDataMov))+"<BR />";
                     +"Banco/AG/Conta: " +cBanco+"/"+cAgencia+"/"+cConta+"<BR />"

    //Conseguiu gerar o arquivo? 
    IF File(MV_PAR04)
        U_Mail033("BOLETO",Lower(cMailBol),"Borderô: "+ cNumBor ,cMsgBol,MV_PAR04,"")
    endif
    
Return 
