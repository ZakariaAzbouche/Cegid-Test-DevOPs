/**
* @author Keshav M- Comforth
* @date Creation 05 June 2020
* @description Test class for trigger logic SM002_ProductOption
*              
*/
@isTest
public class SM002_ProductOption_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'primarycontact@email.com';
    static BypassTrigger__c bt= new BypassTrigger__c();
    
    @TestSetup static void setup(){    
        
        System.runAs(adminUser){ 
            //create product List
            List<Product2> listProductList = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                     new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                     new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                     new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
                    };
                        
                        listProductList[0].Name = 'test ProductArticle';
            insert listProductList;
            
            
            //create Article
            List<Product2> listArticle = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Article', ''),
                    new UTIL_TestFactory.ProductFactory().createProduct('Article', ''),
                    new UTIL_TestFactory.ProductFactory().createProduct('Article', ''),
                    new UTIL_TestFactory.ProductFactory().createProduct('Article', ''),
                    new UTIL_TestFactory.ProductFactory().createProduct('Article', ''),
                    new UTIL_TestFactory.ProductFactory().createProduct('Article', '')
                    };
                        insert listArticle;
            
            List<SBQQ__ProductOption__c> listProductArticle = new List<SBQQ__ProductOption__c>{
                    new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[0].Id, listProductList[0].Id),
                    new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[1].Id, listProductList[1].Id),
                    new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[2].Id, listProductList[2].Id),
                    new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[3].Id, listProductList[3].Id),
                    new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[4].Id, listProductList[4].Id),
                    new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[5].Id, listProductList[5].Id)
                     };
                      
                        listProductArticle[0].RequiredFor__c = '111';
                        listProductArticle[0].SBQQ__AppliedImmediately__c = TRUE;
            			listProductArticle[0].SBQQ__AppliedImmediatelyContext__c = 'Always';
                        listProductArticle[1].RequiredFor__c = '411';
                        listProductArticle[1].SBQQ__AppliedImmediately__c = TRUE;
            			listProductArticle[1].SBQQ__AppliedImmediatelyContext__c = 'Always';
                        listProductArticle[2].RequiredFor__c = '511';
                        listProductArticle[2].SBQQ__AppliedImmediately__c = TRUE;
            			listProductArticle[2].SBQQ__AppliedImmediatelyContext__c = 'Always';
                        listProductArticle[3].RequiredFor__c = '611';
                        listProductArticle[3].SBQQ__AppliedImmediately__c = TRUE;
            			listProductArticle[3].SBQQ__AppliedImmediatelyContext__c = 'Always';
                        listProductArticle[4].RequiredFor__c = '612';
                        listProductArticle[4].SBQQ__AppliedImmediately__c = TRUE;
            			listProductArticle[4].SBQQ__AppliedImmediatelyContext__c = 'Always';
                        listProductArticle[5].RequiredFor__c = '613';
                        listProductArticle[5].SBQQ__AppliedImmediately__c = TRUE;
            			listProductArticle[5].SBQQ__AppliedImmediatelyContext__c = 'Always';
       
                        
                        insert listProductArticle;
            
                       system.debug('YGO' +listProductArticle);
                       
                       List<string> listRfValues = listProductArticle[0].RequiredFor__c.split(';');
                       string rfValues = listRfValues[0];
                       string externalId = String.valueOf(listProductArticle[0].Id + '_' + rfValues);
            
            List<RequiredProductBySalesPurpose__c> Listrpsp = new List<RequiredProductBySalesPurpose__c>{
                new UTIL_TestFactory.RequiredProductBySalesPurpose().Createrpsp(listProductArticle[0].Id, listProductArticle[0].SBQQ__ConfiguredSKU__c,rfValues,externalId)
                
            };
            
                
            
            bt.Activatetrigger__c = true;
            bt.SetupOwnerId = UserInfo.getOrganizationId();
            insert bt;
            
        }
    }
    
     @isTest static void testSM002_ProductOptionUpdate() {
        System.runAs(adminUser){
            Test.startTest();
            list<SBQQ__ProductOption__c> listProductOption = new list<SBQQ__ProductOption__c>();
            
            for(SBQQ__ProductOption__c po:[SELECT id, SBQQ__OptionalSKU__c,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__r.Purchasing_Price__c,SBQQ__ConfiguredSKU__r.Purchasing_Price__c, name 
                                           from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__r.Name = 'test ProductArticle' limit 1]){
                                               po.SBQQ__Number__c = 2;
                                               listProductOption.add(po);
                                               
                                           }
            
            update listProductOption;
            
            
           // system.assertEquals(200, listProductOption[0].SBQQ__OptionalSKU__r.Purchasing_Price__c);
            
            Test.stopTest();
        }
    }
    
    
    @isTest static void testSM002_ProductOptionDelete() {
        System.runAs(adminUser){
            Test.startTest();
            list<SBQQ__ProductOption__c> listProductOption = new list<SBQQ__ProductOption__c>();
            
            for(SBQQ__ProductOption__c po:[SELECT id, SBQQ__OptionalSKU__c,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__r.Purchasing_Price__c,SBQQ__ConfiguredSKU__r.Purchasing_Price__c, name 
                                           from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__r.Name = 'test ProductArticle']){
                                               po.SBQQ__Number__c = 2;
                                               listProductOption.add(po);
                                           }
            
            system.debug('listProductOption delete' + listProductOption);
            delete listProductOption;
            //system.assertEquals(null, listProductOption[0].SBQQ__ConfiguredSKU__r.Purchasing_Price__c);
            Test.stopTest();
        }
    }
    
    @isTest static void testSM002_CheckDouble() {
        System.runAs(adminUser){
            
            List<Product2> listpro = [SELECT id,Name from Product2 where Name ='test ProductArticle' limit 1];
            Product2 rtarticle =  new UTIL_TestFactory.ProductFactory().createProduct('Article', '');
            
            
            Insert rtarticle;
            
            SBQQ__ProductOption__c sbqq = new UTIL_TestFactory.ProductOptionFactory().createProductOption(rtarticle.Id, listpro[0].Id);
            sbqq.SBQQ__AppliedImmediately__c = TRUE;
            sbqq.SBQQ__AppliedImmediatelyContext__c = 'Always';
            
            Test.startTest();
            Insert sbqq;
            Test.stopTest();
        }
    }
    
    
    
    @isTest static void testSM002_updateRequiredFields() {
                System.runAs(adminUser){
                    
                //list<SBQQ__ProductOption__c> listProductOption = [SELECT id FROM SBQQ__ProductOption__c];
                    
                List<SBQQ__ProductOption__c> listProductOption = [SELECT Required_For_Newcli__c, Required_For_Upsell_Only__c, Required_For_Renew__c, Required_For_Migration_OPS__c,
                                                               Required_For_Migration_SS__c, Required_For_Migration_OPOP__c, RequiredFor__c FROM SBQQ__ProductOption__c];
                
                Test.startTest();
                    
                    SM002_ProductOption.updateRequiredFields(listProductOption);
                    
                    
                Test.stopTest();
                }
                
        
    }
    
    @isTest static void testSM002_upsertChildRecords(){
               System.runAs(adminUser){
               
               Map<Id, SBQQ__ProductOption__c > mapPo = new Map<Id, SBQQ__ProductOption__c>();
                   
               SBQQ__ProductOption__c po = [SELECT id,Required_For_Renew__c, Required_For_Migration_OPS__c,
                                                   Required_For_Migration_SS__c, Required_For_Migration_OPOP__c, RequiredFor__c, 
                                                   SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c
                                            FROM SBQQ__ProductOption__c 
                                            WHERE RequiredFor__c ='111' limit 1];
               po.RequiredFor__c = '411';
                   
               update po;
                   
               RequiredProductBySalesPurpose__c rpsp = [select ProductOption__c, ProductOption__r.SBQQ__ConfiguredSKU__c,Required__c,SalesPurpose__c ,externalId__c, Type__c       
               from RequiredProductBySalesPurpose__c LIMIT 1];
                
                   
                mapPo.put(po.Id, po);
                   
               Test.startTest();
                    
                    SM002_ProductOption.upsertChildRecords(mapPo);
                   
                    
                   
                   
                   
                    
                    
                Test.stopTest();
                   
        
    }
        
}
    
    
}