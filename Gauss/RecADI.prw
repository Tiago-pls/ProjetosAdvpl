user function RecAdi()
Local aArea:=GetArea()
local cChave := SRA->(RA_FILIAL + RA_MAT)
local cCodigo :=''
Local aTabel_	 := {}  

if Select("RGE")==0
    DbSelectArea("RGE")
Endif

RGE->( DbSetOrder(1))
RGE->( DbGotop())

if RGE->(DbSeek(cChave))
    cCodigo := RGE->RGE_COD
    nLinha:= fPosTab( "S061", cCodigo, "==", 4 )
    nPerc := fTabela( "S061", nLinha, 8)
    nValorVb := (nPerc /100) * VAL_ADTO
    FGERAVERBA("502", nValorVb  , 0 ,CSEMANA,SRA->RA_CC,,"R",,,DDATA_PGTO,.F.,,,,,,,,DDATAREF)
Endif

RestArea(aArea)
Return

user function DescAdiR()
Local aArea:=GetArea()
local cChave := SRA->(RA_FILIAL + RA_MAT)

if Select("SRD")==0
    DbSelectArea("SRD")
Endif

SRD->( DbSetOrder(1))
SRD->( DbGotop())

if SRD->(DbSeek(cChave + MV_PAR03+"502") )
    nValor := SRD->RD_VALOR
    n442 := fBuscapd("442")
    FDelPD("442")
    FGERAVERBA("442", Abs(nValor + n442)  , 0 ,CSEMANA,SRA->RA_CC,,"R",,,DDATA_PGTO,.F.,,,,,,,,DDATAREF)
Endif

RestArea(aArea)
Return