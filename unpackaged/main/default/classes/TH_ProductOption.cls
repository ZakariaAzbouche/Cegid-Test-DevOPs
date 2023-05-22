/**
* @author Keshav - Comforth
* @date 2020-06-04
* @modified 2020-06-04
* @group TH_ProductOption
* @object Product Option
* @description 
*/

public without sharing class TH_ProductOption extends TriggerHandler {
    
    BypassTrigger__c getAuth = BypassTrigger__c.getOrgDefaults();

    public override void beforeInsert() {
        if(getAuth.Activatetrigger__c){
            List<SBQQ__ProductOption__c> lstRequiredForPO = new List<SBQQ__ProductOption__c>();
            SM002_ProductOption.checkDoubleRecords(Trigger.new, false); 
            //MCU : W-002249
            for(SBQQ__ProductOption__c po: (List<SBQQ__ProductOption__c>)Trigger.new){
                if(po.RequiredFor__c <> null){
                    lstRequiredForPO.add(po);
                } 
            }// end loop
            
            if(lstRequiredForPO.size() > 0)
                SM002_ProductOption.updateRequiredFields(lstRequiredForPO);
        }
    }
    
    public override void afterInsert() {
        /*if(getAuth.Activatetrigger__c){
            SM002_ProductOption.updatePurchasingPrice(Trigger.new, false);
        }*/
        
        //handle auto update of Tech_HasOnSiteArticle__c on configured SKU product2
        Set<Id> setIdProd2ConfSKU = new Set<Id>();
        Set<Id> setIdConfiguredSKU = new Set<Id>();
		Map<Id,SBQQ__ProductOption__c> mapRequiredForPO = new Map<Id,SBQQ__ProductOption__c>();
        Map<Id,String> mapProductName = new Map<Id,String>();
		
        set<Id> setConfiguredSKUId = new set<Id>();
        set<Id> setProductOptionId = new set<Id>();
        
        for(SBQQ__ProductOption__c prodOpt:(List<SBQQ__ProductOption__c>)Trigger.new){
            if(canTriggerByFeature('FlagHasOnSiteArticle__c') && 
                prodOpt.SBQQ__ConfiguredSKU__c != null){
                setIdProd2ConfSKU.add(prodOpt.SBQQ__ConfiguredSKU__c);               
            }    
            
            if(prodOpt.RequiredFor__c != null){
                mapRequiredForPO.put(prodOpt.Id,prodOpt); 
                mapProductName.put(prodOpt.SBQQ__ConfiguredSKU__c,prodOpt.TECH_ConfiguredSKUName__c);
                setIdConfiguredSKU.add(prodOpt.SBQQ__ConfiguredSKU__c);            
            }
            
            if(getAuth.Activatetrigger__c && 
               prodOpt.SBQQ__ConfiguredSKU__c != null){
                   setConfiguredSKUId.add(prodOpt.SBQQ__ConfiguredSKU__c); 
                   setProductOptionId.add(prodOpt.Id);
            }
				              
        }
        
        if(setIdProd2ConfSKU.size()>0){
            SM007_FlagProductHasOnSiteArticle.updateHasOnSiteArticle(setIdProd2ConfSKU);
        }
        
        if(mapRequiredForPO.size() > 0){
            SM002_ProductOption.upsertChildRecords(mapRequiredForPO);
            SM002_ProductOption.upsertProductRules(mapProductName,setIdConfiguredSKU);
        }
        
        if(setConfiguredSKUId.size() > 0)
            SM002_ProductOption.updatePurchasingPrice(setConfiguredSKUId, setProductOptionId, false);
        
    }
    
    public override void beforeUpdate() {
        if(getAuth.Activatetrigger__c){
            
            List<SBQQ__ProductOption__c> lstRequiredForPO = new List<SBQQ__ProductOption__c>();
            //MCU : W-002249
            for(SBQQ__ProductOption__c po: (List<SBQQ__ProductOption__c>)Trigger.new){
                SBQQ__ProductOption__c oldPo = (SBQQ__ProductOption__c)trigger.oldMap.get(po.Id);
                
                if(oldPo.RequiredFor__c != po.RequiredFor__c){
                    lstRequiredForPO.add(po);
                } 
            }// end loop
            
            if(lstRequiredForPO.size() > 0)
                SM002_ProductOption.updateRequiredFields(lstRequiredForPO);
            
        }
    }
    
    public override void afterUpdate() {
        /*if(getAuth.Activatetrigger__c){
            SM002_ProductOption.updatePurchasingPrice(Trigger.new, false);
        }*/
        //check changement des champs(duration/servicetrem, realization) si changement appeler methode 'resetParentHasonsitearticle'
        
        //handle auto update of Tech_HasOnSiteArticle__c on configured SKU product2
        Set<Id> setIdProd2ConfSKU = new Set<Id>();
        Set<Id> setIdConfiguredSKU = new Set<Id>();
        Map<Id,SBQQ__ProductOption__c> mapRequiredForPO = new Map<Id,SBQQ__ProductOption__c>();
        Map<Id,String> mapProductName = new Map<Id,String>();
        
        //set<Id> setConfiguredSKUId = new set<Id>();
        //set<Id> setProductOptionId = new set<Id>();
        
        for(SBQQ__ProductOption__c prodOpt:(List<SBQQ__ProductOption__c>)Trigger.new){
            SBQQ__ProductOption__c oldProdOpt = (SBQQ__ProductOption__c)trigger.oldMap.get(prodOpt.Id);
            if(canTriggerByFeature('FlagHasOnSiteArticle__c') && 
                (oldProdOpt.SBQQ__OptionalSKU__c != prodOpt.SBQQ__OptionalSKU__c ||
                oldProdOpt.SBQQ__ConfiguredSKU__c != prodOpt.SBQQ__ConfiguredSKU__c)){
                setIdProd2ConfSKU.add(prodOpt.SBQQ__ConfiguredSKU__c);
                setIdProd2ConfSKU.add(oldProdOpt.SBQQ__ConfiguredSKU__c);                              
            }   
            
            if(oldProdOpt.RequiredFor__c != prodOpt.RequiredFor__c){
                mapRequiredForPO.put(prodOpt.Id,prodOpt);
                mapProductName.put(prodOpt.SBQQ__ConfiguredSKU__c,prodOpt.TECH_ConfiguredSKUName__c);
                setIdConfiguredSKU.add(prodOpt.SBQQ__ConfiguredSKU__c); 
            }
            //system.debug('MCU getAuth.Activatetrigger__c : ' + getAuth.Activatetrigger__c);
		    //system.debug('MCU prodOpt.SBQQ__ConfiguredSKU__c : ' + prodOpt.SBQQ__ConfiguredSKU__c);
            //if(getAuth.Activatetrigger__c && 
            //   prodOpt.SBQQ__ConfiguredSKU__c != null){
            //       setConfiguredSKUId.add(prodOpt.SBQQ__ConfiguredSKU__c);
            //       setProductOptionId.add(prodOpt.Id);
            //}
				  
				     
            
        }
        
        if(setIdProd2ConfSKU.size()>0){
            SM007_FlagProductHasOnSiteArticle.updateHasOnSiteArticle(setIdProd2ConfSKU);
        }
        
        if(mapRequiredForPO.size() > 0){
            SM002_ProductOption.upsertChildRecords(mapRequiredForPO);
            SM002_ProductOption.upsertProductRules(mapProductName,setIdConfiguredSKU);
        }
        
        //if(setConfiguredSKUId.size() > 0)
        //    SM002_ProductOption.updatePurchasingPrice(setConfiguredSKUId, setProductOptionId, false);
        
    }
    
    public override void beforeDelete() {
        /*if(getAuth.Activatetrigger__c){
            SM002_ProductOption.updatePurchasingPrice(Trigger.old, true);
        }*/
        
        Map<Id,SBQQ__ProductOption__c> mapRequiredForPO = new Map<Id,SBQQ__ProductOption__c>();
        Set<Id> setIdConfiguredSKU = new Set<Id>();
        
        set<Id> setConfiguredSKUId = new set<Id>();
        set<Id> setProductOptionId = new set<Id>();
        
        for(SBQQ__ProductOption__c prodOpt:(List<SBQQ__ProductOption__c>)Trigger.old){
            system.debug('MCU mapRequiredForPO : ' + mapRequiredForPO);
            if(prodOpt.RequiredFor__c != null){
				mapRequiredForPO.put(prodOpt.Id,prodOpt);
                setIdConfiguredSKU.add(prodOpt.SBQQ__ConfiguredSKU__c);
            }
            
            if(getAuth.Activatetrigger__c){
                   setConfiguredSKUId.add(prodOpt.SBQQ__ConfiguredSKU__c);
                   setProductOptionId.add(prodOpt.Id);
            }
        }
        
        if(mapRequiredForPO.size() > 0 )
            SM002_ProductOption.deleteChildRecord(mapRequiredForPO,setIdConfiguredSKU);
        
        if(setConfiguredSKUId.size() > 0)
            SM002_ProductOption.updatePurchasingPrice(setConfiguredSKUId, setProductOptionId, true);
    }

    /**
     * @author Shamina M - Comforth Karoo
     * @date 2020-09-15
     * @description afterDelete logic          
    */
    public override void afterDelete() {
        //handle auto update of Tech_HasOnSiteArticle__c on configured SKU product2
        Set<Id> setIdProd2ConfSKU = new Set<Id>();
        
        for(SBQQ__ProductOption__c prodOpt:(List<SBQQ__ProductOption__c>)Trigger.old){
            if(canTriggerByFeature('FlagHasOnSiteArticle__c') && 
                prodOpt.SBQQ__ConfiguredSKU__c != null){
                setIdProd2ConfSKU.add(prodOpt.SBQQ__ConfiguredSKU__c);               
            }   
            
        }
        
        if(setIdProd2ConfSKU.size()>0){
            SM007_FlagProductHasOnSiteArticle.updateHasOnSiteArticle(setIdProd2ConfSKU);
        }      
            
    }
}