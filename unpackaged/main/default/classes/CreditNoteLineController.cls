/**
 * @author Soufiane LOGDALI - Comforth Karoo
 * @date 17/10/20200
*/

public with sharing class CreditNoteLineController {

    public static String getToken(){
        try{
            Map <string,object> mapToken = new Map<string,object>();
            HttpRequest request = new HttpRequest();     
            request.setEndpoint(Customer_Requests_API_Properties__c.getValues('Access_Token_Endpoint').Value__c + '?client_id=' + Customer_Requests_API_Properties__c.getValues('Client_Id').Value__c + '&client_secret=' + Customer_Requests_API_Properties__c.getValues('Client_Secret').Value__c + '&grant_type=client_credentials&scope=READ');
            request.setMethod('POST');            
            Http http = new Http();
            HttpResponse response = http.send(request);
            mapToken = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            String token = string.valueof(mapToken.get('access_token'));
            return token;
        } catch(Exception e){
            System.debug('Error from getToken Method' + e.getMessage());    
            return 'ERROR'; 
        } 
    }

    @future(callout=true)
    public static void postCreditNoteLine(String invoicePost, String invoiceName, List<Id> creditNoteLineIds) {  
        System.debug('invoicePost to post : ' + invoicePost);      
        //String str = '{"autoApplyToInvoiceUponPosting":false,"autoPost":true,"visibleClient":"Non","comment":"the comment","effectiveDate":"2023-02-15","taxAutoCalculation":true,"excludeFromAutoApplyRules":false,"motif":"036|AA-R\u00e9siliation","entity":"002","items":[{"amount":12,"comment":"This is comment!","invoiceItemId":"8a2889ea7810c977017818042a960c83","quantity":1,"serviceEndDate":"2016-11-30","serviceStartDate":"2016-11-01","skuName":"SKU-30","unitOfMeasure":"Test_UOM"}],"reasonCode":"Write-off"}';

        for (Integer i = 0; i < invoicePost.length(); i=i+300) {
            Integer iEffectiveEnd = (i+300 > (invoicePost.length()) ? invoicePost.length()-1 : i+300);
            System.debug(invoicePost.substring(i,iEffectiveEnd));
        }


        System.debug('invoiceName to post : ' + invoiceName);

        String token = CustomerRequestsFormController.getToken();  
        String endPoint = Customer_Requests_API_Properties__c.getValues('CreditNote_Endpoint').Value__c + '/invoices/' + invoiceName + '/creditMemos';
        System.debug('endPoint : ' + endPoint);

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');            
        request.setEndpoint(endPoint);  
        request.setHeader('Content-Type', 'application/json; charset=UTF-8'); 
        request.setHeader('Authorization','Bearer '+token);       
        //request.setBody(str);
        request.setBody(invoicePost);
        
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        response = http.send(request);
        String responseBody = response.getBody();
            
        System.debug('Post Response : ' + response.getBody());
        System.debug('Post responseBody : ' + responseBody);
        if(responseBody.indexOf('error') == -1 && responseBody.indexOf('id') != -1 && responseBody.indexOf('number') != -1){
            System.debug('Post truuuuuuuuuuuuue : ' + responseBody);

            for(Id creditNoteLineId : creditNoteLineIds){
                CreditNoteLine__c creditNoteLine = new CreditNoteLine__c() ;
                creditNoteLine.Id = creditNoteLineId;
                creditNoteLine.tech_SendToZuora__c = true;
                update creditNoteLine;
                System.debug('Post truuuuuuuuuuuuue Update: ' + creditNoteLine);
            }
        }
    }

    public class InvoicePostWrapper {
        public Boolean autoApplyToInvoiceUponPosting;
        public Boolean autoPost;
        public String visibleClient;
        public String comment;
        public String effectiveDate;
        public Boolean taxAutoCalculation;
        public Boolean excludeFromAutoApplyRules;
        public String motif;
        public String entity;
        public List<InvoiceItemsPostWrapper> items;
        public String reasonCode;
    }
      
    public class InvoiceItemsPostWrapper {
        public Decimal amount;
        public String comment;
        public String invoiceItemId;
        public Decimal quantity;
        public String serviceEndDate;
        public String serviceStartDate;
        public String skuName;
        public String unitOfMeasure;
    }
}