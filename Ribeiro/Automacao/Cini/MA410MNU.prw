User Function MA410MNU
Local area := GetArea()

aadd(aRotina,{'Imprime Etiqueta','U_RACD004("MATA410")' , 0 , 8,0,NIL}) //Chama a rotina de impressão de etiquetas para o pedido posicionado.

RestArea(area)
return NIL
