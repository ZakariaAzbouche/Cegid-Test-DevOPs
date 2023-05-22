/**
 * @description       : Classe de test pour SM029_UpdatePurchasingPrice
 * @author            : Comforth-EasyFront
 * @last modified on  : 16-01-2023
 * @last modified by  : Moganaden Curpen
**/
@isTest
public class SM029_UpdatePurchasingPrice_TEST {
    
    
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'primarycontact@email.com';
    static BypassTrigger__c bt= new BypassTrigger__c();
    
    @TestSetup static void setup(){    
        
        System.runAs(adminUser){ 
            //create product List
            List<Product2> listProductList = new List<Product2>{
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
                
            listArticle[0].Name = 'ArticleMCU1';
            listArticle[0].Purchasing_Price__c = 1.0;
            listArticle[1].Purchasing_Price__c = 2.0;
            listArticle[2].Purchasing_Price__c = 3.0;
            listArticle[3].Purchasing_Price__c = 4.0;
            listArticle[4].Purchasing_Price__c = 5.0;
            listArticle[5].Purchasing_Price__c = 6.0;
            insert listArticle;
            
            List<SBQQ__ProductOption__c> listProductArticle = new List<SBQQ__ProductOption__c>{
                    new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[0].Id, listProductList[0].Id),
                    new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[1].Id, listProductList[0].Id),
                    new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[2].Id, listProductList[0].Id),
                    new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[3].Id, listProductList[1].Id),
                    new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[4].Id, listProductList[1].Id),
                    new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[5].Id, listProductList[1].Id)
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

            bt.Activatetrigger__c = true;
            bt.SetupOwnerId = UserInfo.getOrganizationId();
            insert bt;
            
        }
    }
    
     @isTest static void testSM002_ProductOptionUpdate() {
        System.runAs(adminUser){
            Test.startTest();
            Product2 pro = [SELECT id,Purchasing_Price__c FROM Product2 WHERE Name = 'ArticleMCU1'];
            pro.Purchasing_Price__c = 2.0;
            update pro;
            
            
           // system.assertEquals(200, listProductOption[0].SBQQ__OptionalSKU__r.Purchasing_Price__c);
            
            Test.stopTest();
        }
    }
    
    
    

}