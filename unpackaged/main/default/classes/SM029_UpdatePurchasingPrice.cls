/**
 * @description       : Update field Purchasing Price on Product with recordType 'Product'
 * @author            : Comforth-EasyFront
 * @last modified on  : 05-05-2023
 * @last modified by  : Comforth-EasyFront
**/
public class SM029_UpdatePurchasingPrice {
    
    @InvocableMethod (label='SM029_UpdatePurchasingPrice') 
    public static void updatePurchasingPrice(List<Id> ArticleId) {
        
        Id articleRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Article').getRecordTypeId();

        Set<Id> setProductsId = new Set<Id>();
        List<Product2> lstProducts = new List<Product2>();
        
        for(SBQQ__ProductOption__c po : [SELECT id,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c
                                         FROM SBQQ__ProductOption__c
                                         WHERE SBQQ__OptionalSKU__c =: ArticleId ]){
        	setProductsId.add(po.SBQQ__ConfiguredSKU__c) ;                    
        }//endFor
        
        for(Product2 p : [SELECT id,Purchasing_Price__c, 
                          (SELECT id,SBQQ__OptionalSKU__r.Purchasing_Price__c 
                           FROM SBQQ__Options__r 
                           WHERE SBQQ__OptionalSKU__r.RecordTypeId =: articleRecordTypeId
                           AND SBQQ__OptionalSKU__r.Purchasing_Price__c <> null)
                          FROM Product2
                          WHERE Id IN :setProductsId]){
            Decimal tempPurchasingPrice = 0;
			for(SBQQ__ProductOption__c po : p.SBQQ__Options__r){
            	tempPurchasingPrice = tempPurchasingPrice + po.SBQQ__OptionalSKU__r.Purchasing_Price__c;           
			}//endFor
                              
            Product2 pro = new Product2(Id=p.Id,Purchasing_Price__c=tempPurchasingPrice);                
            lstProducts.add(pro);
                              
        }//endFor
        
        if(lstProducts.size() > 0 )
            update lstProducts;
    
    }

}