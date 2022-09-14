#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"           
#INCLUDE "topconn.ch"
#Include "restFul.ch"

user function connection
    
Local aHeader:={}
Local oRest:= FWRest():New("https://apisandbox.cieloecommerce.cielo.com.br")

aadd(aHeader,"Content-Type: application/json")
aadd(aHeader,"MerchantId: 6407505c-e309-48fe-a2ce-6bfc29ab5082")
aadd(aHeader,"MerchantKey: CVKHHNNBVUBNPOAARXARVRFBNADFBROGGZXXPUWU")

oRest:setPath("/1/sales/")

cJson:='{'
cJson+=' "MerchantOrderId":"2014111703",'
cJson+='"Customer":{ '
cJson+=' "Name":"Comprador credito simples"'
cJson+='},'
cJson+='"Payment":{ '
cJson+=' "Type":"CreditCard",'
cJson+=' "Amount":15700,'
cJson+=' "Installments":1,'
cJson+=' "SoftDescriptor":"123456789ABCD",'
cJson+=' "CreditCard":{ '
cJson+=' "CardNumber":"0000000000000001",'
cJson+=' "Holder":"Teste Holder",'
cJson+=' "ExpirationDate":"12/2030",'
cJson+=' "SecurityCode":"123",'
cJson+=' "Brand":"Visa"'
cJson+=' }'
cJson+=' }'
cJson+='}'

oRest:SetPostParams(cJson)

If oRest:Post(aHeader)
ConOut(oRest:GetResult())
else
conout(oRest:GetLastError())
endif

Return

