#include 'totvs.ch'

/*/{Protheus.doc} PDFA050Attach
Tela para anexar, visualizar e salvar arquivos PDF vinculados a nota

@author Rafael Ricardo Vieceli
@since 11/09/2019
@version 1.0

@type function
/*/
user function PDFA050Attach(cAlias,nRegister)
  while show(cAlias, nRegister)
  enddo
return

user function TPDFAttc()
  RPCSetEnv('99','01')
  //u_PDFA050Attach('SE2', 199)
  u_PDFA050Attach('SF1', 39)
  RPCClearEnv()
return


static function show(cAlias, nRegister)

  local modal
  local panel
  local reload := .F.
  local lBill := cAlias != nil .and. cAlias == "SE2"
  local lHasBills := lBill
  local lClassified

  local document := PdfAttachment():new(cAlias, nRegister)
  local parcela
  local line
  local scroll

  private parcelas := {}

  if ! lBill
    parcelas := getParcelas(SF1->F1_DUPL, SF1->F1_PREFIXO, SF1->F1_FORNECE, SF1->F1_LOJA, MVNOTAFIS)
    lHasBills := ! empty(SF1->F1_DUPL) .And. len(parcelas) > 0

    if ! lHasBills .and. !empty(SF1->F1_COND)
      parcelas := getFutureSavedParcels()
    endif
  else
    parcelas := getParcelas(SE2->E2_NUM, SE2->E2_PREFIXO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_TIPO, SE2->E2_PARCELA)
  endif

  if ! document:fromBill
    lClassified := !empty(SF1->F1_STATUS)
  endif

  //quando tem financeiro or nao esta classificado
  if lHasBills .or. ! lClassified
    modal	:= FWDialogModal():New()
    modal:SetEscClose(.F.)
    modal:setTitle("Anexo PDF " + iif(lBill,"Contas a Pagar","Nota fiscal de entrada"))
    modal:setSize(220, 500)
    modal:enableFormBar(.T.)
    modal:createDialog()

    panel := modal:getPanelMain()

    TSay():New(05,05,{|| "Documento" },panel,,TFont():New(,,-20),,,,.T.,,,50,29,,,,,,.T.)
    TSay():New(20,05,{|| "Use a opção <b>Abrir</b> para abrir o PDF com o programa padrão no seu computador e <br /><b>Salvar</b> para escolher uma pasta destino." +;
      "<br/><br/>" + ;
      "<b>Este arquivo é utilizado na integração com Fluig</b>" ;
      },panel,,TFont():New(,,-14),,,,.T.,,,185,60,,,,,,.T.)

    //anexo do documento fiscal, nao e do financeiro
    if (document:exists())
      TButton():New( 90, 05, "Abrir", panel, {|| document:downloadAndOpen() }, 55,15,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| .T. },,.F. )
      TButton():New( 90, 65, "Salvar", panel, {|| document:download()  }, 55,15,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| .T. },,.F. )
      if ! lClassified .or. FwIsAdmin()
        TButton():New( 90, 125, "Excluir", panel, {|| document:drop() .and. reload(@reload, @modal) }, 55,15,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| .T. },,.F. )
      endif
    else
      TButton():New( 90, 05, "Upload", panel, {|| document:upload() .and. reload(@reload, @modal) }, 70,15,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| .T. },,.F. )
    endif

    //financeiro, quando classificado (criado de nf) or tiver titulos (criado no financeiro)
    if lClassified .or. lHasBills
      TSay():New(05,200,{|| "Parcelas" },panel,,TFont():New(,,-20),,,,.T.,,,50,29,,,,,,.T.)
      TSay():New(20,200,{|| ;
        "Para cada parcela poderá ser anexado apenas um arquivo. " + ;
        "Use a opção <b>Abrir</b> para abrir o PDF com o programa padrão no seu computador e <b>Salvar</b> para escolher uma pasta destino. " + ;
        "Se o arquivo PDF para a parcela não existir, utilize <b>Upload</b> para selecionar o arquivo." ;
        },panel,,TFont():New(,,-14),,,,.T.,,,300,29,,,,,,.T.)

      scroll := TScrollBox():New(panel,55,200,115,295,.T.,.T.,.F.)

      for parcela := 1 to len(parcelas)
        line := (parcela*15)-15

        TSay():New(line,0,&('{|| "# '+iif(empty(parcelas[parcela][1]),'---',parcelas[parcela][1])+'" }'),scroll,,TFont():New(,,-14),,,,.T.,,,20,10,,,,,,.T.)
        TSay():New(line,25,&('{|| "Venc. '+FormDate(parcelas[parcela][2])+'" }'),scroll,,TFont():New(,,-14),,,,.T.,,,70,10,,,,,,.T.)
        TSay():New(line,110,&('{|| "Vlr. '+alltrim(Transform(parcelas[parcela][3],PesqPict('SE2','E2_VALOR')))+'" }'),scroll,,TFont():New(,,-14),,,,.T.,,,80,10,,,,,,.T.)

        if (parcelas[parcela,4]:exists())
          TButton():New( line, 180, "Abrir", scroll, &('{|| parcelas['+  cValToChar(parcela) +',4]:downloadAndOpen() }'), 30,10,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| .T. },,.F. )
          if empty(parcelas[parcela][5]) .or. FwIsAdmin()
            TButton():New( line, 215, "Salvar", scroll, &('{|| parcelas['+  cValToChar(parcela) +',4]:download()  }'), 30,10,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| .T. },,.F. )
            TButton():New( line, 250, "Excluir", scroll, &('{|| parcelas['+  cValToChar(parcela) +',4]:drop() .and. reload(@reload, @modal) }'), 30,10,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| .T. },,.F. )
          else
            TSay():New(line,215,&('{|| "'+parcelas[parcela][5]+'" }'),scroll,,TFont():New(,,-14),,,,.T.,,,80,10,,,,,,.T.)
          endif
        else
          if empty(parcelas[parcela][5]) .or. FwIsAdmin()
            TButton():New( line, 180, "Upload", scroll, &('{|| parcelas['+  cValToChar(parcela) +',4]:upload() .and. reload(@reload, @modal) }'), 40,10,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| .T. },,.F. )
          else
            TSay():New(line,180,&('{|| "'+parcelas[parcela][5]+'" }'),scroll,,TFont():New(,,-14),,,,.T.,,,80,10,,,,,,.T.)
          endif
        endif
      next parcela

    //quando é preciso, criado as parcelas com base na condicao de pagamento
    elseif ! lClassified //.and. len(parcelas) > 0

      TSay():New(05,200,{|| "Parcelas" },panel,,TFont():New(,,-20),,,,.T.,,,50,29,,,,,,.T.)
      TSay():New(20,200,{|| ;
        "Para cada parcela poderá ser anexado apenas um arquivo." + ;
        "Use a opção <b>Abrir</b> para abrir o PDF com o programa padrão no seu computador e <b>Salvar</b> para escolher uma pasta destino. " + ;
        "Se o arquivo PDF para a parcela não existir, utilize <b>Upload</b> para selecionar o arquivo. <br/><br/>" + ;
        "<b>Esta opção é para títulos que ainda serão criados.</b>" ;
        },panel,,TFont():New(,,-14),,,,.T.,,,300,59,,,,,,.T.)

      scroll := TScrollBox():New(panel,70,200,100,295,.T.,.T.,.F.)

      if len(parcelas) == 0
        TSay():New(10,0,{|| 'Esta nota não possui condição de pagamento preenchida' },scroll,,TFont():New(,,-14),,,,.T.,,,280,10,,,,,,.T.)
      else
        for parcela := 1 to len(parcelas)
          line := (parcela*15)-15

          TSay():New(line,0,&('{|| "# '+iif(empty(parcelas[parcela][1]),'---',parcelas[parcela][1])+'" }'),scroll,,TFont():New(,,-14),,,,.T.,,,20,10,,,,,,.T.)

          if (parcelas[parcela,2]:exists())
            TButton():New( line, 20, "Abrir", scroll, &('{|| parcelas['+  cValToChar(parcela) +',2]:downloadAndOpen() }'), 30,10,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| .T. },,.F. )
            TButton():New( line, 55, "Salvar", scroll, &('{|| parcelas['+  cValToChar(parcela) +',2]:download()  }'), 30,10,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| .T. },,.F. )
            TButton():New( line, 90, "Excluir", scroll, &('{|| parcelas['+  cValToChar(parcela) +',2]:drop() .and. reload(@reload, @modal) }'), 30,10,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| .T. },,.F. )
          else
            TButton():New( line, 20, "Upload", scroll, &('{|| parcelas['+  cValToChar(parcela) +',2]:upload() .and. reload(@reload, @modal) }'), 40,10,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| .T. },,.F. )
          endif
        next parcela
      endif
    endif

    modal:addCloseButton()
    modal:activate()
  
  //anexar a danfe ou algo para fiscal, sem relacao com financeiro
  else
    modal	:= FWDialogModal():New()
    modal:SetEscClose(.F.)
    modal:setTitle("Anexo PDF " + iif(lBill,"Contas a Pagar","Nota fiscal de entrada"))
    modal:setSize(120, 270)
    modal:enableFormBar(.T.)
    modal:createDialog()

    panel := modal:getPanelMain()

    if document:exists()

      TSay():New(15,20,{|| "Use a opção <b>Abrir</b> para abrir o PDF com o programa padrão no seu computador e <b>Salvar</b> para escolher uma pasta destino." },panel,,TFont():New(,,-14),,,,.T.,,,230,29,,,,,,.T.)

      modal:addButtons({{"", "Abrir"   , {|| document:downloadAndOpen() }, "Abrir arquivo com programa padrão",,.T.,.T.}})
      modal:addButtons({{"", "Salvar"  , {|| document:download() }, "Salvar arquino na pasta especificada",,.T.,.T.}})

      if ! lClassified .or. FwIsAdmin()
        TSay():New(40,20,{|| "Caso precise, usa a opção <b>Exluir</b> para remover o arquivo do servidor." },panel,,TFont():New(,,-14),,,,.T.,,,230,29,,,,,,.T.)
        modal:addButtons({{"", "Excluir"   , {|| document:drop() .and. reload(@reload, @modal) }, "Excluir arquivo",,.T.,.T.}})
      endif
    else

      TSay():New(15,20,{|| "O arquivo PDF para " + iif(lBill,"este título","está nota") + " não existe, utilize os botões abaixo para fazer <b>Upload</b> manualmente." },panel,,TFont():New(,,-14),,,,.T.,,,230,29,,,,,,.T.)
      modal:addButtons({{"", "Upload"  , {|| document:upload() .and. reload(@reload, @modal) }, "Subir arquivo",,.T.,.T.}})

      if document:autoGenerated
        TSay():New(40,20,{|| "Também pode <b>Gerar</b> através do XML do TOTVS Colaboração automaticamente." },panel,,TFont():New(,,-14),,,,.T.,,,230,29,,,,,,.T.)
        modal:addButtons({{"", "Gerar"  , {|| document:generate() .and. reload(@reload, @modal) }, "Gerar DANFE a partir do XML",,.T.,.T.}})
      endif
    endif

    modal:addCloseButton()
    modal:activate()
  endif

return reload


static function reload(reload, modal)
  reload := .T.
  modal:deactivate()
return


static function getFutureSavedParcels()
  local branch := SF1->F1_FILIAL
  local prefix := SF1->F1_SERIE
  local number  := SF1->F1_DOC
  local supplier := SF1->F1_FORNECE
  local unit := SF1->F1_LOJA
  local type := MVNOTAFIS

  local parcels := {}

  local paymentConditions := SF1->F1_COND
  local parcelsFromCondition 	:= Condicao(100, paymentConditions,,Date())

  local counter

  local parcel := iif(len(parcelsFromCondition) > 1,SuperGetMV("MV_1DUP"),"")

  for counter := 1 to len(parcelsFromCondition)
    aAdd(parcels, {;
      parcel, ;
      PdfAttachment():dummie(branch, prefix, number, supplier, unit, type, '', parcel) ;
      })

    parcel := MaParcela(parcel)
  next counter

return parcels



static function getParcelas(documento, prefixo, fornecedor, loja, tipo, parcela)

  local parcelas := {}
  local cAlias := MPSysOpenQuery( parcelsQuery(documento, prefixo, fornecedor, loja, tipo, parcela) )

  (cAlias)->( dbEval({|| ;
    aAdd(parcelas, {;
    E2_PARCELA, ;
    StoD(E2_VENCREA), ;
    E2_VALOR, ;
    PdfAttachment():new('SE2', E2RECNO, E2_PARCELA), ;
    getStatus(E2_SALDO, E2_NUMBOR) ;
    }) }) )

  (cAlias)->( dbCloseArea() )

return parcelas


static function parcelsQuery(documento, prefixo, fornecedor, loja, tipo, parcela)

  local query := ''

  query += 'select E2_PARCELA, E2_VENCREA, E2_VALOR, E2_SALDO, E2_NUMBOR, R_E_C_N_O_ as E2RECNO '
  query += ' from '+RetSqlName('SE2')
  query += " where E2_FILIAL = '"+xFilial("SE2")+"' "
  query += " and E2_NUM     = '"+documento+"' "
  query += " and E2_PREFIXO = '"+prefixo+"' "
  query += " and E2_FORNECE = '"+fornecedor+"' "
  query += " and E2_LOJA    = '"+loja+"' "
  query += " and E2_TIPO    = '"+tipo+"' "
  if !empty(parcela)
    query += " and E2_PARCELA = '"+parcela+"' "
  endif
  query += " and D_E_L_E_T_ = ' ' "

return query

static function getStatus(nSaldo, cBordero)

  if nSaldo == 0
    return 'Titulo Baixado'
  endif

  if ! empty(cBordero)
    return 'Titulo em Bordero'
  endif


return ''



user function atufanex()
local aEmp:= {}
aSm0 := FWLoadSM0()

For i:= 1 to len(aSM0)
  If aScan(aEmp,{|x| x[1] == aSm0[i,1]}) == 0 
    cEmpAnt:= asm0[i,1]
    cFilAnt:= asm0[i,2]
    aadd(aEmp,{cEmpAnt})
    fatuanex()
  Endif
NEXT

RETURN

static function fatuanex()
Local cAlias:= ""
Local lExistDoc:= .F.

//Percorre todos os registros da SF1
dbSelectArea("SF1")
dbGotop()
If SF1->(FieldPos("F1_XANEXO")) > 0
  While SF1->(!Eof())

    document := PdfAttachment():new('SF1', SF1->(Recno()))
    lExistDoc:= document:exists()
    
    Reclock("SF1",.F.)
      SF1->F1_XANEXO:= Iif(lExistDoc,'1','2')
    SF1->(msUnlock()) 
    
    //atualiza os titulos
    dbSelectArea("SE2")
    If SE2->(FieldPos("E2_XANEXO")) > 0
      
      cAlias:= MPSysOpenQuery( parcelsQuery(SF1->F1_DUPL, SF1->F1_PREFIXO, SF1->F1_FORNECE, SF1->F1_LOJA, MVNOTAFIS) )
      
      While (cAlias)->(!eof())
        SE2->(dbGoto((cAlias)->E2RECNO))
        documentE2:= PdfAttachment():new('SE2', SE2->(Recno()), SE2->E2_PARCELA)
        lExistDoc:= documentE2:exists()
        Reclock("SE2",.F.)
          SE2->E2_XANEXO:= Iif(lExistDoc,'1','2')
        SE2->(msUnlock()) 
        (cAlias)->(DbSkip())
      End
      (cAlias)->(dbCloseArea())
    Endif
    SF1->(dbSkip()) 
  End 
Endif

return
