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
global class CustomerRequestsFormControllerTokenMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request){
         HttpResponse response = new HttpResponse();
         response.setStatusCode(200);
         response.setHeader('Content-Type', ' application/json; charset=utf-8');
         response.setBody('{"access_token":"NRNx-6s2sBmk-2qdmIs8zezrzzrrgege","refresh_token":"_DxATHZpfNEzenV_QAtOURAORJF22","scope":"READ","token_type":"Bearer","expires_in":3600}');
         return response;

    }
 }