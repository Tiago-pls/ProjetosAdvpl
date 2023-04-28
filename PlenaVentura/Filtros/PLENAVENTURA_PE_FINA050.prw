#include 'protheus.ch'


user function F050ROT()

  local aRotina := ParamIXB

  aAdd(aRotina, { "Anexo em PDF"	,"u_PDFA050Attach", 0 , 4, 0, nil})

return aRotina


user function F050BUT()

  local aButtons := {}

  if ! INCLUI
    aAdd(aButtons, {"", {|| u_PDFA050Attach('SE2', SE2->(recno())) }, "Anexo em PDF", "Anexo em PDF"})
  endif

return aButtons


user function FA050FIN()

  if FunName() $ "FINA050#FINA750" .and. ! isBlind() .and. ( type("lF050Auto") == "U" .or. ! lF050Auto)
    u_PDFA050Attach('SE2', SE2->(recno()))
  endif

return