/**
* @author Keshav - Comforth
* @date 2020-06-04
* @modified 2020-06-04
* @group SM002_ProductOption
* @object Product Option
* @description 
*/
public class SM002_ProductOption {
    
    public static void updatePurchasingPrice(set<Id> setConfiguredSKUId, set<Id> setProductOptionId, Boolean isDelete){
        Id productRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
        Id articleRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Article').getRecordTypeId();
        Map<Id,Decimal> mapPurchasePrice = new Map<Id,Decimal>();
        List<Product2> listProdUpdate = new  List<Product2>();
        for(SBQQ__ProductOption__c po : [SELECT id,SBQQ__ConfiguredSKU__r.id,SBQQ__OptionalSKU__r.id
                                         	   ,SBQQ__OptionalSKU__r.Purchasing_Price__c,SBQQ__Quantity__c
                                         FROM SBQQ__ProductOption__c
                                         WHERE SBQQ__ConfiguredSKU__c IN: setConfiguredSKUId
                                         AND SBQQ__ConfiguredSKU__r.RecordTypeId =: productRecordTypeId
                                         AND SBQQ__OptionalSKU__r.RecordTypeId =: articleRecordTypeId]){
            Decimal total;
            Decimal purchasePrice = po.SBQQ__OptionalSKU__r.Purchasing_Price__c == null ? 0 : po.SBQQ__OptionalSKU__r.Purchasing_Price__c;
            Decimal quantity = po.SBQQ__Quantity__c == null ? 0 : po.SBQQ__Quantity__c;
                                             
            if(isDelete && setProductOptionId.contains(po.Id))
                total = 0.0;   
            else
                total = purchasePrice;// * quantity;  
                                   
            system.debug('MCU purchasePrice : ' + purchasePrice);  
            system.debug('MCU quantity : ' + quantity);
            system.debug('MCU total : ' + total);
                                             
			if(mapPurchasePrice.containsKey(po.SBQQ__ConfiguredSKU__r.id)){
                Decimal tempPurchasePrice = mapPurchasePrice.get(po.SBQQ__ConfiguredSKU__r.id);
                tempPurchasePrice = tempPurchasePrice + total;
                mapPurchasePrice.put(po.SBQQ__ConfiguredSKU__r.id,tempPurchasePrice);                     
            }else{
                mapPurchasePrice.put(po.SBQQ__ConfiguredSKU__r.id,total);  
            }                     
        }
		system.debug('MCU mapPurchasePrice : ' + mapPurchasePrice);
		for(Id productId : mapPurchasePrice.keySet()){
            Product2 pro = new Product2(id=productId, Purchasing_Price__c = mapPurchasePrice.get(productId),Schedulable__c = true );
			listProdUpdate.add(pro);            
        }
        system.debug('MCU listProdUpdate : ' + listProdUpdate);
        if(listProdUpdate.size() > 0)
            update listProdUpdate;
        
    }
    
    
    public static void checkDoubleRecords(List<SBQQ__ProductOption__c> listProductOptions, Boolean isDelete){

        System.debug('listProductOptions : ' + listProductOptions);
        
        set<Id> prodIdsSet = new set<Id>();
        
        for(SBQQ__ProductOption__c po:listProductOptions){
            prodIdsSet.add(po.SBQQ__ConfiguredSKU__c);
        }

        Map<Id, set<Id>>  mapProductOptions= new Map<Id, set<Id>>();

        for(SBQQ__ProductOption__c po:[SELECT Id, SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c 
                                      FROM  SBQQ__ProductOption__c WHERE SBQQ__ConfiguredSKU__c IN:prodIdsSet 
                                      AND SBQQ__ConfiguredSKU__r.recordtype.developername = 'Product' 
                                      AND SBQQ__OptionalSKU__r.recordtype.developername = 'Article']){

                                        set<Id> tempSetArticleIds =(mapProductOptions.get(po.SBQQ__ConfiguredSKU__c) != null)?mapProductOptions.get(po.SBQQ__ConfiguredSKU__c):new set<Id>();
                                        tempSetArticleIds.add(po.SBQQ__OptionalSKU__c);
                                        mapProductOptions.put(po.SBQQ__ConfiguredSKU__c,tempSetArticleIds);

        }
             
        
        for(SBQQ__ProductOption__c newPo:listProductOptions){

            set<Id> tempSetArticleIds =(mapProductOptions.get(newPo.SBQQ__ConfiguredSKU__c) != null)?mapProductOptions.get(newPo.SBQQ__ConfiguredSKU__c):new set<Id>();

            if(tempSetArticleIds.contains(newPo.SBQQ__OptionalSKU__c)){
                newPo.addError(System.Label.VR_checkDoubleArticleForProduct);
            }
            
        }
        
    }
    
    /*
    * @Method       updateRequiredFields 
    * @Author       Moganaden Curpen <moganaden.curpen@conforth-karoo.eu>
    * @Date         23/12/2022
    * @Description  Update corresponding Required_For_XXX fields from RequiredFor
    */
    public static void updateRequiredFields(List<SBQQ__ProductOption__c> lstRequiredForPO){
        
        for(SBQQ__ProductOption__c po : lstRequiredForPO){
            system.debug('MCU po : ' + po);
            //Reset fields.
            po.Required_For_Newcli__c = null;
            po.Required_For_Newbiz__c = null; // Newbiz/cross-sell
            po.Required_For_Upsell_Only__c = null;
            po.Required_For_Renew__c = null;
            po.Required_For_Migration_OPS__c = null;
            po.Required_For_Migration_SS__c = null;
            po.Required_For_Migration_OPOP__c = null;
            
            if(po.RequiredFor__c <> null) {       
                for(String rfValues : po.RequiredFor__c.split(';')){
                    if(rfValues == '111') //NewCli
                        po.Required_For_Newcli__c = '111'; 
                    else if(rfValues == '121') //Newbiz/Cross-sell
                        po.Required_For_Newbiz__c = '121'; //TO CHANGE TO FIELD CROSS-SELL
                    else if(rfValues == '411') // Upsell only	
                        po.Required_For_Upsell_Only__c = '411'; 
                    else if(rfValues == '511') // Renew
                        po.Required_For_Renew__c = '511'; 
                    else if(rfValues == '611') // Migration OP/SaaS	
                        po.Required_For_Migration_OPS__c = '611'; 
                    else if(rfValues == '612') // Migration SaaS/SaaS	
                        po.Required_For_Migration_SS__c = '612'; 
                    else if(rfValues == '613') // Migration OP/OP
                        po.Required_For_Migration_OPOP__c = '613'; 
                }//endFor
            }//endIf
        }//endFor
        
    }
    
    
    /*
    * @Method       upsertChildRecords 
    * @Author       Moganaden Curpen <moganaden.curpen@conforth-karoo.eu>
    * @Date         05/01/2023
    * @Description  Upsert RequiredProductBySalesPurpose records
    */
    public static void upsertChildRecords(Map<Id,SBQQ__ProductOption__c> mapRequiredForPO){
        system.debug('MCU START upsertChildRecords : ');
        Map<String, RequiredProductBySalesPurpose__c> mapRPSP = new Map<String, RequiredProductBySalesPurpose__c>();
        List<RequiredProductBySalesPurpose__c> lstRPSP = new List<RequiredProductBySalesPurpose__c>();
        Set<String> setExternalId = new Set<String>();
        
        for(RequiredProductBySalesPurpose__c rpsp : [SELECT id,ProductOption__c,externalId__c
                                                  	 FROM RequiredProductBySalesPurpose__c
                                                     WHERE ProductOption__c =: mapRequiredForPO.keySet()]){
			mapRPSP.put(rpsp.externalId__c,rpsp);                                                      
        }
        
        for(SBQQ__ProductOption__c po : mapRequiredForPO.values()){
            if(po.RequiredFor__c <> null) {
                for(String rfValues : po.RequiredFor__c.split(';')){
                    String externalId = String.valueOf(po.Id + '_' + rfValues);
                    
                    RequiredProductBySalesPurpose__c rpsp = new RequiredProductBySalesPurpose__c();
                    rpsp.ProductOption__c = po.Id;
                    rpsp.ParentProduct__c = po.SBQQ__ConfiguredSKU__c;
                    rpsp.Product__c = po.SBQQ__OptionalSKU__c;
                    rpsp.Required__c  = true;
                    rpsp.Type__c = 'Show & Add';
                    rpsp.SalesPurpose__c = rfValues;
                    rpsp.externalId__c = externalId;
                    
                    lstRPSP.add(rpsp);              
                    setExternalId.add(externalId);
                
            	}//endFor
            }//endIf            
        }//endFor

        for(String externalId : setExternalId){
            if(mapRPSP.containsKey(externalId))
                mapRPSP.remove(externalId);
            
        }
        
        if(mapRPSP.size() > 0)
            delete mapRPSP.values();
        
        if(lstRPSP.size() > 0)
            upsert lstRPSP externalId__c;
        
    }
    
    
    /*
    * @Method       upsertProductRules 
    * @Author       Moganaden Curpen <moganaden.curpen@conforth-karoo.eu>
    * @Date         05/01/2023
    * @Description  Upsert ProductRules records
    */
    public static void upsertProductRules(Map<Id,String> mapProductName,Set<Id> setIdConfiguredSKU){
        system.debug('MCU START upsertProductRules : ');
        List<SBQQ__ProductRule__c> lstProductRuleToDel = new List<SBQQ__ProductRule__c>();
        List<SBQQ__ProductRule__c> lstProductRules = new List<SBQQ__ProductRule__c>();
        List<SBQQ__LookupQuery__c> lstLookupQueries = new List<SBQQ__LookupQuery__c>();
        List<SBQQ__LookupQuery__c> lstLookupQueriesSalesPurpose = new List<SBQQ__LookupQuery__c>();
        List<SBQQ__ConfigurationRule__c> lstConfigRules = new List<SBQQ__ConfigurationRule__c>();
        List<SBQQ__ConfigurationAttribute__c> lstConfigAttributes = new List<SBQQ__ConfigurationAttribute__c>();
        
        List<Schema.PicklistEntry> picklistEntries = SBQQ__ProductOption__c.RequiredFor__c.getDescribe().getPicklistValues();
		Map<String,String> mapRequiredValues = new Map<String,String>();
        
        Map<String,String> mapTestedFields = new Map<String,String>{'111'=>'Required_For_Newcli__c',
            														'121'=>'Required_For_Newbiz__c',
            														'411'=>'Required_For_Upsell_Only__c',
            														'511'=>'Required_For_Renew__c',
            														'611'=>'Required_For_Migration_OPS__c',
            														'612'=>'Required_For_Migration_SS__c',
            														'613'=>'Required_For_Migration_OPOP__c'};

        for(Schema.PicklistEntry ple :picklistEntries)
            mapRequiredValues.put(ple.getValue(),ple.getLabel());
        
        
        lstProductRuleToDel = [SELECT id FROM SBQQ__ProductRule__c WHERE TECH_Configured_SKU__c IN: setIdConfiguredSKU];
        if(lstProductRuleToDel.size() > 0)
            DELETE lstProductRuleToDel;
        
        Map<Id, SBQQ__ConfigurationAttribute__c> mapConfigAttributesToDel = new Map<Id, SBQQ__ConfigurationAttribute__c>([SELECT id 
                                                                                                                          FROM SBQQ__ConfigurationAttribute__c 
                                                                                                                          WHERE SBQQ__Product__c IN: setIdConfiguredSKU]);

        if(mapConfigAttributesToDel.size() > 0){
            List<SBQQ__LookupQuery__c> lstLQ = [SELECT id FROM SBQQ__LookupQuery__c WHERE SBQQ__TestedConfigurationAttribute__c =: mapConfigAttributesToDel.keySet() ];
            if(lstLQ.size() < 1)
            	DELETE mapConfigAttributesToDel.values();
        }
            
        
        
        Map<Id,Set<String>> mapPOIdRequiredBy = new  Map<Id,Set<String>>();
        for (SBQQ__ProductOption__c poTest : [SELECT id,SBQQ__ConfiguredSKU__c,RequiredFor__c 
                                              FROM SBQQ__ProductOption__c 
                                              WHERE SBQQ__ConfiguredSKU__c IN : setIdConfiguredSKU
                                              AND RequiredFor__c != null]){
            Set<String> tempSet = new Set<String>();
            for(String rfValues : poTest.RequiredFor__c.split(';')){
				tempSet.add(rfValues);
            }
                                                  
        	if(mapPOIdRequiredBy.containsKey(poTest.SBQQ__ConfiguredSKU__c)) {
                Set<String> requiredBy = mapPOIdRequiredBy.get(poTest.SBQQ__ConfiguredSKU__c);
                requiredBy.addAll(tempSet);
                mapPOIdRequiredBy.put(poTest.SBQQ__ConfiguredSKU__c, requiredBy);
            } else {
                mapPOIdRequiredBy.put(poTest.SBQQ__ConfiguredSKU__c, tempSet);
            }                                          
                                                  
        }
            
            
        for(Id poId : mapPOIdRequiredBy.keySet()){
            
            for(String rfValues : mapPOIdRequiredBy.get(poId)){
                String priceRuleName = 'Add Options by ' + mapRequiredValues.get(rfValues) + ' for ' + mapProductName.get(poId);
                system.debug('MCU priceRuleName.length() : ' + priceRuleName.length());
                if(priceRuleName.length() > 80)
                    priceRuleName = priceRuleName.substring(0, 80);
                
                system.debug('MCU priceRuleName : ' + priceRuleName);
                system.debug('MCU priceRuleName.length()2 : ' + priceRuleName.length());
                SBQQ__ProductRule__c pr = new SBQQ__ProductRule__c();
                pr.Name = priceRuleName;
                pr.SBQQ__ConditionsMet__c = 'All';
                pr.SBQQ__Scope__c = 'Product';
                pr.SBQQ__EvaluationEvent__c = 'Always';
                pr.CurrencyIsoCode = 'EUR';
                pr.SBQQ__Type__c = 'Selection';
                pr.SBQQ__Active__c = true;
                pr.SBQQ__EvaluationOrder__c = 10;
                pr.SBQQ__LookupObject__c = 'RequiredProductBySalesPurpose__c';
                pr.SBQQ__LookupTypeField__c = 'Type__c';
                pr.SBQQ__LookupProductField__c = 'Product__c';
                pr.SBQQ__LookupRequiredField__c = 'Required__c';
                pr.TECH_Configured_SKU__c = poId;
                pr.externalId__c = rfValues + '_' + poId;
                
                lstProductRules.add(pr);
                
                
            }//endFor
          
        }//endFor
        
        if(lstProductRules.size()>0){
            insert lstProductRules;
            
            for(SBQQ__ProductRule__c pr :  lstProductRules){
                String externalId = pr.externalId__c;
                system.debug('MCU pr.externalId__c : ' + pr.externalId__c);
                List<String> lstExternalId = externalId.split('_');
                
                SBQQ__LookupQuery__c lqSP = new SBQQ__LookupQuery__c();
                lqSP.SBQQ__ProductRule__c = pr.Id;
                lqSP.SBQQ__MatchType__c = 'Field Value';
                lqSP.SBQQ__TestedObject__c = 'Quote';
                lqSP.SBQQ__TestedField__c = 'Sale_Purpose__c';
                lqSP.CurrencyIsoCode = 'EUR';
                lqSP.SBQQ__Operator__c = 'equals';
                lqSP.SBQQ__LookupField__c = 'SalesPurpose__c';
                lstLookupQueriesSalesPurpose.add(lqSP);
                
                SBQQ__LookupQuery__c lq = new SBQQ__LookupQuery__c();
                lq.SBQQ__ProductRule__c = pr.Id;
                lq.SBQQ__MatchType__c = 'Configuration Attribute Value';
                lq.SBQQ__TestedObject__c = 'Product Option';
                lq.CurrencyIsoCode = 'EUR';
                lq.SBQQ__Operator__c = 'equals';
                lq.SBQQ__LookupField__c = 'SalesPurpose__c';
                lq.externalId__c = externalId; // Used to match with the correspondin Configuration Attribute
                
                if(mapTestedFields.containsKey(lstExternalId[0]))
                	lq.SBQQ__TestedField__c = mapTestedFields.get(lstExternalId[0]);
                
                lstLookupQueries.add(lq);
                
                SBQQ__ConfigurationAttribute__c ca = new SBQQ__ConfigurationAttribute__c();
                ca.Name = 'Attribute ' + externalId;
                ca.SBQQ__DisplayOrder__c = 1;
                ca.SBQQ__ColumnOrder__c = '1';
                ca.SBQQ__Position__c = 'Top';
                ca.SBQQ__AppliedImmediately__c = true;
                ca.SBQQ__DefaultObject__c = 'Quote__c';
                ca.SBQQ__DefaultField__c = 'Sale_Purpose__c';
                ca.CurrencyIsoCode = 'EUR';
                ca.SBQQ__Product__c = lstExternalId[1];
                ca.externalId__c = externalId;
                ca.SBQQ__Hidden__c = true;
                if(mapTestedFields.containsKey(lstExternalId[0]))
                	ca.SBQQ__TargetField__c = mapTestedFields.get(lstExternalId[0]);
                
                lstConfigAttributes.add(ca);
                
                

                
                SBQQ__ConfigurationRule__c cr = new SBQQ__ConfigurationRule__c();
                cr.SBQQ__ProductRule__c = pr.Id;
                cr.SBQQ__Active__c = true;
                cr.SBQQ__Product__c = lstExternalId[1];
                cr.CurrencyIsoCode = 'EUR';
                
                lstConfigRules.add(cr);
                       
            }
        }
        
       if(lstConfigRules.size() > 0)
        	insert lstConfigRules;
        
        system.debug('MCU lstConfigAttributes : ' + lstConfigAttributes);
        if(lstConfigAttributes.size() > 0)
        	insert lstConfigAttributes;
        
        if(lstLookupQueriesSalesPurpose.size() > 0)
            insert lstLookupQueriesSalesPurpose;
        
		//Assigne ConfigurationAttibute corresponding record to the LookupQuery records
        for(SBQQ__LookupQuery__c lq : lstLookupQueries){
            for(SBQQ__ConfigurationAttribute__c ca : lstConfigAttributes){
                
                if(lq.externalId__c == ca.externalId__c)
                    lq.SBQQ__TestedConfigurationAttribute__c = ca.Id;
            
        	}
        }
            
        if(lstLookupQueries.size() > 0)
            insert lstLookupQueries;

        
    }
    
    /*
    * @Method       deleteChildRecord 
    * @Author       Moganaden Curpen <moganaden.curpen@conforth-karoo.eu>
    * @Date         05/01/2023
    * @Description  Delete RequiredProductBySalesPurpose records
    */
    public static void deleteChildRecord(Map<Id,SBQQ__ProductOption__c> mapRequiredForPO,Set<Id> setIdConfiguredSKU){
        system.debug('MCU START deleteChildRecord : ');
        system.debug('MCU mapRequiredForPO: ' +mapRequiredForPO);
		List<SBQQ__ProductRule__c> lstProductRuleToDel = new List<SBQQ__ProductRule__c>();
        
        //Delete RequiredProductBySalesPurpose records related to corresponding Product Option
        List<RequiredProductBySalesPurpose__c> lstRPSP = [SELECT id
                                                  	 	  FROM RequiredProductBySalesPurpose__c
                                                          WHERE ProductOption__c =: mapRequiredForPO.keySet()];
        system.debug('MCU lstRPSP : ' +lstRPSP);
        if(lstRPSP.size() > 0)
            Delete lstRPSP;
        
        //Delete Price Rule records related to corresponding Product Option
        lstProductRuleToDel = [SELECT id FROM SBQQ__ProductRule__c WHERE TECH_Configured_SKU__c IN: setIdConfiguredSKU];
        if(lstProductRuleToDel.size() > 0)
            DELETE lstProductRuleToDel;
        
        Map<Id, SBQQ__ConfigurationAttribute__c> mapConfigAttributesToDel = new Map<Id, SBQQ__ConfigurationAttribute__c>([SELECT id 
                                                                                                                          FROM SBQQ__ConfigurationAttribute__c 
                                                                                                                          WHERE SBQQ__Product__c IN: setIdConfiguredSKU]);
		//Delete LookupQuery records related to corresponding Product Rule
        if(mapConfigAttributesToDel.size() > 0){
            List<SBQQ__LookupQuery__c> lstLQ = [SELECT id FROM SBQQ__LookupQuery__c WHERE SBQQ__TestedConfigurationAttribute__c =: mapConfigAttributesToDel.keySet() ];
            if(lstLQ.size() < 1)
            	DELETE mapConfigAttributesToDel.values();
        }
            
    }
   
    
    
    
    
    
    
}