#Include "TOPCONN.CH"
#include "protheus.ch"
#include "rwmake.ch"

user function LPCredito()
local aArea := GetArea()
SE1->(DbSeek(xFilial("SE1")))


RestArea(aArea)
return " "
