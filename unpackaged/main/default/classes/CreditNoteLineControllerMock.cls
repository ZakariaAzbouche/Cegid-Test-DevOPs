/** 
  @File Name          : CreditNoteLineControllerMock
  @Description        : mock class for CreditNoteLineController
  @Author             : JDA   
  @Group              : Comforth_Easyfront
  @Last Modified By   : 
  @Last Modified On   : 
  @Modification Log   : 
  Ver       Date            Author      		    Modification
  ---    -----------       -------           ------------------------ 
  1.0    27/02/2023         JDA                 Initial Version
  ---    -----------       -------           ------------------------ 
**/
@isTest
global class CreditNoteLineControllerMock implements HttpCalloutMock {
   global HttpResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', ' application/json; charset=utf-8');
        response.setBody('{"autoApplyToInvoiceUponPosting": false,"autoPost": true,"visibleClient": "Non","comment": "the comment","effectiveDate": "2023-02-15","excludeFromAutoApplyRules": false,"taxAutoCalculation": true,"reasonCode": "Write-off","motif": null, "items": [{ "amount": 12, "quantity": 1,"comment": "This is comment!","invoiceItemId": "8a2889ea7810c977017818042a960c83", "serviceEndDate": "2016-11-30","serviceStartDate": "2016-11-01","skuName": "SKU-30", "unitOfMeasure": "Test_UOM"} ]}');
        return response;
     
   }
}