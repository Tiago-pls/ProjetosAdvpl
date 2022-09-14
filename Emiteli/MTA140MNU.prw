#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH" // BIBLIOTECA

// Ponto de entrada: MTA140MNU
// Localiza��o.: Function MenuDef - Monta o Array com op��es da rotina 
// Finalidade...: Ponto de entrada utilizado para inserir novas op��es no array aRotina 
// Programa fonte: MATA140.PRW  - Pr� documento de entrada

User Function  MTA140MNU ()

// Adicionando as Rotinas
aAdd(aRotina,{ "Etiqueta Conf", "U_IMP_ETIQ", 0 , 3, 0, Nil})
aAdd(aRotina,{ "Etiqueta Conferencia", "U_ETIQRECE", 0 , 3, 0, Nil})
//aAdd(aRotina,{ "teste Tiago Santos", "U_TSTIMP", 0 , 3, 0, Nil})
	
Return ( )
