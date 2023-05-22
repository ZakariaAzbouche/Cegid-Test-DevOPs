/**
 * @author           : Soufiane LOGDALI soufiane.logdali@comforth-karoo.eu
 * created on  : 20/07/2022
**/


@isTest
global class CustomerRequestsFormControllerMock implements HttpCalloutMock {
    private String type;

    global CustomerRequestsFormControllerMock(String type) {
        this.type = type;
    }

    global HTTPResponse respond(HTTPRequest req) {
        
        StaticResource static_resourceToken = [SELECT Id,Body, SystemModStamp
        FROM StaticResource 
        WHERE Name = 'Vue360_Mock_Token'
        LIMIT 1];

        StaticResource static_invoiceLines = [SELECT Id,Body, SystemModStamp
                                  FROM StaticResource 
                                  WHERE Name = 'INT01_Mock_InvoiceLines'
                                  LIMIT 1];

        StaticResource static_subscriptionLines = [SELECT Id,Body, SystemModStamp
                                  FROM StaticResource 
                                  WHERE Name = 'INT02_Mock_SubscriptionLines'
                                  LIMIT 1];
        
        HttpResponse res = new HttpResponse();
        
        if(req.getMethod()=='GET'){
            if(type == 'InvoiceLines'){
                res.setBody(static_invoiceLines.Body.toString());
            } else {
                res.setBody(static_subscriptionLines.Body.toString());
            }        	
        }else if(req.getMethod()=='POST'){
            if(type =='Access_Token_Endpoint'){
                res.setBody('{"access_token":"NRNx-6s2sBmk-2qdmIs8zezrzzrrgege","refresh_token":"_DxATHZpfNEzenV_QAtOURAORJF22","scope":"READ","token_type":"Bearer","expires_in":3600}');
                system.debug('access token response '+static_resourceToken.Body.toString());
            }
             else if(type=='CreditNote_Endpoint')
                 res.setBody('{"autoApplyToInvoiceUponPosting": false,"autoPost": true,"visibleClient": "Non","comment": "the comment","effectiveDate": "2023-02-15","excludeFromAutoApplyRules": false,"taxAutoCalculation": true,"reasonCode": "Write-off","motif": null, "items": [{"amount": 12,"quantity": 1,"comment": "This is comment!","invoiceItemId": "8a2889ea7810c977017818042a960c83","serviceEndDate": "2016-11-30","serviceStartDate": "2016-11-01","skuName": "SKU-30","unitOfMeasure": "Test_UOM"}]}');
        }
        res.setStatusCode(200);
        system.debug('response debug '+res.getBody()+'---'+res.getStatusCode());
        return res;
    }
}