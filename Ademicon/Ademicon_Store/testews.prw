#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#Include "TBICONN.ch"
#include "Fileio.ch"

user function testeWS
 Local oWsdl
  Local xRet
  Local aOps := {}
   
  // Cria o objeto da classe TWsdlManager
  oWsdl := TWsdlManager():New()
   
  // Faz o parse de uma URL
  xRet := oWsdl:ParseURL( "http://10.0.0.123:8189/ws/FLUIGPROTHEUS.apw?WSDL" )
  if xRet == .F.
    conout( "Erro: " + oWsdl:cError )
    Return
  endif
  // Lista as operações definidas. Passo opcional.
  aOps := oWsdl:ListOperations()
   
  // O array de retorno deve possuir ao menos 1 elemento
  if Len( aOps ) == 0
    conout( "Erro: " + oWsdl:cError )
    Return
  endif  // Exibe as informações das operações retornadas
  varinfo( "", aOps )
   
  // Define a operação
  xRet := oWsdl:SetOperation( "PRODUTOS" )
  //xRet := oWsdl:SetOperation( aOps[1][1] )
  if xRet == .F.
    conout( "Erro: " + oWsdl:cError )
    Return
  endif
Return
