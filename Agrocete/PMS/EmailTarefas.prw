#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Função    ¦ BuscaPerg¦ Autor ¦ Tiago Santos               ¦ Data ¦ 27/04/21 ¦¦¦
¦¦+----------+----------+-------+----------------------------+------+----------+¦¦
¦¦¦Descrição ¦ EmailTarefa              							  		   ¦¦¦
¦¦+----------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/ 

user function EnvEmail(aParam)

// aParam[01] == EMPRESA
// aParam[02] == FILIAL
Local oProcAprov
Local oProcVisto
Local aArea		:= GetArea()
Local aRetAprov	:= {}
Local aRetComp	:= {}
Local lRet		:= .F.
Local lContinua := .T.
Local lAprAlt	:= .F.
Local lAbriu 	:= .F.
Local cQuery	:= ''
Local cAprOri	:= ''
Local cUsrOri	:= ''
Local cNomeApr  := ''
Local cMailApr  := ''
Local cAltern	:= ''
Local cLFRC		:= chr(10)+chr(13)
Local aParam := {}
aadd(aParam, '01') // Empresa
aadd(aParam, '01') // Filial

Private cEndServ := ""
Private cDirWF   := ""

cModulo := 'PMS'
cTabs := 'AF9,AE8,AFA,AF8'


Prepare Environment EMPRESA aParam[1] FILIAL aParam[2] MODULO cModulo Tables cTabs

//Verifica se abriu o ambiente
If Select("SX2") <> 0
	lAbriu := .T.
Endif

If !lAbriu
	Return lRet
Endif
	
cQuery := " with PRO as("
cQuery += " 	select"
cQuery += " 		AF9_FILIAL , AF9_PROJET ,   AF9_TAREFA,   max(AF9_REVISA) AF9_REVISA,  "
cQuery += " 		 max(AF9_DESCRI) AF9_DESCRI,  MAX(AF9_START)AF9_START,  Max(AF9_FINISH) AF9_FINISH"
cQuery += " 		from " + RetSqlName("AF9")+" AF9 where AF9_DTATUF =' ' and  "
cQuery += " 		 AF9.D_E_L_E_T_ =' ' and AF9_START < '" + Dtos(dDatabase -2 ) +"'  and "
cQuery += " 		AF9_DTATUF =' '"
cQuery += " 	group by "
cQuery += " 		AF9_FILIAL , AF9_PROJET ,   AF9_TAREFA "
cQuery += " ), "
cQuery += " TAR AS("
cQuery += " 	select "
cQuery += " 	AFA_FILIAL, AFA_PROJET, AFA_TAREFA, AFA_ITEM, AE8_RECURS, AE8_DESCRI,  AE8_EMAIL,  AFA_REVISA"
cQuery += " 	 from " + RetSqlName("AFA")+" AFA "
cQuery += " 	inner join "+ RetSQLNAME("AE8")+" AE8 on AFA_RECURS = AE8_RECURS and AE8.D_E_L_E_T_ =' '"
cQuery += " 	where AFA.D_E_L_E_T_ =' ' "
cQuery += " ),"
cQuery += " FIN as ("
cQuery += " 	Select * from " + RetSqlName("AF8") +" AF8 where AF8.D_E_L_E_T_ =' ' and AF8_FASE<> '04'"
cQuery += " )"
cQuery += " select * from PRO"
cQuery += " inner join TAR on "
cQuery += " 	PRO.AF9_FILIAL = TAR.AFA_FILIAL and PRO.AF9_PROJET = TAR.AFA_PROJET and PRO.AF9_TAREFA = TAR.AFA_TAREFA and AF9_REVISA = AFA_REVISA"
cQuery += " inner join FIN on PRO.AF9_FILIAL = FIN.AF8_FILIAL  and PRO.AF9_PROJET = FIN.AF8_PROJET and PRO.AF9_REVISA = FIN.AF8_REVISA"
//cQuery += " Where AE8_RECURS in ('000000000000122','000000000000140','000000000000203')"
cQuery += " order by AE8_RECURS , AF9_PROJET, AF9_TAREFA"

If Select('TC7')<>0
	dbSelectArea('TC7')
	dbCloseArea()
Endif

dbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),'TC7',.F.,.T.)
cRecurso := ""
While TC7->(!Eof())
	
// Posiciona na alçada de aprovaÃ§Ã£o
	
// Busca as informações do Aprovador			
  cAprEmail := alltrim(TC7->AE8_EMAIL)
   	
// Verifica se o aprovador possui email cadastrado
	If Empty(cAprEmail)
		dbSelectArea('TC7');DbSkip();Loop
	Endif
    
	//Envio de e-mail para o aprovador 
	If !Empty(cAprEmail) 
		cTipo:= "LEMBRETES TAREFAS"
		cAssunto:= "LEMBRETES TAREFAS"
		cMsg:= "Há Tarefas pendentes de execução."
	 
		cTracker :=' <table cellspacing="0" id="tblTracker" cellpadding="0" width="100%">'+cLFRC
		cTracker +=' <tr align="center" bgcolor="008653" class="negrito centro">'+cLFRC
		cTracker +=' <td width="*">Projeto</td>'+cLFRC
		cTracker +=' <td width="*">Tarefa</td>'+cLFRC
		cTracker +=' <td width="*">Descrição</td>'+cLFRC
		cTracker +=' <td width="*">Revisão</td>'+cLFRC
		cTracker +=' <td width="*">Previsão início</td>'+cLFRC
		cTracker +=' <td width="*">Previsão Fim</td>'+cLFRC
	 	cTracker +=' </tr>'+cLFRC	    
        cDtInicio:= TC7->AF9_START
        cDtFim   := TC7->AF9_FINISH
        cDtInicio   :=  SubStr(cDtInicio,7,2) + '/' + SubStr(cDtInicio,5,2) + '/' + SubStr(cDtInicio,1,4)  
        cDtFim   :=  SubStr(cDtFim,7,2) + '/' + SubStr(cDtFim,5,2) + '/' + SubStr(cDtFim,1,4)  
        if !Empty(cRecurso)
            cRecurso := TC7->AE8_RECURS   
        Endif
        While  cRecurso == TC7->AE8_RECURS .or.  Empty(cRecurso)
            cTracker+=' <tr align="center">'+cLFRC   
            cTracker+=' <td width="*">'+TC7->AF9_PROJET+'</td>'+cLFRC
            cTracker+=' <td width="*">'+TC7->AF9_TAREFA+'</td>'+cLFRC
            cTracker+=' <td width="*">'+Alltrim(TC7->AF9_DESCRI)+'</td>'+cLFRC
            cTracker+=' <td width="*">'+TC7->AF9_REVISA+'</td>'+cLFRC
            cTracker+=' <td width="*">'+cDtInicio+'</td>'+cLFRC
            cTracker+=' <td width="*">'+cDtFim+'</td>'+cLFRC
            cTracker+=' </tr>'+cLFRC             
            cRecurso := TC7->AE8_RECURS
			cNome := Alltrim( TC7->AE8_DESCRI)
            TC7->( dbSkip())
        Enddo

		cTracker+=' </table>'+cLFRC
		//Função envio de email - Cód.User,Mensagem, Tabela itens 
		u_MailWF(cTipo,cAprEmail,cAssunto,cMsg,cTracker,'cLink',cNome)        
	endif	
Enddo

TC7->(DBCloseArea())

Return lRet

User Function MailWF(cTipo,cDest,cAssunto,cMsg,cTracker,cLink,cNome)
  
Local cDestMail := ""
Local cCompLink := ""

Private cEndServ:= GetMv('MV_WFBRWSR') // Endereço do servidor da pagina do Portal
Private cLFRC	:= chr(13)+chr(10)
Private cCSS	:= ""
Private cLogoSMS:= ""

//Envio de e-mail para o destinatário
cDestMail:=alltrim( cAprEmail)

If !Empty(cDestMail)                  
	
	cCSS := MontaCSS()
	oProcAprov := TWFProcess():New('MAILWF','Workflow SMS')
	oProcAprov:cSubject := cAssunto
	oProcAprov:NewTask('WFOK','\WORKFLOW\MAILWF.HTM')
	oProcAprov:cTo := "tiago.santos@smsti.com.br"//cDestMail
	oProcAprov:oHtml:ValByName('cTipo',Upper(cTipo))
	oProcAprov:oHtml:ValByName('cDest',Capital(cNome))
	oProcAprov:oHtml:ValByName('cMsg',cMsg)
	oProcAprov:oHtml:ValByName('cCSS',cCSS)
	oProcAprov:oHtml:ValByName('TRACKER',cTracker)
	oProcAprov:oHtml:ValByName('cLogoSms',cLogoSms)
	oProcAprov:oHtml:ValByName('LINK',cCompLink)
	oProcAprov:Start()
	oProcAprov:Finish()
Endif

Return

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦ MontaCSS  ¦ Autor ¦  Lucilene Mendes   ¦ Data ¦08.05.2015  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Monta o CSS para envio nos emails.                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function MontaCSS()
Local _cCSS := ""

	// Montagem do CSS para formatação do HTML
	_cCSS += 'BODY { margin:0; padding:0;background:#f2f2f2 url(http://'+cEndServ+'/images/fundo.gif) repeat-x top;font-family: Tahoma, Arial, Helvetica, sans-serif;font-size:13px;color:#333; }'
	_cCSS += 'form{margin:0; padding:0; overflow:hidden;}'
	_cCSS += 'P { margin:0 0 15px 0; }'
	_cCSS += 'TD { font-size: 13px; vertical-align: top; font-color:#FFF;}'	
	_cCSS += 'A { text-decoration:none; color:#000;  }'
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
