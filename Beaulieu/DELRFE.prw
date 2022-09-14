user function DELRFE

local cDatade := left(GETMV("MV_PAPONTA"), 8)
local cCracha := Space(10)

if SELECT("RFE")==0
    dbselectArea("RFE")
endif

if SELECT("RFB")==0
    dbselectArea("RFB")
endif

RFE->( DbSetOrder(1)) // Cracha + Data
RFE->( DbGotop())


While RFE->(!Eof()) 
    RecLock("RFE", .F.)
        dbDelete()
    MsUnLock()

    RFE->( DbSkip())
Enddo

RFB->( DbSetOrder(1)) // Cracha + Data
RFB->( DbGotop())

While RFB->(!Eof()) 
    RecLock("RFB", .F.)
        dbDelete()
    MsUnLock()

    RFB->( DbSkip())
Enddo

PONM010()
Return