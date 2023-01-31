#include 'protheus.ch'
#INCLUDE 'APWEBEX.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#include "fileio.ch"


User Function confcot()
	Local cHTML := ""
	//Local cTitle := OemToAnsi("Cota&ccedil;&atilde;o de Compra")
	//Local nValunit1 := httpPost->valunit0001
	//Local nValunit2 := httpPost->valunit0002
	Local cCondicao := httpPost->condpag
	//Local cDesc := ""
	//Local nHandle
	Local cFornece
	Local cIDconf  := httpGet->id
	Local aCab  :={}
	Local aItem := {}
	//Local aItens := {}
	Local nVunit := 0
	Local nVTot := 0
	Local nReg := 0
	local difdata := 0
	local nValFrete := 0
	Local cObser := httpPost->Observ
	Local aInfo :={}
	Local nI :=0


	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" MODULO "COM" TABLES "SA1,SA4,SB1,SE4,SF4,SA2,SC8,SC1,SCY"

	cStartPath	:= GetSrvProfString("Startpath","")

	/* ----   Imprimir variaveis Get*/
    conOut(Procname()+"("+ltrim(str(procline()))+") *** Portal ")
    aInfo := HttpGet->aGets
    For nI := 1 to len(aInfo)
       conout('GET '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPGET->"+aInfo[nI]))
    Next
    aInfo := HttpPost->aPost
    For nI := 1 to len(aInfo)
       conout('POST '+str(nI,3)+' = '+aInfo[nI]+' -> '+&("HTTPPOST->"+aInfo[nI]))
    Next

	dbSelectArea("SC8")
	SC8->(DbOrderNickName("MD5"))
	If SC8->(dbSeek(xFilial("SC8")+cIDconf))
		If SC8->C8_TOTAL == 0		
	
			cFornece := SC8->C8_FORNECE
			cLoja := SC8->C8_LOJA
			cNum := SC8->C8_NUM
			nReg := SC8->(Recno())
		
			conout(SC8->C8_NUM)
			conout(cIDconf)		
		
			aCab := {	{"C8_NUM"		,cNum			,NIL},;
				{"C8_EMISSAO"	,SC8->C8_EMISSAO				,NIL},;
				{"C8_FORNECE"	,cFornece			,NIL},;
				{"C8_LOJA"	,cLoja				,NIL},;
				{"C8_COND"  	,cCondicao	     		,NIL},;
				{"C8_CONTATO"	,"PORTAL"	,NIL},;
				{"C8_MOEDA",1 ,NIL},;
				{"C8_TXMOEDA",0 ,NIL}}

			While !SC8->(Eof()) .and. cNum == SC8->C8_NUM .and. SC8->C8_fornece+SC8->C8_loja == cFornece+cLoja

				nVunit := val(strtran(strtran(&("httpPost->valunit"+SC8->C8_ITEM),".",""),",","."))
				nVTot := SC8->C8_QUANT * nVunit
				dbSelectArea("SB1")
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+SC8->C8_PRODUTO))
				nValFrete := Val(strtran(strtran(&("httpPost->vfrete"),".",""),",","."))
				conout("variaviavel Frete  Antes" + &("httpPost->vfrete"))
				conout("variaviavel Frete  depois" + cValtoChar(nValFrete))

				difdata := DateDiffDa(DATE(),Ctod(&("httpPost->prz"+SC8->C8_ITEM)))

						

				IF (httpPost->vfrete) != ""  .or. nValFrete == 0
					aadd(aItem,   {{"C8_ITEM",SC8->C8_ITEM ,NIL},;
						{"C8_NUMPRO"	,SC8->C8_NUMPRO,NIL},;
						{"C8_PRODUTO",SC8->C8_PRODUTO ,NIL},;
						{"C8_UM"		,SC8->C8_UM,	NIL},;
						{"C8_QUANT",SC8->C8_QUANT ,NIL},;
						{"C8_PRECO",Round(nVunit,2) ,NIL},;
						{"C8_TOTAL",SC8->C8_QUANT * Round(nVunit,2) ,NIL},;
						{"C8_PRAZO",difdata ,NIL},;
						{"C8_FORNECE",cFornece ,NIL},;
						{"C8_LOJA",cLoja ,NIL},;
						{"C8_ALIIPI",Val(strtran(strtran(&("httpPost->pipi"+SC8->C8_ITEM),".",""),",",".")) ,NIL},;
						{"C8_TES",SB1->B1_TE ,NIL},;
						{"C8_TPFRETE",left(&("httpPost->Tpfrete"),1) ,NIL},;
						{"C8_VALFRE",Round(nValFrete,2) ,NIL},;						
						{"C8_TOTFRE",Round(nValFrete,2) ,NIL},;						
						{"C8_MOEDA",1 ,NIL},;
						{"C8_MD5",SC8->C8_MD5 ,NIL},;
						{"C8_OBS",cObser ,NIL},;
						{"C8_PICM",Val(strtran(strtran(&("httpPost->picm"+SC8->C8_ITEM),".",""),",",".")) ,NIL}})

				ELSE 
					aadd(aItem,   {{"C8_ITEM",SC8->C8_ITEM ,NIL},;
						{"C8_NUMPRO"	,SC8->C8_NUMPRO,NIL},;
						{"C8_PRODUTO",SC8->C8_PRODUTO ,NIL},;
						{"C8_UM"		,SC8->C8_UM,	NIL},;
						{"C8_QUANT",SC8->C8_QUANT ,NIL},;
						{"C8_PRECO",Round(nVunit,2) ,NIL},;
						{"C8_TOTAL",SC8->C8_QUANT * Round(nVunit,2) ,NIL},;
						{"C8_PRAZO",difdata ,NIL},;
						{"C8_FORNECE",cFornece ,NIL},;
						{"C8_LOJA",cLoja ,NIL},;
						{"C8_ALIIPI",Val(strtran(strtran(&("httpPost->pipi"+SC8->C8_ITEM),".",""),",",".")) ,NIL},;
						{"C8_TES",SB1->B1_TE ,NIL},;
						{"C8_MOEDA",1 ,NIL},;
						{"C8_MD5",SC8->C8_MD5 ,NIL},;
						{"C8_OBS",cObser ,NIL},;
						{"C8_PICM",Val(strtran(strtran(&("httpPost->picm"+SC8->C8_ITEM),".",""),",",".")) ,NIL}})
						
				ENDIF				

				SC8->(dbSkip())
			EndDo


			lMsErroAuto := .F.
	
			SC8->(dbGoTo(nReg))
	
			Begin Transaction
	            
				MSExecAuto({|x,y,z| mata150(x,y,z)},aCab,aItem,3) //Atualiza

				If lMsErroAuto
			// Gravo o log de erro com 'MMMC', mais o codigo do cliente e o CPF/CNPJ
			////////////////////////////////////////////////////////////////////////////////////////////////////////////
			//MostraErro()
					MostraErro(cStartPath,"COT_"+Alltrim(cNum)+".log")
					DisarmTransaction()
					break
				Endif
				
				AvisoRet(SC8->C8_NUM,SC8->C8_FORNECE+SC8->C8_LOJA,SC8->C8_CODUSR)
				
				
			End Transaction

			If lMsErroAuto
				cHTML += " <html>                                                                                                                    "
				cHTML += " <head>                                                                                                                              "
				//cHTML += " <meta charset='utf-8'>                                                                                                              "
				//cHTML += " <meta http-equiv='X-UA-Compatible' content='IE=edge'>                                                                               "
				cHTML += "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
				cHTML += "<meta name='viewport' content='width=device-width, initial-scale=1.0'> "                                                           "
				cHTML += " <title>Cotação De Compras</title>                                                                                                   "
				cHTML += " <link rel='stylesheet' href='css/bootstrap.min.css'>                                "
				cHTML += " <script src='js/jquery.min.js'></script>                                            "
				cHTML += " <script src='js/bootstrap-datepicker.js'></script>                "
				cHTML += " <script src='js/jquery.maskMoney.min.js' type='text/javascript'></script> "
				cHTML += " <script src='js/bootstrap.min.js'></script>                                         "
				cHTML += " <script src='js/funcoes.js' type='text/javascript'></script> "
				cHTML += " </head>                                                                                         "
                                                                                      "


				cHTML+="</hr>"
				cHTML += "<div class='alert alert-danger' role='alert'> "
				cHTML += "<p class='text-center'>Ocorreu um erro durante a gravação de sua cotação. Favor entrar em contato com a equipe de compras.</p>"
				cHTML += "</div> "
				cHTML+="</hr>"
				cHTML+="<body>"
				cHTML+="</body>"
				cHTML+="</html>"

			ElseIf !lMsErroAuto

				cHTML += " <html>                                                                                                                    "
				cHTML += " <head>                                                                                                                              "
				//cHTML += " <meta charset='utf-8'>                                                                                                              "
				//cHTML += " <meta http-equiv='X-UA-Compatible' content='IE=edge'>                                                                               "
				cHTML += "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
				cHTML += "<meta name='viewport' content='width=device-width, initial-scale=1.0'> "                                                           "
				cHTML += " <title>Cotação De Compras</title>                                                                                                   "
				cHTML += " <link rel='stylesheet' href='css/bootstrap.min.css'>                                "
				cHTML += " <script src='js/jquery.min.js'></script>                                            "
				cHTML += " <script src='js/bootstrap-datepicker.js'></script>                "
				cHTML += " <script src='js/jquery.maskMoney.min.js' type='text/javascript'></script> "
				cHTML += " <script src='js/bootstrap.min.js'></script>                                         "
				cHTML += " <script src='js/funcoes.js' type='text/javascript'></script> "
				cHTML += " </head>                                                                                         "

				cHTML+="</hr>"
				cHTML += "<div class='alert alert-success' role='alert'> "
				cHTML += "<p class='text-center'>Sua cotação foi gravada com sucesso, será analisada nas próximas horas. Nós agradecemos sua atenção.</p>"
				cHTML += "</div> "
				cHTML+="</hr>"
				cHTML+="<body>"
				cHTML+="</body>"
				cHTML+="</html>"


			Endif

		Else

			cHTML += " <html>                                                                                                                    "
			cHTML += " <head>                                                                                                                              "
			//cHTML += " <meta charset='utf-8'>                                                                                                              "
			//cHTML += " <meta http-equiv='X-UA-Compatible' content='IE=edge'>                                                                               "
			cHTML += "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
			cHTML += "<meta name='viewport' content='width=device-width, initial-scale=1.0'> "                                                           "
			cHTML += " <title>Cotação De Compras</title>                                                                                                   "
			cHTML += " <link rel='stylesheet' href='css/bootstrap.min.css'>                                "
			cHTML += " <script src='js/jquery.min.js'></script>                                            "
			cHTML += " <script src='js/bootstrap-datepicker.js'></script>                "
			cHTML += " <script src='js/jquery.maskMoney.min.js' type='text/javascript'></script> "
			cHTML += " <script src='js/bootstrap.min.js'></script>                                         "
			cHTML += " <script src='js/funcoes.js' type='text/javascript'></script> "
			cHTML += " </head>                                                                                         "
	             


			cHTML+="</hr>"
			cHTML += "<div class='alert alert-warning' role='alert'> "
			cHTML += "<p class='text-center'>Desculpe mas sua proposta já está gravada em nosso banco de dados, não podendo ser revista ou alterada. Se necessário entrar em contato com a equipe de compras.</p>"
			cHTML += "</div> "
			cHTML+="</hr>"
			cHTML+="<body>"
			cHTML+="</body>"
			cHTML+="</html>"


		Endif

	Else

		cHTML += " <html>                                                                                                                    "
		cHTML += " <head>                                                                                                                              "
		//cHTML += " <meta charset='utf-8'>                                                                                                              "
		//cHTML += " <meta http-equiv='X-UA-Compatible' content='IE=edge'>                                                                               "
		cHTML += "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
		cHTML += "<meta name='viewport' content='width=device-width, initial-scale=1.0'> "                                                           "
		cHTML += " <title>Cotação De Compras</title>                                                                                                   "
		cHTML += " <link rel='stylesheet' href='css/bootstrap.min.css'>                                "
		cHTML += " <script src='js/jquery.min.js'></script>                                            "
		cHTML += " <script src='js/bootstrap-datepicker.js'></script>                "
		cHTML += " <script src='js/jquery.maskMoney.min.js' type='text/javascript'></script> "
		cHTML += " <script src='js/bootstrap.min.js'></script>                                         "
		cHTML += " <script src='js/funcoes.js' type='text/javascript'></script> "
		cHTML += " </head>                                                                                         "
	


		cHTML+="</hr>"
		cHTML += "<div class='alert alert-warning' role='alert'> "
		cHTML += "<p class='text-center'>Cotação não encontrada, favor verificar. - Paramentro passado pelo navegador - MD5: "+cIDconf+"</p>"
		cHTML += "</div> "
		cHTML+="</hr>"
		cHTML+="<body>"
		cHTML+="</body>"
		cHTML+="</html>"




	Endif


Return cHtml




Static Function AvisoRet(cCot,cForn,cComp)
	Local cRetComp := ""
	Local cCC := ""
	Local cAttach := ""
	Local cTo
	Local cFrom
	//Local cCC
	Local cSubject
	LOCAL cFileini := GetSrvProfString ("ROOTPATH","")+GetSrvProfString ("STARTPATH","")+"TEXTOSCOTACAOOLINE.INI"
	//local serverhttp := GetPvProfString("CONFHTTP", "SERVERHTTP","",cFileini,,)
	//local portahttp := GetPvProfString("CONFHTTP", "PORTAHTTP","",cFileini,,)
	
	
	conout("retorno para comprador")
	
	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA2")+cForn))
	
	cFrom := GETMV("MV_RELFROM")
	cTo := UsrRetMail(cComp)
	cNome := ALLTRIM(SA2->A2_NOME)
	cSubject := "Retorno de Cotação n.: "+ cCot
	cRetComp := ""	
	cRetComp += " <html>                                                                                                                    "
	cRetComp += " <head>                                                                                                                              "                                                                            "
	cRetComp += "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
	cRetComp += "<meta name='viewport' content='width=device-width, initial-scale=1.0'> "                                                           "
	cRetComp += " <title>Cotação De Compras</title>                                                                                                   "
	cRetComp += " <link rel='stylesheet' href='css/bootstrap.min.css'>                                "
	cRetComp += " <script src='js/jquery.min.js'></script>                                            "
	cRetComp += " <script src='js/bootstrap-datepicker.js'></script>                "
	cRetComp += " <script src='js/jquery.maskMoney.min.js' type='text/javascript'></script> "
	cRetComp += " <script src='js/bootstrap.min.js'></script>                                         "
	cRetComp += " <script src='js/funcoes.js' type='text/javascript'></script> "
	cRetComp += " </head>  
	      
	cRetComp += "<div class='top1'>"
	cRetComp += "<div class='main'>"
	cRetComp += "<center><a href='" + GetPvProfString("LINKIMAGEMEMAIL", "CLICKIMAGEM","",cFileini,,) + "'><img src='" + GetPvProfString("LINKIMAGEMEMAIL", "IMAGEM","",cFileini,,) + "'  height='100' border='0'></a></center>" 
	cRetComp += "</div>"
	cRetComp += "</header>"
	cRetComp += "</div>"
	cRetComp += "  <body>"
	cRetComp += "  <p>&nbsp;</p>"
	cRetComp += "  <p>&nbsp;</p>"
	cRetComp += "  <p>Olá, "+cComp+"</p>"
	cRetComp += "  <p>&nbsp;</p>"
	cRetComp += "  <p>A cotação número: "+cCot+" foi respondida pelo fornecedor "+cNome+". </p>"
	cRetComp += " <p>A mesma já pode ser avaliada. </p>"
	cRetComp += "  <p>&nbsp;</p>"
	cRetComp += "  <p>&nbsp;</p>"
	cRetComp += "  <p>&nbsp;</p>"
	cRetComp += "  <p>&nbsp;</p>"
	cRetComp += "  <p>&nbsp;</p>"
	cRetComp += "<footer>"
	cRetComp += "<div class='main'>"
	cRetComp += "<div class=inside'>"
	cRetComp += "<div class='container'>"
	cRetComp += "<div class='fright'><!--{%FOOTER_LINK}--></div>"
	cRetComp += "<div class='fleft'>"
	cRetComp += "<span>" + GetPvProfString("RODAPEEMAIL", "TEXTO","",cFileini,,) + "</span> &copy; " + GetPvProfString("RODAPEEMAIL", "ANO","",cFileini,,) + " &bull;"
	cRetComp += "</div>"
	cRetComp += "</div>"
	cRetComp += "</div>"
	cRetComp += "</div>"
	cRetComp += "</footer>"		
	cRetComp += "  </body>"
	cRetComp += "</html>"	
	conout(cFrom)
	conout(cTo)
	conout(cTo)
	conout(cCC)
	conout(cSubject)

	U_OpenSendMail(cFrom, cTo, cCC, cSubject, cRetComp, cAttach)

Return

