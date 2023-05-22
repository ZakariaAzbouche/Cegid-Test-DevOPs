/***
* @author      Comforth - SRA
* @date        08/06/2020
* @description Class for AP03_RelatedListParc
***/
public with sharing class AP03_RelatedListParc {
    
    @AuraEnabled
    public static Map <string,object> fetchData(Id recordId) {
        apps_credentials__mdt appCred= apps_credentials__mdt.getInstance('Vue360SouscriptionToken');
        apps_credentials__mdt appCredVue360= apps_credentials__mdt.getInstance('Vue360_ParcURL');

        //list<apps_credentials__mdt> appCred = [select client_id__c, client_secret__c, DeveloperName, grant_type__c, Id, url__c, scope__c from apps_credentials__mdt where DeveloperName='Vue360SouscriptionToken' limit 1];
        //list<apps_credentials__mdt> appCredVue360 = [select client_id__c, client_secret__c, DeveloperName, grant_type__c, Id, url__c, scope__c from apps_credentials__mdt where DeveloperName='Vue360_ParcURL' limit 1];

        system.debug(' recordId : ' + recordId);
        
        Map <string,object> mapParc = new Map<string,object>();
        Map <string,object> mapToken = new Map<string,object>();
        string erp_Number;
        
        Account acc= [select Id,ERP_Number__c from Account where Id =: recordId];
        
        if(acc.ERP_Number__c!=null){
            erp_Number= acc.ERP_Number__c;
        }else{
            system.debug('Testing');
            return new Map <String, Object>{
                'error' => system.Label.Error_Message_WS
                    
                    };
        }
         
        system.debug('ERP_Number__c'+acc.ERP_Number__c);
        
        Http httpToken = new Http();
        HttpRequest req = new HttpRequest();

        string strUrl= appCred.url__c +'?'+'client_id='+appCred.client_id__c+'&client_secret='+appCred.client_secret__c+'&grant_type='+appCred.grant_type__c+'&scope='+appCred.scope__c;
        system.debug(strUrl);
        //req.setEndpoint(system.Label.Vue360SouscriptionToken);
        req.setEndpoint(strUrl);

        req.setMethod('POST');
        HttpResponse res = httpToken.send(req);
        system.debug('res' +res.getBody());
        string TokenResponse = res.getBody();
        mapToken=(Map<String, Object>) JSON.deserializeUntyped(TokenResponse);
        String Token = string.valueof(mapToken.get('access_token'));
        system.debug('mapToken'+mapToken);
        system.debug('Token'+Token);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //request.setEndpoint('https://uat-exp-cegid-360view-api.de-c1.eu1.cloudhub.io/api/exp-cegid-360View-api-acceptance/v1/customer360/'+erp_Number+'/assets');
        
        request.setEndpoint(appCredVue360.url__c+erp_Number+'/assets');
        //request.setEndpoint(system.Label.Vue360_ParcURL+erp_Number+'/assets');
        request.setMethod('GET');
        request.setHeader('Authorization','Bearer '+Token);
        system.debug('request.Header' + request.getHeader('Authorization'));
        HttpResponse response = http.send(request);
        system.debug('response' +response.getBody());
        system.debug('response status' +response.getStatusCode());
        
        if(response.getStatusCode()==200){
            string returnData= response.getBody();
            if(returnData!=null){
                
                List<AP03_RelatedListParc_Wrapper> parcDeserialized = (List<AP03_RelatedListParc_Wrapper>) JSON.deserializeStrict(returnData, List<AP03_RelatedListParc_Wrapper>.class);
                System.debug('$$$parcDeserialized: ' + parcDeserialized);             
                //mapParc= (Map<string, object>) JSON.deserializeUntyped(returnData);
                //System.debug('$$$mapParc: ' + mapParc);
                return new Map <String, Object>{
                'parcList' => parcDeserialized
                    };
            }else{
                return new Map <String, Object>{
                'error' => system.Label.Error_Message_WS
                    };
            }
        }else{
            return new Map <String, Object>{
                'error' => system.Label.Error_Message_WS
                    };
             }
        
    }
}