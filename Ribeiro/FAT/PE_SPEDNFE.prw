#Include "Protheus.ch"

/*/{Protheus.doc} FISTRFNFE
Ponto de entrada para tratamento de informacoes na geracao do XML da nota-fiscal
@type function
@version 1.0
@author FSW
@since 30/11/2018
/*/
User Function FISTRFNFE()

    AADD( aRotina, { "Ajusta Volumes", "U_EXPA001", 0, 3, 0 , Nil} )

Return 

user function NFEMNUCC()

local aRotina := { {"CCe","U_IMPCONHEC",0,3,0,.F.},; // "Item Menu 1"
                    {"","",0,3,0 ,NIL}} // "Item Menu 2"

return aRotina
