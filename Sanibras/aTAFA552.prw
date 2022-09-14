#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552
@type			function
@description	Programa de inicialização do Portal THF/Portinari do TAF (ESOCIAL).
@author			Flavio Lopes Rasta
@since			07/08/2019
@version		1.0
/*/
//---------------------------------------------------------------------
user Function ATAFA()

If (GetBuild() >= "7.00.170117A-20190628") 	

	If (Empty( GetNewPar( "MV_BACKEND", "" ) ) .OR. Empty( GetNewPar( "MV_GCTPURL", "" ) ) .OR. !TafVldRP(.F.))  


		If FWIsAdmin( __cUserID )
			If TAFFUTPAR()
				If TAFAlsInDic( "V3J" ) .and. TAFAlsInDic( "V45" )
					FWMsgRun( , { || EraseData() }, "Aguarde", "Aplicando limpeza das tabelas de requisições" )
				EndIf

				FWCallApp( "TAFA552" )
			EndIf
		Else	
			MsgAlert("As configurações para o funcionamento do TAF do Futuro não foram realizadas. Contate o administrador do sistema.")
		EndIf

	Else
		If TAFAlsInDic( "V3J" ) .and. TAFAlsInDic( "V45" )
			FWMsgRun( , { || EraseData() }, "Aguarde", "Aplicando limpeza das tabelas de requisições" )
		EndIf

		FWCallApp( "TAFA552" )
	EndIf 
Else
	MsgAlert("Para utilizar as funcionalidades do TAF do Futuro você deve atualizar o seu sistema para uma build 64 bits (Lobo Guará).")
EndIf

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl
@type			function
@description	Bloco de código que receberá as chamadas JavaScript.
@author			Robson Santos
@since			20/09/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function JsToAdvpl( oWebChannel, cType, cContent )

Local cJsonCompany	:=	""
Local cJsonContext	:=	""
Local cJsonTafFull	:=	""
Local cContext		:=  ""
Local cSourceBranch	:=	""
Local cIsTafFull	:=	"true"

If FWIsInCallStack("TAFA552A")
	cContext := "esocial"
ElseIf FWIsInCallStack("TAFA552B")
	cContext := "reinf"
ElseIf FWIsInCallStack("TAFA552C")
	cContext := "gpe"
EndIf

Do Case

	Case cType == "preLoad"

		DBSelectArea( "C1E" )
		C1E->( DBSetOrder( 3 ) )
		If C1E->( MsSeek( xFilial( "C1E" ) + PadR( FWCodFil(), TamSX3( "C1E_FILTAF" )[1] ) + "1" ), .T. )
			cSourceBranch := C1E->C1E_CODFIL
		EndIf

		cJsonCompany	:=	'{ "company_code" : "' + FWGrpCompany() + '", "branch_code":"' + FWCodFil() + '", "source_branch":"' + cSourceBranch + '" }'
		cJsonContext	:=	'{ "context" : "'+ cContext +'" }'
		cJsonTafFull    :=  '{ "tafFull" : "'+cIsTafFull+'" }'
		cJsonCodUser    :=  '{ "codUser" : "'+RetCodUsr()+'" }'

		oWebChannel:AdvPLToJS( "setContext"	  , cJsonContext  )
		oWebChannel:AdvPLToJS( "setCompany"   , cJsonCompany  )
		oWebChannel:AdvPLToJS( "setlIsTafFull", cJsonTafFull  ) 
		oWebChannel:AdvPLToJS( "setCodUser"   , cJsonCodUser  ) 

EndCase

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} EraseData
@type			function
@description	Exclui os dados voláteis dos relatórios.
@author			Robson Santos
@since			20/09/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function EraseData

Local cQuery	:=	""
Local cDate		:=	DToS( dDataBase )

cQuery := "DELETE FROM " + RetSqlName( "V45" ) + " "
cQuery += "WHERE V45_ID IN ( SELECT V3J_ID FROM " + RetSqlName( "V3J" ) + " WHERE V3J_DTREQ < '" + cDate + "' )

TCSQLExec( cQuery )

cQuery := "DELETE FROM " + RetSqlName( "V3J" ) + " "
cQuery += "WHERE V3J_DTREQ < '" + cDate + "' "

TCSQLExec( cQuery )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552B
@type			function
@description	Programa de inicialização do Portal THF/Portinari do TAF (REINF).
@author			Robson Santos
@since			26/11/2019
@version		1.0
/*/
//---------------------------------------------------------------------
user Function BTAFA552()

If (GetBuild() >= "7.00.170117A-20190628") 	
	If (Empty( GetNewPar( "MV_BACKEND", "" ) ) .OR. Empty( GetNewPar( "MV_GCTPURL", "" ) ) .OR. !TafVldRP(.F.)) 
		If FWIsAdmin( __cUserID )	
			If TAFFUTPAR()
				FWCallApp( "TAFA552" )
			EndIf
		Else
			MsgAlert("As configurações para o funcionamento do TAF do Futuro não foram realizadas. Contate o administrador do sistema.")
		EndIf
	Else
		FWCallApp( "TAFA552" )
	EndIf	
Else
	MsgAlert("Para utilizar as funcionalidades do TAF do Futuro você deve atualizar o seu sistema para uma build 64 bits (Lobo Guará).")
EndIf
	
Return( .T. )


//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552B
@type			function
@description	Programa de inicialização do Portal THF/Portinari do TAF (GPE).
@author			Robson Santos
@since			26/11/2019
@version		1.0
/*/
//---------------------------------------------------------------------
user Function TAFA552C()

If (GetBuild() >= "7.00.170117A-20190628") 	
	If (Empty( GetNewPar( "MV_BACKEND", "" ) ) .OR. Empty( GetNewPar( "MV_GCTPURL", "" ) ) .OR. !TafVldRP(.F.)) 
		If FWIsAdmin( __cUserID )
			If TAFFUTPAR()
				FWCallApp( "TAFA552" )
			EndIf
		Else
			MsgAlert("As configurações para o funcionamento do TAF do Futuro não foram realizadas. Contate o administrador do sistema.")
		EndIf
	Else
		FWCallApp( "TAFA552" )
	EndIf	
Else
	MsgAlert("Para utilizar as funcionalidades do TAF do Futuro você deve atualizar o seu sistema para uma build 64 bits (Lobo Guará).")
EndIf
	
Return( .T. )
