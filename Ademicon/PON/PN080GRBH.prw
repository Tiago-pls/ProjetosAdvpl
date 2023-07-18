#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PRCONST.CH"

User Function PN80GRBH

	Local nHrsPos  := 0 // 119
	Local nHrsNeg  := 0 // 338
	Local nSaldo   := 0
	Local dDataGrv := PARAMIXB[5]
	Local dPerIni		:= Ctod("//")
	Local dPerFim		:= Ctod("//")
	Local cLastFil  := xFilial("SRA")
	Local lPerCompleto	:= .F.
	checkPonMes( @dPerIni , @dPerFim , NIL , NIL , .T. , cLastFil , NIL , @lPerCompleto )
	dPerFim +=1
	DbSelectArea("SPB") 
	SPB->(DbSetorder(2))
	SPB->( DbGotop() ) 
	If SPB->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT)) 
		While SPB->(!EOF()) .AND. SRA->RA_FILIAL + SRA->RA_MAT == SPB->PB_FILIAL + SPB->PB_MAT 
			IF SPB->PB_PD = "255" 
				nHrsPos := nHrsPos + SPB->PB_HORAS
			ELSEIF SPB->PB_PD = "466" 
				nHrsNeg := nHrsNeg + SPB->PB_HORAS
			ENDIF
			SPB->(dbskip()) 		
		Enddo
	Endif
	nSaldo  := nHrsPos - nHrsNeg
IF nSaldo < 0
	nSaldo := fConvHr(nSaldo*-1,'H',,3)
	//Alert("nSaldo: " + cvaltochar(  fConvHr(nSaldo,'H',,3)  ) )
	nDtSaldo := stod(SubStr(POSICIONE("SX6",1,SRA->RA_FILIAL+"MV_PAPONTA","X6_CONTEUD"),10,8))+1
	DbSelectArea("SPB") 
		SPB->(DbSetorder(2))
		SPB->( DbGotop() ) 
		If SPB->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT)) 
			While SPB->(!EOF()) .AND. SRA->RA_FILIAL + SRA->RA_MAT == SPB->PB_FILIAL + SPB->PB_MAT 
				IF SPB->PB_PD = "255" .or. SPB->PB_PD = "466" 
					RecLock("SPB",.F.)
					SPB->(DbDelete())
					MsUnLock()
				ENDIF
				SPB->(dbskip()) 
			Enddo
		Endif

			DbSelectArea("SPI")
			DbSetOrder(1)
			DbGoTop()
			IF !DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+DTOS(nDtSaldo) ) //PC_FILIAL+PC_MAT+PC_PD
				RecLock("SPI",.t.)
				SPI->PI_FILIAL := SRA->RA_FILIAL
				SPI->PI_MAT    := SRA->RA_MAT
				SPI->PI_DATA   := dPerFim
				SPI->PI_PD     := "302"
				SPI->PI_CC     := SRA->RA_CC //POSICIONE("SRA",13,SRA->RA_MAT+SRA->RA_FILIAL,"RA_CC")
				SPI->PI_QUANT  := nSaldo
				SPI->PI_QUANTV := nSaldo
				SPI->PI_FLAG   := "I"
				MsUnLock()
			ENDIF
ELSE
		DbSelectArea("SPB") 
		SPB->(DbSetorder(2))
		SPB->( DbGotop() ) 
		If SPB->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT)) 
			While SPB->(!EOF()) .AND. SRA->RA_FILIAL + SRA->RA_MAT == SPB->PB_FILIAL + SPB->PB_MAT 
				IF SPB->PB_PD = "388" .or. SPB->PB_PD = "119" 
					RecLock("SPB",.F.)
					SPB->(DbDelete())
					MsUnLock()
				ENDIF
				SPB->(dbskip())
			Enddo
		Endif
		DbSelectArea("SPB")
		DbSetOrder(1)
		DbGoTop()
		IF !DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"119") //PC_FILIAL+PC_MAT+PC_PD
			RecLock("SPB",.t.)
			SPB->PB_FILIAL := SRA->RA_FILIAL
			SPB->PB_MAT    := SRA->RA_MAT
			SPB->PB_PD     := "119"
			SPB->PB_TIPO1  := "H"
			SPB->PB_TIPO2  := "I"
			SPB->PB_DATA   := dDataGrv
			SPB->PB_CC     := SRA->RA_CC
			SPB->PB_HORAS := nSaldo 
			MsUnLock()
		ENDIF		
ENDIF
Return
