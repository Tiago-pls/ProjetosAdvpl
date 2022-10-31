#include 'protheus.ch'

*--------------------------------------------------------------------------------
user function PvFinM01
* Batch de geração de boletos em pdf
* Ricardo Luiz da Rocha 22/10/2015 GNSJC
*--------------------------------------------------------------------------------
Local _nVez := 0
Private cGetEmpres:=cEmpAnt // Isto é para configurar o filtro em SXB consulta SM0MOB
Private cMarca:=GetMark(),lInverte:=.f.,_oDlg1

_vPerg:={}
AADD(_vPerg,{_nTipo:=1,_cDescric:="Emissao de                   :",_xDefault:=ctod(''),_cPicture:="",_cValid:="",_cF3:="",_cWhen:="",_nTam:=nil,_lObrigat:=.f.})
AADD(_vPerg,{_nTipo:=1,_cDescric:="Emissao até                  :",_xDefault:=ctod('31/12/2020'),_cPicture:="",_cValid:="",_cF3:="",_cWhen:="",_nTam:=nil,_lObrigat:=.f.})
AADD(_vPerg,{_nTipo:=1,_cDescric:="Vencimento real de           :",_xDefault:=ctod(''),_cPicture:="",_cValid:="",_cF3:="",_cWhen:="",_nTam:=nil,_lObrigat:=.f.})
AADD(_vPerg,{_nTipo:=1,_cDescric:="Vencimento real até          :",_xDefault:=ctod('31/12/2020'),_cPicture:="",_cValid:="",_cF3:="",_cWhen:="",_nTam:=nil,_lObrigat:=.f.})
AADD(_vPerg,{_nTipo:=1,_cDescric:="Filial de                    :",_xDefault:=space(len(cFilAnt)),_cPicture:="",_cValid:="",_cF3:="SM0MOB",_cWhen:="",_nTam:=nil,_lObrigat:=.f.})
AADD(_vPerg,{_nTipo:=1,_cDescric:="Filial até                   :",_xDefault:="zzzzzz",_cPicture:="",_cValid:="",_cF3:="SM0MOB",_cWhen:="",_nTam:=nil,_lObrigat:=.f.})
AADD(_vPerg,{_nTipo:=1,_cDescric:="Banco                        :",_xDefault:=space(len(sa6->a6_cod)),_cPicture:="",_cValid:="",_cF3:="SA6",_cWhen:="",_nTam:=nil,_lObrigat:=.t.})
AADD(_vPerg,{_nTipo:=1,_cDescric:="Agência                      :",_xDefault:=space(len(sa6->a6_agencia)),_cPicture:="",_cValid:="",_cF3:="",_cWhen:="",_nTam:=nil,_lObrigat:=.t.})
AADD(_vPerg,{_nTipo:=1,_cDescric:="Conta                        :",_xDefault:=space(len(sa6->a6_numcon)),_cPicture:="",_cValid:="",_cF3:="",_cWhen:="",_nTam:=nil,_lObrigat:=.t.})
AADD(_vPerg,{_nTipo:=1,_cDescric:="Borderô de                   :",_xDefault:=space(len(sea->ea_numbor)),_cPicture:="",_cValid:="",_cF3:="",_cWhen:="",_nTam:=nil,_lObrigat:=.f.})
AADD(_vPerg,{_nTipo:=1,_cDescric:="Borderô até                  :",_xDefault:="zzzzzz",_cPicture:="",_cValid:="",_cF3:="",_cWhen:="",_nTam:=nil,_lObrigat:=.f.})
AADD(_vPerg,{_nTipo:=1,_cDescric:="Diretório para geração       :",_xDefault:=padr("C:\Boletos\",130),_cPicture:="",_cValid:="",_cF3:="HSSDIR",_cWhen:="",_nTam:=100,_lObrigat:=.f.})
aAdd( _vPerg ,{2,"Tipo de Boleto",1, {"1-NORMAL", "2-LIQ SALDO DEVEDOR","3-AMORT PARCIAL SALDO","4-PARCELAS VENCIDAS"}, 100,'.T.',.T.})

_vRet:={}
If !ParamBox(_vPerg,"Geração de boletos em formato PDF",@_vRet,_bTudOk:=nil,_vBotoes:=nil,_lCentered:=.t.,_nCoordX:=nil,_nCoordY:=nil,;
			_oDlgWizard:=nil,_cArq:=FunName()+"_"+cEmpAnt,_lCanSave:=.T.,_lUserSave:=.t.)
   return
Endif
	
cursorwait()
	
_dEmisIni:=mv_par01 // Emissao de
_dEmisFim:=mv_par02 // Emissao ate
_dVencIni:=mv_par03 // Vencimento de
_dVencFim:=mv_par04 // Vencimento ate
_cFiliIni:=mv_par05 // Filial de 
_cFiliFim:=mv_par06 // Filial até
_cBanco  :=mv_par07 // Banco
_cAgencia:=mv_par08 // Agencia
_cConta  :=mv_par09 // Conta
_cBordIni:=mv_par10 // Borderô de
_cBordFim:=mv_par11 // Borderô até
_cPath:=alltrim(mv_par12) // Diretório para gravação

if VALTYPE(mv_par13)="N"	
	_cTpBol:= str(mv_par13)
else
	_cTpBol:=  substr(mv_par13,1,1) // Tipo de Boleto
endif
_vCampos:={"E1_FILIAL","E1_CLIENTE","E1_LOJA","A1_NOME","E1_VENCREA","E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","E1_SALDO","E1_VALOR","E1_NUMBOR","E1_PORTADO","E1_AGEDEP","E1_CONTA"}
_cSql:="Select SE1.R_E_C_N_O_ as SE1REC,"
aeval(_vCampos,{|x|_cSql+=x+","})
// Remove a última vírgula da select list
_cSql:=left(_cSql,len(_cSql)-1)
_cSql+=" from "+RetSqlName("SE1")+" SE1 "
_cSql+=" inner join "+RetSqlName("SA1")+" SA1 on(A1_FILIAL='"+xfilial("SA1")+"' and A1_COD=E1_CLIENTE and A1_LOJA=E1_LOJA and SA1.D_E_L_E_T_<>'*')"
_cSql+=" where SE1.D_E_L_E_T_<>'*' and E1_SALDO>0"
_cSql+=" and E1_EMISSAO between '"+dtos(_dEmisIni)+"' and '"+dtos(_dEmisFim)+"'" 
_cSql+=" and E1_VENCREA between '"+dtos(_dVencIni)+"' and '"+dtos(_dVencFim)+"'"
_cSql+=" and E1_FILIAL between '"+_cFiliIni+"' and '"+_cFiliFim+"'"
_cSql+=" and E1_PORTADO='"+_cBanco+"' and E1_AGEDEP='"+_cAgencia+"' and E1_CONTA='"+_cConta+"'"
_cSql+=" and E1_CONTA>' '"
_cSql+=" and E1_NUMBOR between '"+_cBordIni+"' and '"+_cBordFim+"'"
_cSql+=" order by A1_NOME,E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSql),"_SE1",.T.,.T.)

sx3->(dbsetorder(2))
_cAliasQry:=alias()
for _nVez:=1 to (_cAliasQry)->(fcount())
	_cCampo:=(_cAliasQry)->(fieldname(_nVez))
	if sx3->(dbseek(_cCampo))
		if alltrim(upper(sx3->x3_tipo))$"DNL"
			sx3->(tcsetfield(_cAliasQry,_cCampo,x3_tipo,x3_tamanho,x3_decimal))
		endif
	endif
next

// Estrutura da tabela temporária
_vStruct:={{"OK","C",2,0}}
aadd(_vStruct,{"SE1REC","N",14,0})
_vMBrw:={{"OK",,"OK",""}}
sx3->(dbsetorder(2))
for _nVez:=1 to len(_vCampos)
    _cCampo:=_vCampos[_nVez] 
    sx3->(dbseek(_cCampo,.f.))
    sx3->(aadd(_vStruct,{x3_Campo,x3_tipo,x3_tamanho,x3_decimal}))
    sx3->(aadd(_vMBrw,{x3_campo,,x3_titulo,x3_picture}))
next    

_nTotTit:=_nTotSel:=0
// Criando arquivo temporario
_cArq:=CriaTrab(_vStruct,.T.)
dbUseArea(.T.,,_cArq,'_TMP',.F.)
IndRegua(alias(),cIndex:=_cArq,cKey:="A1_NOME+E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO",,cFilter:=nil)
do while _Se1->(!eof())
	_Tmp->(reclock(alias(),.t.))
	_Tmp->se1rec:=_se1->se1rec
	_nTotTit++
	for _nVez:=1 to len(_vCampos)
    	_cCampo:=_vCampos[_nVez] 
    	_cComando:="_Tmp->"+_cCampo+":=_SE1->"+_cCampo
    	_x:=&_cComando
    next
    _Tmp->(msunlock())
    _Se1->(dbskip(1))
enddo

aSize := MSADVSIZE()

define msDIALOG _oDlg1 TITLE "Geração de boletos em formato PDF" From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
_oDlg1:lMaximized := .T.
@ 008 ,010	SAY "Total de títulos: " of _oDlg1 Pixel
@ 006 ,055	MsGet  _nTotTit picture "@er 999,999" size 30,15 when .f. of _oDlg1 pixel
@ 008, 110	Say "Selecionados : "   of _oDlg1 pixel
_cVar:="_nTotSel"
BSetGet  := "{|u| iif(PCount()>0,"+_cVar+":=u,"+_cVar+")}"
_oTotSel:=TGet():New(06,155,&BSetGet,_oDlg1,,15,cPict:="@er 999,999",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,(_cVar),,,,.T.)
_lConfirmou:=.f.
_oButgera:=TButton():New(005,400, "Gerar", _oDlg1, { ||_lConfirmou:=.t.,_oDlg1:End()},80,20,,,.F.,.T.,.F.,,.F.,,,.F. )
_oButFim :=TButton():New(005,520, "Sair", _oDlg1, { ||_oDlg1:End()},80,20,,,.F.,.T.,.F.,,.F.,,,.F. )

//@ 011,555 button "Fechar" size 80,20 action (_oDlg1:End()) //of _oDlg1 pixel
_oButGera:BWhen:={||_nTotSel>0}

_nTop:=30
_nLeft:=1
_nBottom:=aSize[4]
_nRight:=aSize[3]+5

oMark :=MsSelect():New(alias(),"OK",,_vMBrw,@lInverte,@cMarca,{_nTop,_nLeft,_nBottom,_nRight},,_oDlg1)
oMark:bAval:= { || InvMarc( cMarca )}
oMark:oBrowse:lhasMark 	  := .t.
oMark:oBrowse:lCanAllmark := .t.
oMark:oBrowse:bAllMark 	  := { || MarcTodos( cMarca )}
//oMark:oBrowse:Align 	  := CONTROL_ALIGN_ALLCLIENT
_Tmp->(dbgotop())
oMark:oBrowse:SetFocus()
ACTIVATE DIALOG _oDlg1

if _lConfirmou
     
	oProcess := MsNewProcess():New( { |lEnd| u_fGeraBol(@lEnd,oProcess)},_cArq:=nil, "Gerando os arquivos", .T. )
	oProcess:Activate()
endif

u__fCloseDb("_Tmp")
u__fCloseDb("_Se1")

return

*-------------------------------------------------------------------------------------
User Function fGeraBol()
*-------------------------------------------------------------------------------------
oProcess:SetRegua1(_nTotTit)
oProcess:SetRegua2(_nTotSel)

cursorwait()
_Tmp->(dbgotop())
_cPath:=alltrim(_cPath)
if right(_cPath,1)<>"\"
	_cPath+="\"	
endif

_nJafoi:=0
do while _Tmp->(!eof())
    oProcess:IncRegua2(_Tmp->("Lendo: "+left(A1_NOME,20)+" - "+e1_num))
	if _Tmp->(IsMark("OK",cMarca,lInverte))
	   oProcess:IncRegua1(_Tmp->("Gerando: "+left(a1_nome,20)+" - "+e1_num))
	   se1->(dbgoto(_Tmp->se1rec))
	   // Chamada para a geração do boleto
	   _cPathCli:=_cPath+_fLimpa(_Tmp->a1_nome)+"\"
	   makedir(_cPathCli)
	   _cArq:=_fLimpa(se1->(e1_filial+"_"+e1_prefixo+"_"+e1_num+"_"+e1_parcela+"_"+e1_tipo))
	   if cEmpAnt $ '04'
		   if _cBanco == "237"
		   	se1->(u_BolBrad(_cPathCli,_cArq,.t.,_cTpBol))
		   elseif _cBanco == "341"
		   	se1->(u_BolItau(_cPathCli,_cArq,.t.,_cTpBol))
		   else
		   	se1->(u_BolCaixa(_cPathCli,_cArq,.t.,_cTpBol))	
		   endif
		else
		   if _cBanco == "237"
		   	se1->(u_BolBrad(_cPathCli,_cArq,.t.,"1"))
		   else
		   	se1->(u_BolCaixa(_cPathCli,_cArq,.t.,"1"))	
		   endif
		endif
	endif
	_Tmp->(dbskip(1))
enddo

cursorarrow()

alert("Processamento concluído")

return .t.

*-------------------------------------------------------------------------------------
Static Function MarcTodos( cMarca  )
*-------------------------------------------------------------------------------------

Local nReg := _Tmp->(Recno())

_Tmp->(dbGoTop())
cursorwait()
While !Eof()
	if RecLock('_Tmp')
		if _Tmp->OK <> cMarca
			_Tmp->OK := cMarca
			_nTotSel++
		Else
			_Tmp->OK := Space(2)
			_nTotSel--
		Endif
		_Tmp->(MsUnlock())
		_Tmp->(dbSkip())
	Endif
Enddo

_Tmp->(dbGoto(nReg))
oMark:oBrowse:Refresh(.t.)
_oTotSel:Refresh()
_oButGera:Refresh()
_oButGera:SetFocus()
oMark:oBrowse:SetFocus()

Return .t.

*-------------------------------------------------------------------------------------
Static Function InvMarc( cMarca )
*-------------------------------------------------------------------------------------

Local nReg := _Tmp->(Recno())

if RecLock('_Tmp')
	IF _Tmp->OK <> cMarca
		_Tmp->OK := cMarca
		_nTotSel++
	Else
		_Tmp->OK := Space(2)
		_nTotSel--
	Endif
Endif

_Tmp->(MsUnlock())
_Tmp->(dbGoto(nReg))
_oTotSel:Refresh()
_oButGera:Refresh()
_oButGera:SetFocus()
oMark:oBrowse:SetFocus()

Return .t.

*----------------------------------------------------------------------------------------------------
static function _fLimpa(_cExpr)
*----------------------------------------------------------------------------------------------------
local _cPermite:="0123456789abcdefghijklmnopqrstuvwxyz:\._",_nVez,_cLido,_cReturn:=""
_cExpr:=alltrim(lower(_cExpr))
do while at("  ",_cExpr)>0
   _cExpr:=strtran(_cExpr,"  "," ")
enddo   
for _nVez:=1 to len(_cExpr)
    _cLido:=substr(_cExpr,_nVez,1)
    if _cLido==" "
       _cLido:="_"
    elseif _cLido$_cPermite
    else
       _cLido:=""
    endif
    _cReturn+=_cLido
next

do while at("__",_cReturn)>0
   _cReturn:=strtran(_cReturn,"__","_")
enddo   

Return _cReturn
