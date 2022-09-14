#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH" // BIBLIOTECA

// Ponto de entrada: MTA140MNU
// Localização.: Function MenuDef - Monta o Array com opções da rotina 
// Finalidade...: Ponto de entrada utilizado para inserir novas opções no array aRotina 
// Programa fonte: MATA140.PRW  - Pré documento de entrada

User Function  MTA140MNU ()

// Adicionando as Rotinas
aAdd(aRotina,{ "Etiqueta Conf", "U_IMP_ETIQ", 0 , 3, 0, Nil})
aAdd(aRotina,{ "Etiqueta Conferencia", "U_ETIQRECE", 0 , 3, 0, Nil})
//aAdd(aRotina,{ "teste Tiago Santos", "U_TSTIMP", 0 , 3, 0, Nil})
	
Return ( )
