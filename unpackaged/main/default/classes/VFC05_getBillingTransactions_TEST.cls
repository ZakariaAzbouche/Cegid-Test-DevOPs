/**
* @author Moganaden C - Comforth
* @date 2023-04-12
* @description VFC05_getBillingTransactions_TEST          
*/
@isTest
public class VFC05_getBillingTransactions_TEST {
    
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'primarycontact@email.com';
    @testSetup static void setup(){
        System.runAs(adminUser){ 
            Insert new BypassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), Activatetrigger__c = True); 

            Test.startTest();
            //create account
            List<Account> listAcc = new List<Account>();
            for(Integer i=0; i<1;i++ ){
                listAcc.add( new UTIL_TestFactory.AccountFactory().createAccountWithNature(i));
            }
            insert listAcc;

            //create contact
            Contact primaryContact = new UTIL_TestFactory.ContactFactory().createContact(listAcc[0].Id);
            primaryContact.Email = PRIMARY_CONTACT_EMAIL;
            insert primaryContact;

            PriceBook2 standardPricebook = new UTIL_TestFactory.PricebookFactory().activateStdPriceBook();

            //create opportunity
            List<Opportunity> listOpp = new List<Opportunity>();
            for(Integer i=0; i<1;i++){
                listOpp.add(new UTIL_TestFactory.OpportunityFactory().createOpportunity(listAcc[i].Id, false, false));
            }
            insert listOpp;
        
            //create product2
            List<Product2> listProduct = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost')
            };
            insert listProduct;

            List<PricebookEntry> listPBE = new List<PricebookEntry>{
                new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(standardPricebook.id, listProduct[0].id)
            };
            insert listPBE; 

            //create quote in mass (cannot create more than that because of SOQL & CPU limit exceeded from CPQ SBQQ package)
            List<SBQQ__Quote__c> listQuotes = new List<SBQQ__Quote__c>();
            for(Integer i=0; i<1;i++ ){
                listQuotes.add(new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteV2(listOpp[i].Id, listAcc[i].Id, primaryContact.Id, listAcc[i].Id));
            }
            insert listQuotes;
            
            
            //create BillingPlan
            List<BillingPlan__c> listBillingPlan = new List<BillingPlan__c>{
                new BillingPlan__c(Quote__c=listQuotes[0].Id)
            };
            insert listBillingPlan;

 			//create BillingTransaction
            List<BillingTransaction__c> listBillingTransaction = new List<BillingTransaction__c>{
                new BillingTransaction__c(Name='Order',Step__c='1',EstimatedDate__c = date.today(),MaxDate__c = date.today(),BillingPlan__c = listBillingPlan[0].Id,Percentage__c = 2 )
            };
            insert listBillingTransaction;
            
        	Test.stopTest();

        }//end RunAs
    }//end setup
    
    
    
    static testMethod void test_init() {
		System.runAs(adminUser){
			SBQQ__Quote__c QuoteId = [SELECT Id FROM SBQQ__Quote__c limit 1];
            
            Test.startTest(); 
            
			PageReference pageRef = Page.VFP05_getBillingTransactions;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('qid',QuoteId.id);
            
            VFC05_getBillingTransactions vfc05 = new VFC05_getBillingTransactions();
            vfc05.init();
            Test.stopTest();
             
         }
     }

}