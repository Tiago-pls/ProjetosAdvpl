#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#Include "TBICONN.CH"
#INCLUDE 'TOPCONN.CH'
/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Fun??o    ¦  RepMarc    ¦ Autor ¦ Tiago Santos        ¦ Data ¦02.03.22 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descri??o ¦  Reprocessamento das marcações com intervalo automatico    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User function RepMarc()
Private cPerg 	:= "" 
dbSelectArea("SX1")  
dbSetOrder(1)
cPerg := "RepMar" +Replicate(" ",Len(X1_GRUPO)- Len("CUSTOFUN"))

GeraPerg(cPerg)
  
If !Pergunte(cPerg,.T.)
   Return
Endif  

MsAguarde({|| GeraMarcacao()}, "Aguarde...", "Gerando Registros...")
Return

static function  GeraMarcacao()
PRIVATE lMsErroAuto := .F.

cQuery :=" select  P8_FILIAL, P8_MAT, P8_DATAAPO, MAX(RA_REGRA) REGRA, MAX(RA_TNOTRAB) TURNO, Max(RA_CC) RA_CC from " + RetSqlName("SP8") +" SP8 "
cQuery +=" Inner join " + RetSqlName("SRA") + " SRA on P8_FILIAL = RA_FILIAL and P8_MAT = RA_MAT"
cQuery +=" Inner join " + RetSqlName("SPA") + " SPA on PA_FILIAL = RA_FILIAL and PA_CODIGO = RA_REGRA"
cQuery +=" Where P8_FILIAL >= '"+ MV_PAR01 + "' and P8_FILIAL <= '"+ MV_PAR02+"'"
cQuery +=" and SP8.D_E_L_E_T_ =' ' and SRA.D_E_L_E_T_ =' ' and SPA.D_E_L_E_T_ =' ' "
cQuery +=" and P8_CC >= '"+ MV_PAR03 + "' and P8_CC <= '"+ MV_PAR04+"'"
cQuery +=" and P8_MAT >= '"+ MV_PAR05 + "' and P8_MAT <= '"+ MV_PAR06+"'"
cQuery +=" and P8_TPMCREP <>'D' and PA_SAI1AUT ='S'"
cQuery +=" group by P8_FILIAL, P8_MAT, P8_DATAAPO "
cQuery +=" order by P8_FILIAL, P8_MAT, P8_DATAAPO "
TcQuery cQuery New Alias "QRY"  

if select("SP8") <> 0
    DbSelectArea("SP8")
Endif

if select("SPJ") <> 0
    DbSelectArea("SPJ")
Endif

SP8->( DbOrderNickName("TIPOREG"))
While QRY->(! EOF())
	
    MsProcTxt("Analisando Registro: Matricula " + QRY->P8_MAT)
	if ( SP8->( dbSeek( QRY->(P8_FILIAL + P8_MAT+ P8_DATAAPO)))) 
		cOrdem := SP8->P8_ORDEM
		cPaPonta := SP8->P8_PAPONTA
	Endif
	SP8->(dbGotop())
    if !(SP8->( dbseek(QRY->(P8_FILIAL + P8_MAT+ P8_DATAAPO + 'P') )))
//Function fTrocaTno( dPerIni , dPerFim , aTurnos , aSPF , cSeq , lAddTrcIniPer )
// PONXFUN 
		nDia := Dow( Stod( QRY->P8_DATAAPO))
		SPJ->( DbGotop())
		if SPJ->( DbSeek( QRY->( P8_FILIAL + TURNO) + '01' + cValToChar(nDia)))
		
			If !(SPJ->PJ_SAIDA1 == SPJ->PJ_ENTRA1 )

				nDias := iif( SPJ->PJ_SAIDA1 < SPJ->PJ_ENTRA1, 1,0)
				For nCont :=1 to 2

					RECLOCK("SP8", .T.) // BLoqueia o registro para alteração
						SP8->P8_FILIAL := QRY->P8_FILIAL
						SP8->P8_MAT    := QRY->P8_MAT
						SP8->P8_DATAAPO:= Stod(QRY->P8_DATAAPO)
						SP8->P8_DATA   := Stod(QRY->P8_DATAAPO) + nDias
						SP8->P8_HORA   := Iif (nCont ==1, SPJ->PJ_SAIDA1, SPJ->PJ_ENTRA2)
						SP8->P8_TURNO  := QRY->TURNO
						SP8->P8_ORDEM  := cOrdem
						SP8->P8_FLAG   := 'A'
						SP8->P8_CC     := QRY->RA_CC
						SP8->P8_TPMARCA:= Iif (nCont ==1, '1S', '2S')
						SP8->P8_PAPONTA:= cPaPonta
						SP8->P8_SEMANA := '01'
						SP8->P8_TIPOREG:= 'P'
						SP8->P8_MOTIVRG:= 'INCLUSAO AUTOMATICA'
						SP8->P8_DATAALT:= dDatabase
						SP8->P8_HORAALT:= Strtran(TIME(),':','')
						SP8->P8_USUARIO:= RetCodUsr()

					MSUNLOCK()

				Next nCont
			Endif

		Endif
    Endif
    QRY->( DbSkip())
Enddo
return

Static Function GeraPerg(cPerg)
Local aRegs:= {}

aAdd(aRegs,{cPerg,"01","Filial"         ,"Filial De"        ,"Filial De"       ,"mv_ch1","C",02,0,0,"G"," ","mv_par01","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"02","Filial Ate"     ,"Filial Ate"       ,"Filial Ate"      ,"mv_ch2","C",02,0,0,"G","naovazio()","mv_par02","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SM0","",""})
aAdd(aRegs,{cPerg,"05","Centro Custo"   ,"Centro Custo De"  ,"Centro Custo De" ,"mv_ch5","C",09,0,0,"G"," ","mv_par05","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"06","Centro Ate"     ,"Centro Custo Ate" ,"Centro Custo Ate","mv_ch6","C",09,0,0,"G","naovazio()","mv_par06","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","CTT","",""})
aAdd(aRegs,{cPerg,"07","Matricula"      ,"Matricula De"     ,"Matricula De"    ,"mv_ch7","C",06,0,0,"G"," ","mv_par07","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"08","Matricula Ate"  ,"Matricula Ate"    ,"Matricula Ate"   ,"mv_ch8","C",06,0,0,"G","naovazio()","mv_par08","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","SRA","",""})
aAdd(aRegs,{cPerg,"09","Data Ate"       ,"Data Ate"         ,"Data Ate"        ,"mv_ch9","D",08,0,0,"G","naovazio()","mv_par09","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Data Ate"       ,"Data Ate"         ,"Data Ate"        ,"mv_cha","D",08,0,0,"G","naovazio()","mv_par10","","","",""  ,"","","","","","","","","","","","","","","","","","","","","","","",""})

U_BuscaPerg(aRegs)

Return

User Function BuscaPerg(aRegsOri)

Local cGrupo	:= ''
Local cOrdem	:= ''
Local aRegAux   := {}
Local aEstrut   := {}
Local nCount    := 0
Local nLenGrupo := 0
Local nLenOrdem := 0
Local nX	 	:= 0
Local nY		:= 0
Local aRegs		:= aClone(aRegsOri)

If ValType('aRegs') <> 'C'
	Return
Endif

If Len(aRegs) <= 0
	Return
Endif

// Buscar Estrutura da tabela SX1
dbSelectArea('SX1');dbSetOrder(1)
aEstrut   := SX1->(dbStruct())
nCount	  := Len(aEstrut)

// Definir o Tamanho dos Campos de Pesquisa
nLenGrupo := aEstrut[1][3] // Tamanho do campo X1_GRUPO
nLenOrdem := aEstrut[2][3] // Tamanho do campo X1_ORDEM

// Compatibilizando o Array de Perguntas
For nX := 1 To Len(aRegs)
	aAdd(aRegAux,Array(nCount))
	For nY := 1 To nCount
		aRegAux[Len(aRegAux)][nY]:=Space(aEstrut[nY][3])
	Next nY
	For nY := 1 To nCount
		If nY <= Len(aRegs[nX])
			aRegAux[Len(aRegAux)][nY]:= aRegs[nX,nY]
		Endif
	Next nY
Next nX

// Recarregando o Array de Peguntas compatibilizado
aRegs := {}
aRegs := aClone(aRegAux)

// Testando se ele nao ficou vazio
If Len(aRegs) <= 0
	Return
Endif

// Buscando no SX1 e incluindo caso nao exista
dbSelectArea('SX1')
For nX := 1 to Len(aRegs)
	cGrupo := Padr(aRegs[nX,1],nLenGrupo)
	cOrdem := Padr(aRegs[nX,2],nLenOrdem)
	If !dbSeek(cGrupo+cOrdem,.F.)
		RecLock('SX1',.T.)
		For nY := 1 to nCount
			If nY <= Len(aRegs[nX])
				FieldPut(nY,aRegs[nX,nY])
			Endif
		Next nY
		MsUnlock()
	Endif
Next nX

Return 

//2757
