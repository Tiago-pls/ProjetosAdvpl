#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#INCLUDE "TOTVS.CH"
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  GeraPdf      ¦ Autor ¦ Tiago Santos      ¦ Data ¦02.02.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Gera PDF de acordo com a seleção previa     		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/


user function GeraPDF(aEscolhidos)
cModelo := ""
nCont :=0
cCateg := MV_PAR08
cSitua := MV_PAR07
// montan a query

cQuery := "Select RA_FILIAL, RA_NOME, RA_MAT, RA_CRACHA, RA_CATFUNC,RA_SITFOLH, RA_RG, RA_NUMCP, RA_SERCP,RA_DTCPEXP,"
cQuery += " RA_ENDEREC, RA_CEP, SubString(RA_ADMISSA, 7,2)+ '/'+SubString(RA_ADMISSA, 5,2) +'/'+SubString(RA_ADMISSA, 1,4) RA_ADMISSA, "
cQuery += " RA_DESCOMP , SubString(RA_CIC, 1,3)+ '.'+SubString(RA_CIC, 4,3) +'.'+SubString(RA_CIC, 7,3)+'-'+SubString(RA_CIC, 10,2) RA_CIC, "
cQuery += " SubString(RA_NASC, 7,2)+ '/'+SubString(RA_NASC, 5,2) +'/'+SubString(RA_NASC, 1,4) RA_NASC, RA_SALARIO , "
cQuery += " RJ_DESC "
cQuery += " from "+ RetSqlName("SRA") + " SRA"
cQUery += " inner join " + RetSqlName("SRJ") + " SRJ on RA_CODFUNC = RJ_FUNCAO"
cQuery += " where SRA.D_E_L_E_T_ =' ' and "
cQuery += " RA_FILIAL  >='" +mv_par01+" ' and RA_FILIAL <= '" +MV_PAR02+"' and"
cQuery += " RA_CC  >='" +mv_par03+" ' and RA_CC <= '" +MV_PAR04+"' and"
cQuery += " RA_MAT  >='" +mv_par05+" ' and RA_MAT <= '" +MV_PAR06+"' and"
cQuery += " RA_ADMISSA  >='" + dTos(mv_par09)+" ' and RA_ADMISSA <= '" + dTos(MV_PAR10)+"' "

if (select('QRYF') <> 0)
    dbClosearea("QRYF")
Endif
TcQuery cQuery New Alias "QRYF" 

While QRYF->( ! EOF())
	If  !( QRYF->RA_CATFUNC $ cCateg ) .or. !( QRYF->RA_SITFOLH $ cSitua )
			QRYF->(dbSkip())
			Loop
	Endif

    MsAguarde({|| GeraArq(aEscolhidos)}, "Aguarde...", "Gerando arquivos...")

    QRYF->( DbSkip())
Enddo

Return


static function GeraArq(aEscolhidos)

    local oFont1  := TFont():New("Courier New", 9, 16, .T., .T.)
    local oFont2 := TFont():New("Courier New", 9, 13, .T., .F.)
    local nLargTxt := 870 // largura em pixel para alinhamento da funcao sayalign
    
    local oPrint
    local lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
    
    cLogo := GetSrvProfString("StartPath", "\undefined") + "pdf\logo_fgvtn.bmp"
    cPath := "c\temp\"
    cFileName := "tst" + "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-")
    //cFileName := Alltrim( QRYF->(RA_FILIAL + RA_MAT + RA_NOME))
    oPrint := FWMsPrinter():New( cFileName, IMP_PDF, lAdjustToLegacy,cPath, .T.,,, "PDF" ) 
        
    oPrint:SetResolution(78) // Tamanho estipulado
    oPrint:SetPortrait()
        //oPrint:SetPaperSize(0, 210, 297 ) // Tamanho da folha 
    oPrint:SetPaperSize( DMPAPER_A4 ) // Tamanho da folha 
    oPrint:SetMargin(10,10,10,10)
    
    For nqtd := 1 to len(aEscolhidos)
        cCaminho := GetSrvProfString("StartPath", "\undefined") + "pdf\" + aEscolhidos[nQtd]
            // validar existir arquivo na pasta no servidor
        if ! File(cCaminho + '.txt')
            MsgAlert("Arquivo  "+ aEscolhidos[nQtd] + '.TXT Não Encontrado')
            Return      
        else
            FT_FUSE(cCaminho + '.txt')
            ProcRegua(FT_FLASTREC())
            FT_FGOTOP() 
            cTexto := "" 
            cLinha := ""
            cCHR := chr(13)+chr(10)
            nCOnt := 0
            l1LinCabec := .T.
            While !FT_FEOF()
            
                IncProc("Lendo arquivo texto...")
                if nCont == 0 
                    cCabec := DecodeUTF8( FT_FREADLN())
                else
                    cLinha := DecodeUTF8( FT_FREADLN())
                endif
                nCabec := At("cabecalho", cLinha)
                if nCabec > 0
                    cCabec += cCHR + SubStr(cLinha, 10, len (cLinha) -9 )
                    cLinha := ""
                    l1LinCabec := .F.

                Endif
                nOutraPagina := At("outrapagina", cLinha)
                
                if nOutraPagina > 0
                    nLin            := 0
                    oPrint:StartPage()  
                    nLin += 03
                    oPrint:SayBitmap( nLin, 030, cLogo , 600, 40)
                    nLin += 45
                    ntam := iif(l1LinCabec, 20, 60)
                    ntamcabec := iif(l1LinCabec, 20, 60)
                    oPrint:SayAlign(nLin, 035, cCabec, oFont1, 575,ntam , CLR_BLACK, 3, 2) 	
                    nLin += ntamcabec
                    oPrint:SayAlign(nLin, 035, cTexto, oFont2, 575, 900, CLR_BLACK, 3, 2) 		
                    oPrint:EndPage()
                    cCabec := ""
                    cLinha := ""
                    cTexto := ""
                Endif
                nPos := At("->", cLinha)
                nPosData := At("dDataBase", cLinha)
                DO CASE
                    CASE nPos > 0
                        cCampo := "QRYF"+ substr( cLinha, nPos, len(cLinha) )
                        if Valtype(&cCampo) = "N"
                            cValor := Alltrim( transform(&cCampo,"@E 999,999,999.99"))
                        else
                            cValor:= Alltrim( &cCampo)
                        endif
                        cTexto +=  SubStr( cLinha, 1, nPos-1) +cValor
                    CASE nPosData > 0
                        cData := Dtos(dDataBase)
                        cData := SubString(cData, 7,2)+ '/'+SubString(cData, 5,2) +'/'+SubString(cData, 1,4)
                        cTexto +=  SubStr( cLinha, 1, nPosData-1) + cData

                    OTHERWISE
                        //cTexto += Alltrim(cLinha) + cCHR
                        cTexto += cLinha + cCHR
                ENDCASE
                
                nCont ++
                FT_FSKIP()
            EndDo
            // gerar pdf
              //Pagina com 3 - Alinhamento justificado.  e  2 - Alinhamento centralizado;
            nLin            := 0
            oPrint:StartPage() // Inicia uma nova página  
            
            nLin += 03
            oPrint:SayBitmap( nLin, 030, cLogo , 600, 40) // imagem
                //nLin += 02
            // oPrint:Line( nLin, 01, nLin, nLargTxt, CLR_BLACK, "-1")   
            nLin += 45
            oPrint:SayAlign(nLin, 035, cCabec, oFont1, 575, 20, CLR_BLACK, 3, 2) 	
            nLin += 20
            //oPrint:SayAlign(nLin, 030, cTexto, oFont2, 800, 200, CLR_BLACK, 3, 2) 		
            oPrint:SayAlign(nLin, 035, cTexto, oFont2, 575, 900, CLR_BLACK, 3, 2) 		
                
            oPrint:EndPage()
            
        Endif

    Next nQtd

   oPrint:Preview()			

Return
